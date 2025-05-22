#!/bin/bash

read -p "Hostname (no .rnao.ca): " host
read -p "IP Address: " ipaddress

# Fix /etc/hosts, /etc/hostname, /etc/mailname, and /etc/network/interfaces,
perl -pi -e "s/192.168.100.9/$ipaddress/e" /etc/hosts
perl -pi -e "s/dev/$host/e" /etc/hosts
perl -pi -e "s/dev.rnao.ca/${host}.rnao.ca/" /etc/mailname
perl -pi -e "s/192.168.100.9/$ipaddress/e" /etc/network/interfaces
perl -pi -e "s/8.8.8.8/192.168.100.9 192.168.1.11 8.8.8.8/" /etc/network/interfaces

# then:
sudo ifdown eth0
sudo ifup eth0
sudo apt-get update && sudo apt-get dist-upgrade -y

wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sudo dpkg -i puppetlabs-release-precise.deb 
sudo apt-get update
sudo apt-get install puppet
sudo perl -pi -e 's/START=no/START=yes/' /etc/default/puppet
sudo echo <<EOF >>/etc/puppet/puppet.conf
[agent]
server=puppet.rnao.ca
report=true
pluginsync=true
certname=$host.rnao.ca
EOF
