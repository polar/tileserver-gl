#!/bin/bash

function LOG {
    echo $(date -R): $0: $*
}

# Two minutes should be enough.
timeout=120

displayNumber=1
screenNumber=0
export DISPLAY=:${displayNumber}.${screenNumber}

LOG "Starting Xvfb on ${DISPLAY}"
    start-stop-daemon --start --pidfile ~/xvfb.pid --make-pidfile --background \
        --exec /usr/bin/Xvfb -- :${displayNumber} -screen ${screenNumber} 1024x768x24 \
        -ac +extension GLX +render -noreset

LOG "Waiting to be able to connect to display at ${DISPLAY} for ${timeout} seconds time."

# Wait to be able to connect to the port. This will exit if it cannot in 15 minutes.
timeout ${timeout} bash -c "while  ! xdpyinfo; do sleep 0.5; done"
if [ $? -eq 0 ]; then
    LOG "Display ${DISPLAY} is up."
    LOG "Starting tileserver"
    cd /data
    node /usr/src/app/ -p 80 "$@"
else
  LOG "Could not connect to display port ${DSIPLAY} in ${timeout} seconds time."
fi
