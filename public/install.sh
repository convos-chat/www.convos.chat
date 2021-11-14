#!/bin/sh
REPO_URL="https://github.com/convos-chat/convos.git";
TAR_URL="https://github.com/convos-chat/convos/archive/stable.tar.gz";

cannot_install () {
  echo "";
  echo "! Cannot install Convos: $1";
  echo "";
  echo "See https://convos.chat/doc/faq#is-convos-supported-on-my-system";
  echo "for more information.";
  echo "";
  exit 1;
}

check_required_dependencies () {
  PERL_BIN=$(find_bin perl);
  [ -z "$PERL_BIN" ] && cannot_install "'perl' has to be installed.";
  MAKE_BIN=$(find_bin make);
  [ -z "$MAKE_BIN" ] && cannot_install "'make' has to be installed.";
  GCC_BIN=$(find_bin gcc);
  [ -z "$GCC_BIN" ] && cannot_install "'gcc' has to be installed.";
}

chdir_convos () {
  echo "\$ cd convos";
  cd convos || cannot_install "cd convos failed: $?";
}

find_bin () {
  which $1 2>/dev/null;
}

fetch_tar () {
  CURL_BIN=$(find_bin curl);
  TAR_BIN=$(find_bin tar);
  WGET_BIN=$(find_bin wget);

  [ -z "$TAR_BIN" ] && cannot_install "'tar' has to be installed."
  [ -z "$CURL_BIN$WGET_BIN" ] && return 3;
  [ -d convos ] || mkdir convos;

  if [ -n "$CURL_BIN" ]; then
    echo "\$ $CURL_BIN -s -L $TAR_URL | $TAR_BIN xz -C convos --strip-components 1";
    $CURL_BIN -s -L $TAR_URL | $TAR_BIN xz -C convos --strip-components 1 || cannot_install "curl + tar failed";
  else
    echo "\$ $WGET_BIN -q -O - $TAR_URL | $TAR_BIN xz -C convos --strip-components 1";
    $WGET_BIN -q -O - $TAR_URL | $TAR_BIN xz -C convos --strip-components 1 || cannot_install "wget + tar failed";
  fi

  chdir_convos;
}

git_clone () {
  GIT_BIN=$(find_bin git);
  [ -z "$GIT_BIN" ] && return 3;

  if [ -d convos ]; then
    [ ! -d convos/.git ] && return 2;
    chdir_convos;
    echo "\$ $GIT_BIN pull origin stable";
    $GIT_BIN pull origin stable;
  else
    echo "\$ $GIT_BIN clone --branch stable $REPO_URL";
    $GIT_BIN clone --branch stable $REPO_URL;
    chdir_convos;
  fi
}

[ -d convos ] && ACTION="Upgrading" || ACTION="Installing";
echo "$ACTION Convos...";

check_required_dependencies;
git_clone || fetch_tar || cannot_install "Either 'git', 'curl' or 'wget' has to be installed.";

echo "\$ $PERL_BIN script/convos install";
if $PERL_BIN script/convos install; then
  echo "Thank you for downloading Convos! Need help? Check out https://convos.chat/doc,";
  echo "or come talk to us in #convos on irc.libera.chat:6697.";
  echo "";
else
  cannot_install "Dependencies missing.";
fi
