#!/bin/bash

if ! su docker_user -c 'screen -list' | grep -q protonmail; then
	echo "Health check failed at $(date +'%Y-%m-%d %H:%M')" >/proc/1/fd/2
	su -g docker_group - docker_user -c "/opt/init/connect.sh" >/proc/1/fd/1 2>/proc/1/fd/2
	
	sleep 5
	
	if ! su docker_user -c 'screen -list' | grep -q protonmail; then
		exit 1
	fi
fi

exit 0

