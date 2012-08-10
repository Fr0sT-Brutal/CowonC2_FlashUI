// Scripts for Music Flash UI
// Developed by Cowon
// Modified by Fr0sT

/*

TO DO

* _global.GetPopupMCName() != null || gInputEnable == false вынести в функцию
* прогресс бар уезжает в конце трека
* иконка инструментов
* метки АВ - возм, выделение более заметное, установка - подумать
* удалить ненужное, связанное с popup
* gInputEnable - во время слайда. показывать прозрачный блокировщик во весь экран?
* индексы при проигрывании по тегам?
* альбом на главный экран
* удаление при проигрывании по тегам

? muteState
? чтение/запись конфигов
? долгое нажатие на клавишу
* условная компиляция

globalToLocal (MovieClip.globalToLocal method) 
public globalToLocal(pt:Object) : Void
Converts the pt object from Stage (global) coordinates to the movie clip's (local) coordinates.

*/

/*

v 0.1.
* Убрано кручение обложки (при смене трека - осталось)
* Увеличена верхняя планка (где громкость, батарея и т.д.)
* Надпись исполнителя побольше
* Прошло/осталось пишется текстом (намного четче и крупнее; не пишет часы, если 0)
* Зеленый градиентный скроллбар 
* Прогресс-бар с панели контролов убран

v 0.2.
* Убран зеленый прогресс-бар
* Прогресс-бар с красного экрана вынесен на главную, вместе с контролами проигрывания. Реагирует на нажатия. Контролы доступны сразу, без лишних нажатий. Со вспомогательных экранов убраны метки времени (осталась только надпись Артист / Трек)
* Добавлена кнопка "Инструменты", вызывающая инструменты и настройки 
* Красный экран задвинут после синего, в перспективе вообще будет удален

v 0.3.
* отработка инфобара, вроде кое-как заставил его подхватываться.
* прогресс бар можно двигать при паузе
* метка времени отображает минус, если режим "осталось", при нажатии на спец кнопку режим меняется
* прогресс бар на синем экране исправлен
* скругленный инфобар

v.0.4
* инфобар, новые картинки
* служебный код выделен в Library.as
* autoresume - при запуске приложения начинается проигрывание
* показ "№ трека / всего" на синем экране
* дебуг надпись

v.0.5
* замена отрисовки инфобара - совместимость с другими приложениями
* номер трека начинается с 1
* перемещена надпись общего времени трека, надпись текущего времени сделана активной, нажатие меняет режим отображения и сохраняет его в настройки
* прогресс бар сделан поуже и пониже
* глюки с переходом по клику и режимом "Осталось времени"
* autoresume только из состояния "Стоп"

v.0.6
* индикатор блокировки на инфобаре заменён
* исправлено отображение иконки аудиовыхода (не работало)
* исправлено отображение am/pm (не работало)

v.0.7
* удаление текущего трека (с переходом на следующий)
* исправлено: loopA,B - позиции захардкодены. Изображения "рисок" увеличены и сделаны принадлежностью прогресс-бара
* иконка на Инструменты
* окончательно удалён "красный экран", отлажены кнопки перелистывания
* кнопка "Назад" на экране инструментов

v.0.8
* запрос на удаление
* новый компонент TPopup
* слегка раздвинуты контролы на инфобаре
* таймер синего экрана не считается, пока висит попап

v.0.9
* новый класс TButton, почти все контролы переделаны под него (существенно сократило код)
* попап DRM не показывается при отладке на десктопе

v.0.10
* новый класс TPageLister для перелистывания страниц. Намного сокращён код
* исправлено неотображение меток АВ
* pagelister для stage перенесен на stage
* область метки текущего времени расширена
* области контролов уменьшены сверху
* кнопка-матрица работает снова!
* если исполнитель или название трека пустое, отображаются надписи unknown artist/track

v.0.11
* кнопка Play/pause также переделана под TButton
* метка текущего времени снова реагирует на нажатия
* Library разделена на собственно библиотеку функций и чисто ковоновские утилы (CowonCommon.as). Library реализована как статический класс
* инфобар меняет размер в зависимости от режима отображения времени

v.0.12
* экраны настроек и эквалайзера вынесены в отдельный мувиклип
* информация о текущем треке
* с синего экрана удалена инфа о треке и прогресс бар
* переработаны принципы обновления надписей, убраны ненужные обновления
* инфо о треке хранится в отдельном объекте и обновляется из отдельной функции
* функции Key_* перенесены в fn_KeyHandler
* отметка выбранной настройки эквалайзера "бегает" на одном мувиклипе с элементами (не нужно вычислять позицию)
* присвоение событий pagelister-ам после присвоения текущей страницы - чтобы избежать ненужной реакции на смену
* исправлен глюк с pagelister на фреймах, отличных от первого (отсроченным init)

V.0.13
* на экран информации о текущем треке добавлены поясняющие глифы
* глюк с непоказом номера трека для первых треков в папке

*/

// uses components & classes: TButton, TPopup, TPageLister, TInfobar, Library

import Library;

#include "CowonCommon.as"

var MODE_REPEAT_NO = 0;
var MODE_REPEAT_OK = 1;
var MODE_SHUFFLE_NO = 0;
var MODE_SHUFFLE_OK = 1;
var MODE_BOUNDARY_ALL = 0;
var MODE_BOUNDARY_ONE = 1;
var MODE_BOUNDARY_FOLDER = 2;
var MODE_PITCH_OFF = 0;
var MODE_PITCH_ON = 1;
var LDB_NOTHING = 0;
var LDB_1 = 1;
var LDB_2 = 2;
var AB_MODE_OFF = 0;
var AB_MODE_A = 1;
var AB_MODE_AB = 2;
var STATE_PLAY = 1;
var STATE_PAUSE = 2;
var STATE_STOP = 3;
var KEY_REPEAT_TIME = 250;
var IMG_DIR_NEXT = 0;
var IMG_DIR_PREV = 1;
var IMG_DIR_NOTHING = 2;
var POPUP_TIME = 700;
var VIEW_TITLE = 0;
var VIEW_POPUP_EQ = 1;
var VIEW_POPUP_SETTING = 2;
var VIEW_STAGE_LYRIC = 4;
var VIEW_STAGE_TOOLS = 6;
var VIEW_POPUP_TRACKINFO = 7;
var PLAY_MODE_NORMAL = 0;
var PLAY_MODE_FAVORITES = 1;
var INFO_LEVEL_TIME  = 1 << 0;
var INFO_LEVEL_PROPS = 1 << 1;
var INFO_LEVEL_ADV   = 1 << 2;

