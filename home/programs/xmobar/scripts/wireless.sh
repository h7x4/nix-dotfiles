#!/bin/sh

NETWORK_CARD=$(ip -br link | grep UP | grep -v lo | head -n 1 | awk '{print $1}')

iwconfig $NETWORK_CARD 2>&1 | grep -q no\ wireless\ extensions\. && {
  echo wired
  exit 0
}

essid=`iwconfig $NETWORK_CARD | awk -F '"' '/ESSID/ {print $2}'`
stngth=`iwconfig $NETWORK_CARD | awk -F '=' '/Quality/ {print $2}' | cut -d '/' -f 1`
bars=`expr $stngth / 20`

case $bars in
#  0)  bar='[-----]' ;;
#  1)  bar='[/----]' ;;
#  2)  bar='[//---]' ;;
#  3)  bar='[///--]' ;;
#  4)  bar='[////-]' ;;
#  5)  bar='[/////]' ;;
#  *)  bar='[--!--]' ;;
  0)  bar='[<fn=1>〇</fn>]' ;;
  1)  bar='[<fn=1>壱</fn>]' ;;
  2)  bar='[<fn=1>弐</fn>]' ;;
  3)  bar='[<fn=1>参</fn>]' ;;
  4)  bar='[<fn=1>肆</fn>]' ;;
  5)  bar='[<fn=1>伍</fn>]' ;;
  *)  bar='[<fn=1>無</fn>]' ;;
esac

echo "$essid $bar"

exit 0
