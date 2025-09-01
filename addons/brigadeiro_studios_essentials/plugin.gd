@tool
extends EditorPlugin

const LOADING_SERVICE_NAME := "LoadingService"
const LOADING_SERVICE_PATH := "res://addons/brigadeiro_studios_essentials/LoadingService.gd"

const GLOBALDATA_NAME := "GlobalData"
const ACHIEVEMENTS_PATH := "res://addons/brigadeiro_studios_essentials/savedata/global_data.gd"

func _enter_tree():
	_add_autoload(LOADING_SERVICE_NAME, LOADING_SERVICE_PATH)

func _exit_tree():
	_remove_autoload(LOADING_SERVICE_NAME)

func _add_autoload(name: String, path: String) -> void:
	if not ProjectSettings.has_setting("autoload/" + name):
		add_autoload_singleton(name, path)

func _remove_autoload(name: String) -> void:
	if ProjectSettings.has_setting("autoload/" + name):
		remove_autoload_singleton(name)
