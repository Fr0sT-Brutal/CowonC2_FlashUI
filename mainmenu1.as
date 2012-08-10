// Scripts for Main menu Flash UI
// Developed by Cowon
// Modified by Fr0sT

/*

v.0.1
* загрузка обоев (пока одна штука). Прозрачность ставится 50%

v.0.2
* смена обоев, дополнительная иконка
* надписи иконок сделаны текстом
* куча внутренних изменений

v.0.3
* конфиг отличается заголовком от стандартного (чтобы избежать путаницы при переходе со стандартного UI на мод и обратно)
* TPopup для запроса подтверждения на выключение девайса
* исправлено: "иконки можно прокрутить вверх"
* таскание иконок пока отключено
* recent modes - глобально переделаны

v.0.4
* количество обоев увеличено до 7
* recent modes снова работают (частично)

TO DO
* recentfile - фон подложки
* верт прокрутка - цикл. подумать.
* иногда не запускается RECENTMODE
* посмотреть, как реализуется перевод

Bugs
* таскание иконок - не выключается
* mccon уфигачивает вниз при запуске

*/

#include "CowonCommon.as"

//** Global variables & constants **\\

var LIMITTOP = 0;
var LIMITLEFT = _global.LCD_WIDTH*2;
var LIMITRIGHT = -_global.LCD_WIDTH;
// limitBottom - see below
var MOVEPAGEALPHAMAX = 50;
var WIDGETMAXPAGE = 2;
var NEXT = 1;
var PREV = -1;

var ICONINTERVALX = 100;
var ICONINTERVALY = 120;
var MAXICONS = 19;
var HORIZONTAL_ICON = 3;
var VERTICAL_ICON = 2;
var ONEPAGEICONS = HORIZONTAL_ICON * VERTICAL_ICON;
var VERTICAL_ICON_MARGIN = 10;
var HORIZONTAL_ICON_MARGIN = 20;
var BLURICON = 60;
var UNSELECTEDICON = 100;
var SELECTEDICON = 30;
var ICON_DMB = 3;
var ICON_ROTATE = 14;
var ICON_POWEROFF = 15;
var ICON_THEME = 16;
var ICON_SLEEP = 17;
var ICON_WALLPAPER = 18;

var WIDGETMODE = 0;
var ICONMODE = 1;
var RECENTMODE = 2;
var KEYBOARD_OFFSET_X = 4;
var KEYBOARD_OFFSET_Y = 3;
var WALLPAPER_COUNT = 7;
var WALLPAPER_ALPHA = 50;
var BASE_WALLPAPER_NAME = "MCWallpaper";
var VERSION = "Cowon C2 Mainmenu2 V0.9 [Fr0sT mod]"; // ! to distinguish config from original UI

var STANDARD_SWF = "notepad;stopwatch;typist;calculator";
var modeArray = new Array("music", "videos", "radio", "recorder", "dmb", "flash", "documents", "picture", null, null, null, null, null, null, "settings", "browser", null, "flash", "browser", null, "browser");

var arrayIcon;
var tempString;
var holdStatus = -1;
var currentPage = 0;
var limitBottom = -currentPage * _global.LCD_HEIGHT;
var selectedItem = -1;
var currentIconMaxPage = Math.ceil(MAXICONS / ONEPAGEICONS) - 1;
var currentMode = 1;
var currentWidget = 1;
var hour;
var minute;
var currentDate;
var selectedYear = -1;
var selectedMonth = -1;
var selectedDay = -1;
var memoArray;
var intervalID;
var thumbnailImageLoader;
var thumbnailImageListener;
var currentFileIndex = -1;
var movingPage = false;
var mouseTouch = false;
var mouseListener = new Object();
var isBlocking = false;
var isStarting = false;
var popup = new TPopup();
var currWallpaperIdx = 0; // 0 means no wallpaper
var mcStage = _root.MCCon.MCIconStage;
var mcWidget = _root.MCCon.MCWidgetStage;
var mcRecent;

//** funcions **\\

// iconArrangement - list of icon numbers in the needed order
function InitializeIcons(iconArrangement)
{
	var idx;
	var iconArrangementArray = new Array();

	delete arrayIcon;
	arrayIcon = new Array();
	
	// iconArrangement array stores icon placement settings in the form
	// icon_ID [ icon_index_on_screen ]
	// 0 => icon_5
	// 1 => icon_0
	// ...
	// fill default iconArrangement
	if (iconArrangement == null)
		for (idx = 0; idx < MAXICONS; idx++)
			iconArrangementArray.push(String(idx));
	else
		iconArrangementArray = iconArrangement.split("/");

	// fill general icon state array in the form
	// icon_index_on_screen [ icon_ID ] (undefined if icon must not be shown)
	// icon_0 => true
	// icon_1 => undefined
	// ...
	var tempArray = new Array(MAXICONS);
	for (idx in iconArrangementArray)
		tempArray[Number(iconArrangementArray[idx])] = true;
	
	// use DMB?
	if (_global.GetFirmwareVersion() != _global.C2_DOMESTIC_DMB)
		tempArray[ICON_DMB] = undefined;

	// fill arrayIcon with icons in the needed order
	for (idx = 0; idx < iconArrangementArray.length; idx++)
	{
		if (tempArray[Number(iconArrangementArray[idx])] == undefined)
			continue;
		arrayIcon.push(mcStage["MCIcon" + iconArrangementArray[idx]]);
		arrayIcon[arrayIcon.length-1].arrayIndex = idx;
	}
	
	// hide those which are undefined in tempArray
	for (idx in tempArray)
	{
		if (tempArray[idx] == undefined)
			mcStage["MCIcon" + Number(idx)]._visible = false;
	}
	
	currentIconMaxPage = Math.ceil(arrayIcon.length / ONEPAGEICONS) - 1;
	limitBottom = -currentIconMaxPage * _global.LCD_HEIGHT;
}

function SetIconPosition(Void)
{
	for (var idx in arrayIcon)
	{
		with (arrayIcon[idx])
		{
			_x = (idx % HORIZONTAL_ICON) * ICONINTERVALX + HORIZONTAL_ICON_MARGIN;
			_y = Math.floor(idx / HORIZONTAL_ICON) * ICONINTERVALY + VERTICAL_ICON_MARGIN;
			_alpha = UNSELECTEDICON;
			_visible = true;
		}
	}
}

function InitWallpaper(Void)
{
	with (_root.MCCon)
		MCBg1._alpha = MCBg2._alpha = WALLPAPER_ALPHA;
	LoadWallpaper();
}

function LoadWallpaper(Void)
{
	with (_root.MCCon)
	{
		MCBg1[BASE_WALLPAPER_NAME].removeMovieClip();
		MCBg2[BASE_WALLPAPER_NAME].removeMovieClip();
		if (currWallpaperIdx > 0)
		{
			var wallpaperName = BASE_WALLPAPER_NAME + String(currWallpaperIdx);
			MCBg1.attachMovie(wallpaperName, BASE_WALLPAPER_NAME, MCBg1.getNextHighestDepth());
			MCBg2.attachMovie(wallpaperName, BASE_WALLPAPER_NAME, MCBg2.getNextHighestDepth());
		}
	}
}

function SaveMemo(Void)
{
	var _loc1;
	var _loc2;
	for (var _loc1 = 0; _loc1 < memoArray.length; ++_loc1)
	{
		if (memoArray[_loc1] != 33 && memoArray[_loc1] != 34)
		{
			break;
		} // end if
	} // end of for
	if (_loc1 < memoArray.length)
	{
		_loc2 = SharedObject.getLocal("mainmenu1_memo");
		_loc2.data.memoArray = memoArray;
		_loc2.flush();
		false;
	} // end if
}

function InitializeMemoWidget(Void)
{
	var _loc3;
	var _loc5;
	var _loc2;
	var _loc1;
	var _loc4;
	var _loc6 = SharedObject.getLocal("mainmenu1_memo");
	if (_loc6.data.memoArray != undefined)
	{
		memoArray = _loc6.data.memoArray;
	}
	else
	{
		memoArray = new Array(16, 21, 20, 34, 34, 25, 15, 21, 18, 34, 14, 1, 13, 5, 32);
		SaveMemo();
	}
	for (var _loc2 = 0; _loc2 <= 20; _loc2 = _loc2 + 10)
	{
		for (var _loc1 = 0; _loc1 < 5; ++_loc1)
		{
			_loc3 = _loc2 + _loc1 < 10 ? (String("0" + String(_loc2 + _loc1))) : (String(_loc2 + _loc1));
			if (_loc1 != 0)
			{
				_loc4 = mcWidget.MCFreeText["MCFreeText" + _loc5];
				mcWidget.MCFreeText["MCFreeText" + _loc3]._x = _loc4._x + _loc4._width;
			} // end if
			_loc5 = _loc3;
			mcWidget.MCFreeText["MCFreeText" + _loc3].gotoAndStop(memoArray[int(_loc2 / 10) * 5 + _loc1]);
		} // end of for
	} // end of for
	false;
}

