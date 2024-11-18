#!/usr/bin/env nix-shell
#!nix-shell -i sh -p mpc-cli gawk gnugrep

while true; do
  MPC_OUTPUT=$(mpc --format '[[%artist% - ]%title%]|[%file%]')

  TITLE=$(head -n 1 <<<"$MPC_OUTPUT")

  if [ ${#TITLE} -gt 60 ]; then
    TITLE=$(awk '{print substr($0,0,57) "..."}' <<<"$TITLE")
  fi

  LINE2=$(head -n 2 <<<"$MPC_OUTPUT" | tail -n 1)

  PLAY_STATUS_RAW=$(awk '{print $1}' <<<"$LINE2")

  if [ "$PLAY_STATUS_RAW" == "[playing]" ]; then
    PLAY_STATUS="▶"
  elif [ "$PLAY_STATUS_RAW" == "[paused]" ]; then
    PLAY_STATUS="⏸"
  else
    PLAY_STATUS="??"
  fi

  TIME=$(awk '{print $3}' <<<"$LINE2")

  echo -e "$PLAY_STATUS $TITLE | [$TIME]"
  sleep 1
done
