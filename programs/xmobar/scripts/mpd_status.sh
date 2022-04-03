MPD_STATUS=$(mpc 2>/dev/null | sed -n '2{p;q}' | cut -d ' ' -f1)
case "$MPD_STATUS" in
  "[playing]")
    echo "<fn=2><fc=#00ff00>▶</fc></fn>"
    # echo "[<fn=2><fc=#00ff00>行</fc></fn>]"
    exit 0
    ;;
  "[paused]")
    echo "<fn=2><fc=#ff0000>⏸</fc></fn>"
    # echo "[<fn=1><fc=#ff0000>止</fc></fn>]"
    exit 0
    ;;
  *)
    echo "<fn=2><fc=#AA0000>⏼</fc></fn>"
    # echo "[<fn=1><fc=#AA0000>無</fc></fn>]"
    exit 0
    ;;
esac
