#!/bin/bash
start-stop-daemon --start --pidfile ~/xvfb.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset

let p=80
while [ ${p} -lt 3000 ]
 do
    if nc -z localhost ${p}; then
        let p+=1
    else
        let port=p
        break
    fi
 done
 echo The port is ${port}

if ${port}; then
    timeout 15 bash -c "until echo > /dev/tcp/localhost/${port}; do sleep 0.5; done"
else
    exit 1
fi

export DISPLAY=:${port}.0

cd /data
node /usr/src/app/ -p 80 "$@"
