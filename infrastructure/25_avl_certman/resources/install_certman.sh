#!/usr/bin/env bash
#
# Apsara Video Live Pull-domain certificate manager installation script.
#
# Arguments:
# $1 = Public IP address of this server.
# $2 = Access key ID of a user that can call CDN and DNS OpenAPIs.
# $3 = Access key secret of a user that can call CDN and DNS OpenAPIs.
# $4 = Region ID of this server.
# $5 = Pull domain name of the Apsara Video Live service (e.g my-sample-domain.xyz).
# $6 = Pull sub-domain name of the Apsara Video Live service (e.g livevideo-pull).
# $7 = Email address for Let's Encrypt to notify us when a certificate is going to be expired.
#
# The following resources are expected in the /tmp folder:
# /tmp/certificate-updater.py
# /tmp/certificate-updater-config.ini
# /tmp/certificate-updater.service
# /tmp/certificate-updater-cron
#

PUBLIC_IP_ADDR=$1
ACCESSKEY_ID=$2
ACCESSKEY_SECRET=$3
REGION_ID=$4
AVL_PULL_TOP_DOMAIN=$5
AVL_PULL_SUB_DOMAIN=$6
EMAIL_ADDRESS=$7

echo "PUBLIC_IP_ADDR=$PUBLIC_IP_ADDR"
echo "ACCESSKEY_ID=$ACCESSKEY_ID"
echo "ACCESSKEY_SECRET=$ACCESSKEY_SECRET"
echo "REGION_ID=$REGION_ID"
echo "AVL_PULL_TOP_DOMAIN=$AVL_PULL_TOP_DOMAIN"
echo "AVL_PULL_SUB_DOMAIN=$AVL_PULL_SUB_DOMAIN"
echo "EMAIL_ADDRESS=$EMAIL_ADDRESS"

# Update the distribution
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# Install Certbot for obtaining a Let's Encrypt certificate
echo "Install Certbot"
apt-get -y install software-properties-common
add-apt-repository -y ppa:certbot/certbot
apt-get -y update
apt-get -y install python-certbot certbot

# Install the Python SDK
echo "Install Python SDK"
apt-get -y install python3-pip
pip3 install aliyun-python-sdk-core

# Configure the certificate updater
echo "Configure the certificate updater"
mkdir -p /etc/certificate-updater/
mkdir -p /opt/certificate-updater/
export ESCAPED_ACCESSKEY_ID=$(echo ${ACCESSKEY_ID} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_ACCESSKEY_SECRET=$(echo ${ACCESSKEY_SECRET} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_REGION_ID=$(echo ${REGION_ID} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_PUBLIC_IP_ADDR=$(echo ${PUBLIC_IP_ADDR} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PULL_TOP_DOMAIN=$(echo ${AVL_PULL_TOP_DOMAIN} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PULL_SUB_DOMAIN=$(echo ${AVL_PULL_SUB_DOMAIN} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_EMAIL_ADDRESS=$(echo ${EMAIL_ADDRESS} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
sed -i "s/%access-key-id%/${ESCAPED_ACCESSKEY_ID}/" /tmp/certificate-updater-config.ini
sed -i "s/%access-key-secret%/${ESCAPED_ACCESSKEY_SECRET}/" /tmp/certificate-updater-config.ini
sed -i "s/%region-id%/${ESCAPED_REGION_ID}/" /tmp/certificate-updater-config.ini
sed -i "s/%public-ip-address%/${ESCAPED_PUBLIC_IP_ADDR}/" /tmp/certificate-updater-config.ini
sed -i "s/%pull-top-domain%/${ESCAPED_AVL_PULL_TOP_DOMAIN}/" /tmp/certificate-updater-config.ini
sed -i "s/%pull-sub-domain%/${ESCAPED_AVL_PULL_SUB_DOMAIN}/" /tmp/certificate-updater-config.ini
sed -i "s/%email-address%/${ESCAPED_EMAIL_ADDRESS}/" /tmp/certificate-updater-config.ini
cp /tmp/certificate-updater-config.ini /etc/certificate-updater/config.ini
cp /tmp/certificate-updater.py /opt/certificate-updater/certificate-updater.py

# Configure and run SystemD and cron scripts
echo "Configure and run SystemD and cron scripts"
cp /tmp/certificate-updater-cron /etc/cron.d/certificate-updater
cp /tmp/certificate-updater.service /etc/systemd/system/certificate-updater.service
systemctl enable certificate-updater.service
systemctl start certificate-updater.service