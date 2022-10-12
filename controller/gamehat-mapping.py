controller = {
    'dpad': False,
    'axis': True,
    'axis-threshold': 0.9,
    'buttons': dict(
        BUTTON_A = 0,
        BUTTON_B = 1,
        BUTTON_X = 2,
        BUTTON_Y = 3,
        BUTTON_RT = 4,
        BUTTON_LT = 5,
        BUTTON_SELECT = 7,
        BUTTON_START = 6,
    ),
    'mapping': dict(
        # knobs
        KNOB_1 = 'BUTTON_Y',
        KNOB_2 = 'BUTTON_X',
        KNOB_3 = 'BUTTON_B',
        KNOB_4 = 'BUTTON_A',
        KNOB_5 = 'BUTTON_RT',
        KNOB_MODE_SCENE = 'BUTTON_LT',
        # shift knobs
        KNOB_GAIN = 'BUTTON_Y',
        KNOB_TRIGGER_SOURCE = 'BUTTON_X',
        KNOB_MIDI_CHANNEL = 'BUTTON_B',
        # keys
        KEY_SHIFT = 'BUTTON_SELECT',
        KEY_SECONDARY = 'BUTTON_START',
        # more keys (hold secondary button)
        KEY_OSD = 'BUTTON_Y',
        KEY_PERSIST = 'BUTTON_X',
        KEY_SAVE = 'BUTTON_B',
        KEY_SCREENSHOT = 'BUTTON_A',
        KEY_TRIGGER = 'BUTTON_RT'
    )
}
