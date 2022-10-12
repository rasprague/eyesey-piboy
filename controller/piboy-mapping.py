controller = {
    'dpad': True,
    'axis': False,
    'buttons': dict(
        BUTTON_A = 0,
        BUTTON_B = 1,
        BUTTON_C = 2,
        BUTTON_X = 3,
        BUTTON_Y = 4,
        BUTTON_Z = 5,
        BUTTON_RT = 6,
        BUTTON_LT = 7,
        BUTTON_SELECT = 8,
        BUTTON_START = 9,
        BUTTON_L3 = 10,
        BUTTON_DOWN = 11,
        BUTTON_UP = 12,
        BUTTON_LEFT = 13,
        BUTTON_RIGHT = 14
    ),
    'mapping': dict(
        # knobs
        KNOB_1 = 'BUTTON_Z',
        KNOB_2 = 'BUTTON_Y',
        KNOB_3 = 'BUTTON_X',
        KNOB_4 = 'BUTTON_C',
        KNOB_5 = 'BUTTON_B',
        KNOB_MODE_SCENE = 'BUTTON_A',
        # shift knobs
        KNOB_GAIN = 'BUTTON_Z',
        KNOB_TRIGGER_SOURCE = 'BUTTON_Y',
        KNOB_MIDI_CHANNEL = 'BUTTON_X',
        # keys
        KEY_SHIFT = 'BUTTON_SELECT',
        KEY_SECONDARY = 'BUTTON_START',
        # more keys (hold secondary button)
        KEY_OSD = 'BUTTON_Z',
        KEY_PERSIST = 'BUTTON_X',
        KEY_SAVE = 'BUTTON_C',
        KEY_SCREENSHOT = 'BUTTON_B',
        KEY_TRIGGER = 'BUTTON_A'
    )
}
