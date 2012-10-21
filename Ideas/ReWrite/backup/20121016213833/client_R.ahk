;//Directives
	OnExit, ExitRoutine
	#singleinstance force

;//Includes
	#include wrapper
	#include lib\ws.ahk
	#include lib\attach.ahk
	#include lib\keywords.ahk

;//Variables
	test := 1
	CODE := []
;//GUI
	createGUI()
	input:=new sci(mainwin,"input",20,370,550,50)
	Attach(input.hwnd, "w y r")
	input.2268(1),input.2400(1)
	input.2268(1),input.4006(0,"asm"),input.2051(8,0xff0000)
	input.2242(1,0)
	global Input

	;// Debug Only
	GoSub, Initialize
	;//===========
return

;//Labels
Initialize:
	;//WS_LOGTOCONSOLE := 1
	WS_Startup()
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, test ? "127.0.0.1" : "99.23.4.199", "80")
	WS_HandleEvents(client, "READ")
	WS_Send(client, "NWCN||")
	sleep 100
return

ChangeChannel:
	Gui, Main: Submit, NoHide
	chanSwitcher(TabSwitch)
return

HKTabSwitch:
	Gui, Main: Submit, NoHide
	for a, b in CLIENTCHANS
	{
		if (a = TabSwitch)
		current := a_index
		max := a_index	
	}
	if (current == max)
	current := 1
	else
	current++
	GuiControl, Main: Choose, SysTabControl321, % current
	Gui, Main: Submit, NoHide
	chanSwitcher(TabSwitch)
return

;//Funcions
createGUI(){
	global MsgInput, EChLog, MainWin, TabSwitch, cd

	static controlflow, commands, functions, directives, keysbuttons, variables, specialparams


	OnMessage(5,"setguipos")
	Gui, Main: +HWNDMainWin +Resize
	Gui, Main:Default
	sc := new sci(MainWin,"sc",20,50,520,270)
	sc.2268(1),sc.4006(0,"asm"),sc.2069(0xffffff)
	sc.2051(8,0xff0000),sc.2051(9,0x0000ff)
	OnMessage(0x4E, "Notify")
	Gui, Main:Add, ListView, x570 y12  w90  h328 HwndLNkL +ReadOnly -Hdr, UserList
	Gui, Main:Add, Groupbox, x10  y350 w650 h90  HwndGGbx  , Groupbox
	Gui, Main:Add, Button,   x580 y360 w70  h30  HwndBCon gInitialize,Connect
	Gui, Main:Add, Button,   x580 y390 w70  h30  HwndBCod gCodeWin ,Code
	Gui, Main:Add, Button,   w0   h0             HwndBSnd Default gSendMessage
	Gui, Main:Add, Tab,      x10  y10  w550 h330 HwndTTSw -Wrap vTabSwitch gChangeChannel
	Gui, Main:Show

	Gui, Code:Add, Button, x360 y510 w70 h30 HwndBSub gLocalSubmit, Submit
	Gui, Code:Add, Button, x10 y510 w70 h30 HwndBBGCol gFontColorChanger, Foreground
	Gui, Code:Add, Button, x90 y510 w70 h30 HwndBBFCol gBackgroundColorChanger, Background
	Gui, Code:Add,Treeview,x540 y10 w110 h490 HwndTVCd gUpdateCode
	Gui, Code:+Resize +HwndCdWn

	Hotkey, IfWinActive, ahk_id%MainWin%
	Hotkey, ^Tab, HKTabSwitch, On
	Hotkey, F6, CodeWin, On
	Hotkey, F5, Initialize, On
	Hotkey, IfWinActive, ahk_id%CdWn%
	Hotkey, F6, CodeWin, On
	Hotkey, ^Enter, LocalSubmit, On

	cd := new sci(CdWn,"cd",5,5,500,500)

	for a,b in keywords()
		%a%:=b
	cd.2056(32,"Courier New")
	cd.2055(32,12)
	cd.2050
	colorsetter()
	cd.4005(0,controlflow) ;//SetKeywords
    cd.4005(1,commands)
    cd.4005(2,functions)
    cd.4005(3,directives)
    cd.4005(4,keysbuttons)
    cd.4005(5,variables)
    cd.4005(6,specialparams)
    cd.4005(7,userdefined)

	Attach(cd.hwnd, "w h r")
	Attach(sc.hwnd, "w h r")
	Attach(BSub, "x y")
    Attach(LNkL, "x h")
    Attach(GGbx, "w y")
    Attach(BCon, "x y r")
    Attach(BCod, "x y r")
    Attach(BBGCol, "y")
    Attach(BBFCol, "y")
    Attach(TTSw, "w h")
	Attach(TVCd, "x h")
    return

    BackgroundColorChanger:
    	s := sci.hk().cd
   		col := Dlg_Color(s.2482(32))
   		IniWrite, %col%, color_settings.ini, Background, 32
   		colorsetter()
    return

    FontColorChanger:
		s := sci.hk().cd
		style := s.2010(s.2008)
   		col := Dlg_Color(s.2481(style))
   		IniWrite, %col%, color_settings.ini, Fonts, %style%
   		;s.2051(style, col)
   		;mb(style, col)
   		colorsetter()
    return

    CodeGuiClose:
    CodeWin:
    	cd.2400
    	x := !x
    	if (x)
    		Gui, Code:Show
    	else
    		Gui, Code:Hide
    return
}

