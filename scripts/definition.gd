extends Panel

@onready var word_list_container := $VBoxContainer

func add_word_to_list(word: String):
	var hbox := HBoxContainer.new()

	var label := Label.new()
	label.text = word
	hbox.add_child(label)

	var button := Button.new()
	button.text = "▼"
	button.connect("pressed", Callable(self, "_on_definition_button_pressed").bind(word))
	hbox.add_child(button)

	word_list_container.add_child(hbox)

func _on_definition_button_pressed(word):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", Callable(self, "_on_kbbi_request_completed").bind(word))
	var url = "https://kbbi.raf555.dev/api/v1/entry/" + word.to_lower()
	http_request.request(url)

func _on_kbbi_request_completed(result, response_code, headers, body, word):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("entries") and json.entries.size() > 0:
			var definitions = json.entries[0].definitions
			var definition_text = ""

			for def in definitions:
				var label_text := ""
				if def.has("labels"):
					for label in def["labels"]:
						label_text += "[" + label.get("name", "") + "] "

				var arti = str(def.get("definition", ""))
				definition_text += "- " + label_text + arti + "\n"

			show_popup_definition(word, definition_text)
		else:
			show_popup_definition(word, "Definisi tidak ditemukan di KBBI.")
	else:
		show_popup_definition(word, "Gagal mengambil definisi dari KBBI.")


func show_popup_definition(word, definition):
	var popup = AcceptDialog.new()
	popup.dialog_text = word + ":\n" + definition
	add_child(popup)
	popup.popup_centered()
