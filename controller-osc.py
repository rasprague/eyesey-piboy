#!/usr/bin/env python

import liblo
import pygame
from pygame.locals import *
import os
import signal

# tuning constants
SMALL_INC = 5
BIG_INC = 10
GAIN_SMALL_INC = 0.001
GAIN_BIG_INC = 0.01

knobs = [512] * 6 # one extra so I can use 1-based index
gain = 1.0
trigger_source = 1
midi_channel = 1
osc_target = None
osc_server = None
joysticks = None
run = True
shift_state = False

# PiBoy DMG button constants
BUTTON_A = 0
BUTTON_B = 1
BUTTON_C = 2
BUTTON_X = 3
BUTTON_Y = 4
BUTTON_Z = 5
BUTTON_RT = 6
BUTTON_LT = 7
BUTTON_SELECT = 8
BUTTON_START = 9
BUTTON_L3 = 10
BUTTON_DOWN = 11
BUTTON_UP = 12
BUTTON_LEFT = 13
BUTTON_RIGHT = 14

## button mappings
# knobs
KNOB_1 = BUTTON_Z
KNOB_2 = BUTTON_Y
KNOB_3 = BUTTON_X
KNOB_4 = BUTTON_C
KNOB_5 = BUTTON_B
# shift knobs
KNOB_GAIN = BUTTON_Z
KNOB_TRIGGER_SOURCE = BUTTON_Y
KNOB_MIDI_CHANNEL = BUTTON_X
# keys
KEY_SHIFT = BUTTON_SELECT
KEY_MODE_SCENE = BUTTON_A
# more keys (hold start button)
KEY_SECONDARY = BUTTON_START
KEY_OSD = BUTTON_Z
KEY_PERSIST = BUTTON_X
KEY_SAVE = BUTTON_C
KEY_SCREENSHOT = BUTTON_B
KEY_TRIGGER = BUTTON_A

def clamp(val, min=0, max=1023):
    if val < min:
        return min
    if val > max:
        return max
    return val

def knob_callback(path, args, type, src, data):
    global knobs
    i = data
    knobs[i] = args[0]

def fallback(path, args, types, src):
    print("got unknown message '%s' from '%s'" % (path, src.url))
    for a, t in zip(args, types):
        print("argument of type '%s': %s" % (t, a))

def setupOscClient():
    global osc_target
    try:
        osc_target = liblo.Address(4000)
    except liblo.AddressError as err:
        print(err)

def sendOscMsg(path, args):
    global osc_target
    liblo.send(osc_target, path, args)

def setupOscServer():
    global osc_server
    try:
        osc_server = liblo.ServerThread(4001)

        # add methods for TouchOsc template
        osc_server.add_method("/knobs/1", 'f', knob_callback, 1)
        osc_server.add_method("/knobs/2", 'f', knob_callback, 2)
        osc_server.add_method("/knobs/3", 'f', knob_callback, 3)
        osc_server.add_method("/knobs/4", 'f', knob_callback, 4)
        osc_server.add_method("/knobs/5", 'f', knob_callback, 5)
        #osc_server.add_method("/key/1", 'f', skey_callback)
        #osc_server.add_method("/key/3", 'f', skey_callback)
        #osc_server.add_method("/key/4", 'f', skey_callback)
        #osc_server.add_method("/key/5", 'f', skey_callback)
        #osc_server.add_method("/key/6", 'f', skey_callback)
        #osc_server.add_method("/key/7", 'f', skey_callback)
        #osc_server.add_method("/key/8", 'f', skey_callback)
        #osc_server.add_method("/key/9", 'f', skey_callback)
        #osc_server.add_method("/key/10", 'f', skey_callback)
        osc_server.add_method(None, None, fallback)
        
        osc_server.start()
    except liblo.ServerError, err:
        print str(err)

def stopOscServer():
    osc_server.stop()

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

def stopPygame():
    pygame.joystick.quit()
    pygame.quit()

def signalHandler(signum, frame):
    global run
    run = False

def setupSignalHandler():
    signal.signal(signal.SIGINT, signalHandler)
    signal.signal(signal.SIGHUP, signalHandler)
    signal.signal(signal.SIGTERM, signalHandler)

def updateKnob(joy, i):
    global knobs
    inc = 0
    if joy.get_button(BUTTON_LEFT):
        inc = -SMALL_INC
    elif joy.get_button(BUTTON_RIGHT):
        inc = SMALL_INC
    elif joy.get_button(BUTTON_UP):
        inc = BIG_INC
    elif joy.get_button(BUTTON_DOWN):
        inc = -BIG_INC

    if inc != 0:
        knobs[i] = clamp(knobs[i]+inc)
        sendOscMsg("/knobs/%i" % i, knobs[i])

