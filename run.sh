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

if ${port}; then
    echo The display port will be ${port}
    start-stop-daemon --start --pidfile ~/xvfb.pid --make-pidfile --background \
        --exec /usr/bin/Xvfb -- :${port} -screen 0 1024x768x24 \
        -ac +extension GLX +render -noreset

    # Wait to be able to connect to the port. This will exit if it cannot in 15 minutes.
    timeout 15 bash -c "until echo > /dev/tcp/localhost/${port}; do sleep 0.5; done"
    export DISPLAY=:${port}.0

    cd /data
    node /usr/src/app/ -p 80 "$@"
else
    echo "Could get a display port ${port}."
    exit 1
fi
