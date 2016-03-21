#!/usr/bin/env bash


# I have several host specific settings, pass mac/quantum to distinguishe
host=${1:-'default'}
install_dependencies=true
install_dropbox=true
setup_host=true
install_java=true
install_numlockx=true
install_chrome=true
install_code=true
install_whatpulse=true
install_remmina=true
install_intellij=true
install_ansible=false
install_sdkman=true
install_packer=true
install_r10k=true
install_npm=true
install_git=true
setup_git=false
install_smartgit=true
setup_sshkeys=false
setup_repos=false
install_conkey=true
setup_packages=true
setup_vagrant=true
install_vmware=true
#####################################################
#              HELPER FUNCTIONS                     #
#####################################################
print() {
    echo -e "***\n***$@\n***"
}

p_install() {
    print "INSTALLING: $@"
}

p_installed() {
    print "PACKAGE ALREADY INSTALLED: $@"
}

is_installed() {
    dpkg -s $1 2>/dev/null
    return $?
}

apt_update() {
    print 'APT: UPDATE: ...'
    sudo apt update > /dev/null
    print 'APT: UPDATE: Done'
}

apt_install() {
    p_install $@
    sudo apt install -y $@
}

apt_check() {
    to_check=$1
    dpkg -l | grep $1 > /dev/null
    [[ $? == 0 ]] && return 0 || return 1
}
#####################################################
#              DEPENDENCY PACKAGES                  #
#####################################################
if [[ $install_dependencies == true ]]; then
    apt_update
    dep_packages='curl wget vim vim-gnome'
    for pkg in $dep_packages
    do
        if $(apt_check $pkg); then
            p_installed $pkg
        else
            apt_install $pkg
        fi
    done
fi
#####################################################
#              DROPBOX INSTALL                      #
#####################################################
if [[ $install_dropbox == true ]]; then
    if $(apt_check dropbox); then
        print 'PACKAGE ALREADY INSTALLED: dropbox'
    else
        apt_install dropbox nemo-dropbox
        print "DROPBOX: Dropbox should be installed now, setup it up and type 'y' here when it's done syncing..."
        read dropbox_finished
        print "DROPBOX: You entered: $dropbox_finished"
        if [ $dropbox_finished != 'y' ]; then
            print "DROPBOX: Dropbox is required and you did NOT enter 'y', exiting..."
            exit 1
        fi
    fi
fi
#####################################################
#              HOST PREPARATIONS                    #
#####################################################
if [[ $setup_host == true ]]; then
    gsettings set org.cinnamon.desktop.background picture-uri "file:///home/phill/Dropbox/Photos/circuits_integrated_circuit_cpu_1366x768_wallpaper_Wallpaper HD_2560x1600_www.paperhi.com.jpg"

    if [ $host == 'quantum' ]; then
        print 'HOST PREP: Fixing LED Keyboard...'
        grep 'xset led 3' /etc/mdm/Init/Default 2>/dev/null
        hasLEDFix=$?
        if [ $hasLEDFix -ne 0 ]; then
            sudo sed -i 's/exit 0/xset led 3\n\nexit 0/g' /etc/mdm/Init/Default
        fi
    fi
fi
#####################################################
#              JAVA SETUP                           #
#####################################################
if [[ $install_java == true ]]; then
    jdk_package='openjdk-7-jdk'
    if $(apt_check $jdk_package); then
        print "PACKAGE ALREADY INSTALLED: $jdk_package"
    else
        apt_install $jdk_package
        grep 'JAVA_HOME=' /etc/environment 2>/dev/null
        hasJavaHomeSet=$?
        if [ $hasJavaHomeSet -ne 0 ]; then
            echo "JAVA_HOME='/usr/lib/jvm/java-7-openjdk-amd64'" >> /etc/environment
        fi
        source /etc/environment
    fi
fi
#####################################################
#              INSTALL: NumLockx                    #
#####################################################
if [[ $install_numlockx == true ]]; then
    if $(apt_check numlockx); then
        print 'PACKAGE ALREADY INSTALLED: numlockx'
    else
        apt_install numlockx
        grep '#Numlock enable' /etc/rc.local 2>/dev/null
        hasNumLockx=$?
        if [ $hasNumLockx -ne 0 ]; then
            sudo sed -i 's|^exit 0.*$|# Numlock enable\n[ -x /usr/bin/numlockx ] \&\& numlockx on\n\nexit 0|' /etc/rc.local
        fi
    fi
fi
#####################################################
#              INSTALL: Chrome                      #
#####################################################
if [[ $install_chrome == true ]]; then
    if $(apt_check google-chrome-stable); then
        print 'PACKAGE ALREADY INSTALLED: google-chrome-stable'
    else
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
        apt_update
        apt_install google-chrome-stable
    fi
