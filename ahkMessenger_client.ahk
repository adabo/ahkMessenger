/*
	ahkMessenger v0.2.2
	author: adabo
	email: abel4@msn.com
*/

;//Directives
	OnExit, ExitRoutine
	#singleinstance Off

;//Includes
	#include lib\attach.ahk
	#include lib\keywords.ahk
	#include lib\ws.ahk
	#include wrapper

;//Variables
	WS_LOGTOCONSOLE := 1
	test            := 0
	
;//Super Globals
	global trm      := chr(13) chr(10)
	global mainUser
	global cd,sc,input
	global client
	global MsgInput
	global TabSwitch
/*
	global ALLCHANLOGS := []
	global CHANLIST := []
	global chanlogs := []
	global chansNicks := []
	global CLIENTCHANS := []
	global CLIENTNICK
	global CODE        := []
	global CURRENTCHAN
	global EChLog 
*/

;//Program start
	createGUI()  ;
	initialize()  ;
return

createGUI(){
	static
	Gui, DBG:Font, s8, Verdana
	Gui, DBG:Add, Edit, w500 h700 +ReadOnly

	;//Setup Main chat window
	Gui, Main:Default
	Gui, Main: +HWNDMainWinHwn +Resize
	Gui, Main:Add, ListView, x570 y12  w90  h328 HwndLNkL +ReadOnly -Hdr, UserList
	Gui, Main:Add, Groupbox, x10  y350 w650 h90  HwndGGbx  , Groupbox
	Gui, Main:Add, Button,   x580 y360 w70  h30  HwndBCon ginitialize,Connect
	Gui, Main:Add, Button,   x580 y390 w70  h30  HwndBCod gCodeWin ,Code
	Gui, Main:Add, Tab,      x10  y10  w550 h330 HwndTTSw -Wrap vTabSwitch gchanTabSwitcher
	Gui, Main:Font, s8, Courier New
	Gui, Main:Add, StatusBar, gstatusBarClick
	SB_SetParts(120,80,80)
	;//SB_SetIcon("Shell32.dll",3,1)
	sc := new sci(MainWinHwn,"sc",20,50,520,270)
	input:=new sci(MainWinHwn,"input",20,370,550,50)
	
	;//Setup Code share window
	Gui, Code:+Resize +HwndCodeWinHWn
	Gui, Code:Add, Button, x360 y510 w70 h30 HwndBSub gsendCode, Submit
	Gui, Code:Add, Button, x10 y510 w70 h30 HwndBBGCol gForegroundColorChanger, Foreground
	Gui, Code:Add, Button, x90 y510 w70 h30 HwndBBFCol gBackgroundColorChanger, Background
	Gui, Code:Add,Treeview,x540 y10 w110 h490 HwndTVCd grequestCode
	cd := new sci(CodeWinHWn,"cd",5,5,500,500)

	setupHotkeys(MainWinHwn,CodeWinHWn)  ;
	setupSciControls()

	attachControls(input.hwnd, "w y r"
		             ,sc.hwnd, "w h r"
		             ,cd.hwnd, "w h r"
		             ,BSub,"x y"
		             ,LNkL,"x h"
		             ,GGbx,"w y"
		             ,BCon,"x y "
		             ,BCod,"x y "
		             ,BBGCol,"y"
		             ,BBFCol,"y"
		             ,TTSw,"w h"
		             ,TVCd,"x h")
	Gui, Main:Show
}

attachControls(hwn*){
	hwnObject := []
	for i,coord in hwn
	{
		if !(mod(i, 2))
		{
			hwnObject[i, hwId] := coord
			for h,c in hwnObject[i]
				Attach(h, c)
		}
		hwId := coord
	}
}

setupSciControls(){
	input.2268(1),input.2400(1)
	input.2268(1),input.4006(0,"asm"),input.2051(8,0xff0000)
	input.2242(1,0)

	sc.2268(1),sc.4006(0,"asm"),sc.2069(0xffffff)
	sc.2051(8,0xff0000),sc.2051(9,0x0000ff)
	OnMessage(0x4E, "Notify")

	cd.2056(32,"Courier New")
	cd.2055(32,12),cd.2050,cd.4006(0,"asm")
	setSciColors()
}

