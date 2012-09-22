#include <ws>
#include <SCI>
#singleinstance force

NickName := "Server"
OnExit, ExitRoutine

; Variables/Objects
NewConnection := Object()
userCodes := Object()

; GUI
	Gui, ServMain: +LastFound
    hwnd := WinExist(), sci := new scintilla(hwnd, 10,0,200,200, "", "", a_scriptdir "\lib"), setup_Scintilla(sci)
    
	Gui, ServMain:Add, Edit, y210 w200 -WantReturn vGuiMessage -0x100
	Gui, ServMain:Add, Button, Default gSendMessage, Send
	Gui, ServMain: Add, Button, gCodeWin, Code
	
	Gui, ServCode: Font, s10, Lucida Console
	Gui, ServCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
	Gui, ServCode: Font, s8, Tahoma
	Gui, ServCode: Add, Button, gSendCode, Send ;Sends to server
	Gui, ServCode: Add, Button, gRequestCode, Request ;Request other clients code from server

	Gui, ServMain:Show


; Initialize
	WS_LOGTOCONSOLE := 1
	WS_Startup()

; Port/Socket setup
	server := WS_Socket("TCP", "IPv4")
	WS_Bind(server, "0.0.0.0", "12345")
	WS_Listen(server)
	WS_HandleEvents(server, "ACCEPT READ")
return

SendMessage:
	Gui, Submit, NoHide
	if (!GuiMessage)
		return
	loop % NewConnection.MaxIndex()
		WS_Send(NewConnection[A_Index], NickName . ": " . GuiMessage)
    sci.AddText(strLen(str:="`n" NickName ": " GuiMessage), str), sci.ScrollCaret()
	GuiControl, ServMain:, GuiMessage
return

CodeWin:
	Gui, ServCode: Show
return

SendCode:
	Gui, ServCode: Submit, NoHide
	i++
	userCodes[i] := GuiCode
	;WS_Send(client, "CODE||" . GuiCode)
return

RequestCode:
	;WS_Send(client, "RQST||")
return

WS_OnAccept(socket){
    global NewConnection
    static var:=0
    var++
    NewConnection[var] := WS_Accept(socket, client_ip, client_port)
}

; Send to Multiple clients
WS_OnRead(socket){
    global Log, LogID, NewConnection, sci, userCodes, i

    WS_Recv(socket, ClientMessage)
    msgType :=  SubStr(ClientMessage, 1 , 6)
    StringTrimLeft, ClientMessage, ClientMessage, 6

    if (msgType == "MESG||")
    {
		loop % NewConnection.MaxIndex()
			if (NewConnection[A_Index] != server)
			{
				WS_Send(NewConnection[A_Index], ClientMessage)
			}
		sci.AddText(strLen(str:="`n" ClientMessage), str), sci.ScrollCaret()
    }
    else if (msgType == "RQST||")
    {
    	loop % NewConnection.MaxIndex()
    		if (NewConnection[A_Index] == socket)
				WS_Send(socket, userCodes[i])
    }
    else if (msgType == "CODE||")
    {
    	i++
    	userCodes[i] := ClientMessage
    }
}

; Remove client from array
WS_OnCLose(socket){
	
}

setup_Scintilla(sci){
    sci.SetWrapMode("SC_WRAP_WORD"), sci.SetMarginWidthN("SC_MARGIN_NUMBER", 0)
}

ServMainGuiClose:
ExitRoutine:
	WS_CloseSocket(NewConnection)
	WS_CloseSocket(server)
	WS_Shutdown()
ExitApp