fi
#####################################################
#              INSTALL: VS-Code                     #
#####################################################
if [[ $install_code == true ]]; then
    if [ ! -e /usr/local/bin/code ]; then
        install_dir='/opt'
        filename='VSCode-linux64.zip'
        url='https://az764295.vo.msecnd.net/public/0.10.6-release'

        curl -f -o /tmp/${filename} ${url}/${filename}
        sudo unzip /tmp/${filename} -d ${install_dir}
        rm /tmp/$filename
        sudo ln -s ${install_dir}/VSCode-linux-x64/Code /usr/local/bin/code
    else
        print "PACKAGE ALREADY INSTALLED: VSCode-linux64.zip"
    fi
fi
#####################################################
#              INSTALL: WhatPulse                   #
#####################################################
if [[ $install_whatpulse == true ]]; then
    if [ ! -e /usr/local/bin/whatpulse ]; then
        filename='whatpulse-linux-64bit-2.6.3.tar.gz'
        url='http://static.whatpulse.org/files'
        dependencies='libqtcore4 libqtwebkit4 libqt4-sql libqt4-sql-sqlite libssl-dev libqtscript4-core libqtscript4-gui libqtscript4-network libqtscript4-webkit libpcap0.8 libpcapnav0'

        apt_install $dependencies
        dep_failed=$?
        if [ $dep_failed -ne 0 ]; then
            echo ''
            echo 'Dependency install failed, stopping install'
            echo ''
        else
            curl -f -o /tmp/$filename ${url}/${filename}
            sudo mkdir /opt/whatpulse
            sudo tar -xvf /tmp/${filename} -C /opt/whatpulse
            rm -f /tmp/${filename}
            cd /opt/whatpulse
            # After libpcap installation, you need to tell the OS to allow the WhatPulse binary to hook into the network traffic. To do so, execute this command inside the directory where the binary resides:
            sudo setcap cap_net_raw,cap_net_admin=eip ./whatpulse
            cd -
            sudo ln -s /opt/whatpulse/whatpulse /usr/local/bin/whatpulse
        fi
    else
        print "PACKAGE ALREADY INSTALLED: whatpulse-linux-64bit-2.6.3.tar.gz"
    fi
fi
#####################################################
#              INSTALL: REMMINA                     #
#####################################################
if [[ $install_remmina == true ]]; then
    if $(apt_check remmina); then
        print 'PACKAGE ALREADY INSTALLED: remmina'
    else
        sudo apt-add-repository -y ppa:remmina-ppa-team/remmina-next
        apt_update
        apt_install -y remmina remmina-plugin-rdp libfreerdp-plugins-standard remmina-plugin-vnc
    fi
fi
#####################################################
#              INSTALL: Intellij                    #
#####################################################
if [[ $install_intellij == true ]]; then
    file='ideaIC-15.0.3.tar.gz'
    if [ ! -e /usr/local/bin/idea ]; then
        url='https://d1opms6zj7jotq.cloudfront.net/idea'
        target='idea-IC-143.1821.5'

        curl -f -o /tmp/$file ${url}/${file}
        sudo tar -xvf /tmp/${file} -C /opt/ > /dev/null
        rm -f /tmp/${file}
        sudo ln -s /opt/${target}/bin/idea.sh /usr/local/bin/idea
    else
        p_installed $file
    fi
fi
#####################################################
#              INSTALL: Ansible                     #
#####################################################
if [[ $install_ansible == true ]]; then
    # apt_install python-pip
    sudo apt-add-repository -y ppa:ansible/ansible
    apt_update
    apt_install ansible
fi
#####################################################
#              INSTALL: GVM/Grails                  #
#####################################################
if [[ $install_sdkman == true ]]; then
    if [ ! -e ~/.sdkman/bin/sdkman-init.sh ]; then
        curl -s http://get.sdkman.io | bash
    else
        print "PACKAGE ALREADY INSTALLED: sdkman"
    fi
    source ~/.sdkman/bin/sdkman-init.sh
    which grails > /dev/null
    grails_installed=$?
    sdk_to_install='grails'
    for sdk_pack in $sdk_to_install
    do
        which $sdk_pack > /dev/null
        sdk_installed=$?
        if [ $sdk_installed -ne 0 ]; then
            yes 'yes' | sdk install $sdk_pack
        else
            p_installed $sdk_pack
        fi
    done
fi
#####################################################
#              INSTALL: Packer                      #
#####################################################
if [[ $install_packer == true ]]; then
    if [ ! -e /usr/local/bin/packer ]; then
        install_dir='/opt'
        filename='packer_0.8.6_linux_amd64.zip'
        url='https://releases.hashicorp.com/packer/0.8.6'

        curl -f -o /tmp/${filename} ${url}/${filename}
        sudo unzip /tmp/${filename} -d ${install_dir}/packer
        rm /tmp/$filename
        sudo ln -s ${install_dir}/packer/packer /usr/local/bin/packer
    else
        p_installed 'Packer'
    fi
fi
#####################################################
#              INSTALL: r10k                        #
#####################################################
if [[ $install_r10k == true ]]; then
    which r10k > /dev/null
    r10k_installed=$?
    if [ $r10k_installed -ne 0 ]; then
        p_install 'r10k'
        sudo gem install r10k
    else
        p_installed 'r10k'
    fi
