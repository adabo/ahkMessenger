/* Legend:
		MESG|| = Message
		NWCD|| = New code
		USRN|| = User name
		RQST|| = Request Code
		USLS|| = User list
		DISC|| = User Disconnected
        NKCH|| = User Changed Nick
*/

#include <ws>
#include <SCI>
#include <chatGUI>
#include <attach>
#singleinstance force

type := "server"

OnExit, ExitRoutine

; Variables/Objects
    NewConnection := Object()
    userCodes := Object()
    userNick := Object()
    nickFromSocket := Object()
    serverIP := "000"

; GUI
	CreateGui()

    if (EdNick != "Server")
    {
        msgbox, The server nick MUST be: "Server"!
        return
    }
    else if (!EdServIP)
        return

    ; Initialize
    WS_LOGTOCONSOLE := 1
    WS_Startup()

    ; Port/Socket setup
    server := WS_Socket("TCP", "IPv4")
    WS_Bind(server, EdServIP, "12345")
    WS_Listen(server)
    WS_HandleEvents(server, "ACCEPT READ CLOSE")
    NewConnection[serverIP] := serverIP
    userNick[EdNick] := serverIP
    nickFromSocket[000] := "Server"

    if (!EdNick)
    {
        msgbox, Please choose a Nickname
        return
    }
    Gui, Main: Default
    LV_Add("", "", EdNick)
return

WS_OnAccept(socket){
    global NewConnection
    userSock := WS_Accept(socket, client_ip, client_port)
    NewConnection[userSock] := userSock
}

; Send to Multiple clients
WS_OnRead(socket){
    global Log, LogID, NewConnection, sci, userCodes, userNick, nickFromSocket, EdNick

    sci[1].GotoPos(sci[1].GetLength())
    WS_Recv(socket, ClientMessage)
    msgType :=  SubStr(ClientMessage, 1 , 6)
    StringTrimLeft, ClientMessage, ClientMessage, 6

    if      (msgType == "USRN||")
    {
        userNick[ClientMessage] := socket
        nickFromSocket[socket] := ClientMessage
        for key, value in nickFromSocket
            nickList .= value . (key == nickFromSocket.MaxIndex() ? "" : " ")
        for key, value in NewConnection
            if (key != 000)
                WS_Send(key, "USLS||" . nickFromSocket[socket] . "||" . nickList)

        StringReplace, nickList, nickList, %EdNick%%a_space%,,A
        sci[1].SetKeywords(1,nl:=nickList)

        ;========Update Server listview main====
        Gui, Main: Default
        lV_Delete()
        Loop, Parse, nickList, %A_Space%, %A_Space%
            if (A_LoopField != "Server")
                LV_Add("" ,"", A_LoopField) ;The userNick
        sci[1].setReadOnly(false)
        sci[1].AddText(strLen(str:="Notice: " ClientMessage . " has connected.`n"), str), sci[1].ScrollCaret()
        sci[1].setReadOnly(true)
        ;=======================================
    }
    else if (msgType == "MESG||")
    {
        RegexMatch(ClientMessage, "^(.+?)\|\|", match)
        StringTrimLeft, ClientMessage, ClientMessage, strLen(match1) + 2 
        for key, value in NewConnection
            if (NewConnection[key] != 000)
                WS_Send(NewConnection[key], "MESG||" . match1 . "||" . ClientMessage)
        ;=============== For Server GUI =================
        sci[1].setReadOnly(false)
        sci[1].AddText(strLen(str:= match1 . ": " . ClientMessage "`n"), str), sci[1].ScrollCaret()
        sci[1].setReadOnly(true)
        IfWinnotActive, ahkMessenger Server
            soundplay, *48
        ;================================================
    }
    else if (msgType == "RQST||")
    {
        skt := userNick[ClientMessage]
        WS_Send(socket, "CODE||" . ClientMessage . "||" . userCodes[skt])
    }
    else if (msgType == "NWCD||")
    {
        userCodes[socket] := ClientMessage
        for key, value in NewConnection
            if (NewConnection[key] != 000)
                WS_Send(NewConnection[key], "NWCD||" . nickFromSocket[socket])

        ;=========== Update Server code window ListView ===================;
        Gui, Code: Default
        sci[1].setReadOnly(false)
        sci[1].AddText(strlen(str := "Notice: New code from """ . nickFromSocket[socket] . """`n"), str), sci[1].ScrollCaret()
        sci[1].setReadOnly(true)
        loop % LV_GetCount()
        {
            LV_GetText(rowText, A_Index, 2)
            if (nickFromSocket[socket] == rowText)
            {
                namExist := True
                LV_Modify(A_Index, "Icon" . 1, "")
                break
            }
            else
                namExist := False
        }
        if (!namExist)
            LV_Add("Icon" . 1,"", nickFromSocket[socket])
        ;===================================================================;
    }
    else if (msgType == "NKCH||")
    {

        oldNick := nickFromSocket[socket]
        nickFromSocket[socket] := ClientMessage
        for key, value in nickFromSocket
            nickList .= value . " "
        for key, value in NewConnection
            if (key != 000)
                WS_Send(key, "NKCH||" . oldNick . "||" . ClientMessage . "||" . nickList)

        StringReplace, nickList, nickList, %EdNick%%a_space%,,A
        sci[1].SetKeywords(1,nl:=nickList)

        ;========Update Server listview main====
        Gui, Main: Default
        lV_Delete()
        Loop, Parse, nickList, %A_Space%
            if (A_LoopField != "Server")
                LV_Add("" ,"", A_LoopField) ;The userNick
        sci[1].setReadOnly(false)
        sci[1].AddText(strLen(str:="Notice: " oldNick . " has changed their nick to: " . ClientMessage . "`n"), str), sci[1].ScrollCaret()
        sci[1].setReadOnly(true)
        ;=======================================
    }
    else if (msgType == "COMD||")
    {
        RegexMatch(ClientMessage, "^/(.+?) ", cmd)
        if      (cmd1 == "")
            WS_Send(NewConnection[socket], "MESG||Notice from Server: You want to to send some command?")
        else if (cmd1 == "/JOIN")
            WS_Send(NewConnection[socket], "MESG||Notice from Server: You want to join some channel?")
        else if (cmd1 == "/LEAVE")
            WS_Send(NewConnection[socket], "MESG||Notice from Server: You want to leave some channel?")
        else if (cmd1 == "/MOTD")
            WS_Send(NewConnection[socket], "MESG||Notice from Server: You want the Message Of The Day?")
        ;else if (cmd1 == "/EXIT")
    }
}

; Remove client from array
WS_OnCLose(socket){
    global NewConnection, userCodes, userNick, nickFromSocket

        Gui, Main: Default
        loop % LV_GetCount()
        {
            LV_GetText(nm, A_Index, 2)
            if (nickFromSocket[socket] == nm)
                lV_Delete(A_Index)
        }

    for key, value in NewConnection
        if (NewConnection[key] != 000)
            WS_Send(value, "DISC||" . nickFromSocket[socket])

    userCodes.Remove(socket, "")
    userNick.Remove(nickFromSocket[socket])
    NewConnection.Remove(socket, "")
    nickFromSocket.Remove(socket, "")
}

MainGuiClose:
ExitRoutine:
    WS_CloseSocket(NewConnection)
    WS_CloseSocket(server)
    WS_Shutdown()
ExitApp