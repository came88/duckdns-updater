# DuckDNS Updater

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/came88/duckdns-updater)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/came88/duckdns-updater)
![MicroBadger Layers](https://img.shields.io/microbadger/layers/came88/duckdns-updater)
![MicroBadger Size](https://img.shields.io/microbadger/image-size/came88/duckdns-updater)
![Docker Pulls](https://img.shields.io/docker/pulls/came88/duckdns-updater)

DuckDNS Updater is a lightweight image that check your public IP and update your [DuckDNS](https://www.duckdns.org) Dynamic DNS.

By default, DuckDNS Updater will obtain your public IP every 30 seconds using a DNS query to opendns, akamay or google, updating your DDNS only if it is different from your domain ip on DuckDNS.

## Usage

### With docker-compose

```yaml
version: '3'

services:
  duckdns:
    image: came88/duckdns-updater
    environment:
    - DOMAIN=your_domain
    - TOKEN=your_duckdns_token
```

### With only docker

```shell
docker run --detach \
    -e DOMAIN=your_domain \
    -e TOKEN=your_duckdns_token \
    came88/duckdns-updater
```

## Advanced configuration

There are a couple of environment variables that can be used to adjust check and update frequencies:

- TIME_CHECK: how often (in seconds) DuckDNS Updater check your public IP
- TIME_UPDATE: how much time the checks are paused after a successful update

## Debug

By default DuckDNS Updater logs very little, if you need more detail you can set the environment variable `DEBUG=1`.
