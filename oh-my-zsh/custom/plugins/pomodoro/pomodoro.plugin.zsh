# Pomodoro timer with background process and macOS notifications

POMODORO_WORK=25
POMODORO_SHORT_BREAK=5
POMODORO_LONG_BREAK=15
POMODORO_LONG_BREAK_AFTER=3
POMODORO_PID_FILE="/tmp/pomodoro.pid"
POMODORO_STATE_FILE="/tmp/pomodoro.state"

pomodoro() {
  case "${1:-start}" in
    start)
      if [ -f "$POMODORO_PID_FILE" ] && kill -0 $(cat "$POMODORO_PID_FILE") 2>/dev/null; then
        echo "Pomodoro läuft bereits — starte neu..."
        kill $(cat "$POMODORO_PID_FILE") 2>/dev/null
        sleep 1
      fi
      # Apply optional overrides: pomodoro start [work] [short_break] [long_break] [long_break_after]
      POMODORO_WORK=${2:-$POMODORO_WORK}
      POMODORO_SHORT_BREAK=${3:-$POMODORO_SHORT_BREAK}
      POMODORO_LONG_BREAK=${4:-$POMODORO_LONG_BREAK}
      POMODORO_LONG_BREAK_AFTER=${5:-$POMODORO_LONG_BREAK_AFTER}
      rm -f "$POMODORO_PID_FILE" "$POMODORO_STATE_FILE"
      _pomodoro_loop &!
      echo $! > "$POMODORO_PID_FILE"
      echo "Pomodoro gestartet (Runde 1, ${POMODORO_WORK}min bis $(date -v+${POMODORO_WORK}M '+%H:%M'))"
      echo "  Work: ${POMODORO_WORK}min | Short break: ${POMODORO_SHORT_BREAK}min | Long break: ${POMODORO_LONG_BREAK}min (every ${POMODORO_LONG_BREAK_AFTER} rounds)"
      echo "  pomodoro status  — Status anzeigen"
      echo "  pomodoro stop    — Beenden"
      ;;
    stop)
      if [ -f "$POMODORO_PID_FILE" ] && kill -0 $(cat "$POMODORO_PID_FILE") 2>/dev/null; then
        kill $(cat "$POMODORO_PID_FILE") 2>/dev/null
        echo "Pomodoro gestoppt"
      else
        echo "Kein Pomodoro aktiv"
      fi
      rm -f "$POMODORO_PID_FILE" "$POMODORO_STATE_FILE"
      ;;
    status)
      if [ ! -f "$POMODORO_STATE_FILE" ]; then
        echo "Kein Pomodoro aktiv"
        return 1
      fi
      local phase=$(sed -n '1p' "$POMODORO_STATE_FILE")
      local round=$(sed -n '2p' "$POMODORO_STATE_FILE")
      local end_ts=$(sed -n '3p' "$POMODORO_STATE_FILE")
      local work=$(sed -n '4p' "$POMODORO_STATE_FILE")
      local short_break=$(sed -n '5p' "$POMODORO_STATE_FILE")
      local long_break=$(sed -n '6p' "$POMODORO_STATE_FILE")
      local long_break_after=$(sed -n '7p' "$POMODORO_STATE_FILE")
      local now=$EPOCHSECONDS
      local remaining_secs=$(( end_ts - now ))
      if (( remaining_secs < 0 )); then remaining_secs=0; fi
      local mins=$(( remaining_secs / 60 ))
      local secs=$(( remaining_secs % 60 ))
      echo "Runde $round — $phase — noch ${mins}m ${secs}s (bis $(date -r "$end_ts" '+%H:%M:%S'))"
      echo "  Work: ${work}min | Short break: ${short_break}min | Long break: ${long_break}min (every ${long_break_after} rounds)"
      ;;
    *)
      echo "Usage: pomodoro [start|stop|status]"
      echo "       pomodoro start [work_min] [short_break_min] [long_break_min] [long_break_every_n]"
      ;;
  esac
}

_pomodoro_write_state() {
  local phase="$1" round="$2" end_ts="$3"
  cat > "$POMODORO_STATE_FILE" <<EOF
$phase
$round
$end_ts
$POMODORO_WORK
$POMODORO_SHORT_BREAK
$POMODORO_LONG_BREAK
$POMODORO_LONG_BREAK_AFTER
EOF
}

_pomodoro_notify() {
  local title="$1" message="$2"
  osascript -e "display notification \"$message\" with title \"$title\" sound name \"default\""
}

_pomodoro_wait_until() {
  local end_ts="$1"
  caffeinate -i -t $(( end_ts - EPOCHSECONDS )) &
  local cafe_pid=$!
  while (( EPOCHSECONDS < end_ts )); do sleep 30; done
  kill $cafe_pid 2>/dev/null
}

_pomodoro_loop() {
  local round=0
  while true; do
    round=$((round + 1))

    # Work phase
    local work_end=$((EPOCHSECONDS + POMODORO_WORK * 60))
    _pomodoro_write_state "WORK" "$round" "$work_end"

    _pomodoro_notify "POMODORO Runde $round" "Arbeiten bis $(date -r "$work_end" '+%H:%M')"
    _pomodoro_wait_until "$work_end"

    # Break phase
    local pause
    if (( round % POMODORO_LONG_BREAK_AFTER == 0 )); then
      pause=$POMODORO_LONG_BREAK
    else
      pause=$POMODORO_SHORT_BREAK
    fi
    local break_end=$((EPOCHSECONDS + pause * 60))
    _pomodoro_write_state "BREAK" "$round" "$break_end"

    _pomodoro_notify "PAUSE" "${pause}min Pause bis $(date -r "$break_end" '+%H:%M')"
    _pomodoro_wait_until "$break_end"

    _pomodoro_notify "WEITER GEHTS!" "Runde $((round + 1)) startet"
  done
}
