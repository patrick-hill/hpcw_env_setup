#!/bin/bash
debug=false
scriptRoot="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dropbox_path=~/Dropbox

echo "Install brew, brew cask, and all the needed applications"

# install brew (requires Xcode[it auto prompts])
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install python's pip
sudo easy_install pip
# passlib used for encrypted credentials with Ansible on OSX -.-
sudo pip install passlib

# Puppet Setup
sudo gem install r10k

# Git ignore File (So tired of redoing this .....)

# Tab some brew ;)
brew tap homebrew/versions

if [ $? == 0 ]; then
  brews="ansible bash-completion caskroom/cask/brew-cask grails gradle groovy packer wget"
for brew in “${brews}
do
  if [ $debug == false ]; then
    brew install $brew
  else
    echo "Command would be: brew install $brew"
  fi
done

  ## Place symlinks to the apps in the root Applications folder
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"

  ## List the casks that you want to install
  casks="alfred android-file-transfer arduino
  bartender
  caffeine
  diskmaker-x dropbox
  evernote
  git google-chrome
  hipchat
  intellij-idea
  java
  keyboard-maestro
  logitech-control-center logitech-unifying
  microsoft-office
  node
  path-finder
  skitch skype sourcetree spectacle
  utorrent
  vagrant vagrant-manager visual-studio-code vlc
  whatpulse wireshark
  xquartz"
  # broken='jdownloader'
  # broken='vmware-fusion' // need version 8.0.2 not 8.1.0 for vagrant -.-
  for cask in $casks
  do
    if [ $debug == false ]; then
      brew cask install $cask
    else
      echo "Command would be: brew cask install $cask"
    fi
  done

  ## Clean up the downloaded installer files
  brew cask cleanup
  echo "Brew Setup Completed"
fi

# Brew & Casks done, setup other apps/configs/etc
if [ $debug == false ]; then
    
    # Install python's pip
    sudo easy_install pip
    # passlib used for encrypted credentials with Ansible on OSX -.-
    sudo pip install passlib
    
    # Setup Git
    cp -f .gitignore_global ~/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global
    git config --global user.name "Patrick Hill"
    git config --global user.email "PHill@RedstoneContentSolutions.com"
    
    # Puppet Setup
    sudo gem install r10k
    
    # NPM
    npm install -g typescript grunt-cli bower generator-angular
    
    # Whatever requires Dropbox to be synced
    echo ''
    echo "Dropbox should be installed now, setup it up and type 'y' here when it's done syncing..."
    read dropbox_finished
    echo "You entered: $dropbox_finished"
    if [ $dropbox_finished == 'y' ]; then

        # Setup Fusion  
        hdiutil mount $dropbox_path/Software/Mac/VMware-Fusion-8.0.2-3164312.dmg
        sudo cp -R "/Volumes/VMware Fusion/VMware Fusion.app" /Applications
        # sudo installer -package fusion/fusion.pkg -target "/Volumes/Macintosh HD"
        hdiutil detach /Volumes/VMware\ Fusion/
        
        # Copy over SSH Keys
        ln -s $dropbox_path/0-Backups/rcs_mac/ssh_keys/current/ ~/.ssh
        chmod 600 $dropbox_path/0-Backups/rcs_mac/ssh_keys/current/id_rsa
        chmod 600 $dropbox_path/0-Backups/rcs_mac/ssh_keys/current/id_rsa.pub
        chmod 644 $dropbox_path/0-Backups/rcs_mac/ssh_keys/current/known_hosts
        chmod 755 $dropbox_path/0-Backups/rcs_mac/ssh_keys/current
        
        # Setup Repos : requires ssh keys
        ./scripts/repos.groovy 'bitbucket' ~/src phill
        ./scripts/repos.groovy 'github' ~/src patrick-hill
        
        # Vagrant Setup
        vagrant plugin install vagrant-vmware-fusion
        vagrant plugin install vagrant-salt 
        vagrant plugin install vagrant-multiprovider-snap
        vagrant plugin install vagrant-hostmanager              # https://github.com/smdahlen/vagrant-hostmanager
        vagrant plugin license vagrant-vmware-fusion /Users/phill/Dropbox/0-Backups/rcs_mac/licenses/vagrant_fusion_license.lic
        
    fi
fi

# Vagrant Setup
vagrant plugin install vagrant-vmware-fusion
vagrant plugin license vagrant-vmware-fusion $srcPath/../licenses/vagrant_fusion_license.lic
vagrant plugin install vagrant-reload
vagrant plugin install vagrant-salt 
vagrant plugin install vagrant-multiprovider-snap
vagrant plugin install vagrant-hostmanager              # https://github.com/smdahlen/vagrant-hostmanager
vagrant plugin install vagrant-vbguest                  # https://github.com/dotless-de/vagrant-vbguest/

# NPM
sudo npm install -g bower generator-angular grunt-cli gulp typescript


