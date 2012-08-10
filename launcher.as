// Scripts for Launcher Flash
// Developed by Cowon
// Modified by Fr0sT

/*

v.0.1
* Автозапуск последнего использовавшегося приложения при включении девайса. Пока безусловное, без настройки

v.0.2
* Баг с незапуском приложения

*/

function RegisterPopupMC(targetMC)
{
	var scale;
	if (popupMCName != targetMC)
	{
		if (popupMCName != null)
		{
			clearTimeout(__id);
			var tempMC = popupMCName;
			tempMC.onEnterFrame = function (Void)
			{
				scale = tempMC._xscale / 2;
				tempMC._xscale = scale;
				tempMC._yscale = scale;
				tempMC._alpha = scale;
				if (tempMC._xscale <= 10)
				{
					delete tempMC.onEnterFrame;
					tempMC._xscale = 100;
					tempMC._yscale = 100;
					tempMC._visible = false;
					tempMC = null;
				} // end if
			};
		} // end if
		if (targetMC != null)
		{
			var scaleIndex = 0;
			var scaleArray;
			if (targetMC._height > 250 || targetMC._width > 250)
			{
				scaleArray = new Array(85, 95, 101, 99);
			}
			else
			{
				scaleArray = new Array(85, 95, 103, 98);
			} // end else if
			targetMC._visible = true;
			targetMC._xscale = targetMC._yscale = 60;
			targetMC._alpha = 100;
			targetMC.onEnterFrame = function (Void)
			{
				scale = scaleArray[scaleIndex];
				targetMC._xscale = scale;
				targetMC._yscale = scale;
				if (++scaleIndex > scaleArray.length)
				{
					targetMC._xscale = 100;
					targetMC._yscale = 100;
					delete this.onEnterFrame;
					delete scaleArray;
				} // end if
			};

			if (targetMC._parent != undefined)
			{
				targetMC.swapDepths(targetMC._parent.getNextHighestDepth());
			} // end if
		} // end if
		popupMCName = targetMC;
	} // end if
}

function LoadSwfFile(itemNumber, fileName)
{
	var tempStr = "System\\Flash UI\\";
	if (itemNumber == _global.MODE_ETC && fileName == undefined || itemNumber >= modeArray.length && itemNumber != initializeCountry)
	{
		return;
	} // end if
	_global.g_PrevLauncherMode = _global.g_CurrLauncherMode;
	_global.g_CurrLauncherMode = itemNumber;
	_global.gfn_Common_ResetTimer();
	prevLauncherMode = currentLauncherMode;
	currentLauncherMode = itemNumber;
	if (currentMode == -1)
	{
		currentMode = itemNumber;
	} // end if
	_global.RemoveKeyListener();
	_global.RemoveTouchListener();
	_global.CommonResetStringScroll();
	userWallpaper = ext_fscommand2("GetDisWallpaper");
	LoadWallpaper();
	ext_fscommand2("SetEtcFlashUpdate", 0);
	smartUpdate = 3;
	unloadMovieNum(1);
	if (itemNumber == _global.MODE_ETC)
	{
		tempStr = tempStr + fileName;
		var _loc4 = new LoadVars();
		_loc4._parent = this;
		_loc4.onLoad = function (success)
		{
			if (success == true)
			{
				loadMovieNum(tempStr, 1);
			}
			else
			{
				_global.LoadPrevSWF();
			} // end else if
		};

		_loc4.load(tempStr);
	}
	else if (itemNumber == initializeCountry)
	{
		loadMovieNum(String(tempStr + "init_country.swf"), 1);
	}
	else
	{
		if (itemNumber == _global.MODE_MAIN)
		{
			var _loc5 = ext_fscommand2("EtcUsrGetMainmenu");
			if (_loc5 < MAX_MAINMENU_NUMBER)
			{
				tempStr = tempStr + ("mainmenu" + String(_loc5 + 1) + ".swf");
			}
			else
			{
				tempStr = tempStr + "mainmenu1.swf";
			} // end else if
		}
		else
		{
			tempStr = tempStr + String(modeArray[itemNumber] + ".swf");
		} // end else if
		loadMovieNum(tempStr, 1);
	} // end else if
}

function RegisterSystemTickTimer(Void)
{
	var tempMC;
	var previousSecond = -1;
	var prevMinute = -1;
	var prevHour = -1;
	var currentTickCount;
	var idx;
	this.onEnterFrame = function (Void)
	{
		currentTickCount = getTimer();
		currentTime = new Date();
		_global.g_curSec = currentTime.getSeconds();
		if (_global.g_curSec != previousSecond)
		{
			_global.g_curMin = currentTime.getMinutes();
			if (prevMinute != _global.g_curMin)
			{
				_global.g_curHour = currentTime.getHours();
				_global.DisplayTime();
				prevMinute = _global.g_curMin;
				if (prevHour != _global.g_curHour)
				{
					prevHour = _global.g_curHour;
					_global.g_curYear = currentTime.getFullYear();
					_global.g_curMonth = currentTime.getMonth();
					_global.g_curDate = currentTime.getDate();
				} // end if
			} // end if
			_global.DisplayBattery(0);
			previousSecond = _global.g_curSec;
		} // end if
		delete currentTime;
		for (idx = 0; idx < 3; idx++)
		{
			if (cTimer.tick[idx] != null)
			{
				if (currentTickCount - cTimer.StartTick[idx] >= cTimer.tick[idx])
				{
					cTimer.func[idx]();
					cTimer.StartTick[idx] = null;
					cTimer.tick[idx] = null;
					cTimer.func[idx] = null;
				} // end if
			} // end if
		} // end of for
		if (enableTextScrolling == true)
		{
			for (idx = 0; idx < NUMOFSCROLLFIELD; idx++)
			{
				if (scrollFlagArray[idx] != null)
				{
					tempMC = scrollFlagArray[idx];
					if (scrollDirection[idx] == 0)
					{
						++tempMC.hscroll;
						if (tempMC.hscroll >= tempMC.maxhscroll)
						{
							scrollDirection[idx] = 1;
						} // end if
						continue;
					} // end if
					--tempMC.hscroll;
					if (tempMC.hscroll <= 0)
					{
						scrollDirection[idx] = 0;
					} // end if
				} // end if
			} // end of for
		} // end if
		if (smartUpdate > 0)
		{
			--smartUpdate;
			if (smartUpdate == 0)
			{
				this._visible = false;
				ext_fscommand2("SetEtcFlashUpdate", 1);
				this._visible = true;
			} // end if
		} // end if
	};

}

