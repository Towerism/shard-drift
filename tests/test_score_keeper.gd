extends RefCounted


func test_starts_at_zero_with_given_best(t) -> void:
	var s := ScoreKeeper.new(20)
	t.eq(s.score, 0, "score")
	t.eq(s.best, 20, "best")
	t.eq(s.is_new_best(), false, "no new best yet")


func test_each_shard_adds_shard_points(t) -> void:
	var s := ScoreKeeper.new(0)
	s.add_shard()
	s.add_shard()
	t.eq(s.score, ScoreKeeper.SHARD_POINTS * 2, "two shards")


func test_best_follows_score_only_after_passing_it(t) -> void:
	var s := ScoreKeeper.new(ScoreKeeper.SHARD_POINTS * 2)
	s.add_shard()
	t.eq(s.best, ScoreKeeper.SHARD_POINTS * 2, "below best")
	s.add_shard()
	t.eq(s.best, ScoreKeeper.SHARD_POINTS * 2, "tied")
	t.eq(s.is_new_best(), false, "a tie is not a new best")
	s.add_shard()
	t.eq(s.best, ScoreKeeper.SHARD_POINTS * 3, "passed")
	t.eq(s.is_new_best(), true, "new best")
