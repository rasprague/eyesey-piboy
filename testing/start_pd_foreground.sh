#!/bin/bash

pushd /home/pi/Eyesy
/usr/bin/pd -alsamidi -mididev 1 -noaudio -path /home/pi/Eyesy/pd/externals pd/main.pd
popd
