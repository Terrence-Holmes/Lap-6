class_name RC_Pause


########################################
## SET BITMAP HERE #####################
########################################

## Pause bitmap
static var pauseState : int = 0

## Possible values of soft pause state. Due to 2^32 being the max value of a signed int, 32 is the max number of enum
## values supported.
enum PauseState {
	PLAY = 0,
	NOT_RACING = 1 << 0,
	PLAYER_PAUSED = 1 << 1,
}





########################################
## DELEGATES ###########################
########################################

#Invokes when the game is paused
static var onPaused : Delegate = Delegate.new()

#Invokes when the game is unpaused
static var onUnpaused : Delegate = Delegate.new()

#Invokes when PLAYER_PAUSING is paused
static var onPlayerPaused : Delegate = Delegate.new()

#Invokes when PLAYER_PAUSING is unpaused
static var onPlayerUnpaused : Delegate = Delegate.new()




########################################
## GETTERS #############################
########################################

static var isPaused : bool:
	get:
		return pauseState != PauseState.PLAY

static var lastPauseTime : int = 0




########################################
## PAUSE FUNCTIONS #####################
########################################

static func set_pause(_pauseState : PauseState, value : bool):
	var prevPause : int = pauseState
	
	##Set pause to true
	if (value):
		#Set pause
		pauseState = pauseState | _pauseState
	##Set pause to false
	else:
		var inverseState = Math.MAX_INT ^ _pauseState
		pauseState = pauseState & inverseState
	_check_pause_delegates(prevPause)


static func get_pause(_pauseState : PauseState) -> bool:
	return (pauseState & _pauseState)


static func toggle_pause(_pauseState : PauseState):
	var prevPause : int = pauseState
	pauseState = pauseState ^ _pauseState
	_check_pause_delegates(prevPause)


static func _check_pause_delegates(prevPause : int):
	#Game was paused
	if (prevPause == PauseState.PLAY and pauseState != PauseState.PLAY):
		_just_paused()
	#Game was unpaused
	elif (prevPause != PauseState.PLAY and pauseState == PauseState.PLAY):
		_just_unpaused()
	#PLAYER_PAUSED was pause
	if (not prevPause & PauseState.PLAYER_PAUSED and pauseState & PauseState.PLAYER_PAUSED):
		onPlayerPaused.invoke()
	elif (prevPause & PauseState.PLAYER_PAUSED and not pauseState & PauseState.PLAYER_PAUSED):
		onPlayerUnpaused.invoke()

static func _just_paused():
	onPaused.invoke()
	lastPauseTime = Time.get_ticks_msec()

static func _just_unpaused():
	onUnpaused.invoke()
