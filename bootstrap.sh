#!/bin/bash
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list
apt-get update
apt-get install -y git imagemagick mongodb-10gen curl build-essential python2.7
groupadd edegal
useradd -m -c 'Edegal Image Gallery' -d /srv/edegal -g edegal edegal
sudo -iu edegal git clone https://github.com/creationix/nvm /srv/edegal/nvm
sudo -iu edegal /bin/bash -c "source /srv/edegal/nvm/nvm.sh && nvm install v0.10.21 && nvm alias default v0.10.21"
sudo -iu edegal /bin/bash -c "source /srv/edegal/nvm/nvm.sh && nvm use default && cd /vagrant && npm install --no-bin-links"
