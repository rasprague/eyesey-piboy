#!/bin/bash

pushd /home/pi/Eyesy/engines/python
python -u main.py -device dummy -doublebuffer 0 -rate 0
popd
