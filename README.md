# Apsara Video Live Demo

## Summary
0. [Introduction](#introduction)
1. [Prerequisite](#prerequisite)
2. [Architecture](#architecture)
3. [Apsara Video Live configuration](#apsara-video-live-configuration)
4. [Apsara Video Live test](#apsara-video-live-test)
5. [Installation](#installation)

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
   request to the `Transcoding server` (relayed via the web app server) in order to start transcoding the audio + video
   stream to Apsara Video Live via the RTMP protocol.
6. Another user, Bob, wants to watch Alice's stream. With his web browser he navigates to the `HomePage` where
   he can have a list of all streams currently sent to Apsara Video Live (the web app server obtains this
   list of streams by contacting Apsara Video Live via the
   [Apsara Video Live SDK](https://github.com/aliyun/aliyun-openapi-java-sdk/tree/master/aliyun-java-sdk-live)).
   Bob then selects Alice's stream and navigates to the `WatchPage`.
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
Before building the application, we need to register two domains in Apsara Video Live, one for sending data
(push domain), one for receiving (pull domain):
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
  * Live Center = the closest region the the users who will watch the videos
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

## Apsara Video Live test
We can test this configuration by using [Open Broadcaster Software (OBS)](https://obsproject.com/download), a free
and open source software for video recording and live streaming. Download and install this application to your
computer.

Before configuring OBS we need to get an URL where to send the video stream:
* Go to the [ApsaraVideo Live console](https://live.console.aliyun.com/);
* Click on the "Domains" left menu item;
* Click on your push domain name (e.g. "livevideo-push.my-sample-domain.xyz");
* Click on the "Access Control" left menu item.

You should get a page similar to this screenshot:

![Push domain access control](images/avl-push-domain-access-control.png)

This page is in fact composed of two independent sections:
* "Signed URL Settings" that displays all information to authenticate the stream sender;
* "Generate Signed URL" that allow you to generate an RTMP URL with a valid authentication token.

Go to the second section and fill the form in the following way:
* Original URL = rtmp://your-push-domain/sample-app/sample-stream
  (e.g. "rtmp://livevideo-push.my-sample-domain.xyz/sample-app/sample-stream")
* Cryptographic Key = copy-paste the "Primary Key" field value from the "Signed URL Settings" section above
* Validity Period = 30

Click on the "Generate" button to obtain an URL. As you can see on the following screenshot, the URL is:
```
rtmp://livevideo-push.my-sample-domain.xyz/sample-app/sample-stream?auth_key=1546482883-0-0-7c5a077514e3a8e6913a8234e8b88976
```
![Push RTMP URL](images/avl-push-domain-access-control-rtmp-url.png)

Now execute OBS on your computer and configure it in the following way:
* Configure one scene with one "Video Capture Device" source and select your webcam (note the resolution of your
  webcam, for example 1280x720);
  
  ![OBS scene and source](images/obs-scene-source.png)
  
  ![OBS video capture device](images/obs-video-capture-device.png)
  
* Go to the "Settings" and go to the "Video" tab; set the "Base (Canvas) Resolution" and "Output (Canvas) Resolution"
  to the same value as your webcam (e.g. 1280x720);
  
  ![OBS video settings](images/obs-settings-video.png)
  
* Still in the "Settings" window, go to the "Stream" tab; fill the form with the following values:
  * Stream Type = Custom Streaming Server
  * URL = your push URL truncated after "sample-app/" (e.g. "rtmp://livevideo-push.my-sample-domain.xyz/sample-app/")
  * Stream key = the rest of the push URL
    (e.g. "sample-stream?auth_key=1546482883-0-0-7c5a077514e3a8e6913a8234e8b88976")
  * Use authentication = unchecked
  
  ![OBS stream settings](images/obs-settings-stream.png)

Click on the "OK" button to save your settings, then click on the "Start Streaming" button. After few seconds
the status bar at the bottom of OBS should look like this:

![OBS status bar while streaming](images/obs-status-bar-while-streaming.png)

Keep OBS running in the background. With your web browser, go back to the Apsara Video Live console:
* Click on the "Stream Management > Ingest Endpoints" menu item; you should be able to see your "sample-stream":

  ![Sample stream in Apsara Video Live](images/avl-ingest-endpoint-sample-stream.png)

* Click on the "View URLs" link on the right of your "sample-stream"; you should b able to see three URLs:

  ![Sample stream URLs](images/avl-sample-stream-urls.png)

* Put your mouse cursor on top of the first URL: two links should appear, "Copy" and "Play"; click on "Play";
* A new popup should appear. If you use Google Chrome, you will need to click to enable "Adobe Flash Player";

Congratulation if you can see yourself! It means the Apsara Video Live configuration is correct.

![Play sample stream](images/avl-play-sample-stream.png)

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