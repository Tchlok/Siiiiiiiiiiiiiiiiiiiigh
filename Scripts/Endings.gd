class_name Endings
extends Node2D

var flagHitLepus : bool
var flagHitCiv : bool
var flagHitBottle : bool
var flagHitMoon : bool
var flagGunFired : bool

@export var sprite : Sprite2D
@export var title : RichTextLabel
@export var commentLabel : RichTextLabel

var mainTarget : Target
@export var nearMissThreshold : float = 300
@export var commentFallback : String



func resetEndingFlags():
	flagHitCiv=false
	flagHitLepus=false
	flagHitBottle=false
	flagHitMoon=false
	flagGunFired=false
func loadEndingVisuals():
	if visible==true:
		return
	visible=true
	if not flagGunFired:
		_endingExpired()
		return
	
	if flagHitCiv:
		_endingCiv()
		return
	if flagHitLepus:
		_endingLepus()
		return
	if flagHitBottle:
		_endingBottle()
		return
	if flagHitMoon:
		_endingMoon()
		return

	if global_position.distance_to(mainTarget.global_position+Vector2.UP*250)<=nearMissThreshold:
		_endingNearMiss()
	else:
		_endingMiss()

var narratorRagequit : bool = false
@export var commentsCiv : Array[String]
var cIdxCiv : int = 0
@export var _civTex : Array[Texture2D]
func _endingCiv():
	var comment : String
	if cIdxCiv>=commentsCiv.size():
		comment=commentFallback
	else:
		comment=commentsCiv[cIdxCiv]
		cIdxCiv+=1
	_displayEnding(_civTex.pick_random(),"CIVILIAN ELIMINATED", comment)
	if cIdxCiv>=commentsCiv.size():
		narratorRagequit=true

@export var commentsLepus : Array[String]
@export var _lepusTex : Array[Texture2D]
func _endingLepus():
	var comment : String = commentsLepus.pick_random()
	_displayEnding(_lepusTex.pick_random(), "TARGET ELIMINATED", comment)

@export var commentsNearMiss : Array[String]
var cIdxNearMiss : int = 0
@export var _nearMissTex : Texture2D
func _endingNearMiss():
	var comment : String
	if cIdxNearMiss>=commentsNearMiss.size():
		comment=commentFallback
	else:
		comment=commentsNearMiss[cIdxNearMiss]
		cIdxNearMiss+=1
	_displayEnding(_nearMissTex, "NEAR MISS", comment)

@export var commentsMiss : Array[String]
var cIdxMiss : int = 0
@export var _missTex : Texture2D
func _endingMiss():
	var comment : String
	if cIdxMiss>=commentsMiss.size():
		comment=commentFallback
	else:
		comment=commentsMiss[cIdxMiss]
		cIdxMiss+=1
	_displayEnding(_missTex, "COMPLETE MISS", comment)

@export var commentsBottle : Array[String]
var cIdxBottle : int = 0
@export var _bottleTex : Texture2D
func _endingBottle():
	var comment : String
	if cIdxBottle>=commentsBottle.size():
		comment=commentFallback
	else:
		comment=commentsBottle[cIdxBottle]
		cIdxBottle+=1
	_displayEnding(_bottleTex, "BOTTLE ELIMINATED", comment)

@export var commentsMoon : Array[String]
var cIdxMoon : int = 0
@export var _moonTex : Texture2D
func _endingMoon():
	var comment : String
	if cIdxMoon>=commentsMoon.size():
		comment=commentFallback
	else:
		comment=commentsMoon[cIdxMoon]
		cIdxMoon+=1
	_displayEnding(_moonTex, "MOON ELIMINATED", comment)

@export var commentsExpired : Array[String]
var cIdxExpired : int = 0
@export var _expiredTex : Texture2D
func _endingExpired():
	var comment : String
	if cIdxExpired>=commentsExpired.size():
		comment=commentFallback
	else:
		comment=commentsExpired[cIdxExpired]
		cIdxExpired+=1
	_displayEnding(_expiredTex, "TIME EXPIRED", comment)

func _displayEnding(_tex : Texture2D, _title : String, _comment : String):
	sprite.texture=_tex
	title.text="[center]"+_title
	if narratorRagequit:
		commentLabel.text=""
	else:
		commentLabel.text="[center]"+_comment
