// Infobar for Cowon player UI
// © Fr0sT

import Library;

class TInfoBar extends MovieClip
{
	private var fInited: Boolean;
	private var fAmPm: Boolean = true;
	private var fTxTime: TextField;
	private var fTxVol: TextField;

	public function TInfoBar()
	{
	}

	private function init(): Void 
	{
		fTxTime = this["TXTime"];
		fTxVol = this["MCVol"]["TXVol"];
		fInited = true;
	}
	
	public function setTime(hours, mins, ampm)
	{
		if (fInited == undefined || !fInited)
			init();
		// prepare values
		var sAmpm = "";
		if (ampm)
		{
			if (hours < 12)
				sAmpm = " am"
			else
			{
				sAmpm = " pm"
				if (hours != 12)
					hours -= 12;
			} // end else if
		}
		// resize the bar and move time label if am/pm mode changed
		if (fAmPm != ampm)
		{
			var shift = (ampm ? 1 : -1)*20;
			this["MCBg"]._width += shift;
			this["MCBg"]._x += (-shift);
			this["TXTime"]._x += (-shift);
		
			fAmPm = ampm;
		}
		
		fTxTime.text = Library.FormatTime(false, hours, mins) + sAmpm;
	}

	public function setVol(vol)
	{
		if (fInited == undefined || !fInited)
			init();
		fTxVol.text = Library.TwoDigitNumber(int(vol));
	}
}