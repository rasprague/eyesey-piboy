#/bin/bash
echo Starting Eyesy Web Services

sudo systemctl start eyesy-web.service
sudo systemctl start eyesy-web-socket.service
