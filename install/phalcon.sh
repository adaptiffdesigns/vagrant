#
# Install Phalcon Framework
#
if [[ ! -e /var/www/cphalcon ]]; then
    cd /var/www
    git clone --depth=1 git://github.com/phalcon/cphalcon.git
    cd /var/www/cphalcon/build
    sudo ./install
    echo "extension=phalcon.so" > /etc/php.d/phalcon.ini > /dev/null
fi