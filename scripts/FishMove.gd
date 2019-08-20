extends Sprite

var direction = 1
var fish_speed = 100
var normal_speed = 100
var max_speed = 600

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fish_speed > normal_speed:
		fish_speed = fish_speed - (100 * delta)
	
	if position.x > 400 or position.x < 50:
		direction = direction * -1
	
	flip_h = direction == -1
	position.x = position.x + (delta * fish_speed * direction)

func _on_clicked(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		direction = direction * -1
		fish_speed = min(fish_speed * 4, max_speed)