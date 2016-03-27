#!/usr/bin/env bash

# Allow the script to be either interactive or not
# Default variables to keep script functionality
silent=${1:-false}
username=${2:-''}

if [ $silent != false ]; then
    silent=true
fi

# Helper
print() {
    if ! $silent ; then
        echo "$@"
    fi
}

requirements() {
    # Check root
    if [ "`whoami`" != "root" ] ; then
        print "This script must be run as root (e.g. using sudo). Will now exit."
        error 1
    fi
    # If silent install, verify username
    if $silent ; then
        if [ -z "$username" ] ; then
            print "What do you mean by an empty username? Quitting."
            error 1
        fi
    fi
}

intro() {
    print "This script sets up read permissions for the kernel's event devices 
in order for your user to be able to run WhatPulse. It will create a new
group called 'input', add your username to that group, and make the event
devices readable for the group. Press Ctrl+C now if you don't want this,
or press Return to continue."
    
    if ! $silent ; then 
        read temp
    fi
}


# set up persistent settings
update_udev() {
    if [ -r /etc/udev/rules.d/99-whatpulse-input.rules ] ; then
        print "/etc/udev/rules.d/99-whatpulse-input.rules already exists. Will not change it."
    else
        echo "KERNEL==\"event*\",       NAME=\"input/%k\", MODE=\"640\", GROUP=\"input\"" >> /etc/udev/rules.d/99-whatpulse-input.rules
        if [ $? != 0 ] ; then
            print "There was some error creating the udev rule file. Sorry. Quitting."
            error 1
        fi
        print "UDEV rules file has been set up."
    fi

    if [ -n "`cat /etc/group | grep -e ^input:`" ] ; then
        print "Group 'input' already exists!"
    else
        groupadd input
        print "Created group 'input'."
    fi
    
    print "UDEV rules updated."
}

update_inputgroup() {
    if ! $silent ; then
        print "Please enter the username that should get added to the group:"
        read username
    fi

    if [ -z "$username" ] ; then
        print "What do you mean by an empty username? Quitting."
        error 1
    fi

    if [ -z "`cat /etc/passwd | grep -e ^$username:`" ] ; then
        print "This username doesn't exist. Quitting."
        error 1
    fi

    gpasswd -a $username input &> /dev/null
    if [ $? != 0 ] ; then
        # maybe this is openSUSE (or a similar system)
        usermod -A input $username &> /dev/null
        if [ $? != 0 ] ; then
            print "There was a problem adding your username to the group 'input'.
    Please add your user to the 'input' group yourself."
        else
            print "Added user '$username' to group 'input', using the special openSUSE method."
        fi
    else
        print "Added user '$username' to group 'input'."
    fi
}

# apply non-persistent settings so that no reboot is necessary :-)
update_temp_rules() {
    print " "
    print "Since the UDEV rules will only be applied when you restart your 
computer, this script will now apply temporary read permissions for all 
users to the device files to let you use WhatPulse immediately. You have 
the chance to cancel this by pressing Ctrl+C now (which you should do if 
you fear that other users on your computer might log your keyboard 
events!). Otherwise press Return to continue."
    
    if ! $silent ; then
        read temp
    fi
    
    find /dev/input/ -iname 'event*' -exec chmod 644 {} \;
}

error() {
    echo 'Exiting.'
    exit 1
}


# Run Script
requirements
intro
update_udev
update_inputgroup
update_temp_rules
print "All done, have fun using WhatPulse!"

exit 0