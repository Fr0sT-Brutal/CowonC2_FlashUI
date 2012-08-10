#include "CowonCommon.as"

function fn_Music_Show_SelectedAlbum()
{
	brwObject.RegistEvent();
	Common_DrawScrollBar();
	gShowAlbumFlag = 1;
	mcMatrixAlbum._visible = false;
	mcBtmTitle._visible = false;
	mcBtmPage._visible = false;
	mcPlayIcon._visible = false;
	mcMatrixBG._visible = false;
	mcDetailAlbum._visible = true;
	mcDetailAlbum.MCMtxAlbum._rotation = 0;
} // End of the function

function fn_Music_Hide_SelectedAlbum()
{
	fn_Music_Set_PrevStep();
	mcMatrixAlbum._visible = true;
	ext_fscommand2("SetAudAlbumBMCSize", gMatrixWidth - 1);
	mcMatrixAlbum._visible = true;
	mcBtmTitle._visible = true;
	mcPlayIcon._visible = true;
	mcBtmPage._visible = matrixTotalIdx > NUM_VIEW_MATRIX;
	brwObject.RemoveEvent();
	mcDetailAlbum._visible = false;
} // End of the function

function fn_Music_Set_PrevStep()
{
	var _loc1;
	_loc1 = ext_fscommand2("EtcBrwSetPrevStage");
	if (_loc1 >= 0)
	{
		trTotalIdx = _loc1;
	} // end if
} // End of the function

function fn_Music_Set_NextStep(curIndex)
{
	var _loc2;
	pMode = undefined;
	_loc2 = ext_fscommand2("EtcBrwSetNextStage", curIndex, "pMode");
	if (_loc2 >= 0)
	{
		gCurrentPage = 0;
		trTotalIdx = _loc2;
	} // end if
	if (pMode == undefined)
	{
		gMatrixCurIndex = curIndex;
		brwObject.currentPage = 0;
		brwObject.currentIndex = 0;
		brwObject.startField = 0;
		brwObject.prevIndex = -1;
		brwObject.selectbarIdx = 0;
		brwObject.totalIndex = trTotalIdx;
		Common_GetCurrentIndex();
		Common_DrawSelectBar(-1);
		brwObject.RelocateTextField();
		Common_InitScrollBar();
		Common_GetList();
	}
	else
	{
		gMatrixAlbumIndex = gMatrixCurIndex;
		Common_FadeOutSelectBar();
	} // end else if
} // End of the function

var mcPlayIcon = mcCon.MCMatrix.MCPlay;
var mcBtmTitle = mcCon.MCMatrix.TXTitle;
var mcBtmPage = mcCon.MCMatrix.TXPage;
var mcMatrixAlbum = mcCon.MCMatrix.MCAlbum;
var mcDetailAlbum = mcCon.MCMatrix.MCDetail;
var mcMatrixBG = mcCon.MCMatrix.MCBg;
var mcBtnBack = mcCon.MCMatrix.MCBack;
var mcBtnListBack = mcDetailAlbum.MCBack;
var mcListScrollTouch = mcDetailAlbum.MCTrack.MCScroll;
var mcListScrollBar = mcListScrollTouch.MCScrollbar;
var mcListTouch = mcDetailAlbum.MCTrack.MCTouch;
var mcListTitle = mcDetailAlbum.MCTrack.MCList;
var mcListSelect = mcListTitle.MCSelect;
var mcListABTitle = mcDetailAlbum.MCTrack.TXTitle;
var matrixLoader = new MovieClipLoader();
var matrixListener = new Object();
var albumLoader = new MovieClipLoader();
var albumListener = new Object();
var matrixArray = new Object();
var dirtyArray = new Array();
var matrixCurIdx;
var matrixTotalIdx;
var matrixStartIdx;
var trCurIdx;
var trTotalIdx;
var gMatrixCurIndex = -1;
var gMatrixAlbumIndex = -1;
var gAlbumWidth = 350;
var gAlbumHeight = 350;
var gMatrixWidth = 100;
var gMatrixHeight = 100;
var gMatrixMove = false;
var gProgressIdx = 0;
var gShowAlbumFlag = 0;
var gaTextField = new Array();
var gScrollResult = -1;
var gapX;
var brwObject = new Object();
brwObject.totalIndex = -1;
brwObject.startField = 0;
brwObject.currentPage = 0;
brwObject.currentIndex = 0;
brwObject.prevIndex = -1;
brwObject.selectbarIdx = 0;
var SCROLLHEIGHT = 200;
var LINEINTERVAL = 5;
var TEXTFIELDHEIGHT = 40;
var BASE_Y = 10;
var MAX_BOTTOM_Y = LINEINTERVAL * TEXTFIELDHEIGHT;
mcListScrollTouch._height = SCROLLHEIGHT;
var gLow = 2;
var gViewColume = 4;
var gColume = gViewColume + 16;
var gLeftIdx = 0;
var gRightIdx = 0;
var gStartX = 0;
var gStartY = 0;
var gMouseStart = 0;
var gStartTick = 0;
var gDrag = false;
var gStop = 0;
var mouseYPosition;
var mouseXPosition;
var startTime;
var elapsedTime;
var multiplier;
var startX;
var startY;
var endX;
var endY;
var accX;
var accY;
var MODE_MATRIX = 1;
var MODE_ALBUMLIST = 2;
var LIMIT_MOVE = gMatrixWidth * ((gColume - gViewColume) / 2 - 1);
var LIMIT_LEFT_Y = -gMatrixWidth * (gColume - gViewColume) / 2;
var LIMIT_RIGHT_Y = gMatrixWidth * (gColume - gViewColume) / 2 + _global.LCD_WIDTH;
var MOVE_MATRIX_WIDTH = gMatrixWidth * gColume;
var NUM_MATRIX = gLow * gColume;
var NUM_VIEW_MATRIX = gViewColume * gLow;

