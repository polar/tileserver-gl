#!/bin/bash

# Find an open port
let p=99
while [ ${p} -lt 3000 ]
 do
    if nc -z localhost ${p}; then
        let p+=1
    else
        let port=p
        break
    fi
 done

let timeout=20

if [ "${port}" != "" ]; then
    echo "The display port will be ${port}."
    start-stop-daemon --start --pidfile ~/xvfb.pid --make-pidfile --background \
        --exec /usr/bin/Xvfb -- :${port} -screen 0 1024x768x24 \
        -ac +extension GLX +render -noreset

    # Wait to be able to connect to the port. This will exit if it cannot in 15 minutes.
    timeout ${timeout} bash -c "while ! nc -z localhost ${port}; do sleep 0.5; done"
    if [ $? -eq 0 ]; then
        export DISPLAY=:${port}.0

        cd /data
        node /usr/src/app/ -p 80 "$@"
    else
      echo "Could not connect to display port ${port} in ${timeout} seconds time."
    fi
else
    echo "Could not get a display port."
    exit 1
fi
