---
title: Convos has moved to irc.libera.chat
---

The #convos channel has moved to [irc.libera.chat](https://libera.chat/). You
might still see people in the #convos channel on freenode, but that will
hopefully soon change.

The Freenode network has been overtaken by a corporate entity, resulting in the
staff members quitting and starting a new IRC network called "libera".

You can read more about the details on [kline.sh](https://kline.sh/), but here
is a quote from the post:

> I cannot stand by such a (hostile) takeover of the freenode network, and I
> am resigning along with most other freenode staff.

Here are some instructions, if you want to prevent your personal account to get
into the hands of an unknown corporate entity:

    # Change the account information
    /msg nickserv set password
    /msg nickserv set email

    # Delete your freenode account data:
    /msg nickserv drop &lt;account name> &lt;password>

Moving to the new network, you might want to register your nick:

    /msg nickserv register &lt;password> &lt;email>

If you get any error such as "Sending email failed, sorry! Registration
aborted.", it just means that the network has a lot of new registrations and is
unable to handle your request. Please wait a couple of minutes and try again.
(Flooding #libera with questions is not helpful)

Convos [v6.18](https://github.com/convos-chat/convos/blob/v6.18/Changes) has
been released with new defaults, and the [official webpage](https://convos.chat/)
has been updated with links to [https://libera.chat/](https://libera.chat/),
instead of freenode.

Looking forward to seeing you on the new network!
