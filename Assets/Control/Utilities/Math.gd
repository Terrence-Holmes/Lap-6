extends Node
class_name Math

## max of 64-bit signed integer
const MAX_INT = 0xff_ff_ff_ff


#Returns -1 if number is negative, 1 if positive
static func pos_or_neg(num) -> int:
	return (1) if (num >= 0) else (-1)



#Returns the given angle (in degrees) clamped between 0 and 360
static func clamp_angle_degrees(degree : float) -> float:
	if (degree >= 360):
		degree -= 360
	elif (degree < 0):
		degree += 360
	
	return degree

#Returns the given angle (in radians) clamped between 0 and 360
static func clamp_angle_radians(degree : float) -> float:
	if (degree >= TAU):
		degree -= TAU
	elif (degree < 0):
		degree += TAU
	
	return degree


#Returns true if the given position is within a certain area
#pos = The position to check
#area = The area to check in; x & y = position, z & w = width/height
static func is_in_area(pos : Vector2, area : Rect2) -> bool:
	return (pos.x > area.position.x and pos.x < area.position.x + area.size.x
	and pos.y > area.position.y and pos.y < area.position.y + area.size.y)


#Returns a random result from the given array
static func random_choice(arr : Array):
	return (arr[randi() % arr.size()])


#Returns the result (from 0-1) of position 't' on a sine wave with the given aimplitude and frequency
static func sine_wave(t : float, frequency : float = 1, amplitude : float = 1) -> float:
	return ((sin(t * frequency) * amplitude) + 1) * 0.5



#ARRAYS

#Finds the given target in the given array and returns its index in the array, or returns -1 if the target is not found in the array
#NOTE: If the target is in the array multiple times, it will return the index of the first found instance of the target
static func get_index_from_array(target, array : Array):
	for i in range(array.size()):
		if (array[i] == target):
			return i
	return -1



#VECTORS AND MATRICES

static func get_forward(transform : Transform3D) -> Vector3:
	return -transform.basis.z
static func get_backward(transform : Transform3D) -> Vector3:
	return transform.basis.z
static func get_left(transform : Transform3D) -> Vector3:
	return -transform.basis.x
static func get_right(transform : Transform3D) -> Vector3:
	return transform.basis.x
static func get_down(transform : Transform3D) -> Vector3:
	return -transform.basis.y
static func get_up(transform : Transform3D) -> Vector3:
	return transform.basis.y


#Returns a Vector3, converted from a Vector2
static func vec2_to_vec3(vector : Vector2, swapYandZ : bool = false) -> Vector3:
	if (swapYandZ):
		return Vector3(vector.x, 0, vector.y)
	else:
		return Vector3(vector.x, vector.y, 0)

#Returns a Vector2, converted from a Vector3
static func vec3_to_vec2(vector : Vector3, swapYandZ : bool = false) -> Vector2:
	if (swapYandZ):
		return Vector2(vector.x, vector.z)
	else:
		return Vector2(vector.x, vector.y)


static func get_nearest_point_on_line(point : Vector2, linePointA : Vector2, linePointB : Vector2):
	var lineDirection : Vector2 = linePointA.direction_to(linePointB)
	var vectorToPoint : Vector2 = point - linePointA
	var projectionLength : float = lineDirection.dot(vectorToPoint)
	
	#Clamp projection length to stay within the line segment
	projectionLength = clamp(projectionLength, 0, linePointA.distance_to(linePointB))
	var projectionVector : Vector2 = lineDirection * projectionLength
	
	return linePointA + projectionLength * lineDirection




#TIME

#Returns true if the given number of seconds have passed since the given start time
static func timeout(secs : float, startTime : int) -> bool:
	return (float(Time.get_ticks_msec() - startTime) / 1000) >= secs

#Returns the remaining time based on the seconds and start time
static func time_left(secs : float, startTime : int) -> float:
	return (secs - (float(Time.get_ticks_msec() - startTime) / 1000))




#BINARY

# Takes in a decimal value and returns the binary value
static func decimal_to_binary(decimalValue):
	var binaryString : String = "" 
	var count : int = 31 # Check up to 32 bits 
	var temp
	
	while(count >= 0):
		temp = decimalValue >> count 
		if(temp & 1):
			binaryString = binaryString + "1"
		else:
			binaryString = binaryString + "0"
		count -= 1
	
	return int(binaryString)

# Takes in a binary value (int) and returns the decimal value (int)
static func binary_to_decimal(binaryValue):
	var decimalValue = 0
	var count : int = 0
	var temp
	
	while(binaryValue != 0):
		temp = binaryValue % 10
		binaryValue /= 10
		decimalValue += temp * pow(2, count)
		count += 1
	
	return decimalValue