setupHotkeys(MainWinHwn,CodeWinHWn){
	Hotkey, IfWinActive, ahk_id%MainWinHWn% MainWinHwn
	Hotkey, ^Tab, hotkeySwitchChans, On
	Hotkey, F6, CodeWin, On
	Hotkey, F5, initialize, On
	Hotkey, IfWinActive, ahk_id%CodeWinHWn%
	Hotkey, F6, CodeWin, On
	Hotkey, ^Enter, sendCode, On
}

initialize(){
	initialize:
	WS_Startup()
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, "99.23.4.199", "12345")
	WS_HandleEvents(client, "READ")
	return
}

WS_OnRead(socket){
	static dbugWin
	;// static i:=1
	WS_Recv(socket, s),ServerMessage:=rtrim(s,"`n")

	;//=====================
	;//For debugging
	Gui,Main:Default
	SB_SetText(ServerMessage , 4)
	dbugWin .= ServerMessage "`n"
	GuiControl, DBG:, Edit1, %dbugWin%
	;//=====================

	Loop, Parse, ServerMessage, `n
	{
		if !(ServerMessage := rtrim(A_LoopField,"`r`n"))
			return
		;// db("a_index " a_index,ServerMessage)
		getRegexArgs(ServerMessage,arg1,arg2,arg3,arg4,arg5)
		protType := arg1

		if      (protType == "MESG")
			protMESG(arg2,arg3,arg4)
		else if (protType == "JOIN")
			protJOIN(arg2,arg3,arg4)
			;// (chn,nck,lst)
		else if (protType == "NKCH")
			protNKCH(arg2,arg3)
			;// (onk,nnk,chn,lst)
		else if (protType == "USRN")
			statusBarSetText(arg2, 1),protUSRN(arg2)
			;// (nck)
		else if (protType == "NWCD")
			protNWCD(arg2,arg3)
			;// (nck,ver)
		else if (protType == "RQCD")
			protRQCD(arg3,arg4)
			;// (ver,nck,cod)
	}
}

protUSRN(nck){
	mainUser := new user(nck)
}

protMESG(chn,nck,msg){
	static i:=1
	msg := getTime() " " nck ": " msg
	user.addMsgToLog(chn,msg)
	db(i++,chn,nck,msg)
	setChatWin(chn,msg)
}

protJOIN(chn,nck,lst){
	listU:=lst  ;// Save original casing for ListView
	user.setNickList(chn,lst)
	input.4005(3,lst)
	stringlower,lst,lst
	input.4005(3,lst),sci.hk().sc.4005(3,lst)
	if (mainUser.nick == nck)
	{
		mainUser.addChan(chn)
		mainUser.curChan := chn
		RegExMatch(lst,"i)(" nck ")",name),
		rest:=regexreplace(lst,"i)(" name ")"),
		rest:=Trim(rest,"`n")
		StringLower,rest,rest
		StringLower,name,name
		sci.hk().sc.4005(2,name),
		sci.hk().sc.4005(3,rest)
		for i,c in mainUser.chans
			channels .= c "|"
		GuiControl, Main:, SysTabControl321, |%channels%|
	}
	Gui, Main: Default
	LV_Delete()
	user.getNickList(chn)
	Loop, Parse, listU, %A_Space%
		LV_Add("", A_LoopField)
	setChatWin(chn,getTime() " Notice: '" nck "' joins the channel")
}

protNKCH(onk,nnk){
	user.setNickList("","",onk,nnk)
	sci.hk().sc.4005(2,setCase(nnk,"l"))
	if !(user.chanNicks[mainUser.curChan,nnk])
		return
	Gui, Main: Default
	LV_Delete()
	;// thisChansNicks := chansNicks[chn]
	lst := user.getNickList(mainUser.curChan)
	Loop, Parse, lst, %A_Space%
		LV_Add("", A_LoopField)
	note := getTime() " Notice: '" onk "' has changed their name to '" nnk "'"
	setChatWin(chn,note)
}

protNWCD(nck,ver){
	if (nck == CLIENTNICK)
		return
	Gui, Code:Default
	id := 0
	loop % TV_GetCount()  ;//Find if the nickname exists in treeview
	{
		id := TV_GetNext(id,  "Full")
		TV_GetText(itemtext, id)
		if (itemtext == nck)
			break
		itemtext := ""
	}
	if (itemtext)       ;//If a nick was found, add a child version
		TV_Add(ver, id)
	else				;//Else add the nick with a parent and first child version
	{
		id := TV_Add(nck)
		TV_Add(ver,id)
	}
}