var arrayJeteffect = new Array("User 1", "User 2", "User 3", "User 4", "Normal", "BBE", "BBE ViVA", "BBE ViVA 2", "BBE Mach3Bass", "BBE MP", "BBE Headphone", "BBE Headphone 2", "BBE Headphone 3", "Rock", "Jazz", "Classic", "Ballad", "Pop", "Club", "Funk", "Hip Hop", "Techno", "Blues", "Metal", "Dance", "Rap", "Wide", "X-Bass", "Hall", "Vocal", "Maestro", "Feel the Wind", "Mild Shore", "Crystal Clear", "Reverb Room", "Reverb Club", "Reverb Stage", "Reverb Hall", "Reverb Stadium");
var brwModes = new Array("Default", "Favorite");
var albumLoader = new MovieClipLoader();
var gTmpNumber = -1;
var gTmpString = "";
var gInputEnable = true;
var gAlbumUpdate = false;
var gMouseTime = -1;
var gABMode = AB_MODE_OFF;
var gEQIdx = -1;
var gTimeRemain = false;
var gPrevSeek = -1;
var gPrevSeekTime = -1;
var gStageTimer = 0;
var gRotateTime = -1;
var gMultiAlbumTime = -1;
var gMultiAlbumIdx = -1;
var gAlbumCount = -1;
var gChangeNow = false;
var ldbconfigOn1 = "1|60|90|200|60|3|16|16777215|0";
var ldbconfigOn2 = "1|20|90|280|60|3|16|16777215|0";
var ldbconfigOff = "0|60|90|200|60|3|16|16777215|0";
var gPlayState = ext_fscommand2("GetEtcState");
var coverLoader = new MovieClipLoader();
var imgListener = new Object();
var popup: TPopup = new TPopup();
var gImgDir = IMG_DIR_NEXT;
var gImgRotate = false;
var view_statusUI = VIEW_TITLE;
var page_Setting = 1;
var lyricSetting = ext_fscommand2("GetDisLyrics");
var gCurrTrackInfo; // object containing all the info about current track

var mcCon = _root.MCCon;
var mcInfobar = mcCon.MCInfobar;
var mcTitle = mcCon.MCTitle;
var mcControls = mcCon.MCControls;
var mcStage = mcCon.MCStage;
var mcLyric = mcStage.MCUi.MCLyrics;
var mcTools = mcStage.MCUi.MCTools;
var mcPopupScreen = mcCon.MCPopupScreen;
var mcStageProgressBar = mcStage.MCBar;
var mcTitleProgress = mcTitle.MCProgressBar;
var mcTitleProgressSeeker = mcTitleProgress.MCSlider;
var mcNeedle = mcCon.MCNeedle;
var mcBtnMatrix = mcCon.MCMatrix;
var mcTouchArea = mcCon.MCMusic.MCTouch;
var mcLoopA = mcTitleProgress.MCLoopA;
var mcLoopB = mcTitleProgress.MCLoopB;
var mcCover = mcCon.MCMusic.MCCover;
var mcDefaultCover;
var mcCover1 = mcCover.MCLoader1;
var mcCover2 = mcCover.MCLoader2;
var mcCurCover = mcCover1;
var mcNextCover = mcCover2;

// *** Main code ***

function InvisiblePopup()
{
}

function Popup_Result(s, t)
{
	popup.showResult(Boolean(s));
/**/
/*
	if (t == undefined)
		t = 700;
	_global.DisplayPopupMC(mcResultPopup, t);
*/
}

function Popup_ShowDRM(str)
{
	if (_global.__desktopMode) return;
	popup.showResult(false, str);
/**/
//	_global.DisplayPopupMC(mcDRMPopup, 2000);
}

function Init()
{
	InvisiblePopup();
	_global.RegisterKeyListener(fn_KeyHandler);
	LoadConfig();
}

function LoadConfig()
{
}

function SaveConfig()
{
}

function fn_KeyHandler(keyType)
{
	if (statusInputEnable /**/== false && keyType != _global.KEY_DISPLAY_UPDATE)
		return;

	switch (keyType)
	{
		case _global.KEY_PLAY_LONG:
		case _global.KEY_PLAY_SHORT:
			_global.Load_SWF(_global.MODE_MAIN);
			break;

		case _global.KEY_PLUS_LONG:
/**/// 			break;
		case _global.KEY_PLUS_SHORT:
			ext_fscommand2("KeyComPlus");
			_global.gfn_dispVolume(1);
			break;

		case _global.KEY_MINUS_SHORT:
		case _global.KEY_MINUS_LONG:
			ext_fscommand2("KeyComMinus");
			_global.gfn_dispVolume(1);
			break;

		case _global.KEY_REW_SHORT:
			if (gAlbumUpdate)
				break;
			gImgDir = IMG_DIR_PREV;
			ext_fscommand2("KeyAudShortREW");
			Update_Display();
			break;

		case _global.KEY_REW_LONG:
			if (gAlbumUpdate)
				break;
			ext_fscommand2("KeyAudLongREW");
			Update_Progress();
			break;

		case _global.KEY_FF_SHORT:
			if (gAlbumUpdate)
				break;
			gImgDir = IMG_DIR_NEXT;
			ext_fscommand2("KeyAudShortFF");
			Update_Display();
			break;

		case _global.KEY_FF_LONG:
			if (gAlbumUpdate)
				break;
			ext_fscommand2("KeyAudLongFF");
			Update_Progress();
			break;

		case _global.KEY_RELEASE_LONG: /**/
			break;

		case _global.KEY_DISPLAY_UPDATE:
			Update_Display();
			break;

		case _global.KEY_HOLD:
			_global.gfn_DispHold(1);
	/**/		if (ext_fscommand2("GetSysHoldKey"))
			{
				
			} // end if
			break;

		default:
			break;
	} // End of switch
}

function Key_Play()
{
	ext_fscommand2(gPlayState == STATE_PLAY ? "KeyAudPause" : "KeyAudPlay");
	Update_Display();
}

function Init_fr1()
{
	InvisiblePopup();
	gTimeRemain = (ext_fscommand2("GetDisPlayTime") == 1);
	ext_fscommand2("SetAudAlbumArtMCSize", "350");
	view_statusUI = VIEW_TITLE;
	Update_Display();
	Draw_UI();
	var cnt = 0;
/**///?
	mcBtnMatrix.onEnterFrame = function ()
	{
		if (cnt > 10)
		{
			delete this.onEnterFrame;
			Always_Update();
		} // end if
		++cnt;
	};
	// Auto-resume feature. If current state is Stop and audio resume option is set,
	// start playback automatically
	var val = ext_fscommand2("GetAudResume");
	if (val == 1)
	{
		if (gPlayState == STATE_STOP)
			Key_Play();
	}
}

