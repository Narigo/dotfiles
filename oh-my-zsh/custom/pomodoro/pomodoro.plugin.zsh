# Adds a pomodoro timer
POMODORO_TIME=25
POMODORO_BREAK=5

pomodoro () {
  while true; do
    echo -n ' WORK Pomodoro until ' && date -v+$((${POMODORO_TIME}))M '+%H:%M:%S';
    osascript -e 'display notification "WORK Pomodoro until '$(date -v+$((${POMODORO_TIME}))M '+%H:%M:%S')'" with title "POMODORO" sound name "default"';
    sleep $(($POMODORO_TIME*60))
    echo -n 'BREAK time until ' && date -v+$((${POMODORO_BREAK}))M '+%H:%M:%S';
    osascript -e 'display notification "BREAK time until '$(date -v+$((${POMODORO_BREAK}))M '+%H:%M:%S')'" with title "BREAK TIME" sound name "default"';
    sleep $(($POMODORO_BREAK*60))
  done
};
