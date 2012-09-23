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
    hwnd := WinExist(), sci := new scintilla(hwnd, 10,0,200,200, "", a_scriptdir "\lib"), setup_Scintilla(sci)

	Gui, ServMain: Add, Edit, y210 w200 -WantReturn vGuiMessage -0x100
	Gui, ServMain: Add, Button, Default gSendMessage, Send
	Gui, ServMain: Add, Button, gCodeWin, Code
	
	Gui, ServCode: Default
	Gui, ServCode: Font, s10, Lucida Console
	Gui, ServCode: Add, Edit, w400 h400 vGuiCode HwndCodeID
	Gui, ServCode: Add, ListView, x420 y8 w140 h400 -Hdr -Multi, Icon|Users
	ImageListID := IL_Create(2)
	LV_SetImageList(ImageListID)
	IL_Add(ImageListID, "shell32.dll", 209)
	IL_Add(ImageListID, "shell32.dll", 288)

	Gui, ServCode: Font, s8, Tahoma
	Gui, ServCode: Add, Button, x10 gSendCode, Send ;Sends to server
	Gui, ServCode: Add, Button, x10 gRequestCode, Request ;Request other clients code from server

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
return

SendMessage:
	Gui, Submit, NoHide
	if (!GuiMessage)
		return
	for key, value in NewConnection
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

RequestCode:
	Gui, ServCode: Default
	rowNum := LV_GetNext(0, "Focused")
	if (!rowNum)
	{
		msgbox, None selected!
		return
	}
	LV_GetText(reqUserName, rowNum, 2)

	while (reqUserName != rowText)
	{
		LV_GetText(rowText, A_Index, 2)
		if (reqUserName == rowText) ;Compare username from message to name in listview
			LV_Modify(A_Index, "Icon" . 2)
	}
	LV_ModifyCol(1)
	
	Gui, ServMain: Default
	skt := userName[reqUserName]
	GuiControl, ServCode:, %CodeID%, % userCodes[skt]
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
    }
    else if (msgType == "MESG||")
    {
   		for key, value in NewConnection
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
	global NewConnection
	loop % NewConnection.MaxIndex()
	NewConnection.Remove(socket, "")
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