#!/usr/bin/env bash
clear
#####################################################
#              VARIABLES							#
#####################################################
start=`date +%s`
print_prefix="* * Automaton 9k - run.sh ==>"
dts=`date +%Y-%m-%d_%H:%M:%S`
#####################################################
#              USER CONFIG VARIABLES				#
#####################################################
boxes=${1:-'eventhorizon'} # comma delimited list of box names
box_provider=virtualbox
ansible_replace_config=true
ansible_use_log_plugin=true
vagrant_plugins_install=true
vagrant_plugins='' # # comma delimited list
# Possible Plugins: vagrant-vmware-fusion, vagrant-vmware-workstation, vagrant-hostmanager
vagrant_force_provisioning=false
vagrant_force_reload_after_provision=false
#####################################################
#              FUNCTIONS CODE BLOCK                 #
#####################################################
print() {
	echo "$print_prefix"
	echo "$print_prefix $@"
	echo -e "$print_prefix\n"
}
print_line() {
    echo -e "$print_prefix $@"
}

print_header() {
    echo -e "\n$print_prefix"
	echo "$print_prefix $@"
	echo -e "$print_prefix\n"
}

print_done() {
    print_line "#####################################################\n"
}

in_list() {
	[[ $1 =~ $2 ]] && return 0 || return 1	
}

sed_replace() {
	sed -i "s|.*$2.*|$3|" $1
}

vagrant_install() {
    installed=$(which vagrant && echo $?)
    if [ "$installed" == '1' ]; then
        print_line "Install: Installing ..."
    else
        print_line "Install: Already installed"
    fi
    
}

vagrant_get_plugins() {
    if $vagrant_plugins_install; then
        for plugin in $vagrant_plugins; do
            print_line "Plugins: Checking for: $plugin"
            if ! vagrant plugin list | grep -q -i $plugin ; then
                print_line "Plugins: Installing: $plugin"
                vagrant plugin install $plugin
            else
                print_line "Plugins: Already installed: $plugin"
            fi
        done
    fi
}

vagrant_download_boxes() {
    for box in $boxes; do
        if [[ "$box" -ne 'default' ]]; then
            print_line "Boxes: Download box: '$box'"
            vagrant box add "https://artifactory.passporthealth.com/artifactory/api/vagrant/vagrant-local/$box"
        fi
    done
}

ansible_install() {
    # print "Pre-Reqs: Checking for Ansible"
    installed=$(which ansible && echo $?)
    if [ "$installed" == '1' ]; then
        print_line "Install: Installing Ansible via pip ..."
        sudo pip install ansible
    else
        print_line "Install: Already installed"
    fi
}

ansible_config() {
    if $ansible_replace_config; then
        print_line "Config: Removing current ansible.cfg"
        rm -f ansible.cfg    
    fi
    
    if [ ! -e ansible.cfg ]; then
        print_line "Config: Downloading 'clean' ansible.cfg"
        curl -s https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg -o ansible.cfg
    fi

    print_line "Config: Setting 'roles_path' to: 'ansible/roles'"
    sed_replace 'ansible.cfg' '#roles_path' 'roles_path = ansible/roles'
    
    if [[ $ansible_use_log_plugin == true ]]; then
        print_line "Config: Setting 'callback_plugins' to: 'ansible/plugins'"
        # Source: https://gist.github.com/cliffano/9868180
        sed_replace 'ansible.cfg' '#callback_plugins' 'callback_plugins = ansible/plugins'
    fi

    print_line "Config: Settings 'cows' to off"
    sed_replace 'ansible.cfg' '#nocows' 'nocows = 1'

    print_line "Config: Disable retry files"
    sed_replace 'ansible.cfg' '#retry_files_enabled' 'retry_files_enabled = false'
}

