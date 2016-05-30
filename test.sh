#!/usr/bin/env bash
clear
#####################################################
#              VARIABLES							#
#####################################################
start=`date +%s`
echo "* * test.sh ==> Starting: $start"
dts=`date +%Y-%m-%d_%H:%M:%S`
echo -e "* * test.sh ==> DTS: $dts\n"
boxes=${1:-'proxy stack'}
boxes=${1:-'stack'}
replace_ansible_config=true
ansible_use_log_plugin=true
#####################################################
#              FUNCTIONS CODE BLOCK                 #
#####################################################
print() {
	echo '* * test.sh ==>'
	echo "* * test.sh ==> $@"
	echo '* * test.sh ==>'
}

in_list() {
	[[ $1 =~ $2 ]] && return 0 || return 1	
}

sed_replace() {
	sed -i "s|.*$2.*|$3|" $1
  # sed -i 
}

vm_check_status() {
	$(vagrant status $1 | grep "$1.*running") && return 0 || return 1
}

vm_start() {
    exitCode=1
    if $(in_list $1); then
        print "$FUNCNAME ==> Starting Box: $1"
        vagrant up --provider=virtualbox $1
        exitCode=$?
    fi
  [[ $exitCode == 0 ]] && return 0 || return 1
}

vm_destroy() {
    exitCode=1
	running=$(vagrant status $1 | grep -ic "$1.*running")
	if [ "$running" == '1' ]; then
		print "$FUNCNAME ==> Destroying Box: $1"
		vagrant destroy -f $1
        exitCode=$?
	fi
  [[ $exitCode == 0 ]] && return 0 || return 1
}

vm_provision() {
	name=$1
	# Puppet:  Call Puppet Apply
	# Salt:    Done with Vagrant
	# Ansible: Done with Vagrant
}
#####################################################
#	 	PROJECT REQUIREMENTS # THIRD PARTY APPS   	#
#####################################################
# This project requires the use of the Vagrant HostManager Plugin
print "Pre-Reqs: Checking for Vagrant plugin 'hostmanager'"
hostman_installed=$(vagrant plugin list | grep 'hostman*')
if [[ $hostman_installed == 1 ]]; then
	vagrant plugin install vagrant-hostmanager
fi

# Install Ansible
print "Pre-Reqa: Checking for Ansible"
installed=$(which ansible && echo $?)
if [ "$installed" == '1' ]; then
  sudo apt-get install software-properties-common
  sudo apt-add-repository ppa:ansible/ansible
  sudo apt-get update
  sudo apt-get install ansible
fi
# Template ansible.cfg
# Check for overwrite
if [[ $replace_ansible_config  ]]; then
  print "Replacing ansible.cfg"
  rm -f ansible.cfg    
fi
if [ ! -e ansible.cfg ]; then
  # Download config
  print "asnible.cfg not found, downloading..."
  curl -s https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg -o ansible.cfg
fi

# Install Ansible Output Callback
if [[ $ansible_use_log_plugin == true ]]; then
    if [ ! -e ansible/plugins/human_log.py ]; then
      print "Downloading ansible plugin: 'Human Log'"
      mkdir -p ansible/plugins
      plugin_link="https://gist.githubusercontent.com/dmsimard/cd706de198c85a8255f6/raw/a2332f282be6e47286f588a9af6c10ff1b92749d/human_log.py"
      plugin_link="https://raw.githubusercontent.com/redhat-openstack/khaleesi/master/plugins/callbacks/human_log.py"
      plugin_link="https://raw.githubusercontent.com/n0ts/ansible-human_log/master/human_log.py"
      curl -s $plugin_link -o ansible/plugins/human_log.py
    fi
fi


#####################################################
#	 	MAIN CODE BLOCK # PLACE CUSTOM CODE HERE   	#
#####################################################
# ansible.cfg Settings
print "ansible.cfg: Setting 'roles_path'"
sed_replace 'ansible.cfg' '#roles_path' 'roles_path = ansible/roles'
if [[ $ansible_use_log_plugin == true ]]; then
    print "ansible.cfg: Setting 'callback_plugins'"
    # Source: https://gist.github.com/cliffano/9868180
    sed_replace 'ansible.cfg' '#callback_plugins' 'callback_plugins = ansible/plugins'
fi

print "Boxes are: $boxes"
for box in $boxes
do
	vm_destroy $box
    if (vm_start $box && vm_provision $box); then
        vagrant reload $box
        print "!!! SCRIPT COMPLETED !!!"
    else
        print "!!! ERROR !!!    Unable to bring up box: $box    !!! ERROR !!!"
    fi
done
#####################################################
#	END CODE BLOCK # DO NOT PUT CODE BELOW HERE    	#
#####################################################
# Grab the current time and calculate how long all this took
end=`date +%s`
print "Total execution time: $((end-start)) seconds"
exit 0

