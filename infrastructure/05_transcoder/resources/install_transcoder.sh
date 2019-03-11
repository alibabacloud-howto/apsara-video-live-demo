#!/usr/bin/env bash
#
# Transcoder installation script.
#
# The following resources are expected in the /tmp folder:
# /tmp/nginx-transcoder.conf
# /tmp/application.properties
# /tmp/transcoder.jar
# /tmp/transcoder.service

# Update the distribution
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# Install JDK 11
echo "Install OpenJDK 11"
apt-get -y install software-properties-common
add-apt-repository -y ppa:openjdk-r/ppa
apt-get update
apt-get -y install openjdk-11-jre-headless

# Install FFMPEG
echo "Install Ffmpeg"
add-apt-repository -y ppa:jonathonf/ffmpeg-4
apt-get update
apt-get -y install ffmpeg

# Install Nginx
echo "Install Nginx"
apt-get -y install nginx

# Configure Nginx
echo "Configure Nginx"
cp /tmp/nginx-transcoder.conf /etc/nginx/conf.d/transcoder.conf
rm /etc/nginx/sites-enabled/default

# Configure the application
echo "Configure the transcoder app"
FFMPEG_PATH=/usr/bin/ffmpeg
export ESCAPED_FFMPEG_PATH=$(echo ${FFMPEG_PATH} | sed -e 's/\\/\\\\/g; s/\//\\\//g; s/&/\\\&/g')
sed -i "s/\(transcoding\.ffmpegExecutablePath=\).*\$/\1${ESCAPED_FFMPEG_PATH}/" /tmp/application.properties
mkdir -p /etc/transcoder
mkdir -p /opt/transcoder
cp /tmp/application.properties /etc/transcoder/
cp /tmp/transcoder.jar /opt/transcoder/
cp /tmp/transcoder.service /etc/systemd/system/

# Start and enable the application and Nginx
echo "Start the transcoder app and Nginx"
systemctl start transcoder.service
systemctl enable transcoder.service
systemctl restart nginx
systemctl enable nginx