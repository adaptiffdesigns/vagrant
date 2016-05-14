#!/bin/bash
# Using Trusty64 Ubuntu

export DEBIAN_FRONTEND=noninteractive

#
# Add PHP, Phalcon, PostgreSQL and libsodium repositories
#
LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php5-5.6
apt-add-repository -y ppa:phalcon/stable
apt-add-repository -y ppa:chris-lea/libsodium
touch /etc/apt/sources.list.d/pgdg.list
echo -e "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list > /dev/null
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Cleanup package manager
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

apt-get update
apt-get install -y build-essential software-properties-common python-software-properties

#
# Setup locales
#
echo -e "LC_CTYPE=en_US.UTF-8\nLC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8\nLANGUAGE=en_US.UTF-8" | tee -a /etc/environment > /dev/null
locale-gen en_US en_US.UTF-8
dpkg-reconfigure locales

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

#
# Hostname
#
hostnamectl set-hostname $2

#
# MySQL with root:<no password>
#

apt-get -q -y install mysql-server-5.6 mysql-client-5.6 php5-mysql

case "$1" in
    apache)
        #
        # Apache
        #
        apt-get install -y apache2 libapache2-mod-php5
    ;;
    nginx)
        #
        # nginx
        #
        apt-get install -y nginx php5-fpm
    ;;
    *)
        echo "Invalid webserver supplied"
        exit 1
    ;;
esac



#
# PHP
#
apt-get install -y php5 php5-cli php5-dev php-pear php5-mcrypt php5-curl php5-intl php5-xdebug php5-gd php5-imagick php5-imap php5-mhash php5-xsl
php5enmod mcrypt intl curl

# Update PECL channel
pecl channel-update pecl.php.net

#
# Apc
#
apt-get -y install php-apc php5-apcu
echo 'apc.enable_cli = 1' | tee -a /etc/php5/mods-available/apcu.ini > /dev/null

#
# Memcached
#
apt-get install -y memcached php5-memcached php5-memcache

#
# MongoDB
#
apt-get install -y mongodb-clients mongodb-server
pecl install mongo < /dev/null &
echo 'extension = mongo.so' | tee /etc/php5/mods-available/mongo.ini > /dev/null

#
# PostgreSQL with postgres:postgres
# but "psql -U postgres" command don't ask password
#
apt-get install -y postgresql-9.4 php5-pgsql
cp /etc/postgresql/9.4/main/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.bkup.conf
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres'" > /dev/null
sed -i.bak -E 's/local\s+all\s+postgres\s+peer/local\t\tall\t\tpostgres\t\ttrust/g' /etc/postgresql/9.4/main/pg_hba.conf
service postgresql restart

#
# SQLite
#
apt-get -y install sqlite3 php5-sqlite

#
# Beanstalkd
#
apt-get -y install beanstalkd

#
# YAML
#
apt-get install libyaml-dev
(CFLAGS="-O1 -g3 -fno-strict-aliasing"; pecl install yaml < /dev/null &)
echo 'extension = yaml.so' | tee /etc/php5/mods-available/yaml.ini > /dev/null
php5enmod yaml

#
# Utilities
#
apt-get install -y curl htop git dos2unix unzip vim grc gcc make re2c libpcre3 libpcre3-dev lsb-core autoconf

#
# Libsodium
#
apt-get install -y libsodium-dev
pecl install -a libsodium < /dev/null &
echo 'extension=libsodium.so' | tee /etc/php5/mods-available/libsodium.ini > /dev/null
php5enmod libsodium

#
# Zephir
#
#git clone --depth=1 git://github.com/phalcon/zephir.git
#(cd zephir && ./install -c)

#
# Install Phalcon Framework
#
#git clone --depth=1 git://github.com/phalcon/cphalcon.git
#(cd cphalcon && zephir build)
sudo apt-add-repository ppa:phalcon/stable
sudo apt-get update
sudo apt-get install php5-phalcon
echo -e "extension=phalcon.so" | tee /etc/php5/mods-available/phalcon.ini > /dev/null
php5enmod phalcon

#
# Redis
#
# Allow us to remote from Vagrant with port
#
apt-get install -y redis-server redis-tools php5-redis
cp /etc/redis/redis.conf /etc/redis/redis.bkup.conf
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
service redis-server restart

