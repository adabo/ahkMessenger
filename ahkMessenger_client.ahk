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
    hwnd := WinExist(), sci := new scintilla(hwnd, 10,0,400,200, "", a_scriptdir "\lib"), setup_Scintilla(sci, NickName)
	Gui, CltMain: Add, ListView, x420 y6 w120 h198 -Hdr -Multi, Icon|Users
	Gui, CltMain: Add, Edit, x10 y210 w530 -WantReturn vGuiMessage -0x100
	Gui, CltMain: Add, Button, x10 Default gSendMessage, Send
	Gui, CltMain: Add, Button, x10 xp40 yp gCodeWin, Code

	Gui, CltCode: Default
	Gui, CltCode: Font, s10, Lucida Console
	Gui, CltCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
	Gui, CltCode: Add, ListView, x420 y8 w140 h400 -Hdr -Multi gListViewNotifications, Icon|Users
	ImageListID := IL_Create(2)
	LV_SetImageList(ImageListID)
	IL_Add(ImageListID, "shell32.dll", 71)
	IL_Add(ImageListID, "shell32.dll", 291)
	Gui, CltCode: Font, s8, Tahoma
	Gui, CltCode: Add, Button, x10 gSendCode, Send ;Sends to server

	Gui, CltMain: Show

; Initialize
	;WS_LOGTOCONSOLE := 1
	WS_Startup()
    
; Port/Socket setup
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, "127.0.0.1", "12345")
	WS_HandleEvents(client, "READ")
	WS_Send(client, "USRN||" . NickName)
return

CodeWin:
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

    sci.SetWrapMode("SC_WRAP_WORD"), sci.SetMarginWidthN("SC_MARGIN_NUMBER", 0), sci.SetLexer(2)
    sci.StyleSetBold("STYLE_DEFAULT", true), sci.StyleClearAll()
    
    sci.SetKeywords(0,localNick)

    sci.StyleSetFore(0,0x000000), sci.StyleSetBold(0, false)    ; SCE_MSG_DEFAULT
    sci.StyleSetFore(1,0xFF0000)                                ; SCE_MSG_LOCALNICK
    sci.StyleSetFore(2,0x0000FF)                                ; SCE_MSG_OTHERNICK
    sci.StyleSetFore(3,0x0E0E0E), sci.StyleSetBold(3, false)    ; SCE_MSG_INFOMESSAGE
    
    return 0
}

CltMainGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
