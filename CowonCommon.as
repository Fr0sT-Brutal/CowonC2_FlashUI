// *** Common stuff for Cowon UI ***

// for desktop launch only - if _global object isn't assigned, add some necessary stubs and functions

if (_global == undefined)
{
	_global.__desktopMode = true;

	_global.LCD_WIDTH = 320;
	_global.LCD_HEIGHT = 240;

	_global.GetPopupMCName = function () { return null; }

	// make sure these methods assigned!
	_global.DisplayVolume = function () {};

	_global.DisplayTime = function () {};
	
	_global.gfn_systemInfo = _global.UpdateSystemInfo = function (forceUpdate)
	{
		_global.DisplayTime(forceUpdate);
		_global.DisplayVolume(forceUpdate);
		_global.DisplayBattery(forceUpdate);
		_global.DisplayHold(forceUpdate);
		_global.DisplayAudioOut(forceUpdate);
	};
}

// "Patch" the standard functions with new ones. They will call old methods for old infobars and
// perform our custom actions for the new ones

// ! check if someone has already done the patch
if (_global.DisplayVolume_old == undefined)
	_global.DisplayVolume_old = _global.DisplayVolume;
if (_global.DisplayTime_old == undefined)
	_global.DisplayTime_old = _global.DisplayTime;

_global.gfn_DispVolume = _global.DisplayVolume = function (forceUpdate)
{
	if (mcInfobar == undefined) return; // no infobar - do nothing
	if (mcInfobar.MCVol.TXVol != undefined) // old or new infobar?
	{
		currentVolume = ext_fscommand2("GetEtcVolume");
		if (forceUpdate == 1 || prevVolume != currentVolume)
		{
			prevVolume = currentVolume;
			mcInfobar.setVol(currentVolume);
		} // end if
	}
	else
		_global.DisplayVolume_old(forceUpdate); // call the old method
};

_global.gfn_DispTime = _global.DisplayTime = function (forceUpdate)
{
	if (mcInfobar == undefined) return; // no infobar - do nothing
	if (mcInfobar.TXTime != undefined) // old or new infobar?
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
		
		mcInfobar.setTime(_global.g_curHour, _global.g_curMin, ext_fscommand2("GetTim24HDisplay") == 0);
	}
	else
		_global.DisplayTime_old(forceUpdate); // call the old method
};

var debugObj = null;

function initDebug(txDbg)
{
	if (debugObj == null)
	{
		debugObj = new Object();
		debugObj.checkDebug = function ()
		{
			this.txDebug._visible = false;
			clearInterval(this.intervID);
			this.intervID = 0;
		}
	}
	debugObj.txDebug = txDbg;
	debugObj.txDebug._visible = false;
}

function debug(msg)
{
	debugObj.txDebug.text = String(msg);
	debugObj.txDebug._visible = true;
	if (debugObj.intervID != 0)
		clearInterval(debugObj.intervID);
	debugObj.intervID = setInterval(debugObj, "checkDebug", 4000);
}