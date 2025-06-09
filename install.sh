#!/bin/bash

print_header() {
    echo -e "\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "---"
    echo "$1"
    echo "---"
    echo "\n\n"
    [ -n "$2" ] && echo "$2"
}

print_header "Update to the latest version of Ubuntu." "https://ubuntu.com/tutorials/upgrading-ubuntu-desktop#1-before-you-start"
sudo apt -y update

print_header "Allow IPv4 support:" "https://askubuntu.com/questions/1123177/sudo-add-apt-repository-hangs"

print_header "Updating package lists to latest and greatest"
sudo apt -y update

print_header "Installing necessary packages for displays" "Check GRUB and blacklist simpledrm if needed"

print_header "Installing VS Code"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt -y update && sudo apt -y install code

print_header "Installing Google Chrome" "https://www.google.com/chrome/"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt -y install ./google-chrome-stable_current_amd64.deb

print_header "Installing Git and configuring settings"
sudo apt -y install git
git config --global core.filemode false

print_header "Installing Meld for Git merges"
sudo apt -y install meld

print_header "Installing Curl"
sudo apt -y install curl

print_header "Installing GIMP with custom repository"
sudo apt-get -y autoremove gimp gimp-plugin-registry
sudo add-apt-repository ppa:otto-kesselgulasch/gimp
sudo apt -y update
sudo apt -y install gimp

print_header "Installing GIMP via snap (alternative)"
sudo snap install gimp --channel=edge

print_header "Installing Node.js and npm"
sudo apt -y install nodejs npm

print_header "Installing nvm (Node Version Manager)"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
echo "nvm use node" >> ~/.bashrc
source ~/.bashrc

print_header "Installing Slack via snap"
sudo snap install slack --classic

print_header "Installing Apache"
sudo apt -y install apache2

print_header "Installing MySQL"
sudo apt -y install mysql-server

print_header "Enabling Apache modules"
sudo a2enmod rewrite vhost_alias proxy headers proxy_http
sudo apt install libapache2-mod-php8.3
sudo service apache2 restart

print_header "Installing SilverStripe PHP version switcher"
cd ~
git clone https://github.com/sunnysideup/silverstripe-switch-php-versions.git
sudo bash silverstripe-switch-php-versions/install.sh
rm -rf silverstripe-switch-php-versions

print_header "Installing Composer and adding to PATH"
sudo apt -y install composer
echo 'PATH=$HOME/.config/composer/vendor/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

print_header "Downloading and verifying Composer installer"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer

print_header "Installing linter via Composer"
composer global config minimum-stability dev
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

print_header "Configuring PHP timezone setting"
for ver in 7.0 7.2 7.4 8.0 8.1 8.3; do
    echo "date.timezone = 'Pacific/Auckland'" | sudo tee -a /etc/php/$ver/apache2/php.ini
done
sudo service apache2 restart


print_header "Creating folder structure"

# Define the list of directories
dirs=(ss3 ss4 ss5 craft wp upgrader upgrades)

# Create directories
for dir in "${dirs[@]}"; do
    sudo mkdir -p "/var/www/$dir"
done

# Set ownership
sudo chown "$USER:www-data" /var/www -R

# Create symbolic links in root
for dir in "${dirs[@]}"; do
    sudo ln -s "/var/www/$dir" "/$dir"
done


print_header "Installing SSPak for SilverStripe"
cd /usr/local/bin
curl -sS https://silverstripe.github.io/sspak/install | sudo php

print_header "Installing SSBak for SilverStripe"
curl -sL https://github.com/axllent/ssbak/releases/latest/download/ssbak_linux_amd64.tar.gz | sudo tar -zx -C /usr/local/bin/ ssbak

print_header "Setting up SilverStripe test site"
cd /var/www/ss4
echo "127.0.0.1 test.ss4" | sudo tee -a /etc/hosts
composer create-project silverstripe/installer test 
cd test && sudo ./vendor/bin/sake installsake


# Find all php.ini files under /etc/php/*/
find /etc/php/ -type f -path '*/php.ini' | while read -r iniFile; do
    echo "Updating $iniFile"

    # Change display_errors to On
    sudo sed -i 's/^\s*display_errors\s*=.*/display_errors = On/' "$iniFile"

    # Change display_startup_errors to On
    sudo sed -i 's/^\s*display_startup_errors\s*=.*/display_startup_errors = On/' "$iniFile"
done


print_header "Generating SSH key"
ssh-keygen

print_header "THE END"

print_header "Setting up MySQL root user and privileges"
cat << EOF
Run in MySQL:
flush privileges;
use mysql;
UNINSTALL COMPONENT 'file://component_validate_password';
ALTER USER 'root'@'localhost' IDENTIFIED BY '';
UPDATE user SET plugin="mysql_native_password" WHERE User='root';
quit;

Then:
sudo pkill mysqld
sudo service mysql restart
EOF

print_header "Setting up SSH public key and creating aliases"
sudo nano ~/.ssh/config
