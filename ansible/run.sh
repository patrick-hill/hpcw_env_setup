#!/usr/bin/env bash

if [ $# -gt 0 ]; then
	ansible-playbook -i hosts $1 --ask-sudo-pass
else
	ansible-playbook -i hosts playbook-devhouse.yml --user=vagrant --ask-sudo-pass
fi