function InitializeLauncher(Void)
{
	RegisterWallpaperListener();
	RegisterSystemTickTimer();
	LoadConfiguration();
	if (_global.GetFirmwareVersion() != C2_DOMESTIC_DMB && ext_fscommand2("GetSysRegion") == -1)
	{
		LoadSwfFile(initializeCountry);
	}
	else
	{
		var _loc2 = ext_fscommand2("GetTimAlarmState");
		display24Hour = ext_fscommand2("GetTim24HDisplay");
		
		// !!! implementing Resume mode instead of not working "EtcModGetResumeMode"
		// We use recent mode here as it quite reliable.
		var recentModeArr = _global.GetRecentMode().split("/");
		if (recentModeArr == undefined || recentModeArr.length == 0)
			recentModeArr = new Array(String(_global.MODE_MAIN));
		var recentCode = Number(recentModeArr[0]);

		switch (recentCode)
		{
			case _global.MODE_DICTIONARY:
			case _global.MODE_DMB:
			case _global.MODE_FLASHBROWSER:
			case _global.MODE_MAIN:
			case _global.MODE_MUSIC:
			case _global.MODE_PICTURE:
			case _global.MODE_RADIO:
			case _global.MODE_RECORD:
			case _global.MODE_TEXT:
			case _global.MODE_VIDEO:
				_global.LoadSWF(recentCode);
				break;
			default:
				_global.LoadSWF(_global.MODE_MAIN);				
				break;
		}

/*
		ext_fscommand2("EtcModGetResumeMode", "tempString");
		if (tempString == "Music")
			_global.LoadSWF(_global.MODE_MUSIC);
		else if (tempString == "Video")
			_global.LoadSWF(_global.MODE_VIDEO);
		else if (tempString == "Radio")
			_global.LoadSWF(_global.MODE_RADIO);
		else if (tempString == "Record")
			_global.LoadSWF(_global.MODE_RECORD);
		else if (tempString == "MobileTV")
			_global.LoadSWF(_global.MODE_DMB);
		else if (tempString == "Flash")
			_global.LoadSWF(_global.MODE_FLASHBROWSER);
		else if (tempString == "Text")
			_global.LoadSWF(_global.MODE_TEXT);
		else if (tempString == "Picture")
			_global.LoadSWF(_global.MODE_PICTURE);
		else if (tempString == "Dictionary")
			_global.LoadSWF(_global.MODE_DICTIONARY);
		else
			_global.LoadSWF(_global.MODE_MAIN);
*/
	} // end else if
}

_global.LCD_WIDTH = 320;
_global.LCD_HEIGHT = 240;
_global.SCROLL_VERTICAL = 1;
_global.SCROLL_HORIZONTAL = 2;
_global.SCROLL_FREE = 3;
_global.C2_DOMESTIC = 1;
_global.C2_OVERSEAS = 2;
_global.C2_DOMESTIC_DMB = 3;
_global.C2_DOMESTIC_VOKHAN = 4;
_global.STATE_UNDEFINED = 0;
_global.STATE_MUSIC_PLAY = 1;
_global.STATE_MUSIC_PAUSE = 2;
_global.STATE_MUSIC_STOP = 3;
_global.STATE_RADIO = 4;
_global.STATE_RADIO_RECORD = 5;
_global.STATE_RECORD = 7;
_global.STATE_RECORD_PAUSE = 8;
_global.STATE_RECORD_STOP = 9;
_global.STATE_RECORD_PLAY = 10;
_global.STATE_RECORD_PLAYPAUSE = 11;
_global.STATE_MTV = 12;
_global.STATE_MTV_RECORD = 13;
_global.MODE_MUSIC = 0;
_global.MODE_VIDEO = 1;
_global.MODE_RADIO = 2;
_global.MODE_RECORD = 3;
_global.MODE_DMB = 4;
_global.MODE_FLASH = 5;
_global.MODE_TEXT = 6;
_global.MODE_PICTURE = 7;
_global.MODE_DICTIONARY = 8;
_global.MODE_UTIL = 9;
_global.MODE_ETC = 10;
_global.MODE_MAIN = 11;
_global.MODE_MAIN2 = 12;
_global.MODE_MAIN3 = 13;
_global.MODE_SETTING = 14;
_global.MODE_BROWSER = 15;
_global.MODE_LAUNCHER = 16;
_global.MODE_FLASHBROWSER = 17;
_global.MODE_TEXTBROWSER = 18;
_global.MODE_VOKHAN = 19;
_global.MODE_WORDUP = 20;
_global.TEXT_ALIGN_UNDEFIEND = 0; /**/// bugoga
_global.TEXT_ALIGN_CENTER = 1;
_global.seekRatio = 0;
_global.g_curYear = 0;
_global.g_curMonth = 0;
_global.g_curDate = 0;
_global.g_curHour = 0;
_global.g_curMin = 0;
_global.g_curSec = 0;
var NUMOFSCROLLFIELD = 6;
var scrollDirection = new Array(0, 0, 0, 0, 0, 0);
var scrollFlagArray = new Array(null, null, null, null, null, null);
var scrollAlign = new Array(null, null, null, null, null, null);
var isFlipping = false;
var popupMCName = null;
var __id = -1;
var restoreAlign = new TextFormat();
_global.S9_NODMB_DIC = 1;
_global.S9_NODMB = 2;
_global.S9_DMB = 3;
_global.S9_NORWAY_DMB = 4;
_global.g_FirmwareVersion = 0;
_global.g_PrevLauncherMode = -1;
_global.g_CurrLauncherMode = -1;
_global.g_PrevBrowser = "unknown";
_global.g_Browser_CurrScale = 16;
_global.g_Browser_InitScale = 16;
_global.g_TextCurrScale;
_global.g_TextinitScale;
_global.g_Rec_CurMode = STATE_RECORD_STOP;
cTimer = new Object();
cTimer.startTick = new Array(null, null, null);
cTimer.tick = new Array(null, null, null);
cTimer.func = new Array(null, null, null);

