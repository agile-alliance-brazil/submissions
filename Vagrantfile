# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
APP_DIR = HERE.to_s.freeze
INFRA_DIR = "#{HERE}/puppet"

Vagrant.configure('2') do |config|
  # Production is Ubuntu 14.04 in an AWS micro instance/Digital Ocean basic droplet so is our Vagrant box
  config.vm.box     = 'ubuntu/trusty64'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.provider :virtualbox do |vm|
    vm.memory = 2048
    vm.cpus = 2
  end
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.auto_detect = true
    # If you are using VirtualBox, you might want to enable NFS for shared folders
    config.cache.enable_nfs  = true
  end
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = true
    config.vbguest.no_remote = true
  end

  config.ssh.insert_key = false
  config.ssh.private_key_path = "#{APP_DIR}/certs/insecure_private_key"

  # We want to use the same ruby version that production will use
  config.vm.provision :shell do |s|
    s.path = "#{INFRA_DIR}/script/server_bootstrap.sh"
    s.args = 'vagrant'
  end

  config.vm.define :dev do |cfg|
    # Setting up a share so we can edit locally but run in vagrant
    cfg.vm.synced_folder APP_DIR.to_s, '/srv/apps/submissions/current'

    cfg.vm.network :private_network, ip: '10.11.12.15'
    cfg.vm.network :forwarded_port, id: 'ssh', guest: 22, host: 2205
    cfg.vm.network :forwarded_port, guest: 9292, host: 9294

    cfg.vm.provision :shell, inline:
      "/opt/puppetlabs/bin/puppet apply --modulepath=/srv/apps/submissions/current/puppet/modules /srv/apps/submissions/current/puppet/manifests/vagrant-dev.pp &&\
      /opt/puppetlabs/bin/puppet apply --modulepath=/srv/apps/submissions/current/puppet/modules /srv/apps/submissions/current/puppet/manifests/vagrant-dev.pp"
  end

  config.vm.define :deploy do |cfg|
    cfg.vm.network :private_network, ip: '10.11.12.16'
    cfg.vm.network :forwarded_port, id: 'ssh', guest: 22, host: 2206
    cfg.vm.network :forwarded_port, guest: 80, host: 8082
  end
end