protRQCD(nck,cod){
	Gui, Code:Default
	id := 0
	loop % TV_GetCount()  ;//Find if the nickname exists in treeview
	{
		id := TV_GetNext(id,  "Full")
		TV_GetText(itemtext, id)
		if (itemtext == nck)
			break
		itemtext := ""
	}
	CODE[id] := cod
	cd.2181(0,cod)
	cd.2400		
}

setChatWin(chn,msg){
	if (chn != mainUser.curChan)
		return
	sc:=sci.hk().sc
	sci.hk().sc.2171(0)
	sci.hk().sc.2181(0,rtrim(user.chanLogs[chn],"`n"))
	sci.hk().sc.2171(1)
	sc.2160(sc.2006,sc.2006)
}

sendMessage(ctl){
	if (ctl=input.hwnd && MsgInput:=trim(input.gettext(),"`n`r"))
	{
		if (SubStr(MsgInput,1,1) == "/")
		{
			RegexMatch(MsgInput,"^\/(\w+?) (.*)", arg)
			cmd:=setCase(arg1,"u"),prm:=arg2
			if      (cmd == "JOIN")
				WS_Send(client, "JOIN||" (SubStr(prm,1,1) == "#" ? prm : "#" prm) trm)
			else if (cmd == "NICK") 
				WS_Send(client, "NKCH||" prm trm)
		}
		else
			WS_Send(client, "MESG||" mainUser.curChan "||" MsgInput trm)
		input.2181(0,"")
		input.2380(1)
	}
}

sendCode(){
	sendCode:
	static i := 1
	static p1

	Gui, Code:Default
	EdCode := cd.gettext()
	WS_Send(client, "NWCD||" i "||" EdCode)
	if (i < 2)
		p1 := TV_Add(CLIENTNICK)
	c := TV_Add(i,p1)
	CODE[c] := EdCode
	i++
	return
}

requestCode(){
	requestCode:
	Gui, Code:Default
	TV_GetText(item, id := TV_GetSelection()), TV_GetText(p, TV_GetParent(id))
	if (a_guievent != "DoubleClick" || item + 0 == "")
		return
	else if (c := CODE[id])
	{
		cd.2181(0,c)
		cd.2400
	}
	else
		WS_Send(client, "RQCD||" p "||" item)
	return
}

hotkeySwitchChans(){
	hotkeySwitchChans:
	Gui, Main: Submit, NoHide
	chn := TabSwitch
	for i, c in mainUser.chans
	{
		if (c = chn)
			current := A_Index
		max := A_Index
	}
	if (current == max)
		current := 1
	else
		current++
	GuiControl, Main: Choose, SysTabControl321, % current
	Gui, Main: Submit, NoHide
	chanTabSwitcher(chn)
	return
}

backgroundColorChanger(){
    BackgroundColorChanger:
	s := sci.hk().cd
	col := Dlg_Color(s.2482(32))
	IniWrite, %col%, color_settings.ini, Background, 32
	setSciColors()
    return
}

foregroundColorChanger(){
	ForegroundColorChanger:
	s := sci.hk().cd
	style := s.2010(s.2008)
	col := Dlg_Color(s.2481(style))
	IniWrite, %col%, color_settings.ini, Fonts, %style%
	s.2051(style, col)
	;//mb(style, col)
	setSciColors()
    return
}

statusBarClick(){
	statusBarClick:
	Gui,DBG:Default
	if (A_EventInfo == 4)
		Gui, DBG:Show
	return
}

statusBarSetText(t, p){
	Gui, Main:Default
	SB_SetText(t, p)
}

