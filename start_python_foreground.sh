#!/bin/bash

DEVICE="default"
RATE=44100
PERIOD=1024
DOUBLEBUF=1
REMOTECONTROL_CLIENT="None" # value stores the server hostname thus client should connect to
CONTROLLER_MAPPING="dummy"
REMOTECONTROL_SERVER=0

EYESY_PYTHON_PID=0
CONTROLLER_OSC_PID=0
ARGS=$@

function usage()
{
    echo "Start Eyesy Python Video in the foreground"
    echo "  also start controller-to-osc mapping script"
    echo "Usage $0"
    echo "  options:"
    echo "    [ -d | --device ] <D> - use audio device D, defaults to 'default'"
    echo "      (see output from list-pcms.py)"
    echo "    [ -r | --rate ] <R> - use R sample rate, defaults to 44100"
    echo "    [ -p | --period ] <P> - use P period, defaults to 1024"
    echo "    [ -b | --doublebuffer <0|1> - 0 to disable double-buffering, 1 to enable double-buffering, defaults to 1"
    echo "    [ -c | --remotecontrol-client <H> - act as a remote-control client, send keep-alive packets to server host H"
    echo "    [ -m | --controller-mapping <M> - use controller mapping python file M, defaults is 'mapping.py'"
    echo "    [ -s | --remotecontrol-server - act as a remote-control server, turn on keep-alive listening for controller"
    echo "    [ -h | --help ] show this helpful message"
}

function parseargs()
{
    OPTIONS=$(getopt -o d:r:p:b:c:m:sh --long device:,rate:,double-buffer:,period:,double-buffer:,remotecontrol-client:,controller-mapping:,remotecontrol-server,help -- $ARGS)
    if [ $? -ne 0 ]; then
	usage
	exit 1
    fi

    eval set -- "$OPTIONS"

    while true; do
	case "$1" in
	    -d|--device)
		DEVICE=$2 ; shift 2 ;;
	    -r|--rate)
		RATE=$2 ; shift 2 ;;
	    -p|--period)
		PERIOD=$2 ; shift 2 ;;
	    -b|--double-buffer)
		DOUBLEBUF=$2 ; shift 2 ;;
	    -c|--remotecontrol-client)
		REMOTECONTROL_CLIENT=$2 ; shift 2 ;;
	    -m|--controller-mapping)
		CONTROLLER_MAPPING=$2 ; shift 2 ;;
	    -s|--remotecontrol-server)
		REMOTECONTROL_SERVER=1 ; shift ;;
	    -h|--help)
		usage ; shift ; exit 0 ;;
	    --)
		shift ; break ;;
	esac
    done
}

function startup()
{
    sudo systemctl start eyesy-web.service
    sudo systemctl start eyesy-web-socket.service
    sudo systemctl start eyesy-pd.service

    if [ $CONTROLLER_MAPPING != "dummy" ]; then
        cd /home/pi/Eyesy/controller
        ./controller-osc.py --remotecontrolserver $REMOTECONTROL_SERVER $CONTROLLER_MAPPING &
        CONTROLLER_OSC_PID=$!
        echo "CONTROLLER_OSC_PID=$CONTROLLER_OSC_PID"
    fi

    cd /home/pi/Eyesy/engines/python
    python -u main.py -device $DEVICE -doublebuffer $DOUBLEBUF -rate $RATE -period $PERIOD -remotecontrolclient $REMOTECONTROL_CLIENT &
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

# here we go
trap cleanup EXIT SIGHUP SIGTERM

exec > >(tee /tmp/video.log) 2>&1
parseargs
startup
while ps -p $EYESY_PYTHON_PID > /dev/null; do
    sleep 1
done
cleanup
