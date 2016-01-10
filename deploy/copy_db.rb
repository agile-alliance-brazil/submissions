#!/usr/bin/env ruby

require 'English'
require 'yaml'

if ARGV.size < 2
  puts "Usage: #{__FILE__} <origin_host> <destination_host> [<type>]"
  puts ''
  puts "<origin_host>\t\tIP address or host uri without protocol. Eg submissoes-staging.agilebrazil or 107.170.116.137"
  puts "<destination_host>\tIP address or host uri without protocol. Eg submissoes-staging.agilebrazil or 107.170.116.137"
  puts "<type>\t\t\tOptional. Defaults to staging. Valid values are 'staging' or 'production'."
  exit 1
end

ORIGIN = ARGV[0]
DESTINATION = ARGV[1]

TYPE = ARGV.size > 2 ? (ARGV[2].to_sym == :production ? :production : :staging) : :staging
staging = TYPE != :production
POSTFIX = staging ? '_staging' : ''
ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../'))
USER = 'ubuntu'
prod_db_info = YAML.load_file("#{ROOT}/config/#{TYPE}_database.yml")['production']
db = prod_db_info['database']
user = prod_db_info['username']
password = prod_db_info['password']

def execute(command)
  puts "executing #{command}"
  result = `#{command}`
  status = $CHILD_STATUS.to_i
  return true if status == 0

  puts "ERROR: #{result}"
  exit status
end

timestamp = Time.now.getlocal.strftime('%Y%m%d-%H%M')
filepath = "/tmp/#{timestamp}-snapshot.sql"
dump_command = "mysqldump -u #{user} -p#{password} #{db} --result-file=#{filepath}"
load_command = "mysql -u #{user} -p#{password} #{db} < #{filepath}"

execute("ssh -i certs/digital_ocean#{POSTFIX} #{USER}@#{ORIGIN} '#{dump_command}'")
execute("scp -3 -i certs/digital_ocean#{POSTFIX} #{USER}@#{ORIGIN}:#{filepath} #{USER}@#{DESTINATION}:#{filepath}")
execute("ssh -i certs/digital_ocean#{POSTFIX} #{USER}@#{DESTINATION} '#{load_command}'")

puts "SUCCESS: Data in DB #{db} loaded from #{ORIGIN} to #{DESTINATION}"