LocalSubmit(){
	LocalSubmit:
	global cd, client, CLIENTNICK, CODE
	static i := 1
	static p1

	Gui, Code:Default
	EdCode := cd.gettext()
	WS_Send(client, "NWCD||" i "||" EdCode)
	if (i < 2)
		p1 := TV_Add(CLIENTNICK)
	c := TV_Add(i,p1)
	CODE[c] := EdCode
	tt(CODE[c],c)
	i++
	return

	UpdateCode:
	Gui, Code:Default
	thisNick := TV_GetText(v, tv_getselection())
	t := CODE[tv_getselection()]
	TV_GetText(clickedNick, t)
	id := tv_getselection()
	TV_GetText(itemtext,(TV_GetParent(id)))
	if(a_guievent != "DoubleClick" || !itemtext)
		return
	else if (itemtext == CLIENTNICK)
	{
		cd.2181(0,CODE[id])
		return
	}
	WS_Send(client, "RQCD||" thisNick . "||1")
	cd.2181(0,t)
	cd.2400		

	return
}

WS_OnRead(socket){
	global EChLog, CODE
	WS_Recv(socket, ServerMessage)
	RegexReplace(ServerMessage, "\|\|", "", count)
	loop, %count%
	search.="(.*)\|\|"
	search .= "(.*)"
	RegexMatch(ServerMessage, "^" . search, arg)
	msgType := arg1
	;msgbox % arg1 "`n" arg2 "`n" arg3 "`n" arg4
	setChatLog(EChLog, arg1, arg2, arg3, arg4, arg5)
}

