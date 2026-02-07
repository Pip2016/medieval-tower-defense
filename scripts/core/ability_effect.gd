@tool
class_name AbilityEffect
extends Resource

## A single effect applied by an ability (slow, DOT, stun, etc.)

enum EffectType { DAMAGE, SLOW, STUN, DOT, HEAL, BUFF_TOWERS }

@export var effect_type: EffectType = EffectType.DAMAGE
@export var value: float = 0.0
@export var duration: float = 3.0
@export var tick_interval: float = 1.0
