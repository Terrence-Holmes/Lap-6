class_name RC_InputRecorder


static var json = JSON.new()
const pathTemplate : String = RC_Data.AIDataFilepath

#The file names of all possible AIData options for the CPU to be assigned to.
#To retrieve AIData, call AIData[level][difficulty] and you will recieve an array of file names.
static var AIData : Array = [
	[  [], [], []  ], #Level1 [easy, medium, hard]
	[  [], [], []  ], #Level2 [easy, medium, hard]
	[  [], [], []  ]] #Level3 [easy, medium, hard]


static func save_data(content : Array, fileName : String):
	var path : String = pathTemplate + "AIData_" + fileName + ".json"
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(content)
	print("AI input data saved: " + fileName)
	file.close()
	file = null



static func load_data(fileName : String, levelIndex : int) -> Array:
	var filepath : String = str(pathTemplate + "Level" + str(levelIndex + 1) + "/")
	var path : String = filepath + fileName
	if (FileAccess.file_exists(path)):
		var file : FileAccess = FileAccess.open(path, FileAccess.READ)
		var returnArray : Array = file.get_var()
		#print("AI input data loaded {\n      File name: " + fileName + "\n      Data: " + str(returnArray))
		return returnArray
	return []
