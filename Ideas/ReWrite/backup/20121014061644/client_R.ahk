OnExit, ExitRoutine

#singleinstance force

; Variabls
	test := 1

; GUI
	createGUI()
	GoSub, Initialize
	/*
	GuiControl, Main:, Edit1, /nick adabo
	Send, {Enter}
	sleep 500
	GuiControl, Main:, Edit1, /join #ahk
	sleep 300
	Send, {Enter}
*/
return

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

WS_OnRead(socket){
	global EChLog
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

setChatLog(hwn, a, b, c, d, e){  ; //(Control HWND, string message)
	global CLIENTNICK, CURRENTCHAN, CLIENTCHANS, ALLCHANLOGS
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
		chansNicks[b] := d
		stringlower,d,d
		sci.hk().sc.4005(2,d)
		if (CLIENTNICK == c)
		{
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
		stringlower,e,e
		sci.hk().sc.4005(2,e)
		if (CLIENTNICK == b)
			CLIENTNICK := c
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
	chanLogs[b, A_Now "." A_MSec] := m
	ALLCHANLOGS := chanLogs
	CURRENTCHAN := var("CURRENTCHAN")
	for tmStamp, msgLine in ALLCHANLOGS[CURRENTCHAN]
		chatBuilder .= msgLine . "`r`n"

	if (b != var("CURRENTCHAN"))
		return
	sci.hk().sc.2181(0,chatbuilder)
	;for a,b in sci.hk()
		;b.2181(0,chatbuilder)
	;ControlGetText, log,, ahk_id%hwn%
	;msg := log = "" ? m : log . "`r`n" m
	;ControlSetText,, %msg%, ahk_id %hwn%
}

createGUI(){
	global MsgInput, EChLog, MainWin, TabSwitch
	;__New(hwnd,x=0,y=0,w=500,h=500)
	Gui, Main: +HWNDMainWin
	sc := new sci(MainWin,"sc",20,50,520,270)
	sc.2268(1),sc.4006(0,"asm")
	sc.2051(8,0xff0000)
		;sc.4005(2,"hi")
	Gui, Main: Add,ListView,x570 y50 w90 h290,ListView
	Gui, Main: Add,Groupbox,x10 y350 w650 h90,Groupbox
	;Gui, Main: Add,Edit,x20 y50 w520 h270 HwndEChLog
	Gui, Main: Add,Edit,x20 y370 w550 h50 -WantReturn vMsgInput HwndEMsgIn
	Gui, Main: Add,Button,x580 y380 w70 h30 gInitialize, Connect
	Gui, Main: Add, Button, w0 h0 Default gSendMessage
	Gui, Main: Add,Tab,x10 y10 w550 h330 vTabSwitch gChangeChannel
	Gui, Main: Show
	GuiControl, Main: Focus, Edit1
	Hotkey, IfWinActive, ahk_id%MainWin%
	Hotkey, ^Tab, HKTabSwitch, On
}

sendMessage(){
	global MsgInput, client, CLIENTNICK, CURRENTCHAN, CLIENTCHANS, ALLCHANLOGS
	SendMessage:
		Gui, Main: Submit, NoHide
		if (!MsgInput)
			return
		if (SubStr(MsgInput, 1, 1) == "/")                               ; //If message is a command
		{
			if (SubStr(MsgInput,2,1) == "#")  ;// Channel switcher!! :P
			{
				ch := SubStr(MsgInput, 2)
				if (CLIENTCHANS[ch])
					chanSwitcher(ch)
					GuiControl, Main:, Edit1,
					GuiControl, Main: Focus, Edit1
				return
			}
			WS_Send(client, "COMD||" . MsgInput)    ; //
		}
		else                                                             ; //or normal message
			WS_Send(client, "MESG||" . var("CURRENTCHAN") . "||" . MsgInput)
		GuiControl, Main:, Edit1,
		GuiControl, Main: Focus, Edit1
	return
}

chanSwitcher(h){
	var({CURRENTCHAN:h})
	global CLIENTCHANS, ALLCHANLOGS
	GuiControl, Main:, Edit1,
	GuiControl, Main: Focus, Edit1
	chatBuilder := ""
	for tmStamp, msgLine in ALLCHANLOGS[h]
		chatBuilder .= msgLine . "`r`n"
	sci.hk().sc.2181(0,chatbuilder)
	;GuiControl, Main:, Edit1, % trim(chatBuilder, "`r`n")
	GuiControl, Main: ChooseString, SysTabControl321, %h%
	nicklist := var("chansNicks")[h]
	Gui, Main: Default
	LV_Delete()
	Loop, Parse, nicklist, %A_Space%
	{
		LV_Add("", A_LoopField)
	}
}

mb(x*){
    for a,b in x
        list.=a "=" b "`n"
    MsgBox,% list
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
	s := sci.hk().sc
	mb(s.2010(s.2008))
return

F5::
	GoSub, Initialize
return

;==== For DEBUGGING ONLY 
~*Esc::
;==== End DEBUG
MainGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
#include wrapper