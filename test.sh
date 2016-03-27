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
boxes=${1:-'devhouse'}
replace_ansible_config=true
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
hostman_installed=$(vagrant plugin list | grep 'hostman*')
if [ "$hostman_installed" == '1' ]; then
	vagrant plugin install vagrant-hostmanager
fi

# Install Ansible
installed=$(which ansible && echo $?)
if [ "$installed" == '1' ]; then
  sudo apt-get install software-properties-common
  sudo apt-add-repository ppa:ansible/ansible
  sudo apt-get update
  sudo apt-get install ansible
fi
# Template ansible.cfg
# Check for overwrite
if [ $replace_ansible_config == true ]; then
  rm -f ansible.cfg    
fi
if [ ! -e ansible.cfg ]; then
  # Download config
  curl -s https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg -o ansible.cfg
fi

# Install Ansible Output Callback
if [ ! -e ansible/plugins/human_log.py ]; then
  mkdir -p ansible/plugins
  curl -s https://gist.githubusercontent.com/dmsimard/cd706de198c85a8255f6/raw/a2332f282be6e47286f588a9af6c10ff1b92749d/human_log.py -o ansible/plugins/human_log.py
fi

#####################################################
#	 	MAIN CODE BLOCK # PLACE CUSTOM CODE HERE   	#
#####################################################
# ansible.cfg Settings
sed_replace 'ansible.cfg' '#roles_path' 'roles_path = ansible/roles'
# Source: https://gist.github.com/cliffano/9868180
sed_replace 'ansible.cfg' '#callback_plugins' 'callback_plugins = ansible/plugins'

print "Boxes are: $boxes"
for box in $boxes
do
	vm_destroy $box
    if (vm_start $box && vm_provision $box); then
        vagrant reload $box
        print "!!! SCRIPT COMPLTED !!!"
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

