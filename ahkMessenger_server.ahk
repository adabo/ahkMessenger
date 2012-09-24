/*
	Legend:
		MESG|| = Message
		NWCD|| = New code
		USRN|| = User name
		RQST|| = Request Code
		USLS|| = User list
		DISC|| = User Disconnected
*/

#include <ws>
#include <SCI>
#singleinstance force

NickName := "Server"
OnExit, ExitRoutine

; Variables/Objects
NewConnection := Object()
userCodes := Object()
userName := Object()
nameFromSocket := Object()
serverIP := "999"

; GUI
	Gui, ServMain: +LastFound
    hwnd := WinExist(), sci := new scintilla(hwnd, 10,0,400,200, "", a_scriptdir "\lib"), setup_Scintilla(sci)
    Gui, ServMain: Add, ListView, x420 y6 w120 h198 -Hdr -Multi, Icon|Users
	Gui, ServMain: Add, Edit, x10 y210 w530 -WantReturn vGuiMessage -0x100
	Gui, ServMain: Add, Button, x10 Default gSendMessage, Send
	Gui, ServMain: Add, Button, x10 xp40 yp gCodeWin, Code
	
	Gui, ServCode: Default
	Gui, ServCode: Font, s10, Lucida Console
	Gui, ServCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
	Gui, ServCode: Add, ListView, x420 y8 w140 h400 -Hdr -Multi gListViewNotifications, Icon|Users
	ImageListID := IL_Create(2)
	LV_SetImageList(ImageListID)
	IL_Add(ImageListID, "shell32.dll", 71)
	IL_Add(ImageListID, "shell32.dll", 291)

	Gui, ServCode: Font, s8, Tahoma
	Gui, ServCode: Add, Button, x10 gSendCode, Send ;Sends to server

	Gui, ServMain:Show


; Initialize
	WS_LOGTOCONSOLE := 1
	WS_Startup()

; Port/Socket setup
	server := WS_Socket("TCP", "IPv4")
	WS_Bind(server, "0.0.0.0", "12345")
	WS_Listen(server)
	WS_HandleEvents(server, "ACCEPT READ CLOSE")
	NewConnection[serverIP] := serverIP
    userName[NickName] := serverIP
    nameFromSocket[999] := "Server"

    Gui, ServMain: Default
    LV_Add("", "", NickName)

return

SendMessage:
	Gui, Submit, NoHide
	if (!GuiMessage)
		return
	for key, value in NewConnection
		if (NewConnection[key] != 999)
			WS_Send(NewConnection[key], "MESG||" . NickName . ": " . GuiMessage)
    sci.AddText(strLen(str:="`n" NickName ": " GuiMessage), str), sci.ScrollCaret()
	GuiControl, ServMain:, GuiMessage
return

CodeWin:
	Gui, ServCode: Show
return

SendCode:
	Gui, ServCode: Submit, NoHide
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
	;WS_Send(client, "NWCD||" . GuiCode)
return

ListViewNotifications:
	if (A_GuiEvent == "DoubleClick") ;Request code from server with user name
	{
		Gui, ServCode: Default
		LV_GetText(rowText, A_EventInfo, 2)
		skt := userName[rowText]
		GuiControl, ServCode:, %CodeID%, % userCodes[skt]
		LV_Modify(A_EventInfo, "Icon" . 0)
	}
return

WS_OnAccept(socket){
    global NewConnection
    userSock := WS_Accept(socket, client_ip, client_port)
    NewConnection[userSock] := userSock
}

; Send to Multiple clients
WS_OnRead(socket){
    global Log, LogID, NewConnection, sci, userCodes, userName, nameFromSocket

    WS_Recv(socket, ClientMessage)
    msgType :=  SubStr(ClientMessage, 1 , 6)
    StringTrimLeft, ClientMessage, ClientMessage, 6

    if (msgType == "USRN||")
    {
    	userName[ClientMessage] := socket
    	nameFromSocket[socket] := ClientMessage
	    for key, value in nameFromSocket
	    	nickList .= value . " "
	    ;msgbox, %nickList%
	    for key, value in NewConnection
   			if (key != 999)
				WS_Send(key, "USLS||" . nickList)

;========Update Server listview main====
    	Gui, ServMain: Default
    	Loop, Parse, nickList, %A_Space%
    		if (A_LoopField != "Server")
				LV_Add("" ,"", A_LoopField) ;The username
;=======================================

    }
    else if (msgType == "MESG||")
    {
   		for key, value in NewConnection
   			if (NewConnection[key] != 999)
				WS_Send(NewConnection[key], "MESG||" . ClientMessage)
		sci.AddText(strLen(str:="`n" ClientMessage), str), sci.ScrollCaret()
    }
    else if (msgType == "RQST||")
    {
        skt := userName[ClientMessage]
		WS_Send(socket, "CODE||" . ClientMessage . "||" . userCodes[skt])
    }
    else if (msgType == "NWCD||")
    {
    	userCodes[socket] := ClientMessage
    	for key, value in NewConnection
    		if (NewConnection[key] != 999)
    			WS_Send(NewConnection[key], "NWCD||" . nameFromSocket[socket])

;=========== Update Server code window ListView ===================;
    	Gui, ServCode: Default
    	loop % LV_GetCount()
    	{
    		LV_GetText(rowText, A_Index, 2)
    		if (nameFromSocket[socket] == rowText)
    		{
    			namExist := True
    			LV_Modify(A_Index, "Icon" . 1, "")
    			break
    		}
    		else
    			namExist := False
    	}
    	if (!namExist)
			LV_Add("Icon" . 1,"", nameFromSocket[socket])
;===================================================================;
    }
}

; Remove client from array
WS_OnCLose(socket){
	global NewConnection, userCodes, userName, nameFromSocket

		Gui, ServMain: Default
		loop % LV_GetCount()
		{
			LV_GetText(nm, A_Index, 2)
			if (nameFromSocket[socket] == nm)
				lV_Delete(A_Index)
		}

	for key, value in NewConnection
		if (!999)
			WS_Send(value, "DISC||" . nameFromSocket[socket])

	userCodes.Remove(socket, "")
	userName.Remove(nameFromSocket[socket])
	NewConnection.Remove(socket, "")
	nameFromSocket.Remove(socket, "")
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