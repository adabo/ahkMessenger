OnExit, ExitRoutine
#singleinstance force

; Variables
test := 1

; GUI
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

createGUI(){
	global MsgInput, EChLog, MainWin, TabSwitch

	static controlflow, commands, functions, directives, keysbuttons, variables, specialparams
    controlflow =
    (
        break continue else exit exitapp gosub goto loop onexit pause repeat return settimer sleep suspend
        static global local byref while until for
    )
    commands =
    (
        autotrim blockinput clipwait control controlclick controlfocus controlget controlgetfocus
        controlgetpos controlgettext controlmove controlsend controlsendraw controlsettext coordmode
        critical detecthiddentext detecthiddenwindows drive driveget drivespacefree edit endrepeat envadd
        envdiv envget envmult envset envsub envupdate fileappend filecopy filecopydir filecreatedir
        filecreateshortcut filedelete filegetattrib filegetshortcut filegetsize filegettime filegetversion
        fileinstall filemove filemovedir fileread filereadline filerecycle filerecycleempty fileremovedir
        fileselectfile fileselectfolder filesetattrib filesettime formattime getkeystate groupactivate
        groupadd groupclose groupdeactivate gui guicontrol guicontrolget hideautoitwin hotkey if ifequal
        ifexist ifgreater ifgreaterorequal ifinstring ifless iflessorequal ifmsgbox ifnotequal ifnotexist
        ifnotinstring ifwinactive ifwinexist ifwinnotactive ifwinnotexist imagesearch inidelete iniread
        iniwrite input inputbox keyhistory keywait listhotkeys listlines listvars menu mouseclick
        mouseclickdrag mousegetpos mousemove msgbox outputdebug pixelgetcolor pixelsearch postmessage
        process progress random regdelete regread regwrite reload run runas runwait send sendevent
        sendinput sendmessage sendmode sendplay sendraw setbatchlines setcapslockstate setcontroldelay
        setdefaultmousespeed setenv setformat setkeydelay setmousedelay setnumlockstate setscrolllockstate
        setstorecapslockmode settitlematchmode setwindelay setworkingdir shutdown sort soundbeep soundget
        soundgetwavevolume soundplay soundset soundsetwavevolume splashimage splashtextoff splashtexton
        splitpath statusbargettext statusbarwait stringcasesense stringgetpos stringleft stringlen
        stringlower stringmid stringreplace stringright stringsplit stringtrimleft stringtrimright
        stringupper sysget thread tooltip transform traytip urldownloadtofile winactivate
        winactivatebottom winclose winget wingetactivestats wingetactivetitle wingetclass wingetpos
        wingettext wingettitle winhide winkill winmaximize winmenuselectitem winminimize winminimizeall
        winminimizeallundo winmove winrestore winset winsettitle winshow winwait winwaitactive
        winwaitclose winwaitnotactive fileencoding
    )
    functions =
    (
        abs acos asc asin atan ceil chr cos dllcall exp fileexist floor getkeystate numget numput
        registercallback il_add il_create il_destroy instr islabel isfunc ln log lv_add lv_delete
        lv_deletecol lv_getcount lv_getnext lv_gettext lv_insert lv_insertcol lv_modify lv_modifycol
        lv_setimagelist mod onmessage round regexmatch regexreplace sb_seticon sb_setparts sb_settext sin
        sqrt strlen substr tan tv_add tv_delete tv_getchild tv_getcount tv_getnext tv_get tv_getparent
        tv_getprev tv_getselection tv_gettext tv_modify varsetcapacity winactive winexist trim ltrim rtrim
        fileopen strget strput object isobject objinsert objremove objminindex objmaxindex objsetcapacity
        objgetcapacity objgetaddress objnewenum objaddref objrelease objclone _insert _remove _minindex
        _maxindex _setcapacity _getcapacity _getaddress _newenum _addref _release _clone comobjcreate
        comobjget comobjconnect comobjerror comobjactive comobjenwrap comobjunwrap comobjparameter
        comobjmissing comobjtype comobjvalue comobjarray
    )
    directives =
    (
        allowsamelinecomments clipboardtimeout commentflag errorstdout escapechar hotkeyinterval
        hotkeymodifiertimeout hotstring if iftimeout ifwinactive ifwinexist include includeagain
        installkeybdhook installmousehook keyhistory ltrim maxhotkeysperinterval maxmem maxthreads
        maxthreadsbuffer maxthreadsperhotkey menumaskkey noenv notrayicon persistent singleinstance
        usehook warn winactivateforce
    )
    keysbuttons =
    ( 
        shift lshift rshift alt lalt ralt control lcontrol rcontrol ctrl lctrl rctrl lwin rwin appskey
        altdown altup shiftdown shiftup ctrldown ctrlup lwindown lwinup rwindown rwinup lbutton rbutton
        mbutton wheelup wheeldown xbutton1 xbutton2 joy1 joy2 joy3 joy4 joy5 joy6 joy7 joy8 joy9 joy10
        joy11 joy12 joy13 joy14 joy15 joy16 joy17 joy18 joy19 joy20 joy21 joy22 joy23 joy24 joy25 joy26
        joy27 joy28 joy29 joy30 joy31 joy32 joyx joyy joyz joyr joyu joyv joypov joyname joybuttons
        joyaxes joyinfo space tab enter escape esc backspace bs delete del insert ins pgup pgdn home end
        up down left right printscreen ctrlbreak pause scrolllock capslock numlock numpad0 numpad1 numpad2
        numpad3 numpad4 numpad5 numpad6 numpad7 numpad8 numpad9 numpadmult numpadadd numpadsub numpaddiv
        numpaddot numpaddel numpadins numpadclear numpadup numpaddown numpadleft numpadright numpadhome
        numpadend numpadpgup numpadpgdn numpadenter f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16
        f17 f18 f19 f20 f21 f22 f23 f24 browser_back browser_forward browser_refresh browser_stop
        browser_search browser_favorites browser_home volume_mute volume_down volume_up media_next
        media_prev media_stop media_play_pause launch_mail launch_media launch_app1 launch_app2 blind
        click raw wheelleft wheelright
    )
    variables =
    ( 
        a_ahkpath a_ahkversion a_appdata a_appdatacommon a_autotrim a_batchlines a_caretx a_carety
        a_computername a_controldelay a_cursor a_dd a_ddd a_dddd a_defaultmousespeed a_desktop
        a_desktopcommon a_detecthiddentext a_detecthiddenwindows a_endchar a_eventinfo a_exitreason
        a_formatfloat a_formatinteger a_gui a_guievent a_guicontrol a_guicontrolevent a_guiheight
        a_guiwidth a_guix a_guiy a_hour a_iconfile a_iconhidden a_iconnumber a_icontip a_index
        a_ipaddress1 a_ipaddress2 a_ipaddress3 a_ipaddress4 a_isadmin a_iscompiled a_issuspended
        a_keydelay a_language a_lasterror a_linefile a_linenumber a_loopfield a_loopfileattrib
        a_loopfiledir a_loopfileext a_loopfilefullpath a_loopfilelongpath a_loopfilename
        a_loopfileshortname a_loopfileshortpath a_loopfilesize a_loopfilesizekb a_loopfilesizemb
        a_loopfiletimeaccessed a_loopfiletimecreated a_loopfiletimemodified a_loopreadline a_loopregkey
        a_loopregname a_loopregsubkey a_loopregtimemodified a_loopregtype a_mday a_min a_mm a_mmm a_mmmm
        a_mon a_mousedelay a_msec a_mydocuments a_now a_nowutc a_numbatchlines a_ostype a_osversion
        a_priorhotkey a_programfiles a_programs a_programscommon a_screenheight a_screenwidth a_scriptdir
        a_scriptfullpath a_scriptname a_sec a_space a_startmenu a_startmenucommon a_startup
        a_startupcommon a_stringcasesense a_tab a_temp a_thishotkey a_thismenu a_thismenuitem
        a_thismenuitempos a_tickcount a_timeidle a_timeidlephysical a_timesincepriorhotkey
        a_timesincethishotkey a_titlematchmode a_titlematchmodespeed a_username a_wday a_windelay a_windir
        a_workingdir a_yday a_year a_yweek a_yyyy clipboard clipboardall comspec errorlevel programfiles
        true false a_thisfunc a_thislabel a_ispaused a_iscritical a_isunicode a_ptrsize
    )
    specialparams =
    (
        ltrim rtrim join ahk_id ahk_pid ahk_class ahk_group processname minmax controllist statuscd
        filesystem setlabel alwaysontop mainwindow nomainwindow useerrorlevel altsubmit hscroll vscroll
        imagelist wantctrla wantf2 vis visfirst wantreturn backgroundtrans minimizebox maximizebox sysmenu
        toolwindow exstyle check3 checkedgray readonly notab lastfound lastfoundexist alttab shiftalttab
        alttabmenu alttabandmenu alttabmenudismiss controllisthwnd hwnd deref pow bitnot bitand bitor
        bitxor bitshiftleft bitshiftright sendandmouse mousemove mousemoveoff hkey_local_machine
        hkey_users hkey_current_user hkey_classes_root hkey_current_config hklm hku hkcu hkcr hkcc reg_sz
        reg_expand_sz reg_multi_sz reg_dword reg_qword reg_binary reg_link reg_resource_list
        reg_full_resource_descriptor caret reg_resource_requirements_list reg_dword_big_endian regex pixel
        mouse screen relative rgb low belownormal normal abovenormal high realtime between contains in is
        integer float number digit xdigit alpha upper lower alnum time date not or and topmost top bottom
        transparent transcolor redraw region id idlast count list capacity eject lock unlock label serial
        type status seconds minutes hours days read parse logoff close error single shutdown menu exit
        reload tray add rename check uncheck togglecheck enable disable toggleenable default nodefault
        standard nostandard color delete deleteall icon noicon tip click show edit progress hotkey text
        picture pic groupbox button checkbox radio dropdownlist ddl combobox statusbar treeview listbox
        listview datetime monthcal updown slider tab tab2 iconsmall tile report sortdesc nosort nosorthdr
        grid hdr autosize range xm ym ys xs xp yp font resize owner submit nohide minimize maximize
        restore noactivate na cancel destroy center margin owndialogs guiescape guiclose guisize
        guicontextmenu guidropfiles tabstop section wrap border top bottom buttons expand first lines
        number uppercase lowercase limit password multi group background bold italic strike underline norm
        theme caption delimiter flash style checked password hidden left right center section move focus
        hide choose choosestring text pos enabled disabled visible notimers interrupt priority waitclose
        unicode tocodepage fromcodepage yes no ok cancel abort retry ignore force on off all send wanttab
        monitorcount monitorprimary monitorname monitorworkarea pid base useunsetlocal useunsetglobal
        localsameasglobal
    )

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

	Gui, Code:+Resize +HwndCdWn
	Hotkey, IfWinActive, ahk_id%MainWin%
	Hotkey, ^Tab, HKTabSwitch, On
	Hotkey, F6, CodeWin, On
	Hotkey, IfWinActive, ahk_id%CdWn%
	Hotkey, F6, CodeWin, On
	cd := new sci(CdWn,"cd",5,5,500,500)
	cd.4006(0,"asm")
	cd.2242(0,24)
	cd.2242(1,0)
	;//cd.2181(0,specialparams)

	cd.2051(0, 0xFF0000)  ;// Spaces? #?
	cd.2051(1, 0x00FF00)  ;// Comments
	cd.2051(2, 0x0000ff)  ;// Numbers
	cd.2051(3, 0xFF00FF)  ;// Strings
	cd.2051(4, 0x55aa55)  ;// Punctuation
	cd.2051(5, 0xaa55aa)  ;// Plain text
	cd.2051(6, 0xaaaaaa)  ;// Control Flow
	cd.2051(7, 0xffaa00)  ;// Specialparams
	cd.2051(8, 0xffaa00)  ;// Funcions
	cd.2051(9, 0xffaa00)  ;// Directives
	cd.2051(10, 0xffaa00) ;// Keybuttons
	cd.2051(11, 0xffaa00) ;// Multline Comments
	cd.2051(14, 0xffaa00) ;// Variables
	cd.2051(15, 0xffaa00) ;// Escape Sequence

	cd.4005(0,controlflow)
    cd.4005(1,commands)
    cd.4005(2,functions)
    cd.4005(3,directives)
    cd.4005(4,keysbuttons)
    cd.4005(5,variables)
    cd.4005(6,specialparams)
    cd.4005(7,userdefined)
	
	Gui, Code:Add, Button, x420 y520 w70 h30 HwndBSub, Submit
	Gui, Code:Add, Button, x5 y520 w70 h30 HwndBCol gColorSelect, Select Color
	
	
	attach(cd.hwnd, "w h r")
	Attach(sc.hwnd, "w h r")
	Attach(BSub, "x y")
    Attach(LNkL, "x h")
    Attach(GGbx, "w y")
    Attach(BCon, "x y")
    Attach(BCol, "x y")
    Attach(TTSw, "w h")
    return

    ColorSelect:
		s := sci.hk().cd
		var := s.2010(s.2008)
		c := Dlg_Color(s.2481(var))
		s.2051(var,c)
    return

    CodeGuiClose:
    CodeWin:
    	x := !x
    	if (x)
    		Gui, Code:Show, w550 h550
    	else
    		Gui, Code:Hide
    return
}

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
; //(Control HWND, string message)
setChatLog(hwn, a, b, c, d, e){
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
			RegExMatch(e,"i)(" clientnick ")",name),
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
	global MsgInput, client, CLIENTNICK, CURRENTCHAN, CLIENTCHANS, ALLCHANLOGS
	SendMessage:
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

;F7::
;return

F3::
s := sci.hk().cd
var := s.2010(s.2008)
c := Dlg_Color(s.2481(var))
s.2051(var,c)
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
notify(a,b,c,d){
	Critical
	global client,	chansNicks
	if A_Gui not in main
	return
	control:=NumGet(b+0)
	if !s:=sci.hk(control)
	return
	code:=NumGet(b+8),cp:=s.2008,scpos:=NumGet(b+12)
	if (code=2001){
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
#Include lib\ws.ahk
#Include lib\attach.ahk
#include wrapper
