#!/usr/bin/env nix-shell
#!nix-shell -i bash -p dbus

printState() {
  STATUS=$(dbus-send --session --print-reply=literal --dest='org.fcitx.Fcitx5' '/controller' 'org.fcitx.Fcitx.Controller1.CurrentInputMethod' | tr -d '[:space:]')

  case $STATUS in
    keyboard-us)
      echo 'US'
    ;;
    keyboard-no)
      echo 'NO'
    ;;
    mozc)
      echo '日本語'
    ;;
    *)
      echo "$STATUS?"
    ;;
  esac
}

while :; do
  printState
  sleep 1
done
