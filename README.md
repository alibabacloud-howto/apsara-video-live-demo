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

## Installation
TODO Terraform script