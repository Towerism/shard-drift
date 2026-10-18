extends RefCounted


func test_ready_at_start(t) -> void:
	var d := DashState.new()
	t.eq(d.cooldown_ratio(), 1.0, "ratio")
	t.eq(d.is_dashing(), false, "dashing")
	t.eq(d.is_invulnerable(), false, "invulnerable")


func test_dash_starts_all_three_timers(t) -> void:
	var d := DashState.new()
	t.eq(d.try_dash(), true, "dash")
	t.eq(d.is_dashing(), true, "dashing")
	t.eq(d.is_invulnerable(), true, "invulnerable")
	t.eq(d.cooldown_ratio(), 0.0, "ratio")


func test_dash_ends_before_invulnerability(t) -> void:
	var d := DashState.new()
	d.try_dash()
	d.tick(DashState.DASH_TIME + 0.01)
	t.eq(d.is_dashing(), false, "dash over")
	t.eq(d.is_invulnerable(), true, "still invulnerable")
	d.tick(DashState.INVULNERABLE_TIME - DashState.DASH_TIME)
	t.eq(d.is_invulnerable(), false, "invulnerability over")


func test_cooldown_refuses_until_it_runs_out(t) -> void:
	var d := DashState.new()
	d.try_dash()
	d.tick(DashState.COOLDOWN / 2.0)
	t.eq(d.cooldown_ratio(), 0.5, "halfway")
	t.eq(d.try_dash(), false, "refused halfway")
	d.tick(DashState.COOLDOWN / 2.0 - 0.01)
	t.eq(d.try_dash(), false, "refused just before")
	d.tick(0.02)
	t.eq(d.try_dash(), true, "allowed just after")


func test_cooldown_counts_from_the_press(t) -> void:
	var d := DashState.new()
	d.try_dash()
	for i: int in int(DashState.COOLDOWN / 0.25):
		t.eq(d.try_dash(), false, "refused at tick %d" % i)
		d.tick(0.25)
	t.eq(d.cooldown_ratio(), 1.0, "ratio when ready")
	t.eq(d.try_dash(), true, "allowed exactly at COOLDOWN")