function GetLastDay(month)
{
	var _loc1;
	if (month == 2)
	{
		if (selectedYear % 4 == 0)
		{
			if (selectedYear % 100 == 0 && selectedYear % 400 != 0)
			{
				_loc1 = 28;
			}
			else
			{
				_loc1 = 29;
			}
		}
		else
		{
			_loc1 = 28;
		}
	}
	else if (month < 8)
	{
		_loc1 = month % 2 == 0 ? (30) : (31);
	}
	else
	{
		_loc1 = month % 2 == 1 ? (30) : (31);
	}
	return (_loc1);
}

function ResetCalendarDate(Void)
{
	selectedYear = currentDate.getFullYear();
	selectedMonth = currentDate.getMonth() + 1;
	selectedDay = currentDate.getDate();
}

function SetCalendarDate(dir)
{
	selectedMonth = selectedMonth + dir;
	if (selectedMonth > 12)
	{
		if (selectedYear != 2030)
		{
			selectedMonth = 1;
			++selectedYear;
		}
		else
		{
			selectedMonth = 12;
		}
	}
	else if (selectedMonth < 1)
	{
		if (selectedYear != 1970)
		{
			selectedMonth = 12;
			--selectedYear;
		}
		else
		{
			selectedMonth = selectedMonth - dir;
		}
	}
}

function RegisterCalendarEvents(Void)
{
	mcWidget.MCCalendar.onPress = function (Void)
	{
		if (popup.isActive || busyFlag || movingPage)
			return;

		var delay = 12;
		var mode;
		if (this._xmouse > _global.LCD_WIDTH * 2 / 3)
		{
			mode = NEXT;
		}
		else if (this._xmouse > _global.LCD_WIDTH / 3)
		{
			mode = 0;
		}
		else
		{
			mode = PREV;
		}
		this.longKeyPressed = false;
		if (mode != 0)
		{
			this.onEnterFrame = function (Void)
			{
				if (delay-- < 0)
				{
					SetCalendarDate(mode);
					InitializeCalendarWidget(false);
					delay = 0;
					if (this.longKeyPressed == false)
					{
						RemoveMouseEvents();
					} // end if
					this.longKeyPressed = true;
				} // end if
			};
		}
		else
		{
			ResetCalendarDate();
			InitializeCalendarWidget(false);
		}
	};
	mcWidget.MCCalendar.onRelease = function (Void)
	{
		if (popup.isActive || busyFlag || movingPage)
			return;

		if (this.longKeyPressed == true)
		{
			SetMouseEvents();
		}
		else if (this.longKeyPressed != true && this.onEnterFrame != undefined)
		{
			SetCalendarDate(this._xmouse > _global.LCD_WIDTH >> 1 ? (NEXT) : (PREV));
			InitializeCalendarWidget(false);
		}
		delete this.onEnterFrame;
	};
}

function InitializeCalendarWidget(isInitialized)
{
	var _loc2 = mcWidget.MCCalendar;
	if (isInitialized == undefined || isInitialized == true)
	{
		delete currentDate;
		currentDate = new Date();
		RegisterCalendarEvents();
		ResetCalendarDate();
	} // end if
	var _loc7 = new Array("JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER");
	var _loc1;
	var _loc6 = new Date(selectedYear, selectedMonth - 1, 1);
	var _loc5 = GetLastDay(selectedMonth);
	var _loc3 = _loc6.getDay();
	var _loc4 = 0;
	_loc2.TXYear.text = selectedYear;
	_loc2.TXMonthName.text = _loc7[selectedMonth - 1];
	false;
	false;
	for (var _loc1 = 1; _loc1 <= 31; ++_loc1)
	{
		if (_loc1 > _loc5)
		{
			if (_loc2["Tx" + _loc1] != undefined)
			{
				_loc2["Tx" + _loc1]._visible = false;
			}
			else
			{
				break;
			}
			continue;
		} // end if
		if (_loc2["Tx" + _loc1] == undefined)
		{
			duplicateMovieClip(_loc2.TxDate, "Tx" + _loc1, _loc2.getNextHighestDepth());
		} // end if
		_loc2["Tx" + _loc1]._visible = true;
		if (_loc3 == 7)
		{
			_loc3 = 0;
			++_loc4;
			_loc2["Tx" + _loc1].textColor = "0xED8464";
		}
		else
		{
			_loc2["Tx" + _loc1].textColor = "0x857A72";
		}
		_loc2["Tx" + _loc1]._x = 46 * _loc3 + 10;
		_loc2["Tx" + _loc1]._y = 37 * _loc4 + 28;
		_loc2["Tx" + _loc1].text = _loc1;
		++_loc3;
	} // end of for
	_loc2.TxDate._visible = false;
	if (currentDate.getFullYear() == selectedYear && currentDate.getMonth() == selectedMonth - 1)
	{
		_loc2.MCCalendarFocus._visible = true;
		_loc2.MCCalendarFocus._x = _loc2["Tx" + selectedDay]._x - 11;
		_loc2.MCCalendarFocus._y = _loc2["Tx" + selectedDay]._y - 6;
		_loc2["Tx" + selectedDay].textColor = "0xECECE2";
	}
	else
	{
		_loc2.MCCalendarFocus._visible = false;
	}
}

function InitializeTimeWidget(Void)
{
	var mcTimeWidget = mcWidget.MCTimeWidget;
	var previousSecound = -1;
	if (mcTimeWidget.MCSec.onEnterFrame != undefined)
	{
		delete mcTimeWidget.MCSec.onEnterFrame;
	} // end if
	mcTimeWidget.MCSec.onEnterFrame = function (Void)
	{
		if (previousSecound != _global.g_curSec)
		{
			_global.CommonSetDigitMC(mcTimeWidget.MCSec, _global.g_curSec);
			_global.CommonSetDigitMC(mcTimeWidget.MCMinute, _global.g_curMin);
			_global.CommonSetDigitMC(mcTimeWidget.MCHour, _global.g_curHour);
			_global.DisplayTime(1);
			previousSecound = _global.g_curSec;
		} // end if
	};
}

/**/
function RegisterThumbnailListenerEvent(Void)
{
return;
	thumbnailImageLoader = new MovieClipLoader();
	thumbnailImageListener = new Object();
	ext_fscommand2("SetAudAlbumArtMCSize", "320");
	thumbnailImageListener.onLoadInit = function (mc)
	{
		var _loc4 = mc._width / mc._height;
		thumbnailImageLoader.removeListener(this);
		mcRecent.MCImage._visible = false;
		switch (mcRecent.launchApp)
		{
			case _global.MODE_VIDEO:
			{
				if (mc._width < 100 && mc._height < 100)
				{
					mcRecent.MCImage._visible = true;
					mc._visible = false;
					break;
				} // end if
			}
			case _global.MODE_MUSIC:
			{
				mc._x = -int(mc._width >> 1);
				mc._y = -120 + int(_global.LCD_HEIGHT - mc._height - 56 >> 1);
				break;
			}
			case _global.MODE_PICTURE:
			{
				_loc4 = mc._width / mc._height;
				if (mc._width < _global.LCD_WIDTH && mc._height < _global.LCD_HEIGHT)
				{
					mc._x = -int(mc._width >> 1);
					mc._y = -120 + int(_global.LCD_HEIGHT - mc._height - 56 >> 1);
				}
				else if (_loc4 > _global.LCD_WIDTH / _global.LCD_HEIGHT)
				{
					mc._width = _global.LCD_WIDTH;
					mc._height = _global.LCD_WIDTH / _loc4;
					mc._x = -160;
					mc._y = -120 + int(_global.LCD_HEIGHT - mc._height - 56 >> 1);
				}
				else
				{
					mc._height = _global.LCD_HEIGHT;
					mc._width = _global.LCD_HEIGHT * _loc4;
					mc._x = -int(mc._width >> 1);
					mc._y = -120;
				}
				break;
			}
		} // End of switch
	};
	thumbnailImageListener.onLoadError = function (mc, errorCode)
	{
		thumbnailImageLoader.removeListener(this);
		mcRecent.MCImage._visible = true;
	};
}

