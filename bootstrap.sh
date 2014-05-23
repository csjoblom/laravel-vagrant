#/usr/bin/env bash
#Update the box
#--
#Downloads the package lists from repos and updates them
apt-get update

#install vim
apt-get install -y vim

#Apache
#---
#Install
apt-get install -y apache2

#remove /var/www/ default
rm -rf /var/www

# symlink /vagrant to /var/www
ln -fs /vagrant /var/www

# add servname to httpd.conf
echo "ServerName localhost" > /etc/apache2/conf-available/httpd.conf

#Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/vagrant/public"
  ServerName localhost
  <Directory "/vagrant/public">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default

#enable mod_rewrite
a2enmod rewrite
# restart apache
service apache2 restart

#PHP5.4
#---
apt-get install -y libapache2-mod-php5
#add add-apt-repo binary
apt-get install -y python-software-properties
#install php5.4
add-apt-repository ppa:ondrej/php5
#update
apt-get update

#PHP stuff
#---
#CLI Interp
apt-get install -y php5-cli
#mysql
apt-get install -y php5-mysql
#curl
apt-get install -y php5-curl
#mcrypt
apt-get install -y php5-mcrypt

#sys curl
apt-get install -y curl

#mysql
#---
#ignore the post install qs
export DEBIAN_FRONTEND=noninteractive
#install quietly
apt-get -q -y install mysql-server-5.5

#git
#--
apt-get install git-core

#composer
#--
curl -s https://getcomposer.org/installer | php
#make available globally
mv composer.phar /usr/local/bin/composer

#laravel
#---
#Load comp packages
cd /var/www
composer install --dev
#set up db
echo "CREATE DATABASE IF NOT EXISTS lavatest" | mysql
echo "CREATE USER 'csjoblom'@'localhost' IDENTIFIED BY 'chris'" | mysql
echo "GRANT ALL PRIVILEGES ON lavatest.* to 'csjoblom'@'localhost' IDENTIFIED BY 'chris'" | mysql
php artisan migrate --env=development
php artisan db:seed --env=development
