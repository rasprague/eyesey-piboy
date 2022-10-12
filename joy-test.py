#!/usr/bin/env python

import liblo
import pygame
from pygame.locals import *
import os

joysticks = None

def setupPygame():
    global joysticks

    # a pretend video
    os.environ["SDL_VIDEODRIVER"] = "dummy"
    pygame.init()
    pygame.display.set_mode((1,1))

    # setup joystick
    pygame.joystick.init()
    joysticks = [pygame.joystick.Joystick(x) for x in range(pygame.joystick.get_count())]
    for j in joysticks:
        j.init()
                                                    
def main():
    global joysticks
    print("go ahead, press some buttons")
    setupPygame()

    run = True
    try:
        while run:
            for event in pygame.event.get():
                joy = joysticks[event.joy]
                if event.type == JOYAXISMOTION:
                    print("AXIS", event.joy, event.axis, joy.get_axis(event.axis))
                elif event.type == JOYHATMOTION:
                    print("HAT", event.joy, event.hat, joy.get_hat(event.hat))
                elif event.type == JOYBALLMOTION:
                    print("BALL", event.joy, event.ball, joy.get_ball(event.ball))
                elif event.type == JOYBUTTONDOWN:
                    print("BUTTONDOWN", event.joy, event.button)
                elif event.type== JOYBUTTONUP:
                    print("BUTTONUP", event.joy, event.button)
                else:
                    print("EVENT", event)
    except KeyboardInterrupt:
        run = False

if __name__ == "__main__":
    main()
