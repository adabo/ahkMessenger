CreateClientGui(){
    global

    Gui, CltMain: +LastFound
    sci := {} ; Scintilla Editor Array
    hwnd := WinExist(), sci[1] := new scintilla(hwnd, 10,0,400,200, "", a_scriptdir "\lib")

    Gui, CltMain: Add, ListView, x420 y6 w120 h198 -Hdr -Multi, Icon|Users
    Gui, CltMain: Add, Edit, x10 y210 w530 -WantReturn vGuiMessage -0x100
    Gui, CltMain: Add, Button, x10 yp30 Default gcSendMessage, Send
    Gui, CltMain: Add, Button, x10 xp40 yp gcCodeWin, Code
    Gui, CltMain: Add, GroupBox, xp46 yp-6 w444
    Gui, CltMain: Add, Text, x108 y260, Nickname:
    Gui, CltMain: Add, Edit, xp56 yp-2 w100 vcEdNick, Guest%A_TickCount%
    Gui, CltMain: Add, Text, xp140 y260, Server:
    Gui, CltMain: Add, Edit, xp50 yp-2 w100 vcEdServIP Disabled, 99.23.4.199
    Gui, CltMain: Add, Button, xp118 yp4 gcConnectToServer, Connect  
    Gui, CltMain: Add, CheckBox, xp yp-18 gcDisableIP vTest Checked1 , Test

    Gui, CltCode: Default
    Gui, CltCode: +LastFound
    hwnd := WinExist(), sci[2] := new scintilla(hwnd, 0,0,400,400,"", a_scriptdir "\lib") 

    Gui, CltCode: Font, s10, Lucida Console
    ; Gui, CltCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
    Gui, CltCode: Add, ListView, x420 y8 w140 h400 -Hdr -Multi gcListViewNotifications, Icon|Users
    ImageListID := IL_Create(2)
    LV_SetImageList(ImageListID)
    IL_Add(ImageListID, "shell32.dll", 71)
    IL_Add(ImageListID, "shell32.dll", 291)
    Gui, CltCode: Font, s8, Tahoma
    Gui, CltCode: Add, Button, x10 y410 gcSendCode, Send ;Sends to server

    setup_Scintilla(sci, NickName)
    Gui, CltMain:Show
    Pause, On

    cConnectToServer:
        Pause, Off
        Gui, CltMain: Submit, NoHide
        Nickname := cEdNick
    return

    cDisableIP:
        Gui, CltMain: Submit, NoHide
        if (test)
            GuiControl, CltMain: Disable, cEdServIP
         else
             GuiControl, CltMain: Enable, cEdServIP
    return

    cCodeWin:
        Gui, CltCode: Show
    return

    cSendMessage:
        Gui, CltMain:Submit, NoHide
        if (!GuiMessage)
            return
        WS_Send(client, "MESG||" . NickName . ": " . GuiMessage)
        GuiControl, CltMain:, GuiMessage
    return

    cSendCode:
        sci[2].GetText(sci[2].GetLength()+1, GuiCode)
        WS_Send(client, "NWCD||" . GuiCode)
    return

    cListViewNotifications:
        if (A_GuiEvent == "DoubleClick")
        {
            Gui, CltCode: Default
            rowNum := LV_GetNext(0, "Focused")
            LV_GetText(reqUserName, rowNum, 2)
            WS_Send(client, "RQST||" . reqUserName)
        }
    return
}