_global.gfn_flipFooter = _global.FlipFooter = function (mcSideA, mcSideB, flipMode, fastMode)
{
	var step = 1;
	var chMenu = 0;
	var bgHalfHeight;
	var bgHeight;
	var _loc3 = mcSideA._parent;
	if (isFlipping == true)
	{
		return;
	} // end if
	switch (flipMode)
	{
		case _global.SCROLL_VERTICAL:
		{
			bgHeight = _loc3._width;
			if (fastMode)
			{
				bgHalfHeight = bgHeight * 0.800000;
			}
			else
			{
				bgHalfHeight = bgHeight / 2;
			} // end else if
			isFlipping = true;
			_loc3.onEnterFrame = function (Void)
			{
				if (this._width < 1)
				{
					step = 2;
				} // end if
				if (step == 1)
				{
					if (this._width > bgHalfHeight)
					{
						this._width = this._width - bgHalfHeight;
					}
					else
					{
						this._width = 0;
					} // end else if
				}
				else if (step == 2)
				{
					if (bgHeight < bgHalfHeight + this._width)
					{
						this._width = bgHeight;
						isFlipping = false;
						delete this.onEnterFrame;
					}
					else
					{
						this._width = this._width + bgHalfHeight;
					} // end else if
					if (this._width > bgHalfHeight - 2 && chMenu == 0)
					{
						if (mcSideA._visible != mcSideB._visible)
						{
							mcSideA._visible = !mcSideA._visible;
							mcSideB._visible = !mcSideB._visible;
						}
						else
						{
							mcSideA._visible = true;
							mcSideB._visible = false;
						} // end else if
						chMenu = 1;
					} // end if
				} // end else if
			};

			break;
		} 
		default:
		{
			bgHeight = _loc3._height;
			if (fastMode)
			{
				bgHalfHeight = bgHeight * 0.800000;
			}
			else
			{
				bgHalfHeight = bgHeight / 2;
			} // end else if
			isFlipping = true;
			_loc3.onEnterFrame = function (Void)
			{
				if (this._height < 1)
				{
					step = 2;
				} // end if
				if (step == 1)
				{
					if (this._height > bgHalfHeight)
					{
						this._height = this._height - bgHalfHeight;
					}
					else
					{
						this._height = 0;
					} // end else if
				}
				else if (step == 2)
				{
					if (this._height > bgHeight)
					{
						this._height = bgHalfHeight;
					}
					else if (bgHeight < bgHalfHeight + this._height)
					{
						this._height = bgHeight;
						isFlipping = false;
						delete this.onEnterFrame;
					}
					else
					{
						this._height = this._height + bgHalfHeight;
					} // end else if
					if (this._height > bgHalfHeight - 2 && chMenu == 0)
					{
						if (mcSideA._visible != mcSideB._visible)
						{
							mcSideA._visible = !mcSideA._visible;
							mcSideB._visible = !mcSideB._visible;
						}
						else
						{
							mcSideA._visible = true;
							mcSideB._visible = false;
						} // end else if
						chMenu = 1;
					} // end if
				} // end else if
			};

			break;
		} 
	} // End of switch
};

_global.gfn_SetPopupMCName = function (targetMC, timeOut)
{
	if (timeOut == undefined)
	{
		timeOut = 0;
	}
	else if (timeOut == 1)
	{
		timeOut = 5000;
	} // end else if
	_global.DisplayPopupMC(targetMC, timeOut);
};

_global.DisplayPopupMC = function (targetMC, timeOut)
{
	RegisterPopupMC(targetMC);
	if (timeOut == undefined)
	{
		timeOut = 0;
	} // end if
	if (timeOut > 0)
	{
		clearTimeout(__id);
		__id = setTimeout(_global.RemovePopupMC, timeOut);
	} // end if
};

_global.gfn_GetPopupMCName = _global.GetPopupMCName = function (Void)
{
	return (popupMCName._name);
};

_global.RemovePopupMC = function (Void)
{
	clearTimeout(__id);
	RegisterPopupMC(null);
};

