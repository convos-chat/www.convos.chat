---
title: Convos with NGINX behind Cloudflare with Flexible SSL setting
author: Claudiu Ciungan
---

My goal was to use docker-compose and install Convos, then place it behind NGINX and Cloudflare, with the purpose of benefiting from Cloudflare's protection.
I quickly ran into a very peculiar problem due to me using Cloudflare's **Flexible** SSL/TLS setting.

<!--more-->

To Convos' credit, deploying via Docker is very easy, but I wrote my own docker-compose.yml file, since I didn't want to remember or lookup the full CLI command with it's arguments.

Here's my docker-compose file:

    version: "3"
    # Defining a shared network between my containers - you can skip this if you want to manage your networks a different way
    networks:
    dockernet:
        external: true
    volumes:
    data:
    services:
    convos:
        image: 'convos/convos:stable'
        container_name: convos
        restart: unless-stopped
        ports:
        - "3000:3000"
        volumes:
        - data:/data
        environment:
        - CONVOS_REVERSE_PROXY=1
        - MOJO_REVERSE_PROXY=1
        networks:
        - dockernet


Once that file is in a folder called convos, I do docker-compose up.

At this stage, I switch over the NGINX and configure the reverse proxy. My initial config looked like this:

    server {
    set $forward_scheme http;
    set $server         "convos.dockernet";
    set $port           3000;

    listen 80;
    listen [::]:80;

    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name im.example.com;

    # Let's Encrypt SSL
    include conf.d/include/letsencrypt-acme-challenge.conf;
    include conf.d/include/ssl-ciphers.conf;
    ssl_certificate /etc/letsencrypt/live/npm-1/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/npm-1/privkey.pem;

    # Block Exploits
    include conf.d/include/block-exploits.conf;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_http_version 1.1;

    access_log /data/logs/proxy-host-1_access.log proxy;
    error_log /data/logs/proxy-host-1_error.log warn;


    location / {

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        proxy_http_version 1.1;


        # Proxy!
        include conf.d/include/proxy.conf;
        }
    }

With this config in place, everything seemed to work well when I accessed im.example.com without the Cloudflare proxy turned on, but as soon as I turned it on I was getting this error:

[![Picture of not found error](/screenshots/2022-06-01-convos-error-not-found.png)](/screenshots/2022-06-01-convos-error-not-found.png)

I then followed the documentation on reverse proxies, on the [Running Convos behind my favorite web server](https://convos.chat/doc/reverse-proxy#example-nginx-config) page and modified the `location` section as follows:

    location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Scheme $scheme;
    proxy_set_header X-Forwarded-Proto  $scheme;
    proxy_set_header X-Forwarded-For    $remote_addr;
    proxy_set_header X-Real-IP		$remote_addr;
    proxy_pass       http://convos.dockernet:3000;

    # Block Exploits
    include conf.d/include/block-exploits.conf;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_http_version 1.1;

    # http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size

    client_max_body_size 0;

    # Enable Convos to construct correct URLs by passing on custom headers.

    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Request-Base "https://$host/";
    }

The initial portion, with `proxy_set_header` was already declared in `include conf.d/include/proxy.conf;` with the only modification to that portion being the hardcoded `proxy_pass` line. That in itself, didn't do the trick.

After some more testing, I figured out that setting the X-Request-Base to be `https://` **seemed to be the solution**, instead of `$scheme://`, which was recommended in the documentation page.

My guess is that this is not due to the documentation page, or Convos, but rather because Convos is now essentially behind two reverse proxies and the fact that Cloudflare is set to Flexible, as opposed to Full or Full (strict), would mean that its trying to pass the forwarding in a transparent way. However, the local NGINX server isn't catching the scheme and it keeps trying to redirect to http, instead of https.