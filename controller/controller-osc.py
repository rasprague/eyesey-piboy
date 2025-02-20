#!/usr/bin/env python

import liblo
import pygame
from pygame.locals import *
import os
import signal
import argparse
import importlib
import sys

def remove_suffix(text, suffix):
    if text.endswith(suffix):
        text = text[:-len(suffix)]
    return text

parser = argparse.ArgumentParser(description='Convert Game Controller events to Eyesy OSC messages')
parser.add_argument('mapfile', type=str, help='controller mapping file')
args = parser.parse_args()
controller = importlib.import_module(remove_suffix(args.mapfile, '.py')).controller

# tuning constants
SMALL_INC = 5
BIG_INC = 10
GAIN_SMALL_INC = 0.001
GAIN_BIG_INC = 0.01
GAIN_MAX = 10.0

knobs = [512] * 6 # one extra so I can use 1-based index
gain = 1.0
trigger_source = 1
midi_channel = 1
osc_target = None
osc_server = None
joysticks = None
run = True
shift_state = False
axis_state = [0] * 2

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

def audio_scale_callback(path, args):
    global gain
    gain = args[0]

def midi_ch_callback(path, args):
    global midi_channel
    midi_channel = args[0]

def trigger_source_callback(path, args):
    global trigger_source
    trigger_source = args[0]

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
        osc_server = liblo.ServerThread(4002)

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
        
        # original osc methods
        #osc_server.add_method("/knobs", 'iiiiii', knobs_callback)
        #osc_server.add_method("/key", 'ii', keys_callback)
        #osc_server.add_method("/mblob", 'b', mblob_callback)
        #osc_server.add_method("/midicc", 'ii', midicc_callback)
        #osc_server.add_method("/midinote", 'ii', midinote_callback)
        #osc_server.add_method("/reload", 'i', reload_callback)
        # osc_server.add_method("/new", 's', reload_callback)
        #osc_server.add_method("/set", 's', set_callback)
        #osc_server.add_method("/new", 's', new_callback)
        #osc_server.add_method("/fs", 'i', fs_callback)
        #osc_server.add_method("/shift", 'i', shift_callback)
        osc_server.add_method("/ascale", 'f', audio_scale_callback)
        #osc_server.add_method("/trig", 'i', trig_callback)
        #osc_server.add_method("/atrigen", 'i', audio_trig_enable_callback)
        #osc_server.add_method("/linkpresent", 'i', link_present_callback)
        osc_server.add_method("/midi_ch", 'i', midi_ch_callback)
        osc_server.add_method("/trigger_source", 'i', trigger_source_callback)
        #osc_server.add_method("/sline", None, shift_line_callback)
        #osc_server.add_method("/quit", None, quit_callback)

        osc_server.add_method(None, None, fallback)

        osc_server.start()
    except liblo.ServerError as  err:
        print("libloServerError:", str(err))
        raise err

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
    if get_button(joy, 'BUTTON_LEFT'):
        inc = -SMALL_INC
    elif get_button(joy, 'BUTTON_RIGHT'):
        inc = SMALL_INC
    elif get_button(joy, 'BUTTON_UP'):
        inc = BIG_INC
    elif get_button(joy, 'BUTTON_DOWN'):
        inc = -BIG_INC

    if inc != 0:
        knobs[i] = clamp(knobs[i]+inc)
        sendOscMsg("/knobs/%i" % i, knobs[i])

def updateGain(joy):
    global gain
    inc = 0.0
    if get_button(joy, 'BUTTON_LEFT'):
        inc = -GAIN_SMALL_INC
    elif get_button(joy, 'BUTTON_RIGHT'):
        inc = GAIN_SMALL_INC
    elif get_button(joy, 'BUTTON_UP'):
        inc = GAIN_BIG_INC
    elif get_button(joy, 'BUTTON_DOWN'):
        inc = -GAIN_BIG_INC

    if inc != 0.0:
        gain = clamp(gain+inc, 0.0, GAIN_MAX)
        sendOscMsg("/ascale", gain)

def updateTriggerSource(event):
    global trigger_source
    inc = 0
    if get_button_by_event(event, 'BUTTON_LEFT'):
        inc = -1
    elif get_button_by_event(event, 'BUTTON_RIGHT'):
        inc = 1
    elif get_button_by_event(event, 'BUTTON_UP'):
        inc = 1
    elif get_button_by_event(event, 'BUTTON_DOWN'):
        inc = -1

    if inc != 0:
        trigger_source = clamp(trigger_source+inc, 1, 6)
        sendOscMsg("/trigger_source", trigger_source)