#
# MySQL configuration
# Allow us to remote from Vagrant with port
#
cp /etc/mysql/my.cnf /etc/mysql/my.bkup.cnf
# Note: Since the MySQL bind-address has a tab character I comment out the end line
sed -i 's/bind-address/bind-address = 0.0.0.0#/' /etc/mysql/my.cnf

#
# Grant all privilege to root for remote access
#
mysql -u root -Bse "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
service mysql restart

#
# Composer for PHP
#
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#
# Apache VHost
#
cd /var/www/
case "$1" in
    apache)
        #
        # Apache VHost
        #
        echo '<VirtualHost *:80>
            DocumentRoot /var/www/'$2'
            ServerName '$2'
            ServerAlias www.'$2'
            ErrorLog  /var/www/projects-error.log
            CustomLog /var/www/projects-access.log combined
        </VirtualHost>

        <Directory "/var/www/'$2'">
                Options Indexes Followsymlinks
                AllowOverride All
                Require all granted
        </Directory>' > vagrant.conf
        mv vagrant.conf /etc/apache2/sites-available
    ;;
    nginx)
        #
        # nginx server block
        #
        echo 'server {
            listen 80;

            server_name '$2';
            set $ipl /var/www/meters;
            set $fcgi_path 127.0.0.1:9000;

            root $ipl/public;
            rewrite ^/(.*)/$ /$1 permanent;

            # Enable Gzip
            gzip on;
            gzip_http_version 1.0;
            gzip_types application/x-javascript text/javascript text/css application/pdf;
            gzip_vary on;
            gzip_proxied any;
            gzip_disable "msie6";

            #common
            index index.php index.html index.htm;
            location / {
                try_files $uri $uri/ /index.php?_url=$uri&$args;
            }

            location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass $fcgi_path;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
            }
            location ~ /\.ht {
                deny all;
            }
            location /__data {
                 alias $ipl/data/public;
                location ~ \.php$ {
                    fastcgi_split_path_info ^/__data/(.*)(.*);
                    fastcgi_pass $fcgi_path;
                    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                    include fastcgi_params;
                }
            }

            location /__tests {
                alias $ipl/tests/report;
                index index.html index.htm;
            }

            location ~* ^/(css|img|js|flv|swf|download)/(.+)$ {
                root $ipl/public;
            }

            #deny .inc .FFV CVS
            location ~ \.inc$ {
                deny all;
            }
            location ~ /(CVS:\.FFV)/ {
                deny all;
            }
        }' > /etc/nginx/conf.d/vagrant.conf

    ;;
esac

# TODO:: See if this only applys to apache.
a2enmod rewrite

#
# Install Phalcon DevTools
#
cd ~
php5dismod xdebug
echo '{"require": {"phalcon/devtools": "dev-master"}}' > composer.json
composer install
rm composer.json
php5enmod xdebug

mkdir /opt/phalcon-tools
mv ~/vendor/phalcon/devtools/* /opt/phalcon-tools
rm -rf ~/vendor
echo "export PTOOLSPATH=/opt/phalcon-tools/" >> /home/vagrant/.profile
echo "export PATH=\$PATH:/opt/phalcon-tools/" >> /home/vagrant/.profile
chmod +x /opt/phalcon-tools/phalcon.sh
ln -s /opt/phalcon-tools/phalcon.sh /usr/bin/phalcon

#
# Update PHP Error Reporting
#
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php5/apache2/php.ini
sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php5/apache2/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini
#  Append session save location to /tmp to prevent errors in an odd situation..
sed -i '/\[Session\]/a session.save_path = "/tmp"' /etc/php5/apache2/php.ini

# TODO:: See if this only applys to apache.
a2ensite vagrant
a2dissite 000-default
case "$1" in
    apache)
        #
        # Reload apache
        #
        service apache2 restart
    ;;
    nginx)
        #
        # nginx
        #
        service nginx restart
    ;;
    *)
        echo "Invalid webserver supplied"
        exit 1
    ;;
esac

service mongodb restart

#
#  Cleanup
#
apt-get autoremove -y
apt-get autoclean -y

usermod -a -G www-data vagrant

echo -e "----------------------------------------"
echo -e "To create a Phalcon Project:\n"
echo -e "----------------------------------------"
echo -e "$ cd /vagrant/www"
echo -e "$ phalcon project <projectname>\n"
echo -e
echo -e "Then follow the README.md to copy/paste the VirtualHost!\n"

echo -e "----------------------------------------"
echo -e "Default Site: $2"
echo -e "----------------------------------------"