function Slide_Page(tgtX, mc: MovieClip)
{
	if (tgtX != mc._x)
	{
		gInputEnable = false;
		mc.onEnterFrame = function ()
		{
			this._x = this._x + (tgtX - this._x) * 0.700000;
			if (Math.abs(tgtX - this._x) < 5)
			{
				this._x = tgtX;
				gInputEnable = true;
				delete this.onEnterFrame;
			} // end if
		};
	} // end if
}

// infoLevel - sum of
//   0 - curr time only
//   1 - tag info
//   2 - file info
function Get_TrackInfo(infoLevel)
{
	if (gCurrTrackInfo == undefined)
	{	
		gCurrTrackInfo = new Object();
		gCurrTrackInfo.CurrTime = 0;
		gCurrTrackInfo.Idx = -1;
		gCurrTrackInfo.TotalIdx = -1;
		gCurrTrackInfo.AlbumartIdx = -1;
		gCurrTrackInfo.TotalTime = 0;
		gCurrTrackInfo.Artist = "";
		gCurrTrackInfo.Title = "";
		gCurrTrackInfo.Album = "";
		gCurrTrackInfo.FileName = "";
		gCurrTrackInfo.BitRate = -1;
		gCurrTrackInfo.SampleRate = -1;
		gCurrTrackInfo.Codec = "";
		gCurrTrackInfo.PlayMode = -1;
		gCurrTrackInfo.FolderTotal = -1;
		gCurrTrackInfo.FolderIdx = -1;
		gCurrTrackInfo.FileFolder = "";
	}
	
	if ( (infoLevel & INFO_LEVEL_TIME) != 0)
	{
		gCurrTrackInfo.currTime = ext_fscommand2("GetAudPlayTime");
	}
	
	if ( (infoLevel & INFO_LEVEL_PROPS) != 0)
	{
		gCurrTrackInfo.Idx = ext_fscommand2("GetEtcCurPLIndex");
		gCurrTrackInfo.TotalIdx = ext_fscommand2("GetEtcTotalPLNum");
		gCurrTrackInfo.TotalTime = ext_fscommand2("GetAudTotalTime");

		if (ext_fscommand2("GetEtcFileName", gCurrTrackInfo.Idx, "gTmpString") != -1)
			gCurrTrackInfo.FileName = gTmpString;
		else
			gCurrTrackInfo.FileName = "";

		if (ext_fscommand2("GetAudTitle", gCurrTrackInfo.Idx, "gTmpString") != -1)
			gCurrTrackInfo.Title = gTmpString;
		else
			gCurrTrackInfo.Title = "";
			
		if (ext_fscommand2("GetAudArtist", gCurrTrackInfo.Idx, "gTmpString") != -1)
			gCurrTrackInfo.Artist = gTmpString;
		else
			gCurrTrackInfo.Artist = "";
			
		if (ext_fscommand2("GetAudAlbum", gCurrTrackInfo.Idx, "gTmpString") != -1)
			gCurrTrackInfo.Album = gTmpString;
		else
			gCurrTrackInfo.Album = "";
	}

	if ( (infoLevel & INFO_LEVEL_ADV) != 0)
	{
		// get advanced audio info
		if (ext_fscommand2("GetAudCodec", "gTmpString") != -1)
			gCurrTrackInfo.Codec = gTmpString;
		else
			gCurrTrackInfo.Codec = "";

		gCurrTrackInfo.BitRate = ext_fscommand2("GetAudBitRate");
		gCurrTrackInfo.SampleRate = ext_fscommand2("GetAudSampleRate");			

		// get file properties
		// get current play mode
		gCurrTrackInfo.PlayMode = ext_fscommand2("GetEtcFavorite");
		// init browser and get index of the current track, its filename and folder name
		gCurrTrackInfo.FolderTotal =
			ext_fscommand2("EtcBrwSetInitialization", brwModes[gCurrTrackInfo.PlayMode]);
		gCurrTrackInfo.FolderIdx =
			ext_fscommand2("EtcBrwGetCurIndex");
		if (gCurrTrackInfo.PlayMode == PLAY_MODE_NORMAL)
			if (ext_fscommand2("EtcBrwGetTitleString", "gTmpString") != -1)
				gCurrTrackInfo.FileFolder = gTmpString;
			else
				gCurrTrackInfo.FileFolder = "";
	}
}

function Draw_UI()
{
	Draw_PopupScreen();
	Draw_Stage();
}

function Draw_PopupScreen()
{
	switch (view_statusUI)
	{
		case VIEW_POPUP_SETTING:
			mcPopupScreen.gotoAndStop("settings");
			// ! if init directly after frame change, components do not get custom classes.
			// So we use delayed init here
			mcPopupScreen.onEnterFrame = 
				function()
				{
					Init_Popup_Settings(); // launches Update_Settings too
					delete this.onEnterFrame;
				}
			mcPopupScreen._visible = true;
			break;
		case VIEW_POPUP_EQ:
			mcPopupScreen.gotoAndStop("je");
			// ! if init directly after frame change, components do not get custom classes.
			// So we use delayed init here
			mcPopupScreen.onEnterFrame = 
				function()
				{
					Init_Popup_JE(); // launches Update_EQ too
					delete this.onEnterFrame;
				}
			mcPopupScreen._visible = true;
			break;
		case VIEW_POPUP_TRACKINFO:
			mcPopupScreen.gotoAndStop("trackinfo");
			Init_Popup_TrackInfo();
			Update_TrackInfo();
			mcPopupScreen._visible = true;
			break;
		default:
			mcPopupScreen._visible = false;	/**/
			mcPopupScreen.gotoAndStop("empty");
			break;
	}
}

