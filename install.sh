#!/bin/bash

echo "
--- 
Update to the latest version of Ubuntu.
---
https://ubuntu.com/tutorials/upgrading-ubuntu-desktop#1-before-you-start
"
sudo apt -y update

echo "
--- 
Allow IPv4 support:
---
https://askubuntu.com/questions/1123177/sudo-add-apt-repository-hangs
"

echo "
--- 
Updating package lists to latest and greatest
---"
sudo apt -y update


echo "
--- 
Installing necessary packages for displays:
---
Add nomodeset to GRUB loader; this may help with screen detection.
If only one display is detected, consider blacklisting simpledrm
Run dmesg | grep -i drm to check if simpledrm is loading
Append modprobe.blacklist=simpledrm to GRUB_CMDLINE_LINUX_DEFAULT if needed"


echo "
--- 
Installing VS Code (automated repository addition)
---"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt -y update && sudo apt -y install code


# Install git
echo "
--- 
Installing Google Chrome
---
https://www.google.com/chrome/
"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb

echo "
--- 
Installing Git and configuring settings
---"
sudo apt -y install git
git config --global core.filemode false



echo "
--- 
Installing Meld for Git merges
---"
sudo apt -y install meld

echo "
--- 
Installing Curl
---"
sudo apt -y install curl

echo "
--- 
Installing GIMP with custom repository
---"
sudo apt-get -y autoremove gimp gimp-plugin-registry
sudo add-apt-repository ppa:otto-kesselgulasch/gimp
sudo apt -y update
sudo apt -y install gimp

echo "
--- 
Installing GIMP via snap (alternative)
---"
sudo snap install gimp --channel=edge

echo "
--- 
Installing Node.js and npm
---"
sudo apt -y install nodejs
sudo apt -y install npm

echo "
--- 
Installing nvm (Node Version Manager)
---"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
echo "
---
manually added - nvm use latest npm / node
---"
echo "
# manually added - nvm use latest npm / node
nvm use node" >> ~/.bashrc
source ~/.bashrc


echo "
--- 
Installing Slack via snap
---"

sudo snap install slack --classic


# Install apache
echo "
--- 
Installing Apache
---"
sudo apt -y install apache2

	
# Install mysql
echo "
--- 
Installing MySQL and securing installation
---"
sudo apt -y  install mysql-server
cat << EOF
Recommended settings:
# VALIDATE PASSWORD COMPONENT :n
# Remove anonymous users?: n
# Disallow root login remotely?: y
# Remove test database and access to it? : y
# Reload privilege tables now?: y
EOF


# https://stackoverflow.com/questions/39281594/error-1698-28000-access-denied-for-user-rootlocalhost
# Login as root to mysql then ... 
cat << EOF
Please run the below commands in mysql:
# mysql> flush privileges;
# mysql> use mysql;
# mysql> UNINSTALL COMPONENT 'file://component_validate_password';
# mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '';
# mysql> UPDATE user SET plugin="mysql_native_password" WHERE User='root';
# mysql> quit;
Enter mysql password
EOF

sudo mysql -u root -p

sudo pkill mysqld
sudo service mysql restart

# mysql -u root -p[as you set it]
# See: https://linuxconfig.org/how-to-reset-root-mysql-password-on-ubuntu-18-04-bionic-beaver-linux

# Install additioanl apache modules
echo "
--- 
Setting up MySQL root user and privileges
---"
sudo mysql -u root -p
mysql> flush privileges;
mysql> use mysql;
mysql> UNINSTALL COMPONENT 'file://component_validate_password';
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '';
mysql> UPDATE user SET plugin="mysql_native_password" WHERE User='root';
mysql> quit;
sudo pkill mysqld
sudo service mysql restart

echo "
--- 
Enabling Apache modules
---"
sudo a2enmod rewrite
sudo a2enmod vhost_alias
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo apt install libapache2-mod-php8.3
sudo service apache2 restart


echo "
--- 
Installing multiple PHP versions via SilverStripe switch
---"
cd ~
git clone https://github.com/sunnysideup/silverstripe-switch-php-versions.git
sudo bash silverstripe-switch-php-versions/install.sh
rm silverstripe-switch-php-versions -rf


echo "
--- 
Installing phpMyAdmin
---"
sudo apt -y install phpmyadmin
git clone https://github.com/sunnysideup/silverstripe-switch-php-versions.git


# https://getcomposer.org/download/

echo "
--- 
Installing Composer and adding path to bashrc
---"
sudo apt -y install composer
echo "
# manually added composer to path
PATH=~/.config/composer/vendor/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

echo "
--- 
Downloading and verifying Composer installer"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

echo "
--- 
Installing linter via Composer"
composer global require sunnysideup/easy-coding-standards:dev-master
composer global update

composer -v

if [ -d "$HOME/.composer/vendor/bin" ]; then
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
elif [ -d "$HOME/.config/composer/vendor/bin" ]; then
    echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
else
    echo "ERROR: No composer folder"
fi

source ~/.bashrc

# Set up public key and create aliases
sudo nano ~/.ssh/config 
	
# Set php settings
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.0/apache2/php.ini
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.2/apache2/php.ini
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.4/apache2/php.ini
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/8.0/apache2/php.ini
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/8.1/apache2/php.ini
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/8.1/apache2/php.ini
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/8.3/apache2/php.ini


sudo service apache2 restart


echo "
--- 
Setting up SSH public key and creating aliases"
sudo nano ~/.ssh/config 

echo "
--- 
Configuring PHP timezone setting"
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.4/apache2/php.ini
sudo service apache2 restart

echo "
--- 
Generating SSH key"
ssh-keygen

echo "
---
Folder structure
---"

# Set up sites-enables - see default.conf
sudo nano /etc/apache2/sites-enabled/sites-enabled.conf


# Create folders for silverstripe
sudo mkdir -p /var/www/ss{3..5}
sudo mkdir -p /var/www/craft
sudo mkdir -p /var/www/wp
sudo mkdir -p /var/www/upgrader
sudo mkdir -p /var/www/upgrades
sudo chown $USER:www-data /var/www -R


echo "
--- 
Creating symbolic links for SilverStripe folders
---"
sudo ln -s /var/www/ss3 /ss3
sudo ln -s /var/www/ss4 /ss4
sudo ln -s /var/www/ss5 /ss5
sudo ln -s /var/www/craft /craft
sudo ln -s /var/www/wp /wp


echo "
--- 
Installing SSPak for SilverStripe
---"
cd /usr/local/bin
curl -sS https://silverstripe.github.io/sspak/install | sudo php

echo "
--- 
Installing SSBak (better sspak) for SilverStripe
---"
curl -sL https://github.com/axllent/ssbak/releases/latest/download/ssbak_linux_amd64.tar.gz | sudo tar -zx -C /usr/local/bin/ ssbak

echo "
--- 
Setting up test site for SilverStripe
---"
cd /var/www/ss5
echo "127.0.0.1 test.ss4" | sudo tee -a /etc/hosts
sudo chown www-data /var/www/ss4 -R
composer create-project silverstripe/installer test 
cd test
ls

echo "
--- 
Installing sake for SilverStripe
---"
cd /var/www/ss4/test
sudo ./vendor/bin/sake installsake


echo "



---
THE END 
---




"