# HPCW Env Setup
Automated provisioning of my various environments.
* Warning: I'm new to Ansible and still learning the best ways to utilize its many features.
If you see me doing something asinine, SAY SOMETHING!


# Requirements
Vagrant 1.7.4+ [https://www.vagrantup.com/]   
Ansible 2.0.1+ [https://www.ansible.com/]   
Virtualbox 4+ [https://www.virtualbox.org/wiki/Downloads]   
CentOS 7.1 Vagrant Boxes (Possibly 6.7)   
* Repo: Make your own like me: [https://github.com/boxcutter/centos]   
* Use prebuilt boxes: [https://atlas.hashicorp.com/boxcutter/boxes/centos71]    


# Environments
* DevHouse: My current dev box used for just about everything. Currently undergoing distro testing of: [Mint, (X,K)Ubuntu(14/15/16), Debian, openSUSE]
* Proxy: My reverse proxy used to access my networks nethers from abroad
* Stack01: (Media): Used to stream my various services
* Stack02: (Data): Used to collect, process & file my data
* Mac: Old work laptop no longer used
* LinuxMint: This was my first attempt at officially moving my main development setup to a Linux enviroment.


## EventHorizon
** Status: Active   
Current dev task

### Manual Tasks
* Settings 
	* Themes:
		* Window borders [Mint-Y-Dark]
		* Icons [Mint-X-Dark]
		* Controls [Mint-Y-Dark]
		* Deskotp [Linux Mint]
	* Bluetooth: Disabled
	* Preferred Applications
		* Web [Chrome]
* Gnome Terminal -> Edit -> Prefs -> Shortcuts [Reset/Clear == Ctrl + k]
* VS-Code: Install ext "Sort Lines"
* Nemo -> Edit -> Preferences:
	* Views: 
		* Default View [List View]
	* Display: Date Fromat: [YYYY-MM-DD Time]
* Vagrant --> Plugins
	* vagrant-hostmanager
	* vagrant-reload

### TODO
* Guacamole: Break out Tomcat/SQL
* firewall: add services
* dotfiles
* SSH Key Setup
* Setup Backups?
* Cinnamon: Set as default DE?
* Conky: Setup default profile (from dotfiles?)
* Intellij: setup default settings
* Vagrant: Add plugin check to roles main.yml
* VMWare: Fix lib errors
* Setup apps for startup


## Env-DevHouse
**Status: Abandoned**   
Ansible provisioning: Abandoned as PC is now re-purposed   


## Env-LinuxMint:
**Status: Abandoned**    
Bash powered setup driven from my Mac script adapted for Linux. Very repatative approach and not dynamic or maintainable.


## Env-Mac:
**Status: Archived**   
Bash setup powered mainly by [Brew](http://brew.sh/) & [Brew Cask](https://github.com/caskroom/homebrew-cask)

# Ansible Roles
* autokey
* chrome
* cinnamon-desktop
* common
* conky
* couchpotato
* dropbox
* firewal
* git-config
* gitgraken
* guacamole
* headphones
* intellij
* jdk8
* mysql
* nfs-mounts
* nginx
* openssl
* packer
* remmina
* sabnzbd
* sickrage
* sonarr
* ssh-server
* transmission
* vagrant
* virtualbox
* vmware-workstation
* vnc-x11vnc
* vs-code
* what-pulse

# Kudos/Respect/Props/Etc
Major kudos to Derek Horn [Deviant Engineer](https://deviantengineer.com) for writing some great
CentOS guides for Sab, CouchPotato, SickRage, HeadPhones, Guacamole, etc
Check out his site for links to his [Twitter](https://twitter.com/DeviantEng) Google+, etc