function Update_TrackInfo()
{
	Get_TrackInfo(INFO_LEVEL_PROPS + INFO_LEVEL_ADV);

	// draw the received values
	var mcInf = mcPopupScreen.MCTrackInfo;

	mcInf.TXLen.text = (gCurrTrackInfo.TotalTime > 0 ? Library.FormatTime(true, gCurrTrackInfo.TotalTime) : "");
	mcInf.TXTrack.text = (gCurrTrackInfo.FolderIdx >= 0 && gCurrTrackInfo.FolderTotal > 0 ? (gCurrTrackInfo.FolderIdx + 1) + " / " + gCurrTrackInfo.FolderTotal : "");
	mcInf.TXArtist.text = gCurrTrackInfo.Artist;
	mcInf.TXAlbum.text = gCurrTrackInfo.Album;
	mcInf.TXTitle.text = gCurrTrackInfo.Title;
	mcInf.TXBitrate.text = (gCurrTrackInfo.BitRate != 0 ? (gCurrTrackInfo.BitRate + " kbps") : "");
	mcInf.TXSampleRate.text = (gCurrTrackInfo.SampleRate != 0 ? (gCurrTrackInfo.SampleRate + " kHz") : "");
	mcInf.TXCodec.text = gCurrTrackInfo.Codec;
	mcInf.TXFilename.text = gCurrTrackInfo.FileName;
	mcInf.TXFolder.text = (gCurrTrackInfo.PlayMode == PLAY_MODE_FAVORITES ? brwModes[playMode] : gCurrTrackInfo.FileFolder);

	_global.CommonSetStringScroll(mcInf.TXArtist, _global.TEXT_ALIGN_UNDEFIEND);
	_global.CommonSetStringScroll(mcInf.TXArtist, _global.TEXT_ALIGN_UNDEFIEND);
	_global.CommonSetStringScroll(mcInf.TXTitle, _global.TEXT_ALIGN_UNDEFIEND);
	_global.CommonSetStringScroll(mcInf.TXFilename, _global.TEXT_ALIGN_UNDEFIEND);
	_global.CommonSetStringScroll(mcInf.TXFolder, _global.TEXT_ALIGN_UNDEFIEND);
}

function Draw_Stage()
{
	gStageTimer = 0;
	switch (view_statusUI)
	{
		case VIEW_TITLE:
		{
			mcTitle._visible = mcControls._visible = mcBtnMatrix._visible = true;
			mcStage._visible = false;
			Update_Title();
			Update_Control();
			Update_Progress();
			Update_ProgressABMode();
			tgtOffset = 0;
			break;
		}
		case VIEW_STAGE_LYRIC:
		{
			mcTitle._visible = mcControls._visible = mcBtnMatrix._visible = false;
			mcStage._visible = true;
			tgtOffset = _global.LCD_WIDTH;
			break;
		}
		case VIEW_STAGE_TOOLS:
		{
			mcTitle._visible = mcControls._visible = mcBtnMatrix._visible = false;
			mcStage._visible = true;
			gStageTimer = getTimer();
			tgtOffset = 0;
			break;
		}
		default:
		{
			mcStage._visible = mcInfobar._visible = false;
			mcTitle._visible = mcControls._visible = mcBtnMatrix._visible = false;
			return; // !
		}
	}

	// we get here only if the stage or title is active

	mcInfobar._visible = true;
	Update_Albumart();
	Update_LDB();
	if (tgtOffset != undefined)
		Slide_Page(tgtOffset, mcStage.MCUi);
}

function Always_Update()
{
	delete mcInfobar.onEnterFrame;
	mcInfobar.onEnterFrame = function ()
	{
		if (gPlayState == STATE_PLAY && gImgRotate == false)
		{
			if (view_statusUI == VIEW_TITLE)
			{
				Update_Progress();
				Update_ProgressABMode();
			}
			Albumart_Rotate(); /**/
			Albumart_Multi();
		}
		Check_Stage();
	};
}

function Update_Progress()
{
	Get_TrackInfo(INFO_LEVEL_TIME);
	var currPercent;
	
	if (gCurrTrackInfo.TotalTime == 0)
		currPercent = 0;
	else
	{
		currPercent = gCurrTrackInfo.CurrTime / gCurrTrackInfo.TotalTime;
		if (gTimeRemain)
			currPercent = 1 - currPercent;
	}

	if (view_statusUI == VIEW_STAGE_TOOLS)
	{
		mcStageProgressBar._width = currPercent*_global.LCD_WIDTH;
	}
	else if (view_statusUI == VIEW_TITLE)
	{
		mcTitleProgressSeeker._x = currPercent*mcTitleProgress._width;
		var zeroHours = Math.floor(gCurrTrackInfo.TotalTime / 3600) == 0;
		mcTitle.MCCurrentTime.TXCurrTime.text =
			(gTimeRemain ? "–" : "") +
			Library.FormatTime(zeroHours, gCurrTrackInfo.CurrTime);
	}
}

function Update_ProgressABMode()
{
	gABMode = ext_fscommand2("GetAudABMode");
	switch (gABMode)
	{
		case AB_MODE_A:
		{
			mcLoopA._visible = true;
			mcLoopB._visible = false;
			mcLoopA._x = int(ext_fscommand2("GetAudABModeStartTime") / gCurrTrackInfo.TotalTime * mcTitleProgress._width);
			break;
		}
		case AB_MODE_AB:
		{
			mcLoopA._visible = true;
			mcLoopB._visible = true;
			mcLoopA._x = int(ext_fscommand2("GetAudABModeStartTime") / gCurrTrackInfo.TotalTime * mcTitleProgress._width);
			mcLoopB._x = int(ext_fscommand2("GetAudABModeEndTime") / gCurrTrackInfo.TotalTime * mcTitleProgress._width);
			break;
		}
		case AB_MODE_OFF:
		default:
		{
			mcLoopA._visible = false;
			mcLoopB._visible = false;
			break;
		}
	} // End of switch
}

// main update method, called also from key handler as reaction on key press (automatic track change 
// is considered as key press too)
function Update_Display()
{
	_global.UpdateSystemInfo(1);
	switch (view_statusUI)
	{
		case VIEW_TITLE:
			Update_Title();
			Update_Control();
			Update_Progress();
			Update_ProgressABMode();
			// no break here man!
		case VIEW_STAGE_LYRIC:
		case VIEW_STAGE_TOOLS:
			Update_LDB();
			Update_Albumart();
			break;
		case VIEW_POPUP_TRACKINFO:
			Update_TrackInfo();
			break;
	}
	Check_DRM();
}

function Update_Title()
{
	Get_TrackInfo(INFO_LEVEL_PROPS);
	
	mcTitle.TXTitle.text = (gCurrTrackInfo.Title != "" ? gCurrTrackInfo.Title : "No title");
	mcTitle.TXArtist.text = (gCurrTrackInfo.Artist != "" ? gCurrTrackInfo.Artist : "No artist");
	mcTitle.TXTotalTime.text = (gCurrTrackInfo.TotalTime > 0 ? Library.FormatTime(true, gCurrTrackInfo.TotalTime) : "");

	_global.CommonSetStringScroll(mcTitle.TXTitle, _global.TEXT_ALIGN_CENTER);
	_global.CommonSetStringScroll(mcTitle.TXArtist, _global.TEXT_ALIGN_CENTER);
}

