extends Control

func _ready():
	Global.muat_histori()

	var histori = Global.histori
	var panel = $Panel/GridContainer
	var label_start_index = 3

	for i in range(min(histori.size(), 10)):
		var data = histori[i]

		# Cek apakah data lengkap dan benar
		if typeof(data) != TYPE_DICTIONARY:
			continue
		if not (data.has("nama") and data.has("skor") and data.has("waktu")):
			continue

		var nama_label = panel.get_child(label_start_index + i * 3 + 0)
		var skor_label = panel.get_child(label_start_index + i * 3 + 1)
		var waktu_label = panel.get_child(label_start_index + i * 3 + 2)

		if nama_label and skor_label and waktu_label:
			nama_label.text = str(data["nama"])
			skor_label.text = str(data["skor"])

			var waktu = int(data.get("waktu", 0))
			var menit = int(waktu / 60)
			var detik = int(waktu % 60)

			waktu_label.text = "%02d:%02d" % [menit, detik]

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
