#/bin/bash
# Run any custom config. Host first.
for script in `ls -1 $PWD/postinstall/host-*.sh 2>/dev/null`; do
    bash $script;
done

# Next guest.
NAME=$1
URL=$2
SSH=$3


for script in $(ls -1 $PWD/postinstall/guest-${NAME}-*.sh 2>/dev/null); do
    scriptName=`basename $script`
    $SSH -A -t root@$URL 'bash /vagrant/postinstall/'$scriptName
done
