#!/usr/bin/env bash

plugins=( 'vagrant-hostmanager', 'vagrant-reload')

for plugin in "${plugins[@]}"
do
  vagrant plugin install "${plugin}"
done