function GetRecentDMBChannelName(Void)
{
	var _loc9;
	var _loc5;
	var _loc4;
	var _loc6;
	var _loc7;
	var _loc8;
	ext_fscommand2("GetEtcUIConfig", _global.MODE_DMB, "tempString");
	_loc9 = tempString.split("|");
	if (_loc9 == undefined)
	{
		return ("No Information");
	}
	else
	{
		var _loc3;
		var _loc2 = 0;
		_loc5 = Number(_loc9[1]);
		_loc6 = _loc5 > 2 ? (1) : (2);
		_loc4 = Number(_loc9[_loc5 % 3 + 2]);
		_loc8 = Number(ext_fscommand2("GetMTVRegion")) ^ 1;
		_loc7 = ext_fscommand2("GetMTVTotalSvcIdx");
		for (var _loc3 = 0; _loc3 < _loc7; ++_loc3)
		{
			if (_loc6 == ext_fscommand2("GetMTVSvcType", _loc3))
			{
				if (_loc6 == 2)
				{
					if (ext_fscommand2("GetMTVBitrate", _loc3) < 250 && _loc8)
					{
						if (_loc5 == 2)
						{
							if (_loc2 == _loc4)
							{
								break;
							} // end if
							++_loc2;
						} // end if
					}
					else if (_loc5 == 1)
					{
						if (_loc2 == _loc4)
						{
							break;
						} // end if
						++_loc2;
					}
					continue;
				} // end if
				if (_loc2 == _loc4)
				{
					break;
				} // end if
				++_loc2;
			} // end if
		} // end of for
		if (_loc3 < _loc7)
		{
			if (ext_fscommand2("GetMTVSvcLable", _loc3, "tempString") == -1)
			{
				return ("No Information");
			}
			else
			{
				return (tempString);
			}
		}
		else
		{
			return ("No Information");
		}
	}
}

function InitializeRecentFile(Void)
{
	var recentMode = _global.GetRecentMode();
	var recentModeArr;
	var fileName;
	var fileMode: Boolean;
	var modeName;
	var currentFileIndex;

	recentModeArr = recentMode.split("/");
	if (recentModeArr == undefined || recentModeArr.length == 0)
		recentModeArr = new Array(String(_global.MODE_ETC));

	if (_global.__desktopMode)
		recentModeArr[0] = _global.MODE_ETC;

	mcRecent = _root.MCCon.MCRecent;

	// non-standard mode
	if (recentModeArr[0] == _global.MODE_ETC)
	{
		fileName = recentModeArr[1].substring(0, recentModeArr[1].length - 4).toLowerCase();
		// check if it was some of standard SWF's
		if (STANDARDSWFS.indexOf(fileName) != -1 && fileName != undefined && fileName != "")
			mcRecent.MCImage.gotoAndStop(fileName);
		else
			mcRecent.MCImage.gotoAndStop("empty");
		mcRecent.launchApp = recentModeArr[1];
		modeName = fileName;
		fileName = "";
		fileMode = false;
	}
	// standard mode
	else
	{
		mcRecent.launchApp = Number(recentModeArr[0]);
		modeName = modeArray[mcRecent.launchApp];
		if (modeName != null)
			mcRecent.MCImage.gotoAndStop(modeName);
		else
			mcRecent.MCImage.gotoAndStop("empty");
		switch (mcRecent.launchApp)
		{
			case _global.MODE_MUSIC:
			case _global.MODE_VIDEO:
			case _global.MODE_PICTURE:
			{
				fileMode = true;
				RegisterThumbnailListenerEvent();
				var ext;
				if (mcRecent.launchApp == _global.MODE_MUSIC)
				{
					ext_fscommand2("EtcModChangeMode", "Music");
					ext = ".MU0";
				}
				else if (mcRecent.launchApp == _global.MODE_VIDEO)
				{
					ext_fscommand2("EtcModChangeMode", "Video");
					ext = ".VID";
				}
				else if (mcRecent.launchApp == _global.MODE_PICTURE)
				{
					ext_fscommand2("EtcModChangeMode", "Picture");
					ext = ".PM0";
				}
				currentFileIndex = ext_fscommand2("GetEtcCurPLIndex");
				if (currentFileIndex != -1)
				{
					thumbnailImageLoader.loadClip(String(currentFileIndex) + ext, mcRecent.MCLoader);
					thumbnailImageLoader.addListener(thumbnailImageListener);
					ext_fscommand2("GetEtcFileName", currentFileIndex, "tempString");
					fileName = tempString;
				}
				else
				{
					fileName = "";
				}
				break;
			}
			case _global.MODE_RADIO:
			{
				fileName = String(Number(ext_fscommand2("GetFmrCurrentFreq") / 1000)) + " MHz";
				fileMode = false;
				break;
			}
			case _global.MODE_DMB:
			{
				fileName = GetRecentDMBChannelName();
				fileMode = false;
				break;
			}
			case _global.MODE_TEXT:
			case _global.MODE_TEXTBROWSER:
			{
				ext_fscommand2("EtcModChangeMode", "Text");
				ext_fscommand2("GetEtcFileName", 0, "tempString");
				fileName = String(tempString);
				fileMode = true;
				break;
			}
			case _global.MODE_FLASH:
			case _global.MODE_FLASHBROWSER:
			{
				ext_fscommand2("EtcModChangeMode", "Flash");
				ext_fscommand2("EtcBrwSetInitialize");
				currentFileIndex = ext_fscommand2("EtcBrwGetCurIndex");
				ext_fscommand2("EtcBrwGetListString", currentFileIndex, "tempString");
				fileName = String(tempString);
				fileMode = true;
				break;
			}
			default:
			{
				fileName = "";
				fileMode = false;
			}
		} // End of switch
	}
	
	if (fileName == "" || fileName == "null" || fileName == undefined)
		fileName = (fileMode ? "No recent File" : "");

	// mcRecent._x = _global.LCD_WIDTH;
	// mcRecent._y = 0;
	mcRecent.MCHeader.TxFileName.text = fileName;
	mcRecent.MCHeader.TxMode.text = modeName.toUpperCase();
	_global.CommonResetStringScroll();
	_global.CommonSetStringScroll(mcRecent.MCHeader.TxFileName, 0);
}

// widget <-> icon <-> recent, on horisontal slide
function ChangeMode(direction, acceleration)
{
	var diff;
	var step = 0;
	var targetPositionX;
	if (currentMode - direction < 0 || currentMode - direction > RECENTMODE)
	{
		return;
	} // end if
	currentMode = currentMode - direction;
	targetPositionX = -(currentMode - 1) * _global.LCD_WIDTH;

	if (currentMode == ICONMODE)
	{
		UnregisterClockMouseEvent();
		UnregisterMemoMouseEvent();
	}
	else if (currentMode == WIDGETMODE)
	{
		RegisterMemoMouseEvent();
		RegisterClockMouseEvent();
	}
	if (acceleration > 0.700000)
	{
		acceleration = 0.900000;
	}
	else if (acceleration < 0.300000)
	{
		acceleration = 0.300000;
	}
	movingPage = true;
	mcWidget.onEnterFrame = function (Void)
	{
		if (mouseTouch == true)
		{
			delete this.onEnterFrame;
		} // end if
		diff = targetPositionX - _root.MCCon._x;
		if (Math.abs(diff) > 3 && acceleration != undefined)
		{
			_root.MCCon._x = _root.MCCon._x + int(diff * acceleration);
		}
		else if (step == 0)
		{
			_root.MCCon._x = targetPositionX;
			step = 1;
		}
		else
		{
			movingPage = false;
			_root.MCCon.MCRecentArrow._rotation = 0;
			if (currentMode == RECENTMODE)
			{
				limitBottom = LIMITTOP;
			}
			else
			{
				limitBottom = -currentIconMaxPage * _global.LCD_HEIGHT;
			}
			delete this.onEnterFrame;
		}
		DisplayAlphaBlending(_global.LCD_WIDTH >> 1, diff);
	};
}