matrixListener.onLoadInit = function (mc)
{
	var _loc2;
	mc._xscale = 100;
	mc._yscale = 100;
	mc._rotation = 0;
	mc._parent.MCBG._visible = false;
	mc._visible = true;
	if (mc._width == mc._height)
	{
		mc._x = 0;
		mc._y = 0;
	}
	else
	{
		_loc2 = mc._width / mc._height;
		if (_loc2 > 1)
		{
			mc._x = 0;
			mc._y = 0 + (gMatrixHeight - 1 - mc._height) / 2;
		}
		else
		{
			mc._x = 0 + (gMatrixWidth - 1 - mc._width) / 2;
			mc._y = 0;
		} // end else if
	} // end else if
};

matrixListener.onLoadError = function (mc)
{
	mc._parent.MCBG._visible = true;
	mc._visible = false;
};

AlbumListener.onLoadInit = function (mc)
{
	mcDetailAlbum.MCMtxAlbum.MCDefaultAlbum._visible = false;
	var _loc3 = mc._width;
	var _loc2 = mc._height;
	mc._xscale = mc._yscale = 100;
	mc._x = mc._y = -175;
	if (_loc3 == _loc2)
	{
		mc._width = mc._height = gAlbumWidth;
	}
	else if (_loc3 > _loc2)
	{
		mc._width = gAlbumWidth;
		mc._height = int(_loc2 * gAlbumWidth / _loc3);
		mc._y = int((gAlbumWidth - mc._height) / 2) - 175;
	}
	else
	{
		mc._width = int(_loc3 * gAlbumWidth / _loc2);
		mc._height = gAlbumWidth;
		mc._x = int((gAlbumWidth - mc._width) / 2) - 175;
	} // end else if
	fn_Music_Set_NextStep(trCurIdx);
	fn_Music_Show_SelectedAlbum();
};

AlbumListener.onLoadError = function (mc)
{
	mcDetailAlbum.MCMtxAlbum.MCDefaultAlbum._visible = true;
	fn_Music_Set_NextStep(trCurIdx);
	fn_Music_Show_SelectedAlbum();
};

DirtyPop = function ()
{
	if (dirtyArray.length == 0 || LoadMatrixArt._visible == false || gDrag == true && dirtyArray.length < 4)
	{
		return;
	} // end if
	var _loc1 = Number(dirtyArray.shift());
	LoadMatrixArt(matrixArray[_loc1].idx, matrixArray[_loc1]);
};

DirtyPush = function (mcIdx, abIdx)
{
	if (abIdx < 0)
	{
		abIdx = abIdx + matrixTotalIdx;
	} // end if
	abIdx = abIdx % matrixTotalIdx;
	matrixArray[mcIdx].idx = abIdx;
	dirtyArray.push(mcIdx);
	matrixArray[mcIdx].MCBG._visible = true;
	matrixArray[mcIdx].MCLoader._visible = false;
};

mcDetailAlbum.onEnterFrame = function ()
{
	if (mcMatrixAlbum._visible == true)
	{
		DirtyPop();
	}
	else if (gPlayState == true && gMatrixAlbumIndex == gMatrixCurIndex)
	{
		++mcDetailAlbum.MCMtxAlbum._rotation;
	} // end else if
	fn_ProgressUpdate();
};

fn_ProgressInit = function ()
{
	mcBtmPage.text = String(matrixCurIdx + 1) + " / " + String(matrixTotalIdx);
};

fn_ProgressUpdate = function ()
{
	mcBtmPage.text = String(matrixCurIdx + 1) + " / " + String(matrixTotalIdx);
};

Init = function ()
{
	if (_global.__desktopMode)/**/
		matrixTotalIdx = 10;
	else
		matrixTotalIdx = ext_fscommand2("EtcBrwSetInitialization", "Album");
	matrixCurIdx = ext_fscommand2("EtcBrwGetCurIndex");
	gMatrixAlbumIndex = gMatrixCurIndex = matrixCurIdx;
	mcDetailAlbum.MCMtxAlbum._rotation = 0;
	_global.UpdateSystemInfo(1);
	ext_fscommand2("SetAudAlbumArtIndex", 0);
	ext_fscommand2("SetAudAlbumBMCSize", gMatrixWidth - 1);
	InvisiblePopup();
	mcDetailAlbum._visible = false;
	mcMatrixBG._visible = false;
	fn_ProgressInit();
	Show_PlayStatus();
	matrixLoader.addListener(matrixListener);
	albumLoader.addListener(albumListener);
	mcBtmPage._visible = matrixTotalIdx > NUM_VIEW_MATRIX;
	CreateMatrix();
	for (i = 0; i < LINEINTERVAL; i++)
		gaTextField[i] = mcListTitle["TXTitle" + (i + 1)];
};

