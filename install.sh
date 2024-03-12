#!/bin/bash

arch=`uname  -m`
osarch=`dpkg --print-architecture`

version=`lsb_release -r -s`
codename=`lsb_release -c -s`

curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/salt/py3/ubuntu/$version/$osarch/SALT-PROJECT-GPG-PUBKEY-2023.gpg
echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring.gpg arch=$osarch] https://repo.saltproject.io/salt/py3/ubuntu/$version/$osarch/latest $codename main" | sudo tee /etc/apt/sources.list.d/salt.list
apt-get -y update
apt-get -y install salt-minion git

echo "Enter Git username"
read username
echo "Enter Git HTTPS key"
read key

#can also git clone, either way we have to configure some authentication first
git clone https://$username:$key@github.com/NOC-OI/imfe-pilot-salt_config.git
ln -s $(pwd)/salt_config/salt /srv/
ln -s $(pwd)/salt_config/pillar /srv/
sed -i 's/^#file_client: remote$/file_client: local/' /etc/salt/minion
service salt-minion start
