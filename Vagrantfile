# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Requirements
# This project requires the vagrant plugin: vagrant-reload

# Configs
Vagrant.require_version ">= 1.7.0"
VAGRANTFILE_API_VERSION = "2"
DOMAIN          = ".hpcw.com"
NETWORK         = "11.0.0."
NETMASK         = "255.255.255.0"
BOX_CENT_6      = "hpcw-centos67-nocm-0.0.1.box"
BOX_CENT_7      = "hpcw-centos71-nocm-0.0.3.box"
BOX_UBUNTU_14   = "hpcw-ubuntu1404-desktop-nocm-0.1.0.box"
BOX_UBUNTU_15   = "hpcw-ubuntu1510-nocm-0.1.0.box"
#BOX_UBUNTU_16   = ""
HOSTS = {
    :proxy          => 'proxy',
    :stack          => 'stack',
    :quantum        => 'quantum',
    :eventhorizon   => 'eventhorizon'
}

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Providers
  config.vm.provider :virtualbox do |v|
    v.gui = false
    v.customize ["modifyvm", :id, "--memory", '2048']
    v.customize ["modifyvm", :id, "--cpus", '2']
  end
  config.vm.provider :vmware_fusion do |v|
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = "2"
    v.vmx["ethernet0.virtualDev"] = "vmxnet3"
  end
  
  config.vm.define HOSTS[:proxy] do |box|
    box.ssh.pty     = true
    box.vm.box      = BOX_CENT_7
    box.vm.hostname = HOSTS[:proxy] + DOMAIN
    box.vm.network :private_network, ip: NETWORK+'5', netmask: NETMASK
    # Provisioning
    box.vm.provision :ansible do |ansible|
      ansible.verbose   = "v" # Vagrant displays ansible commands
      ansible.playbook  = "ansible/playbook-#{HOSTS[:proxy]}.yml"
    end
  end

  config.vm.define HOSTS[:stack] do |box|
    box.ssh.pty     = true
    box.vm.box      = BOX_CENT_7
    box.vm.hostname = HOSTS[:stack] + DOMAIN
    box.vm.network :private_network, ip: NETWORK+'6', netmask: NETMASK
    # Provisioning
    box.vm.provision :ansible do |ansible|
      ansible.verbose   = "v" # Vagrant displays ansible commands
      ansible.playbook  = "ansible/playbook-#{HOSTS[:stack]}.yml"
    end
  end

#  config.vm.define HOSTS[:quantum] do |box|
#    box.ssh.pty     = true
#    box.vm.box      = BOX_UBUNTU_16
#    box.vm.hostname = HOSTS[:quantum] + DOMAIN
#    box.vm.network :private_network, ip: NETWORK+'10', netmask: NETMASK
#    # Provisioning
#    box.vm.provision :ansible do |ansible|
#      ansible.verbose   = "v" # Vagrant displays ansible commands
#      ansible.playbook  = "ansible/playbook-#{HOSTS[:quantum]}.yml"
#    end
#  end

  config.vm.define HOSTS[:eventhorizon] do |box|
    box.ssh.pty     = true
    box.vm.box      = BOX_UBUNTU_15
    box.vm.hostname = HOSTS[:eventhorizon] + DOMAIN
    box.vm.network :private_network, ip: NETWORK+'11', netmask: NETMASK
    # Provisioning
    box.vm.provision :ansible do |ansible|
      ansible.verbose   = "v" # Vagrant displays ansible commands
      ansible.playbook  = "ansible/playbook-#{HOSTS[:eventhorizon]}.yml"
    end
  end

end

# Resources
# Vagrant's Ansible Docs: http://docs.vagrantup.com/v2/provisioning/ansible.html
# Vagrant Automatic Inventory File: .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
# Vagrant 1.7 auto Private Key Location: .vagrant/machines/[machine name]/[provider]/private_key
