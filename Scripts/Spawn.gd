class_name Spawn
extends Node2D

@export var layouts : Array[PackedScene]
@export var spawnPointUsageRatio : float
@export var mainTargetPacked : PackedScene
@export var civTargets : Array[PackedScene]
@export var bottleSpawnCount : int = 2
@export var bottleTarget : PackedScene
@export var moonTarget : PackedScene


var spawnPoints : Array[Node2D]
var curLayout : Node2D

func spawn():
	if curLayout!=null:
		curLayout.queue_free()
		curLayout=null
	spawnPoints.clear()
	var layoutPacked : PackedScene = layouts.pick_random()
	var layout:Node2D = layoutPacked.instantiate()
	if randf()>0.5:
		layout.scale*=Vector2(-1,1)
	curLayout = layout

	# front layer
	for sp in layout.get_child(0).get_child(0).get_children():
		spawnPoints.append(sp)
	# back layer
	for sp in layout.get_child(1).get_child(0).get_children():
		spawnPoints.append(sp)

	

	add_child(layout)

	var mainTar = _spawnTarget(mainTargetPacked,spawnPoints.pick_random(),true)

	

	var usedSpawnPointsCount : int = spawnPoints.size()*spawnPointUsageRatio
	print(str(spawnPoints.size())+"   "+str(usedSpawnPointsCount))

	for i in usedSpawnPointsCount:
		_spawnTarget(civTargets.pick_random(),spawnPoints.pick_random(),true)
	
	var bottleSpawnPoints : Array[Node2D]
	for sp in layout.get_child(0).get_child(1).get_children():
		bottleSpawnPoints.append(sp)
	for sp in layout.get_child(1).get_child(1).get_children():
		bottleSpawnPoints.append(sp)

	for i in bottleSpawnCount:
		var p : Node2D = bottleSpawnPoints.pick_random()
		bottleSpawnPoints.erase(p)
		var bottle : Node2D = bottleTarget.instantiate()
		if randf()>0.5:
			bottle.scale*=Vector2(-1,1)
		p.add_child(bottle)


	var moon : Node2D = moonTarget.instantiate()
	if randf()>0.5:
		moon.scale*=Vector2(-1,1)
	layout.get_child(2).get_children().pick_random().add_child(moon)

	return mainTar

func _spawnTarget(packed : PackedScene, point : Node2D , remove : bool):
	var tar : Target = packed.instantiate()
	point.add_child(tar)
	#tar.global_position=point.global_position
	if remove:
		spawnPoints.erase(point)
	return tar
