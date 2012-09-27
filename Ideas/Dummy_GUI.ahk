;MainGUI
	Menu, mMenuBar, Add, Edit
	Menu, mMenuBar, Add, View
	Menu, mMenuBar, Add, Tools
	Gui, Main: Menu, mMenuBar
	Gui, Main: Add, StatusBar

	Gui, Main: Add, Edit, x5 y6 w400 h200
	Gui, Main: Add, ListView, x410 y6 w120 h198 , 
	Gui, Main: Add, Edit, x5 y210 w400 h21 , 
	Gui, Main: Add, Button, x410 y210 w55 h23 , Send
	Gui, Main: Add, Button, x475 y210 w55 h23 gCodeGUI, Code
	Gui, Main: Add, GroupBox, x5 y238 w530 h57 , Connection Settings
	Gui, Main: Add, Text, x17 y263 w51 h13 , Nickname:
	Gui, Main: Add, Edit, x78 y268 w100 h21 , Guest17623105
	Gui, Main: Add, Text, x258 y263 w34 h13 , Server:
	Gui, Main: Add, Edit, x308 y260 w100 h21 , 99.23.4.199
	Gui, Main: Add, Button, x186 y260 w55 h23 , Change
	Gui, Main: Add, Button, x420 y260 w55 h23 , Connect
	Gui, Main: Add, Checkbox, x485 y265 w43 h13 , Test
	Gui, Main: Show  ; , x684 y355 h322 w539, New GUI Window
Return

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