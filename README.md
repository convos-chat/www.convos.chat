[![convos](https://snapcraft.io//convos/badge.svg)](https://snapcraft.io/convos)
[![Docker Status](https://github.com/convos-chat/convos/actions/workflows/docker.yml/badge.svg)](https://github.com/convos-chat/convos/actions/workflows/docker.yml)
[![Build Status](https://github.com/convos-chat/convos/actions/workflows/linux.yml/badge.svg)](https://github.com/convos-chat/convos/actions/workflows/linux.yml)
[![GitHub issues](https://img.shields.io/github/issues/convos-chat/convos)](https://github.com/convos-chat/convos/issues)

# Convos - Multiuser chat application

Convos is a multiuser chat application that runs in your web browser.

This repo contains files that is used to build the
[convos.chat](https://convos.chat/) website.

## How to make changes

```
# Convos has a CMS that is used to render the website
git clone git@github.com:convos-chat/convos
./convos/script/convos daemon

# This environment variable should be displayed when starting "convos daemon"
export CONVOS_HOME="$HOME/.local/share/convos/";

# Clone the website
git clone git@github.com:convos-chat/www.convos.chat $CONVOS_HOME/content

# Make changes
cd $CONVOS_HOME/content
$EDITOR index.md
git commit -a -m "made some changes"
git push origin main
```
