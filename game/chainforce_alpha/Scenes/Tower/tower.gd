extends StaticBody2D

@export var rotation_speed: float = 5
@export var hp: int = 100 :
	set(val):
		hp = val
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate", Color.WHITE, 0.5).from(Color(1.3, 1.3, 1.3))
		if hp <= 0:
			die()

@onready var projectile_shooter: EnemyProjectileShooter = $ProjectileShooter

var enemy_target: Node2D
var is_dead: bool

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	shoot_enemy(delta)

func shoot_enemy(delta: float):
	if enemy_target == null:
		return
	
	var target_rotation: float = global_position.angle_to_point(enemy_target.global_position) #+ PI/2
	global_rotation = lerp_angle(global_rotation, target_rotation, rotation_speed * delta)

func die():
	is_dead = true
	$ExplosionParticles.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$ProjectileShooter.process_mode = Node.PROCESS_MODE_DISABLED
	$ExplosionSFX.play()
	await get_tree().create_timer(3).timeout
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("friendly") or body.is_in_group("enemy"):
		enemy_target = body
		projectile_shooter.can_shoot = true