Key_UpdateDisp = function ()
{
	var _loc3 = mcDRMPopup.TXMessage.text;
	var _loc2;
	if (matrixTotalIdx < 0)
	{
		return;
	} // end if
	_loc2 = ext_fscommand2("GetEtcOpenState", "gTmpString");
	if (_loc2 == 0)
	{
		mcDRMPopup.TXMessage.text = _loc3;
	}
	else if (_loc2 >= 100)
	{
		mcDRMPopup.TXMessage.text = gTmpString;
		_global.gfn_SetPopupMCName(MCPopDRM, 0);
	}
	else
	{
		_global.gfn_SetPopupMCName(mcDRMPopup, 1);
		_global.gfn_Common_SetTimer(1000, gfn_SetPopupMCName);
	} // end else if
	Show_PlayStatus();
};

Show_PlayStatus = function ()
{
	gPlayState = ext_fscommand2("GetEtcState");
	if (gPlayState == STATE_PLAY)
	{
		mcPlayIcon.gotoAndStop(3);
	}
	else
	{
		mcPlayIcon.gotoAndStop(1);
	} // end else if
	var _loc3 = 0;
	var _loc2 = ext_fscommand2("GetEtcCurPLIndex");
	_loc3 = ext_fscommand2("GetAudTitle", _loc2, "gTmpString");
	if (_loc3 == -1)
	{
		ext_fscommand2("GetEtcFileName", _loc2, "gTmpString");
		mcBtmTitle.text = gTmpString;
	}
	else
	{
		mcBtmTitle.text = gTmpString;
	} // end else if
	_global.CommonResetStringScroll();
	idxScrollTitle = _global.gfn_Common_SetStringScroll(mcBtmTitle);
};

CreateMatrix = function ()
{
	var x = 0;
	var y = 0;
	var tgtIdx = 0;
	var tmpString;
	if (matrixTotalIdx <= gViewColume * gLow)
	{
		matrixStartIdx = 0;
		gLeftIdx = 0;
		gRightIdx = 0;
	}
	else
	{
		matrixStartIdx = matrixCurIdx - int(gViewColume * gLow / 2) - (gColume - gViewColume) / 2 * gLow;
		if (matrixStartIdx < 0)
		{
			matrixStartIdx = matrixStartIdx + matrixTotalIdx;
		} // end if
		gLeftIdx = 0;
		gRightIdx = (gColume - 1) * gLow;
	} // end else if
	for (x = 0; x < gColume; x++)
	{
		for (y = 0; y < gLow; y++)
		{
			tgtIdx = x * gLow + y;
			tmpString = "MCMatrix" + String(tgtIdx);
			if (matrixTotalIdx <= gViewColume * gLow)
			{
				if (tgtIdx < matrixTotalIdx)
				{
					matrixArray[tgtIdx] = mcMatrixAlbum.attachMovie("MCAlbumArt", tmpString, mcMatrixAlbum.getNextHighestDepth());
					with (matrixArray[tgtIdx])
					{
						_x = x * gMatrixWidth;
						_y = y * gMatrixHeight;
					} // End of with
					LoadMatrixArt(matrixStartIdx + tgtIdx, matrixArray[tgtIdx]);
				} // end if
				continue;
			} // end if
			matrixArray[tgtIdx] = mcMatrixAlbum.attachMovie("MCAlbumArt", tmpString, mcMatrixAlbum.getNextHighestDepth());
			with (matrixArray[tgtIdx])
			{
				_x = -(gColume - gViewColume) / 2 * gMatrixWidth + x * gMatrixWidth;
				_y = y * gMatrixHeight;
			} // End of with
			if (tgtIdx >= ((gColume - gViewColume) / 2 - (gColume - gViewColume) / 4) * gLow && tgtIdx <= ((gColume - gViewColume) / 2 + gViewColume + (gColume - gViewColume) / 4) * gLow)
			{
				LoadMatrixArt(matrixStartIdx + tgtIdx, matrixArray[tgtIdx]);
				continue;
			} // end if
			var tmp = matrixStartIdx + tgtIdx;
			tmp = tmp % matrixTotalIdx;
			matrixArray[tgtIdx].idx = tmp;
			DirtyPush(tgtIdx, matrixArray[tgtIdx].idx);
		} // end of for
	} // end of for
	matrixStartIdx = 0;
	return (true);
};

LoadMatrixArt = function (idx, mc)
{
	if (idx < 0)
	{
		idx = idx + matrixTotalIdx;
	} // end if
	idx = idx % matrixTotalIdx;
	mc.idx = idx;
	if (_global.__desktopMode)
		var _loc2 = "test.jpg";
	else
		var _loc2 = String(idx) + ".ab1";
	matrixLoader.loadClip(_loc2, mc.MCLoader);
};

