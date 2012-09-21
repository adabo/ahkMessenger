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

    Gui, Client: +LastFound
    hwnd := WinExist(), sci := new scintilla(hwnd, 10,0,200,200, "", "", a_scriptdir "\lib"), setup_Scintilla(sci)
    
	Gui, Client: Add, Edit, y210 w200 -WantReturn vGuiMessage -0x100
	Gui, Client: Add, Button, Default gSendMessage, Send

	Gui, Client: Show

; Initialize
	WS_LOGTOCONSOLE := 1
	WS_Startup()

; Port/Socket setup
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, "99.23.4.199", "12345")
	WS_HandleEvents(client, "READ")
return

SendMessage:
	Gui, Client:Submit, NoHide
	if (!GuiMessage)
		return
	WS_Send(client, NickName . ": " . GuiMessage)
	GuiControl, Client:, GuiMessage
return

WS_OnRead(socket){
	Global sci
	WS_Recv(socket, ServerMessage)
    sci.AddText(strLen(str:="`n" ServerMessage), str), sci.ScrollCaret()
}

setup_Scintilla(sci){
    sci.SetWrapMode("SC_WRAP_WORD"), sci.SetMarginWidthN("SC_MARGIN_NUMBER", 0)
}

ClientGuiSize:
    GuiControl, MoveDraw, %LogID%, % "w"A_GuiWidth - 20 "h"A_GuiHeight - 80
    GuiControl, MoveDraw, %MsgID%, % "y"A_GuiHeight - 60 "w"A_GuiWidth - 20
    GuiControl, MoveDraw, %SendID%, % "y"A_GuiHeight - 24
return

ClientGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
