extends Area2D

const GRAVITY = 9.8
const WALKSPEED = 2
const RUNSPEED = 4

@onready var buddyAnim = $BuddyCollision/BuddyAnim
@onready var heartsParticles = $BuddyCollision/HeartsParticles

var mouseOn = false

var dragStartPosition = null

var fallingSpeed = 0

var currentPos = null

var speedX = WALKSPEED
var nextPosX = null

var idle2Animation = false

var isSleeping = false

var iterationTimer = 30.0
var iterationInverval = 30.0

var screenSize = null

func _ready():
	buddyAnim.connect("animation_finished", onAnimationFinished)

func onAnimationFinished():
	idle2Animation = false

func _process(delta):
	if isSleeping:
		return

	if dragStartPosition:
		fallingSpeed = 0
		nextPosX = null
		buddyAnim.play("Hanging")
		return

	if fallingSpeed:
		nextPosX = null

	currentPos = DisplayServer.window_get_position()
	screenSize = DisplayServer.screen_get_size()
	
	handleFall(delta)
	handleMoviment()
	handleAnim()
	
	iterationTimer -= delta
	if iterationTimer <= 0.0:
		handleIteration()
	
func handleIteration():
	if isSleeping || idle2Animation:
		return
		
	iterationInverval = RandomNumberGenerator.new().randi_range(10, 60)
	iterationTimer = iterationInverval

	var chance = RandomNumberGenerator.new().randi_range(1, 100)
	if chance <= 10:
		return
	elif chance <= 40:
		idle2Animation = true
	elif chance <= 70:
		speedX = WALKSPEED
		setNextPosX()
	elif chance <= 95:
		speedX = RUNSPEED
		setNextPosX()
	else:
		isSleeping = true

func handleAnim():
	if fallingSpeed:
		buddyAnim.play("Falling")
		return
	
	if nextPosX:
		if speedX <= WALKSPEED:
			buddyAnim.play("Walk")
		elif speedX >= RUNSPEED:
			buddyAnim.play("Run")
		return

	if isSleeping:
		buddyAnim.play("Sleep")
		return

	if idle2Animation:
		buddyAnim.play("Idle2")
	else:
		buddyAnim.play("Idle1")

func handleFall(delta):
	var floorY = screenSize.y - 127 - 50

	if currentPos.y < floorY:
		fallingSpeed += GRAVITY * delta
	else:
		fallingSpeed = 0
		return

	var nextY = currentPos.y + fallingSpeed
	if (nextY > floorY):
		nextY = floorY

	var nextPosition = Vector2(currentPos.x, nextY)

	DisplayServer.window_set_position(nextPosition)

func handleMoviment():
	if nextPosX == null:
		return

	var nextX = null
	if currentPos.x > nextPosX:
		nextX = currentPos.x - speedX
		if nextX < nextPosX:
			nextX = nextPosX
	elif currentPos.x < nextPosX:
		nextX = currentPos.x + speedX
		if nextX > nextPosX:
			nextX = nextPosX

	if nextX == nextPosX:
		nextPosX = null

	var nextPosition = Vector2(nextX, currentPos.y)

	DisplayServer.window_set_position(nextPosition)

func _input(event):
	handleDrag(event)

func setNextPosX():
	var screenStartX = DisplayServer.screen_get_position().x
	var screenEndX = screenSize.x + screenStartX

	var rng = RandomNumberGenerator.new()
	nextPosX = rng.randi_range(screenStartX, screenEndX)

	if (currentPos.x < nextPosX):
		buddyAnim.flip_h = false
	else:
		buddyAnim.flip_h = true

func handleDrag(event):
	if event is InputEventMouseButton:
		if event.double_click:
			if buddyAnim.flip_h:
				heartsParticles.position.x = -22
			else:
				heartsParticles.position.x = 22
			heartsParticles.restart()
		if event.is_pressed():
			dragStartPosition = event.position
			isSleeping = false
		else:
			dragStartPosition = null

	if event is InputEventMouseMotion && dragStartPosition:
		var newPosition = DisplayServer.mouse_get_position() - Vector2i(dragStartPosition)
		DisplayServer.window_set_position(newPosition)

func _mouse_enter():
	mouseOn = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	updateHover()

func _mouse_exit():
	mouseOn = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	updateHover()

func updateHover():
	if dragStartPosition || mouseOn:
		buddyAnim.modulate = "#989898"
	else:
		buddyAnim.modulate = "#ffffff"
