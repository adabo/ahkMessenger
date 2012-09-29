#include f:\ZapZap\Documents\Scripts\My Projects\ahkMessenger\lib\attach.ahk
;MainGUI
	Menu, mMenuBar, Add, Edit
	Menu, mMenuBar, Add, View
	Menu, mMenuBar, Add, Tools
	Gui, Main: Menu, mMenuBar
	Gui, Main: Add, StatusBar, 0x100
	Gui, Main: +Resize MinSize545x324
	Gui, Main: Add, Edit, x5 y6 w400 h200               HwndmELog,
	Gui, Main: Add, ListView, x410 y6 w120 h198         HwndmLUsl, 
	Gui, Main: Add, Edit, x5 y210 w400 h21              HwndmESmg, 
	Gui, Main: Add, Button, x410 y210 w55 h23           HwndmBSmg, Send
	Gui, Main: Add, Button, x475 y210 w55 h23 gCodeGUI  HwndmBCde, Code
	Gui, Main: Add, Tab2, x5 y238 w0 h57 -Wrap vTabs HwndmTabs, TabShw|TabHid
	Gui, Main: Add, GroupBox, x5 y238 w530 h57    HwndmGCon, Connection Settings

	GUi, Main: Tab, TabShw
	Gui, Main: Add, Text, x17 y263 w51 h13              HwndmTNkN, Nickname:
	Gui, Main: Add, Edit, x78 y263 w100 h21             HwndmENkN, Guest17623105
	Gui, Main: Add, Text, x258 y263 w34 h13             HwndmTSIP, Server:
	Gui, Main: Add, Edit, x308 y260 w100 h21            HwndmESIP, 99.23.4.199
	Gui, Main: Add, Button, x186 y260 w55 h23           HwndmBCNk, Change
	Gui, Main: Add, Button, x420 y260 w55 h23           HwndmBCon, Connect
	Gui, Main: Add, Checkbox, x485 y265 w43 h13         HwndmCTst, Test
	Gui, Main: Add, Button, x5 y300 w55 h23 gTabsToggle HwndmBTG1, toggle
    Attach(mELog, "w h r1")
    Attach(mLUsl, "x h r1")
    Attach(mESmg, "y w r1")
    Attach(mBSmg, "x y r")
    Attach(mBCde, "x y r")
    Attach(mGCon, "y w r1")
    Attach(mTNkN, "y r1")
    Attach(mENkN, "y r1")
    Attach(mTSIP, "y r1")
    Attach(mESIP, "y r1")
    Attach(mBCNk, "y r")
    Attach(mBCon, "y r")
    Attach(mCTst, "y r1")
    Attach(mBTG1, "y r1")

	GUi, Main: Tab, TabHid
	Gui, Main: Add, Button, x5 y300 w55 h23 gTabsToggle HwndmBTG2, toggle
    Attach(mBTG2, "y r1")

	Gui, Main: Show  ; , x684 y355 h322 w539, New GUI Window

Return

MainGuiSize:
	gh := A_GuiHeight
return

TabsToggle:
	Gui, Main: Submit, NoHide
	tooltip %Tabs%
	GuiControl, Choose, Tabs, % (Tabs == "TabShw" ? "TabHid" : "TabShw")
	if (Tabs == "TabShw")
	{
		GuiControl, Main: MoveDraw, %mTabs%, % "y" . gh + 1
		GuiControl, Main: MoveDraw, %mELog%, % "h" . gh - 100
		GuiControl, Main: MoveDraw, %mESmg%, % "y" . gh - 82
		GuiControl, Main: MoveDraw, %mBSmg%, % "y" . gh - 82
		GuiControl, Main: MoveDraw, %mBCde%, % "y" . gh - 82
	}
	else if (Tabs == "TabHid")
			{
		GuiControl, Main: MoveDraw, %mTabs%, % "y" . gh + 120
		GuiControl, Main: MoveDraw, %mELog%, % "h" . gh - 154
		GuiControl, Main: MoveDraw, %mESmg%, % "y" . gh - 142
		GuiControl, Main: MoveDraw, %mBSmg%, % "y" . gh - 142
		GuiControl, Main: MoveDraw, %mBCde%, % "y" . gh - 142
	}
return

CodeGUI:
	Menu, cMenuBar, Add, Edit
	Menu, cMenuBar, Add, View
	Menu, cMenuBar, Add, Tools
	Gui, Code: Add, StatusBar
	Gui, Code: Menu, cMenuBar
	Gui, Code: Add, ListView, x415 y3 w140 h400 , 
	Gui, Code: Add, Button, x330 y405 w75 h23 , Send
	Gui, Code: Show  ; , x402 y335 h434 w566, New GUI Window
return

Edit:
	if (A_ThisMenu == "mMenuBar")
		ToolTip, Main GUI %A_ThisMenuItem%
	else if (A_ThisMenu == "cMenuBar")
		ToolTip, Code GUI %A_ThisMenuItem%
return

View:
	if (A_ThisMenu == "mMenuBar")
		ToolTip, Main GUI %A_ThisMenuItem%
	else if (A_ThisMenu == "cMenuBar")
		ToolTip, Code GUI %A_ThisMenuItem%
return

Tools:
	if (A_ThisMenu == "mMenuBar")
		ToolTip, Main GUI %A_ThisMenuItem%
	else if (A_ThisMenu == "cMenuBar")
		ToolTip, Code GUI %A_ThisMenuItem%
return

CodeGuiClose:
MainGuiClose:
ExitApp
