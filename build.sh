#!/bin/bash

#export PRESERVE_CONTAINER=1 # inspect failed build
export CONTINUE=1            # faster rebuilds

# copy sources, symlinks don't work
cp config pi-gen/
cp -r organellem pi-gen/

cd pi-gen                 # have to do build in pi-gen directory
rm -f stage2/EXPORT_NOOBS # don't build NOOBS image

./build-docker.sh         # build with docker image

if [[ $? -eq 0 ]]; then    # sd card flashing instructions
    echo "write sd card with:" \
    "gunzip --stdout pi-gen/$(ls deploy/*.zip) | " \
    "sudo dd bs=4M status=progress of=/path/to/sdcard"
fi
