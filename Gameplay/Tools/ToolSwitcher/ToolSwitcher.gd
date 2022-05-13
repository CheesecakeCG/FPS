extends Node

var tools : Array[PlayerTool]

var current_tool_index : int = 0
var current_tool : PlayerTool:
	get:
		return tools[current_tool_index]

	
