#!/bin/bash
start-stop-daemon --start --pidfile ~/xvfb.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset

timeout 15 bash -c 'until echo > /dev/tcp/localhost/99; do sleep 0.5; done'

export DISPLAY=:99.0

cd /data
node /usr/src/app/ -p 80 "$@"
