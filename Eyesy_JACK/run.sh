#/bin/bash

# make sure the log file exists
touch /tmp/video.log

sleep 4

echo Starting Eyesy
systemctl start eyesy_norns-python.service
systemctl start eyesy-web.service
systemctl start eyesy-web-socket.service
systemctl start eyesy-pd.service          # Deactivated to let norns take over the hardware