// widget / icon page cycle, on vertical slide
function MovePage(direction, acceleration, draggingMC)
{
	var diff;
	var step = 0;
	var targetPositionY;
	var ptrMC;
	if (currentMode == ICONMODE)
	{
		currentPage = currentPage + direction;
		if (currentPage < 0 || currentPage > currentIconMaxPage)
		{
			currentPage = currentPage - direction;
		} // end if
		targetPositionY = -currentPage * _global.LCD_HEIGHT;
		ptrMC = mcStage;
	}
	else
	{
		currentWidget = currentWidget + direction;
		if (currentWidget < 0 || currentWidget > WIDGETMAXPAGE)
		{
			currentWidget = currentWidget - direction;
		} // end if
		targetPositionY = -currentWidget * _global.LCD_HEIGHT;
		ptrMC = mcWidget;
	}
	if (acceleration > 0.700000)
	{
		acceleration = 0.900000;
	}
	else if (acceleration < 0.300000)
	{
		acceleration = 0.300000;
	}
	movingPage = true;
	ptrMC.onEnterFrame = function (Void)
	{
		diff = targetPositionY - ptrMC._y;
		if (Math.abs(diff) > 3 && acceleration != undefined)
		{
			ptrMC._y = ptrMC._y + int(diff * acceleration);
			if (draggingMC != undefined)
			{
				draggingMC._y = ptrMC._ymouse;
			} // end if
		}
		else if (step == 0)
		{
			ptrMC._y = targetPositionY;
			step = 1;
		}
		else
		{
			movingPage = false;
			if (draggingMC != undefined)
			{
				draggingMC._y = ptrMC._ymouse;
			} // end if
			delete this.onEnterFrame;
		}
		DisplayAlphaBlending(_global.LCD_HEIGHT >> 1, diff);
		if (mouseTouch == true)
		{
			delete this.onEnterFrame;
		} // end if
	};
}

// slide the stage to the screen - just a visual effect
function StartUpEffect(postProcess)
{
	var delay = 3;
	var targetY = 0;
	var step = 0;
	var _loc3 = currentPage;
	currentPage = 0;
	if (_global.GetPrevLauncherMode() == -1 || _global.GetPrevLauncherMode() == _global.MODE_MAIN)
	{
		isStarting = true;
		mcStage._y = _global.LCD_HEIGHT;
		mcStage.onEnterFrame = function (Void)
		{
			if (--delay < 0)
			{
				diff = targetY - this._y;
				if (step == 1)
				{
					this._y = -2.500000;
					step = 2;
				}
				else if (step == 2)
				{
					this._y = 0;
					isStarting = false;
					postProcess();
					delete this.onEnterFrame;
				}
				else if (Math.abs(diff) > 3)
				{
					this._y = this._y + diff * 0.350000;
				}
				else if (step == 0)
				{
					step = 1;
				}
			}
		};
	}
	else
	{
		mcStage._y = 0;
		mcWidget._y = 0;
		MovePage(_loc3, 0.900000);
		postProcess();
	}
}

// perform an action on icon click
function ExecuteSubMenu(iconIndex)
{
	switch (iconIndex)
	{
		// execute some action
		case ICON_ROTATE:
		{
			var _loc2 = ext_fscommand2("GetSysDisplayRotation");
			if (_loc2 != -1)
			{
				_loc2 = _loc2 ^ 1;
				ext_fscommand2("SetSysDisplayRotation", _loc2);
			} // end if
			break;
		}
		case ICON_SLEEP:
		case ICON_POWEROFF:
		{
			RemoveMouseEvents(); // ! block all mouse events
			popup.show(TPopup.BOX_PROMPT, "",
				function(promptResult)
				{
					SetMouseEvents();
					if (promptResult == TPopup.RES_YES)
						ext_fscommand2("SetSysOffFlag", (iconIndex == ICON_POWEROFF) ? 2 : 1);
				});
			break;
		}
		case ICON_THEME:
		{
			ext_fscommand2("EtcUsrSetMainmenu", 0);
			_global.LoadSWF(_global.MODE_MAIN);
			break;
		}
		case ICON_WALLPAPER:
		{
			currWallpaperIdx++;
			if (currWallpaperIdx > WALLPAPER_COUNT)
				currWallpaperIdx = 0;
			LoadWallpaper();
			break;
		}
		// load SWF
		default:
		{
			var swfArr = new Array(MODE_MUSIC, MODE_VIDEO, MODE_PICTURE, MODE_DMB, MODE_RADIO, MODE_TEXT, MODE_FLASHBROWSER, MODE_RECORD, MODE_BROWSER, "Calculator.swf", MODE_SETTING, "Notepad.swf", "Typist.swf", "Stopwatch.swf");
			if (isNaN(swfArr[iconIndex]))
				_global.LoadSWF(_global.MODE_ETC, swfArr[iconIndex]);
			else
				_global.LoadSWF(Number(swfArr[iconIndex]));
		}
	} // End of switch
}

function RegisterClockMouseEvent(Void)
{
	var clockSetting = false;
	mcWidget.MCTimeWidget.onPress = function (Void)
	{
		if (popup.isActive || isBlocking || movingPage)
		{
			return;
		} // end if
		var timeOut = 12;
		if (clockSetting == false)
		{
			this.onEnterFrame = function (Void)
			{
				if (--timeOut < 0)
				{
					clockSetting = true;
					TimeSetting(true);
					delete this.onEnterFrame;
				} // end if
			};
		}
		else
		{
			clockSetting = false;
			TimeSetting(false);
		}
	};
	mcWidget.MCTimeWidget.onRelease = function (Void)
	{
		delete this.onEnterFrame;
	};
}

function UnregisterClockMouseEvent(Void)
{
	delete mcWidget.MCTimeWidget.onPress;
	delete mcWidget.MCTimeWidget.onRelease;
}

function RegisterMemoMouseEvent(Void)
{
	mcWidget.MCFreeText.onPress = function (Void)
	{
		if (popup.isActive || isBlocking || movingPage)
		{
			return;
		} // end if
		var timeOut = 12;
		if (mcWidget.MCKeyboard == undefined)
		{
			this.onEnterFrame = function (Void)
			{
				if (--timeOut < 0)
				{
					ShowInputBox();
					delete this.onEnterFrame;
				} // end if
			};
		} // end if
	};
	mcWidget.MCFreeText.onRelease = function (Void)
	{
		delete this.onEnterFrame;
	};
}

function UnregisterMemoMouseEvent(Void)
{
	delete mcWidget.MCFreeText.onEnterFrame;
	delete mcWidget.MCFreeText.onPress;
	delete mcWidget.MCFreeText.onRelease;
}

function RegisterIconEvents(Void)
{
	var mouseDown = false;
	for (var idx in arrayIcon)
	{
		arrayIcon[idx].onPress = function (Void)
		{
			if (popup.isActive || isBlocking || movingPage || isStarting)
				return;
			var iconIdx = Number(this._name.substring(6));
			var timeOut = 12;
			this._alpha = SELECTEDICON;
			selectedItem = iconIdx;
			mouseDown = true;
			this.onEnterFrame = function (Void)
			{
				if (--timeOut < 0)
				{
					delete this.onEnterFrame;
					RegisterMouseEventWhileDragging(this);
					DragIcon(this);
				} // end if
			};
		};
		
		arrayIcon[idx].onDragOut = function (Void)
		{
			if (!isBlocking)
			{
				selectedItem = -1;
				delete this.onEnterFrame;
				this._alpha = UNSELECTEDICON;
				mouseDown = false;
			} // end if
		};
		
		arrayIcon[idx].onRelease = function (Void)
		{
			if (popup.isActive || !mouseDown || isStarting)
				return;
			var iconIdx = Number(this._name.substring(6));
			delete this.onEnterFrame;
			mouseDown = false;
			if (isBlocking)
			{
				DropIcon(iconIdx);
			}
			else
			{
				this._alpha = UNSELECTEDICON;
				ExecuteSubMenu(iconIdx);
			}
		};
		
		arrayIcon[idx].onReleaseOutside = function (Void)
		{
			this._alpha = UNSELECTEDICON;
			selectedItem = -1;
		};
	} // end of for
}

function RegisterRecentFileEvent(Void)
{
	var executeMenu;
	mcRecent.onPress = function (Void)
	{
		executeMenu = true;
	};
	mcRecent.onDragOut = function (Void)
	{
		executeMenu = false;
	};
	mcRecent.onRelease = function (Void)
	{
		if (!executeMenu)
			return;
		currentPage = 0;
		if (isNaN(mcRecent.launchApp))
			_global.LoadSWF(_global.MODE_ETC, mcRecent.launchApp);
		else
			_global.LoadSWF(mcRecent.launchApp);
	};
}