SetMatrix = function ()
{
	MoveMatrix(0, true);
	var _loc2 = mcMatrixAlbum._x % gMatrixWidth;
	if (_loc2 == 0)
	{
		gMatrixMove = false;
		return;
	} // end if
	if (_loc2 < 0)
	{
		_loc2 = _loc2 + gMatrixWidth;
	} // end if
	var dist;
	var len = 0;
	if (_loc2 > gMatrixWidth / 2)
	{
		dist = gMatrixWidth - _loc2;
	}
	else
	{
		dist = -_loc2;
	} // end else if
	mcMatrixAlbum.onEnterFrame = function ()
	{
		if (dist > 0)
		{
			len = int(dist * 0.700000);
			if (len == 0)
			{
				len = 1;
			} // end if
			if (len > 50)
			{
				len = 50;
				dist = dist - 50;
			}
			else
			{
				dist = dist - len;
			} // end else if
		}
		else if (dist < 0)
		{
			len = int(dist * 0.700000);
			if (len == 0)
			{
				len = -1;
			} // end if
			if (len < -50)
			{
				len = -50;
				dist = dist + 50;
			}
			else
			{
				dist = dist - len;
			} // end else if
		}
		else
		{
			delete this.onEnterFrame;
			gMatrixMove = false;
			MoveMatrix(0, true);
			return;
		} // end else if
		MoveMatrix(len, true);
	};

};

MoveMatrix = function (offset, update)
{
	if (matrixTotalIdx <= NUM_VIEW_MATRIX)
	{
		return;
	} // end if
	mcMatrixAlbum._x = mcMatrixAlbum._x + offset;
	if (update == false)
	{
		return;
	} // end if
	var _loc2 = 0;
	var _loc1 = 0;
	var _loc5 = 0;
	if (int(mcMatrixAlbum._x / gMatrixWidth) != matrixStartIdx)
	{
		var _loc3 = matrixStartIdx;
		matrixStartIdx = int(mcMatrixAlbum._x / gMatrixWidth);
		var _loc4 = Math.abs(matrixStartIdx - _loc3);
		for (j = 0; j < _loc4; j++)
		{
			if (_loc3 - matrixStartIdx < 0)
			{
				for (var _loc2 = 0; _loc2 < gLow; ++_loc2)
				{
					_loc1 = gRightIdx + _loc2;
					matrixArray[_loc1]._x = matrixArray[_loc1]._x - MOVE_MATRIX_WIDTH;
					matrixArray[_loc1].idx = matrixArray[_loc1].idx - NUM_MATRIX;
					DirtyPush(_loc1, matrixArray[_loc1].idx);
				} // end of for
				gRightIdx = gRightIdx - gLow;
				gLeftIdx = gLeftIdx - gLow;
				matrixCurIdx = matrixCurIdx - 2;
			}
			else
			{
				for (var _loc2 = 0; _loc2 < gLow; ++_loc2)
				{
					_loc1 = gLeftIdx + _loc2;
					matrixArray[_loc1]._x = matrixArray[_loc1]._x + MOVE_MATRIX_WIDTH;
					matrixArray[_loc1].idx = matrixArray[_loc1].idx + NUM_MATRIX;
					DirtyPush(_loc1, matrixArray[_loc1].idx);
				} // end of for
				gRightIdx = gRightIdx + gLow;
				gLeftIdx = gLeftIdx + gLow;
				matrixCurIdx = matrixCurIdx + 2;
			} // end else if
			if (gRightIdx < 0)
			{
				gRightIdx = gRightIdx + NUM_MATRIX;
			} // end if
			if (gLeftIdx < 0)
			{
				gLeftIdx = gLeftIdx + NUM_MATRIX;
			} // end if
			if (matrixCurIdx < 0)
			{
				matrixCurIdx = matrixCurIdx + matrixTotalIdx;
			} // end if
			gLeftIdx = gLeftIdx % NUM_MATRIX;
			gRightIdx = gRightIdx % NUM_MATRIX;
			matrixCurIdx = matrixCurIdx % matrixTotalIdx;
		} // end of for
	} // end if
};

Common_FadeOutSelectBar = function (counterNumber)
{
	var selectbarCounter;
	if (counterNumber != undefined)
	{
		selectbarCounter = counterNumber;
	}
	else
	{
		selectbarCounter = 6;
	} // end else if
	mcListSelect.onEnterFrame = function (Void)
	{
		if (--selectbarCounter > 0)
		{
			return;
		} // end if
		if (brwObject.selectbarIdx != -1)
		{
			brwObject.selectbarIdx = -1;
		} // end if
		if (brwObject.prevIndex != -1)
		{
			_global.CommonResetStringScroll(brwObject.prevIndex);
			brwObject.prevIndex = -1;
		} // end if
		this._alpha = this._alpha - this._alpha / 9;
		if (this._alpha < 5)
		{
			delete this.onEnterFrame;
			Common_DrawSelectBar(-1);
		} // end if
	};

};

