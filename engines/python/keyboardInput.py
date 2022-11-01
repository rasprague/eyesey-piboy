import pygame
import etc_system

# tuning constants
SMALL_INC = 5 / 1023.0
BIG_INC = 10 / 1023.0
GAIN_SMALL_INC = 10 / 1023.0
GAIN_BIG_INC = 100 / 1023.0
GAIN_MAX = 10.0

def clamp(val, min=0.0, max=1.0):
    if val < min:
        return min
    if val > max:
        return max
    return val

def updateKnob(i, pressed, etc):
    inc = 0.0
    if pressed[pygame.K_UP]:
        inc = BIG_INC
    if pressed[pygame.K_DOWN]:
        inc = -BIG_INC
    if pressed[pygame.K_LEFT]:
        inc = -SMALL_INC
    if pressed[pygame.K_RIGHT]:
        inc = SMALL_INC

    v = etc.knob_hardware[i]
    etc.knob_hardware[i] = clamp(v+inc)

def updateGain(pressed, etc):
    inc = 0.0
    if pressed[pygame.K_UP]:
        inc = GAIN_BIG_INC
    if pressed[pygame.K_DOWN]:
        inc = -GAIN_BIG_INC
    if pressed[pygame.K_LEFT]:
        inc = -GAIN_SMALL_INC
    if pressed[pygame.K_RIGHT]:
        inc = GAIN_SMALL_INC

    v = etc.audio_scale
    etc.audio_scale = clamp(v+inc, 0.0, GAIN_MAX)

def updateTriggerSource(event, etc):
    inc = 0
    if event.key == pygame.K_LEFT:
        inc = -1
    elif event.key == pygame.K_RIGHT:
        inc = 1
    elif event.key == pygame.K_UP:
        inc = 1
    elif event.key == pygame.K_DOWN:
        inc = -1

    if inc != 0:
        etc.trigger_source = clamp(etc.trigger_source+inc, 0, 5)
        etc.audio_trig_enable = etc.trigger_source == 0
    
def updateMidiChannel(event, etc):
    inc = 0
    if event.key == pygame.K_LEFT:
        inc = -1
    elif event.key == pygame.K_RIGHT:
        inc = 1
    elif event.key == pygame.K_UP:
        inc = 1
    elif event.key == pygame.K_DOWN:
        inc = -1

    if inc != 0:
        etc.midi_ch = clamp(etc.midi_ch+inc, 1, 16)

def updateShift(etc):
    etc.shift = not etc.shift
    if etc.shift:
        etc.set_osd(False)
    else : 
        etc.save_shift_params()

def eventHandler(event, pressed, etc):
    if event.type == pygame.KEYDOWN:
        if event.key == pygame.K_LSHIFT or event.key == pygame.K_RSHIFT:
            updateShift(etc)
        if pressed[pygame.K_7]: # trigger source
            updateTriggerSource(event, etc)
        if pressed[pygame.K_8]: # midi channel
            updateMidiChannel(event, etc)
        if event.key == pygame.K_UP:
            pass
        if event.key == pygame.K_DOWN:
            pass
        if event.key == pygame.K_LEFT:
            pass
        if event.key == pygame.K_RIGHT:
            pass
    
def update(pressed, etc):
    if pressed[pygame.K_1]:
        updateKnob(0, pressed, etc)
    if pressed[pygame.K_2]:
        updateKnob(1, pressed, etc)
    if pressed[pygame.K_3]:
        updateKnob(2, pressed, etc)
    if pressed[pygame.K_4]:
        updateKnob(3, pressed, etc)
    if pressed[pygame.K_5]:
        updateKnob(4, pressed, etc)
    if pressed[pygame.K_6]: # gain
        updateGain(pressed, etc)
