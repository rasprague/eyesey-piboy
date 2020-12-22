#!/bin/bash
export LUA_PATH="/home/pi/Eyesy/engines/oflua/?.lua;;"

# make sure log ownership is not root
sudo chown pi:pi /tmp/video.log

cd /home/pi/Eyesy/engines/oflua/eyesy
startx ./bin/eyesy -- -s off 

#stdbuf -o0 bin/eyesy &> /tmp/video.log
