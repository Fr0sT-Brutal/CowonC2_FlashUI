// Popup box with optional text label (HTML tags supported), YES and NO buttons
// Requires TButton class
// © Fr0sT

/*
 TO DO
	* positioning
*/

/*************************************************
                          Usage:
 Add MCPopup component to the project
 var popup: TPopup = new TPopup();
 popup.show(TPopup.BOX_PROMPT, "Do Some Stuff?",
            function(promptResult)
            {
            	if (promptResult == TPopup.RES_YES)
            	{
            		var res = doSomeStuff();
            		popup.show( (res ? TPopup.BOX_SUCCESS : TPopup.BOX_FAIL) );
            	}
            });
 callback function could be used even with notification boxes
 (BOX_SUCCESS/BOX_FAIL) to perform some finalisation actions.
 
                      !!! ATTENTION !!!
 This class has little limitation: if there has been registered
 some mouse listeners, mouse events won't be blocked by popup
 and would be traversed to a listener. So adding a check 
 "if (popup.isActive) ... " is needed.
 
**************************************************/

class TPopup
{
	// popup types
	static var BOX_PROMPT  = 0;
	static var BOX_SUCCESS = 1;
	static var BOX_FAIL    = 2;
	// popup results
	static var RES_NO      = 0;
	static var RES_YES     = 1;
	static var RES_TIMEOUT = 2;  // when no action has been done during POPUP_TIME period
	static var RES_AREA    = 3;  // when clicked on the popup area (for BOX_FAIL/BOX_SUCCESS only)
	// other
	static var POPUP_TIME  = 3000;

	// internal fields
	private var fMCPopup: MovieClip;
	private var fType;
	private var fCallback;
	private var fTimer = 0;

	public function TPopup()
	{
	}
	
	public function get isActive(): Boolean
	{
    	return (fMCPopup != undefined && fMCPopup._visible);
	}

	public function show(type, msg: String, callback)
	{
		// some checks
		if (isActive) return;
		if ( !(type == BOX_FAIL || type == BOX_PROMPT || type == BOX_SUCCESS) ) return;
		if ( type == BOX_PROMPT && callback == undefined) return;

		fCallback = callback;
		fType = type;
		var mcBack, mcPopupWnd, mcBtnYes, mcBtnNo, btn;
		var hasMsg = (msg.length > 0);
		var btnX, btnY, btnGap;
		
		// create new clip, resize it to fill the whole stage
		fMCPopup = _root.createEmptyMovieClip("Popup", _root.getNextHighestDepth());
		mcBack = fMCPopup.attachMovie("MCBackground", "MCBackground", fMCPopup.getNextHighestDepth());
		with (fMCPopup)
		{
			_width = Stage.width;
			_height = Stage.height;
		}
		// load popup background
		mcPopupWnd = fMCPopup.attachMovie("MCPopupWnd", "MCPopupWnd", fMCPopup.getNextHighestDepth());
		with (mcPopupWnd)
		{
			_x = int((_parent._width - _width)/2);
			_y = int((_parent._height - _height)/2);
//trace(new Array(_parent, _parent._width, _parent._height, _width, _height, _x, _y));
		}

		// load button(s)
		if (fType == BOX_FAIL || fType == BOX_PROMPT)
		{
			mcBtnNo = mcPopupWnd.attachMovie("MCBtnNo", "MCBtnNo", mcPopupWnd.getNextHighestDepth());
			btn = mcBtnNo;
		}
		if (fType == BOX_SUCCESS || fType == BOX_PROMPT)
		{
			mcBtnYes = mcPopupWnd.attachMovie("MCBtnYes", "MCBtnYes", mcPopupWnd.getNextHighestDepth());
			btn = mcBtnYes;
		}

		// place the button(s)
		if (hasMsg)
		{
			if (fType == BOX_PROMPT)
			{
				btnGap = int((mcPopupWnd._width - 2*btn._width)/3);
				btnX = btnGap;
				btnY = int(0.9*mcPopupWnd._height) - btn._height;
			}
			else
			{
				btnX = int((mcPopupWnd._width - btn._width)/2);
				btnY = int(0.9*mcPopupWnd._height) - btn._height;
			}
		}
		else // no message - buttons are centered vertically
		{
			if (fType == BOX_PROMPT)
			{
				btnGap = int((mcPopupWnd._width - 2*btn._width)/3);
				btnX = int((mcPopupWnd._width - 2*btn._width)/3);
				btnY = int((mcPopupWnd._height - btn._height)/2);
			}
			else
			{
				btn._height = int(1.5*btn._height);
				btn._width = int(1.5*btn._width);
				btnX = int((mcPopupWnd._width - btn._width)/2);
				btnY = int((mcPopupWnd._height - btn._height)/2);				
			}
		}

		if (fType == BOX_PROMPT)
		{
			mcBtnYes._x = btnX;
			mcBtnNo._x = btnX + mcBtnYes._width + btnGap;
			mcBtnYes._y = mcBtnNo._y = btnY;
		}
		else
		{
			btn._x = btnX;
			btn._y = btnY;
		}
		
		// message label
		with (mcPopupWnd["TXMsg"])
		{
			if (hasMsg)
			{
				autoSize = wordWrap = html = true;
				_width = int(0.8*_parent._width);
				htmlText = msg; // changes the height of TextField
				_height = int(0.5*_parent._height);
				_y = btnY - _height;
				_x = int(0.1*_parent._width);
			}
			else
				_visible = false;
		}

		// assign event listeners. Two buttons for "Prompt" and the whole region for "Success" or "Fail"
		if (fType == BOX_PROMPT)
		{
			mcBtnYes.parentPopup = mcBtnNo.parentPopup = this; // make object props accessible from event handlers

			mcBtnYes.onClick = mcBtnNo.onClick = function()
			{
				this.parentPopup.btnClicked(this._name);
			};
		}
		else
		{
			mcPopupWnd.parentPopup = this;
			fTimer = getTimer();
			
			// close popup after some time
		    mcPopupWnd.onEnterFrame = function ()
		    {
		        if (this.parentPopup.fTimer > 0 && getTimer() - this.parentPopup.fTimer > POPUP_TIME)
					this.parentPopup.close(RES_TIMEOUT);
		    };

			mcPopupWnd.onRelease = function()
			{
				this.parentPopup.close(RES_AREA);
			}
		}
		
		// background will eat all the events it catches
		mcBack.onPress = mcBack.onRelease = mcBack.onDragOut = mcBack.onDragOver = mcBack.onMouseDown = 
		mcBack.onMouseMove = mcBack.onMouseUp = mcBack.onReleaseOutside = function() {};
		
		fMCPopup._visible = true;
	}

