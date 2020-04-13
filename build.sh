#!/bin/bash

#export PRESERVE_CONTAINER=1 # inspect failed build
export CONTINUE=1            # faster rebuilds

source config                # IMG_NAME variable

# copy sources, symlinks don't work
cp config pi-gen/
cp -r organellem pi-gen/

cd pi-gen                 # have to do build in pi-gen directory
rm -f stage2/EXPORT_NOOBS # don't build NOOBS image

./build-docker.sh         # build with docker image

[[ $? -eq 0 ]] && \       # flashing instructions
    echo "write sd card with:" \
    "gunzip --stdout pi-gen/deploy/image_$(date --iso-8601)-$IMG_NAME-lite.zip" \
    "| sudo dd bs=4M status=progress of=/path/to/sdcard"
