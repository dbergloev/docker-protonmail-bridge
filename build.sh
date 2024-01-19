#!/bin/bash

set -ex

# Clone from github
git clone https://github.com/ProtonMail/proton-bridge.git
cd proton-bridge
git checkout v3.8.1

# Build package
make build-nogui

