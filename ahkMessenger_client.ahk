/*
Title: AHK Messenger
Author: adabo, RaptorX
*/

#include <ws>
#include <SCI>
#singleinstance force

NickName := A_UserName
OnExit, ExitRoutine

; GUI

    Gui, CltMain: +LastFound
    hwnd := WinExist(), sci := new scintilla(hwnd, 10,0,200,200, "", a_scriptdir "\lib"), setup_Scintilla(sci)
    
	Gui, CltMain: Add, Edit, y210 w200 -WantReturn vGuiMessage -0x100
	Gui, CltMain: Add, Button, Default gSendMessage, Send
	Gui, CltMain: Add, Button, gCodeWin, Code

	Gui, CltCode: Font, s10, Lucida Console
	Gui, CltCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
	Gui, CltCode: Font, s8, Tahoma
	Gui, CltCode: Add, Button, gSendCode, Send ;Sends to server
	Gui, CltCode: Add, Button, gRequestCode, Request ;Request other clients code from server

	Gui, CltMain: Show

; Initialize
	;WS_LOGTOCONSOLE := 1
	WS_Startup()

; Port/Socket setup
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, "127.0.0.1", "12345")
	WS_HandleEvents(client, "READ")
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
	WS_Send(client, "CODE||" . GuiCode)
return

RequestCode:
	WS_Send(client, "RQST||")
return

WS_OnRead(socket){
	Global sci, CodeID
	
	WS_Recv(socket, ServerMessage)

    msgType :=  SubStr(ServerMessage, 1 , 6)
    StringTrimLeft, ServerMessage, ServerMessage, 6

	if (msgType == "CODE||")
	{
		GuiControl, CltCode:, %CodeID%, %ServerMessage%
	}
	else if (msgType == "MESG||")
	{
    	sci.AddText(strLen(str:="`n" ServerMessage), str), sci.ScrollCaret()
	}
	

}

setup_Scintilla(sci){
    sci.SetWrapMode("SC_WRAP_WORD"), sci.SetMarginWidthN("SC_MARGIN_NUMBER", 0)
}

/*
CltMainGuiSize:
    GuiControl, MoveDraw, %LogID%, % "w"A_GuiWidth - 20 "h"A_GuiHeight - 80
    GuiControl, MoveDraw, %MsgID%, % "y"A_GuiHeight - 60 "w"A_GuiWidth - 20
    GuiControl, MoveDraw, %SendID%, % "y"A_GuiHeight - 24
return

CltCodeGuiClose:
	Gui, CltCode: Hide
return
*/

CltMainGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
