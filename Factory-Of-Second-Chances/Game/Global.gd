tool
extends Node

func _color(type : int, dark : bool = true):
	if dark:
		match type:
			0:	return Color.red
			1:	return Color.limegreen
			2:	return Color.darkviolet
			3:	return Color.gold
	else:
		match type:
			0:	return Color.darkorange
			1:	return Color.chartreuse
			2:	return Color.mediumorchid
			3:	return Color.yellow