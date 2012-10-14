OnExit, ExitRoutine

#include <ws>
#singleinstance force

; Variabls
	test := 1

; GUI
	createGUI()
	GoSub, Initialize
	/*
	GuiControl, Main:, Edit2, /nick adabo
	Send, {Enter}
	sleep 500
	GuiControl, Main:, Edit2, /join #ahk
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
	OutputDebug **Client>>Initialize** **END**
return

ChangeChannel:
	Gui, Main: Submit, NoHide
	;mb("ChangeChannel", TabSwitch)
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
	;mb(current, max)
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
	OutputDebug **Client>>WS_OnRead** **START**
	WS_Recv(socket, ServerMessage)
	RegexReplace(ServerMessage, "\|\|", "", count)
	loop, %count%
		search.="(.*)\|\|"
	search .= "(.*)"
	RegexMatch(ServerMessage, "^" . search, arg)
	msgType := arg1
	;msgbox % arg1 "`n" arg2 "`n" arg3 "`n" arg4
	OutputDebug **Client>>WS_OnRead** msgType=%msgType%, data=%data%
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
		;history .= chanLogs[b] . "`n" . d

		;if (b != CLIENTCHANS[CURRENTCHAN])
			;return
		m := "[" A_Hour ":" A_Min "] " c ": " d
		;msgbox %m%`n%b%`n%c%`n%d%
		OutputDebug **Client>>setChatLog>>MESG**
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
		;mb(thisChansNicks,d)
		Loop, Parse, thisChansNicks, %A_Space%
		{
			LV_Add("", A_LoopField)
		}
		;for chan, nick in chansNicks[var("CURRENTCHAN")]
			;if (chan == var("CURRENTCHAN"))
				;LV_Add("", chan)
		;OutputDebug **Client>>setChatLog>>JOIN**
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
		if (CLIENTNICK == b)
			CLIENTNICK := c
		m := "Notice: '" . b . "' has changed their name to '" . c . "'"
		b := d  ;// Leave this for later use
		OutputDebug **Client>>setChatLog>>NKCH**
		if (b != CURRENTCHAN)
			return
		Gui, Main: Default
		LV_Delete()
		thisChansNicks := chansNicks[b]
		;mb(thisChansNicks,d)
		Loop, Parse, thisChansNicks, %A_Space%
		{
			LV_Add("", A_LoopField)
		}

		;for chan, nick in chansNicks[var("CURRENTCHAN")]
		;	if (chan == var("CURRENTCHAN"))
		;		LV_Add("", nick)

	}
	else if (a == "USRN")
	{
		CLIENTNICK := b
	}
	chanLogs[b, A_Now "." A_MSec] := m
	ALLCHANLOGS := chanLogs
	CURRENTCHAN := var("CURRENTCHAN")
	if (b != var("CURRENTCHAN"))
		return
	ControlGetText, log,, ahk_id%hwn%
	msg := log = "" ? m : log . "`r`n" m
	ControlSetText,, %msg%, ahk_id %hwn%
}

createGUI(){
	global MsgInput, EChLog, MainWin, TabSwitch
	Gui, Main: +HWNDMainWin
	Gui, Main: Add,ListView,x570 y50 w90 h290,ListView
	Gui, Main: Add,Groupbox,x10 y350 w650 h90,Groupbox
	Gui, Main: Add,Edit,x20 y50 w520 h270 HwndEChLog
	Gui, Main: Add,Edit,x20 y370 w550 h50 -WantReturn vMsgInput HwndEMsgIn
	Gui, Main: Add,Button,x580 y380 w70 h30 gInitialize, Connect
	Gui, Main: Add, Button, w0 h0 Default gSendMessage
	Gui, Main: Add,Tab,x10 y10 w550 h330 vTabSwitch gChangeChannel
	Gui, Main: Show
	GuiControl, Main: Focus, Edit2
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
					GuiControl, Main:, Edit2,
					GuiControl, Main: Focus, Edit2
				return
			}
			WS_Send(client, "COMD||" . MsgInput)    ; //
		}
		else                                                             ; //or normal message
			WS_Send(client, "MESG||" . var("CURRENTCHAN") . "||" . MsgInput)
		OutputDebug **Client>>SendMessage:>>If Not "/"** %MsgInput%
		GuiControl, Main:, Edit2,
		GuiControl, Main: Focus, Edit2
	return
}

chanSwitcher(h){
	var({CURRENTCHAN:h})
	global CLIENTCHANS, ALLCHANLOGS
	;CURRENTCHAN := CLIENTCHANS[ch] ? CLIENTCHANS[ch] : ch
	;mb(CURRENTCHAN)
	GuiControl, Main:, Edit2,
	GuiControl, Main: Focus, Edit2
	chatBuilder := ""
	for tmStamp, msgLine in ALLCHANLOGS[h]
		chatBuilder .= msgLine . "`r`n"
	GuiControl, Main:, Edit1, % trim(chatBuilder, "`r`n")
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
	mb(CURRENTCHAN)
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
