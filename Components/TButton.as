// MovieClip descendant with button functionality
// May contain multiple modes (looks), for example Play/Pause, Fullscreen/Window/Minimized, etc.
// © Fr0sT
//
//                      Usage:
// 
// 1) Take MC named, for instance, MC_YourMCName
// 2) Define frames named "!up", "!down", "!over" (optional) and "!disabled" (optional)
// 3) Define the class of the MC: TButton
// 4) _root["MC_YourMCName"].onClick = function() ...

class TButton extends MovieClip
{
	// Button state codes
	private static var STATE_UP       = 0;
	private static var STATE_OVER     = 1;
	private static var STATE_DOWN     = 2;
	private static var STATE_DISABLED = 3;

	// Frame labels for button states. Start with "!" to not interfere with standard Flash "_" constants
	private static var FrameLabels = new Array("!up", "!over", "!down", "!disabled");

	// public fields
	public var repeatPress: Boolean = false;   // fire the onRepeatPress event periodically
	public var strictClick: Boolean = true;    // do not consider DragOut and ReleaseOutside as click
	public var repeatInterv = 1000;            // onRepeatPress event launch interval
	public var autoChangeMode: Boolean = true; // auto shift the mode on click
	public var onClick = null;
	public var onRepeatPress = null;	
	// accessible via get/set methods:
	// var Enabled: Boolean [RW]
	// var wasRepeatPress: Boolean [R]
	// var modeCount: Number [RW]
	// var currMode: Number [RW]
	
	// private fields
	private var fPressTime = 0; // press time counter
	private var fCurrState;
	private var fOverFramePresent: Array; // whether "over" frame exists
	private var fWasRepeatPress: Boolean = false;   // whether onRepeatPress event has been launched
	private var fModeCount: Number = 1;
	private var fCurrMode: Number = 0;
	
	public function TButton()
	{
		fOverFramePresent = new Array();
		setState(STATE_UP);
		onPress = doPress;
		onRelease = doRelease;
		onDragOut = onReleaseOutside = doLeave;
		onRollOut = function()
		{
			setState(STATE_UP);
		}
		onRollOver = function()
		{
			// check if "over" frame exists. Just remember current frame index, try going to the
			// "over" frame and check if current frame index changed
			if (fOverFramePresent[fCurrMode] == undefined)
			{
				var currFrame = _currentframe;
				setState(STATE_OVER);
				fOverFramePresent[fCurrMode] = (currFrame != _currentframe);
			}
			// go to the "over" frame only when it exists, go to "up" frame otherwise
			else
				setState(fOverFramePresent[fCurrMode] ? STATE_OVER : STATE_UP);
		}
	}
	
	// set a new state (and go to appropriate frame)
	private function setState(state)
	{
		if (!Enabled) return; // ! block changes if button is disabled - to prevent state change if button gets disabled in onClick
		var modeSuffix = (fCurrMode == 0 ? "" : String(fCurrMode));
		fCurrState = state;
		gotoAndStop(FrameLabels[fCurrState]+modeSuffix);
	}
	
	// mouse is pressed
	private function doPress()
	{
		setState(STATE_DOWN);
		if (repeatPress && onRepeatPress != undefined)
		{
			fPressTime = getTimer();
			onEnterFrame = doEnterFrame;
		}
	}
	
	// mouse is released outside the button
	private function doLeave()
	{
		doClick(!strictClick);
		setState(STATE_UP);
	}
	
	// mouse is released over the button
	private function doRelease()
	{
		doClick(true);
		setState(fOverFramePresent[fCurrMode] ? STATE_OVER : STATE_UP);
	}
	
	// release the button (launch onClick if clicked == true)
	private function doClick(clicked: Boolean)
	{
		fPressTime = 0;
		delete this.onEnterFrame;
		if (clicked)
		{
			// change the mode
			if (autoChangeMode)
			{
				if (fCurrMode == fModeCount - 1)
					fCurrMode = 0;
				else
					fCurrMode++;
			}
			// launch the handler
			if (onClick)
				onClick();
		}
		fWasRepeatPress = false;
	}

	// periodical function
	private function doEnterFrame()
	{
		if (getTimer() - fPressTime > repeatInterv)
		{
			fPressTime = getTimer();
			if (onRepeatPress)
			{
				fWasRepeatPress = true;
				onRepeatPress();
			}
		}
	};
	
	// enable/disable the button; changes current frame to appropriate one
	public function set Enabled(val: Boolean): Void
	{
    	setState(val ? STATE_UP : STATE_DISABLED);
    	enabled = val;
	}

	public function get Enabled(): Boolean
	{
		return enabled;
	}
	
	// 
	public function get wasRepeatPress(): Boolean
	{
		return fWasRepeatPress;
	}
	
	// get/set a number of button modes	
	public function get modeCount(): Number
	{
		return fModeCount;
	}
	
	public function set modeCount(val: Number): Void
	{
		if (fModeCount == val) return;
		fModeCount = val;
		for (var i in fOverFramePresent)
			fOverFramePresent[i] = undefined;
		currMode = 0;
	}
	
	// get/set current button mode
	public function get currMode(): Number
	{
		return fCurrMode;
	}
	
	public function set currMode(val: Number): Void
	{
		if (fCurrMode == val) return;
		fCurrMode = val;
		setState(fCurrState);		
	}
}