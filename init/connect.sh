#!/bin/bash

# Set the XDG standard variable to match the old style.
# This is used by Protonmail Bridge
export XDG_DATA_HOME=$HOME

# Setup default password manager for the bridge
if ! gpg --list-keys | grep -q ' ProtonBridge'; then
	echo "Initializing key store"

gpg --armor --batch --gen-key <<EOF
%no-protection
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 2048
Name-Real: ProtonBridge
Expire-Date: 0
%commit
%echo done
EOF

	pass init 'ProtonBridge'
fi

# Launch the bridge in a screen process. 
# This will keep it running as well as allow one to access the CLI
echo "Launching bridge service"
screen -S protonmail -dm /protonmail/proton-bridge --cli --no-window

