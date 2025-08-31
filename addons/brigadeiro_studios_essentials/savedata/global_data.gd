extends Node

# Caminho do arquivo global
const SAVE_PATH := "user://save_slots/global_data.json"

# Dados globais
var endings: Array[String] = []
var achievements: Array[String] = []
var one_shot: int = 0

func _ready() -> void:
	_ensure_save_folder()
	load_save_data()  # Carrega ao iniciar

# -------------------- Interface Pública --------------------

# Desbloqueia um ending
func unlock_ending(ending_id: String) -> void:
	if ending_id in endings:
		print("Final já desbloqueado:", ending_id)
		return
	endings.append(ending_id)
	save_data()
	print("Final desbloqueado:", ending_id)

# Verifica se um ending já foi desbloqueado
func has_ending(ending_id: String) -> bool:
	return ending_id in endings

# Salva o one-shot se for maior que o atual
func save_one_shot(one_shot_id: int) -> void:
	if one_shot_id > one_shot:
		one_shot = one_shot_id
		save_data()
		print("One-shot salvo:", one_shot_id)
	else:
		print("One-shot já registrado ou menor.")

func add_achievement(achievement_id: String) -> void:
	if achievement_id in achievements:
		print("Conquista já desbloqueado:", achievement_id)
		return
	achievements.append(achievement_id)
	save_data()
	print("Conquista desbloqueado:", achievement_id)

func has_achievement(achievement_id: String) -> bool:
	return achievement_id in achievements

# Reseta todos os dados globais
func reset_data() -> void:
	_reset_data()
	save_data()
	print("Todos os dados globais foram resetados.")

# -------------------- Salvamento/Carregamento --------------------

func load_save_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Arquivo de dados globais não encontrado. Criando novo.")
		_reset_data()
		save_data()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		var data = JSON.parse_string(content)
		if typeof(data) == TYPE_DICTIONARY:
			# converte para Array[String] usando loop normal
			endings.clear()
			for e in data.get("endings", []):
				endings.append(str(e))
			achievements.clear()
			for e in data.get("achievements", []):
				achievements.append(str(e))
			
			one_shot = int(data.get("one_shot", 0))
			print("Dados globais carregados. Endings:", endings, "One-shot:", one_shot)
		else:
			print("Arquivo corrompido. Resetando.")
			_reset_data()
			save_data()

func save_data() -> void:
	_ensure_save_folder()
	var data = {
		"endings": endings,
		"achievements": achievements,
		"one_shot": one_shot
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()
		print("Dados globais salvos com sucesso.")

# -------------------- Utilitários internos --------------------

func _ensure_save_folder() -> void:
	var folder := "user://save_slots/"
	if not DirAccess.dir_exists_absolute(folder):
		DirAccess.make_dir_absolute(folder)

func _reset_data() -> void:
	endings = []
	achievements = []
	one_shot = 0