def updateGain(joy):
    global gain
    inc = 0.0
    if joy.get_button(BUTTON_LEFT):
        inc = -GAIN_SMALL_INC
    elif joy.get_button(BUTTON_RIGHT):
        inc = GAIN_SMALL_INC
    elif joy.get_button(BUTTON_UP):
        inc = GAIN_BIG_INC
    elif joy.get_button(BUTTON_DOWN):
        inc = -GAIN_BIG_INC

    if inc != 0.0:
        gain = clamp(gain+inc, 0.0, 3.0)
        sendOscMsg("/ascale", gain)

def updateTriggerSource(button):
    global trigger_source
    inc = 0
    if button == BUTTON_LEFT:
        inc = -1
    elif button == BUTTON_RIGHT:
        inc = 1
    elif button == BUTTON_UP:
        inc = 1
    elif button == BUTTON_DOWN:
        inc = -1

    if inc != 0:
        trigger_source = clamp(trigger_source+inc, 1, 6)
        sendOscMsg("/trigger_source", trigger_source)

def updateMidiChannel(button):
    global midi_channel
    inc = 0
    if button == BUTTON_LEFT:
        inc = -1
    elif button == BUTTON_RIGHT:
        inc = 1
    elif button == BUTTON_UP:
        inc = 1
    elif button == BUTTON_DOWN:
        inc = -1

    if inc != 0:
        midi_channel = clamp(midi_channel+inc, 1, 16)
        sendOscMsg("/midi_ch", midi_channel)

def get_buttons(joy, buttons):
    for b in buttons:
        if not joy.get_button(b):
            return False
    return True

def updateInput():
    global joysticks, run
    for joy in joysticks:
        if get_buttons(joy, [BUTTON_SELECT, BUTTON_B, BUTTON_DOWN]):
            sendOscMsg("/quit", None)
            run = False
        elif joy.get_button(KEY_SECONDARY):
            break
        elif shift_state:
            if joy.get_button(KNOB_GAIN):
                updateGain(joy)
        else:
            if joy.get_button(KNOB_1):
                updateKnob(joy, 1)
            elif joy.get_button(KNOB_2):
                updateKnob(joy, 2)
            elif joy.get_button(KNOB_3):
                updateKnob(joy, 3)
            elif joy.get_button(KNOB_4):
                updateKnob(joy, 4)
            elif joy.get_button(KNOB_5):
                updateKnob(joy, 5)
                         
def main():
    global run, joysticks, shift_state
    setupSignalHandler()
    setupOscClient()
    setupOscServer()
    setupPygame()

    clock = pygame.time.Clock()
    while run:
        updateInput()
        for event in pygame.event.get():
            joy = joysticks[event.joy]
            if event.type == JOYAXISMOTION:
                #print("AXIS", event.joy, event.axis)
                pass
            elif event.type == JOYHATMOTION:
                #print("HAT", event.joy, event.hat)
                pass
            elif event.type == JOYBUTTONDOWN:
                #print("BUTTONDOWN", event.joy, event.button)
                if shift_state:
                    if joy.get_button(KNOB_TRIGGER_SOURCE):
                        updateTriggerSource(event.button)
                    elif joy.get_button(KNOB_MIDI_CHANNEL):
                        updateMidiChannel(event.button)
                elif joy.get_button(KEY_SECONDARY):
                    if event.button == KEY_OSD:
                        sendOscMsg("/key/1", 1)
                    elif event.button == KEY_PERSIST:
                        sendOscMsg("/key/3", 1)
                    elif event.button == KEY_SAVE:
                        sendOscMsg("/key/8", 1)
                    elif event.button == KEY_SCREENSHOT:
                        sendOscMsg("/key/9", 1)
                    elif event.button == KEY_TRIGGER:
                        sendOscMsg("/key/10", 1)
                elif joy.get_button(KEY_MODE_SCENE):
                    if event.button == BUTTON_LEFT:
                        sendOscMsg("/key/4", 1)
                    elif event.button == BUTTON_RIGHT:
                        sendOscMsg("/key/5", 1)
                    elif event.button == BUTTON_UP:
                        sendOscMsg("/key/6", 1)
                    if event.button == BUTTON_DOWN:
                        sendOscMsg("/key/7", 1)

                if event.button == KEY_SHIFT:
                    shift_state = not shift_state
                    sendOscMsg("/shift", 1 if shift_state else 0)
            elif event.type== JOYBUTTONUP:
                #print("BUTTONUP", event.joy, event.button)
                if joy.get_button(KEY_SECONDARY):
                    if event.button == KEY_SAVE:
                        sendOscMsg("/key/8", 0)
                    elif event.button == KEY_TRIGGER:
                        sendOscMsg("/key/10", 0)
            else:
                #print("EVENT", event)
                pass
        clock.tick(60)

    stopOscServer()
    stopPygame()

if __name__ == "__main__":
    main()
