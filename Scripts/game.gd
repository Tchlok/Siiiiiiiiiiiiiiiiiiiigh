class_name Game
extends Node2D

enum GameState{Start,ZoomUp,Game,Expired,GunFlash,Ended,Restart}
var gameState : GameState
@export var endings : Endings
@export var camera : Camera2D
@export var spawn : Spawn

@export var crosshairSpring : Node2D
@export var crosshairShake : Node2D
@export var crosshairAnim : AnimationPlayer
@export var crosshairRotate : Node2D
@export var crosshairRotMod : float = 8

@export var startPosition : Vector2
@export var colors : Array[Color]
@export var colorRect : ColorRect

@export var gameBoundsX : float
@export var gameBoundsTop : float
@export var gameBoundsBottom : float

@export var gameMaxMoveSpeed : float
@export var gameCamAcceleration : float
@export var gameCamDrag : float
var gameCamVelocity : Vector2

@export var gameBaseRigid : float
@export var gameBaseDamp : float
var gameSteadyT : float
var swayIntensity : float
@export var gameCamSwayDecay : float
@export var gameCamSwayGain : float
@export var gameCamSwayMin : float
@export var gameCamSwayMag : float
@export var gameCamSwaySpeed : float


@export var zoomUpPosition : Vector2
@export var zoomUpCurve : Curve
@export var zoomUpDuration : float

@export var gunFlashColor : Color
@export var gunFlashCurve : Curve
@export var gunFlashDuration : float

@export var expiredColor : Color
@export var expiredCurve : Curve
@export var expiredDuration : float

@export var restartColor : Color
@export var restartCurve : Curve
@export var restartDuration : float

var moveAxis : Vector2
func _enter_tree():
	camera.position=startPosition

func _ready():
	endings.visible=false
	endings.resetEndingFlags()

func _process(delta):
	moveAxis=Vector2.ZERO
	if Input.is_action_pressed("MoveUp"):
		moveAxis+=Vector2.UP
	if Input.is_action_pressed("MoveRight"):
		moveAxis+=Vector2.RIGHT
	if Input.is_action_pressed("MoveDown"):
		moveAxis+=Vector2.DOWN
	if Input.is_action_pressed("MoveLeft"):
		moveAxis+=Vector2.LEFT
	moveAxis=moveAxis.normalized()

	crosshairSpring.position+=crossVelocity*delta
	crosshairRotate.rotation_degrees=(crossVelocity.x/gameMaxMoveSpeed)*crosshairRotMod
	match gameState:
		GameState.Start:
			if Input.is_action_just_pressed("Shoot"):
				_newState(GameState.ZoomUp)
				crosshairAnim.play("CrosshairOn")
				crosshairSpring.visible=true
				spawn.spawn()
		GameState.ZoomUp:
			camera.position = startPosition.lerp(zoomUpPosition, zoomUpCurve.sample(MathS.Clamp01(_t/zoomUpDuration)))
			crosshairSpring.position=camera.position
			if _t>=zoomUpDuration:
				_newState(GameState.Game)
		GameState.Game:
			if Input.is_action_just_pressed("Shoot"):
				shoot()
			if _t>=20:
				_newState(GameState.Expired)
				colorRect.color=expiredColor
				colorRect.color.a=0
		GameState.GunFlash:
			colorRect.color.a = gunFlashCurve.sample(MathS.Clamp01(_t/gunFlashDuration))
			if _t>=gunFlashDuration:
				_newState(GameState.Ended)
		GameState.Expired:
			var aOld = colorRect.color.a
			colorRect.color.a = expiredCurve.sample(MathS.Clamp01(_t/expiredDuration))
			if aOld!=1 and colorRect.color.a==1:
				endings.loadEndingVisuals()
				crosshairSpring.visible=false
	
			if _t>=expiredDuration:
				_newState(GameState.Ended)
		GameState.Ended:
			if Input.is_action_just_pressed("Shoot"):
				_newState(GameState.Restart)
				colorRect.color=restartColor
				colorRect.color.a=0
				endings.resetEndingFlags()
		GameState.Restart:
			var aOld = colorRect.color.a
			colorRect.color.a = restartCurve.sample(MathS.Clamp01(_t/restartDuration))
			if aOld!=1 and colorRect.color.a==1:
				
				camera.position=startPosition
				crosshairSpring.position=camera.position
				endings.visible=false
			if _t>=restartDuration:
				_newState(GameState.Start)
	_t+=delta
func _physics_process(delta):
	match gameState:
		GameState.Start:
			pass
		GameState.ZoomUp:
			pass
		GameState.Game:
			if moveAxis==Vector2.ZERO:
				gameCamVelocity=Vector2.ZERO
				swayIntensity-=gameCamSwayDecay*delta
			else:
				gameCamVelocity+=moveAxis*delta*gameCamAcceleration
				gameCamVelocity-=moveAxis*delta*gameCamDrag
				swayIntensity+=gameCamSwayGain*delta

			swayIntensity=clamp(swayIntensity,gameCamSwayMin,1)
			gameCamVelocity=gameCamVelocity.limit_length(gameMaxMoveSpeed)
			camera.position+=gameCamVelocity*delta
			
			var sway : Vector2

			sway.x=sin(_t*gameCamSwaySpeed)*2*gameCamSwayMag*swayIntensity
			sway.y=sin(_t*0.5*gameCamSwaySpeed)*gameCamSwayMag*swayIntensity
			crosshairShake.position=sway
			camera.position=Vector2(clamp(camera.position.x,-gameBoundsX, gameBoundsX), clamp(camera.position.y,gameBoundsTop,gameBoundsBottom))
		GameState.GunFlash:
			pass
		GameState.Expired:
			pass
		GameState.Ended:
			pass
		GameState.Restart:
			pass
	_tPhys+=delta

	if gameState==GameState.Game or gameState==GameState.ZoomUp:
		var crossRigid : float = gameBaseRigid
		var crossDamp : float = gameBaseDamp
		var crossToCam : Vector2 = crosshairSpring.position-camera.position
		crossVelocity+= -crossRigid*crossToCam-(crossDamp*crossVelocity)



var crossVelocity : Vector2

var _t : float = 0
var _tPhys : float = 0

func _newState(newState : GameState):
	gameState=newState
	_t=0
	_tPhys=0


func shoot():
	endings.flagGunFired=true

	var spaceState = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position=crosshairRotate.global_position
	query.collide_with_areas=true
	query.collide_with_bodies=false
	query.collision_mask=1
	var result : Array[Dictionary] = spaceState.intersect_point(query,32)
	for d in result:
		print("HIT")
		d["collider"].hit(endings)


	_newState(GameState.GunFlash)
	colorRect.color=gunFlashColor
	colorRect.color.a=1
	endings.loadEndingVisuals()
	crosshairSpring.visible=false