function UnregisterRecentFileEvent(Void)
{
	delete mcRecent.onPress;
	delete mcRecent.onDragOut;
	delete mcRecent.onRelease;
}

/**/
function Position2Index(tmpMC)
{
trace("Position2Index");
	var _loc2 = (currentPage + 1) * ONEPAGEICONS;
	var _loc4 = Math.round((tmpMC._y + 61) / ICONINTERVALY) * HORIZONTAL_ICON;
	var _loc3 = Math.round(Math.round(tmpMC._x + 110) / ICONINTERVALX) % HORIZONTAL_ICON;
	var _loc1 = _loc4 + _loc3;
	if (_loc2 > MAXICONS)
	{
		_loc2 = MAXICONS;
	} // end if
	if (_loc1 < 0)
	{
		_loc1 = -1;
	}
	else if (_loc1 >= _loc2)
	{
		_loc1 = _loc2 - 1;
	}
	return (_loc1);
}

function DragIcon(selectedMC)
{
trace("DragIcon"); return;
	isBlocking = true;
	selectedMC.startDrag();
	selectedMC.swapDepths(mcStage.getNextHighestDepth());
	selectedMC.previousPage = currentPage;
	RemoveMouseEvents();
	for (var idx in arrayIcon)
		arrayIcon._alpha = BLURICON;
	selectedMC._alpha = UNSELECTEDICON;
}

/**/
function SetIconTargetPosition(idx, direct)
{
trace("SetIconTargetPosition"); return;
	if (direct)
	{
		//	_x = (idx % HORIZONTAL_ICON) * ICONINTERVALX + HORIZONTAL_ICON_MARGIN;
		//	_y = Math.floor(idx / HORIZONTAL_ICON) * ICONINTERVALY + VERTICAL_ICON_MARGIN;

		arrayIcon[idx]._x = int(arrayIcon[idx].arrayIndex % ONEPAGEICONS % HORIZONTAL_ICON - 1) * ICONINTERVALX;
		arrayIcon[idx]._y = int(arrayIcon[idx].arrayIndex / HORIZONTAL_ICON) * ICONINTERVALY;
	}
	else
	{
		arrayIcon[idx].targetX = int(arrayIcon[idx].arrayIndex % ONEPAGEICONS % HORIZONTAL_ICON - 1) * ICONINTERVALX;
		arrayIcon[idx].targetY = int(arrayIcon[idx].arrayIndex / HORIZONTAL_ICON) * ICONINTERVALY;
	}
}

/**/
function DropIcon(selectedIndex)
{
trace("DropIcon");
	var counter = 0;
	var iconNumber;
	var diffX;
	var diffY;
	var startIdx;
	var endIdx;
	var tmpMC;
	var selectedMC = mcStage["MCIcon" + selectedIndex];
	var _loc3 = selectedMC.arrayIndex;
	var _loc4 = -1;
	var idx;
	var _loc6 = currentPage * ONEPAGEICONS;
	var _loc5 = _loc6 + ONEPAGEICONS;
	var traceArray = new Array(90, 75, 95, 105, 100);
	selectedMC.stopDrag();
	delete selectedMC.onMouseMove;
	if (_loc5 > arrayIcon.length)
		_loc5 = arrayIcon.length;

	for (idx = _loc6; idx < _loc5; idx++)
		if (idx != _loc3)
			if (arrayIcon[idx].hitTest(_root._xmouse, _root._ymouse, true) == true)
				_loc4 = idx;

	if (_loc4 != -1)
	{
		selectedMC.arrayIndex = _loc4;
		SetIconTargetPosition(_loc3, false);
		if (_loc3 < _loc4)
		{
			for (idx = _loc4; idx > _loc3; idx--)
			{
				--arrayIcon[idx].arrayIndex;
				SetIconTargetPosition(idx, false);
			} // end of for
			arrayIcon.splice(_loc4 + 1, 0, selectedMC);
			arrayIcon.splice(_loc3, 1);
			startIdx = _loc3;
			endIdx = _loc4 + 1;
		}
		else if (_loc3 > _loc4)
		{
			for (idx = _loc4; idx < _loc3; idx++)
			{
				++arrayIcon[idx].arrayIndex;
				SetIconTargetPosition(idx, false);
			} // end of for
			arrayIcon.splice(_loc4, 0, selectedMC);
			arrayIcon.splice(_loc3 + 1, 1);
			startIdx = _loc4;
			endIdx = _loc3 + 1;
		}
	}
	else
	{
		startIdx = _loc3;
		endIdx = _loc3 + 1;
		_loc4 = _loc3;
		SetIconTargetPosition(_loc3, false);
	}
	iconNumber = endIdx - startIdx;
	arrayIcon[_loc4].onEnterFrame = function (Void)
	{
		for (idx = startIdx; idx < endIdx; idx++)
		{
			tmpMC = arrayIcon[idx];
			diffX = tmpMC.targetX - tmpMC._x;
			diffY = tmpMC.targetY - tmpMC._y;
			if (Math.abs(diffX) + Math.abs(diffY) > 7)
			{
				tmpMC._x = tmpMC._x + diffX / 3;
				tmpMC._y = tmpMC._y + diffY / 3;
			}
			else if (counter > iconNumber)
			{
				tmpMC._x = tmpMC.targetX;
				tmpMC._y = tmpMC.targetY;
				selectedMC._xscale = selectedMC._yscale = 100;
				for (idx = startIdx; idx < endIdx; idx++)
				{
					tmpMC = arrayIcon[idx];
					tmpMC._x = tmpMC.targetX;
					tmpMC._y = tmpMC.targetY;
				} // end of for
				for (idx = 0; idx < arrayIcon.length; idx++)
				{
					arrayIcon[idx]._alpha = UNSELECTEDICON;
				} // end of for
				SetMouseEvents();
				isBlocking = false;
				selectedItem = -1;
				delete this.onEnterFrame;
				break;
			}
			else
			{
				++counter;
				tmpMC._x = tmpMC.targetX;
				tmpMC._y = tmpMC.targetY;
			}
			selectedMC._xscale = selectedMC._yscale = Number(traceArray.shift());
		} // end of for
	};
}

function GetLastIndex(Void)
{
	for (var _loc1 = memoArray.length - 1; _loc1 >= 0; --_loc1)
	{
		if (Number(memoArray[_loc1]) != 34)
			return (_loc1 + 1);
	} // end of for
	return (0);
}

function PrintText(lineIndex)
{
	var _loc2 = GetLastIndex();
	var _loc1;
	var _loc3 = " ABCDEFGHIJKLMNOPQRSTUVWXYZ!?&[]_ ";
	for (idx = 0; idx < 3; idx++)
	{
		mcWidget.MCKeyboard["TxInput" + idx].text = "";
	} // end of for
	if (_loc2 != 0)
	{
		for (idx = 0; idx < _loc2; idx++)
		{
			_loc1 = int(idx / 5);
			mcWidget.MCKeyboard["TxInput" + _loc1].text = mcWidget.MCKeyboard["TxInput" + _loc1].text + _loc3.charAt(memoArray[idx]);
		} // end of for
	} // end if
	BlinkCursor();
}

function BlinkCursor(Void)
{
	mcWidget.MCKeyboard.MCCursor._visible = !mcWidget.MCKeyboard.MCCursor._visible;
	if (mcWidget.MCKeyboard.MCCursor._visible)
	{
		var _loc2;
		var _loc1 = int(GetLastIndex() / 5);
		if (_loc1 > 2)
		{
			_loc1 = 2;
		} // end if
		_loc2 = mcWidget.MCKeyboard["TxInput" + _loc1];
		mcWidget.MCKeyboard.MCCursor._x = _loc2._x + ext_fscommand2("EtcNpdGetStringWidth", String(_loc2.text)) + 3;
	} // end if
}

