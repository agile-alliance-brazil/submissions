#!/usr/bin/env ruby

RAILS_ROOT = File.expand_path(File.dirname(__FILE__), '../')

def ssh_config_path
  "#{ENV['HOME']}/.ssh/config"
end

def ssh_config
  @ssh_config_lines ||= File.readlines(ssh_config_path)
end

def ssh_config_template(id_file, host_ip, host_port=22)
  %Q{Host #{host_ip}
    HostName #{host_ip}
    User vagrant
    Port #{host_port}
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    PasswordAuthentication no
    IdentityFile "#{id_file}"
    IdentitiesOnly yes
    LogLevel FATAL}
end

def vagrantfile_lines
  @vagrantfile_lines ||= File.readlines("#{RAILS_ROOT}/Vagrantfile")
end

def get_vm_config_lines(vm_name)
  config = vagrantfile_lines
  config_lines = []
  definition_start_index = config.index{|l| l.match(/vm.define\W+#{vm_name}\W/}
  return [] if definition_start_index < 0

  level = 0
  current_index = definition_start_index
  loop do
    line = config[current_index]
    if line.match(/\Wdo\s*(?:\s*\|[^|]*\|)?$/)
      level += 1
    elsif line.match(/[\s;]?end\s*$/)
      level -= 1
    end
    config_lines << line
    break if level == 0
  end
  config_lines
end

def extract_local_ip_from_vagrantfile(box_name)
  config_lines = get_vm_config_lines(box_name)
  match = config_lines.map{|l| l.match(/vm\.network :private_network, ip:\s*['"]([^,]+)['"]/)}.compact.last
  match.nil? : nil : match[1]
end

def extract_ssh_port_from_vagrantfile(box_name)
  config_lines = get_vm_config_lines(box_name)
  match = config_lines.map{|l| l.match(/vm\.network :forwarded_port.*ssh.*host[^,]*(\d+),?$/)}.compact.last
  match.nil? : nil : match[1]
end

def vagrant_config(vagrant_name)
  configs = []
  id_file = "#{RAILS_ROOT}/.vagrant/machines/#{vagrant_name}/virtualbox/private_key"
  host_ip = extract_local_ip_from_vagrantfile(vagrant_name)
  if host_ip
    config << ssh_config_template(id_file, host_ip)
  end
  mapped_ssh_port = extract_ssh_port_from_vagrantfile(vagrant_name)
  if mapped_ssh_port
    config << ssh_config_template(id_file, '127.0.0.1', mapped_ssh_port)
  end
  configs
end

configs = (vagrant_config('dev') + vagrant_config('deploy'))
configs.each do |config|
  host_info = config.split("\n").first
  unless @ssh_config_lines.find{|l| l.match(host_info)}
    File.open(ssh_config_path, '+a') { |f| f.puts(config) }
  end
end
