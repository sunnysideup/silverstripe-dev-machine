#!/bin/bash

# Update to the latest version of Ubuntu
echo -e "\e[33m[INFO] --- Updating to the latest version of Ubuntu.\e[0m"
echo "More info: https://ubuntu.com/tutorials/upgrading-ubuntu-desktop#1-before-you-start"

# Allow IPv4 support
echo -e "\e[33m[INFO] --- Allowing IPv4 support.\e[0m"
echo "See: https://askubuntu.com/questions/1123177/sudo-add-apt-repository-hangs"

#########################################
# BASICS
#########################################

echo -e "\e[33m[INFO] --- Updating package lists.\e[0m"
sudo apt -y update

#########################################
# DISPLAYS
#########################################

echo -e "\e[33m[INFO] --- Installing display packages and configuring settings.\e[0m"
# Instructions to help configure multiple displays and fix issues with simpledrm

#########################################
# SOFTWARE
#########################################

echo -e "\e[33m[INFO] --- Installing VS Code.\e[0m"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt -y update && sudo apt -y install code

echo -e "\e[33m[INFO] --- Installing Google Chrome.\e[0m"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb

echo -e "\e[33m[INFO] --- Installing Git and configuring settings.\e[0m"
sudo apt -y install git
git config --global core.filemode false

echo -e "\e[33m[INFO] --- Installing Meld for Git merges.\e[0m"
sudo apt -y install meld

echo -e "\e[33m[INFO] --- Installing Curl.\e[0m"
sudo apt -y install curl

echo -e "\e[33m[INFO] --- Installing and configuring GIMP.\e[0m"
sudo apt-get -y autoremove gimp gimp-plugin-registry
sudo add-apt-repository ppa:otto-kesselgulasch/gimp
sudo apt -y update
sudo apt -y install gimp

echo -e "\e[33m[INFO] --- Installing Node.js and npm.\e[0m"
sudo apt -y install nodejs
sudo apt -y install npm

echo -e "\e[33m[INFO] --- Installing nvm.\e[0m"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

echo -e "\e[33m[INFO] --- Installing Slack.\e[0m"
sudo snap install slack --classic

#########################################
# LAMP
#########################################

echo -e "\e[33m[INFO] --- Installing Apache.\e[0m"
sudo apt -y install apache2

echo -e "\e[33m[INFO] --- Installing MySQL.\e[0m"
sudo apt -y install mysql-server
sudo /usr/bin/mysql_secure_installation

echo -e "\e[33m[INFO] --- Restarting MySQL service.\e[0m"
sudo pkill mysqld
sudo service mysql restart

echo -e "\e[33m[INFO] --- Enabling Apache modules.\e[0m"
sudo a2enmod rewrite
sudo a2enmod vhost_alias
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo service apache2 restart

echo -e "\e[33m[INFO] --- Installing phpMyAdmin.\e[0m"
sudo apt -y install phpmyadmin

echo -e "\e[33m[INFO] --- Installing PHP switcher.\e[0m"
git clone https://github.com/sunnysideup/silverstripe-switch-php-versions.git
sudo bash silverstripe-switch-php-versions/install.sh
rm silverstripe-switch-php-versions -rf

#########################################
# COMPOSER
#########################################

echo -e "\e[33m[INFO] --- Installing Composer.\e[0m"
sudo apt -y install composer

echo -e "\e[33m[INFO] --- Setting up Composer environment.\e[0m"
echo "- PATH=~/.config/composer/vendor/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

echo -e "\e[33m[INFO] --- Installing Composer linter.\e[0m"
composer global require sunnysideup/easy-coding-standards:dev-master
composer global update

#########################################
# SETTINGS
#########################################

echo -e "\e[33m[INFO] --- Configuring SSH keys.\e[0m"
sudo nano ~/.ssh/config 

echo -e "\e[33m[INFO] --- Setting PHP timezone.\e[0m"
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.4/apache2/php.ini
sudo service apache2 restart

echo -e "\e[33m[INFO] --- Generating SSH key.\e[0m"
ssh-keygen

#########################################
# SILVERSTRIPE
#########################################

echo -e "\e[33m[INFO] --- Setting up SilverStripe directories and configurations.\e[0m"
sudo nano /etc/apache2/sites-enabled/sites-enabled.conf
sudo chown ssu:www-data . -R
mkdir /var/www/ss3
mkdir /var/www/ss4
mkdir /var/www/ss5

echo -e "\e[33m[INFO] --- Creating symbolic links for SilverStripe installations.\e[0m"
sudo ln -s /var/www/ss3 /ss3
sudo ln -s /var/www/ss4 /ss4
sudo ln -s /var/www/ss5 /ss5

echo -e "\e[33m[INFO] --- Installing SSPak.\e[0m"
cd /usr/local/bin
curl -sS https://silverstripe.github.io/sspak/install | sudo php

echo -e "\e[33m[INFO] --- Setting up test SilverStripe site.\e[0m"
cd /var/www/ss4
echo "127.0.0.1 test.ss4" | sudo tee -a /etc/hosts
sudo chown www-data /var/www/ss4 -R
composer create-project silverstripe/installer test 4.7
cd test
ls

echo -e "\e[33m[INFO] --- Installing Sake for SilverStripe.\e[0m"
cd /var/www/ss4/test
sudo ./vendor/bin/sake installsake
