class_name Unit extends CharacterBody2D

const Cooldown = preload("res://scripts/cooldown.gd")
const SPEED = 100.0
var class_info: ClassInfo

enum STATES {
	WALK,
	ATTACK
}

var state: STATES = STATES.WALK
var target = null
var max_hp: float

var is_moving_left: bool
var attack_cooldown_time: float
var hp = 100
var damage: float

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var health_bar = $HUD/HealthBar
var attack_cooldown = null

func init(class_info: ClassInfo):
	self.class_info = class_info


func _ready():
	hp = class_info.hp
	is_moving_left = class_info.is_moving_left
	damage = class_info.damage
	attack_cooldown_time = class_info.attack_cooldown_time
	attack_cooldown = Cooldown.new(attack_cooldown_time)

	var shape = RectangleShape2D.new()
	shape.set_size(Vector2(class_info.range, 30))
	var collision = CollisionShape2D.new()
	collision.set_shape(shape)
	detection_area.add_child(collision)

	max_hp = hp
	health_bar.visible = false
	health_bar.value = 100
	if is_moving_left:
		animated_sprite.flip_h = true
		detection_area.position = Vector2(-((class_info.range + 15) /2) , -3)
	else:
		detection_area.position = Vector2(((class_info.range + 15) /2), -3)


func _physics_process(delta):
	_get_animation(delta)
	_get_action(delta)
	move_and_slide()
	update_ui()
	pass


############## Animation ##############

func _get_animation(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	else:
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")


############## Movement ##############

func _get_action(delta):
	handle_death()
	match state:
		STATES.WALK:
			velocity.x = -SPEED if is_moving_left else SPEED
		STATES.ATTACK:
			velocity.x = 0
			attack_cooldown.tick(delta)
			if attack_cooldown.is_ready() and target != null:
				if target.has_method("take_damage"):
					target.take_damage(damage)
		_:
			velocity.x = 0
			pass


############## Actions ##############

func take_damage(damage: float):
	var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "hp", -damage, 0.5).as_relative().from_current()


func handle_death():
	if hp <= 0:
		queue_free()


func add_damage(value):
	damage += value


func check_collisions_for_valid_target(body = null) -> bool:
	var is_valid_target = _is_valid_target(body)
	if is_valid_target and target == null:
		if (body == null):
			var bodies = detection_area.get_overlapping_bodies()
			for b in bodies:
				if _is_valid_target(b):
					target = b
					state = STATES.ATTACK
					return true
			return false
		target = body
		state = STATES.ATTACK
		return true
	return false


############## UI ##############

func update_ui():
	update_health_bar()

func update_health_bar():
	if hp == max_hp:
		health_bar.visible = false
	else:
		health_bar.visible = true
	health_bar.value = hp * 100 / max_hp


############## Events ##############

func _on_detection_area_2d_body_entered(body):
	print(body.name)
	if not body.has_method("get_collision_layer"):
		return
	check_collisions_for_valid_target(body)


func _on_detection_area_2d_body_exited(body):
	var has_target = check_collisions_for_valid_target()
	if not has_target:
		state = STATES.WALK
		attack_cooldown.reset()


############## Helpers ##############

func _is_valid_target(body) -> bool:
	if body == null:
		return false

	if not body.has_method("get_collision_layer"):
		return false

	if (body.get_collision_layer() == 2 or body.get_collision_layer() == 4 or body.get_collision_layer() == 8 or body.get_collision_layer() == 16):
		return true

	return false