Common_InitScrollBar = function ()
{
	var _loc1 = brwObject.totalIndex * TEXTFIELDHEIGHT;
	var _loc2 = int(SCROLLHEIGHT * SCROLLHEIGHT / _loc1);
	if (brwObject.totalIndex <= LINEINTERVAL)
	{
		mcListScrollBar._height = 0;
	}
	else if (_loc2 < 10)
	{
		mcListScrollBar._height = 10;
		multiplier = TEXTFIELDHEIGHT * (SCROLLHEIGHT - 10) / _loc1;
	}
	else
	{
		mcListScrollBar._height = _loc2;
		multiplier = TEXTFIELDHEIGHT * SCROLLHEIGHT / _loc1;
	} // end else if
	Common_DrawScrollBar();
};

Common_GetList = function ()
{
	var _loc1 = 0;
	var _loc2;
	while (_loc1 < LINEINTERVAL)
	{
		_loc2 = _loc1 + brwObject.startField;
		if (_loc2 >= LINEINTERVAL)
		{
			_loc2 = _loc1 + brwObject.startField - LINEINTERVAL;
		} // end if
		brwObject.GetListIdx(_loc2, brwObject.currentPage + _loc1);
		++_loc1;
	} // end while
	Common_FadeOutScrollBar();
};

Common_EnableScrollBar = function ()
{
	delete mcListScrollBar.onEnterFrame;
	mcListScrollBar._alpha = 100;
};

Common_DrawScrollBar = function ()
{
	if (brwObject.totalIndex <= LINEINTERVAL)
	{
		return;
	} // end if
	mcListScrollBar._y = int(brwObject.currentPage * multiplier);
};

Common_FadeOutScrollBar = function ()
{
	var scrollbarCounter = 48;
	mcListScrollBar.onEnterFrame = function (Void)
	{
		if (--scrollbarCounter > 0)
		{
			return;
		} // end if
		this._alpha = this._alpha - this._alpha / 9;
		if (this._alpha < 10)
		{
			delete this.onEnterFrame;
			this._alpha = 0;
		} // end if
	};

};

Common_DrawSelectBar = function (lineIndex, noScroll)
{
	if (lineIndex != -1)
	{
		lineIndex = lineIndex + brwObject.startField;
		if (lineIndex >= LINEINTERVAL)
		{
			lineIndex = lineIndex - LINEINTERVAL;
		} // end if
		mcListSelect._alpha = 100;
		mcListSelect._y = gaTextField[lineIndex]._y - BASE_Y;
		_global.CommonResetStringScroll(brwObject.prevIndex);
		brwObject.selectbarIdx = lineIndex;
		if (noScroll != true)
		{
			brwObject.prevIndex = _global.CommonSetStringScroll(gaTextField[lineIndex], 0);
		} // end if
	}
	else
	{
		mcListSelect._alpha = 0;
		if (brwObject.selectbarIdx != -1)
		{
			brwObject.selectbarIdx = -1;
		} // end if
		_global.CommonResetStringScroll(brwObject.prevIndex);
		brwObject.prevIndex = -1;
	} // end else if
};

Common_GetCurrentIndex = function ()
{
	brwObject.currentIndex = 0;
	brwObject.currentPage = 0;
	if (brwObject.currentIndex >= LINEINTERVAL)
	{
		if (brwObject.totalIndex - LINEINTERVAL > brwObject.currentIndex)
		{
			brwObject.currentPage = brwObject.currentIndex - int((LINEINTERVAL - 1) / 2);
		}
		else
		{
			brwObject.currentPage = brwObject.totalIndex - LINEINTERVAL;
		} // end else if
		brwObject.currentIndex = brwObject.currentIndex - brwObject.currentPage;
	} // end if
};

Common_MouseMovementHandler = function (currentMC)
{
	var _loc1 = currentMC._ymouse - mouseYPosition;
	if (_loc1 != 0)
	{
		blockRelease = 1;
		brwObject.MoveTextField(_loc1);
		mouseXPosition = currentMC._xmouse;
		mouseYPosition = currentMC._ymouse;
	} // end if
};

brwObject.RelocateTextField = function ()
{
	var _loc2 = 0;
	this.startField = 0;
	while (_loc2 < LINEINTERVAL)
	{
		gaTextField[_loc2]._y = TEXTFIELDHEIGHT * _loc2 + BASE_Y;
		++_loc2;
	} // end while
};

