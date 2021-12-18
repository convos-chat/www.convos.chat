---
title: How to move Convos to a new server
author: Jan Henning Thorsen
---

We had to move Convos to [DigitalOcean](https://digitalocean.com), since the
old server had disk issues.  Moving Convos was not too hard, but there were
some issues [getting connected to libera.chat](/blog/2021/12/23/connecting-to-libera-from-digitalocean)
afterwards.

The move was simple because...

* The [Convos](https://convos.chat) data is located in one place, and consists
  of simple text files that can be copied over to the server.
* We had the Convos instances running in [Docker](https://www.docker.com/).
  That and the self-contained nature of Convos makes it very easy to move
  Convos around.
* Providing a [user data](https://docs.digitalocean.com/products/droplets/how-to/provide-user-data/)
  script when setting up the "Droplet" (DigitalOcean VPS) helps gettings a
  consistent starting point.

## The move

Here are the five steps I did in order to move Convos:

1. Copy the [docker compose file](#docker-composeconvosyaml) over to the server
   and run it to get Convos installed. This can also be done remotely though,
   but requires poking holes in the firewall.

        rsync -va docker-compose $NEW_SERVER:~
        ssh $NEW_SERVER 'sudo docker-compose -p convos -f docker-compose/convos.yaml up -d'

2. After running docker-compose, you should make sure that the reverse proxy
   works as expected, without actually changing the DNS records first.
   [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) is used for a
   close to zero config setup.

        ssh $NEW_SERVER 'curl -s -H "Host: your-convos.com" http://localhost' | grep 'convos:'
        curl -s -H "Host: your-convos.com" http://$NEW_SERVER | grep 'convos:'

    The first check can fail if nginx-proxy or Convos is not set up correctly
    inside Docker. The second check can fail if the host's firewall is not set
    up correctly. If both commands give you some "meta content" output, then
    you're good to go.

3. Stop Convos on the new server, since it currently does not have the correct
   data. Doing this with a quick-and-dirty command that stops all the running
   containers, since Docker does not run anything else interesting:

        ssh $NEW_SERVER 'sudo docker stop $(sudo docker ps -q)'

4. Copy the Convos data from the old server to the new server. Going to do this
   twice: Once while Convos is running and then one time after it was stopped
   to be sure we get all the data.

        ssh $OLD_SERVER 'rsync -va ~/.local/share/convos $NEW_SERVER:~/.local/share/convos'

5. The last step is actually multiple steps, but documenting it as one to
   illustrate that it should be done at the same time. The first thing you have
   to do before running the commands below is to update your DNS records. After
   that is done, you can run these commands:

        # Stop convos on the old server
        ssh $OLD_SERVER 'sudo docker stop $(sudo docker ps -q)'

        # Copy over the few files that might have changed in the meanwhile
        ssh $OLD_SERVER 'rsync -va ~/.local/share/convos $NEW_SERVER:~/.local/share/convos'
         
        # Start all the stopped Docker containers
        ssh $NEW_SERVER 'sudo docker start $(sudo docker ps -q -a)'
        
        # Check that Convos is running
        ssh $NEW_SERVER 'curl -s -H "Host: your-convos.com" http://localhost' | grep 'convos:'
        curl -s -H "Host: your-convos.com" http://$NEW_SERVER | grep 'convos:'
        curl -s -H https://your-convos.com | grep 'convos:'

   In addition to the two curl-commands from step #2, I also check that the DNS
   records have been updated. This might take some time, so don't panic if the
   last step fails. Double check with `dig` or some other tool to see if the
   DNS was indeed correctly changed.

## Conclusion

Moving Convos is not very hard, but setting up TLS/SSL and making sure backups
run makes hosting applications harder. Setting up TLS/SSL is luckily easier than
ever: Have a look at [SSL Support using an ACME CA](https://github.com/nginx-proxy/nginx-proxy#ssl-support-using-an-acme-ca)
for a starting point. When it comes to backups, you can simply start by using
`rsync` to copy the [$CONVOS_HOME](/doc/config#convos_home) to a different
location/server using a periodic [cron](https://en.wikipedia.org/wiki/Cron) job.

## Assets

Below are the most important parts of the docker-compose and user_data files,
but with some private details taken out.

### docker-compose/convos.yaml

The docker-compose file below sets up Convos,
[nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) (as a reverse web
proxy) and [ergo](https://github.com/ergochat/ergo) (a modern IRC server).
daemon.

    version: "3"
    
    services:
     convos: 
        image: convos/convos:v6.41
        container_name: convos
        restart: always
        environment:
          - CONVOS_CONNECT_DELAY=4
          - CONVOS_DEBUG=0
          - CONVOS_BOT_EMAIL=bot_nick_name@your-convos.com
          - CONVOS_DETECT_THEMES_INTERVAL=60
          - CONVOS_MAX_UPLOAD_SIZE=50000000
          - CONVOS_REVERSE_PROXY=1
          - VIRTUAL_HOST=your-convos.com
          - VIRTUAL_PORT=3000
        volumes:
          - '/home/convos/.local/share/convos:/data'
    
      ergo:
        image: ghcr.io/ergochat/ergo:master
        container_name: ergo
        ports:
          - '6697:6697'
        restart: always
        volumes:
          - '/home/convos/.local/share/ergo:/ircd'
    
      nginx-proxy:
        image: nginxproxy/nginx-proxy:alpine
        container_name: nginx_proxy
        restart: always
        ports:
          - '80:80'
          - '443:443'
        volumes:
          - /var/run/docker.sock:/tmp/docker.sock:ro

### user_data.sh

In addition to the script below, you might want to consider doing this:

* Add normal user accounts, and deny root access directly to the server.
* Set up periodic backups. This can be a simple `rsync` command from cron to
  another backup server.

The following script can be copy/pasted into the "User data" text field when
creating a Droplet:

    #!/bin/bash
    
    # Distro: Ubuntu 21.10
    # Plan: Shared CPU Basic
    # Hardware: Premium AMD with NVMe SSD, smallest and cheapest option
    # [x] IPv6
    # [x] User data
    # [x] Monitoring
    # [x] SSH keys
    
    apt-get -y update;
    apt-get -y upgrade;
    apt-get -y autoremove;
    apt-get -qqy install ack-grep aufs-tools gcc etckeeper cpanminus curl fail2ban libio-socket-ssl-perl mlocate rsync tmux ufw vim unzip wget;
    
    [ -e /etc/systemd/system/do-agent.service ] \
      || curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash;
    
    [ -d '/etc/.git' ] || etckeeper init;
    
    ufw status | grep -q '^22'  || ufw allow 22;
    ufw status | grep -q '^443' || ufw allow 443;
    ufw status | grep -q '^80'  || ufw allow 80;
    ufw status | grep -q 'inactive' && ufw --force enable
    
    [ -x /usr/bin/docker ] || apt-get install -qqy docker.io docker-compose;
    systemctl start docker.service;
    systemctl start docker.socket;