CreateServerGui(){
    global

    Gui, ServMain: +LastFound
    sci := {} ; Scintilla Editor Array
    hwnd := WinExist(), sci[1] := new scintilla(hwnd, 10,0,400,200, "", a_scriptdir "\lib")
    
    Gui, ServMain: Add, ListView, x420 y6 w120 h198 -Hdr -Multi, Icon|Users
	Gui, ServMain: Add, Edit, x10 y210 w530 -WantReturn vGuiMessage -0x100
	Gui, ServMain: Add, Button, x10 yp30 Default gsSendMessage, Send
	Gui, ServMain: Add, Button, x10 xp40 yp gsCodeWin, Code
    Gui, ServMain: Add, GroupBox, xp46 yp-6 w444
    Gui, ServMain: Add, Text, x108 y260, Nickname:
    Gui, ServMain: Add, Edit, xp56 yp-2 w100 vsEdNick, Server
    Gui, ServMain: Add, Text, xp140 y260, Server:
    Gui, ServMain: Add, Edit, xp50 yp-2 w100 -Number vsEdServIP, 0.0.0.0
    ;Gui, ServMain: Add, Button, xp128 yp-2 gsConnectToServer, Connect
	
	Gui, ServCode: Default
    Gui, ServCode: +LastFound
    hwnd := WinExist(), sci[2] := new scintilla(hwnd, 0,0,400,400,"", a_scriptdir "\lib")
    
	Gui, ServCode: Font, s10, Lucida Console
	; Gui, ServCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
	Gui, ServCode: Add, ListView, x420 y8 w140 h400 -Hdr -Multi gsListViewNotifications, Icon|Users
	ImageListID := IL_Create(2)
	LV_SetImageList(ImageListID)
	IL_Add(ImageListID, "shell32.dll", 71)
	IL_Add(ImageListID, "shell32.dll", 291)

	Gui, ServCode: Font, s8, Tahoma
	Gui, ServCode: Add, Button, x10 y410 gsSendCode, Send ;Sends to server

    setup_Scintilla(sci, NickName)
    Gui, ServMain: Submit, NoHide
    Gui, ServMain:Show
    return
    
    sSendMessage:
    	Gui, ServMain: Submit, NoHide
    	if (!GuiMessage)
    		return
    	for key, value in NewConnection
    		if (NewConnection[key] != 999)
    			WS_Send(NewConnection[key], "MESG||" . NickName . ": " . GuiMessage)
        sci[1].AddText(strLen(str:=NickName ": " GuiMessage "`n"), str), sci[1].ScrollCaret()
    	GuiControl, ServMain:, GuiMessage
    return

    sCodeWin:
        Gui, ServCode: Show
    return

    sSendCode:
        sci[2].GetText(sci[2].GetLength()+1, GuiCode)
        userCodes[serverIP] := GuiCode
        Gui, ServCode: Default

        LV_ModifyCol(1)
        if(!firstVisit)
        {
            LV_Add("Icon" . 3, "", NickName)
            LV_ModifyCol(1)
            firstVisit++
        }

        for key, value in NewConnection
            if (NewConnection[key] != 999)
                WS_Send(NewConnection[key], "NWCD||" . NickName)
    return

    sListViewNotifications:
        if (A_GuiEvent == "DoubleClick") ;Request code from server with user name
        {
            Gui, ServCode: Default
            LV_GetText(rowText, A_EventInfo, 2)
            skt := userName[rowText]            
            sci[2].ClearAll(), sci[2].AddText(strLen(str:=userCodes[skt]), str), sci[2].ScrollCaret()
            LV_Modify(A_EventInfo, "Icon" . 0)
        }
    return
}

