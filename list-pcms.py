#!/usr/bin/env python

import argparse
import alsaaudio

parser = argparse.ArgumentParser()
parser.add_argument("-a", "--all", type=bool, dest='listall', default=False, const=True, nargs='?')
args = parser.parse_args()

cards = alsaaudio.pcms(alsaaudio.PCM_CAPTURE)
for card in cards:
    if args.listall or card.startswith("default"):
        print(card)
    
