class_name Delegate

var methods : Array[Callable] = []

var size : int:
	get:
		return methods.size()


#ACTIONS

## Appends the given callable to the delegate
func append(callable : Callable):
	if (not methods.has(callable)):
		methods.append(callable)


## Removes the FIRST instance of the given callable in the delegate
func remove(callable : Callable):
	for i in range(methods.size()):
		if (methods[i].get_object_id() == callable.get_object_id() and
			methods[i].get_method() == callable.get_method()):
			methods.remove_at(i)
			return


## Calls all methods in the delegate
func invoke(argument = null):
	var methodsToRemove = []
	for i in range(methods.size()):
		#If method's class is no longer available, don't call
		if not methods[i].is_valid():
			methodsToRemove.append(methods[i])
			continue
		if (argument == null):
			methods[i].call()
		else:
			methods[i].call(argument)
	for method in methodsToRemove:
		remove(method)



#RETURNS

## Returns true if this delegate contains the given method
func contains(callable : Callable) -> bool:
	return methods.has(callable)
