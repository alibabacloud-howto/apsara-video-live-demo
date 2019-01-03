# Apsara Video Live Demo

## Summary
0. [Introduction](#introduction)
1. [Prerequisite](#prerequisite)
1. [Architecture](#architecture)
2. [Apsara Video Live configuration](#apsara-video-live-configuration)
3. [Installation](#installation)

## Introduction
The goal of this demo is to showcase [Apsara Video Live](https://www.alibabacloud.com/product/apsaravideo-for-live),
an Alibaba Cloud service that allows users to broadcast video on internet.

This demo is composed of 3 pages:
* A home page that displays all the available streams.
* A broadcast page that allows a user to broadcast his webcam video on internet.
* A watch page that displays a selected video stream.

This demo doesn't require users to install any plugin: it uses WebRTC technology included in all modern web browsers.

## Prerequisite
Please [create an Alibaba Cloud account](https://www.alibabacloud.com/help/doc-detail/50482.htm) and
[obtain an access key id and secret](https://www.alibabacloud.com/help/faq-detail/63482.htm).

## Architecture
In order to design the architecture of this project, it is important to take on consideration two main constraints:
* The demo should not require users to install any plugin or tool on their computer. The web browser must be sufficient.
* Apsara Video Live expects [RTMP](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol) for
  input streams, which is incompatible with standard web browser technologies such as HTML5.

Fortunately web browsers natively support a technology that allows users to send their webcam video on internet: 
[WebRTC](https://webrtc.org/). Thus, the chosen solution is to use WebRTC to lets users to broadcast their stream
to our server, then convert this data to RTMP in order to forward it to Apsara Video Live.

However establishing a WebRTC communication with a web browser and converting the video stream to RTMP is quite complex:
* A WebRTC gateway is necessary for the first part of the solution. For that we will choose
  [Janus](https://janus.conf.meetecho.com/), an open source server-side application that cans establish a WebRTC
  communication with web browsers and forward the video streams to another application via
  [RTP](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Intro_to_RTP).
* In order to convert a RTP stream (from Janus) to RTMP, we will use [FFmpeg](https://www.ffmpeg.org/), a video
  conversion and streaming tool.
* In addition to Janus, we will need [Coturn](https://github.com/coturn/coturn), a
  [STUN / TURN server](https://www.html5rocks.com/en/tutorials/webrtc/infrastructure/#after-signaling-using-ice-to-cope-with-nats-and-firewalls)
  that allows users behind a firewall to use WebRTC.

The following diagram illustrates the architecture for this solution:

![Demo architecture](images/diagrams/avld-architecture.png)

The blue arrows represent HTTP traffic. The orange arrows represent the audio + video data stream.

The complete flow to broadcast video stream from one user to others is the following:
0. A user, Alice, wants to broadcast video from her webcam and audio from her microphone. With a web browser,
   she navigates to the `BroadcastPage` and enters a name for her stream.
1. When she clicks on a start button, her web browser opens a HTTP connection to Janus, creates a "room" via
   the `videoroom plugin`, then starts sending audio + video stream to this room by using the RTP protocol. Note that
   Coturn is used to forward the RTP data stream from Alice to Janus in order to bypass Alice's firewall (Janus is
   unable to function properly without Coturn, even if it has a public IP address).
2. Once Alice's web browser is successfully transmitting audio + video data to Janus, this stream needs to be
   forwarded to the `Transcoding server`. Thus, her web browser contacts this `Transcoding server` (relayed via the
   web app server) in order to know which ports are available for this stream.
3. The `Transcoding server` chooses available ports for the RTP stream (4 ports in total, 2 for audio and 2 for video
   data) and sends back a response containing the ports and the IP address where to forward the stream (the IP address
   is useful in case you want to scale transcoding into multiple servers behind a
   [load balancer](https://www.alibabacloud.com/product/server-load-balancer)).
4. When Alice's web browser receives the response containing the ports and IP address of the `Transcoding server`,
   it sends a requests to Janus to let it forward the RTP stream to this destination.
5. Once Janus is successfully sending the RTP stream to the `Transcoding server`, Alice's web browser sends a
   request to `Transcoding server` (relayed via the web app server) in order to start transcoding the audio + video
   stream to Apsara Video Live via the RTMP protocol.
6. Another user, Bob, wants to watch Alice's stream. With his web browser he navigates to the `HomePage` where
   he can have a list of all streams currently sent to Apsara Video Live (the web app server obtains this
   list of streams by contacting Apsara Video Live via the
   [Apsara Video Live SDK](https://github.com/aliyun/aliyun-openapi-java-sdk/tree/master/aliyun-java-sdk-live)).
   Bob then clicks on Alice's stream and navigates to the `WatchPage`.
7. Bob's web browser establishes a connection with Apsara Video Live via HTTP in order to receive audio and video
   stream in the [FLV format](https://en.wikipedia.org/wiki/Flash_Video) (the web application uses
   [Flv.js](https://github.com/Bilibili/flv.js/) to decode the stream in Javascript).

As you can see this solution is quite complex, and to that we need to add TLS certificate management for HTTPS,
[Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) configuration and
scaling.

Finally, now that the most critical part of the solution is decided, we choose the following technologies to build the
web application:
* [Spring Boot](https://spring.io/projects/spring-boot) for the backend.
* [React](https://reactjs.org/) and [Bootstrap](https://getbootstrap.com/) for the frontend.

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

TODO explain how to test with OBS

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

TODO: create a section about scaling and support (provide a contact email address).