function Update_LDB()
{
	var _loc2 = ext_fscommand2("GetAudLDBType");
	if (view_statusUI == VIEW_STAGE_LYRIC)
	{
		if (lyricSetting == 1)
		{
			if (view_statusUI == VIEW_STAGE_LYRIC && _global.gfn_GetPopupMCName() == null && _loc2 > 0)
			{
				mcLyric.MCNo._visible = false;
				if (_loc2 == 1)
					ext_fscommand2("SetAudLDBConfig", ldbconfigOn1);
				else
					ext_fscommand2("SetAudLDBConfig", ldbconfigOn2);
			}
			else
			{
				mcLyric.MCNo.gotoAndStop(1);
				mcLyric.MCNo._visible = true;
				ext_fscommand2("SetAudLDBConfig", ldbconfigOff);
/**/
				// if (view_statusUI == VIEW_STAGE_LYRIC)
				// {
				// 	view_statusUI = VIEW_STAGE_TOOLS;
				// 	Draw_UI();
				// } // end if
				// return the page lister to previous page
				mcStage.MCPageLister.currPage = 1;
				
			}
		}
		else
		{
			mcLyric.MCNo.gotoAndStop(2);
			mcLyric.MCNo._visible = true;
			ext_fscommand2("SetAudLDBConfig", ldbconfigOff);
/**/
			// if (view_statusUI == VIEW_STAGE_LYRIC)
			// {
			// 	view_statusUI = VIEW_STAGE_TOOLS;
			// 	Draw_UI();
			// } // end if
			// return the page lister to previous page
			mcStage.MCPageLister.currPage = 1;
		}
	}
	else
	{
		ext_fscommand2("SetAudLDBConfig", ldbconfigOff);
		if (view_statusUI == VIEW_STAGE_TOOLS && (lyricSetting == 0 || _loc2 == 0 || gPlayState == STATE_STOP) || view_statusUI == VIEW_STAGE_LYRIC)
		{
		/**/
		}
	}
}

function Update_Settings()
{
	var tmp;
	var settPage = mcPopupScreen.MCSettings.MCPageLister.currPage + 1;
	var mcSett = mcPopupScreen.MCSettings.MCSettings;
	switch (settPage)
	{
		case 2:
		{
			tmp = ext_fscommand2("GetAudBoundary");
			mcSett.MCFolder.gotoAndStop(tmp == MODE_BOUNDARY_FOLDER ? 2 : 1);
			mcSett.MCOne.gotoAndStop(tmp == MODE_BOUNDARY_ONE ? 2 : 1);
			mcSett.MCAll.gotoAndStop(tmp == MODE_BOUNDARY_ALL ? 2 : 1);
			break;
		}
		case 3:
		{
			tmp = ext_fscommand2("GetAudPSpeed");
			mcSett.TXSpeed.text = String((tmp + 5) * 10) + "%";
			tmp = ext_fscommand2("GetAudPitchControl");
			mcSett.MCOff.gotoAndStop(tmp == MODE_PITCH_OFF ? 2 : 1);
			mcSett.MCOn.gotoAndStop(tmp != MODE_PITCH_OFF ? 2 : 1);
			break;
		}
		case 1:
		default:
		{
			tmp = ext_fscommand2("GetAudRepeat");
			mcSett.MCRepeatOff.gotoAndStop(tmp == MODE_REPEAT_NO ? 2 : 1);
			mcSett.MCRepeatOn.gotoAndStop(tmp != MODE_REPEAT_NO ? 2 : 1);
			tmp = ext_fscommand2("GetAudShuffle");
			mcSett.MCShuffleOff.gotoAndStop(tmp == MODE_SHUFFLE_NO ? 2 : 1);
			mcSett.MCShuffleOn.gotoAndStop(tmp != MODE_SHUFFLE_NO ? 2 : 1);
			break;
		}
	} // End of switch
}

// draw current page of JE screen
function Update_EQ()
{
	gEQIdx = ext_fscommand2("GetJetEffectIndex");
	var mcEQ = mcPopupScreen.MCJe.MCJe;
	var mcCurr = mcEQ["MCJe" + (gEQIdx + 1)];
	mcEQ.MCSelect._x = mcCurr._x;
	mcEQ.MCSelect._y = mcCurr._y;

	for (i = 1; i <= arrayJeteffect.length; i++)
		mcEQ["MCJe" + i].gotoAndStop((gEQIdx == i - 1) ? 2 : 1);
}

function Update_Control()
{
	gPlayState = ext_fscommand2("GetEtcState");
	mcControls.MCBtnPlayPause.currMode = ((gPlayState == STATE_PLAY) ? 1 : 0);
}

function Update_Albumart()
{
	if (gCurrTrackInfo.Idx == gCurrTrackInfo.AlbumartIdx)
		return;
	if (gImgDir == IMG_DIR_NOTHING)
		gImgDir = IMG_DIR_NEXT;
	gCurrTrackInfo.AlbumartIdx = gCurrTrackInfo.Idx;
	gAlbumCount = ext_fscommand2("GetAudAlbumArtTotalNum", gCurrTrackInfo.AlbumartIdx);
	ext_fscommand2("SetAudAlbumArtIndex", 0);
	gMultiAlbumIdx = 0;
	gMultiAlbumTime = getTimer();
	var _loc1 = gCurrTrackInfo.AlbumartIdx + ".MU0";
	gRotateTime = getTimer();
	gAlbumUpdate = true;
	Albumart_Swap();
	coverLoader.loadClip(_loc1, mcCurCover);
}

// hide the settings stage after a while
function Check_Stage()
{
	// do not count the time while popup is active
	if (popup.isActive)
	{
		gStageTimer = getTimer();
		return;
	}

	if (gStageTimer != 0 && getTimer() - gStageTimer > 4000)
	{
		if (view_statusUI == VIEW_STAGE_TOOLS && gABMode != AB_MODE_A) /**///??
		{
			view_statusUI = VIEW_TITLE;
			Draw_UI();
		} // end if
	} // end if
}

function Check_DRM()
{
	if (ext_fscommand2("GetEtcTotalPLNum") >= 0)
		if (ext_fscommand2("GetEtcOpenState", "gTmpString") != 0)
			Popup_ShowDRM(gTmpString);
}

function AlbumArt_PostProcess(s)
{
	if (gChangeNow == false)
	{
		Albumart_Change();
		
	} // end if
	if (s == true)
	{
		
	} // end if
}

