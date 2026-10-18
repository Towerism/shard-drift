extends CanvasLayer
## Heads-up display. It only shows what main.gd tells it and emits nothing.

@onready var score_label: Label = $ScoreLabel
@onready var best_label: Label = $BestLabel
@onready var dash_bar: ProgressBar = $DashBar
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var final_label: Label = $GameOverPanel/FinalLabel


func set_score(n: int) -> void:
	score_label.text = "Score: %d" % n


func set_best(n: int) -> void:
	best_label.text = "Best: %d" % n


func set_dash_ratio(r: float) -> void:
	dash_bar.value = r


func show_game_over(score: int, best: int, new_best: bool) -> void:
	var lines := PackedStringArray(["Score: %d" % score, "Best: %d" % best])
	if new_best:
		lines.append("New best!")
	lines.append("Press Space to play again")
	final_label.text = "\n".join(lines)
	game_over_panel.show()
