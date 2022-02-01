#!/bin/bash

date > provision.txt
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y install linux-generic linux-headers-generic linux-image-generic
sudo apt-get -y install qemu-guest-agent
sudo apt-get -y install curl
./pihole-install.sh
exit 0