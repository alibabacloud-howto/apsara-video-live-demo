#!/usr/bin/env bash
#
# Web application installation script.
#
# Arguments:
# $1  = Domain name of the TURN / STUN server
# $2  = Username of the TURN / STUN server
# $3  = Password of the TURN / STUN server
# $4  = Domain name of the WebRTC gateway
# $5  = Domain name of the Transcoder
# $6  = Access key ID of the (RAM) user that can access to Apsara Video Live.
# $7  = Access key secret of the (RAM) user that can access to Apsara Video Live.
# $8  = Region ID where the Apsara Video Live service is running.
# $9  = Push domain name for the Apsara Video Live service.
# $10 = Pull domain name for the Apsara Video Live service.
# $11 = Application name for the Apsara Video Live service (allow several applications to share one domain).
# $12 = Primary key for the authentication for the push domain.
# $13 = Validity period in seconds of an authentication key for the push domain.
# $14 = Primary key for the authentication for the pull domain.
# $15 = Validity period in seconds of an authentication key for the pull domain.
#
# The following resources are expected in the /tmp folder:
# /tmp/nginx-webapp.conf
# /tmp/application.properties
# /tmp/webapp.jar
# /tmp/webapp.service

STUN_TURN_DOMAIN=$1
TURN_USERNAME=$2
TURN_PASSWORD=$3
WEBRTC_GATEWAY_DOMAIN=$4
TRANSCODER_DOMAIN=$5
AVL_USER_ACCESSKEY_ID=$6
AVL_USER_ACCESSKEY_SECRET=$7
AVL_REGION_ID=$8
AVL_PUSH_DOMAIN=$9
AVL_PULL_DOMAIN=${10}
AVL_APP_NAME=${11}
AVL_PUSH_AUTH_PRIMARY_KEY=${12}
AVL_PUSH_AUTH_VALIDITY_PERIOD=${13}
AVL_PULL_AUTH_PRIMARY_KEY=${14}
AVL_PULL_AUTH_VALIDITY_PERIOD=${15}

echo "STUN_TURN_DOMAIN=$STUN_TURN_DOMAIN"
echo "TURN_USERNAME=$TURN_USERNAME"
echo "TURN_PASSWORD=$TURN_PASSWORD"
echo "WEBRTC_GATEWAY_DOMAIN=$WEBRTC_GATEWAY_DOMAIN"
echo "TRANSCODER_DOMAIN=$TRANSCODER_DOMAIN"
echo "AVL_USER_ACCESSKEY_ID=$AVL_USER_ACCESSKEY_ID"
echo "AVL_USER_ACCESSKEY_SECRET=$AVL_USER_ACCESSKEY_SECRET"
echo "AVL_REGION_ID=$AVL_REGION_ID"
echo "AVL_PUSH_DOMAIN=$AVL_PUSH_DOMAIN"
echo "AVL_PULL_DOMAIN=$AVL_PULL_DOMAIN"
echo "AVL_APP_NAME=$AVL_APP_NAME"
echo "AVL_PUSH_AUTH_PRIMARY_KEY=$AVL_PUSH_AUTH_PRIMARY_KEY"
echo "AVL_PUSH_AUTH_VALIDITY_PERIOD=$AVL_PUSH_AUTH_VALIDITY_PERIOD"
echo "AVL_PULL_AUTH_PRIMARY_KEY=$AVL_PULL_AUTH_PRIMARY_KEY"
echo "AVL_PULL_AUTH_VALIDITY_PERIOD=$AVL_PULL_AUTH_VALIDITY_PERIOD"