function Albumart_Change()
{
	mcCurCover._alpha = 0;
	mcNextCover._alpha = 100;
	var rot = 10;
	gImgRotate = true;
	mcCurCover.onEnterFrame = function ()
	{
		mcCurCover._alpha = mcCurCover._alpha + 20;
		mcNextCover._alpha = mcNextCover._alpha - 20;
		if (gImgDir == IMG_DIR_NEXT || gImgDir == IMG_DIR_NOTHING)
		{
			mcCover._rotation = mcCover._rotation + rot;
		}
		else
		{
			mcCover._rotation = mcCover._rotation - rot;
		}
		rot = rot + 10;
		if (mcCurCover._alpha > 70)
		{
			delete this.onEnterFrame;
			gAlbumUpdate = false;
			gImgRotate = false;
			mcCurCover._alpha = 100;
			mcNextCover._alpha = 0;
			mcCover._rotation = 0;
			coverLoader.unLoadClip(mcNextCover);
			mcCurCover._visible = true;
			mcNextCover._visible = false;
			mcCover._rotation = 0;
			gImgDir = IMG_DIR_NOTHING;
		} // end if
	};
}

function Albumart_Swap()
{
	var _loc1;
	_loc1 = mcCurCover;
	mcCurCover = mcNextCover;
	mcNextCover = _loc1;
}

function Albumart_Rotate()
{
	if (gPlayState == STATE_PLAY)
	{
// Fr0sT - no cover rotate
//		gRotateTime = getTimer();
//		++mcCover._rotation;
	} // end if
}

function Albumart_Multi()
{
	if (gPlayState == STATE_PLAY && gAlbumCount > 1)
	{
		if (getTimer() - gMultiAlbumTime > 6000 && gChangeNow == false)
		{
			gMultiAlbumTime = getTimer();
			++gMultiAlbumIdx;
			if (gMultiAlbumIdx > gAlbumCount - 1)
			{
				gMultiAlbumIdx = 0;
			} // end if
			ext_fscommand2("SetAudAlbumArtIndex", gMultiAlbumIdx);
			gChangeNow = true;
			var _loc2 = gCurrTrackInfo.AlbumartIdx + ".MU0";
			Albumart_Swap();
			coverLoader.loadClip(_loc2, mcCurCover);
			delete mcCover1.onEnterFrame;
			delete mcCover2.onEnterFrame;
			mcCurCover._alpha = 0;
			mcNextCover._alpha = 100;
			mcCurCover._visible = true;
			mcNextCover._visible = true;
			mcCurCover.onEnterFrame = function ()
			{
				if (mcNextCover._alpha < 30)
				{
					delete this.onEnterFrame;
					gChangeNow = false;
					mcCurCover._alpha = 100;
					mcNextCover._alpha = 0;
					mcNextCover._visible = false;
					coverLoader.unLoadClip(mcNextCover);
				} // end if
				mcCurCover._alpha = mcCurCover._alpha + 20;
				mcNextCover._alpha = mcNextCover._alpha - 20;
			};
		} // end if
	} // end if
}

function Progress_Seek(percent)
{
	Get_TrackInfo(INFO_LEVEL_TIME);
	var currTime = gCurrTrackInfo.CurrTime;
	var tmpTime = 0;
	if (gTimeRemain && currTime > 0)
		currTime = gCurrTrackInfo.TotalTime - currTime;
	if (percent < 0)
		percent = 0;
	if (percent > 1)
		percent = 1;

	var newTime = int(percent * gCurrTrackInfo.TotalTime);

	if (gABMode == AB_MODE_A)
	{
		tmpTime = ext_fscommand2("GetAudABModeStartTime");
		if (newTime < tmpTime)
			newTime = tmpTime + 1;
	}
	else if (gABMode == AB_MODE_AB)
	{
		tmpTime = ext_fscommand2("GetAudABModeStartTime");
		if (newTime < tmpTime)
			newTime = tmpTime + 1;
		tmpTime = ext_fscommand2("GetAudABModeEndTime");
		if (newTime > tmpTime)
			newTime = tmpTime - 1;
	}

	if (newTime != currTime && (gPrevSeek != newTime || gPrevSeek == newTime && getTimer() - gPrevSeekTime > 200))
	{
		if (ext_fscommand2("KeyAudDirectSeek", newTime) == 1)
		{
			Update_Progress();
			gPrevSeek = newTime;
			gPrevSeekTime = getTimer();
		} // end if
	} // end if
}

function DeleteCurrTrack(): Boolean
{
	// checks for invalid state (current state is not playing or paused no current track, empty playlist, etc)
	if ( (gPlayState != STATE_PLAY && gPlayState != STATE_PAUSE) || !(gCurrTrackInfo.FolderTotal > 0) || !(gCurrTrackInfo.FolderIdx >= 0) )
		return false;

	// trick: pause the playback and go one track forward (it won't start playing)
	// deleting the current file throws the state to total stop
	ext_fscommand2("KeyAudPause");
	ext_fscommand2("KeyAudShortFF");

	// delete the file
	var res = ext_fscommand2("EtcBrwDelete", gCurrTrackInfo.FolderIdx);
	if (res == -1)
		return false;

	// resume playback if it was active
	if (gPlayState == STATE_PLAY)
		ext_fscommand2("KeyAudPlay");

	// return the final result
	return true;
}

imgListener.onLoadInit = function (mc)
{
	mcDefaultCover.removeMovieClip();
	var _loc3 = mc._width;
	var _loc2 = mc._height;
	mc._xscale = mc._yscale = 100;
	mc._x = mc._y = -175;
	if (_loc3 == _loc2)
	{
		mc._width = mc._height = 350;
	}
	else if (_loc3 > _loc2)
	{
		mc._width = 350;
		mc._height = int(_loc2 * 350 / _loc3);
		mc._y = int((350 - mc._height) / 2) - 175;
	}
	else
	{
		mc._width = int(_loc3 * 350 / _loc2);
		mc._height = 350;
		mc._x = int((350 - mc._width) / 2) - 175;
	}
	AlbumArt_PostProcess(true);
};

imgListener.onLoadError = function (mc)
{
	mcDefaultCover.removeMovieClip();
/**///	mcDefaultCover = mc._parent.attachMovie("MCDefault", "mcDefault", this.getNextHighestDepth());
	mcDefaultCover._x = mcDefaultCover._y = -175;
	AlbumArt_PostProcess(false);
};

coverLoader.addListener(imgListener);
var gestureTime = 0;
var gestureInitX = -1;
var gestureLastX = -1;
var gestureOn = false;

// title

mcTouchArea.onPress = function ()
{
	if (_global.GetPopupMCName() != null || gInputEnable == false || view_statusUI == VIEW_STAGE_LYRIC)
	{
		return;
	} // end if
	if (view_statusUI == VIEW_STAGE_TOOLS)
	{
		view_statusUI = VIEW_TITLE;
		Draw_UI();
		gestureOn = false;
	}
	else
	{
		gestureTime = getTimer();
		gestureOn = true;
		gestureLastX = gestureInitX = this._xmouse;
		this.onMouseMove = function ()
		{
			gestureLastX = this._xmouse;
		};
	}
};

