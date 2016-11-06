#!/usr/bin/env bash
clear

ansible localhost -m setup
# http://docs.ansible.com/ansible/intro_adhoc.html#gathering-facts