# allow ip4:
https://askubuntu.com/questions/1123177/sudo-add-apt-repository-hangs



#########################################
# BASICS
#########################################



# get latest and greatest
sudo apt-get update

# Installing the necessary packages
# add nomodeset to grub loader
# this may help with getting the screens working.


#########################################
# SOFTWARE
#########################################


# install chrome
https://www.google.com/chrome/
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

# install git
sudo apt-get -y install git
git config --global corsudo e.filemode false

# install meld - for git merges
sudo apt-get -y install meld
	
# install curl
sudo apt -y install curl


# install gimp
# see: 
# Uninstall GIMP
sudo apt-get autoremove gimp gimp-plugin-registry
# Add the following PPA
sudo add-apt-repository ppa:otto-kesselgulasch/gimp
sudo apt-get update
# Reinstall the latest GIMP
sudo apt-get install gimp

# or ...
sudo snap install gimp --channel=edge


# atom
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt-get update
sudo apt-get -y install atom
apm install atom-updater-linux
apm install sync-settings
# https://atom.io/packages/sync-settings



# install npm
sudo apt install nodejs
sudo apt-get -y install npm

# install slack
sudo snap install slack --classic


#########################################
# LAMP
#########################################

# install apache
sudo apt-get -y install apache2
	
# install mysql
sudo apt-get install mysql-server
sudo /usr/bin/mysql_secure_installation
# https://stackoverflow.com/questions/39281594/error-1698-28000-access-denied-for-user-rootlocalhost

sudo mysql -u root

mysql> USE mysql;
mysql> UPDATE user SET plugin='mysql_native_password' WHERE User='root';
mysql> FLUSH PRIVILEGES;
mysql> exit;

sudo service mysql restart

# mysql -u root -p[as you set it]
# see: https://linuxconfig.org/how-to-reset-root-mysql-password-on-ubuntu-18-04-bionic-beaver-linux

# install additioanl apache modules
sudo a2enmod rewrite
sudo a2enmod vhost_alias
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo service apache2 restart

# install phpmyadmin
sudo apt-get -y install phpmyadmin	


# install php versions
rm /usr/local/bin/php-switch-scripts -rf
git clone https://github.com/rapidwebltd/php-switch-scripts.git
cd php-switch-scripts/
bash setup.sh
cd ..
mv php-switch-scripts /usr/local/bin/
cat <<EOT >> /usr/local/bin/php-switch
if [ \$# -eq 0 ]
  then
    echo "Please supply the php version you would like to switch to as an argument."
else
   bash /usr/local/bin/php-switch-scripts/switch-to-php-\$1.sh
fi
EOT
chmod +x /usr/local/bin/php-switch
echo "you can now use php-switch X.X  to switch to any version of PHP"


# test installing exteions on various versions of PHP
sudo apt-get install -y php7.4-intl
sudo apt-get install -y php7.4-intl



#########################################
# COMPOSER
#########################################

# install composer
sudo apt-get -y install composer
nano ~/.bashrc 
# add one of these: 
# - PATH=~/.composer/vendor/bin:$PATH
# - PATH=~/.config/composer/vendor/bin:$PATH
# reload ~/.bashrc
source ~/.bashrc


# install linter
composer global require sunnysideup/easy-coding-standards:dev-master
composer global update


#########################################
# SETTINGS
#########################################

# set up public key and create aliases
sudo nano ~/.ssh/config 
	

# set php settings
sudo echo "date.timezone = 'Pacific/Auckland'" >> /etc/php/7.4/apache2/php.ini
sudo service apache2 restart

# set up public key
ssh-keygen



#########################################
# SILVERSTRIPE
#########################################



# set up sites-enables - see default.conf
sudo nano /etc/apache2/sites-enabled/sites-enabled.conf

# create folders for silverstripe
mkdir /var/www/ss3
mkdir /var/www/ss4
mkdir /var/www/ss5

# set up aliases
sudo ln -s /var/www/ss3 /ss3
sudo ln -s /var/www/ss4 /ss4
sudo ln -s /var/www/ss5 /ss5

# sspak
cd /usr/local/bin
curl -sS https://silverstripe.github.io/sspak/install | sudo php


# test up test site. 
cd /var/www/ss4
sudo nano /etc/hosts
echo "127.0.0.1 test.ss4" | sudo tee -a /etc/hosts
sudo chown www-data /var/www/ss4 -R #must be all www-data
composer create-project silverstripe/installer test 4.7
cd test
ls
# install sake
cd /var/www/ss4/test
sudo ./vendor/bin/sake installsake


