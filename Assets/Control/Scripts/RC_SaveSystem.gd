extends Node
class_name RC_SaveSystem


static var json = JSON.new()
static var filepath : String = "user://HighScoreData.json"


static var data : Dictionary = {
	"HIGHSCORE_1" : 0.0,
	"HIGHSCORE_2" : 0.0,
	"HIGHSCORE_3" : 0.0,
	"HIGHSCORE_1_NAME" : "",
	"HIGHSCORE_2_NAME" : "",
	"HIGHSCORE_3_NAME" : "",
}


static func save_data(dataKey : String, content):
	if (data.has(dataKey)):
		data[dataKey] = content
		_save_to_storage(data)
	else:
		printerr("RC_SaveSystem.save_data() :: An invalid dataKey was given, that doesn't match any of the keys from the 'data' dictionary.")

#Updates the data dictionary with the saved data or creates new save data if none exists
static func update_data():
	#File doesn't exist; Create a new one
	if (_load_from_storage() == {}):
		_save_to_storage(data)

#Updates the data dictionary with the saved data and returns the data assigned to the given key
static func get_data(dataKey : String):
	#File doesn't exist; Create a new one
	if (_load_from_storage() == {}):
		_save_to_storage(data)
	#Make sure the given data key exists
	if (data.has(dataKey)):
		return data[dataKey]
	else:
		printerr("RC_SaveSystem.get_data() :: The given dataKey (" + dataKey + ") does not exist in the data dictionary.")
		return null


static func _save_to_storage(content : Dictionary):
	var file : FileAccess = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_var(content)
	file.close()
	file = null


static func _load_from_storage() -> Dictionary:
	if (FileAccess.file_exists(filepath)):
		var file : FileAccess = FileAccess.open(filepath, FileAccess.READ)
		data = file.get_var()
		file.close()
		return data
	return {}

