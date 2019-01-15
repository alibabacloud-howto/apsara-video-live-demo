#!/usr/bin/env bash
#
# TURN / STUN server installation script.
#
# Arguments:
# $1 = domain of this server
# $2 = public ip address of this machine
#
# The following resources are expected in the /tmp folder:
# /tmp/coturn.service
#

DOMAIN=$1
PUBLIC_IP_ADDR=$2
PRIVATE_IP_ADDR=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

# Update the distribution
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# Install Coturn
echo "Install Coturn"
apt-get -y install coturn

# Configure Coturn
echo "Configure Coturn"
echo "TURNSERVER_ENABLED=1" >> /etc/default/coturn
echo "fingerprint" >> /etc/turnserver.conf
echo "user=livevideo:LivevideoPassword2018" >> /etc/turnserver.conf
echo "external-ip=${PUBLIC_IP_ADDR}/${PRIVATE_IP_ADDR}" >> /etc/turnserver.conf
echo "server-name=${DOMAIN}" >> /etc/turnserver.conf
echo "realm=${DOMAIN}" >> /etc/turnserver.conf
cp /tmp/coturn.service /etc/systemd/system/

# Start and enable Coturn
echo "Start the transcoder app and Nginx"
systemctl start coturn.service
systemctl enable coturn.service
