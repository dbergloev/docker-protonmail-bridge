#!/bin/bash

echo "Launching Protonmail Bridge at $(date +'%Y-%m-%d %H:%M')"

# Change docker user/group ids
echo "Fixing docker user UID and GID"
usermod -u $PUID docker_user >/dev/null 2>&1
groupmod -g $PGID docker_group >/dev/null 2>&1
chown -R docker_user:docker_group /config >/dev/null 2>&1

# Protonmail Bridge does not use default ports. 
# Also it only listens to localhost/127.0.0.1 so 
# have to redirect. 
echo "Start redirecting port 25 and 143 to the bridge"
socat TCP-LISTEN:25,fork TCP:127.0.0.1:1025 >/dev/null 2>&1 &
socat TCP-LISTEN:143,fork TCP:127.0.0.1:1143 >/dev/null 2>&1 &

# Launch the service
su -g docker_group - docker_user -c "/opt/init/connect.sh" >/proc/1/fd/1 2>/proc/1/fd/2

# Keep this running
trap : TERM INT; sleep infinity & echo $! > /var/run/init.pid; wait