setChatLog(hwn, a, b, c, d, e){
	global CLIENTNICK, CURRENTCHAN, CLIENTCHANS, ALLCHANLOGS, CODE
	;mb(a,b,c,d,e)
	static CHANLIST := [], chanLogs := [], chansNicks := []
	if      (a == "MESG")
	{
		/*
			a = MESG
			b = Channel
			c = Nickname
			d = Message
		*/
		m := "[" A_Hour ":" A_Min "] " c ": " d
	}
	else if (a == "JOIN")
	{
		/*
			a = JOIN
			b = #Channel
			c = Nickname
			d = Nick List
		*/
		input.4005(3,d)
		chansNicks[b] := d
		stringlower,d,d
		input.4005(3,d),sci.hk().sc.4005(3,d)
		if (CLIENTNICK == c)
		{
			RegExMatch(d,"i)(" c ")",name),
			rest:=regexreplace(d,"i)(" name ")"),
			rest:=Trim(rest)
			StringLower,rest,rest
			StringLower,name,name
			sci.hk().sc.4005(2,name),
			sci.hk().sc.4005(3,rest)
			CURRENTCHAN := b
			newchan := SubStr(b, 2)
			if !(CLIENTCHANS[CURRENTCHAN])
			chanSwitcher(CURRENTCHAN)
			CHANLIST[CURRENTCHAN] := CURRENTCHAN  ;//,mb(CURRENTCHAN, CHANLIST[CURRENTCHAN])
			CLIENTCHANS := CHANLIST
			channels := ""
			for a, b in CLIENTCHANS
			channels .= a "|"
			GuiControl, Main:, SysTabControl321, |%channels%|
		}
		m := "Notice: '" . c . "' joins the channel"
		var({chansNicks:chansNicks})
		if (b != CURRENTCHAN)
		return
		Gui, Main: Default
		LV_Delete()
		thisChansNicks := chansNicks[b]
		Loop, Parse, thisChansNicks, %A_Space%
		{
			LV_Add("", A_LoopField)
		}
	}
	else if (a == "NKCH")
	{
		/*
			a = NKCH
			b = Oldnick
			c = NewNick
			d = Channel
			e = List of nicks
		*/
		chansNicks[d] := e
		stringlower,e,e  ;//Extremely important. Don't forget.
		if (CLIENTNICK == b){
			CLIENTNICK := c
		}
		{
			RegExMatch(e,"i)(" CLIENTNICK ")",name),
			rest:=regexreplace(e,"i)(" name ")"),
			rest:=Trim(rest)
			StringLower,rest,rest
			StringLower,name,name
			sci.hk().sc.4005(2,name),
			sci.hk().sc.4005(3,rest)
		}
		m := "Notice: '" . b . "' has changed their name to '" . c . "'"
		b := d  ;// Leave this for later use
		if (b != CURRENTCHAN)
		return
		Gui, Main: Default
		LV_Delete()
		thisChansNicks := chansNicks[b]
		Loop, Parse, thisChansNicks, %A_Space%
		{
			LV_Add("", A_LoopField)
		}
		
	}
	else if (a == "USRN")
	{
		CLIENTNICK := b
	}
	else if (a == "NWCD")
	{
		/*
			b = nickname
			c = version	
		*/
		for i,c in CODE
		{
			TV_GetText(itemtext, i)
			if (itemtext == b)
				mb(itemtext)
			
		}
		if (CODE[])
		loop % TV_GetCount()
		{
			GetNext([ItemID,)
			TV_GetText(itemtext, )
		}

	}
	else if (a == "RQCD")
	{
		/*
			b = version
			c = nick
			d = code
		*/
		Gui, Code:Default
		thisNick := c
		if (thisNick == CLIENTNICK)
		{
			c :=
			loop % TV_GetCount()
			{
				TV_GetText(itemtext, ItemID)

			}
			cd.2181(0,CODE[id])
			return
		}
		WS_Send(client, "RQCD||" thisNick . "||1")
		cd.2181(0,t)
		cd.2400		

		/*
		;mb("a " a,"b " b,"c " c,"d " d)
		nickName := c, EdCode := d
		nickName := TV_Add(nickName)
		c := TV_Add(b " newcode",nickName)
		CODE[c] := EdCode
		if(!t)
			return
		cd.2181(0,t)
		cd.2400		
		*/
	}
	chanLogs[b, A_Now "." A_MSec] := m
	ALLCHANLOGS := chanLogs
	CURRENTCHAN := var("CURRENTCHAN")
	for tmStamp, msgLine in ALLCHANLOGS[CURRENTCHAN]
	chatBuilder .= msgLine . "`r`n"
	
	if (b != var("CURRENTCHAN"))
	return
	sc:=sci.hk().sc
	sci.hk().sc.2171(0)
	sci.hk().sc.2181(0,chatbuilder)
	sci.hk().sc.2171(1)
	sc.2160(sc.2006,sc.2006)
}

sendMessage(){
	SendMessage:
	global MsgInput, client, CLIENTNICK, CURRENTCHAN, CLIENTCHANS, ALLCHANLOGS
	if (!MsgInput)
	return
	if (SubStr(MsgInput, 1, 1) == "/")                               ; //If message is a command
	{
		if (SubStr(MsgInput,2,1) == "#")  ;// Channel switcher!! :P
		{
			ch := SubStr(MsgInput, 2)
			if (CLIENTCHANS[ch])
			chanSwitcher(ch)
			input.2380(1)
			return
		}
		WS_Send(client, "COMD||" . MsgInput)    ; //
	}
	else                                                             ; //or normal message
	WS_Send(client, "MESG||" . var("CURRENTCHAN") . "||" . MsgInput)
	input.2380(1)
	return
}

chanSwitcher(h){
	var({CURRENTCHAN:h})
	global CLIENTCHANS, ALLCHANLOGS
	input.2380(1)
	chatBuilder := ""
	for tmStamp, msgLine in ALLCHANLOGS[h]
	chatBuilder .= msgLine . "`r`n"
	sc:=sci.hk().sc
	sci.hk().sc.2171(0)
	sci.hk().sc.2181(0,chatbuilder),sci.hk().sc.2160(sci.hk().sc.2006,sci.hk().sc.2006)
	sc.2160(sc.2006,sc.2006)
	sci.hk().sc.2171(1)

	GuiControl, Main: ChooseString, SysTabControl321, %h%
	nicklist := var("chansNicks")[h]
	Gui, Main: Default
	LV_Delete()
	Loop, Parse, nicklist, %A_Space%
	{
		LV_Add("", A_LoopField)
	}
}

Dlg_Color(Color){
	VarSetCapacity(CHOOSECOLOR,0x24,0),VarSetCapacity(CUSTOM,64,0)
	,NumPut(0x24,CHOOSECOLOR,0),NumPut(hGui,CHOOSECOLOR,4)
	,NumPut(color,CHOOSECOLOR,12),NumPut(&CUSTOM,CHOOSECOLOR,16)
	,NumPut(0x00000103,CHOOSECOLOR,20)
	nRC:=DllCall("comdlg32\ChooseColorA", str,CHOOSECOLOR)
	if (errorlevel <> 0) || (nRC = 0)
	Exit
	setformat,integer,H
	clr := NumGet(CHOOSECOLOR,12)
	setformat,integer,D
	return %clr%
}

colorsetter(){
	/*
	;//cd.2051(0, 0xFF0000)  ;// Spaces? #?
	cd.2051(1, 0x00FF00)  ;// Comments
	cd.2051(2, 0x0000ff)  ;// Numbers
	cd.2051(3, 0xFF00FF)  ;// Strings
	cd.2051(4, 0x55aa55)  ;// Punctuation
	cd.2051(6, 0xaaaaaa)  ;// Control Flow
	cd.2051(7, 0xffaa00)  ;// Specialparams
	cd.2051(8, 0xffaa00)  ;// Functions
	cd.2051(9, 0xffaa00)  ;// Directives
	cd.2051(10, 0xffaa00) ;// Keybuttons
	cd.2051(11, 0xffaa00) ;// Multiline Comments
	cd.2051(14, 0xffaa00) ;// Variables
	cd.2051(15, 0xffaa00) ;// Escape Sequence
	cd.2051(5, 0xaaaaaa)  ;// Plain text
	*/
	cd:=sci.hk().cd
	IniRead, bc, color_settings.ini, Background, 32, 0x343A39
	cd.4006(0,"asm")
	cd.2052(32,bc) ; Set background to black (32 is default)
	cd.2050              ; set fore/back function for text

	for a,b in {0:"61dbde",1:"0x337739",2:"0x1E6CE1",3:"0xE362B6",4:"0x55aa55",5:"0xA7A7A7",6:"0xaaaaaa",7:"0xffaa00",8:"0x3EF9EF",9:"0xffaa00",10:"0xffaa00",11:"0xffaa00",14:"0xffaa00",15:"0xffaa00"}
	{
		IniRead, fc, color_settings.ini, Fonts, %a%
		fc := fc!="ERROR"?fc:b
		cd.2051(a, fc)

	}
}

notify(a,b,c,d){
	Critical
	global client,	chansNicks
	if A_Gui not in main,code
	return
	control:=NumGet(b+0)
	if !s:=sci.hk(control)
	return
	sciCode:=NumGet(b+8),cp:=s.2008,scpos:=NumGet(b+12)
	if (sciCode=2008)
	{
		if A_Gui = sciCode
		s:=sci.hk().cd,s.2242(0,strlen(s.2154)*10)
	}
	if (sciCode=2001){
		nicklist:=var("chansNicks")[var("CURRENTCHAN")]
		StringLower,nicklist,nicklist
		s:=input
		command:=s.gettextrange(s.2266(cp,0),s.2267(cp,0))
		word:=s.gettextrange(s.2266(cp,1),s.2267(cp,1))
		if (StrLen(word)>1&&s.2102=0){
			loop,parse,nicklist,%a_space%
			if RegExMatch(A_LoopField,"Ai)" word)
			list.=a_loopfield " "
			sort,list,UD%A_Space%
			if list
			s.2100(strlen(word),trim(list))
		}
		char:=NumGet(b+16)
		if char = 47
		{
			if s.2102
			return
			list=join me nick
			input.2100(0,list)
		}
		if char in 10
		if (control=input.hwnd)
		{
			msginput:=input.gettext()
			if (SubStr(MsgInput, 1, 1) == "/")                               ; //If message is a command
			{
				if (SubStr(MsgInput,2,1) == "#")  ;// Channel switcher!! :P
				{
					ch := SubStr(MsgInput, 2)
					if (CLIENTCHANS[ch])
					chanSwitcher(ch)
					input.2380(1)
					return
				}
				WS_Send(client, "COMD||" . MsgInput)    ; //
			}
			else                                                             ; //or normal message
			WS_Send(client, "MESG||" . var("CURRENTCHAN") . "||" . MsgInput)
			input.2181(0,"")
			input.2380(1)
		}
	}
}

mb(x*){
	for a,b in x
	list.=b "`n"
	MsgBox,% list
}

tt(x*){
	for a,b in x
	list.=b "`n"
	ToolTip,% list
}

db(x*){
	for a,b in x
	list.=b "|"
	OutputDebug,%list%
}

var(x=""){
	static
	static list:=[]
	if !IsObject(x)
	return list[x]
	for a,b in x
	list[a]:=b
}

F3::
	WS_Send(client, "RQCD||abel||" 1)
return
/*
;F7::
;return

F3::
	s := sci.hk().cd
	mb(s.2010(s.2008))
	Dlg_Color(Color)
return

F5::
	GoSub, Initialize
return
*/
;==== For DEBUGGING ONLY 
~*Esc::
;==== End DEBUG

;//Exit routine
	MainGuiClose:
	ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
	ExitApp