_global.gfn_Common_DrawSeekBar = _global.CommonDrawSeekBar = function (bgMC, targetMC, maskMC, position, scrollMode)
{
	var _loc2;
	if (position < 0)
	{
		position = 0;
	}
	else if (position > 100)
	{
		position = 100;
	} // end else if
	switch (scrollMode)
	{
		case SCROLL_VERTICAL:
		{
			_loc2 = bgMC._height - targetMC._height;
			if (maskMC != null)
			{
				_loc2 = _loc2 + 24;
			} // end if
			targetMC._y = position * _loc2 / 100;
			maskMC._width = int(targetMC._y);
			maskMC._height = bgMC._width;
			bgMC.setMask(maskMC);
			break;
		} 
		default:
		{
			_loc2 = bgMC._width - targetMC._width;
			if (maskMC != null)
			{
				_loc2 = _loc2 + 24;
			} // end if
			targetMC._x = position * _loc2 / 100;
			maskMC._width = int(targetMC._x);
			maskMC._height = bgMC._height;
			bgMC.setMask(maskMC);
			break;
		} 
	} // End of switch
};

_global.gfn_Common_GetRatio = _global.CommonGetRatio = function (total, currentValue)
{
	if (currentValue == 0)
	{
		return (0);
	} // end if
	if (total == 0)
	{
		return (Infinity);
	} // end if
	return (int(currentValue * 100 / total));
};

_global.gfn_Common_GetSeekBarRatio = _global.CommonGetSeekBarRatio = function (totalWidth, targetWidth, currentPosition)
{
	_global.seekRatio = int(currentPosition * 100 / (totalWidth - targetWidth));
	if (_global.seekRatio < 0)
	{
		_global.seekRatio = 0;
	}
	else if (_global.seekRatio > 100)
	{
		_global.seekRatio = 100;
	} // end else if
	return (_global.seekRatio);
};

_global.gfn_Common_GetSeekRatio = _global.CommonGetSeekRatio = function (Void)
{
	return (_global.seekRatio);
};

_global.gfn_Common_Get2ChiperNum = _global.CommonGetTwoDigitNumber = function (currentValue)
{
	if (currentValue < 10)
	{
		return (String("0" + String(currentValue)));
	}
	else
	{
		return (String(currentValue));
	} // end else if
};

_global.gfn_Common_GetTime2Text = _global.CommonGetTime2Text = function (time)
{
	var _loc5 = int(time / 3600);
	var _loc4 = int(time % 3600 / 60);
	var _loc2 = int(time % 3600 % 60);
	return (String(_global.CommonGetTwoDigitNumber(_loc5) + ":" + _global.CommonGetTwoDigitNumber(_loc4) + ":" + _global.CommonGetTwoDigitNumber(_loc2)));
};

_global.gfn_Common_SetStringScroll = _global.CommonSetStringScroll = function (textFieldName, textAlign)
{
	var _loc5 = textFieldName.getTextFormat();
	if (textFieldName.maxhscroll >= 5)
	{
		var _loc3 = NUMOFSCROLLFIELD;
		for (var _loc2 = 0; _loc2 < NUMOFSCROLLFIELD; ++_loc2)
		{
			if (scrollFlagArray[_loc2] == textFieldName)
			{
				_loc3 = _loc2;
				break;
				continue;
			} // end if
			if (scrollFlagArray[_loc2] == null && _loc3 == NUMOFSCROLLFIELD)
			{
				_loc3 = _loc2;
			} // end if
		} // end of for
		if (_loc3 != NUMOFSCROLLFIELD)
		{
			scrollFlagArray[_loc3] = textFieldName;
			scrollDirection[_loc3] = 0;
			scrollAlign[_loc3] = _loc5.align;
			_loc5.align = "left";
			textFieldName.setTextFormat(_loc5);
			return (_loc3);
		} // end if
	}
	else
	{
		for (var _loc2 = 0; _loc2 < NUMOFSCROLLFIELD; ++_loc2)
		{
			if (scrollFlagArray[_loc2] == textFieldName)
			{
				scrollFlagArray[_loc2] = null;
				scrollDirection[_loc2] = 0;
				scrollAlign[_loc2] = 0;
				break;
			} // end if
		} // end of for
		if (textAlign == _global.TEXT_ALIGN_CENTER)
		{
			_loc5.align = "center";
			textFieldName.setTextFormat(_loc5);
		} // end if
		return (-1);
	} // end else if
	false;
	return (1);
};

_global.gfn_Common_StringScroll = _global.CommonStringScroll = function (Void)
{
	for (var _loc1 = 0; _loc1 < NUMOFSCROLLFIELD; ++_loc1)
	{
		if (scrollFlagArray[_loc1] != null)
		{
			if (scrollDirection[_loc1] == 0)
			{
				++scrollFlagArray[_loc1].hscroll;
				if (scrollFlagArray[_loc1].hscroll >= scrollFlagArray[_loc1].maxhscroll)
				{
					scrollDirection[_loc1] = 1;
				} // end if
				continue;
			} // end if
			--scrollFlagArray[_loc1].hscroll;
			if (scrollFlagArray[_loc1].hscroll <= 0)
			{
				scrollDirection[_loc1] = 0;
			} // end if
		} // end if
	} // end of for
};

_global.gfn_Common_ResetStringScroll = _global.CommonResetStringScroll = function (targetIdx)
{
	var _loc3;
	var _loc2;
	if (targetIdx == undefined)
	{
		_loc3 = 0;
		_loc2 = NUMOFSCROLLFIELD;
	}
	else
	{
		_loc3 = targetIdx;
		_loc2 = targetIdx + 1;
	} // end else if
	for (var _loc1 = _loc3; _loc1 < _loc2; ++_loc1)
	{
		if (scrollFlagArray[_loc1] != null)
		{
			restoreAlign.align = scrollAlign[_loc1];
			scrollFlagArray[_loc1].setTextFormat(restoreAlign);
			restoreAlign.align = null;
		} // end if
		scrollFlagArray[_loc1].hscroll = 0;
		scrollFlagArray[_loc1] = null;
		scrollDirection[_loc1] = null;
		scrollAlign[_loc1] = null;
	} // end of for
};

