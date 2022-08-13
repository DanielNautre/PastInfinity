extends Node

export (Resource) var alpha
export (Resource) var phi


var stats = {
	"time_passed": 1,
	"number_clicked": 0,
	"phi_sacrifices_overall": 0,
	"phi_sacrifices_this_round": 0,
}



func save():
	var data = {
		"Node": "Player",
		"alpha": alpha.serialize(),
		"phi": phi.serialize(),
		"stats": stats,
	}
	return data


func load(data):
	alpha.restore(data.alpha)
	phi.restore(data.phi)
	stats = data.stats


func _on_Milestones_counter_1_bought():
	alpha.counter_1_bought = true