	// just a shorthand for displaying results of some actions
	public function showResult(success: Boolean, msg: String)
	{
		show( (success ? BOX_SUCCESS : BOX_FAIL), msg);
	}

	// button was clicked, return the modal result and close popup. 
	// ! if placed directly in onRelease(), the execution completely aborts after close()
	private function btnClicked(name)
	{
		if (name == "MCBtnYes")
			close(RES_YES);
		else if (name == "MCBtnNo")
			close(RES_NO);
		else
			close(undefined);
	}

	private function close(result)
	{
		fMCPopup._visible = false;
		fMCPopup.removeMovieClip();
		fMCPopup = null;
		fTimer = 0;
		fCallback(result);
	}

	//	Creates the background for the Alert
	private static function createBackground(): Void
	{
//		var myBackground: Sprite = new Sprite();
/*		var colour: int = alertOptions.colour;
		switch (alertOptions.background) {
			case "blur" : 
				var BackgroundBD: BitmapData = new BitmapData(fStage.stageWidth, fStage.stageHeight, true, 0xFF000000+colour);
				var stageBackground: BitmapData = new BitmapData(fStage.stageWidth, fStage.stageHeight);
				stageBackground.draw(fStage);
				var rect: Rectangle = new Rectangle(0, 0, fStage.stageWidth, fStage.stageHeight);
				var point: Point = new Point(0, 0);
				var multiplier: uint = 120;
				BackgroundBD.merge(stageBackground, rect, point, multiplier, multiplier, multiplier, multiplier);
				BackgroundBD.applyFilter(BackgroundBD, rect, point, new BlurFilter(5, 5));
				var bitmap: Bitmap = new Bitmap(BackgroundBD);
				myBackground.addChild(bitmap);
				break;
			case "none" : 
				myBackground.graphics.beginFill(colour, 0);	//	BACKGROUND IS STILL THERE BUT IS INVISIBLE
				myBackground.graphics.drawRect(0, 0, fStage.stageWidth, fStage.stageHeight);
				myBackground.graphics.endFill();
				break;
			case "nonenotmodal" : 
				//	DRAW NO BACKGROUND AT ALL
				break;
			case "simple" : 
				myBackground.graphics.beginFill(colour, 0.3);
				myBackground.graphics.drawRect(0, 0, fStage.stageWidth, fStage.stageHeight);
				myBackground.graphics.endFill();
				break;
		}
		return myBackground;
/*	}
	
	
	//	returns a sprite containing a prompt complete with a background, the specified text and an OK button
	private static function createPrompt(): Void
	{
		//	Create a background for the prompt
/*		var ellipseSize = 10;
		promptBackground.graphics.lineStyle(1);
		promptBackground.graphics.beginFill(alertOptions.colour);
		promptBackground.graphics.drawRoundRect(0, 0, myWidth, myHeight, ellipseSize, ellipseSize);
		promptBackground.graphics.endFill();
		promptBackground.filters = [getGlowFilter(alertOptions.colour), getDropShadowFilter(alertOptions.colour)];
		promptBackground.alpha = alertOptions.promptAlpha;
*/
	}
	
}