setup_Scintilla(sci, localNick=""){

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
    
    ;{ sci[1] Configuration
    sci[1].SetWrapMode("SC_WRAP_WORD"), sci[1].SetMarginWidthN(1, 0), sci[1].SetLexer(2)
    sci[1].StyleSetBold("STYLE_DEFAULT", true), sci[1].StyleClearAll()
    
    sci[1].SetKeywords(0,localNick)

    sci[1].StyleSetFore(0,0x000000), sci[1].StyleSetBold(0, false)      ; SCE_MSG_DEFAULT
    sci[1].StyleSetFore(1,0xFF0000)                                     ; SCE_MSG_LOCALNICK
    sci[1].StyleSetFore(2,0x0000FF)                                     ; SCE_MSG_OTHERNICK
    sci[1].StyleSetFore(3,0x0E0E0E), sci[1].StyleSetBold(3, false)      ; SCE_MSG_INFOMESSAGE
    ;}
    
    ;{ sci[2] Configuration
    sci[2].SetWrapMode("SC_WRAP_WORD"), sci[2].SetMarginWidthN(0, 40), sci[2].SetMarginWidthN(1, 16), sci[2].SetLexer(3)
    sci[2].StyleSetBold("STYLE_DEFAULT", true), sci[2].StyleClearAll()
    
    ; Change this in to a loop
    sci[2].SetKeywords(0,controlflow)
    sci[2].SetKeywords(1,commands)
    sci[2].SetKeywords(2,functions)
    sci[2].SetKeywords(3,directives)
    sci[2].SetKeywords(4,keysbuttons)
    sci[2].SetKeywords(5,variables)
    sci[2].SetKeywords(6,specialparams)
    sci[2].SetKeywords(7,userdefined)
    
    sci[2].StyleSetBold("STYLE_LINENUMBER", false)
    
    ; Change this in to a loop
    sci[2].StyleSetFore(0,0x000000), sci[2].StyleSetBold(0, false)      ; SCE_AHK_DEFAULT
    sci[2].StyleSetFore(1,0x009900), sci[2].StyleSetBold(1, false)      ; SCE_AHK_COMMENTLINE
    sci[2].StyleSetFore(2,0x009900), sci[2].StyleSetBold(2, false)      ; SCE_AHK_COMMENTBLOCK
    sci[2].StyleSetFore(3,0xFF0000)                                     ; SCE_AHK_ESCAPE
    sci[2].StyleSetFore(4,0x000080), sci[2].StyleSetBold(4, false)      ; SCE_AHK_SYNOPERATOR
    sci[2].StyleSetFore(5,0x000080), sci[2].StyleSetBold(5, false)      ; SCE_AHK_EXPOPERATOR
    sci[2].StyleSetFore(6,0xA2A2A2), sci[2].StyleSetBold(6, false)      ; SCE_AHK_STRING
    sci[2].StyleSetFore(7,0xFF9000), sci[2].StyleSetBold(7, false)      ; SCE_AHK_NUMBER
    sci[2].StyleSetFore(8,0xFF9000), sci[2].StyleSetBold(8, false)      ; SCE_AHK_IDENTIFIER
    sci[2].StyleSetFore(9,0XFF9000), sci[2].StyleSetBold(9, false)      ; SCE_AHK_VARREF
    sci[2].StyleSetFore(10,0x0000FF)                                    ; SCE_AHK_LABEL
    sci[2].StyleSetFore(11,0x0000FF)                                    ; SCE_AHK_WORD_CF
    sci[2].StyleSetFore(12,0x0000FF)                                    ; SCE_AHK_WORD_CMD
    sci[2].StyleSetFore(13,0xFF0090)                                    ; SCE_AHK_WORD_FN
    sci[2].StyleSetFore(14,0xA50000)                                    ; SCE_AHK_WORD_DIR
    sci[2].StyleSetFore(15,0xA2A2A2),sci[2].StyleSetItalic(15, true)    ; SCE_AHK_WORD_KB
    sci[2].StyleSetFore(16,0xFF9000)                                    ; SCE_AHK_WORD_VAR
    sci[2].StyleSetFore(17,0x0000FF), sci[2].StyleSetBold(17, false)    ; SCE_AHK_WORD_SP
    sci[2].StyleSetFore(18,0x00F000)                                    ; SCE_AHK_WORD_UD
    sci[2].StyleSetFore(19,0xFF9000)                                    ; SCE_AHK_VARREFKW
    sci[2].StyleSetFore(20,0xFF0000)                                    ; SCE_AHK_ERROR
    
    ;}
    
    return  controlflow := commands := functions := directives := keysbuttons := variables := specialparams := ""
}