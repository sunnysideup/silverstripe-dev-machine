# Update to latest version of ubuntu.
# https://ubuntu.com/tutorials/upgrading-ubuntu-desktop#1-before-you-start


# Allow ip4:
# https://askubuntu.com/questions/1123177/sudo-add-apt-repository-hangs


#########################################
# BASICS
#########################################

# Get latest and greatest
sudo apt -y update

#########################################
# DISPLAYS
#########################################

# Installing the necessary packages
# Add nomodeset to grub loader this may help with getting the screens working.

# If your machine is only detecting one display you might have to blacklist simpledrm
# Run `dmesg | grep -i drm` to check if simpledrm is being loaded
# If it is append `modprobe.blacklist=simpledrm` to `GRUB_CMDLINE_LINUX_DEFAULT`


#########################################
# SOFTWARE
#########################################

# Install VS Code (automated repository addition)
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt -y update && sudo apt -y install code


# Install chrome
# https://www.google.com/chrome/
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb

# Install git
sudo apt -y install git
git config --global corsudo e.filemode false

# Install meld - for git merges
sudo apt -y install meld
	
# Install curl
sudo apt -y install curl

# Uninstall GIMP
sudo apt-get -y autoremove gimp gimp-plugin-registry

# Add the following PPA
sudo add-apt-repository ppa:otto-kesselgulasch/gimp
sudo apt -y update

# Install the latest GIMP
sudo apt -y install gimp

# Or... sudo snap install gimp --channel=edge

# Atom - Uncomment the below lines to install Atom
# wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
# sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
# sudo apt -y update
# sudo apt -y install atom
# apm install atom-updater-linux
# apm install sync-settings
# https://atom.io/packages/sync-settings

# Install npm
sudo apt -y install nodejs
sudo apt -y install npm

# Install nvm
# https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Install slack
sudo snap install slack --classic


#########################################
# LAMP
#########################################

# Install apache
sudo apt -y install apache2
	
# Install mysql
sudo apt -y  install mysql-server
cat << EOF
Recommended settings:
# VALIDATE PASSWORD COMPONENT :n
# Remove anonymous users?: n
# Disallow root login remotely?: y
# Remove test database and access to it? : y
# Reload privilege tables now?: y
EOF

sudo /usr/bin/mysql_secure_installation

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
sudo a2enmod rewrite
sudo a2enmod vhost_alias
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo service apache2 restart

# Install phpmyadmin
sudo apt -y install phpmyadmin	

# Install php versions
git clone https://github.com/sunnysideup/silverstripe-switch-php-versions.git

# Install
sudo bash silverstripe-switch-php-versions/install.sh

# Remove install files
rm silverstripe-switch-php-versions -rf


#########################################
# COMPOSER
#########################################

# Install composer
sudo apt -y install composer

# https://getcomposer.org/download/
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

composer -v

if [ -d "$HOME/.composer/vendor/bin" ]; then
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
elif [ -d "$HOME/.config/composer/vendor/bin" ]; then
    echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
else
    echo "ERROR: No composer folder"
fi

source ~/.bashrc

# Install linter
composer global require sunnysideup/easy-coding-standards:dev-master
composer global update


#########################################
# SETTINGS
#########################################

# Set up public key and create aliases
sudo nano ~/.ssh/config 
	
# Set php settings
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.4/apache2/php.ini
sudo service apache2 restart

# Set up public key
ssh-keygen


#########################################
# SILVERSTRIPE
#########################################

# Set up sites-enables - see default.conf
sudo nano /etc/apache2/sites-enabled/sites-enabled.conf

sudo chown ssu:www-data . -R

# Create folders for silverstripe
mkdir -p /var/www/ss{3..5}

# Set up aliases
sudo ln -s /var/www/ss3 /ss3
sudo ln -s /var/www/ss4 /ss4
sudo ln -s /var/www/ss5 /ss5

# SSPAK
cd /usr/local/bin
curl -sS https://silverstripe.github.io/sspak/install | sudo php

# Test up test site. 
cd /var/www/ss4
echo "127.0.0.1 test.ss4" | sudo tee -a /etc/hosts
sudo chown www-data /var/www/ss4 -R #must be all www-data
composer create-project silverstripe/installer test 4.7
cd test
ls

# Install sake
cd /var/www/ss4/test
sudo ./vendor/bin/sake installsake
