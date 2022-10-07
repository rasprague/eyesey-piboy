#!/bin/bash
#amixer cset numid=11 off

sudo systemctl stop eyesy-python.service
sudo systemctl stop eyesy-web.service
sudo systemctl stop eyesy-web-socket.service
sudo systemctl stop eyesy-pd.service

