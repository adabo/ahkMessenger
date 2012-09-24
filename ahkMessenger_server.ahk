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
#include <chatGUI>
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
	CreateServerGui()

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


WS_OnAccept(socket){
    global NewConnection
    userSock := WS_Accept(socket, client_ip, client_port)
    NewConnection[userSock] := userSock
}

; Send to Multiple clients
WS_OnRead(socket){
    global Log, LogID, NewConnection, sci, userCodes, userName, nameFromSocket, NickName

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
        
        StringReplace, nickList, nickList, %NickName%%a_space%,,A
        sci[1].SetKeywords(1,nl:=nickList)
        
;========Update Server listview main====
    	Gui, ServMain: Default
    	lV_Delete()
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
		sci[1].AddText(strLen(str:=ClientMessage "`n"), str), sci[1].ScrollCaret()
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
		if (NewConnection[key] != 999)
			WS_Send(value, "DISC||" . nameFromSocket[socket])

	userCodes.Remove(socket, "")
	userName.Remove(nameFromSocket[socket])
	NewConnection.Remove(socket, "")
	nameFromSocket.Remove(socket, "")
}

ServMainGuiClose:
ExitRoutine:
	WS_CloseSocket(NewConnection)
	WS_CloseSocket(server)
	WS_Shutdown()
ExitApp