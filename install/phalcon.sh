#
# Install Phalcon Framework
#
git clone --depth=1 git://github.com/phalcon/cphalcon.git
cd cphalcon/build
sudo ./install
echo "extension=phalcon.so" > /etc/php.d/phalcon.ini > /dev/null