_global.CommonSetDigitMC = function (mc, number)
{
	mc.MCDigit1.gotoAndStop(int(number / 10) + 1);
	mc.MCDigit0.gotoAndStop(int(number % 10) + 1);
};

_global.gfn_Common_SetMask = function (maskWidth, maskHeight, bgMC, maskMC)
{
	maskMC._width = maskWidth;
	maskMC._height = maskHeight;
	bgMC.setMask(maskMC);
};

_global.gfn_ToggleVisibleState = function (targetMC)
{
	if (targetMC._visible == true)
	{
		targetMC._visible = false;
	}
	else
	{
		targetMC._visible = true;
	} // end else if
};

_global.gfn_Common_SetTimer = function (tick, exFunc)
{
	var _loc1;
	for (var _loc1 = 0; _loc1 < 3; ++_loc1)
	{
		if (cTimer.func[_loc1] == exFunc)
		{
			cTimer.StartTick[_loc1] = getTimer();
			cTimer.tick[_loc1] = tick;
			cTimer.func[_loc1] = exFunc;
			_loc1 = -1;
			break;
		} // end if
	} // end of for
	if (_loc1 != -1)
	{
		for (var _loc1 = 0; _loc1 < 3; ++_loc1)
		{
			if (cTimer.tick[_loc1] == null)
			{
				cTimer.StartTick[_loc1] = getTimer();
				cTimer.tick[_loc1] = tick;
				cTimer.func[_loc1] = exFunc;
				break;
			} // end if
		} // end of for
	} // end if
};

_global.gfn_Common_ResetTimer = function (Void)
{
	for (var _loc1 = 0; _loc1 < 3; ++_loc1)
	{
		cTimer.StartTick[_loc1] = null;
		cTimer.tick[_loc1] = null;
		cTimer.func[_loc1] = null;
	} // end of for
};

_global.gfn_Common_CheckTimerTick = function (exFunc)
{
	for (var _loc1 = 0; _loc1 < 3; ++_loc1)
	{
		if (cTimer.func[_loc1] == exFunc)
		{
			return (cTimer.tick[_loc1]);
		} // end if
	} // end of for
	return (null);
};

_global.Scale_OneDegree = function (mc, targetScale)
{
	var _loc2;
	var _loc4;
	if (targetScale > mc._xscale)
	{
		_loc2 = targetScale - mc._xscale >> 1;
		if (_loc2 <= 1)
		{
			mc._xscale = mc._yscale = targetScale;
			return (1);
		} // end if
		mc._xscale = mc._xscale + _loc2;
		mc._yscale = mc._yscale + _loc2;
	}
	else
	{
		_loc2 = targetScale - mc._xscale >> 1;
		if (_loc2 >= -1)
		{
			mc._xscale = mc._yscale = targetScale;
			return (1);
		} // end if
		mc._xscale = mc._xscale + _loc2;
		mc._yscale = mc._yscale + _loc2;
	} // end else if
	return (0);
};

_global.KEY_PLAY_SHORT = 0;
_global.KEY_PLAY_LONG = 1;
_global.KEY_FF_SHORT = 2;
_global.KEY_FF_LONG = 3;
_global.KEY_PLUS_SHORT = 4;
_global.KEY_PLUS_LONG = 5;
_global.KEY_REW_SHORT = 6;
_global.KEY_REW_LONG = 7;
_global.KEY_MINUS_SHORT = 8;
_global.KEY_MINUS_LONG = 9;
_global.TOUCH_REW = 10;
_global.TOUCH_REW_SHORT = 10;
_global.TOUCH_REW_LONG = 11;
_global.TOUCH_FF = 12;
_global.TOUCH_FF_SHORT = 12;
_global.TOUCH_FF_LONG = 13;
_global.TOUCH_PLUS = 14;
_global.TOUCH_PLUS_SHORT = 14;
_global.TOUCH_PLUS_LONG = 15;
_global.TOUCH_MINUS = 16;
_global.TOUCH_MINUS_SHORT = 16;
_global.TOUCH_MINUS_LONG = 17;
_global.KEY_RELEASE_LONG = 18;
_global.KEY_DISPLAY_UPDATE = 19;
_global.KEY_HOLD = 20;
_global.KEY_DISPLAY_ROTATE = 21;
_global.VKEY_PLUS = 100;
_global.VKEY_MINUS = 101;
_global.VKEY_FF = 102;
_global.VKEY_REW = 103;
_global.SETTING_FF = 200;
_global.SETTING_REW = 201;

var SHORTKEY_DELAY = 800;
var LONGKEY_REPEAT = 150;
var keyType = 0;
_global.fLongkey = 0;
var virtualKeyMC;
var keyObject = new Object();
var mouseObject = new Object();
var touchHandler = new Object();

with (touchHandler)
{
	functionHandler = null;
	inputKey = -1;
	fmouseDown = -1;
} // End of with

