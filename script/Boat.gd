extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var thrust;
var torque;
var forwardThrust = 5.0;
var rotationThrust = .5;
var max_velocity = 10.0;
var  max_rotation = 2;

var ocean;

#health 
export(float) var max_health = 100
onready var health = max_health setget _set_health
onready var invulnerability_timer = $InvulnerabilityTimer
signal health_updated(health)
signal killed()

# Called when the node enters the scene tree for the first time.
func _ready():
	thrust = Vector3()
	
	ocean = get_parent().get_node('Ocean')
	pass # Replace with function body.

		
func _physics_process(_delta):
	if Input.is_action_just_pressed("press_k"):
		print("Ouch")
		damage(10)
	_get_movement()
	var ocean = get_parent().get_node('Ocean')
	
	var translation = ocean.get_displace(Vector2(global_transform.origin.x, global_transform.origin.z))
	var xP = global_transform.origin.x
	var zP = global_transform.origin.z
	var d1 = ocean.get_displace(Vector2(xP, zP))
	var d2 = ocean.get_displace(Vector2(xP+0.01, zP))
	var d3 = ocean.get_displace(Vector2(xP, zP+0.01))
	var buoyancyForce = translation.y - global_transform.origin.y
	buoyancyForce = clamp(buoyancyForce, 0, INF)
	print(ocean)
	apply_central_impulse(Vector3(0, buoyancyForce, 0))
	
	var vec1 = Vector3(xP, d1.y, zP)
	var vec2 = Vector3(xP+0.01, d2.y, zP)
	var vec3 = Vector3(xP, d3.y, zP+0.01)
	
	var dir1 = vec2 - vec1
	var dir2 = vec3 - vec1

	var norm = dir2.cross(dir1)
	norm = norm.normalized()
#
	var localUp = global_transform.basis.y
	var correctingMoment = localUp.cross(norm)
	apply_torque_impulse(correctingMoment)

					
func _get_movement():
	if Input.is_action_pressed("ui_up"):
		if (linear_velocity.length() <max_velocity):
			thrust = forwardThrust * global_transform.basis.x
			apply_central_impulse(thrust)
			
	if Input.is_action_pressed("ui_down"):
		if (linear_velocity.length() <max_velocity):		
			thrust = forwardThrust * global_transform.basis.x
			apply_central_impulse(-thrust)
			
	if Input.is_action_pressed("ui_left"):

		if (angular_velocity.length() <max_rotation):		
			thrust = rotationThrust * global_transform.basis.y * linear_velocity.length() / max_velocity
			apply_torque_impulse(thrust)
			
	if Input.is_action_pressed("ui_right"):
		if (angular_velocity.length() <max_rotation):
			thrust = rotationThrust * global_transform.basis.y * linear_velocity.length() / max_velocity
			apply_torque_impulse(-thrust)	


func damage(amount):
	#Create IFrame so that player does not repeatedly take damage
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		_set_health(health-amount)
	
func kill():
	print("You Are Dead!")
	pass
	
func _set_health(value):
	var prev_health= health
	health = clamp(value, 0 , max_health)
	if health != prev_health:
		emit_signal("health_updated",health)
		if health == 0:
			kill()
			emit_signal("killed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass