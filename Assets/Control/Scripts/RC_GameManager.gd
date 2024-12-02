extends Node2D
class_name RC_GameManager

@onready var camera : Camera2D = get_node("Camera")
@onready var levelContainer : Node2D = get_node("Levels")
@onready var uiContainer : CanvasLayer = get_node("UI")
@onready var gameUI : RC_GameUI = uiContainer.get_node("GameUI")
#Screens
@onready var scoreboard : RC_Scoreboard = uiContainer.get_node("Scoreboard")
@onready var mainMenu : RC_MainMenuUI = uiContainer.get_node("MainMenu")

@onready var screenDictionary : Dictionary = {
	"SCOREBOARD" : scoreboard,
	"CHARACTER_SELECT" : null,
	"MAIN_MENU" : mainMenu,
}




#References
static var instance : Node:
	get:
		return Engine.get_main_loop().current_scene
static var currentLevel : RC_Level = null
static var lastLevelIndex : int = -1
static var player1 : RC_RaceCar = null
static var player2 : RC_RaceCar = null
static var playerArray : Array:
	get:
		var returnArray : Array = []
		for racecar in lapDictionary:
			if (racecar != null):
				returnArray.append(racecar)
		return returnArray

#Race timers
static var raceCountdown : float = -1 #The countdown until the race starts (counts up to 3)
static var raceStartTime : float = -1
static var lastRaceTotalTime : float = 0
static var raceEndTimer : float = -1 #The countdown until the race ends (begins when the finish line is crossed by the winning racer)
static var raceEndDelayTimer : float = 0
const raceEndTimerDuration : float = 10
const raceEndDelayDuration : float = 2 #The amount of wait time before the race ends after all racers have crossed the finish line
const musicWaitDuration : float = 1
static var musicWaitTimer : float = 0

#Laps
static var lapsToWin : int = 6
static var currentPlayerLap : int:
	get:
		if (player1 != null):
			return player1.lapsComplete
		
		return -1
#A dictionary containing each racer, and each of their lap times.
# Key:value types are RC_RaceCar:Array[float]
static var lapDictionary : Dictionary = {}


#Screen change
static var currentScreen : Node = null


#Delegates
static var updateLapCountUI : Callable
static var updateTimerUI : Callable
static var beginCountdownUI : Callable
static var onGotoScreen : Delegate = Delegate.new()





func _ready():
	RC_Pause.onUnpaused.append(_on_unpause)
	
	_populate_ai_data()
	
	#await get_tree().create_timer(1).timeout
	goto_screen("MAIN_MENU")


func _populate_ai_data():
	for i in range(3):
		#Open directory at the path of this level's AIData
		var dir : DirAccess = DirAccess.open(RC_Data.AIDataFilepath + "Level" + str(i + 1) + "/")
		if (dir):
			#Iterate to the first file in the folder
			dir.list_dir_begin()
			var fileName : String = dir.get_next()
			while (fileName != ""): #Continue until there are no more files to iterate to
				if (not dir.current_is_dir()):
					#Get the time within the file name and convert it to a float
					var dataTimeString : String = fileName.right(  -(fileName.rfind("_") + 1)  ).trim_suffix(".json")
					var dataTime : float = dataTimeString.to_float()
					#Set difficulty
					var diffictulyIndex : int = 2
					if (dataTime > RC_Data.difficultyMaxTime[i].y):
						diffictulyIndex = 0
					elif (dataTime > RC_Data.difficultyMaxTime[i].x):
						diffictulyIndex = 1
					
					RC_InputRecorder.AIData[i][diffictulyIndex].append(fileName)
				
				#Iterate to the next file in the folder
				fileName = dir.get_next()
		else:
			printerr("RC_GameManager._populate_ai_data() :: Unable to find the AIData directory at '" + (RC_Data.AIDataFilepath + "Level1/") + "'."  )
	
	#print(AIData)


func _process(delta):
	_detect_pause()
	_update_timers()





func _detect_pause():
	if (Input.is_action_just_pressed("Pause") and currentLevel != null):
		RC_Pause.toggle_pause(RC_Pause.PauseState.PLAYER_PAUSED)


func _update_timers():
	if (not RC_Pause.isPaused):
		#Race timer UI
		if (raceStartTime >= 0):
			updateTimerUI.call()
	
	if (not RC_Pause.get_pause(RC_Pause.PauseState.PLAYER_PAUSED)):
		#Real countdown timer (Not UI)
		if (raceCountdown >= 0):
			raceCountdown += get_process_delta_time()
			#Timeout
			if (raceCountdown >= 3):
				_begin_race()
		
		#Real game end timer (Not UI)
		if (raceEndTimer >= 0):
			#If all racers are complete, no reason to continue the countdown
			var racersComplete = true
			for racecar in lapDictionary:
				if (not racecar.raceComplete):
					racersComplete = false
					break
			if (racersComplete):
				raceEndTimer = -1
				raceEndDelayTimer = raceEndDelayDuration
				return
			
			var lastRaceEndTimer : float = raceEndTimer
			
			raceEndTimer += get_process_delta_time()
			
			#Timeout
			if (raceEndTimer >= raceEndTimerDuration):
				raceEndTimer = -1
				goto_screen("SCOREBOARD")
				await get_tree().create_timer(0.01).timeout
				RC_SoundManager.stop_all_with_bus("SFX")
			#Play timer beep
			elif (floor(lastRaceEndTimer) != floor(raceEndTimer)):
				RC_SoundManager.play("LetterChange", true, 1.7)
	
	##END THE GAME
	if (raceEndDelayTimer > 0):
		raceEndDelayTimer -= get_process_delta_time()
		#Timeout
		if (raceEndDelayTimer <= 0):
			raceEndDelayTimer = 0
			goto_screen("SCOREBOARD")
			await get_tree().create_timer(0.01).timeout
			RC_SoundManager.stop_all_with_bus("SFX")
	
	#Music wait timer
	if (musicWaitTimer > 0 and not RC_Pause.get_pause(RC_Pause.PauseState.PLAYER_PAUSED)):
		musicWaitTimer -= get_process_delta_time()
		#Timeout
		if (musicWaitTimer <= 0):
			musicWaitTimer = 0
			RC_SoundManager.play("RaceMusic")






static func start_level(levelIndex : int, players : Array[int], cpus : Array[int]):
	if (levelIndex >= RC_Data.levelPrefabs.size()):
		printerr("RC_GameManager.start_level :: The given 'levelIndex' is below 0, OR larger than the number of levels in the 'Levels' container.")
		return
	
	#Disable current screen
	currentScreen.visible = false
	if (currentScreen.has_method("deactivate")):
		currentScreen.deactivate()
	
	lapDictionary = {}
	#Create the level
	var newLevel : Node2D = RC_Data.levelPrefabs[levelIndex].instantiate()
	newLevel.set_script(RC_Data.levelScript)
	currentLevel = newLevel
	lastLevelIndex = levelIndex
	#currentLevel = instance.levelContainer.get_child(levelIndex)
	instance.levelContainer.add_child(currentLevel)
	
	#Activate level
	currentLevel.activate(players, cpus)
	currentScreen = currentLevel
	
	#Enable gameplay UI
	instance.gameUI.set_display("GAMEPLAY")
	
	_begin_countdown()
	

static func _begin_countdown():
	RC_Pause.set_pause(RC_Pause.PauseState.NOT_RACING, true)
	beginCountdownUI.call()
	raceCountdown = 0


static func _begin_race():
	RC_Pause.set_pause(RC_Pause.PauseState.NOT_RACING, false)
	raceCountdown = -1
	updateLapCountUI.call()
	raceStartTime = Time.get_ticks_msec()
	musicWaitTimer = musicWaitDuration
	
	for car in lapDictionary:
		car.lapStartTime = raceStartTime


static func _on_pause():
	pass

static func _on_unpause():
	raceStartTime += Time.get_ticks_msec() - RC_Pause.lastPauseTime



static func start_end_countdown():
	if (raceEndTimer == -1):
		raceEndTimer = 0


static func end_game():
	RC_Pause.set_pause(RC_Pause.PauseState.NOT_RACING, true)
	lastRaceTotalTime = Time.get_ticks_msec() - raceStartTime
	raceStartTime = -1
	#Just in case
	raceCountdown = -1



static func goto_screen(screenKey : String):
	#Deactivate old screen
	if (currentScreen != null and currentScreen.has_method("deactivate")):
		currentScreen.deactivate()
	
	#End game if a level is running
	if (currentLevel != null):
		currentLevel.queue_free()
		#currentLevel.deactivate()
		currentLevel = null
		end_game()
	
	#Make old current screen invisible
	if (currentScreen != null):
		currentScreen.visible = false
	
	#Create the character select screen if needed
	if (screenKey == "CHARACTER_SELECT"):
		if (instance.screenDictionary[screenKey] == null):
			instance.screenDictionary[screenKey] = RC_Data.characterSelectPrefab.instantiate()
			instance.uiContainer.add_child(instance.screenDictionary[screenKey])
	else:
		if (instance.screenDictionary["CHARACTER_SELECT"] != null):
			instance.screenDictionary["CHARACTER_SELECT"].queue_free()
			instance.screenDictionary["CHARACTER_SELECT"] = null
	
	#Set new current screen
	currentScreen = instance.screenDictionary[screenKey]
	currentScreen.visible = true
	
	#Activate new current screen
	if (currentScreen.has_method("activate")):
		currentScreen.activate()
	
	#Set GameUI display
	instance.gameUI.set_display("HIGHSCORE")
	
	#Execute delegate
	onGotoScreen.invoke()




#BUTTON SOUNDS

static func _button_hovered():
	RC_SoundManager.play("MouseHover", true)

static func _button_pressed():
	RC_SoundManager.play("MouseClick", true)

