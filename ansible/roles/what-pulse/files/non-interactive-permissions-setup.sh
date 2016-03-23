#!/usr/bin/env bash

username=$1

if [ "`whoami`" != "root" ] ; then
    echo "This script must be run as root (e.g. using sudo). Will now exit."
    exit 1
fi

# set up persistent settings

if [ -r /etc/udev/rules.d/99-whatpulse-input.rules ] ; then
    echo "/etc/udev/rules.d/99-whatpulse-input.rules already exists. Will not change it."
else
    echo "KERNEL==\"event*\",       NAME=\"input/%k\", MODE=\"640\", GROUP=\"input\"" >> /etc/udev/rules.d/99-whatpulse-input.rules
    if [ $? != 0 ] ; then
        echo "There was some error creating the udev rule file. Sorry. Quitting."
        exit 1
    fi
    echo "UDEV rules file has been set up."
fi

if [ -n "`cat /etc/group | grep -e ^input:`" ] ; then
    echo "Group 'input' already exists!"
else
    groupadd input
    echo "Created group 'input'."
fi

if [ -z "$username" ] ; then
    echo "What do you mean by an empty username? Quitting."
    exit 1
fi

if [ -z "`cat /etc/passwd | grep -e ^$username:`" ] ; then
    echo "This username doesn't exist. Quitting."
    exit 1
fi

gpasswd -a $username input &> /dev/null
if [ $? != 0 ] ; then
    # maybe this is openSUSE (or a similar system)
    usermod -A input $username &> /dev/null
    if [ $? != 0 ] ; then
        echo "There was a problem adding your username to the group 'input'.
Please add your user to the 'input' group yourself."
    else
        echo "Added user '$username' to group 'input', using the special openSUSE method."
    fi
else
    echo "Added user '$username' to group 'input'."
fi
echo " "
echo "Setup of persistent permission settings complete."

# apply non-persistent settings so that no reboot is necessary :-)

echo " "

find /dev/input/ -iname 'event*' -exec chmod 644 {} \;

echo "All done, have fun using WhatPulse!"