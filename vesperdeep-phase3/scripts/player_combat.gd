extends Node
class_name PlayerCombat

signal struck(target: Node)
const ATTACK_ANTIC := 0.06
const ATTACK_ACTIVE := 0.10
const ATTACK_RECOVERY := 0.20
var phase: String = "idle"
var timer: float = 0.0
var swing_id: int = 0
var struck_ids: Dictionary = {}
var direction: String = "forward"
var focus_timer: float = 0.0
var focusing: bool = false

func _physics_process(delta: float) -> void:
    var player := get_parent() as Vessel
    if player == null:
        return
    if focusing:
        if not player.input_enabled or Controls.gameplay_locked or not Input.is_action_pressed("heal") or absf(Input.get_axis("move_left", "move_right")) > 0.15 or not player.is_on_floor():
            interrupt_focus()
        else:
            focus_timer += delta
            if focus_timer >= 1.1:
                finish_focus()
    elif phase == "idle" and player.input_enabled and not Controls.gameplay_locked and Input.is_action_pressed("heal") and RunState.charges > 0 and RunState.hp < 5 and player.is_on_floor() and absf(player.velocity.x) < 20.0:
        focusing = true
        focus_timer = 0.0
        player.velocity.x = 0.0
    if phase != "idle":
        timer -= delta
        match phase:
            "antic":
                if timer <= 0.0:
                    phase = "active"
                    timer = ATTACK_ACTIVE
            "active":
                if player.input_enabled and not Controls.gameplay_locked:
                    _scan_hits(player)
                if timer <= 0.0:
                    phase = "recovery"
                    timer = ATTACK_RECOVERY
            "recovery":
                if timer <= 0.0:
                    phase = "idle"
    elif player.input_enabled and not Controls.gameplay_locked and not focusing and Input.is_action_just_pressed("attack"):
        begin_attack()

func begin_attack() -> bool:
    if phase != "idle" or focusing:
        return false
    var vertical := Input.get_axis("aim_up", "aim_down")
    direction = "down" if vertical > 0.4 else ("up" if vertical < -0.4 else "forward")
    phase = "antic"
    timer = ATTACK_ANTIC
    swing_id += 1
    struck_ids.clear()
    return true

func _scan_hits(player: Vessel) -> void:
    var shape := RectangleShape2D.new()
    shape.size = Vector2(38, 20) if direction == "forward" else Vector2(24, 36)
    var offset := Vector2(player.facing * 29.0, 0.0) if direction == "forward" else Vector2(0.0, 30.0 if direction == "down" else -30.0)
    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = shape
    query.transform = Transform2D(0.0, player.global_position + offset)
    query.collision_mask = 4
    query.exclude = [player.get_rid()]
    for hit in player.get_world_2d().direct_space_state.intersect_shape(query, 16):
        var target: Object = hit.collider
        if not target.has_method("receive_hit") or struck_ids.has(target.get_instance_id()):
            continue
        struck_ids[target.get_instance_id()] = true
        if not target.receive_hit(swing_id, player):
            continue
        struck.emit(target)
        if direction == "down":
            player.pogo()
        register_successful_attack()

func register_successful_attack() -> void:
    if RunState.charges >= 3:
        RunState.hit_progress = 0
        return
    RunState.hit_progress += 1
    if RunState.hit_progress >= 3:
        RunState.hit_progress = 0
        RunState.charges += 1
    RunState.changed.emit()
    RunState.save_game()

func is_focusing() -> bool:
    return focusing

func interrupt_focus() -> void:
    focusing = false
    focus_timer = 0.0

func finish_focus() -> void:
    if not focusing or RunState.charges <= 0 or RunState.hp >= 5:
        interrupt_focus()
        return
    RunState.hp += 1
    RunState.charges -= 1
    RunState.changed.emit()
    RunState.save_game()
    interrupt_focus()
