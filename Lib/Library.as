// *** Library ***

class Library
{

	// 5 -> "05"
	public static function TwoDigitNumber(val: Number)
	{
		if (val < 10)
			return "0" + String(val);
		else
			return String(val);
	};
	
	// Formats time to [hh:]mm[:ss]
	//	 ignoreZeroHours: - ignore hours if zero
	//   args:
	//     1) hours, mins[, secs]: current time of day. secs could be undefined
	//     2) secsOfDay: current time of day in seconds
	public static function FormatTime(ignoreZeroHours: Boolean, args)
	{
		var hours, mins, secs;
		switch (arguments.length)
		{
			case 2: // args is secsOfDay
				hours = Math.floor(arguments[1] / 3600);
				mins = Math.floor(arguments[1] % 3600 / 60);
				secs = Math.floor(arguments[1] % 3600 % 60);
				break;
			case 3: // args is hours, mins
			case 4: // args is hours, mins, secs
				hours = arguments[1];
				mins = arguments[2];
				secs = arguments[3];
				break;
			default:
				return "";
		}
		return ( (hours > 0 || !ignoreZeroHours) ? (TwoDigitNumber(hours) + ":") : "" ) +
		       TwoDigitNumber(mins) +
		       ( (secs != undefined) ? (":" + TwoDigitNumber(secs)) : "" );
	}

}