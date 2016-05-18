#!/usr/bin/env bash

func_wget() {
  wget -O $1 $2
}

# Add Cinnamon PPA (For Ubuntu 15.10/16.04)
sudo add-apt-repository ppa:embrosyn/cinnamon
sudo apt update
sudo apt install cinnamon blueberry

# Themes
sudo apt install numix-gtk-theme

# Links

# Pre-requisites
sudo apt remove libreoffice-style-mint

mkdir /tmp/debs
# mint-themes
func_wget /tmp/debs/ http://packages.linuxmint.com/pool/main/m/mint-themes/mint-themes_1.4.6_all.deb
#libreoffice-sylte-mint
func_wget /tmp/debs/ http://packages.linuxmint.com/pool/main/libr/libreoffice-style-mint/libreoffice-style-mint_5.1%2b3_all.deb
#mint-themes-gtk3
func_wget /tmp/debs/ http://packages.linuxmint.com/pool/main/m/mint-themes-gtk3/mint-themes-gtk3_3.18%2b4_all.deb
#mint-y-theme
func_wget /tmp/debs/ http://packages.linuxmint.com/pool/main/m/mint-y-theme/mint-y-theme_1.0.2_all.deb
#mint-x-icons
func_wget /tmp/debs/ http://packages.linuxmint.com/pool/main/m/mint-x-icons/mint-x-icons_1.3.6_all.deb
#mint-y-icons
func_wget /tmp/debs/ http://packages.linuxmint.com/pool/main/m/mint-y-icons/mint-y-icons_1.0.1_all.deb
#cinnamon-themes
func_wget /tmp/debs/ http://packages.linuxmint.com/pool/main/c/cinnamon-themes/cinnamon-themes_2016.05.03_all.deb

# Install debs
sudo dpkg -i ~/deb/*.deb



## Shutdown Fix
gsettings set org.cinnamon.desktop.session settings-daemon-uses-logind true
gsettings set org.cinnamon.desktop.session session-manager-uses-logind true
gsettings set org.cinnamon.desktop.session screensaver-uses-logind false