mcTouchArea.onReleaseOutside = mcTouchArea.onRelease = mcTouchArea.onDragOut = function ()
{
	if (_global.GetPopupMCName() != null || gInputEnable == false || view_statusUI == VIEW_STAGE_LYRIC || gestureOn == false)
	{
		return;
	} // end if
	delete this.onMouseMove;

	if (Math.abs(gestureLastX - gestureInitX) > 60 && getTimer() - gestureTime < 700)
	{
		if (gestureLastX - gestureInitX > 0)
			fn_KeyHandler(_global.KEY_REW_SHORT);
		else
			fn_KeyHandler(_global.KEY_FF_SHORT);
	}
/*
	else
	if (getTimer() - gestureTime < 300)
	{
		if (view_statusUI == VIEW_TITLE)
		{
			view_statusUI = VIEW_STAGE_TOOLS;
			Draw_UI();
		} // end if
	}
*/
	gestureOn = false;
};

mcTitleProgress.onPress = function ()
{
	this.onMouseMove = function ()
	{
		Progress_Seek(this._xmouse / this._width);
	};
};

mcTitleProgress.onReleaseOutside = mcTitleProgress.onRelease = function ()
{
	delete this.onMouseMove;
};

mcTitle.MCCurrentTime.onReleaseOutside = mcTitle.MCCurrentTime.onRelease = function ()
{
	gTimeRemain = !gTimeRemain;
	ext_fscommand2("SetDisPlayTime", gTimeRemain ? 1 : 0);
	Update_Progress();
}

mcBtnMatrix.onClick = function ()
{
	ext_fscommand2("SetAudLDBConfig", ldbconfigOff);
	mcCon.gotoAndStop(2);
};

// control bar: prev/play/next/open/tools

mcControls.MCBtnPlayPause.modeCount = 2;
mcControls.MCBtnPlayPause.autoChangeMode = false;
mcControls.MCBtnPlayPause.onClick = function ()
{
	Key_Play();
};

mcControls.MCBtnRew.repeatPress = true;
mcControls.MCBtnRew.repeatInterv = KEY_REPEAT_TIME;
mcControls.MCBtnRew.onRepeatPress = function ()
{
	if (gPlayState == STATE_PLAY)
		fn_KeyHandler(_global.KEY_REW_LONG);
	else
		fn_KeyHandler(_global.KEY_REW_SHORT);
};

mcControls.MCBtnRew.onClick = function ()
{
	if (this.wasRepeatPress)
		fn_KeyHandler(_global.KEY_RELEASE_LONG);
	else
		fn_KeyHandler(_global.KEY_REW_SHORT);
};

mcControls.MCBtnFF.repeatPress = true;
mcControls.MCBtnFF.repeatInterv = KEY_REPEAT_TIME;
mcControls.MCBtnFF.onRepeatPress = function ()
{
	if (gPlayState == STATE_PLAY)
		fn_KeyHandler(_global.KEY_FF_LONG);
	else
		fn_KeyHandler(_global.KEY_FF_SHORT);
};

mcControls.MCBtnFF.onClick = function ()
{
	if (this.wasRepeatPress)
		fn_KeyHandler(_global.KEY_RELEASE_LONG);
	else
		fn_KeyHandler(_global.KEY_FF_SHORT);
};

mcControls.MCBtnOpen.onClick = function ()
{
	_global.LoadSWF(_global.MODE_BROWSER);
};

mcControls.MCBtnTools.onClick = function ()
{
	view_statusUI = VIEW_STAGE_TOOLS;
	Draw_UI();
};

// tools screen

mcStage.MCPageLister.pageCount = 2;
mcStage.MCPageLister.currPage = 1;
mcStage.MCPageLister.onPageChange = function()
{
	switch (this.currPage)
	{
		case 0:
			view_statusUI = VIEW_STAGE_LYRIC;
			break;
		case 1:
			view_statusUI = VIEW_STAGE_TOOLS;
			break;
	}
	Draw_Stage();
}

mcStage.MCBtnBack.onClick = function ()
{
	view_statusUI = VIEW_TITLE;
	Draw_UI();
};

mcTools.MCBtnLoop.onClick = function ()
{
	gStageTimer = getTimer();
	gABMode = ext_fscommand2("KeyAudABMode");
	Update_ProgressABMode();
	Update_Progress();
};

mcTools.MCBtnFav.onClick = function ()
{
	gStageTimer = getTimer();
	Popup_Result(ext_fscommand2("KeyAudFavorite") != -1);
};

mcTools.MCBtnBookm.onClick = function ()
{
	gStageTimer = getTimer();
	Popup_Result(ext_fscommand2("KeyAudBookmark") != -1);
};

mcTools.MCBtnJE.onClick = function ()
{
	view_statusUI = VIEW_POPUP_EQ;
	Draw_UI();
};

mcTools.MCBtnSett.onClick = function ()
{
	view_statusUI = VIEW_POPUP_SETTING;
	Draw_UI();
};

mcTools.MCBtnDel.onClick = function ()
{
	gStageTimer = getTimer();
	Get_TrackInfo(INFO_LEVEL_PROPS + INFO_LEVEL_ADV);
	popup.show(TPopup.BOX_PROMPT, "Delete <i>"+gCurrTrackInfo.FileName+"</i>?", 
	           function(promptResult)
	           {
	           	if (promptResult == TPopup.RES_YES)
	           		Popup_Result(DeleteCurrTrack());
	           });
};

mcTools.MCBtnInfo.onClick = function ()
{
	if (gPlayState != STATE_PLAY && gPlayState != STATE_PAUSE)
	{
		popup.show(TPopup.BOX_FAIL, "Playback stopped — info unavailable");
	}
	else
	{
		view_statusUI = VIEW_POPUP_TRACKINFO;
		Draw_UI();
	}
};

// settings screen

