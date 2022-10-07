#!/bin/bash

pushd /home/pi/Eyesy
./start_python_foreground.sh -device default:CARD=CODEC -rate 44100
popd
