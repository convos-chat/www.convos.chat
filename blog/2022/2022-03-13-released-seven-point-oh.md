---
title: Convos just got more modern
author: Jan Henning Thorsen
---

It's been about a year since the v6.00 release and since we decided to bump the
Perl version, and break some internal APIs, I thought it was a good opportunity
to bump the major version to [v.7.00](https://github.com/convos-chat/convos/blob/v7.00/Changes#L3).

<!--more-->

## Why bump the Perl version?

We decided to bump Perl to 5.20, so we could get some modern features such as
async/await. I can't wait to bump it to 5.26 though, so we can use async/await
together with signatures, but that won't happen until the LTS versions of the
most popular Linux distributions ship with that version of Perl: It is nice to
have new tools to use, but the most important is keep Convos easy to install
for the end user.

## Authenticate using a HTTP header

Without the change to async/await in the backend, it would be very hard to add
support for "[Proxy authentication by http header value](https://github.com/convos-chat/convos/issues/696)",
but with the new syntax it was [quite pleasent](https://github.com/convos-chat/convos/pull/702/files)!

This new plugin allow for a single point for user management and authentication,
with the help of a [reverse proxy auth hook](https://developer.okta.com/blog/2018/08/28/nginx-auth-request).

## Brought back paste plugin

After a request from a Convos user, I reviewed the "multiline message to paste"
logic and found it incredible difficult to override. Based on this discovery, I
decided to break the existing Perl API and make revive the Paste plugin. The
documentation also includes an
[alternative implementation](https://github.com/convos-chat/convos/blob/main/lib/Convos/Plugin/Paste.pm#L36).

## Highlights since 6.00

The [Changelog](https://github.com/convos-chat/convos/blob/v7.00/Changes#L3)
has all the changes, but here is a small digest of which changes I consider the
most important:

* Add `/shrug` command
* Add Dracula and GNOME color themes
* Add arm64 docker image
* Add better feedback in case TLS settings are incorrect
* Add connection profiles
* Add handler for `irc://` links
* Add handling of AWAY
* Add management of paste and uploaded files
* Add notification sound
* Add support for Github Webhooks, through the bot system
* Add support for logging to syslog
* Add support for raw messages
* Add support for rendering IRC colors and formatting
* Changed from freenode to [Libera](https://libera.chat)
* Changed password handling for improved security and privacy
* Fix SASL EXTERNAL authentication
* Fix several vulnerabilities reported on [Huntr](https://huntr.dev/)
* Improved handling of notification

## Contributors

I would like to thank the following people for contributing to Convos the last
year: Eugene de Beste, Jess Robinson, Joel Berger, Marcus Ramberg, PeGaSuS,
SerHack, Stig Palmquist and compeak.

And also a big thank you to all the supporters in the
[#Convos](irc://irc.libera.chat:6697/convos) channel on
[Libera](https://libera.chat/).

Hoping to make Convos even better with you all in the future!
