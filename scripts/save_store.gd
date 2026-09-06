class_name SaveStore
## Reads and writes the save file. Knows nothing about what is in it.

const PATH := "user://save.json"

static func write(data: Dictionary) -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not write save file: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data))

## Returns an empty Dictionary when there is no save or it is unreadable.
static func read() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		return parsed
	push_warning("Ignoring corrupt save file at %s" % PATH)
	return {}
