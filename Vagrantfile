# -*- mode: ruby -*-
# vi: set ft=ruby :
HERE = File.dirname(__FILE__)
APP_DIR = "#{HERE}"
INFRA_DIR = "#{HERE}/puppet"

Vagrant.configure('2') do |config|
  # Production is Ubuntu 12.04 in an AWS micro instance/Digital Ocean basic droplet so is our Vagrant box
  config.vm.box     = "server-precise64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  config.vm.provider :virtualbox do |vm|
    vm.customize ["modifyvm", :id, "--memory", 1024]
  end
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
    # If you are using VirtualBox, you might want to enable NFS for shared folders
    config.cache.enable_nfs  = true
  end
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = true
    config.vbguest.no_remote = true
  end

  # We want to use the same ruby version that production will use
  config.vm.provision :shell do |s|
    s.path = "#{INFRA_DIR}/script/server_bootstrap.sh"
    s.args = 'vagrant'
  end

  config.vm.define :dev do |config|
    # Setting up a share so we can edit locally but run in vagrant
    config.vm.synced_folder "#{APP_DIR}", "/srv/apps/submissions/current"

    config.vm.network :private_network, ip: "10.11.12.15"
    config.vm.network :forwarded_port, id: 'ssh', guest: 22, host: 2205
    config.vm.network :forwarded_port, guest: 9292, host: 9294

    config.vm.provision :puppet do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "vagrant-dev.pp"
      puppet.module_path = "puppet/modules"
      puppet.facter = {
        # The work around can be removed when this issue is fixed https://github.com/mitchellh/vagrant/issues/2270
        "server_url" => "dev.localhost"
      }
    end
  end

  config.vm.define :deploy do |config|
    config.vm.network :private_network, ip: "10.11.12.16"
    config.vm.network :forwarded_port, id: 'ssh', guest: 22, host: 2206
    config.vm.network :forwarded_port, guest: 80, host: 8082
  end
end
