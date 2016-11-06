#!/usr/bin/env bash
clear

echo Running Galaxy
# http://stackoverflow.com/questions/25230376/how-to-automatically-install-ansible-galaxy-roles/30176625#30176625
ansible-galaxy install -p ./roles/ -r requirements-eventhorizon.yml

echo Running Ansible
ansible-playbook -i hosts playbook-eventhorizon.yml --ask-sudo-pass -vvv
