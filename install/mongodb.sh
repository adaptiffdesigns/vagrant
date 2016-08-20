pecl install mongo < /dev/null &
echo 'extension=mongo.so' | tee /etc/php.d/mongo.ini > /dev/null