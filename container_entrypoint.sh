#!/bin/bash

# The "single process running in this container.  Runs the VNC server in the background, as well as chrome.  Chrome's
# remote debugging only listens on localhost, so we use socat to divert from 9222 to 9999.  Outside the container, we
# can specify a different port.

_atexit() {
    kill -TERM $socatpid
    kill -TERM $chromepid
    kill -TERM $vncpid
}

trap _atexit SIGTERM SIGINT

socat TCP-LISTEN:9222,fork,reuseaddr TCP:localhost:9999 &
socatpid=$!

/usr/bin/Xtigervnc :0 \
		   -SecurityTypes None \
		   -geometry ${GEOMETRY} \
		   -AcceptSetDesktopSize=1 \
		   -AlwaysShared \
		   -FrameRate 30 \
		   -RawKeyboard \
		   -nolisten unix &
vncpid=$!

gwidth=$(echo ${GEOMETRY} | cut -d 'x' -f 1)
gheight=$(echo ${GEOMETRY} | cut -d 'x' -f 2)

export DISPLAY=:0

/usr/bin/google-chrome \
    $FULLSCREEN \
    --disable-default-apps \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-setuid-sandbox \
    --disable-sync \
    --disable-application-cache \
    --disable-infobars \
    --disable-translate \
    --disable-web-security \
    --hide-scrollbars \
    --ignore-certificate-errors \
    --no-first-run \
    --no-sandbox \
    --no-zygote \
    --user-data-dir=/data \
    --test-type \
    --window-position=0,0 \
    --window-size=${gwidth},${gheight} \
    --remote-debugging-port=9999 &

chromepid=$!

wait $socatpid
wait $chromepid
wait $vncpid
