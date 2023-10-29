---
title: Convos docker images moved to Github
author: Jan Henning Thorsen
---

Convos has finally migrated from the [Docker registry](https://hub.docker.com/r/convos/convos/)
to [Github registry](https://github.com/convos-chat/convos/pkgs/container/convos).

By doing so, we thought it would be a good idea to bump Convos from 7.xx to 8.00.
But that's not all...

<!--more-->

## Why did we have to move from Docker hub?

We tried to reach out to Docker to host our images for free, since we are a
non-profit open source project, but since they never got back to us, we saw no
other way than to move the images to Github.

What does this mean for you? To get the new release, you have to make the
following change in your Docker compose file:

    -    image: convos/convos:v7.15
    +    image: ghcr.io/convos-chat/convos:v8.02


Instead of "v8.02", you can also use the "alpha" or "stable" tags.

## We changed the main menu

In the [8.00 release](https://github.com/convos-chat/convos/blob/v8.00/Changes#L3),
we also made some changes to the main menu: It now has collapsible sections,
where you can hide servers and user settings, if you find them distracting. One
usecase is that during work, you might want to only see relevant IRC servers,
instead of getting distracted by other conversations.

![New main menu](/screenshots/2023-10-30-main-menu.png)

## New participant list

In the [8.01](https://github.com/convos-chat/convos/blob/v8.01/Changes#L3)
release we also merged the conversation/server settings into the participant
list. This has always been the case on small/narriw screens (aka phones), but
we are now reusing the layout on wide screens, making it a bit easier to get to
the conversation settings. Toggling between raw messages are now very easy, and
readily available.

![New participant list](/screenshots/2023-10-30-conversation-setings.png)

## New language support

The 8.00 release also got Romanian translation. We're very happy to support more
languages, and welcome any pull requests for other languages in the future of
course. Adding a language takes some work, but does not require any programming
skills: Simply copy the [en.po](https://github.com/convos-chat/convos/tree/v8.00/assets/i18n)
and start translation the strings into your favorite language. Don't know git
or don't have a github account? No problem: Just [email](contact@convos.chat)
the translation to us and we'll add the changes to the repo.