# Update the distribution
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# Install JDK 11
echo "Install OpenJDK 11"
apt-get -y install default-jdk
wget https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz -O /tmp/openjdk-11.tar.gz
tar xfvz /tmp/openjdk-11.tar.gz --directory /usr/lib/jvm
for bin in /usr/lib/jvm/jdk-11.0.1/bin/*; do update-alternatives --install /usr/bin/$(basename ${bin}) $(basename ${bin}) ${bin} 100; done
for bin in /usr/lib/jvm/jdk-11.0.1/bin/*; do update-alternatives --set $(basename ${bin}) ${bin}; done

# Install Nginx
echo "Install Nginx"
apt-get -y install nginx

# Configure Nginx
echo "Configure Nginx"
cp /tmp/nginx-webapp.conf /etc/nginx/conf.d/webapp.conf
rm /etc/nginx/sites-enabled/default

# Configure the application
echo "Configure the webapp app"
export ESCAPED_STUN_TURN_DOMAIN=$(echo ${STUN_TURN_DOMAIN} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_TURN_USERNAME=$(echo ${TURN_USERNAME} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_TURN_PASSWORD=$(echo ${TURN_PASSWORD} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_WEBRTC_GATEWAY_DOMAIN=$(echo ${WEBRTC_GATEWAY_DOMAIN} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_TRANSCODER_DOMAIN=$(echo ${TRANSCODER_DOMAIN} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_USER_ACCESSKEY_ID=$(echo ${AVL_USER_ACCESSKEY_ID} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_USER_ACCESSKEY_SECRET=$(echo ${AVL_USER_ACCESSKEY_SECRET} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_REGION_ID=$(echo ${AVL_REGION_ID} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PUSH_DOMAIN=$(echo ${AVL_PUSH_DOMAIN} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PULL_DOMAIN=$(echo ${AVL_PULL_DOMAIN} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_APP_NAME=$(echo ${AVL_APP_NAME} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PUSH_AUTH_PRIMARY_KEY=$(echo ${AVL_PUSH_AUTH_PRIMARY_KEY} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PUSH_AUTH_VALIDITY_PERIOD=$(echo ${AVL_PUSH_AUTH_VALIDITY_PERIOD} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PULL_AUTH_PRIMARY_KEY=$(echo ${AVL_PULL_AUTH_PRIMARY_KEY} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
export ESCAPED_AVL_PULL_AUTH_VALIDITY_PERIOD=$(echo ${AVL_PULL_AUTH_VALIDITY_PERIOD} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
sed -i "s/\(janus\.hostname=\).*\$/\1${ESCAPED_WEBRTC_GATEWAY_DOMAIN}/" /tmp/application.properties
sed -i "s/\(turnServer\.url=\).*\$/\1turn:${ESCAPED_STUN_TURN_DOMAIN}:3478/" /tmp/application.properties
sed -i "s/\(turnServer\.username=\).*\$/\1${ESCAPED_TURN_USERNAME}/" /tmp/application.properties
sed -i "s/\(turnServer\.password=\).*\$/\1${ESCAPED_TURN_PASSWORD}/" /tmp/application.properties
sed -i "s/\(transcoder\.hostname=\).*\$/\1${ESCAPED_TRANSCODER_DOMAIN}/" /tmp/application.properties
sed -i "s/\(transcoder\.httpPort=\).*\$/\180/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.accessKeyId=\).*\$/\1${ESCAPED_AVL_USER_ACCESSKEY_ID}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.accessKeySecret=\).*\$/\1${ESCAPED_AVL_USER_ACCESSKEY_SECRET}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.regionId=\).*\$/\1${ESCAPED_AVL_REGION_ID}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.pullDomainName=\).*\$/\1${ESCAPED_AVL_PULL_DOMAIN}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.pushDomainName=\).*\$/\1${ESCAPED_AVL_PUSH_DOMAIN}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.appName=\).*\$/\1${ESCAPED_AVL_APP_NAME}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.pushAuthPrimaryKey=\).*\$/\1${ESCAPED_AVL_PUSH_AUTH_PRIMARY_KEY}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.pushAuthValidityPeriod=\).*\$/\1${ESCAPED_AVL_PUSH_AUTH_VALIDITY_PERIOD}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.pullAuthPrimaryKey=\).*\$/\1${ESCAPED_AVL_PULL_AUTH_PRIMARY_KEY}/" /tmp/application.properties
sed -i "s/\(apsaraVideoLive\.pullAuthValidityPeriod=\).*\$/\1${ESCAPED_AVL_PULL_AUTH_VALIDITY_PERIOD}/" /tmp/application.properties

mkdir -p /etc/webapp
mkdir -p /opt/webapp
cp /tmp/application.properties /etc/webapp/
cp /tmp/webapp.jar /opt/webapp/
cp /tmp/webapp.service /etc/systemd/system/

# Start and enable the application and Nginx
echo "Start the webapp app and Nginx"
systemctl start webapp.service
systemctl enable webapp.service
systemctl restart nginx
systemctl enable nginx