chanTabSwitcher(chn){
	chanTabSwitcher:
	Gui,Main:Submit,NoHide
	chn := !TabSwitch ? chn : TabSwitch  ;// If the tab was clicked by mouse use
	mainUser.curChan := chn              ;// TabSwitch var from Gui Tab
	input.2380(1)
	chatBuilder := user.chanLogs[chn]
	sc:=sci.hk().sc
	sci.hk().sc.2171(0)
	sci.hk().sc.2181(0,chatBuilder) ,sci.hk().sc.2160(sci.hk().sc.2006,sci.hk().sc.2006)
	sc.2160(sc.2006,sc.2006)
	sci.hk().sc.2171(1)

	GuiControl, Main: ChooseString, SysTabControl321, %chn%
	Gui, Main: Default
	LV_Delete()
	nicklist := user.getNickList(chn)
	Loop, Parse, nicklist, %A_Space%
		LV_Add("", A_LoopField)
	return
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

setSciColors(){
	static controlflow, commands, functions, directives, keysbuttons, variables, specialparams
	/*
    	db("setSciColors")
	    cd.2051(0, 0xFF0000)   // Spaces? #?
	    cd.2051(1, 0x00FF00)   // Comments
	    cd.2051(2, 0x0000ff)   // Numbers
	    cd.2051(3, 0xFF00FF)   // Strings
	    cd.2051(4, 0x55aa55)   // Punctuation
	    cd.2051(5, 0xaaaaaa)   // Plain text
	    cd.2051(6, 0xaaaaaa)   // Control Flow
	    cd.2051(7, 0xffaa00)   // Specialparams
	    cd.2051(8, 0xffaa00)   // Functions
	    cd.2051(9, 0xffaa00)   // Directives
	    cd.2051(10, 0xffaa00)  // Keybuttons
	    cd.2051(11, 0xffaa00)  // Multiline Comments
	    cd.2051(14, 0xffaa00)  // Variables
	    cd.2051(15, 0xffaa00)  // Escape Sequence
	*/

	;//SetKeywords
	for a,b in keywords()
		%a%:=b
	cd.4005(0,controlflow)
    cd.4005(1,commands)
    cd.4005(2,functions)
    cd.4005(3,directives)
    cd.4005(4,keysbuttons)
    cd.4005(5,variables)
    cd.4005(6,specialparams)
    cd.4005(7,userdefined)
    ;//Get colors from .ini file
	cd:=sci.hk().cd
	IniRead, bc, color_settings.ini, Background, 32, 0x343A39
	cd.2052(32,bc) ; Set background to black (32 is default)
	cd.2050              ; set fore/back function for text

	;//Set default colors
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
		nicklist:=user.getNickList(chn)
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
			sendMessage(control)
	}
}

getTime(){
	return "[" A_Hour ":" A_Min "]"
}

setCase(str,cas){
	if (cas == "u")
		StringUpper,str,str
	else if (cas == "l")
		StringLower,str,str
	return str
}

getRegexArgs(str, byref a1,byref a2,byref a3 = "",byref a4 = "",byref a5 = ""){
    RegexReplace(str, "\|\|", "", cnt)
    loop, %cnt%
        search.="(.*)\|\|"
    search .= "(.*)"
    RegexMatch(str, "^" search, a)
}

mb(x*){
	for a,b in x
	list.=b "`n"
	MsgBox,% trim(list,"`n")
}

tt(x*){
	for a,b in x
	list.=b "`n"
	ToolTip,% trim(list,"`n")
}

db(x*){
	for a,b in x
	list.=b "|"
	OutputDebug,% rTrim(list, "|")
}

var(x=""){
	static
	static list:=[]
	if !IsObject(x)
		return list[x]
	for a,b in x
	list[a]:=b
}

class user {
	static chanNicks:=[]
	static chanLogs:=[]

	__New(val){
		this.nick:=val
	}

	addChan(chn){
		static chans:=[],i:=1
		this.chans[i++]:=chn
		user.setNickList()
	}

	addCode(cod){
		static codes:=[],i:=1
		this.codes[i++]:=cod
	}

	setNickList(chn,lst,onk="",nnk=""){
		if (nnk)
		{
			for c in user.chanNicks
				for n in user.chanNicks[c]
					if (n == onk)
					{
						user.chanNicks[c].Remove(n)
						user.chanNicks[c,nnk]:=1
					}		
		}
		else
		{
			user.chanNicks.Remove(chn)  ;// Clear the channel to populate new list
			Loop, Parse, lst, %A_Space%
				user.chanNicks[chn,A_LoopField]:=1
		}
	}

    getNickList(chn){
    	for n in user.chanNicks[chn]
    		lst .= n " "
    	return trim(lst," ")
    }

    addMsgToLog(chn,msg){
    	user.chanLogs[chn] .= msg "`n"
    }
} ;

;//On CodeGui close
    CodeGuiClose:
    CodeWin:
	cd.2400
	if (x := !x)
		Gui, Code:Show
	else
		Gui, Code:Hide
    return

;==== For DEBUGGING ONLY 
~*Esc::
;==== End DEBUG

;//ExitRoutine
	MainGuiClose:
	ExitRoutine:
	;//WS_CloseSocket(client)
	WS_Shutdown()
	ExitApp
