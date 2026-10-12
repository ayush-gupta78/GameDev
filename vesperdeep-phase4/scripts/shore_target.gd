extends StaticBody2D
class_name ShoreTarget

var flash: float = 0.0

func _ready() -> void:
    collision_layer = 4
    collision_mask = 0
    var shape := CollisionShape2D.new()
    var rectangle := RectangleShape2D.new()
    rectangle.size = Vector2(28, 34)
    shape.shape = rectangle
    add_child(shape)

func receive_hit(_swing: int, _attacker: Vessel) -> bool:
    flash = 0.3
    queue_redraw()
    return false # Harmless tutorial prop: no Focus charge or pogo credit.

func _process(delta: float) -> void:
    if flash > 0.0:
        flash = maxf(0.0, flash - delta)
        queue_redraw()

func _draw() -> void:
    draw_line(Vector2(0, -32), Vector2(0, -17), Color(0.62, 0.76, 0.75), 3)
    draw_rect(Rect2(-14, -17, 28, 34), Color.WHITE if flash > 0.0 else Color(0.69, 0.62, 0.48))
    draw_line(Vector2(-9, 4), Vector2(9, 4), Color(0.22, 0.26, 0.27), 2)
