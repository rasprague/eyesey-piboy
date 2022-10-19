#!/bin/bash
DEVICE="default"
RATE=44100
CONTROLLER_MAPPING="gamehat-mapping.py"

pushd /home/pi/Eyesy
./start_python_foreground.sh --device $DEVICE --rate $RATE --controller-mapping $CONTROLLER_MAPPING
popd
