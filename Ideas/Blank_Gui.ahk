#Include f:\ZapZap\Documents\Scripts\My Projects\ahkMessenger\lib\attach.ahk
#SingleInstance, force
;MainGUI
	Menu, mMenuBar, Add, Edit
	Menu, mMenuBar, Add, View
	Menu, mMenuBar, Add, Tools
	Gui, Main: +Resize MinSize545x324
	Gui, Main: Menu, mMenuBar
	Gui, Main: Add, StatusBar
	Gui, Main: Add, Edit     , x5 y6 w400 h200    HwndmELog                        ; HwndmELog = Edit chat Log
	Gui, Main: Add, ListView , x410 y6 w120 h198  HwndmLUsl,                       ; HwndmLUsl = Listview User List
	Gui, Main: Add, Edit     , x5 y210 w400 h21   HwndmESmg,                       ; HwndmESmg = Edit Send Message
	Gui, Main: Add, Button   , x410 y210 w55 h23  HwndmBSmg, Send                  ; HwndmBSmg = Button Send Message
	Gui, Main: Add, Button   , x475 y210 w55 h23  HwndmBCde  gCodeGUI, Code        ; HwndmBCde = Button Code
	Gui, Main: Add, GroupBox , x5 y238 w530 h57   HwndmGCon, Connection Settings   ; HwndmGCon = GroupBox Connection settings
	Gui, Main: Add, Text     , x17 y263 w51 h13   HwndmTNkN, Nickname:             ; HwndmTNkN = Text NickName
	Gui, Main: Add, Edit     , x78 y263 w100 h21  HwndmENkN, Guest17623105         ; HwndmENkN = Edit NickName
	Gui, Main: Add, Text     , x258 y263 w34 h13  HwndmTSIP, Server:               ; HwndmTSIP = Text Server IP
	Gui, Main: Add, Edit     , x308 y260 w100 h21 HwndmESIP, 99.23.4.199           ; HwndmESIP = Edit Server IP
	Gui, Main: Add, Button   , x186 y260 w55 h23  HwndmBCNk, Change                ; HwndmBCNk = Button Change NickName
	Gui, Main: Add, Button   , x420 y260 w55 h23  HwndmBCon, Connect               ; HwndmBCon = Button Connect
	Gui, Main: Add, Checkbox , x485 y265 w43 h13  HwndmCTst, Test                  ; HwndmCTst = CheckBox Test
	Gui, Main: Show          ; , x684 y355 h322 w539, New GUI Window
	Attach(mELog, "w h r")
	Attach(mLUsl, "x h r")
	Attach(mESmg, "y w r")
	Attach(mBSmg, "x y r")
	Attach(mBCde, "x y r")
	Attach(mGCon, "y w r")
	Attach(mTNkN, "y r")
	Attach(mENkN, "y r")
	Attach(mTSIP, "y r")
	Attach(mESIP, "y r")
	Attach(mBCNk, "y r")
	Attach(mBCon, "y r")
	Attach(mCTst, "y r")
Return

CodeGUI:
	Menu, cMenuBar, Add, Edit
	Menu, cMenuBar, Add, View
	Menu, cMenuBar, Add, Tools
	Gui, Code: +Resize
	Gui, Code: Add, StatusBar
	Gui, Code: Menu, cMenuBar
	Gui, Code: Add, ListView, x415 y3 w140 h400 , 
	Gui, Code: Add, Button, x330 y405 w75 h23 , Send
	Gui, Code: Show, autosize  ; , x402 y335 h434 w566, New GUI Window
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

/*
#Include f:\ZapZap\Documents\Scripts\My Projects\ahkMessenger\lib\attach.ahk
#SingleInstance, force
Gui, +Resize
Gui, Add, Edit, HWNDhe1 w150 h100
Gui, Add, Picture, HWNDhe2 w100 x+5 h100, pic.bmp

Gui, Add, Edit, HWNDhe3 w100 xm h100
Gui, Add, Edit, HWNDhe4 w100 x+5 h100
Gui, Add, Edit, HWNDhe5 w100 yp x+5 h100

gosub SetAttach ;comment this line to disable Attach
Gui, Show, autosize
return

SetAttach:
Attach(he1, "w.5 h r")
Attach(he2, "x.5 w.5 h r")
Attach(he3, "y w1/3 r")
Attach(he4, "y x1/3 w1/3 r")
Attach(he5, "y x2/3 w1/3 r")
return
*/