function RegisterKeyboardEvent(Void)
{
	var _loc2;
	var lastIndex = GetLastIndex();
	var _loc4 = " ABCDEFGHIJKLMNOPQRSTUVWXYZ!?&[]_ ";
	var _loc3 = mcWidget.MCKeyboard.TxInput.getTextFormat();
	PrintText();
	ext_fscommand2("EtcNpdSetFontStyle", Number(_loc3.size), 0);
	false;
	intervalID = setInterval(this, "BlinkCursor", 700);
	mcWidget.MCKeyboard.MCClose.onPress = function (Void)
	{
		this.gotoAndStop(2);
	};
	mcWidget.MCKeyboard.MCClose.onDragOut = function (Void)
	{
		this.gotoAndStop(1);
	};
	mcWidget.MCKeyboard.MCClose.onRelease = function (Void)
	{
		this.gotoAndStop(1);
		SaveMemo();
		InitializeMemoWidget();
		SetMouseEvents();
		UnregisterKeyboardEvent();
		mcWidget.MCKeyboard.removeMovieClip();
	};
	mcWidget.MCKeyboard.MCBackspace.deleteChar = function (Void)
	{
		if (lastIndex > 0)
		{
			if (lastIndex >= 0)
			{
				--lastIndex;
			} // end if
			memoArray[lastIndex] = 34;
			lastIndex = GetLastIndex();
			PrintText();
		} // end if
		BlinkCursor();
	};
	mcWidget.MCKeyboard.MCBackspace.onPress = function (Void)
	{
		this.gotoAndStop(2);
		var vKeySpeed = 15;
		this.deleteChar();
		this.onEnterFrame = function (Void)
		{
			if (vKeySpeed-- < 0)
			{
				this.deleteChar();
				vKeySpeed = 0;
			} // end if
		};
	};
	mcWidget.MCKeyboard.MCBackspace.onDragOut = function (Void)
	{
		this.gotoAndStop(1);
		delete this.onEnterFrame;
	};
	mcWidget.MCKeyboard.MCBackspace.onRelease = function (Void)
	{
		this.gotoAndStop(1);
		delete this.onEnterFrame;
	};
	for (var _loc2 = 0; _loc2 <= 33; ++_loc2)
	{
		mcWidget.MCKeyboard["MCkey" + _loc2].onPress = function (Void)
		{
			this.gotoAndStop(2);
		};
		mcWidget.MCKeyboard["MCkey" + _loc2].onDragOut = function (Void)
		{
			this.gotoAndStop(1);
		};
		mcWidget.MCKeyboard["MCkey" + _loc2].onRelease = function (Void)
		{
			var _loc2 = Number(this._name.substring(5));
			this.gotoAndStop(1);
			if (lastIndex < memoArray.length)
			{
				memoArray[lastIndex] = _loc2;
				PrintText();
				++lastIndex;
			} // end if
			BlinkCursor();
		};
	} // end of for
}

function UnregisterKeyboardEvent(Void)
{
	var _loc1;
	clearInterval(intervalID);
	delete mcWidget.MCKeyboard.MCClose.onPress;
	delete mcWidget.MCKeyboard.MCClose.onRelease;
	delete mcWidget.MCKeyboard.MCClose.onDragOut;
	delete mcWidget.MCKeyboard.MCBackspace.onPress;
	delete mcWidget.MCKeyboard.MCBackspace.onRelease;
	delete mcWidget.MCKeyboard.MCBackspace.onDragOut;
	delete mcWidget.MCKeyboard.MCEnter.onPress;
	delete mcWidget.MCKeyboard.MCEnter.onRelease;
	delete mcWidget.MCKeyboard.MCEnter.onDragOut;
	for (var _loc1 = 0; _loc1 <= 33; ++_loc1)
	{
		delete mcWidget.MCKeyboard["MCkey" + _loc1].onPress;
		delete mcWidget.MCKeyboard["MCkey" + _loc1].onDragOut;
		delete mcWidget.MCKeyboard["MCkey" + _loc1].onRelease;
	} // end of for
}

/**/
function ShowInputBox(Void)
{
	var _loc1 = mcWidget.MCFreeText;
	RemoveMouseEvents();
	mcWidget.attachMovie("MCKeyboard", "MCKeyboard", mcWidget.getNextHighestDepth());
	mcWidget.MCKeyboard._x = mcWidget.MCFreeText._x - KEYBOARD_OFFSET_X;
	mcWidget.MCKeyboard._y = mcWidget.MCFreeText._y - KEYBOARD_OFFSET_Y;
	RegisterKeyboardEvent();
}

function SetCurrentTime(level, mode)
{
	var _loc3 = mcWidget.MCTimeWidget;
	var _loc2 = new Date();
	var _loc6 = _loc2.getFullYear();
	var _loc5 = _loc2.getMonth();
	var _loc4 = _loc2.getDate();
	if (level == 0)
	{
		hour = hour + mode;
		hour = _loc2.setHours(hour);
		hour = _loc2.getHours();
	}
	else
	{
		minute = minute + mode;
		minute = _loc2.setMinutes(minute);
		minute = _loc2.getMinutes();
	}
	ext_fscommand2("SetTimTime", _loc6, _loc5, _loc4, hour, minute, null);
	_global.CommonSetDigitMC(_loc3.MCSec, 0);
	_global.CommonSetDigitMC(_loc3.MCMinute, minute);
	_global.CommonSetDigitMC(_loc3.MCHour, hour);
	_global.DisplayTime(1);
}

function RegisterTimeControllerEvent(Void)
{
	var _loc3 = mcWidget.MCTimeController;
	_loc3.MCHourControl.MCUp.mode = _loc3.MCMinControl.MCUp.mode = NEXT;
	_loc3.MCHourControl.MCDown.mode = _loc3.MCMinControl.MCDown.mode = PREV;
	_loc3.MCHourControl.MCUp.level = _loc3.MCHourControl.MCDown.level = 0;
	_loc3.MCMinControl.MCUp.level = _loc3.MCMinControl.MCDown.level = 1;
	_loc3.MCHourControl.MCUp.onPress = _loc3.MCHourControl.MCDown.onPress = _loc3.MCMinControl.MCUp.onPress = _loc3.MCMinControl.MCDown.onPress = function (Void)
	{
		var delay = 12;
		this.gotoAndStop(2);
		this.longKeyPressed = false;
		this.onEnterFrame = function (Void)
		{
			if (delay-- < 0)
			{
				SetCurrentTime(this.level, this.mode);
				delay = 0;
				this.longKeyPressed = true;
			} // end if
		};
	};
	_loc3.MCHourControl.MCUp.onRelease = _loc3.MCHourControl.MCDown.onRelease = _loc3.MCMinControl.MCUp.onRelease = _loc3.MCMinControl.MCDown.onRelease = function (Void)
	{
		if (popup.isActive)
			return;

		if (this.longKeyPressed != true && this.onEnterFrame != undefined)
		{
			SetCurrentTime(this.level, this.mode);
		} // end if
		delete this.onEnterFrame;
		this.gotoAndStop(1);
	};
	_loc3.MCHourControl.MCUp.onDragOut = _loc3.MCHourControl.MCDown.onDragOut = _loc3.MCMinControl.MCUp.onDragOut = _loc3.MCMinControl.MCDown.onDragOut = function (Void)
	{
		delete this.onEnterFrame;
		this.gotoAndStop(1);
	};
}

function UnregisterTimeControllerEvent(Void)
{
	delete mcTimeWidget.MCHourControl.MCUp.onEnterFrame;
	delete mcTimeWidget.MCHourControl.MCDown.onEnterFrame;
	delete mcTimeWidget.MCMinControl.MCUp.onEnterFrame;
	delete mcTimeWidget.MCMinControl.MCDown.onEnterFrame;
	delete mcTimeWidget.MCHourControl.MCUp.onPress;
	delete mcTimeWidget.MCHourControl.MCDown.onPress;
	delete mcTimeWidget.MCMinControl.MCUp.onPress;
	delete mcTimeWidget.MCMinControl.MCDown.onPress;
	delete mcTimeWidget.MCHourControl.MCUp.onRelease;
	delete mcTimeWidget.MCHourControl.MCDown.onRelease;
	delete mcTimeWidget.MCMinControl.MCUp.onRelease;
	delete mcTimeWidget.MCMinControl.MCDown.onRelease;
	delete mcTimeWidget.MCHourControl.MCUp.onDragOut;
	delete mcTimeWidget.MCHourControl.MCDown.onDragOut;
	delete mcTimeWidget.MCMinControl.MCUp.onDragOut;
	delete mcTimeWidget.MCMinControl.MCDown.onDragOut;
}

