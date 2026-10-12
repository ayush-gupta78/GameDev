extends CharacterBody2D
class_name Vessel

signal died
@export var tuning: PlayerTuning = PlayerTuning.new()
var facing: int = 1
var air_dash_available: bool = true
var air_jump_available: bool = true
var wing_flash: float = 0.0
var state: String = "idle"
var input_enabled: bool = true
var safe_position: Vector2 = Vector2.ZERO
var coyote: float = 0.0
var jump_buffer: float = 0.0
var dash_timer: float = 0.0
var dash_cooldown: float = 0.0
var wall_lock: float = 0.0
var invulnerable: float = 0.0
var contact_stagger: float = 0.0
var attack: PlayerCombat

func _ready() -> void:
    collision_layer = 2
    collision_mask = 1
    var shape := CollisionShape2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(22, 34)
    shape.shape = rect
    add_child(shape)
    attack = PlayerCombat.new()
    add_child(attack)
    safe_position = global_position
    queue_redraw()

func _physics_process(delta: float) -> void:
    invulnerable = maxf(0.0, invulnerable - delta)
    dash_cooldown = maxf(0.0, dash_cooldown - delta)
    wall_lock = maxf(0.0, wall_lock - delta)
    wing_flash = maxf(0.0, wing_flash - delta)
    contact_stagger = maxf(0.0, contact_stagger - delta)
    var locked := not input_enabled or Controls.gameplay_locked or attack.is_focusing()
    var axis := 0.0 if locked else Input.get_axis("move_left", "move_right")
    if not locked and Input.is_action_just_pressed("jump"):
        jump_buffer = tuning.jump_buffer_seconds
    else:
        jump_buffer = maxf(0.0, jump_buffer - delta)
    if is_on_floor():
        coyote = tuning.coyote_seconds
        air_dash_available = true
        air_jump_available = true
        safe_position = global_position
    else:
        coyote = maxf(0.0, coyote - delta)
    if not locked and Input.is_action_just_pressed("dash") and RunState.has_flag("echo_step_owned") and dash_cooldown <= 0.0 and (is_on_floor() or air_dash_available):
        dash_timer = tuning.dash_seconds
        dash_cooldown = tuning.dash_cooldown
        if not is_on_floor():
            air_dash_available = false
        if absf(axis) > 0.1:
            facing = 1 if axis > 0.0 else -1
    if dash_timer > 0.0:
        dash_timer -= delta
        velocity = Vector2(facing * tuning.dash_speed, 0.0)
        state = "dash"
    else:
        var touching_wall := false
        if is_on_wall() and not is_on_floor():
            for index in get_slide_collision_count():
                var collision := get_slide_collision(index)
                if absf(collision.get_normal().x) > 0.5 and collision.get_collider() is Node and collision.get_collider().is_in_group("climbable_wall"):
                    touching_wall = true
                    break
        if jump_buffer > 0.0 and not locked:
            if touching_wall and coyote <= 0.0:
                var normal := get_wall_normal()
                velocity.x = normal.x * tuning.wall_jump_horizontal
                velocity.y = -tuning.jump_speed
                facing = int(signf(normal.x))
                wall_lock = 0.12
                air_dash_available = true
                air_jump_available = true
                jump_buffer = 0.0
                state = "wall_jump"
            elif coyote > 0.0:
                velocity.y = -tuning.jump_speed
                coyote = 0.0
                jump_buffer = 0.0
                state = "jump"
            elif air_jump_available and RunState.has_flag("double_jump_owned"):
                velocity.y = -tuning.double_jump_speed
                air_jump_available = false
                wing_flash = 0.22
                jump_buffer = 0.0
                state = "double_jump"
        if not locked and Input.is_action_just_released("jump") and velocity.y < 0.0:
            velocity.y *= 0.45
        if not is_on_floor():
            velocity.y = minf(velocity.y + tuning.gravity * delta, tuning.fall_speed)
            if touching_wall and velocity.y > tuning.wall_slide_speed:
                velocity.y = tuning.wall_slide_speed
        if wall_lock <= 0.0:
            var acceleration := tuning.ground_acceleration if is_on_floor() else tuning.air_acceleration
            if contact_stagger > 0.0:
                acceleration *= 0.35 # Recoil still allows jump, dash and directional control.
            if absf(axis) < 0.1 and is_on_floor():
                acceleration = tuning.ground_deceleration
            velocity.x = move_toward(velocity.x, axis * tuning.run_speed, acceleration * delta)
            if absf(axis) > 0.1:
                facing = 1 if axis > 0.0 else -1
        if is_on_floor():
            state = "run" if absf(velocity.x) > 10.0 else "idle"
        elif touching_wall and velocity.y > 0.0:
            state = "wall_slide"
        else:
            state = "jump" if velocity.y < 0.0 else "fall"
    move_and_slide()
    queue_redraw()

func pogo() -> void:
    velocity.y = -tuning.pogo_speed
    state = "pogo"

func receive_damage(source_id: int, amount: int = 1) -> bool:
    if invulnerable > 0.0 or RunState.hp <= 0 or not input_enabled or Controls.gameplay_locked:
        return false
    attack.interrupt_focus()
    RunState.hp = maxi(0, RunState.hp - amount)
    RunState.changed.emit()
    invulnerable = 0.85
    velocity = Vector2(-facing * 160.0, -170.0)
    if RunState.hp == 0:
        died.emit()
    else:
        RunState.save_game()
    return true

func receive_body_contact(source: CharacterBody2D, damage: int = 1) -> bool:
    if invulnerable > 0.0 or contact_stagger > 0.0 or RunState.hp <= 0 or Controls.gameplay_locked:
        return false
    if damage > 0 and not receive_damage(source.get_instance_id(), damage):
        return false
    var away := global_position.x - source.global_position.x
    if absf(away) < 1.0:
        away = velocity.x - source.velocity.x
    var direction := signf(away) if absf(away) >= 1.0 else float(facing)
    velocity = Vector2(direction * tuning.contact_knockback, -tuning.contact_lift)
    contact_stagger = tuning.contact_stagger_seconds
    return true

func recover_hazard() -> void:
    if invulnerable > 0.0:
        return
    var was_fatal := RunState.hp <= 1
    receive_damage(-1, 1)
    if not was_fatal:
        global_position = safe_position
        velocity = Vector2.ZERO

func _draw() -> void:
    draw_rect(Rect2(-11, -17, 22, 34), Color(0.78, 0.88, 0.94) if invulnerable <= 0.0 else Color(0.5, 0.7, 0.9))
    draw_line(Vector2(facing * 3, -7), Vector2(facing * 9, -7), Color(0.08, 0.1, 0.2), 2.0)
    if wing_flash > 0.0:
        draw_line(Vector2(-10, -4), Vector2(-28, -14), Color(0.72, 0.85, 1.0, wing_flash / 0.22), 4.0)
        draw_line(Vector2(10, -4), Vector2(28, -14), Color(0.72, 0.85, 1.0, wing_flash / 0.22), 4.0)
