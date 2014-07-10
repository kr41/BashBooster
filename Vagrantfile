# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "ubuntu" do |ubuntu|
    ubuntu.vm.box = "hashicorp/precise32"
    ubuntu.vm.provision :shell, inline: "/vagrant/examples/bootstrap.sh"
    ubuntu.vm.network :forwarded_port, host: 8081, guest: 80
  end

  config.vm.define "centos" do |centos|
    centos.vm.box = "chef/centos-6.5"
    centos.vm.provision :shell, inline: "/vagrant/examples/bootstrap.sh"
    centos.vm.network :forwarded_port, host: 8082, guest: 80
  end

  config.vm.define "debian" do |debian|
    debian.vm.box = "chef/debian-7.4"
    debian.vm.provision :shell, inline: "/vagrant/examples/bootstrap.sh"
    debian.vm.network :forwarded_port, host: 8083, guest: 80
  end
end
