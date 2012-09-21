#include <ws>
#include <SCI>
#singleinstance force

NickName := "Server"
OnExit, ExitRoutine

; Variables/Objects
NewConnection := Object()

; GUI
	Gui, Server: +LastFound
    hwnd := WinExist(), sci := new scintilla(hwnd, 10,0,200,200, "", "", a_scriptdir "\lib"), setup_Scintilla(sci)
    
	Gui, Server:Add, Edit, y210 w200 -WantReturn vGuiMessage -0x100
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
    sci.AddText(strLen(str:="`n" NickName ": " GuiMessage), str), sci.ScrollCaret()
	GuiControl, Server:, GuiMessage
return

WS_OnAccept(socket){
    global NewConnection
    static var:=0
    var++
    NewConnection[var] := WS_Accept(socket, client_ip, client_port)
}

; Send to Multiple clients
WS_OnRead(socket){
    global Log, LogID, NewConnection, sci

    WS_Recv(socket, ClientMessage)
	loop % NewConnection.MaxIndex()
		if (NewConnection[A_Index] != server)
			WS_Send(NewConnection[A_Index], ClientMessage)
	sci.AddText(strLen(str:="`n" ClientMessage), str), sci.ScrollCaret()
}

; Remove client from array
WS_OnCLose(socket){
	
}

setup_Scintilla(sci){
    sci.SetWrapMode("SC_WRAP_WORD"), sci.SetMarginWidthN("SC_MARGIN_NUMBER", 0)
}

GuiClose:
ExitRoutine:
	WS_CloseSocket(NewConnection)
	WS_CloseSocket(server)
	WS_Shutdown()
ExitApp