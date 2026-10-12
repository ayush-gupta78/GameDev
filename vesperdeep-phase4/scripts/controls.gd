extends Node

const KEY_BINDINGS := {
    "move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
    "aim_up": [KEY_W, KEY_UP], "aim_down": [KEY_S, KEY_DOWN],
    "jump": [KEY_SPACE], "attack": [KEY_J], "heal": [KEY_K],
    "dash": [KEY_SHIFT], "interact": [KEY_E], "pause": [KEY_ESCAPE],
    "menu_up": [KEY_UP, KEY_W], "menu_down": [KEY_DOWN, KEY_S],
    "menu_left": [KEY_LEFT, KEY_A], "menu_right": [KEY_RIGHT, KEY_D],
    "menu_confirm": [KEY_ENTER, KEY_SPACE], "menu_back": [KEY_ESCAPE, KEY_BACKSPACE]
}
const PAD_BUTTONS := {
    "move_left": [JOY_BUTTON_DPAD_LEFT], "move_right": [JOY_BUTTON_DPAD_RIGHT],
    "aim_up": [JOY_BUTTON_DPAD_UP], "aim_down": [JOY_BUTTON_DPAD_DOWN],
    "jump": [JOY_BUTTON_A], "attack": [JOY_BUTTON_X], "heal": [JOY_BUTTON_Y],
    "dash": [JOY_BUTTON_B], "interact": [JOY_BUTTON_RIGHT_SHOULDER],
    "pause": [JOY_BUTTON_START], "menu_up": [JOY_BUTTON_DPAD_UP],
    "menu_down": [JOY_BUTTON_DPAD_DOWN], "menu_left": [JOY_BUTTON_DPAD_LEFT],
    "menu_right": [JOY_BUTTON_DPAD_RIGHT], "menu_confirm": [JOY_BUTTON_A],
    "menu_back": [JOY_BUTTON_B]
}
const AXES := {"move_left": [JOY_AXIS_LEFT_X, -1.0], "move_right": [JOY_AXIS_LEFT_X, 1.0],
    "aim_up": [JOY_AXIS_LEFT_Y, -1.0], "aim_down": [JOY_AXIS_LEFT_Y, 1.0],
    "menu_up": [JOY_AXIS_LEFT_Y, -1.0], "menu_down": [JOY_AXIS_LEFT_Y, 1.0],
    "menu_left": [JOY_AXIS_LEFT_X, -1.0], "menu_right": [JOY_AXIS_LEFT_X, 1.0]}
var gameplay_locked: bool = false
var last_device: String = "keyboard"

func _ready() -> void:
    install_defaults()

func install_defaults() -> void:
    for action in KEY_BINDINGS:
        if InputMap.has_action(action):
            InputMap.action_erase_events(action)
        else:
            InputMap.add_action(action, 0.25)
        for key in KEY_BINDINGS[action]:
            var event := InputEventKey.new()
            event.physical_keycode = key
            InputMap.action_add_event(action, event)
        for button in PAD_BUTTONS[action]:
            var event := InputEventJoypadButton.new()
            event.button_index = button
            InputMap.action_add_event(action, event)
        if AXES.has(action):
            var event := InputEventJoypadMotion.new()
            event.axis = AXES[action][0]
            event.axis_value = AXES[action][1]
            InputMap.action_add_event(action, event)

func rebind(action: StringName, event: InputEvent) -> bool:
    if not KEY_BINDINGS.has(String(action)) or action.begins_with("menu_"):
        return false
    if event is not InputEventKey and event is not InputEventJoypadButton:
        return false
    for bound in InputMap.action_get_events(action):
        if bound.as_text() == event.as_text():
            return false
    for other in KEY_BINDINGS:
        if other == String(action):
            continue
        for bound in InputMap.action_get_events(other):
            if bound.as_text() == event.as_text():
                return false
    for bound in InputMap.action_get_events(action):
        if (bound is InputEventKey and event is InputEventKey) or (bound is InputEventJoypadButton and event is InputEventJoypadButton):
            InputMap.action_erase_event(action, bound)
    InputMap.action_add_event(action, event)
    return true

func _input(event: InputEvent) -> void:
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        last_device = "controller"
    elif event is InputEventKey:
        last_device = "keyboard"
