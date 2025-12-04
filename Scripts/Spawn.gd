class_name Spawn
extends Node2D

@export var layouts : Array[PackedScene]
@export var spawnPointUsageRatio : float
@export var mainTargetPacked : PackedScene
@export var civTargets : Array[PackedScene]

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

	

	var usedSpawnPointsCount : int = spawnPoints.size()*spawnPointUsageRatio-1
	print(str(spawnPoints.size())+"   "+str(usedSpawnPointsCount))

	for i in usedSpawnPointsCount:
		_spawnTarget(civTargets.pick_random(),spawnPoints.pick_random(),true)
	
	return mainTar

func _spawnTarget(packed : PackedScene, point : Node2D , remove : bool):
	var tar : Target = packed.instantiate()
	point.add_child(tar)
	#tar.global_position=point.global_position
	if remove:
		spawnPoints.erase(point)
	return tar