_global.gfn_Key_CreateKeyListner = _global.RegisterKeyListener = function (callBackFunction)
{
	var keyStartTick;
	var keyCode;
	keyObject.onKeyDown = function (Void)
	{
		keyCode = Key.getCode();
		if (keyCode == 32)
		{
			keyCode = keyCode + 4;
		} // end if
		if (keyCode >= 36 && keyCode <= 40)
		{
			var _loc1 = getTimer();
			if (keyType == 0)
			{
				keyStartTick = _loc1;
				keyType = 1;
				if (keyCode == 40 || keyCode == 38)
				{
					callBackFunction((keyCode - 36) * 2 + 1);
				} // end if
			}
			else if (keyType == 1)
			{
				if (_loc1 - keyStartTick > SHORTKEY_DELAY)
				{
					keyType = 2;
					keyStartTick = _loc1;
					callBackFunction((keyCode - 36) * 2 + 1);
				} // end if
			}
			else if (_loc1 - keyStartTick > LONGKEY_REPEAT)
			{
				keyType = 2;
				keyStartTick = _loc1;
				callBackFunction((keyCode - 36) * 2 + 1);
			} // end else if
		} // end else if
	};

	keyObject.onKeyUp = function (Void)
	{
		keyCode = Key.getCode();
		if (keyCode == 32)
		{
			keyCode = keyCode + 4;
		} // end if
		if (keyCode >= 36 && keyCode <= 40)
		{
			switch (keyType)
			{
				case 1:
				{
					if (keyCode != 40 && keyCode != 38)
					{
						callBackFunction((keyCode - 36) * 2);
					} // end if
					break;
				} 
				case 2:
				{
					callBackFunction(_global.KEY_RELEASE_LONG);
					break;
				} 
				default:
				{
					break;
				} 
			} // End of switch
			keyType = 0;
			keyStartTick = 0;
		}
		else
		{
			switch (keyCode)
			{
				case 120:
				{
					unloadMovieNum(1);
					break;
				} 
				case 121:
				{
					if (!_global.CheckCurrentLauncherMode(_global.MODE_MAIN))
					{
						_global.LoadSWF(_global.MODE_MAIN);
					} // end if
					break;
				} 
				case 122:
				{
					callBackFunction(_global.KEY_DISPLAY_ROTATE);
					break;
				} 
				case 123:
				{
					_global.UpdateSystemInfo(1);
					callBackFunction(_global.KEY_DISPLAY_UPDATE);
					break;
				} 
				case 145:
				{
					callBackFunction(_global.KEY_HOLD);
					break;
				} 
				default:
				{
					break;
				} 
			} // End of switch
		} // end else if
	};

	Key.addListener(keyObject);
};

_global.gfn_Key_RemoveKeyListener = _global.RemoveKeyListener = function (Void)
{
	var _loc1 = Key.removeListener(keyObject);
};

_global.gfn_Key_SetVirtualKeyMC = _global.SetVirtualKeyMC = function (targetMC)
{
	virtualKeyMC = targetMC;
};

_global.gfn_Key_GetVirtualKeyMC = _global.GetVirtualKeyMC = function (Void)
{
	return (virtualKeyMC._name);
};

_global.gfn_Key_CreateTouchListener = _global.CreateTouchListener = function (funcHandler)
{
	var startTick;
	var pressX;
	var pressY;
	touchHandler.functionHandler = funcHandler;
	touchHandler.inputKey = -1;
	mouseObject.onMouseDown = function (Void)
	{
		startTick = getTimer();
		if (GetVirtualKeyMC() != null && virtualKeyMC.hitTest(_root._xmouse, _root._ymouse, 0) == 1)
		{
			pressX = _root._xmouse;
			pressY = _root._ymouse;
		}
		else
		{
			pressX = null;
			pressY = null;
		} // end else if
	};

	mouseObject.onMouseMove = function (Void)
	{
		_level1.MCMouse._x = _root._xmouse;
		_level1.MCMouse._y = _root._ymouse;
		if (touchHandler.fmouseDown)
		{
			if (fLongkey == 0)
			{
				if (getTimer() - startTick > SHORTKEY_DELAY)
				{
					fLongkey = 1;
					startTick = getTimer();
				} // end if
			}
			else if (fLongkey == 1)
			{
				if (getTimer() - startTick > LONGKEY_REPEAT)
				{
					touchHandler.functionHandler(touchHandler.inputKey + fLongkey);
					startTick = getTimer();
				} // end if
			} // end if
		} // end else if
	};

	mouseObject.onMouseUp = function (Void)
	{
		if (fLongkey)
		{
			touchHandler.functionHandler(_global.KEY_RELEASE_LONG);
		} // end if
		startTick = 0;
		if (touchHandler.fmouseDown == 0 && pressX != null)
		{
			var _loc4 = _root._xmouse - pressX;
			var _loc3 = _root._ymouse - pressY;
			if (Math.abs(_loc4) > 40 || Math.abs(_loc3) > 40)
			{
				if (Math.abs(_loc4) < Math.abs(_loc3))
				{
					if (_loc3 <= 0)
					{
						touchHandler.functionHandler(_global.VKEY_PLUS);
					}
					else
					{
						touchHandler.functionHandler(_global.VKEY_MINUS);
					} // end else if
				}
				else if (_loc4 <= 0)
				{
					touchHandler.functionHandler(_global.VKEY_REW);
				}
				else
				{
					touchHandler.functionHandler(_global.VKEY_FF);
				} // end if
			} // end else if
		} // end else if
		touchHandler.fmouseDown = 0;
		touchHandler.inputKey = -1;
	};

	Mouse.addListener(mouseObject);
};

_global.gfn_Key_RemoveTouchListener = _global.RemoveTouchListener = function (Void)
{
	Mouse.removeListener(mouseObject);
};

_global.gfn_Key_GetLongkeyState = _global.GetLongkeyState = function (Void)
{
	return (fLongkey);
};

