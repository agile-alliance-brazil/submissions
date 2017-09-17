#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'

if ARGV.count < 2
  puts <<~USAGE
    Usage: #{File.basename(__FILE__)} <user> <target_machine> [<machine_type>] [<optional_ssh_key>]

    <user>:\t\t\t\t The user that will be used to ssh into the machine. Either root for Digital Ocean machines or ubuntu for AWS EC2 machines. It MUST have an ssh key already set up to ssh into.
    <target_machine>:\t The public DNS or public IP address of the machine to be deployed
    <machine_type>:\t\t Optional. Either 'production' or 'staging'. Anything other than 'production' is considered staging. Used for deploy configurations.
    <optional_ssh_key>:\t Optional. The path to the ssh key to be used to log in with the specified user on the specified machine
USAGE
  exit(1)
end

@user = ARGV[0]
@target, @port = ARGV[1].split(':')
@port ||= 22
@type = ARGV[2].to_sym if ARGV.size > 2
RAILS_ROOT = File.join(File.dirname(__FILE__), '..')
@key_path = ARGV[3] if ARGV.size > 3
REMOTE_SHARED_FOLDER = '/srv/apps/submissions/shared'

def files_to_upload
  [
    'config/config.yml',
    'config/database.yml',
    'config/newrelic.yml'
  ]
end

def optional_files
  [
    'certs/server.crt',
    'certs/server_key.pem',
    'certs/intermediate.crt'
  ]
end

def tag_with_target(file)
  File.expand_path File.join(RAILS_ROOT, file.reverse.sub('/', "/#{@target}_".reverse).reverse)
end

def origin_files
  files_to_upload.map { |file| tag_with_target(file) }
end

def missing_files
  origin_files.reject { |file| File.exist?(file) }
end

unless missing_files.empty?
  puts 'Cannot deploy until the following files are available.'
  puts ''
  missing_files.each do |file|
    puts file.to_s
  end
  exit(1)
end

def execute(command)
  puts "Running: #{command}"
  result = system(command)
  puts result unless $CHILD_STATUS.to_i.zero?
  result
end

def key_param
  @key_path.nil? ? '' : "-i #{File.expand_path(@key_path)}"
end

execute %(scp -P #{@port} #{key_param} #{File.expand_path(File.join(RAILS_ROOT, '/puppet/script/server_bootstrap.sh'))} #{@user}@#{@target}:~)
execute %(ssh -t -t -p #{@port} #{key_param} #{@user}@#{@target} '/bin/chmod +x ~/server_bootstrap.sh && /bin/bash ~/server_bootstrap.sh #{@user}')
unless File.exist?("config/deploy/#{@target}.rb")
  deploy_configs = File.read(File.join(RAILS_ROOT, "config/deploy/#{@type}.rb"))
  File.open("config/deploy/#{@target}.rb", 'w+') do |file|
    file.write deploy_configs.gsub(/server '[^']+'/, "server '#{@target}'")
  end
end

@deployed_user = File.read("config/deploy/#{@target}.rb").match(/user[^']+'([^']+)'/)[1]
execute %(bundle)
execute %(bundle exec cap #{@target} deploy:check:directories deploy:check:make_linked_dirs LOG_LEVEL=error)
files_to_upload.each do |file|
  execute %(ssh -p #{@port} #{key_param} #{@user}@#{@target} 'mkdir -p #{File.dirname("#{REMOTE_SHARED_FOLDER}/#{file}")}')
  execute %(scp -P #{@port} #{key_param} #{tag_with_target(file)} #{@deployed_user}@#{@target}:#{REMOTE_SHARED_FOLDER}/#{file})
end
optional_files.each do |file|
  if File.exist? tag_with_target(file)
    execute %(ssh -p #{@port} #{key_param} #{@user}@#{@target} 'mkdir -p #{File.dirname("#{REMOTE_SHARED_FOLDER}/#{file}")}')
    execute %(scp -P #{@port} #{key_param} #{tag_with_target(file)} #{@deployed_user}@#{@target}:#{REMOTE_SHARED_FOLDER}/#{file})
  end
end
execute %(bundle exec cap #{@target} deploy LOG_LEVEL=error)
execute %(bundle exec cap #{@target} deploy LOG_LEVEL=error)