brwObject.MoveTextField = function (intervalY)
{
	if (intervalY > 180)
	{
		intervalY = 180;
	}
	else if (intervalY < -180)
	{
		intervalY = -180;
	} // end else if
	var _loc4 = 0;
	var _loc5 = 0;
	var _loc1;
	_loc4 = brwObject.startField;
	_loc5 = int((intervalY + gaTextField[brwObject.startField]._y) / TEXTFIELDHEIGHT);
	if (intervalY < 0)
	{
		if (brwObject.currentPage - _loc5 + LINEINTERVAL > brwObject.totalIndex)
		{
			intervalY = intervalY / 3;
			++gStop;
			_loc5 = brwObject.currentPage + LINEINTERVAL - brwObject.totalIndex;
		} // end if
		intervalY = int(intervalY);
		for (var _loc2 = 0; _loc2 < LINEINTERVAL; ++_loc2)
		{
			realIndex = _loc4 + _loc2;
			if (realIndex >= LINEINTERVAL)
			{
				realIndex = realIndex - LINEINTERVAL;
			} // end if
			_loc1 = gaTextField[realIndex];
			_loc1._y = _loc1._y + intervalY;
			if (_loc1._y < -TEXTFIELDHEIGHT / 2)
			{
				if (brwObject.currentPage + LINEINTERVAL < brwObject.totalIndex)
				{
					++brwObject.currentPage;
					if (++brwObject.startField >= LINEINTERVAL)
					{
						brwObject.startField = 0;
					} // end if
					_loc1._y = MAX_BOTTOM_Y + _loc1._y;
					brwObject.GetListIdx(realIndex, brwObject.currentPage + (LINEINTERVAL - 1));
					Common_DrawScrollBar();
				} // end if
			} // end if
		} // end of for
	}
	else
	{
		if (brwObject.currentPage - _loc5 < 0)
		{
			intervalY = intervalY / 3;
			++gStop;
			_loc5 = brwObject.currentPage;
		} // end if
		intervalY = int(intervalY);
		for (var _loc2 = LINEINTERVAL - 1; _loc2 >= 0; --_loc2)
		{
			realIndex = _loc4 + _loc2;
			if (realIndex >= LINEINTERVAL)
			{
				realIndex = realIndex - LINEINTERVAL;
			} // end if
			_loc1 = gaTextField[realIndex];
			_loc1._y = _loc1._y + intervalY;
			if (MAX_BOTTOM_Y - TEXTFIELDHEIGHT / 2 < _loc1._y)
			{
				if (brwObject.currentPage > 0)
				{
					brwObject.currentPage = brwObject.currentPage - 1;
					if (--brwObject.startField < 0)
					{
						brwObject.startField = LINEINTERVAL - 1;
					} // end if
					_loc1._y = _loc1._y - MAX_BOTTOM_Y;
					brwObject.GetListIdx(realIndex, brwObject.currentPage);
					Common_DrawScrollBar();
				} // end if
			} // end if
		} // end of for
	} // end else if
};

brwObject.GetListIdx = function (listIndex, fileIndex)
{
	if (fileIndex < brwObject.totalIndex || brwObject.totalIndex == 0 && fileIndex == 0)
	{
		ext_fscommand2("EtcBrwGetListString", fileIndex, "gTmpString");
		gaTextField[listIndex].text = gTmpString;
	}
	else
	{
		gaTextField[listIndex].text = "";
	} // end else if
};

brwObject.TouchReleaseHandler = function (currentMC)
{
	var intervalY;
	if (gInputEnable == false)
	{
		return;
	} // end if
	if (blockRelease == 0)
	{
		intervalY = currentMC._ymouse - mouseYPosition;
		if (Math.abs(intervalY) < 20 && brwObject.currentIndex != -1)
		{
			var _loc3 = int(currentMC._ymouse / TEXTFIELDHEIGHT);
			if (_loc3 < LINEINTERVAL && _loc3 < brwObject.totalIndex)
			{
				brwObject.currentIndex = _loc3;
				Common_FadeOutSelectBar(-1);
				fn_Music_Set_NextStep(brwObject.currentPage + brwObject.currentIndex);
				Key_UpdateDisp();
			} // end if
		} // end if
		_global.ResumeTextScrolling();
		Common_FadeOutScrollBar();
	}
	else
	{
		var idx;
		Common_DrawSelectBar(-1);
		intervalY = BASE_Y - gaTextField[brwObject.startField]._y;
		mcBtnBack.onEnterFrame = function (Void)
		{
			intervalY = intervalY / 2;
			tmpInterval = tmpInterval / 2;
			for (idx = 0; idx < LINEINTERVAL; idx++)
			{
				gaTextField[idx]._y = gaTextField[idx]._y + intervalY;
			} // end of for
			if (Math.abs(intervalY) < 1)
			{
				var _loc2 = -BASE_Y + gaTextField[brwObject.startField]._y;
				for (idx = 0; idx < LINEINTERVAL; idx++)
				{
					gaTextField[idx]._y = gaTextField[idx]._y - _loc2;
				} // end of for
				delete mcBtnBack.onEnterFrame;
				_global.ResumeTextScrolling();
				Common_FadeOutScrollBar();
				blockRelease = 0;
			} // end if
		};

	} // end else if
	delete currentMC.onMouseMove;
};

