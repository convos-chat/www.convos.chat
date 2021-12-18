---
title: How to connect to Libera.chat from DigitalOcean
author: Jan Henning Thorsen
---

[Moving to DigitalOcean](/blog/2021/12/18/moving-convos-to-digitalocean) was
quite painless for most of the users, since they had already made an account on
the [libera.chat](https://libera.chat/) server. Unfortunately, the
[Convos bot](/doc/Convos/Plugin/Bot) and I had not set up our accounts properly.

## Already registered on libera.chat

Since my user was already registered I just had to replace my legacy
"On-connect commands" with SASL setup in my connection settings. Here is a
screenshot of my previous "On-connect commands":

[![Picture of example on connect command](/screenshots/2021-12-23-libera-legacy-on-connect-commands.jpg)](/screenshots/2021-12-23-libera-legacy-on-connect-commands.jpg)

And here is a screenshot of the SASL setup, found under "Authentication
settings": (Username should be the nickname you have registered, which is
the default since Convos [v6.43](https://github.com/convos-chat/convos/blob/v6.43/Changes#L3-L8))

[![Picture of example SASL setup](/screenshots/2021-12-23-libera-sasl-config.jpg)](/screenshots/2021-12-23-libera-sasl-config.jpg)

## Register and connect to libera.chat

<small><em>Note that the following steps has nothing to do with the bot really. It
applies to any user.</em></small>

The bot on the other hand was a bit more difficult, since it was not
registered: Not being registered means that you cannot connect, meaning you
cannot register, since those commands can only be run after you have
successfully connected.

So to register, I started Convos (you can use any IRC client) locally on my
personal computer, logged in to libera.chat and registered the bot nick:

1. Made a new connection with these settings:

        Host and port:            irc.libera.chat:6697
        Nickname:                 convos_bot
        Secure connection (TLS):  Yes
        Verify certificate (TLS): Yes

2. When successfully connected, I ran the command below to register:

        /msg NickServ REGISTER SUPERSECRETPASSWORD convos_bot@convos.chat

   And `NickServ` replied back:

   > An email containing nickname activation instructions has been sent to convos_bot@convos.chat.
   > Please check the address if you don't receive it. If it is incorrect, DROP then REGISTER again.
   > If you do not complete registration within one day, your nickname will expire.

3. The email contained a VERIFY command I had to enter in my IRC client (Convos).
   Something like this:

        /msg NickServ VERIFY REGISTER convos_bot SOME_VERIFICATION_CODE

4. After getting a message back from `NickServ` that the nick was registered,
   I could disconnect and remove the temporarily connection from my computer,
   and then go back to the Convos instance running on DigitalOcean and follow
   the steps in "[Already registered on libera.chat](#already-registered-on-liberachat)"
   above.

## Using SASL External

<small><em>Note that the following steps require Convos
<a href="https://github.com/convos-chat/convos/blob/v6.44/Changes#L3-L4">v6.44</a></em></small>

If you prefer using SASL External then you have to setup
[CertFP](https://libera.chat/guides/certfp). This is pretty easy, since Convos
automatically [generates](https://github.com/convos-chat/convos/blob/834a7dc05ad38b8ed611141044b81fd78363beec/lib/Convos/Util.pm#L54-L82)
unique TLS cert and key for every connection. This means that after you have
connected, you can simply run the command below to add you certificate
fingerprint:

    /msg NickServ CERT ADD

Once that is done, you can go back to your connection settings and change "SASL
authentication mechanism" to "External".

[![Picture of SASL external config](/screenshots/2021-12-23-sasl-external.jpg)](/screenshots/2021-12-23-sasl-external.jpg)

## Conclusion

It's quite annoying that you have to create an account before connecting from a
VPS (such as DigitalOcean Droplet). I don't understand how to make this
user-friendly for new users. Got any ideas? Please contact us in the #convos
channel on [libera.chat](irc://irc.libera.chat:6697/#convos).

## References

* [Nickname Registration](https://libera.chat/guides/registration)
* [Using CertFP](https://libera.chat/guides/certfp)
