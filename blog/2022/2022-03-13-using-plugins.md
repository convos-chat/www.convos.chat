---
title: Using Plugins with Convos
author: toxic0berliner
---

This post simply goes over the setup to extend convo's features using plugins.
It uses uses the example of the Paste plugin [recently updated](/blog/2022/3/13/released-seven-point-oh) to make pasting into convos use the excellent [ix.io](https://ix.io/) to upload the paste in replace the irc message by a link to the content that was just sent to the paste site.

<!--more-->

## What we're trying to solve

When you paste more than 3 lines of text in convos, it now stores this message in a file and replaces your message by a link to convos itself on a page that would display the file that it just created and containing what you pasted. This is very useful to avoid flooding on irc. 
But this also means you're inviting anyone in the chat to connect to your own instance of convos, on this unauthenticated part that will display these pastes.

Having put all of convos behind a reverse-proxy that enforces authentication, that was not helpfull as people wanting to look at my paste were asked to login.
I could have removed the authentication only for the convos paste url, but given the amount of freely available services like pastebin or ix.io that take the risk for me of hosting publicly, using those felt like a better alternative.

This plugin aims actually at replacing an existing convos feature. And if you use it, you'll probably have to enhance it or write another plugin again to hande pictures that can also be pasted in convos and will also use a similar mechanism, but that is out of the scope of this article (for now...)

Now, how do we do this ?

## What we need to do

1. create the plugin (or use the provided example ;) )
2. pass it to convos
3. tell convos to load it
4. done !

## Context
We'll assume for this that you are running convos using the docker image over at "[convos/convos](https://hub.docker.com/r/convos/convos) and have access to the docker host or ability to mount volumes from somewhere.

## The plugin itself

Convos provides a nice [example implementation](https://github.com/convos-chat/convos/blob/main/lib/Convos/Plugin/Paste.pm#L36) for this plugin that we'll shamelessy use pretty much as-is here. So we create a file containing this : 

        package Convos::Plugin::Ix;
        use Mojo::Base 'Convos::Plugin';
        sub register {
            my ($self, $app, $config) = @_;
            my $ua = $app->ua;
            $app->core->backend->on(message_to_paste => sub {
                my ($backend, $connection, $message) = @_;
                return $ua->post_p('http://ix.io', form => {'f:1' => $message})->then(sub {
                my $tx = shift;
                my $err = $tx->error && $tx->error->{message};
                return Mojo::Promise->reject($err) if $err;
                return $tx->res->body;
                # The body contains the URL to the paste and instead of just returning the
                # URL, the message can be customized further:
                #return sprintf 'My message is long, so I made a paste: %s', $tx->res->body;
                });
            });
        }
        1;

And store this `Ix.pm` wherever we wish on the docker host.

## Include our plugin in the running container

Now, when running the docker image, convos will expect to run plugins from the `/app/lib/Convos/Plugin/` directory, so we'll use our compose file here to pass it using a volume mount as this : 

        volumes:
            - convos-data:/data
            - /path/on/host/to/our/plugin/file/Ix.pm:/app/lib/Convos/Plugin/Ix.pm

Simply add other volumes to add more plugin files or mount the entire `/app/lib/Convos/Plugin/` directory using a volume, in which case you'll probably have to populate it with the existing plugins first.

## Instruct convos to load our plugin

Convos will read the environment variable `CONVOS_PLUGINS` on startup and load the appropriate plugins, so again, in our compose file : 

          environment:
            - CONVOS_REQUEST_BASE=https://convos.example.com/
            - CONVOS_SECURE_COOKIES=true
            - CONVOS_PLUGINS=Convos::Plugin::Ix

This simply references the `Convos::Plugin::Ix` package name we defined in our perl code.

Now stringing all together, I end up with the following compose file : 

        version: "3"
        services:
        convos:
            container_name: convos
            environment:
            - CONVOS_REQUEST_BASE=https://convos.example.com/
            - CONVOS_SECURE_COOKIES=true
            - CONVOS_PLUGINS=Convos::Plugin::Ix
            hostname: convos
            image: convos/convos:stable
            labels:
            traefik.http.middlewares.convos.headers.customrequestheaders.X-Forwarded-Proto: 'https'
            subdomain: convos
            #ports:
            #  - 3000
            restart: unless-stopped
            volumes:
            - convos-data:/data
            - /path/on/host/to/our/plugin/file/Ix.pm:/app/lib/Convos/Plugin/Ix.pm
            networks:
            traefik:
                aliases: 
                - convos

Now, this actually assumes you are running convos behind traefik with the docker provider setup to your liking, if you are not, you can uncomment the port exposition for example.

## Contributors

This was all made possible by Jan Henning Thorsen who brought this feature back to life in a pinch when he saw me struggeling to get the older version of the paste plugin working.
Sen many thanks to him for all the help and time invested in making convos a very nice piece of software !
