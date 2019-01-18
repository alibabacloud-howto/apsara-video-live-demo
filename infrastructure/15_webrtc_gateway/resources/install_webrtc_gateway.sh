#!/usr/bin/env bash
#
# WebRTC gateway installation script.
#
# Arguments:
# $1 = STUN / TURN server domain
# $2 = public ip address of this machine
# $3 = TURN server username
# $4 = TURN server password
# $5 = Domain name of this server
# $6 = Email address for Let's Encrypt to notify us when a certificate is going to be expired.
#
# The following resources are expected in the /tmp folder:
# /tmp/coturn.service
#

STUN_TURN_DOMAIN=$1
PUBLIC_IP_ADDR=$2
TURN_USERNAME=$3
TURN_PASSWORD=$4
DOMAIN=$5
EMAIL_ADDRESS=$6

echo "STUN_TURN_DOMAIN=$STUN_TURN_DOMAIN"
echo "PUBLIC_IP_ADDR=$PUBLIC_IP_ADDR"
echo "TURN_USERNAME=$TURN_USERNAME"
echo "TURN_PASSWORD=$TURN_PASSWORD"
echo "DOMAIN=$DOMAIN"
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
apt-get -y install certbot

# Obtain the certificate
echo "Obtaining certificate"
certbot certonly --standalone -d "${DOMAIN}" --non-interactive --agree-tos --email "${EMAIL_ADDRESS}"

# Install dependencies
echo "Install dependencies"
apt-get -y install libmicrohttpd-dev libjansson-dev libnice-dev \
    libssl-dev libsrtp-dev libsofia-sip-ua-dev libglib2.0-dev \
    libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
    pkg-config gengetopt libtool automake libcurl4-openssl-dev unzip

cd /tmp
wget https://github.com/cisco/libsrtp/archive/v2.2.0.zip
unzip v2.2.0.zip
cd libsrtp-2.2.0
./configure
make
make install
cd ..

# Install Janus
echo "Install Janus"
wget https://github.com/meetecho/janus-gateway/archive/v0.4.2.zip
unzip v0.4.2.zip
cd janus-gateway-0.4.2

sh autogen.sh
./configure --disable-websockets --disable-data-channels --disable-rabbitmq --disable-mqtt --disable-plugin-audiobridge
make
make install
make configs

# Configure Janus
echo "Configure Janus"
echo "[nat]" >> /usr/local/etc/janus/janus.cfg
echo "stun_server = ${STUN_TURN_DOMAIN}" >> /usr/local/etc/janus/janus.cfg
echo "stun_port = 3478" >> /usr/local/etc/janus/janus.cfg
echo "nat_1_1_mapping = ${PUBLIC_IP_ADDR}" >> /usr/local/etc/janus/janus.cfg
echo "turn_server = ${STUN_TURN_DOMAIN}" >> /usr/local/etc/janus/janus.cfg
echo "turn_port = 3478" >> /usr/local/etc/janus/janus.cfg
echo "turn_type = udp" >> /usr/local/etc/janus/janus.cfg
echo "turn_user = ${TURN_USERNAME}" >> /usr/local/etc/janus/janus.cfg
echo "turn_pwd = ${TURN_PASSWORD}" >> /usr/local/etc/janus/janus.cfg

PRIVATE_KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
PUBLIC_KEY_PATH="/etc/letsencrypt/live/${DOMAIN}/cert.pem"
export ESCAPED_PRIVATE_KEY_PATH=$(echo ${PRIVATE_KEY_PATH} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_PUBLIC_KEY_PATH=$(echo ${PUBLIC_KEY_PATH} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
sed -i "s/https = no/https = yes/" /usr/local/etc/janus/janus.transport.http.cfg
sed -i "s/\(cert_pem = \).*\$/\1${ESCAPED_PUBLIC_KEY_PATH}/" /usr/local/etc/janus/janus.transport.http.cfg
sed -i "s/\(cert_key = \).*\$/\1${ESCAPED_PRIVATE_KEY_PATH}/" /usr/local/etc/janus/janus.transport.http.cfg

cp /tmp/janus.service /etc/systemd/system/

# Start and enable Janus
echo "Start Janus"
systemctl start janus.service
systemctl enable janus.service
