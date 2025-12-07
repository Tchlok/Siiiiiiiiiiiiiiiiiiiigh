class_name Target
extends Area2D

enum TargetType{Civ,Main,Bottle,Moon}
@export var targetType : TargetType

func _ready():
    if randf()>0.5:
        scale*=Vector2(-1,1)

func hit(endings : Endings):
    match targetType:
        TargetType.Civ:
            endings.flagHitCiv=true
        TargetType.Main:
            endings.flagHitLepus=true
        TargetType.Bottle:
            endings.flagHitBottle=true
        TargetType.Moon:
            endings.flagHitMoon=true