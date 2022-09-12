#!/bin/sh

function up() {
    until tailscale up --authkey=$AUTH_KEY --advertise-exit-node --hostname=$HOSTNAME
    do
        sleep 1
    done
}

# send this function into the background
up &
exec tailscaled --tun=userspace-networking --state=$STATE