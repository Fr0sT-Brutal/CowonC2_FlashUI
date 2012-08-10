// Page lister for Cowon player
// Requires TButton class
// © Fr0sT
// 
//                    Usage
// 
// MCPageLister.onPageChange = function()
// {
// 	trace(this.currPage+"/"+this.pageCount);
// }
// MCPageLister.pageCount = 3; // !! set pageCount BEFORE currPage !!
// MCPageLister.currPage = 0; // ! this will launch onPageChange, set it after currPage if you don't need that

class TPageLister extends MovieClip
{
	// public fields
	public var onPageChange;
	// accessible via get/set methods:
	// public var pageCount [RW]
	// public var currPage [RW]

	// internal fields
	private var fPageCount: Number;
	private var fCurrPage: Number;
	private var fInited: Boolean = false;
	private var btnNext, btnPrev: TButton;    // shorthands for easy access
	private var mcPageHolder: MovieClip;
	private var mcPageMark: MovieClip;        // invisible MC from which other page marks are duplicated
	private var mcPageMarks: Array;           // current list of page marks

	// save pointers to child objects and assign event handlers
	public function TPageLister()
	{
	}

	private function init()
	{
		btnNext = this["MCBtnNext"];
		btnPrev = this["MCBtnPrev"];
		mcPageHolder = this["MCPages"];
		mcPageMark = mcPageHolder["MCPageMark"];
		mcPageMark._visible = false;

		btnNext.onClick = function()
		{
			_parent.currPage += 1;
		}
		
		btnPrev.onClick = function()
		{
			_parent.currPage -= 1;
		}

		fInited = true;
	}

	public function get pageCount(): Number
	{
		return fPageCount;
	}

	public function set pageCount(pageCnt: Number): Void
	{
		if (pageCnt < 0 || fPageCount == pageCnt) return;
		if (!fInited)
			init();
		fPageCount = pageCnt;
		
		// generate page marks
		// remove old ones
		for (var pageMark in mcPageMarks)
			pageMark.removeMovieClip();
		// create new ones
		mcPageMarks = new Array();
		var border = (mcPageHolder._width - (fPageCount - 1)*mcPageMark._width)/2;
		for (var page = 0; page < fPageCount; page++)
			mcPageMarks[page] = 
				mcPageMark.duplicateMovieClip("MCPageMark"+page, 
				                              mcPageMark.getDepth() + 1 + page,
				                              {_x: border + mcPageMark._width*page});
	}

	public function get currPage(): Number
	{
		return fCurrPage;
	}

	public function set currPage(newPage: Number): Void
	{
		if (fPageCount == undefined) return;

		if (newPage > fPageCount - 1)
			newPage = fPageCount - 1;
		else
		if (newPage < 0)
			newPage = 0;

		// don't change page if equal to current
		if (newPage == fCurrPage) return;

		// "leave" the current page
		if (fCurrPage >= 0 && fPageCount > 0)
			mcPageMarks[fCurrPage].gotoAndStop(1);
		
		fCurrPage = newPage;		
		
		// check the buttons
		btnNext.Enabled = (fCurrPage < fPageCount - 1);
		btnPrev.Enabled = (fCurrPage > 0);

		// "enter" the current page
		if (fCurrPage >= 0 && fPageCount > 0)
			mcPageMarks[fCurrPage].gotoAndStop(2);

		// launch event handler
		if (onPageChange)
			onPageChange();
	}

}