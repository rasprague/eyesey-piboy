#!/bin/bash
#amixer cset numid=11 off

sudo systemctl start eyesy-python.service
sudo systemctl start eyesy-web.service
sudo systemctl start eyesy-web-socket.service
sudo systemctl start eyesy-pd.service

