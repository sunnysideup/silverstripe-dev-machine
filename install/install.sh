# Installing the necessary packages
#add nomodeset to grub loader

# set up users

# install chrome:
https://www.google.com/chrome/
https://linuxconfig.org/how-to-install-google-chrome-web-browser-on-ubuntu-20-04-focal-fossa

#latest and greatest
sudo apt-get update

#git
sudo apt-get -y install git
git config --global core.filemode false

#apache
sudo apt-get -y install apache2
	
#mysql
sudo apt-get install mysql-server
sudo /usr/bin/mysql_secure_installation
# https://stackoverflow.com/questions/39281594/error-1698-28000-access-denied-for-user-rootlocalhost
mysql -u root -p[as you set it]
# see: https://linuxconfig.org/how-to-reset-root-mysql-password-on-ubuntu-18-04-bionic-beaver-linux

# apache modules
sudo a2enmod rewrite
sudo a2enmod vhost_alias
sudo service apache2 restart

#phpmyadmin
sudo apt-get -y install phpmyadmin	

	
#meld
sudo apt-get -y install meld
	
#curl
sudo apt -y install curl

#composer
sudo apt-get -y install composer

# php versions
see: https://github.com/sunnysideup/silverstripe-switch-php-versions

#test site basics
sudo apt-get install -y php7.4-intl
sudo apt-get install -y php7.4-intl

# etc/hosts settings
sudo nano /etc/hosts
echo "127.0.0.1 test.ss3" | sudo tee -a /etc/hosts
echo "127.0.0.1 test.ss4" | sudo tee -a /etc/hosts

sudo nano /etc/apache2/sites-enabled/default.conf


#php settings
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.4/apache2/php.ini
sudo service apache2 restart

cd /var/www/ss4
sudo chown www-data /var/www/ss4 -R #must be all www-data
composer create-project silverstripe/installer test 4.4
cd test
ls

#ssh
sudo nano ~/.ssh/config
ssh-keygen
	
	
#install gimp
sudo add-apt-repository ppa:otto-kesselgulasch/gimp
sudo apt-get -y install gimp
wget http://archive.ubuntu.com/ubuntu/pool/universe/p/pygtk/python-gtk2_2.24.0-6_amd64.deb
wget http://archive.ubuntu.com/ubuntu/pool/universe/g/gimp/gimp-python_2.10.8-2_amd64.deb
sudo apt install gimp gimp-plugin-registry gimp-gmic
sudo apt install python python-cairo python-gobject-2
sudo dpkg -i python-gtk2_2.24.0-6_amd64.deb
sudo dpkg -i gimp-python_2.10.8-2_amd64.deb
sudo snap install gimp

# install easy coding standards
composer global require --dev sunnysideup/easy-coding-standards:dev-master


# atom
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt-get update
sudo apt-get -y install atom
apm install atom-updater-linux
apm install sync-settings
# https://atom.io/packages/sync-settings

# sspak
cd /usr/local/bin
curl -sS https://silverstripe.github.io/sspak/install | sudo php

# install npm
sudo apt-get -y install npm

# install slack
sudo snap install slack --classic
