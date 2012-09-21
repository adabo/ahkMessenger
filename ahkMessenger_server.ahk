#include  %A_ScriptDir%\lib\ws.ahk
#Persistent
NickName := "Server"
OnExit, ExitRoutine

; Variables/Objects
NewConnection := Object()

; GUI
	Gui, Server:Add, Edit, w200 h200 vLog HwndLogID
	Gui, Server:Add, Edit, w200 -WantReturn vGuiMessage -0x100
	Gui, Server:Add, Button, Default gSendMessage, Send
	Gui, Server:Show

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
	GuiControl, Server:, %LogID%, % Log . "`n" . NickName . ": " . GuiMessage
	GuiControl, Server:, GuiMessage
	autoScroll()	
return

autoscroll(){
	Global
	SendMessage, 0x00BA, 0, 0,, AHK_ID %LogID%  ; EM_GETLINECOUNT
	LNCount := ErrorLevel - 1
	SendMessage, 0x00BB, LNCount,,, AHK_ID %LogID%  ; EM_LINEINDEX (Gets index number of line)
	CaretTo := ErrorLevel
	SendMessage, 0xB1, CaretTo, CaretTo,, AHK_ID %LogID%
	SendMessage, 0x00B7, 0, 0,, AHK_ID %LogID%  ; EM_SCROLLCARET
}

WS_OnAccept(socket){
    global NewConnection
    static var:=0
    var++
    NewConnection[var] := WS_Accept(socket, client_ip, client_port)
}

; Send to Multiple clients
WS_OnRead(socket){
    global Log, LogID, NewConnection

    WS_Recv(socket, ClientMessage)
	loop % NewConnection.MaxIndex()
		if (NewConnection[A_Index] != server)
			WS_Send(NewConnection[A_Index], ClientMessage)
	Gui, Server:Submit, NoHide
	GuiControl, Server:, %LogID%, % Log . "`n" . ClientMessage
	autoScroll()
}

; Remove client from array
WS_OnCLose(socket){
	
}

GuiClose:
ExitRoutine:
	WS_CloseSocket(NewConnection)
	WS_CloseSocket(server)
	WS_Shutdown()
ExitApp