_global.gfn_KeyRepeatOn = _global.KeyRepeatOn = function (keyType)
{
	touchHandler.inputKey = keyType;
	touchHandler.fmouseDown = 1;
};

_global.gfn_KeyRepeatOff = _global.KeyRepeatOff = function (Void)
{
	fLongkey = 0;
	touchHandler.fmouseDown = 0;
};

var tempHour;
var mcInfobar;
var prevVolume = -1;
var prevBattery = -1;
var prevHoldStatus = -1;
var prevBluetooth = -1;
var prevMute = -1;
var preAudiOut = -1;
var currentTime;
var currentVolume = 0;
var currentBattery = 0;
var currentHoldStatus = 0;
var currentBluetooth = 0;
var display24Hour = 0;
var currentAudioOut = 0;
var muteState = 0;
var baseVolumeOfBoost = -1;

_global.gfn_systemInfo = _global.UpdateSystemInfo = function (forceUpdate)
{
	mcInfobar = _level1.MCCon.MCInfobar;
	display24Hour = ext_fscommand2("GetTim24HDisplay");
	_global.DisplayTime(forceUpdate);
	_global.DisplayBattery(forceUpdate);
	_global.DisplayHold(forceUpdate);
	_global.DisplayAudioOut(forceUpdate);
	_global.DisplayVolume(forceUpdate);
};

_global.DisplayAudioOut = function (forceUpdate)
{
	muteState = ext_fscommand2("GetEtcAudioOutMute");
	currentAudioOut = ext_fscommand2("GetEtcAudioOutDevice");
	if (forceUpdate == 1 || prevMute != muteState || preAudiOut != currentAudioOut)
	{
		prevMute = muteState;
		preAudiOut = currentAudioOut;
		mcInfobar.MCVol.MCVolIcon.gotoAndStop(preAudiOut + 1);
		mcInfobar.MCVol.gotoAndStop(muteState + 1);
	} // end if
};

_global.gfn_DispVolume = _global.DisplayVolume = function (forceUpdate)
{
	currentVolume = ext_fscommand2("GetEtcVolume");
	if (forceUpdate == 1 || prevVolume != currentVolume)
	{
		prevVolume = currentVolume;
		if (mcInfobar.MCVol._currentframe == 1)
		{
			_global.CommonSetDigitMC(mcInfobar.MCVol, currentVolume);
		} // end if
	} // end if
};

_global.gfn_DispTime = _global.DisplayTime = function (forceUpdate)
{
	if (forceUpdate == 1)
	{
		currentTime = new Date();
		_global.g_curYear = currentTime.getFullYear();
		_global.g_curMonth = currentTime.getMonth();
		_global.g_curDate = currentTime.getDate();
		_global.g_curHour = currentTime.getHours();
		_global.g_curMin = currentTime.getMinutes();
		_global.g_curSec = currentTime.getSeconds();
		delete currentTime;
	} // end if
	tempHour = _global.g_curHour;
	if (display24Hour == 0)
	{
		if (tempHour < 12)
		{
			mcInfobar.MCTime.MCAmpm.gotoAndStop(1);
		}
		else
		{
			mcInfobar.MCTime.MCAmpm.gotoAndStop(2);
			if (tempHour != 12)
			{
				tempHour = tempHour - 12;
			} // end if
		} // end else if
		mcInfobar.MCTime.MCAmpm._visible = true;
	}
	else
	{
		mcInfobar.MCTime.MCAmpm._visible = false;
	} // end else if
	_global.CommonSetDigitMC(mcInfobar.MCTime.MCHour, tempHour);
	_global.CommonSetDigitMC(mcInfobar.MCTime.MCMinute, _global.g_curMin);
};

_global.gfn_DispBatt = _global.DisplayBattery = function (forceUpdate)
{
	currentBattery = ext_fscommand2("GetSysBattery");
	if (forceUpdate == 1 || currentBattery != prevBattery)
	{
		prevBattery = currentBattery;
		mcInfobar.MCBattery.gotoAndStop(currentBattery + 1);
	} // end if
};

_global.gfn_DispHold = _global.DisplayHold = function (forceUpdate)
{
	currentHoldStatus = ext_fscommand2("GetSysHoldKey");
	if (forceUpdate == 1 || currentHoldStatus != prevHoldStatus)
	{
		prevHoldStatus = currentHoldStatus;
		if (currentHoldStatus)
		{
			mcInfobar.MCHold.gotoAndStop(ext_fscommand2("GetSysCtrlHoldState") * 2 + 2);
		}
		else
		{
			mcInfobar.MCHold.gotoAndStop(ext_fscommand2("GetSysCtrlHoldState") * 2 + 1);
		} // end if
	} // end else if
};

var tempString;
var versionString;
var pauseSystemTimer = false;
var firmwareVersion = -1;
var firmwareLang = -1;
var prevLauncherMode = -1;
var currentLauncherMode = -1;
var currentMode = -1;
var previousMode = -1;
var loading = false;
var modeArray = new Array("music", "movie", "radio", "record", "dmb", "browser_total", "text", "picture", "PowerDicRun", "null", "null", "mainmenu", "mainmenu", "mainmenu", "Setting", "browser_total", "null", "browser_total", "browser_total", "null", "browser_total");
var initializeCountry = 99;
var enableTextScrolling = true;
var MAX_MAINMENU_NUMBER = 3;
var DEFAULT_HEADER_HEIGHT = 59;
var userWallpaper = 0;
var currentWallpaper = -1;
var wallpaperLoader = new MovieClipLoader();
var wallpaperListener = new Object();
var currentBrowserBackground = 0;
var alarmSettingFlag = false;
var presetSearchString = "";
var LAUNCHER_VERSION = "Cowon C2 Launcher V0.9";
var smartUpdate = 0;