/**/
function TimeSetting(clockSetting)
{
	var _loc2 = mcWidget.MCTimeWidget;
	if (clockSetting == true)
	{
		RemoveMouseEvents();
		mcWidget.attachMovie("MCTimeController", "MCTimeController", mcWidget.getNextHighestDepth());
		mcWidget.MCTimeController._x = _loc2._x;
		mcWidget.MCTimeController._y = _loc2._y;
		mcWidget.MCTimeController.MCSecControl._visible = false;
		delete _loc2.MCSec.onEnterFrame;
		RegisterTimeControllerEvent();
		_global.CommonSetDigitMC(_loc2.MCSec, 0);
	}
	else
	{
		SetCurrentTime(1, 0);
		UnregisterTimeControllerEvent();
		mcWidget.MCTimeController.removeMovieClip();
		SetMouseEvents();
		InitializeTimeWidget();
	}
}

/**/
function RegisterMouseEventWhileDragging(currentMC)
{
	var counter = 0;
	var MARGIN = 30;
	var _loc3 = -1; /**///?
	mouseTouch = false;
	currentMC.onMouseMove = function (Void)
	{
		if (_root._ymouse < MARGIN)
			counter--;
		else if (_root._ymouse > _global.LCD_HEIGHT - MARGIN)
			counter++;
		else
			counter = 0;
		if (counter < -12)
		{
			if (currentPage == 0)
				return;
			counter = 0;
			MovePage(PREV, 0.800000, currentMC);
		}
		else if (counter > 12)
		{
			if (currentPage == currentIconMaxPage)
				return;
			counter = 0;
			MovePage(NEXT, 0.800000, currentMC);
		}
	};
}

// set the movieclip's blending according to drag position
function DisplayAlphaBlending(halfLength, currentLocation)
{
	var alpha = (MOVEPAGEALPHAMAX - Math.abs((halfLength - Math.abs(currentLocation)) * MOVEPAGEALPHAMAX / halfLength));
	mcWidget._alpha = mcStage._alpha = mcRecent._alpha = 100 - alpha;
}

/**/
// only performed once at startup
function InitializeMouseEvents(Void)
{
	var startX;
	var startY;
	var newStartX;
	var newStartY;
	var startTime;
	var counter;
	var direction;
	var intervalY;
	var initXPosition;
	var initYPosition;
	var initPage;
	var dragFlag;
	var touchBoundary = 15;
	var upAndDownMovement = false;
	var move2RecentMode = false;
	var ptrMC;

	mouseListener.onMouseDown = function (Void)
	{
		if (popup.isActive || move2RecentMode || isStarting)
			return;

		_root.MCCon.MCHold._visible = false;
		startX = newStartX = _root._xmouse;
		startY = newStartY = _root.MCCon._ymouse;
		mouseTouch = true;
		move2RecentMode = false;
		if (mcStage.onEnterFrame != undefined || mcWidget.onEnterFrame != undefined)
		{
			dragFlag = true;
			initYPosition = int(ptrMC._y);
			startY = newStartY = int(_root.MCCon._ymouse);
			delete mcStage.onEnterFrame;
			delete mcWidget.onEnterFrame;
		} // end if

		initXPosition = -(currentMode - 1) * _global.LCD_WIDTH;
		if (currentMode == ICONMODE)
			initPage = currentPage;
		else if (currentMode == WIDGETMODE)
			initPage = currentWidget;
		else
			initPage = 0;

		this.onMouseMove = function (Void)
		{
			intervalX = int(_root._xmouse - startX);
			intervalY = int(_root.MCCon._ymouse - startY);
			if (dragFlag)
			{
				// vertical slide - change page
				if (upAndDownMovement)
				{
					if (ptrMC._y >= LIMITTOP && intervalY > 0 || ptrMC._y <= limitBottom && intervalY < 0)
						intervalY = int(intervalY >> 1);
					if (intervalY / direction < 0)
					{
						direction = -direction;
						counter = 1;
						startTime = getTimer();
						newStartY = _root.MCCon._ymouse;
					}
					else if (Math.abs(intervalY) < 5)
					{
						++counter;
						newStartY = _root.MCCon._ymouse;
					}
					else if (counter != 0)
					{
						counter = 0;
						startTime = getTimer();
					}
					ptrMC._y = initYPosition + intervalY;
					DisplayAlphaBlending(_global.LCD_HEIGHT >> 1, intervalY);
				}
				// horizontal slide - change mode
				else
				{
					if (_root.MCCon._x >= LIMITLEFT && intervalX > 0 || _root.MCCon._x <= LIMITRIGHT && intervalX < 0)
						intervalX = int(intervalX >> 1);
					if (intervalX / direction < 0)
					{
						direction = -direction;
						counter = 1;
						startTime = getTimer();
						newStartX = _root._xmouse;
					}
					else if (Math.abs(intervalX) < 5)
					{
						++counter;
						newStartX = _root._xmouse;
					}
					else if (counter != 0)
					{
						counter = 0;
						startTime = getTimer();
					}
					_root.MCCon._x = initXPosition + intervalX;
					DisplayAlphaBlending(_global.LCD_WIDTH >> 1, intervalX);
				}
			}
			else if (Math.abs(intervalY) > touchBoundary || Math.abs(intervalX) > touchBoundary)
			{
				mcRecent.onDragOut();
				mcStage["MCIcon" + selectedItem].onDragOut();
				delete mcWidget.MCTimeWidget.onEnterFrame;
				delete mcWidget.MCFreeText.onEnterFrame;
				delete mcWidget.MCCalendar.onEnterFrame;
				selectedItem = -1;
				if (Math.abs(intervalY) > touchBoundary)
				{
					direction = (intervalY < 0) ? -1 : 1;
					if (currentMode == ICONMODE)
						ptrMC = mcStage;
					else if (currentMode == WIDGETMODE)
						ptrMC = mcWidget;
					else
						ptrMC = mcRecent;
					initYPosition = int(ptrMC._y);
					upAndDownMovement = true;
					startY = newStartY = int(_root.MCCon._ymouse);
				}
				else
				{
					direction = (intervalX < 0) ? -1 : 1;
					upAndDownMovement = false;
					startX = newStartX = int(_root._xmouse);
				}
				dragFlag = true;
				counter = 0;
				startTime = getTimer();
			}
		};
	};
	
	mouseListener.onMouseUp = function (Void)
	{
		delete this.onMouseMove;
		if (popup.isActive || !dragFlag)
			return;
		if (!movingPage && (selectedItem != -1 || isStarting))
			return;
		dragFlag = false;
		mouseTouch = false;
		var acceleration;
		var _loc6 = (getTimer() - startTime) * 1.500000;
		// vertical slide
		if (upAndDownMovement)
		{
			var page;
			var maxpage;
			acceleration = Math.abs(intervalY / _loc6) + 0.170000;
			if (Math.abs(intervalY) > 60)
				acceleration = Math.max(acceleration, 0.500000);
			direction = initYPosition - ptrMC._y;
			if (currentMode == ICONMODE)
			{
				page = currentPage;
				maxpage = currentIconMaxPage;
			}
			else if (currentMode == WIDGETMODE)
			{
				page = currentWidget;
				maxpage = WIDGETMAXPAGE;
			}
			else
			{
				page = 0;
				maxpage = 0;
			}
			if (acceleration < 0.200000 || (direction < 0 && page == 0 || direction > 0 && page == maxpage))
			{
				movingPage = true;
				if (acceleration > 0.400000)
				{
					acceleration = 0.500000;
					initPage = (page == maxpage) ? 0 : maxpage;
					if (currentMode == ICONMODE)
						currentPage = initPage;
					else if (currentMode == WIDGETMODE)
						currentWidget = initPage;
				}
				else
				{
					acceleration = Math.max(Math.min(acceleration, 0.500000), 0.300000);
				}
				initYPosition = -initPage * _global.LCD_HEIGHT;
				ptrMC.onEnterFrame = function (Void)
				{
					if (mouseTouch)
						delete this.onEnterFrame;
					intervalY = initYPosition - this._y;
					if (Math.abs(intervalY) > 3)
					{
						this._y += int(intervalY * acceleration);
					}
					else
					{
						delete this.onEnterFrame;
						this._y = initYPosition;
						movingPage = false;
					}
					DisplayAlphaBlending(_global.LCD_HEIGHT >> 1, intervalY);
				};
			}
			else if (intervalY < 0)
			{
				MovePage(NEXT, acceleration);
			}
			else
			{
				MovePage(PREV, acceleration);
			}
		}
		// horizontal slide
		else
		{
			var traceIndex = 2;
			acceleration = Math.abs(intervalX / _loc6) + 0.160000;
			if (Math.abs(intervalX) > 100)
			{
				acceleration = Math.max(acceleration, 0.500000);
			} // end if
			direction = initXPosition - _root.MCCon._x;
			if (acceleration < 0.200000 || (direction > 0 && currentMode == RECENTMODE || direction < 0 && currentMode == WIDGETMODE))
			{
				movingPage = true;
				acceleration = Math.max(Math.min(acceleration, 0.500000), 0.300000);
				initXPosition = -(currentMode - 1) * _global.LCD_WIDTH;
				mcWidget.onEnterFrame = function (Void)
				{
					if (mouseTouch == true)
					{
						delete this.onEnterFrame;
					} // end if
					intervalX = initXPosition - _root.MCCon._x;
					if (Math.abs(intervalX) > 3)
					{
						_root.MCCon._x = _root.MCCon._x + int(intervalX * acceleration);
					}
					else if (move2RecentMode == true && traceIndex > 0)
					{
						--traceIndex;
						mcRecent._x = traceIndex * -4;
					}
					else
					{
						_root.MCCon._x = initXPosition;
						movingPage = false;
						delete this.onEnterFrame;
					}
					DisplayAlphaBlending(_global.LCD_WIDTH >> 1, intervalX);
				};
			}
			else if (intervalX < 0)
			{
				ChangeMode(PREV, acceleration);
			}
			else
			{
				ChangeMode(NEXT, acceleration);
			}
		}
	};
	
	SetMouseEvents();
}

