# Organelle M pi-gen

Build a rootfs image for the Critter and Guitari Organelle M using the Raspbian pi-gen tool.

The `build.sh` script and `config` file will automate the process of preparing a compressed image ready to be unzipped and flashed to a micro SD card.

The pi-gen tool will build the current release of Raspbian. Presently, this is Buster.

## Requirements

`git`, `docker`, and the dependencies listed in [pi-gen](https://github.com/RPi-Distro/pi-gen#dependencies).

## To Use

Do `git submodule update --init` to populate the `pi-gen` submodule directory.

The default `build.sh` script uses a Debian Buster docker image. If you have a Debian host OS and do not want to use docker, edit `bulid.sh`.

This script builds from the master branch of [Organelle_OS](https://github.com/critterandguitari/Organelle_OS), [Organelle_Patches](https://github.com/critterandguitari/Organelle_Patches), and [Organelle_Test_Patches](https://github.com/critterandguitari/Organelle_Test_Patches). Edit `organellem/00-organellem/01-run.sh` to change the upstream locations.

Run `build.sh`. Some time later a 900 MB zip file will be in the `pi-gen/deploy` directory. Flash this to a micro SD card via `gunzip --stdout pi-gen/deploy/image_*-organellem-lite.zip | sudo dd bs=4M status=progress of=/path/to/sdcard`. The first boot will be a little long. The Organelle M will setup systemd units, create the `/sdcard` partition, copy the `Patches` directory, and setup the filesystem. Reboot and you should have a speedy and functional Organelle M running an up-to-date distro.
