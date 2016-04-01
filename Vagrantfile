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
BOX_CENT_7      = "hpcw-centos71-nocm-0.0.1.box"
BOX_UBUNTU_14   = "hpcw-ubuntu1404-desktop-nocm-0.1.0.box"
HOSTS = {
    :dev    => 'devhouse',
    :stack  => 'stack'
}
# HOSTS = [
#     {
#         :name   => 'devhouse'
#     }
# ]
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|  
  # Hostmanager Settings
#   config.hostmanager.enabled            = true
#   config.hostmanager.manage_host        = true
#   config.hostmanager.ignore_private_ip  = false
#   config.hostmanager.include_offline    = true
  
  # Providers
  config.vm.provider :virtualbox do |v|
    v.gui = false
    # v.gui = true   
    v.customize ["modifyvm", :id, "--memory", '2048']
    v.customize ["modifyvm", :id, "--cpus", '2']
    # v.linked_clone = true
  end
  config.vm.provider :vmware_fusion do |v|
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = "2"
    v.vmx["ethernet0.virtualDev"] = "vmxnet3"
  end
  
  # Box Definitions
  config.vm.define HOSTS[:dev] do |box|
    box.vm.box      = BOX_UBUNTU_14
    box.vm.hostname  = HOSTS[:dev] + DOMAIN
    # box.hostmanager.aliases = 'test'
    box.vm.network :private_network, ip: NETWORK+'5', netmask: NETMASK
    # box.vm.network :forwarded_port, guest: 80,  host: 8080
    # Provisioning
    # box.vm.provision :shell, path: "scripts/setup/common.sh"
    box.vm.provision :ansible do |ansible|
      ansible.verbose = "v" # Vagrant displays ansible commands
      ansible.playbook = "ansible/playbook-#{HOSTS[:dev]}.yml"
    end
  end
  
  config.vm.define HOSTS[:stack] do |box|
    box.ssh.pty = true
    box.vm.box      = BOX_CENT_7
    box.vm.hostname  = HOSTS[:stack] + DOMAIN
    # box.hostmanager.aliases = 'test'
    box.vm.network :private_network, ip: NETWORK+'6', netmask: NETMASK
    # box.vm.network :forwarded_port, guest: 80,  host: 8080
    # Provisioning
    # box.vm.provision :shell, path: "scripts/setup/common.sh"
    box.vm.provision :ansible do |ansible|
      ansible.verbose = "v" # Vagrant displays ansible commands
      ansible.playbook = "ansible/playbook-#{HOSTS[:stack]}.yml"
    end
    box.vm.provision :reload
  end
  
end

# Resources

# Vagrant's Ansible Docs: http://docs.vagrantup.com/v2/provisioning/ansible.html
# Vagrant Automatic Inventory File: .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
# Vagrant 1.7 auto Private Key Location: .vagrant/machines/[machine name]/[provider]/private_key