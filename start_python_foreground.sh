#!/bin/bash

EYESY_PYTHON_PID=0
CONTROLLER_OSC_PID=0
ARGS=$@

function startup()
{
    sudo systemctl start eyesy-web.service
    sudo systemctl start eyesy-web-socket.service
    sudo systemctl start eyesy-pd.service

    cd /home/pi/Eyesy
    ./controller-osc.py &
    CONTROLLER_OSC_PID=$!
    echo "CONTROLLER_OSC_PID=$CONTROLLER_OSC_PID"

    cd /home/pi/Eyesy/engines/python
    python -u main.py $ARGS &
    EYESY_PYTHON_PID=$!
    echo "EYESY_PYTHON_PID=$EYESY_PYTHON_PID"

}

function cleanup()
{
    kill $EYESY_PYTHON_PID
    kill $CONTROLLER_OSC_PID
    sudo systemctl stop eyesy-pd.service
    sudo systemctl stop eyesy-web-socket.service
    sudo systemctl stop eyesy-web.service
    exit
}

trap cleanup EXIT
exec > >(tee /tmp/video.log) 2>&1
startup
while ps -p $EYESY_PYTHON_PID > /dev/null; do
    sleep 1
done
cleanup
