#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

KEYDIR='/var/keys/gitlab'

umask u=rwx,g=,o=

mkdir -p $KEYDIR
chmod 755 '/var/keys'

for FILE in secretFile dbFile otpFile pages_secret; do
  tr -dc A-Za-z0-9 < /dev/random | head -c 128 > $KEYDIR/$FILE
done

nix-shell -p openssl --run "openssl genrsa 2048 > $KEYDIR/jwsFile"
chmod 600 $KEYDIR/jwsFile

read -s -p "Root password: " ROOTPASS
echo $ROOTPASS > $KEYDIR/root_password

chown -R git:git $KEYDIR
