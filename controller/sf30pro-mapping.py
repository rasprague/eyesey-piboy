controller = {
    'dpad': False,
    'hat': True,
    'axis': True,
    'axis-threshold': 0.9,
    'buttons': dict(
        BUTTON_A = 1,
        BUTTON_B = 0,
        BUTTON_X = 2,
        BUTTON_Y = 3,
        BUTTON_R1 = 5,
        BUTTON_L1 = 4,
        BUTTON_R2 = 7,
        BUTTON_L2 = 6,
        BUTTON_R3 = 12,
        BUTTON_L3 = 11,
        BUTTON_SELECT = 8,
        BUTTON_START = 9
    ),
    'mapping': dict(
        # knobs
        KNOB_1 = 'BUTTON_Y',
        KNOB_2 = 'BUTTON_X',
        KNOB_3 = 'BUTTON_B',
        KNOB_4 = 'BUTTON_A',
        KNOB_5 = 'BUTTON_R1',
        KNOB_MODE_SCENE = 'BUTTON_L1',
        # shift knobs
        KNOB_GAIN = 'BUTTON_Y',
        KNOB_TRIGGER_SOURCE = 'BUTTON_X',
        KNOB_MIDI_CHANNEL = 'BUTTON_A',
        # keys
        KEY_SHIFT = 'BUTTON_SELECT',
        KEY_SECONDARY = 'BUTTON_START',
        # more keys (hold secondary button)
        KEY_OSD = 'BUTTON_Y',
        KEY_PERSIST = 'BUTTON_X',
        KEY_SAVE = 'BUTTON_B',
        KEY_SCREENSHOT = 'BUTTON_A',
        KEY_TRIGGER = 'BUTTON_R1'
    )
}
