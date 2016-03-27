# HPCW Env Setup
Automated installation of my various environments.
* Warning: I'm new to Ansible and still learning the best ways to utilize its many features, if you see me doing something asinine, let me know!

# Testing
This project uses Vagrant & Virtualbox for testing.

# Environments
* DevHouse: My current dev box used for just about everything. Currently undergoing distro testing of: [Mint, (X,K)Ubuntu(14/15), Debian, openSUSE]
* Proxy: My reverse proxy used to access my networks nethers from abroad
* Stack01: (Media): Used to stream my various services
* Stack02: (Data): Used to collect, process & file my data
* Mac: Old work laptop no longer used
* LinuxMint: This was my first attempt at officially moving my main development setup to a Linux enviroment.

## Env-DevHouse
**Status: Active**   
Ansible provisioning still under development. Flushing our roles, security, backups, integration and overall ability to customize a Linux environment
### TODO
* dotfiles
* SSH Key Setup
* Theme setup (Crunchy)
* Setup Backups?
* Chrome: Add menu item?
* Cinnamon: Set as default DE?
* Conky: Setup default profile (from dotfiles?)
* Intellij: setup default settings
* JDK8: Verify PATH/JAVA_HOME set correctly after install
* Packer: Add to PATH
* Vagrant: Add plugin check to roles main.yml
* VMWare: Fix lib errors
* Add conditional logic to roles/includes
* Setup apps for startup

-----

## Env-LinuxMint:
**Status: Abandonded**    
Bash powered setup driven from my Mac script adapted for Linux. Very repatative approach and not dynamic or maintainable.

-----

## Env-Mac:
**Status: Archived**   
Bash powered setup powered mainly by [Brew](http://brew.sh/) & [Brew Cask](https://github.com/caskroom/homebrew-cask)
