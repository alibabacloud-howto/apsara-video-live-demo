#!/usr/bin/env bash
#
# WebRTC gateway installation script.
#
# Arguments:
# $1 = STUN / TURN server domain
# $2 = public ip address of this machine
# $3 = TURN server username
# $4 = TURN server password
#
# The following resources are expected in the /tmp folder:
# /tmp/coturn.service
#

STUN_TURN_DOMAIN=$1
PUBLIC_IP_ADDR=$2
TURN_USERNAME=$3
TURN_PASSWORD=$4

# Update the distribution
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

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
cp /tmp/janus.service /etc/systemd/system/

# Start and enable Janus
echo "Start Janus"
systemctl start janus.service
systemctl enable janus.service
