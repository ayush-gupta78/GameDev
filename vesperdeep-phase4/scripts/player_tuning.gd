extends Resource
class_name PlayerTuning

# Original Vesperdeep prototype calibration values; not measured Hollow Knight constants.
@export var run_speed: float = 220.0
@export var ground_acceleration: float = 2000.0
@export var ground_deceleration: float = 2500.0
@export var air_acceleration: float = 1300.0
@export var gravity: float = 1100.0
@export var jump_speed: float = 405.0
@export var double_jump_speed: float = 360.0
@export var fall_speed: float = 570.0
@export var wall_slide_speed: float = 95.0
@export var wall_jump_horizontal: float = 260.0
@export var coyote_seconds: float = 0.09
@export var jump_buffer_seconds: float = 0.11
@export var dash_speed: float = 440.0
@export var dash_seconds: float = 0.18
@export var dash_cooldown: float = 0.24
@export var pogo_speed: float = 360.0
@export var contact_knockback: float = 235.0
@export var contact_lift: float = 125.0
@export var contact_stagger_seconds: float = 0.10