function Init_Popup_Settings()
{
	mcPopupScreen.MCSettings.MCBtnBack.onClick = function ()
	{
		view_statusUI = VIEW_STAGE_TOOLS;
		Draw_UI();
	};
	
	// we intentionally set page change handler before the currPage to have it launched right now
	mcPopupScreen.MCSettings.MCPageLister.onPageChange = function()
	{
		Update_Settings();
		Slide_Page(this.currPage*-_global.LCD_WIDTH, mcPopupScreen.MCSettings.MCSettings);
	}
	mcPopupScreen.MCSettings.MCPageLister.pageCount = 3;
	mcPopupScreen.MCSettings.MCPageLister.currPage = 0;
	
	var mcSett = mcPopupScreen.MCSettings.MCSettings;
	
	mcSett.MCRepeatOff.onPress = mcSett.MCRepeatOn.onPress = mcSett.MCShuffleOff.onPress = mcSett.MCShuffleOn.onPress = mcSett.MCFolder.onPress = mcSett.MCOne.onPress = mcSett.MCAll.onPress = mcSett.MCOff.onPress = mcSett.MCOn.onPress = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		this.gotoAndStop(2);
	};
	
	mcSett.MCRepeatOff.onDragOut = mcSett.MCRepeatOn.onDragOut = mcSett.MCShuffleOff.onDragOut = mcSett.MCShuffleOn.onDragOut = mcSett.MCFolder.onDragOut = mcSett.MCOne.onDragOut = mcSett.MCAll.onDragOut = mcSett.MCOff.onDragOut = mcSett.MCOn.onDragOut = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		Update_Settings();
	};
	
	mcSett.MCRepeatOff.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudRepeat", MODE_REPEAT_NO);
		Update_Settings();
	};
	
	mcSett.MCRepeatOn.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudRepeat", MODE_REPEAT_OK);
		Update_Settings();
	};
	
	mcSett.MCShuffleOff.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudShuffle", MODE_SHUFFLE_NO);
		gCurrTrackInfo.Idx = ext_fscommand2("GetEtcCurPLIndex");
		gCurrTrackInfo.TotalIdx = ext_fscommand2("GetEtcTotalPLNum");
		gCurrTrackInfo.AlbumartIdx = gCurrTrackInfo.Idx;
		Update_Settings();
	};
	
	mcSett.MCShuffleOn.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudShuffle", MODE_SHUFFLE_OK);
		gCurrTrackInfo.Idx = ext_fscommand2("GetEtcCurPLIndex");
		gCurrTrackInfo.TotalIdx = ext_fscommand2("GetEtcTotalPLNum");
		gCurrTrackInfo.AlbumartIdx = gCurrTrackInfo.Idx;
		Update_Settings();
	};
	
	mcSett.MCFolder.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudBoundary", MODE_BOUNDARY_FOLDER);
		gCurrTrackInfo.Idx = ext_fscommand2("GetEtcCurPLIndex");
		gCurrTrackInfo.TotalIdx = ext_fscommand2("GetEtcTotalPLNum");
		gCurrTrackInfo.AlbumartIdx = gCurrTrackInfo.Idx;
		Update_Settings();
	};
	
	mcSett.MCOne.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudBoundary", MODE_BOUNDARY_ONE);
		gCurrTrackInfo.Idx = ext_fscommand2("GetEtcCurPLIndex");
		gCurrTrackInfo.TotalIdx = ext_fscommand2("GetEtcTotalPLNum");
		gCurrTrackInfo.AlbumartIdx = gCurrTrackInfo.Idx;
		Update_Settings();
	};
	
	mcSett.MCAll.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudBoundary", MODE_BOUNDARY_ALL);
		gCurrTrackInfo.Idx = ext_fscommand2("GetEtcCurPLIndex");
		gCurrTrackInfo.TotalIdx = ext_fscommand2("GetEtcTotalPLNum");
		gCurrTrackInfo.AlbumartIdx = gCurrTrackInfo.Idx;
		Update_Settings();
	};
	
	mcSett.MCOff.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudPitchControl", MODE_PITCH_OFF);
		Update_Settings();
	};
	
	mcSett.MCOn.onRelease = function ()
	{
		if (_global.GetPopupMCName() != null || gInputEnable == false)
			return;
		ext_fscommand2("SetAudPitchControl", MODE_PITCH_ON);
		Update_Settings();
	};
	
	mcSett.MCDown.repeatPress = mcSett.MCUp.repeatPress = true;
	mcSett.MCDown.repeatInterv = mcSett.MCUp.repeatInterv = KEY_REPEAT_TIME;
	
	mcSett.MCDown.onRepeatPress = MCDown.onClick = function ()
	{
		var speed = ext_fscommand2("GetAudPSpeed");
		if (speed > 0)
		{
			speed--;
			ext_fscommand2("SetAudPSpeed", speed);
			Update_Settings();
		}
	};
	
	mcSett.MCUp.onRepeatPress = MCUp.onClick = function ()
	{
		var speed = ext_fscommand2("GetAudPSpeed");
		if (speed < 10)
		{
			speed++;
			ext_fscommand2("SetAudPSpeed", speed);
			Update_Settings();
		}
	};
}

// JetEffect screen

function Init_Popup_JE()
{
	mcPopupScreen.MCJe.MCBtnBack.onClick = function ()
	{
		view_statusUI = VIEW_STAGE_TOOLS;
		Draw_UI();
	};

	mcPopupScreen.MCJe.MCPageLister.__proto__ = TPageLister.prototype; // magic !
	// we intentionally set page change handler before the currPage to have it launched right now
	mcPopupScreen.MCJe.MCPageLister.onPageChange = function()
	{
		Update_EQ();
		Slide_Page(this.currPage*-_global.LCD_WIDTH, mcPopupScreen.MCJe.MCJe);
	}
	mcPopupScreen.MCJe.MCPageLister.pageCount = 5;
	mcPopupScreen.MCJe.MCPageLister.currPage = Math.floor(ext_fscommand2("GetJetEffectIndex") / 9);
	
	var mcEQ = mcPopupScreen.MCJe.MCJe;
	
	for (i = 1; i <= arrayJeteffect.length; i++)
	{
		jeBtn = mcEQ["MCJe" + i];
		jeBtn["TXEQ"].text = arrayJeteffect[i-1];
		jeBtn.onPress = function ()
		{
			this.gotoAndStop(2);
		};
		jeBtn.onDragOut = function ()
		{
			this.gotoAndStop(1);
		};
		jeBtn.onRelease = function ()
		{
			this.gotoAndStop(1);
			var eqIdx = int(this._name.substring(4) - 1);
			if (eqIdx != gEQIdx)
			{
				ext_fscommand2("SetJetEffectIndex", eqIdx);
				Update_EQ();
			}
		};
	}
}

// track info screen

function Init_Popup_TrackInfo()
{
	mcPopupScreen.MCTrackInfo.MCBtnBack.onClick = function()
	{
		view_statusUI = VIEW_TITLE;
		Draw_UI();
	};
}

// global

onUnload = function ()
{
	_global.RemoveKeyListener(fn_KeyHandler);
	SaveConfig();
	ext_fscommand2("SetAudLDBConfig", ldbconfigOff);
};

Init();
initDebug(_root.TXDebug);
Init_fr1();
stop();