def updateMidiChannel(event):
    global midi_channel
    inc = 0
    if get_button_by_event(event, 'BUTTON_LEFT'):
        inc = -1
    elif get_button_by_event(event, 'BUTTON_RIGHT'):
        inc = 1
    elif get_button_by_event(event, 'BUTTON_UP'):
        inc = 1
    elif get_button_by_event(event, 'BUTTON_DOWN'):
        inc = -1

    if inc != 0:
        midi_channel = clamp(midi_channel+inc, 1, 16)
        sendOscMsg("/midi_ch", midi_channel)

def bmap(key):
    global controller
    if key.startswith('BUTTON'):
        return controller['buttons'][key]
    else:
        b = controller['mapping'][key]
        return controller['buttons'][b]

def get_button(joy, button):
    global controller
    if button in ('BUTTON_UP', 'BUTTON_DOWN', 'BUTTON_LEFT', 'BUTTON_RIGHT'):
        r = False
        if controller['dpad']:
            r = joy.get_button(bmap(button))
        if not r and controller['hat']:
            x, y = joy.get_hat(0)
            if button == 'BUTTON_LEFT':
                r = x <= -1.0
            elif button == 'BUTTON_RIGHT':
                r = x >= 1.0
            elif button == 'BUTTON_UP':
                r = y >= 1.0
            elif button == 'BUTTON_DOWN':
                r = y <= -1.0
        if not r and controller['axis']:
            thres = controller['axis-threshold']
            if button == 'BUTTON_LEFT':
                r = joy.get_axis(0) < -thres
            elif button == 'BUTTON_RIGHT':
                r = joy.get_axis(0) > thres
            elif button == 'BUTTON_UP':
                r = joy.get_axis(1) < -thres
            elif button == 'BUTTON_DOWN':
                r = joy.get_axis(1) > thres

        return r
    else:
        return joy.get_button(bmap(button))

def get_button_by_event(event, button):
    joy = joysticks[event.joy]
    if button in ('BUTTON_UP', 'BUTTON_DOWN', 'BUTTON_LEFT', 'BUTTON_RIGHT'):
        if controller['dpad'] and event.type == JOYBUTTONDOWN:
            return event.button == bmap(button)
        elif controller['hat'] and event.type == JOYHATMOTION:
            x, y = joy.get_hat(0)
            if button == 'BUTTON_LEFT':
                return x <= -1.0
            elif button == 'BUTTON_RIGHT':
                return x >= 1.0
            elif button == 'BUTTON_UP':
                return y >= 1.0
            elif button == 'BUTTON_DOWN':
                return y <= -1.0
        elif controller['axis'] and event.type == JOYAXISMOTION:
            thres = controller['axis-threshold']
            if button == 'BUTTON_LEFT':
                return joy.get_axis(0) < -thres
            elif button == 'BUTTON_RIGHT':
                return joy.get_axis(0) > thres
            elif button == 'BUTTON_UP':
                return joy.get_axis(1) < -thres
            elif button == 'BUTTON_DOWN':
                return joy.get_axis(1) > thres
        else:
            return False
    else:
        return joy.get_button(bmap(button))
    
def get_buttons(joy, buttons):
    for b in buttons:
        if not get_button(joy, b):
            return False
    return True

def update_axis_state(axis, val):
    """
    Useful for treating analog stick as a dpad
    Returns -1 if moving stick left / up
    Returns  1 if moving stick right / down
    Returns  0 if no change or returning to center
    """
    global axis_state
    if controller['axis']:
        thresh = controller['axis-threshold']

        old_state = axis_state[axis]
        
        new_state = 0
        if val < -thresh: new_state = -1
        elif val > thresh: new_state = 1

        r = 0
        if new_state > old_state: r = 1
        elif new_state < old_state: r = -1

        axis_state[axis] = new_state

        return r
    else:
        return 0
    
def updateInput():
    global joysticks, run
    for joy in joysticks:
        if get_buttons(joy, ['BUTTON_SELECT', 'BUTTON_B', 'BUTTON_DOWN']):
            sendOscMsg("/quit", None)
            run = False
        elif get_button(joy, 'KEY_SECONDARY'):
            break
        elif shift_state:
            if get_button(joy, 'KNOB_GAIN'):
                updateGain(joy)
        else:
            if get_button(joy, 'KNOB_1'):
                updateKnob(joy, 1)
            if get_button(joy, 'KNOB_2'):
                updateKnob(joy, 2)
            if get_button(joy, 'KNOB_3'):
                updateKnob(joy, 3)
            if get_button(joy, 'KNOB_4'):
                updateKnob(joy, 4)
            if get_button(joy, 'KNOB_5'):
                updateKnob(joy, 5)
                         
