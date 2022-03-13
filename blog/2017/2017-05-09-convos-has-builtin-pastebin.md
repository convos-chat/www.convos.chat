---
title: Convos got a built in pastebin
author: Jan Henning Thorsen
---

Convos has a high focus on privacy. Convos can be run on closed network, and
no external resources on the public internet should ever be needed. This ideas
was also taken into consideration when we decided bundle a
[pastebin](https://github.com/convos-chat/convos/pull/329) with Convos. The
pastebin implementation stores the data in
[CONVOS_HOME](/doc/config#convos_home), meaning you are
in full control of the data shared.

<!--more-->

The pastebin works like this:

1. Copy a chunk of multiline text
2. Paste it into the the input text box in a conversation
3. Hit enter
4. Convos will create a paste, and send the link to the past as a message

Here is an example paste:

![Example paste](/screenshots/2017-05-09-pastebin.png)

## Multiline messages

If the text is three lines (subject to change) or less, then Convos will
simply send the them as three messages instead. There is an environment variable
that decides how many lines you need to have before it is converted to a paste.
It is not public, so changing this might not work in the future, but if you want
to play around and tweak the setting, you can try the command below:

    CONVOS_MAX_BULK_MESSAGE_SIZE=1 ./script/convos daemon

## External pastebin service

There are currently no plan to implement support for sending a paste to an
external service, but that doesn't prevent you from making your own. The
pastebin is implemented as a [plugin](https://github.com/convos-chat/convos/blob/main/lib/Convos/Plugin/Paste.pm),
meaning you can create [your own](https://github.com/convos-chat/convos/blob/main/lib/Convos/Plugin/Paste.pm#L41)
and [load that](/doc/config#convos_plugins) instead.

After all... Convos is Open Source!

## Want to know more?

Please [contact us](/doc/#get-in-touch) if you're interested into learning
more about how to make a plugin, or have questions about Convos in general.
