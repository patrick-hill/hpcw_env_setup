# -*- mode: ruby -*-
# vi: set ft=ruby :


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
BOX_MINT_18     = "hpcw-linuxmint18.1-desktop-nocm-0.1.0"
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
    v.linked_clone = true
    v.gui = true
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
    box.vm.box      = BOX_MINT_18
    box.vm.hostname = HOSTS[:eventhorizon] + DOMAIN
    box.vm.network :private_network, ip: NETWORK+'11', netmask: NETMASK
    # Provisioning
    # box.vm.provision :shell, inline: "sudo apt install git -y"
    box.vm.provision :ansible do |ansible|
      # Options
      ansible.force_remote_user = 'vagrant'
      ansible.limit = 'all'           # Disable default imit to connect to all machines
      ansible.ask_sudo_pass = false   # Prompt for sudo pass prior to play run
      ansible.ask_vault_pass = false   # Prompt for vault encryption password
      ansible.vault_password_file = 'ansible/vault-password-file.txt'
      # Ansible Galaxy
      ansible.galaxy_roles_path = 'ansible/roles/:../'
      ansible.galaxy_role_file = 'ansible/requirements-eventhorizon.yml'
      ansible.galaxy_command = 'ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --ignore-errors'
      # Ansible Playbook
      ansible.verbose   = "v" # Vagrant displays ansible commands
      ansible.playbook  = "ansible/playbook-#{HOSTS[:eventhorizon]}.yml"
      # Testing / speeding up / etc
      ansible.extra_vars = {
        # common_install_os_utils: false,
        # common_install_filesys_utils: true,
        # common_install_archive_utils: false,
        # common_install_common_utils: false,
        # common_install_media: false,
        # common_install_dev_utils: false,
        # common_install_hw_apps: false,
        # common_install_av: false

        # dropbox_interactive_install: false
      }
    end
  end

end

# Resources
# Vagrant's Ansible Docs: http://docs.vagrantup.com/v2/provisioning/ansible.html
# Vagrant Automatic Inventory File: .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory
# Vagrant 1.7 auto Private Key Location: .vagrant/machines/[machine name]/[provider]/private_key