def main():
    global run, joysticks, controller, shift_state

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
                if controller['axis']:
                    axis = event.axis
                    value = joy.get_axis(axis)
                    thresh = controller['axis-threshold']
                    changed = update_axis_state(axis, value) != 0
                    if shift_state:
                        if get_button(joy, 'KNOB_TRIGGER_SOURCE'):
                            if changed: updateTriggerSource(event)
                        elif get_button(joy, 'KNOB_MIDI_CHANNEL'):
                            if changed: updateMidiChannel(event)
                    elif get_button(joy, 'KNOB_MODE_SCENE'):
                        if axis == 0:
                            if value < -thresh: # left
                                if changed: sendOscMsg("/key/4", 1)
                            elif value > thresh: # right
                                if changed: sendOscMsg("/key/5", 1)
                        elif event.axis == 1:
                            if value < -thresh: # up
                                if changed: sendOscMsg("/key/6", 1)
                            elif value > thresh: # down
                                if changed: sendOscMsg("/key/7", 1)
            elif event.type == JOYHATMOTION:
                #print("HAT", event.joy, event.hat)
                if controller['hat']:
                    if shift_state:
                        if get_button(joy, 'KNOB_TRIGGER_SOURCE'):
                            updateTriggerSource(event)
                        elif get_button(joy, 'KNOB_MIDI_CHANNEL'):
                            updateMidiChannel(event)
                    elif get_button(joy, 'KNOB_MODE_SCENE'):
                        hat = event.hat
                        x, y = joy.get_hat(hat)
                        if x <= -1.0: # left
                            sendOscMsg("/key/4", 1)
                        elif x >= 1.0: # right
                            sendOscMsg("/key/5", 1)
                        elif y >= 1.0: # up
                            sendOscMsg("/key/6", 1)
                        elif y <= -1.0: # down
                            sendOscMsg("/key/7", 1)
                    pass
            elif event.type == JOYBUTTONDOWN:
                #print("BUTTONDOWN", event.joy, event.button)
                if shift_state:
                    if get_button(joy, 'KNOB_TRIGGER_SOURCE'):
                        updateTriggerSource(event)
                    elif get_button(joy, 'KNOB_MIDI_CHANNEL'):
                        updateMidiChannel(event)
                elif get_button(joy, 'KEY_SECONDARY'):
                    if event.button == bmap('KEY_OSD'):
                        sendOscMsg("/key/1", 1)
                    elif event.button == bmap('KEY_PERSIST'):
                        sendOscMsg("/key/3", 1)
                    elif event.button == bmap('KEY_SAVE'):
                        sendOscMsg("/key/8", 1)
                    elif event.button == bmap('KEY_SCREENSHOT'):
                        sendOscMsg("/key/9", 1)
                    elif event.button == bmap('KEY_TRIGGER'):
                        sendOscMsg("/key/10", 1)
                elif controller['dpad'] and get_button(joy, 'KNOB_MODE_SCENE'):
                    if event.button == bmap('BUTTON_LEFT'):
                        sendOscMsg("/key/4", 1)
                    elif event.button == bmap('BUTTON_RIGHT'):
                        sendOscMsg("/key/5", 1)
                    elif event.button == bmap('BUTTON_UP'):
                        sendOscMsg("/key/6", 1)
                    elif event.button == bmap('BUTTON_DOWN'):
                        sendOscMsg("/key/7", 1)

                if event.button == bmap('KEY_SHIFT'):
                    shift_state = not shift_state
                    sendOscMsg("/shift", 1 if shift_state else 0)
            elif event.type== JOYBUTTONUP:
                #print("BUTTONUP", event.joy, event.button)
                if get_button(joy, 'KEY_SECONDARY'):
                    if event.button == bmap('KEY_SAVE'):
                        sendOscMsg("/key/8", 0)
                    elif event.button == bmap('KEY_TRIGGER'):
                        sendOscMsg("/key/10", 0)
            else:
                #print("EVENT", event)
                pass
        clock.tick(60)

    stopOscServer()
    stopPygame()

if __name__ == "__main__":
    main()
