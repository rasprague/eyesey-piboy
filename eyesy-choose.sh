#!/bin/bash

function joy2key_start {
    echo "Starting joy2key . . ."
    /opt/retropie/admin/joy2key/joy2key start
}

function joy2key_stop {
    echo "Stopping joy2key . . ."
    /opt/retropie/admin/joy2key/joy2key stop
}

trap joy2key_stop EXIT

CARDCMD="dialog --stdout --title \"Eyesy\" --menu \"Choose an Audio Interface\" 20 80 20"
RATECMD="dialog --stdout --title \"Eyesy\" --menu \"Choose a Sample Rate\" 10 30 20 0 44.1kHz 1 48kHz"
MAPPINGCMD="dialog --stdout --title \"Eyesy\" --menu \"Choose a game controller mapping\" 20 80 20"
DOUBLEBUFCMD="dialog --stdout --title \"Eyesy\" --yesno \"Enable Double Buffering??\" 6 30"

CARDLIST=""
MAPPINGLIST=""

I=0
pushd /home/pi/code/eyesy-piboy
OUTPUT=$(./list-pcms.py -a | sort)
IFS=$'\n' CARDS=($OUTPUT)
while read line; do
    CARDLIST="$CARDLIST $I \"$line\""
    ((I=I+1))
done <<< "$OUTPUT"
popd

I=0
pushd /home/pi/code/eyesy-piboy/controller
OUTPUT=$(ls *mapping.py)
IFS=$'\n' MAPPINGS=($OUTPUT)
while read line; do
    MAPPINGLIST="$MAPPINGLIST $I \"$line\""
    ((I=I+1))
done <<< "$OUTPUT"
popd

joy2key_start

CARD=$(eval $CARDCMD $CARDLIST)
[ $? != 0 ] && echo "Cancelled." && exit 1
DEVICE=${CARDS[$CARD]}

RATE=$(eval $RATECMD)
[ $? != 0 ] && echo "Cancelled." && exit 1
if [ $RATE = 0 ]; then
    RATE=44100
elif [ $RATE = 1 ]; then
    RATE=48000
fi

DOUBLEBUF=1
eval $DOUBLEBUFCMD
case $? in
    # yes
    0) DOUBLEBUF=1 ;;
    # no
    1) DOUBLEBUF=0 ;;
    # [ESC]
    255) echo "Cancelled." ; exit 1 ;;
esac

MAPPING=$(eval $MAPPINGCMD $MAPPINGLIST)
[ $? != 0 ] && echo "Cancelled." && exit 1
CONTROLLER_MAPPING=${MAPPINGS[$MAPPING]}

joy2key_stop

pushd /home/pi/Eyesy
./start_python_foreground.sh --device $DEVICE --rate $RATE --double-buffer $DOUBLEBUF --controller-mapping $CONTROLLER_MAPPING
popd
