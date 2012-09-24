/*
Title: AHK Messenger
Author: adabo, RaptorX

	Legend:
		MESG|| = Message
		NWCD|| = New code
		USRN|| = User name
		RQST|| = Request Code
		USLS|| = User list
*/

#include <ws>
#include <SCI>
#singleinstance force

NickName := A_UserName
OnExit, ExitRoutine

; GUI

    Gui, CltMain: +LastFound
    hwnd := WinExist(), sci := {} ; Scintilla Editor Array
    sci[1] := new scintilla(hwnd, 10,0,400,200, "", a_scriptdir "\lib")
    
	Gui, CltMain: Add, ListView, x420 y6 w120 h198 -Hdr -Multi, Icon|Users
	Gui, CltMain: Add, Edit, x10 y210 w530 -WantReturn vGuiMessage -0x100
	Gui, CltMain: Add, Button, x10 Default gSendMessage, Send
	Gui, CltMain: Add, Button, x10 xp40 yp gCodeWin, Code

	Gui, CltCode: Default
	Gui, CltCode: +LastFound
    hwnd := WinExist(), sci[2] := new scintilla(hwnd, 0,0,400,400,"hidden", a_scriptdir "\lib") 
    
	Gui, CltCode: Font, s10, Lucida Console
	; Gui, CltCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
	Gui, CltCode: Add, ListView, x420 y8 w140 h400 -Hdr -Multi gListViewNotifications, Icon|Users
	ImageListID := IL_Create(2)
	LV_SetImageList(ImageListID)
	IL_Add(ImageListID, "shell32.dll", 71)
	IL_Add(ImageListID, "shell32.dll", 291)
	Gui, CltCode: Font, s8, Tahoma
	Gui, CltCode: Add, Button, x10 y410 gSendCode, Send ;Sends to server

    setup_Scintilla(sci, NickName)
	Gui, CltMain: Show

; Initialize
	;WS_LOGTOCONSOLE := 1
	WS_Startup()
    
; Port/Socket setup
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, "99.23.4.199", "12345")
	WS_HandleEvents(client, "READ")
	WS_Send(client, "USRN||" . NickName)
return

CodeWin:
    Control,Show,,, % "ahk_id " sci[2].hwnd
	Gui, CltCode: Show
return

SendMessage:
	Gui, CltMain:Submit, NoHide
	if (!GuiMessage)
		return
	WS_Send(client, "MESG||" . NickName . ": " . GuiMessage)
	GuiControl, CltMain:, GuiMessage
return

SendCode:
	Gui, CltCode: Submit, NoHide
	WS_Send(client, "NWCD||" . GuiCode)
return

ListViewNotifications:
	if (A_GuiEvent == "DoubleClick")
	{
		Gui, CltCode: Default
		rowNum := LV_GetNext(0, "Focused")
		LV_GetText(reqUserName, rowNum, 2)
		WS_Send(client, "RQST||" . reqUserName)
	}
return

WS_OnRead(socket){
	Global sci, CodeID, NickName, nickList
	static firstVist
	
	WS_Recv(socket, ServerMessage)

    msgType :=  SubStr(ServerMessage, 1 , 6)
    StringTrimLeft, ServerMessage, ServerMessage, 6

    if (msgTYpe == "USLS||")
    {
    	Gui, CltMain: Default
    	Loop, Parse, ServerMessage, %A_Space%
			LV_Add("" ,"", A_LoopField) ;The username
        StringReplace, nickList, ServerMessage, %NickName%%a_space%,,A
        sci.SetKeywords(1,nickList)
    }
	else if (msgType == "CODE||")
	{
		Gui, CltCode: Default
		RegexMatch(ServerMessage, "^(.+?)\|\|", match)
		StringTrimLeft, ServerMessage, ServerMessage, strLen(match1) + 2 ;Get requested name from message

;============== check if name exist in listview ===================;
		while (match1 != rowText)
		{
    		LV_GetText(rowText, A_Index, 2)
    		if (match1 == rowText) ;Compare username from message to name in listview
    			LV_Modify(A_Index, "Icon" . 3)
    	}
		LV_ModifyCol(1)
;===================================================================;

	GuiControl, CltCode:, %CodeID%, %ServerMessage%
	}
	else if (msgType == "MESG||")
	{
    	sci.AddText(strLen(str:=ServerMessage "`n"), str), sci.ScrollCaret()
	}
	else if (msgType == "NWCD||")
	{
    	Gui, CltCode: Default
		if (ServerMessage == NickName) ;Do not add icon to Own Nickname
		{
			if (!firstVist)
			{
				LV_Add("Icon" . 0, "", ServerMessage) ;The username
				LV_ModifyCol(1)
				firstVist++
			}
			return
		}

;============== check if name exist in listview ===================;
    	loop % LV_GetCount()
    	{
    		LV_GetText(rowText, A_Index, 2)
    		if (ServerMessage == rowText)
    		{
    			namExist := True
    			LV_Modify(A_Index, "Icon" . 1, "")
    			break
    		}
    		else
    			namExist := False
    	}
    	if (!namExist)
			LV_Add("Icon" . 1, "", ServerMessage)
;===================================================================;

		LV_ModifyCol(1)
	}
	else if (msgType == "DISC||")
	{
		Gui, CltMain: Default
		loop % LV_GetCount()
		{
			LV_GetText(nm, A_Index, 2)
				if (nm == ServerMessage)
					lV_Delete(A_Index)
		}
	}
}

setup_Scintilla(sci, localNick=""){

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
    sci[2].SetWrapMode("SC_WRAP_WORD"), sci[2].SetMarginWidthN(0, 40), sci[2].SetMarginWidthN(1, 0), sci[2].SetLexer(3)
    sci[2].StyleSetBold("STYLE_DEFAULT", true), sci[2].StyleClearAll()
    
    
    sci[2].SetKeywords(0,"controlflow")
    sci[2].SetKeywords(1,"commands")
    sci[2].SetKeywords(2,"functions")
    sci[2].SetKeywords(3,"directives")
    sci[2].SetKeywords(4,"keysbuttons")
    sci[2].SetKeywords(5,"variables")
    sci[2].SetKeywords(6,"specialparams")
    sci[2].SetKeywords(7,"userdefined")
    
    sci[2].StyleSetBold("STYLE_LINENUMBER", false)
    
    sci[2].StyleSetFore(0,0x000000), sci[2].StyleSetBold(0, false)      ; SCE_AHK_DEFAULT
    sci[2].StyleSetFore(1,0x00FF00)                                     ; SCE_AHK_COMMENTLINE
    sci[2].StyleSetFore(2,0x00FF00)                                     ; SCE_AHK_COMMENTBLOCK
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
    sci[2].StyleSetFore(17,0x0000FF)                                    ; SCE_AHK_WORD_SP
    sci[2].StyleSetFore(18,0x00F000)                                    ; SCE_AHK_WORD_UD
    sci[2].StyleSetFore(19,0xFF9000)                                    ; SCE_AHK_VARREFKW
    sci[2].StyleSetFore(20,0xFF0000)                                    ; SCE_AHK_ERROR
    
    ;}
    return 0
}

CltMainGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
