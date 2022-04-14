---
title: How we integrated Convos with Portal using Traefik (and how to configure Traefik for proxy authentication)
author: Max von Tettenborn
---

With [Portal](https://getportal.org/), we are building a platform that allows
even non-technical people to benefit from the perks of selfhosting one's own
services: ownership and sovereignty and the freedom to install any application
you want. Obviously, if everyone should be able to use it, super simple UX is
key. Portal must not feel like selfhosting but like a turnkey private space
that just works. And the same is true for apps: after a one-click installation
from the app store, you must be able to simply open the app and start using it.

<!--more-->

That, however, is not the way most selfhosting apps work. It is common that
apps feature a user management which puts a registration and login view in
front of the actual interface. On Portal, this is awkward. You just installed
the app on your own space, why would you have to login?

The easiest technique to circumvent this is using proxy authentication - if the
app allows it. And
[recently](https://github.com/convos-chat/convos/blob/ec05ff72de854751db384b9292db47dd1914a211/Changes#L7),
Convos added this feature. Let's take a look at what it is and how you can use
[Traefik](https://traefik.io/) as a reverse proxy that handles authentication
for you.

## What is proxy auth?

The idea behind proxy auth is really simple. A web application like Convos that
has built in user management always needs to authenticate users in some way.
There are
[multiple](https://github.com/convos-chat/convos/tree/main/lib/Convos/Plugin/Auth)
ways to do this, like basic auth, where username and password are attached to
the http header of each request. Or there might be session management, where
your login causes a cookie with a session key to be saved in your browser.
Every request that contains that cookie is then treated as belonging to the
session and by extension as belonging to the logged-in user.

Proxy auth is another way of signaling to the server that a request belongs to
a certain user. It works by just putting the plain username inside a http
header. That's it, as long as the username is there, the request is considered
belonging to the user.

Now of course, in a simple hosting scenario, that would be highly insecure. Any
attacker could just set the header and hijack a user's identity.

That is why it only makes sense when the app is not directly exposed to the
internet but is placed behind a reverse proxy like Traefik that forwards - and
modifies - all incoming requests. That way the reverse proxy can not only make
sure that any proxy auth header is stripped from all requests, it can realize
authentication itself (usually by calling another dedicated service) and set
the header accordingly.

The great benefit of that kind of authentication is that you can now deploy
multiple apps behind your reverse proxy and have them all use the same
authentication mechanism. It is a simple form of single sign-on.

## Traefik configuration on Portal

In Traefik, this kind of authentication is implemented by a middleware called
[ForwardAuth](https://doc.traefik.io/traefik/middlewares/http/forwardauth/#forwardauth).
It allows you to forward every single request first to a dedicated auth server.
Its only task is to look at the request and find out if it is authenticated and
(optionally) who is the user that sent it. If it responds with a 2XX code, the
request is forwarded to the app and the username from the AuthServer's response
can be added to the request so the app knows which user sent it. Else, the
request is denied and never reaches the app itself.

On Portal, the Portal Core application plays the role of the auth server. It
provides the [endpoint](https://ptl.gitlab.io/portal_core/#operation/authenticate_and_authorize_internal_auth_get)
`http://portal_core/internal/auth` which looks at incoming requests and expects
an JWT that authenticates a terminal (which is our term for the owner's paired
devices). This method of authentication is custom-built for Portal but neither
Traefik nor Convos nor any other installed app need to know about it. The auth
endpoint just returns the appropriate response including some headers
containing additional information about the authenticated device: their names
start with `X-Ptl-` and they are copied to the request before it is forwarded
to the app.

This is the Traefik config for the ForwardAuth middleware.

    middlewares:
      auth:
        forwardAuth:
          address: "http://portal_core/internal/auth"
          authResponseHeadersRegex: "^X-Ptl-.*"

And this is part of the docker-compose file where Convos is defined. The
sections about TLS are not relevant for this example, they are only included
for completeness.

    networks:
      portal:
        name: portal
    services:
      convos:
        image: convos/convos:stable
        container_name: convos
        restart: always
        volumes:
          - /home/portal/user_data/app_data/convos//data:/data
        environment:
          - CONVOS_ADMIN=gjq6gv@example.com  # the Portal's ID becomes the default username
          - CONVOS_AUTH_HEADER=X-Ptl-User  # The http header where Convos should expect the logged-in username
          - CONVOS_PLUGINS=Convos::Plugin::Auth::Header
          - CONVOS_REVERSE_PROXY=1
        networks:
          - portal
        labels:
          - traefik.enable=true
          - traefik.http.routers.convos_router.entrypoints=https
          - traefik.http.routers.convos_router.middlewares=auth@file  # use the auth middleware defined before
          - traefik.http.routers.convos_router.rule=Host(`convos.gjq6gv.p.getportal.org`)
          - traefik.http.routers.convos_router.service=convos
          - traefik.http.routers.convos_router.tls.certresolver=letsencrypt
          - traefik.http.routers.convos_router.tls.domains[0].main=gjq6gv.p.getportal.org
          - traefik.http.routers.convos_router.tls.domains[0].sans=*.gjq6gv.p.getportal.org
          - traefik.http.routers.convos_router.tls=true
          - traefik.http.services.convos.loadbalancer.server.port=3000

As you can see, Convos' [proxy auth](https://convos.chat/doc/Convos/Plugin/Auth/Header)
feature allows us to completely circumvent any registration or login screen in
order to provide a seamless user experience. People simply install the app,
open it, and it works. This is one key in building an easy-to-use private space
for individuals that enables online freedom and self-determination.

For more information, visit [getportal.org](https://getportal.org) and if you
wanna try it yourself: the first 20 people that enter the code `convos-2204` at
[preview.getportal.org](https://preview.getportal.org) can claim a free Portal
for a few days - no strings attached. Make sure to install the Convos app and
give it a try.