ansible_plugins() {
    if $ansible_replace_config && $ansible_use_log_plugin; then
        if [ ! -e ansible/plugins/human_log.py ]; then
        print_line "Plugins: Downloading 'Human' Readable Ouptut"
        mkdir -p ansible/plugins
        plugin_link="https://gist.githubusercontent.com/dmsimard/cd706de198c85a8255f6/raw/a2332f282be6e47286f588a9af6c10ff1b92749d/human_log.py"
        plugin_link="https://raw.githubusercontent.com/redhat-openstack/khaleesi/master/plugins/callbacks/human_log.py"
        plugin_link="https://raw.githubusercontent.com/n0ts/ansible-human_log/master/human_log.py"
        curl -s $plugin_link -o ansible/plugins/human_log.py
        fi
    fi
}

ansible_get_requirements() {
    if [ -f ./ansible/requirements ]; then
        if [ ! -d .ansible/roles ]; then
            mkdir -p ansible/roles
        fi
    ansible-galaxy install -p ./ansible/roles/ -r ./ansible/requirements.yml
    fi
}

vm_check_status() {
    is_running=$(vagrant status $1 | grep "$1.*running")
    if [[ $is_running == 1 ]]; then
        print_line "Boxes: Box is NOT running: '$1'"
    else
        print_line "Boxes: Box is currently running: '$1'"
    fi
    [[ $is_running == 0 ]] && return 0 || return 1
	# $(vagrant status $1 | grep "$1.*running") && return 0 || return 1
}

vm_destroy() {
    print_line "Boxes: Destroying box: '$1'"
    vagrant destroy -f $1
    return $?
}

vm_start() {
    if $(in_list $1); then
        print_header "Boxes: Starting Box: '$1'"
        vagrant up --provider=$box_provider $1
    fi
    [[ $? == 0 ]] && return 0 || return 1
}

# Not currently used as planning for Ansible prov via Vagrantfile
vm_provision() {
	name=$1
	# Puppet:  Call Puppet Apply
	# Salt:    Done with Vagrant
	# Ansible: Done with Vagrant
}

#####################################################
#	 	MAIN CODE                                   #
#####################################################
print_line "#####################################################"
print_line "#	 	Vagrant Automaton 9000                    #"
print_line "#####################################################\n"

print_line "#####################################################"
print_line "#	 	Variables                                 #"
print_line "#####################################################"
for var in start dts boxes box_provider ansible_replace_config ansible_use_log_plugin vagrant_plugins_install vagrant_plugins ; do
    printf "%-60s %-40s\n" "$print_prefix $var" ${!var}
done
print_done

print_line "#####################################################"
print_line "#	 	Vagrant                                   #"
print_line "#####################################################"
vagrant_install
vagrant_get_plugins
vagrant_download_boxes
print_done

print_line "#####################################################"
print_line "#	 	Ansible                                   #"
print_line "#####################################################"
ansible_install
ansible_config
ansible_plugins
ansible_get_requirements
print_done

print_line "#####################################################"
print_line "#	 	Boxes                                     #"
print_line "#####################################################"
print_line "Boxes: Box(es) is/are: $boxes"
for box in $boxes
do
	if !(vm_check_status $box); then
        vm_destroy $box
    fi

    if (vm_start $box); then
        print_header "Boxes: Box Started Successfully: '$box'"
    else
        print_line "Boxes: !!! ERROR !!!"
        print_line "Boxes: !!! ERROR !!!   Unable to bring up box: '$box'"
        print_line "Boxes: !!! ERROR !!!"
    fi

    if $vagrant_force_provisioning; then
        vm_provision $box
        if $vagrant_force_reload_after_provision; then
            vagrant reload $box
        fi
    fi
done
print_line "#####################################################"
end=`date +%s`
print_line "Total execution time: $((end-start)) seconds"
print_line "#####################################################"
print_line "#	 	Vagrant Automaton 9000                    #"
print_line "#####################################################"
exit 0
#####################################################
#	 	TODOs                                       #
#####################################################
# - Install Vagrant if not found
# - Install VirtualBox if not found
# - Download latest RHEL box from Artifactory and add it to Vagrant
# - Check exit codes and stop script on error