fi
#####################################################
#              INSTALL: NPM PACKAGES                #
#####################################################
if [[ $install_npm == true ]]; then
    npm_pkg='grunt bower'
    for pkg in $npm_pkg
    do
        which $pkg > /dev/null
        if [ $? -ne 0 ]; then
            p_install "NPM: $pkg"
            sudo npm install -g $pkg
        else
            p_installed "NPM: $pkg"
        fi
    done
fi
#####################################################
#              INSTALL & CONFIGURE: GIT             #
#####################################################
if [[ $install_git == true ]]; then
    if $(apt_check git); then
        p_installed 'git'
    else
        apt_install git
    fi
fi

if [[ $setup_git == true ]]; then
    print 'CONFIG: Git User/Email/Global Ignore'
    cp -f .gitignore_global ~/.gitignore_global
    git config --global core.excludesfile ~/.gitignore_global
    print "Git Config: Enter your git 'user.name'"
    read git_user_name
    git config --global user.name $git_user_name
    pring "Git Config: Enter your git 'user.email'"
    read git_user_email
    git config --global user.email $git_user_email
fi
#####################################################
#              INSTALL: SMARTGIT                    #
#####################################################
if [[ $install_smartgit == true ]]; then
    if [ ! -e /usr/local/bin/smartgit ]; then
        filename='smartgit-generic-7_0_4.tar.gz'
        url='http://www.syntevo.com/downloads/smartgit'

        curl -f -o /tmp/${filename} ${url}/${filename}
        sudo tar -xvf /tmp/${filename} -C /opt
        rm -f /tmp/${filename}
        sudo ln -s /opt/smartgit/bin/smartgit.sh /usr/local/bin/smartgit
    else
        p_installed 'smartgit'
    fi
fi

#####################################################
#              CONFIGURE: SSH KEYS                  #
#####################################################
if [[ $setup_sshkeys == true ]]; then
    print 'CONFIG: SSH Keys'
    ln -s ~/Dropbox/0-Backups/rcs_mac/ssh_keys/current/ ~/.ssh
    sudo chmod 600 ~/Dropbox/0-Backups/rcs_mac/ssh_keys/current/id_rsa
    sudo chmod 600 ~/Dropbox/0-Backups/rcs_mac/ssh_keys/current/id_rsa.pub
    sudo chmod 644 ~/Dropbox/0-Backups/rcs_mac/ssh_keys/current/known_hosts
    sudo chmod 755 ~/Dropbox/0-Backups/rcs_mac/ssh_keys/current
fi
#####################################################
#              CONFIGURE: REPOS                     #
#####################################################
if [[ $setup_repos == true ]]; then
    ./scripts/repos.groovy 'bitbucket' ~/src phill
    ./scripts/repos.groovy 'github' ~/src patrick-hill
fi
#####################################################
#              INSTALL: CONKY/MANAGER               #
#####################################################
if [[ $install_conkey == true ]]; then
    grep -q teejee /etc/apt/sources.list.d/*
    if [ $? -ne 0 ]; then
        sudo add-apt-repository -y ppa:teejee2008/ppa
        apt_update
        apt_install conky-manager
    else
        p_installed 'conkey-manager'
    fi
fi
#####################################################
#              INSTALL: PACKAGES                    #
#####################################################
if [[ $setup_packages == true ]]; then
    # Base packages
    packages='gcc make build-essential linux-headers-$(uname -r) software-properties-common'
    # System Utils
    packages="$packages yakuake"
    # AutoKey: Provides typed macro support
    packages="$packages autokey-gtk autokey-common python-gpgme python-simplejson"
    # Virtualbox & VMware
    packages="$packages virtualbox-5.0"
    # Groovy/Gradle
    packages="$packages groovy gradle"
    # Communications
    packages="$packages skype hipchat"
    # Vagrant
    packages="$packages vagrant"
    # Intall packages
    apt_install ${packages}
fi
#####################################################
#              CONFIGURE: VAGRANT                   #
#####################################################
if [[ $setup_vagrant == true ]]; then
    # https://github.com/smdahlen/vagrant-hostmanager
    vagrant_plugins='vagrant-vmware-workstation vagrant-salt vagrant-multiprovider-snap vagrant-hostmanager'
    for v_plugin in $vagrant_plugins
    do
        vagrant plugin list | grep -q $v_plugin
        v_plugin_installed=$?
        if [ $v_plugin_installed -ne 0 ]; then
            vagrant plugin install $v_plugin
        else
            p_installed "Vagrant Plugin: $v_plugin"
        fi
    done
    vagrant plugin license vagrant-vmware-workstation ~/Dropbox/0-Backups/rcs_mac/licenses/vagrant_workstation_license.lic
fi
#####################################################
#              INSTALL: VMWare                      #
#####################################################
if [[ $install_vmware == true ]]; then
    if [ ! -e /usr/bin/vmware ]; then
        file='VMware-Workstation-Full-12.1.0-3272444.x86_64.bundle'
        url='https://download3.vmware.com/software/wkst/file'
        curl -f -o /tmp/$file ${url}/${file}
        sudo ./tmp/$file
        rm -f $file
    else
        p_installed 'VMWare'
    fi
fi

