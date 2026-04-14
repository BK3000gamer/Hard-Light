extends Area3D

func _on_body_entered(body: Node) -> void:
	print("Body entered detection area: ", body.name)
	if body.is_in_group("monsters"):
		print("Monster entered detection area: ", body.name)
		var monster = body as Monster
		monster.catch_player()
