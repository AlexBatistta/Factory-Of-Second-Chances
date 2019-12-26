extends Camera2D

# Script modificado, originalmente desarrollado por Game Endeavor
# https://www.youtube.com/watch?v=_DAvzzJMko8

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

export (int, 0, 25) var amplitude = 5
export (float, 0, 1) var duration = 0.2
export (int, 0, 25) var frequency = 15

func _ready():
	Global.connect("shake", self, "start")

func start():
	$Duration.wait_time = duration
	$Frequency.wait_time = 1 / float(frequency)
	
	$Duration.start()
	$Frequency.start()
	
	_new_shake()

func _new_shake():
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	$ShakeTween.interpolate_property(self, "offset", offset, rand, $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _reset():
	$ShakeTween.interpolate_property(self, "offset", offset, Vector2(), $Frequency.wait_time, TRANS, EASE)
	$ShakeTween.start()

func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