function SetMouseEvents(Void)
{
	Mouse.addListener(mouseListener);
}

function RemoveMouseEvents(Void)
{
	Mouse.removeListener(mouseListener);
}

function ConvertFreq2String(frequency)
{
	var _loc3;
	var _loc1;
	var _loc2;
	_loc3 = int(frequency / 1000);
	if (ext_fscommand2("GetFmrRegion") > 0)
	{
		_loc1 = int(frequency % 1000 / 100);
		_loc2 = _loc3 + "." + _loc1;
	}
	else
	{
		_loc1 = int(frequency % 1000 / 10);
		if (_loc1 < 10)
		{
			_loc2 = _loc3 + "." + "0" + _loc1;
		}
		else
		{
			_loc2 = _loc3 + "." + _loc1;
		}
	}
	return (_loc2);
}

function SaveConfiguration(Void)
{
	// construct icon placement order
	tempString = "";
	// not for-in, we need direct order here!
	for (var idx = 0; idx < arrayIcon.length; idx++)
		tempString =
			tempString + (tempString == "" ? "" : "/") +
			arrayIcon[idx]._name.substring(6);
	// construct config array
	var tempArray =
		new Array(VERSION, _global.GetFirmwareVersion(), currentPage, currentWidget,
		          String(currWallpaperIdx), tempString);
	ext_fscommand2("SetEtcUIConfig", _global.MODE_MAIN2, tempArray.join("|"));
}

// reads config and returns icon placement order string
function LoadConfiguration(Void)
{
	ext_fscommand2("GetEtcUIConfig", _global.MODE_MAIN2, "tempString");
	var tempArray = tempString.split("|");
	if (tempArray[0] == VERSION && tempArray[1] == _global.GetFirmwareVersion())
	{
		// apply config
		var prevMode = _global.GetPrevLauncherMode();
		if (prevMode == _global.MODE_MAIN || prevMode == -1 || prevMode == undefined)
			currentPage = 0;
		else
			currentPage = Number(tempArray[2]);
		currentWidget = Number(tempArray[3]);
		currWallpaperIdx = Number(tempArray[4]);
		// return icon placement order
		tempString = tempArray[5];
	}
	else
	{
		currentPage = 0;
		currentWidget = 1;
		currWallpaperIdx = 0;
		tempString = null;
	}

	return (tempString);
}

function DisplayHoldStatus(Void)
{
	var newHoldStatus = ext_fscommand2("GetSysHoldKey");
	var holdIconTimeOut = 12;
	var holdMC = _root.MCCon.MCHold;
	if (holdStatus != newHoldStatus)
	{
		if (newHoldStatus == 1)
		{
			holdMC.gotoAndStop(1);
			delete holdMC.onEnterFrame;
			holdMC._x = currentMode * _global.LCD_WIDTH - holdMC._width;
			holdMC._visible = true;
			holdMC.swapDepths(_root.MCCon.getNextHighestDepth());
		}
		else if (holdStatus != -1)
		{
			holdMC.gotoAndStop(2);
			delete holdMC.onEnterFrame;
			holdMC.onEnterFrame = function (Void)
			{
				if (holdIconTimeOut-- < 0)
				{
					holdMC._visible = false;
					delete this.onEnterFrame;
				} // end if
			};
		}
		else
		{
			holdMC._visible = false;
		}
		holdStatus = newHoldStatus;
	} // end if
}

/**/ // ?
function DisplayUpdate(Void)
{
	var _loc2;
	DisplayHoldStatus();
	if (mcRecent.launchApp == _global.MODE_MUSIC)
	{
		if (ext_fscommand2("GetEtcState") == _global.STATE_MUSIC_PLAY)
		{
			_loc2 = ext_fscommand2("GetEtcCurPLIndex");
			if (currentFileIndex != _loc2)
			{
				ext_fscommand2("GetEtcFileName", _loc2, "tempString");
				mcRecent.MCHeader.TxFileName.text = tempString;
				thumbnailImageLoader.loadClip(String(_loc2 + ".MU0"), mcRecent.MCLoader);
				thumbnailImageLoader.addListener(thumbnailImageListener);
				currentFileIndex = _loc2;
			} // end if
		} // end if
	} // end if
}

function InitializeMainMenu(Void)
{
_root.MCCon._x = _root.MCCon._y = 0; /**///???
	_global.UpdateSystemInfo(1);
	DisplayHoldStatus();
	ext_fscommand2("EtcModSetWidgetMode", 1);
	InitializeIcons(LoadConfiguration());
	SetIconPosition();
	InitializeCalendarWidget(true);
	InitializeTimeWidget();
	InitializeMemoWidget();
	InitializeEvents();
	RegisterIconEvents();
	InitializeRecentFile();
	RegisterRecentFileEvent();
	StartUpEffect(InitializeMouseEvents);
	InitWallpaper();
	_global.RegisterKeyListener(KeyHandlerMainMenu);
}

function KeyHandlerMainMenu(keyType)
{
	switch (keyType)
	{
		case _global.KEY_PLAY_SHORT:
		{
			teststuff();
			break;
		}
		case KEY_PLUS_SHORT:
		case KEY_PLUS_LONG:
		{
			ext_fscommand2("KeyComPlus");
			_global.DisplayVolume(1);
			break;
		}
		case KEY_MINUS_SHORT:
		case KEY_MINUS_LONG:
		{
			ext_fscommand2("KeyComMinus");
			_global.DisplayVolume(1);
			break;
		}
		case _global.KEY_HOLD:
		{
			DisplayHoldStatus();
			break;
		}
		case _global.KEY_DISPLAY_UPDATE:
		{
			DisplayUpdate();
			break;
		}
	} // End of switch
}

function teststuff()
{
	debug(_global.GetRecentMode());

///**/debug(_global.bugoga);
	// ext_fscommand2("SetEtcUIConfig", _global.MODE_MAIN2, "");
	// InitializeIcons(LoadConfiguration());
	// SetIconPosition();
}

//** Execute section **\\

this.onUnload = function (Void)
{
	SaveConfiguration();
	RemoveMouseEvents();
	UnregisterRecentFileEvent();
	delete mouseListener;
	delete popup;
	for (var idx in arrayIcon)
		delete arrayIcon.onEnterFrame;
	delete thumbnailImageListener;
	delete thumbnailImageLoader;
	delete _root.MCCon.onEnterFrame;
	delete _root.MCCon.MCHold.onEnterFrame;
	delete mcStage.onEnterFrame;
	delete mcWidget.onEnterFrame;
	delete mcWidget.MCTimeWidget.onEnterFrame;
	ext_fscommand2("EtcModSetWidgetMode", 0);
	delete arrayIcon;
};

initDebug(_root.TXDebug);
InitializeMainMenu();