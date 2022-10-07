#!/bin/bash
DEVICE="default:CARD=CODEC"
RATE=44100

pushd /home/pi/Eyesy
./start_python_foreground.sh -device $DEVICE -rate $RATE
popd
