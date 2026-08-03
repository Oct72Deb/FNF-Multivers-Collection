class WeekbUnlock
{
	public static inline var HIDDEN_WEEK_NAME:String = "weekb";
	public static var CONDITION_SONGS:Array<String> = ["how-to-play", "metal-reflection"];
	public static inline var THRESHOLD:Float = 0.9;

	// diffCount = nombre de difficultés à tester (celles de "weeka")
	public static function isUnlocked(diffCount:Int):Bool
	{
		var total:Float = 0;

		for (song in CONDITION_SONGS)
		{
			var best:Float = 0;
			for (diff in 0...diffCount)
			{
				var rating:Float = Highscore.getRating(song, diff);
				if (rating > best)
					best = rating;
			}
			total += best;
		}

		return (total / CONDITION_SONGS.length) >= THRESHOLD;
	}
}