brwObject.RegistEvent = function ()
{
	var dragFlag;
	var throwFlag;
	var counter;
	var direction;
	mcListTouch.onPress = function ()
	{
		if (gInputEnable == false)
		{
			return;
		} // end if
		startY = mouseYPosition = this._ymouse;
		startX = mouseXPosition = this._xmouse;
		if (this.onEnterFrame == undefined)
		{
			var _loc4 = int(this._ymouse / TEXTFIELDHEIGHT);
			_global.ResumeTextScrolling();
			if (_loc4 < LINEINTERVAL && _loc4 < brwObject.totalIndex)
			{
				brwObject.currentIndex = _loc4;
				Common_DrawSelectBar(-1);
				Common_DrawSelectBar(brwObject.currentIndex);
			} // end if
			dragFlag = false;
			throwFlag = false;
			startTime = getTimer();
		} // end if
		Common_EnableScrollBar();
		delete this.onEnterFrame;
		this.onMouseMove = function ()
		{
			var _loc3 = this._ymouse - mouseYPosition;
			var _loc4 = this._xmouse - mouseXPosition;
			if (dragFlag == true)
			{
				if (_loc3 / direction < 0)
				{
					direction = direction * -1;
					startTime = getTimer();
					startY = mouseYPosition = this._ymouse;
					startX = mouseXPosition = this._xmouse;
				} // end if
				if (Math.abs(_loc3) < 30)
				{
					++counter;
					if (counter > 2)
					{
						throwFlag = false;
					} // end if
				}
				else if (counter != 0)
				{
					throwFlag = true;
					counter = 0;
					startTime = getTimer();
					startY = mouseYPosition = this._ymouse;
					startX = mouseXPosition = this._xmouse;
				} // end else if
				Common_MouseMovementHandler(this);
			}
			else if (Math.abs(_loc3) > 10 && Math.abs(_loc3) > Math.abs(_loc4))
			{
				_global.PauseTextScrolling();
				dragFlag = true;
				startY = mouseYPosition = this._ymouse;
				startX = mouseXPosition = this._xmouse;
				Common_DrawSelectBar(-1);
				throwFlag = true;
				counter = 0;
				if (_loc3 < 0)
				{
					direction = -1;
				}
				else
				{
					direction = 1;
				} // end else if
			} // end else if
		};

	};

	mcListTouch.onDragOut = mcListTouch.onRelease = function ()
	{
		if (gInputEnable == false)
		{
			return;
		} // end if
		endTime = getTimer() - startTime;
		endX = this._xmouse - startX;
		endY = this._ymouse - startY;
		accY = int(endY / endTime * 8);
		accX = int(endX / endTime * 8);
		if (Math.abs(endY) > 230)
		{
			accY = accY * 180;
		}
		else
		{
			accY = accY * 140;
		} // end else if
		delete this.onMouseMove;
		if (dragFlag == true && throwFlag == true && brwObject.totalIndex > LINEINTERVAL)
		{
			Common_DrawSelectBar(-1);
			blockRelease = 1;
			this.onEnterFrame = function (Void)
			{
				brwObject.MoveTextField(accY * 0.200000);
				accY = accY * 0.900000;
				if (Math.abs(accY) < 5 || gStop > 1)
				{
					delete this.onEnterFrame;
					gStop = 0;
					brwObject.TouchReleaseHandler(this);
				} // end if
			};

			brwObject.currentIndex = -1;
		}
		else
		{
			var _loc3 = Math.abs(endX);
			if (_loc3 >> 1 > Math.abs(endY) && _loc3 > 60)
			{
				_global.ResumeTextScrolling();
				Common_FadeOutScrollBar();
				Common_DrawSelectBar(-1);
				blockRelease = 0;
			}
			else
			{
				if (dragFlag == true)
				{
					if (brwObject.totalIndex >= LINEINTERVAL)
					{
						Common_MouseMovementHandler(this);
					} // end if
					brwObject.currentIndex = -1;
				} // end if
				brwObject.TouchReleaseHandler(this);
			} // end else if
		} // end else if
	};

	mcListScrollTouch.onPress = function ()
	{
		if (gInputEnable == false)
		{
			return;
		} // end if
		delete mcListTitle.onEnterFrame;
		brwObject.TouchReleaseHandler(this);
		Common_EnableScrollBar();
		Common_DrawScrollBar();
		this.onMouseMove = function (Void)
		{
			var _loc2 = this._ymouse;
			if (_loc2 > SCROLLHEIGHT - 5)
			{
				_loc2 = SCROLLHEIGHT;
			}
			else if (_loc2 < 5)
			{
				_loc2 = 0;
			} // end else if
			if (Popup_IsVisible() == false && _loc2 >= 0 && _loc2 <= SCROLLHEIGHT)
			{
				if (brwObject.totalIndex > LINEINTERVAL)
				{
					brwObject.currentPage = int((brwObject.totalIndex - (LINEINTERVAL - 1)) * _loc2 / SCROLLHEIGHT);
					brwObject.currentIndex = -1;
					if (brwObject.currentPage + LINEINTERVAL >= brwObject.totalIndex)
					{
						brwObject.currentPage = brwObject.totalIndex - LINEINTERVAL;
					} // end if
					Common_GetList();
					Common_DrawScrollBar();
				} // end if
			} // end if
		};

	};

	mcListScrollTouch.onReleaseOutside = mcListScrollTouch.onRelease = function ()
	{
		if (gInputEnable == false)
		{
			return;
		} // end if
		delete this.onMouseMove;
		Common_FadeOutScrollBar();
	};

};

brwObject.RemoveEvent = function ()
{
	delete mcListTouch.onPress;
	delete mcListScrollTouch.onPress;
	delete mcListTouch.onRelease;
	delete mcListScrollTouch.onRelease;
	delete mcListTouch.onDragOut;
	delete mcListScrollTouch.onReleaseOutside;
};