_global.Load_SWF = _global.LoadSWF = function (itemNumber, fileName)
{
	var _loc4 = 0;
	if (loading == true || itemNumber == undefined || itemNumber == _global.MODE_ETC && fileName == undefined)
	{
		return;
	} // end if
	previousMode = currentMode;
	currentMode = itemNumber;
	if (itemNumber != _global.MODE_MAIN && itemNumber != _global.MODE_MAIN2 && itemNumber != _global.MODE_MAIN3)
	{
		tempString = LAUNCHER_VERSION + "|" + String(itemNumber) + "/" + fileName;
		ext_fscommand2("SetEtcUIConfig", _global.MODE_LAUNCHER, tempString);
	} // end if
	if (currentLauncherMode == _global.MODE_VIDEO)
	{
		LoadSwfFile(itemNumber, fileName);
	}
	else if (itemNumber == _global.MODE_VIDEO)
	{
		ext_fscommand2("EtcModChangeMode", "Video");
		if (ext_fscommand2("GetEtcCurPLIndex") < 0)
		{
			if (currentLauncherMode == _global.MODE_BROWSER)
			{
				_global.LoadSWF(_global.MODE_MAIN);
			}
			else
			{
				currentMode = _global.MODE_MAIN;
				_global.LoadSWF(_global.MODE_BROWSER);
			} // end else if
		}
		else
		{
			LoadSwfFile(itemNumber, fileName);
		} // end else if
	}
	else
	{
		if (itemNumber == _global.MODE_MUSIC)
		{
			ext_fscommand2("EtcModChangeMode", "Music");
			if (ext_fscommand2("GetEtcCurPLIndex") < 0)
			{
				if (currentLauncherMode == _global.MODE_BROWSER)
				{
					_global.LoadSWF(_global.MODE_MAIN);
				}
				else
				{
					currentMode = _global.MODE_MAIN;
					_global.LoadSWF(_global.MODE_BROWSER);
				} // end else if
				return;
			} // end if
		}
		else if (itemNumber == _global.MODE_TEXT)
		{
			ext_fscommand2("EtcModChangeMode", "Text");
			if (ext_fscommand2("EtcTxtOpen") != 1)
			{
				if (currentLauncherMode == _global.MODE_BROWSER)
				{
					_global.LoadSWF(_global.MODE_MAIN);
				}
				else
				{
					currentMode = _global.MODE_MAIN;
					_global.LoadSWF(_global.MODE_BROWSER);
				} // end else if
				return;
			} // end if
		} // end else if
		LoadSwfFile(itemNumber, fileName);
	} // end else if
};

_global.LoadPrevSWF = function (Void)
{
	if (prevLauncherMode == -1)
	{
		prevLauncherMode = _global.MODE_MAIN;
	} // end if
	previousMode = currentMode;
	currentMode = -1;
	LoadSwfFile(prevLauncherMode);
};

_global.CheckCurrentLauncherMode = function (mode)
{
	if (currentMode == mode)
	{
		return (true);
	}
	else
	{
		return (false);
	} // end else if
};

_global.GetCurrentLauncherMode = function (Void)
{
	return (currentMode);
};

_global.CheckPrevLauncherMode = function (mode)
{
	if (previousMode == mode)
	{
		return (true);
	}
	else
	{
		return (false);
	} // end else if
};

_global.GetPrevLauncherMode = function (Void)
{
	return (previousMode);
};

_global.GetRecentMode = function (Void)
{
	ext_fscommand2("GetEtcUIConfig", _global.MODE_LAUNCHER, "tempString");
	var arr = tempString.split("|");
	if (arr[0] == LAUNCHER_VERSION)
		return (String(arr[1]));
	else
		return (String(_global.MODE_MUSIC));
};

_global.ResumeTextScrolling = function (Void)
{
	enableTextScrolling = true;
};

_global.PauseTextScrolling = function (Void)
{
	enableTextScrolling = false;
};

_global.ResumeSystemTickTimer = function (Void)
{
	if (pauseSystemTimer == true)
	{
		pauseSystemTimer = false;
		RegisterSystemTickTimer();
	} // end if
};

_global.PauseSystemTickTimer = function (Void)
{
	if (pauseSystemTimer == false)
	{
		pauseSystemTimer = true;
		delete this.onEnterFrame;
	} // end if
};

_global.SetAlarmSettingFlag = function (flag)
{
	alarmSettingFlag = flag;
};

_global.SetPresetSearchString = function (str)
{
	presetSearchString = str;
};

_global.GetFirmwareVersion = function (Void)
{
	if (firmwareVersion == -1 || firmwareLang != ext_fscommand2("GetDisLanguage"))
	{
		if (ext_fscommand2("GetEtcDMBModelCheck") == 1)
		{
			firmwareVersion = _global.C2_DOMESTIC_DMB;
			firmwareLang = ext_fscommand2("GetDisLanguage");
		}
		else
		{
			firmwareLang = ext_fscommand2("GetDisLanguage");
			if (firmwareLang == 1)
			{
				firmwareVersion = _global.C2_DOMESTIC;
			}
			else
			{
				firmwareVersion = _global.C2_OVERSEAS;
			} // end else if
		} // end else if
		_global.g_FirmwareVersion = firmwareVersion;
	} // end if
	return (firmwareVersion);
};

_global.GetAlarmSettingFlag = function (Void)
{
	return (alarmSettingFlag);
};

_global.GetPresetSearchString = function (Void)
{
	return (presetSearchString);
};

InitializeLauncher();
