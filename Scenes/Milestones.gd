extends Node


signal game_started
signal counter_1_available
signal counter_1_bought
signal counter_2_available
signal counter_3_available
signal counter_4_available
signal sacrifice_alpha_available
signal phishop_available
signal counter_5_available
signal counter_6_available
signal improved_counter_6
signal first_phi_unlock
signal second_phi_unlock
signal third_phi_unlock
signal fourth_phi_unlock
signal fifth_phi_unlock


var list = {
	"game_started": false,
	"counter_1_available": false,
	"counter_1_bought": false,
	"counter_2_available": false,
	"counter_3_available": false,
	"counter_4_available": false,
	"sacrifice_alpha_available": false,
	"phishop_available": false,
	"counter_5_available": false,
	"counter_6_available": false,
	"improved_counter_6": false,
	"first_phi_unlock": false,
	"second_phi_unlock": false,
	"third_phi_unlock": false,
	"fourth_phi_unlock": false,
	"fifth_phi_unlock": false,
}


func unlock(milestone = false):
	if !milestone:
		milestone = []
		for key in list.keys():
			if list[key]:
				milestone.append(key)
	else:
		milestone = [milestone, ]
	for key in milestone:
		emit_signal(key)
		if !list[key]:
			list[key] = $"%Player".stats.time_passed
			


func is_unlocked(milestone):
	return true if list[milestone] else false


func save():
	var data = {
		"Node": "Milestones",
		"list": list
	}
	return data


func load(data):
	list = data.list
