Gui Add, Edit, w300 h20 vsearchedString gIncrementalSearch
Gui Add, ListBox, vchoice gListBoxClick w300 h250 hscroll vscroll
Gui Add, Button, gListBoxClick Default, OK
Gosub FillListBox
Gui Show
Return

IncrementalSearch:
	Gui Submit, NoHide
	len := StrLen(searchedString)
	itemNb := 1
	Loop Parse, listContent, |
	{
		StringLeft part, A_LoopField, len
;~ 		Tooltip %part% (%A_LoopField%)
;~ 		Sleep 500
		If (part = searchedString)
		{
			itemNb := A_Index
			Break
		}
	}

	Tooltip %searchedString% (%itemNb%)
	SetTimer HideTooltip, 1000
	GuiControl Choose, choice, %itemNb%
Return

HideTooltip:
	SetTimer HideTooltip, Off
	Tooltip
Return

ListBoxClick:
	Gui Submit, NoHide
	MsgBox Choice: %choice%
Return

GuiClose:
GuiEscape:
ExitApp

FillListBox:
	listContent =
( Join|
car|bicyle|train|plane|road|railway station|track|airport|control tower|wheel
red|green|pink|blue|grey|silver|black|yellow|brown|white
hair|nose|eye|ear|face|mustache|neck|collar|arm|hand|forearm|forehead
finger|thumb|palm|back|stomach|leg|thigh|foot|toe
shoe|sock|stocking|trousers|jumpsuit|skirt|blouse|dress|shirt|tie|necklace|earring
Sun|Moon|Mercure|Venus|Earth|Mars|Jupiter|Saturn|Neptun|Pluto
Africa|America|Antarctica|Asia|Australia|Europe
Canada|USA|Mexico|Guatemala|Honduras|Cuba
Gui Add|Gui Show|Gui Submit|Gui Hide|Gui Destroy
)
	GuiControl, , choice, %listContent%
Return