onUnload = function ()
{
	delete mcDetailAlbum.onEnterFrame;
	delete brwObject;
	matrixLoader.removeListener(matrixListener);
	albumLoader.removeListener(albumListener);
	delete matrixArray;
	delete dirtyArray;
};

mcMatrixAlbum.onPress = function ()
{
	if (gInputEnable == false)
	{
		return;
	} // end if
	gStartX = this._xmouse;
	gMouseStart = _root._xmouse;
	delete this.onEnterFrame;
	gDrag = false;
	this.onMouseMove = function ()
	{
		if (Math.abs(gStartX - this._xmouse) > 15 && gDrag == false && matrixTotalIdx > NUM_VIEW_MATRIX)
		{
			gDrag = true;
			gStartTick = getTimer();
		} // end if
		if (gDrag == true)
		{
			if (Math.abs(this._xmouse - gStartX) > 1)
			{
				if (LIMIT_MOVE < Math.abs(this._xmouse - gStartX))
				{
					if (this._xmouse > gStartX)
					{
						MoveMatrix(LIMIT_MOVE, true);
						gStartX = gStartX + LIMIT_MOVE;
					}
					else
					{
						MoveMatrix(-LIMIT_MOVE, true);
						gStartX = gStartX - LIMIT_MOVE;
					} // end else if
				}
				else
				{
					MoveMatrix(this._xmouse - gStartX, true);
					gStartX = this._xmouse;
				} // end if
			} // end if
		} // end else if
	};

};

mcMatrixAlbum.onDragOut = mcMatrixAlbum.onRelease = function ()
{
	delete this.onMouseMove;
	if (gDrag == false)
	{
		if (gMatrixMove == true)
		{
			SetMatrix();
			return;
		} // end if
		var _loc5;
		var _loc4;
		var _loc3;
		var _loc6;
		_loc4 = int((_root._ymouse - 40) / gMatrixHeight);
		_loc5 = int(_root._xmouse / gMatrixWidth);
		trCurIdx = _loc5 * gLow + _loc4;
		if (matrixTotalIdx > NUM_VIEW_MATRIX)
		{
			trCurIdx = trCurIdx + (matrixArray[gLeftIdx].idx + (gColume - gViewColume) / 2 * gLow);
		}
		else if (trCurIdx > matrixTotalIdx)
		{
			return;
		} // end else if
		trCurIdx = trCurIdx % matrixTotalIdx;
		ext_fscommand2("EtcBrwGetListString", trCurIdx, "gTmpString");
		mcListABTitle.text = gTmpString;
		ext_fscommand2("SetAudAlbumBMCSize", gAlbumWidth);
		_loc3 = String(trCurIdx) + ".ab0";
		albumLoader.loadClip(_loc3, mcDetailAlbum.MCMtxAlbum.MCLoader);
	}
	else
	{
		gDrag = false;
		if (tick > 500)
		{
			SetMatrix();
			return;
		} // end if
		var tick = getTimer() - gStartTick;
		var len;
		var dist;
		gMatrixMove = true;
		len = _root._xmouse - gMouseStart;
		MoveMatrix(0, true);
		tick = 400 / tick;
		dist = len * int(tick);
		if (dist > 580)
		{
			dist = 580;
		}
		else if (dist < -580)
		{
			dist = -580;
		} // end else if
		this.onEnterFrame = function ()
		{
			if (dist > 0)
			{
				len = int(dist / 2);
				if (len > 200)
				{
					len = 200;
					dist = dist - 200;
				}
				else
				{
					dist = int(dist / 2);
				} // end else if
			}
			else if (dist < 0)
			{
				len = int(dist / 2);
				if (len < -200)
				{
					len = -200;
					dist = dist + 200;
				}
				else
				{
					dist = int(dist / 2);
				} // end else if
			}
			else
			{
				delete this.onEnterFrame;
				SetMatrix();
				return;
			} // end else if
			MoveMatrix(len, true);
		};

	} // end else if
};

mcPlayIcon.onPress = function ()
{
	this.gotoAndStop(this._currentframe + 1);
};

mcPlayIcon.onDragOut = function ()
{
	this.gotoAndStop(this._currentframe - 1);
};

mcPlayIcon.onRelease = function ()
{
	if (ext_fscommand2("GetEtcState") == 1)
	{
		ext_fscommand2("KeyAudPause");
	}
	else
	{
		ext_fscommand2("KeyAudPlay");
	} // end else if
	Show_PlayStatus();
};

mcBtnListBack.onPress = mcBtnBack.onPress = function ()
{
	if (_global.GetPopupMCName() != null || gInputEnable == false)
	{
		return;
	} // end if
	this.gotoAndStop(2);
};

mcBtnListBack.onDragOut = mcBtnBack.onDragOut = function ()
{
	if (_global.GetPopupMCName() != null || gInputEnable == false)
	{
		return;
	} // end if
	this.gotoAndStop(1);
};

mcBtnBack.onClick = function ()
{
	mcCon.gotoAndStop(1);
};

mcBtnListBack.onRelease = function ()
{
	if (_global.GetPopupMCName() != null || gInputEnable == false)
	{
		return;
	} // end if
	this.gotoAndStop(1);
	fn_Music_Hide_SelectedAlbum();
};

Init();