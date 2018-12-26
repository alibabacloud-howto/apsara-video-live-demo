# Apsara Video Live Demo

## Summary
0. [Introduction](#introduction)
1. [Architecture](#architecture)
2. [Installation](#installation)

## Introduction
The goal of this demo is to showcase [Apsara Video Live](https://www.alibabacloud.com/product/apsaravideo-for-live),
an Alibaba Cloud service that allows users to broadcast video on internet.

This demo is composed of 3 pages:
* A home page that displays all the available streams.
* A broadcast page that allows a user to broadcast his webcam video on internet.
* A watch page that displays a selected video stream.

This demo doesn't require users to install any plugin: it uses WebRTC technology included in all modern web browsers.

TODO prerequisite
Register a domain.
Get access key


## Architecture
This demos is composed of the following systems:
* A website: backend in [Spring Boot](https://spring.io/projects/spring-boot), frontend
  in [React](https://reactjs.org/).
* [Apsara Video Live](https://www.alibabacloud.com/product/apsaravideo-for-live): a service that accepts video streams
  via the RTMP protocol and distribute them on internet via various protocols (RTMP, HLS and FLV).
* [Janus](https://janus.conf.meetecho.com/), an open-source WebRTC gateway: in this demo we use it to forward video
  data coming from WebRTC to FFmpeg via RTP.
* [Coturn](https://github.com/coturn/coturn), a STUN/TURN server that allows users behind a NAT to use WebRTC.
* [FFmpeg](https://www.ffmpeg.org/), a video conversion and streaming tool: in this demo we use it to forward RTP
  stream from Janus to Apsara Video Live via RTMP. It also convert VP8/Opus data into H264/mp3.

TODO show a schema about the "simplified" architecture.

TODO: mention about scalable architecture and give contact email.

### Apsara Video Live configuration
In order to use Apsara Video Live, you need to register two domains, one for sending data (push), one for
receiving (pull):
* Go to the [ApsaraVideo Live console](https://live.console.aliyun.com/);
* Click on the "Domain Names" left menu item;
* Click on the "Add new domain" button;
* Fill the form with the following parameters:
  * Domain Name = choose a sub-domain name such as "livevideo-push.my-sample-domain.xyz" with "push" in it
  * Live Center = the closest region the the users who will broadcast their video
  * Domain Type = Ingest Domain Name
  * CDN Accelerated Area = Outside Mainland China
* Click on the "Next" button;
* The new page should confirm that your domain name is created; click on "Back to Domain Name List".

Your domain should appear in the table:

![Domain added](images/avl-domain-name-added.png)

Redo the same operation to create a streaming domain name:
* Click on the "Add new domain" button;
* Fill the form with the following parameters:
  * Domain Name = choose a sub-domain name such as "livevideo-pull.my-sample-domain.xyz" with "pull" in it
  * Live Center = the closest region the the users who will broadcast their video
  * Domain Type = Streaming Domain Name
  * CDN Accelerated Area = Outside Mainland China
* Click on the "Next" button;
* The new page should confirm that your domain name is created; click on "Back to Domain Name List".

You should now see your two domains:

![Push and pull domains added](images/avl-push-push-domain-names-not-ready.png)

Let's configure the "push" domain:
* Copy the the CNAME corresponding to your "push" domain (e.g. livevideo-push.my-sample-domain.xyz.w.alikunlun.com);
* Go to the [Domain console](https://dc.console.aliyun.com);
* Next to your domain name (e.g. my-sample-domain.xyz), click on the "Resolve" link;
* Click on "Add Record";
* Fill the form with the following information:
  * Type: CNAME- Canonical name
  * Host: your "push" sub-domain (e.g. livevideo-push)
  * ISP Line: Outside Mainland China
  * Value: the CNAME you have just copied (e.g. livevideo-push.my-sample-domain.xyz.w.alikunlun.com)
  * TTL: 10 minute(s)
  * Synchronize the Default Line: checked
* Click on "OK";

Your DNS entries should look like this:

![DNS entries for push sub-domain](images/dns-entry-push-entry.png)

We can now configure the "pull" domain. Go back to your domain names list in the
[ApsaraVideo Live console](https://live.console.aliyun.com/). You should now have a CNAME entry next to your "pull"
domain:

![Pull domain enabled](images/avl-pull-domain-enabled.png)

Copy this CNAME value (e.g. livevideo-pull.my-sample-domain.xyz.w.kunlunsl.com) and go back to the
[Domain console](https://dc.console.aliyun.com):
* Next to your domain name (e.g. my-sample-domain.xyz), click on the "Resolve" link;
* Click on "Add Record";
* Fill the form with the following information:
  * Type: CNAME- Canonical name
  * Host: your "pull" sub-domain (e.g. livevideo-pull)
  * ISP Line: Outside Mainland China
  * Value: the CNAME you have just copied (e.g. livevideo-pull.my-sample-domain.xyz.w.kunlunsl.com)
  * TTL: 10 minute(s)
  * Synchronize the Default Line: checked
* Click on "OK";

Your DNS entries should be similar to this:

![Push and pull DNS entries](images/dns-entry-push-and-pull-entries.png)

We now need to link the "push" and "pull" domains together:
* Go back to your domain names list in the [ApsaraVideo Live console](https://live.console.aliyun.com/);
* Next to your "pull" domain, click on the "Configure" link;
* In the new page, click on the button with the "pen" icon for "Stream Pushing Information > 
  Ingest Domain Name";
* In the popup, select your "push" domain (e.g. livevideo-push.my-sample-domain.xyz) and click on "OK".

## Installation
TODO Terraform script

```bash
export ALICLOUD_ACCESS_KEY="your-accesskey-id"
export ALICLOUD_SECRET_KEY="your-accesskey-secret"
export ALICLOUD_REGION="your-region-id"

export TF_VAR_domain_name="your-domain.com"
export TF_VAR_webapp_sub_domain_name="www"
export TF_VAR_transcoding_sub_domain_name="transcoding"
export TF_VAR_ecs_root_password="your-root-password"

cd infrastructure
terraform init
terraform apply
```