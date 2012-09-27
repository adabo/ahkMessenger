toggle := 1
Gui, 01: +LastFound
Gui, 01: Add, Edit, w500 h300 HwndEdID
Gui, 01: Add, Button, gListViewToggle, Toggle

Gui, 02: -Caption +LastFound +Owner1 -0x80000000 +0x40000000 -Border
Gui, 02: Add, ListView, h300 w80 gMyListView HwndLVID, Name

Gui, 1: show
return

MyListView:
return

ListViewToggle:
	toggle := !toggle
	if (!toggle)
	{
		GuiControl, 01: Move, %EdID%, w400
		Gui, 02: Show, x420 y0
	}
	else if (toggle)
	{
		GuiControl, 01: Move, %EdID%, w500
		Gui, 02: Hide
	}
return