# bbb-playback-proxy

A docker encapsulated version for BigBlueButton Playback Player proxied with nginx.

## Overview

BigBlueButton records all the events and media data generated during a BigBlueButton session for later playback.

BigBlueButton processes the recordings in 5 phases:

1. Capture
2. Archive
3. Sanity
4. Process
5. Publish
6. Playback

Some Record and Playback phases store the media they handle in different directories. But in the end, the Playback phase involves taking the published files (audio, webcam, deskshare, chat, events, metadata) and playing them in the browser.

The details for how BigBlueButton Recordings are created can be found at [Recordings](https://docs.bigbluebutton.org/dev/recording.html)

By default the media file is stored in the BigBlueButton file system. This means that BigBlueButton, which includes nginx as one of its core components, has the ability to serve the media files and a player as static content, from type-specific root directories.

There are however situations when it is necessary to store and serve this recordings in a different way. For example when the File System is not enough for the amount of data stored, or when the recordings created by clustered BigBlueButton servers needs to be aggregated.

In those cases one strategy that can be applied is to forward the requests to a proxy that is only focused on serving the recordings.

### Architecture

The bbb-playback-proxy Docker image is a Linux Docker image (apline or amazonlinux) that has Nginx stock installed and includes the same nginx configuration files, media player and Directory structure that can be found in a BigBlueButton server.

Example.

### Ports

This image only exposes port 80 externally

### Usage

Example with `docker run`
```
docker run -d -p 80:80 -v /mnt/scalelite-recordings/var/bigbluebutton/:/var/bigbluebutton/ bigbluebutton/bbb-playback-proxy:bionic-23-dev-alpine3.11
```

Example with `docker-compose`

```
version: '3'
services
  frontend-proxy:
    image: nginx:latest
    container_name: frontend-proxy
    restart: unless-stopped
    volumes:
      - ./proxy/log/nginx/:/var/log/nginx
      - ./proxy/nginx/sites.template.${DOCKER_PROXY_NGINX_TEMPLATE:-scalelite-proxy}:/etc/nginx/sites.template
      - ./data/certbot/conf/:/etc/letsencrypt
      - ./data/certbot/www/:/var/www/certbot
    ports:
      - "80:80"
      - "443:443"
    environment:
      - NGINX_HOSTNAME=${URL_HOST:-xlab.blindside-dev.com}
    depends_on:
      - certbot
      - recording-proxy
    command: /bin/bash -c "envsubst '$$NGINX_HOSTNAME' < /etc/nginx/sites.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"

  recording-proxy:
    image: bigbluebutton/bbb-playback-proxy:bionic-23-dev-alpine3.11
    container_name: recording-proxy
    restart: unless-stopped
    volumes:
      - /mnt/recordings/var/bigbluebutton/published:/var/bigbluebutton/published

  certbot:
    image: certbot/certbot
    container_name: certbot
    volumes:
      - ./log/certbot:/var/log/letsencrypt
      - ./data/certbot/conf:/etc/letsencrypt
      - ./data/certbot/www:/var/www/certbot
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"
```
