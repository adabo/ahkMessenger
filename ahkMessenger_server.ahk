/*
    Legend:
        MESG|| = Message
        NWCD|| = New code
        USRN|| = User name
        RQST|| = Request Code
        USLS|| = User list
        DISC|| = User Disconnected
        NKCH|| = User Changed Nick
*/
; includes
    #include <ws>
    #include <SCI>
    #include <chatGUI>
    #include <attach>
    #singleinstance force

; On exit
    OnExit, ExitRoutine

; Variables/Objects
    type := "server"
    chan           := Object()  ; chan[#chan] := #chan  (Array of all occupied channels)
    allNicksInChan := Object()  ; allNicksInChan[#chan, nick] := nick
    chansNickIsIn  := Object()  ; chan := chansNickIsIn[nick, #chan]
    userCodes      := Object()
    socketFromNick := Object()
    nickFromSocket := Object()
    allNicksInChanMaxIndex := Object()
    allNicksInChanMaxIndex["#Main"] := 0

    channelNicks[nChan] := Object()

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

    if (!EdNick)
    {
        msgbox, Please choose a Nickname
        return
    }
    Gui, Main: Default
    LV_Add("", "", EdNick)
    WinMove, server,, 0, 0
return

WS_OnAccept(socket){
    global socketFromNick
    WS_Accept(socket, client_ip, client_port)
}

; Send to Multiple clients
WS_OnRead(socket){
    global Log, LogID, sci, userCodes, socketFromNick, nickFromSocket, EdNick, allNicksInChan, allNicksInChanMaxIndex, chansNickIsIn, chan

    sci[1].GotoPos(sci[1].GetLength())
    WS_Recv(socket, ClientMessage)
    RegexMatch(ClientMessage, "^(\w+)\|\|\/?(\w+)\|?\|?(#?\w+)?\|?\|?(.+)?", arg)  ; Match the socketFromNick
    msgType :=  arg1, nNick := arg2, nChan := arg3, nMsg := arg4
    ;msgbox msgType = %msgType%`nnNick = %nNick%`nnChan = %nChan%`nnMsg = %nMsg%
    if      (msgType == "USRN")
    {
        socketFromNick[nNick] := socket, nickFromSocket[socket] := nNick
        WS_Send(socket, "TITL||" . socket . "||")

        ;=== For Server 
        sci[1].SetKeywords(1,nickList)
    }
    else if (msgType == "MESG")
    {
        for key, value in socketFromNick                                                     ; Send messages to all
            if (allNicksInChan[nChan, nickFromSocket[value]] == nickFromSocket[value])       ; users according to
                WS_Send(socketFromNick[key], "MESG||" . nNick . "||" . nChan . "||" . nMsg)  ; the channels they are
                                                                                             ; associated with
        ;=============== For Server GUI =================
        sci[1].setReadOnly(false)
        sci[1].AddText(strLen(str:= nNick . "(@" . nChan . "): " . nMsg "`n"), str), sci[1].ScrollCaret()
        sci[1].setReadOnly(true)
        IfWinnotActive, ahkMessenger Server
            soundplay, *48
        ;================================================
    }
    else if (msgType == "RQST")
    {
        skt := socketFromNick[nNick]
        WS_Send(socket, "CODE||" . nNick . "||" . userCodes[skt])
    }
    else if (msgType == "NWCD")
    {
        nNick := nickFromSocket[socket]
        nCode := arg2
        userCodes[socket] := nCode
        for key, value in socketFromNick
            WS_Send(socketFromNick[key], "NWCD||" . nNick)

        ;=========== Update Server code window ListView ===================;
        Gui, Code: Default
        sci[1].setReadOnly(false)
        sci[1].AddText(strlen(str := "Notice: New code from """ . nNick . """`n"), str), sci[1].ScrollCaret()
        sci[1].setReadOnly(true)
        loop % LV_GetCount()
        {
            LV_GetText(rowText, A_Index, 2)
            if (nNick == rowText)
            {
                nickExist := True
                LV_Modify(A_Index, "Icon" . 1, "")
                break
            }
            else
                nickExist := False
        }
        if (!nickExist)
            LV_Add("Icon" . 1,"", nNick)
        ;===================================================================;
    }
    else if (msgType == "NKCH")
    {
        /*
            When a client changes their nick the
            server must send updates to all the
            channels the client occupies

            First start with storing the oldnick.
            Then remove the old array links using
            oldNick and skt

            Use nNick to to create new array elements.
        */
        oldNick := nickFromSocket[socket]
        nickFromSocket.Remove(socket, ""), socketFromNick.Remove(oldnick)
        nNick := arg2
        socketFromNick[nNick] := socket, nickFromSocket[socket] := nNick

        /*
            Need To combine this chansNickIsIn for block with the next one.

            This block updates the channel list for each channel you occupy
            with the new nick the client provided.
        */
        for k, v in chansNickIsIn[oldNick]
        {
            for i, j in allNicksInChan[v]
            {
                if (j == oldNick)
                {
                    allNicksInChan[v].Remove(oldNick)
                    allNicksInChan[v, nNick] := nNick
                }
            }
            chansNickIsIn[nNick, v] := v  ; chansNickIsIn["SomeNick", "#SomeChan"] := "#SomeChan"
        }

        /*
            This is the 2nd for block. How do
            I combine these two? The one above and the one below.
        */
        for k, v in chansNickIsIn[oldNick]
        {
            for i, j in allNicksInChan[v]
            {
                for key, value in allNicksInChan[v]
                    nickList .= value . (A_Index != allNicksInChanMaxIndex[v] ? " " : "")
                WS_Send(socketFromNick[j], "NKCH||" . oldNick . "||" . nNick . "||" . nickList . "||" . v)
                nickList := ""
            }
            chansNickIsIn[nNick, v] := v  ; chansNickIsIn["SomeNick", "#SomeChan"] := "#SomeChan"
        }
        chansNickIsIn.Remove(oldNick)

        StringReplace, nickList, nickList, %EdNick%%a_space%,,A  ; Remove "Server" name from list
        sci[1].SetKeywords(1,nl:=nickList)

        ;========Update Server listview main====
        Gui, Main: Default
        lV_Delete()
        Loop, Parse, nickList, %A_Space%
            LV_Add("" ,"", A_LoopField)
        sci[1].setReadOnly(false)
        sci[1].AddText(strLen(str:="Notice: " oldNick . " has changed their nick to: " . nNick . "`n"), str), sci[1].ScrollCaret()
        sci[1].setReadOnly(true)
        ;=======================================
    }
    else if (msgType == "COMD")
    {
        RegexMatch(ClientMessage, "^COMD\|\|\/(\w+) (.+)", arg)          ; args from first Regex not valid here (Line 74)
        cmd := arg1, nChan := arg2, nNick := nickFromSocket[socket]
        if      (cmd == "JOIN")
        {
            if (chansNickIsIn[nNick, nChan])  ; If the client tries to join a channel they are alread in
            {
                WS_Send(socket, "COMD||Notice: You are already in '" . nChan "'||")
                return
            }
            allNicksInChan[nChan, nNick] := nNick
            chansNickIsIn[nNick, nChan] := nChan
            if (chan[nChan])  ; The channel exists and sends notice to all clients in channel
            {
                allNicksInChanMaxIndex[nChan]++
                for key, value in allNicksInChan[nChan]
                    nickList .= value . (A_Index != allNicksInChanMaxIndex[nChan] ? " " : "")
                for k, v in allNicksInChan[nChan]
                    WS_Send(socketFromNick[v], "CHAN||ENTER||" . nChan . "||" . nickList . "||" . nickFromSocket[socket])  ; tell client to enter. Send 5th argument

            }
            else ; If channel does not exist create it and tell client to enter
            {
                allNicksInChanMaxIndex[nChan] := 1
                chan[nChan] := nChan
                nickList := nNick
                WS_Send(socketFromNick[nNick], "CHAN||ENTER||" . nChan . "||" . nickList . "||" . nickFromSocket[socket])
            }
        }
        else if (cmd == "LEAVE")
            WS_Send(socket, "COMD||Notice from Server: You want to leave some channel?")
        else if (cmd == "MOTD")
            WS_Send(socket, "COMD||Notice from Server: You want the Message Of The Day?")
        else if (cmd == "HELP")
            WS_Send(socket, "COMD||Notice from Server: Commands:`n  JOIN`n  LEAVE`n  MOTD`n  HELP")
        else
            WS_Send(socket, "COMD||Notice from Server: Acceptable commands are:`n  JOIN`n  LEAVE`n  MOTD`n  HELP")
        ;else if (cmd == "EXIT")
    }
}

; Remove client from array
WS_OnCLose(socket){
    global socketFromNick, userCodes, socketFromNick, nickFromSocket, allNicksInChan, chansNickIsIn, allNicksInChanMaxIndex

    Gui, Main: Default
    loop % LV_GetCount()
    {
        LV_GetText(nm, A_Index, 2)
        if (nickFromSocket[socket] == nm)
            lV_Delete(A_Index)
    }

    for key, value in socketFromNick
        WS_Send(value, "DISC||" . nickFromSocket[socket])

    userCodes.Remove(socket, "")
    for k, v in chansNickIsIn[nickFromSocket[socket]]
        allNicksInChan[v].Remove(nickFromSocket[socket], "")
    chansNickIsIn.Remove(nickFromSocket[socket], "")
    socketFromNick.Remove(nickFromSocket[socket], "")
    socketFromNick.Remove(socket, "")
    nickFromSocket.Remove(socket, "")
    allNicksInChanMaxIndex--
}
;==== For DEBUGGING ONLY 
~*Esc::
;==== End DEBUG
MainGuiClose:
ExitRoutine:
    for k, v in socketFromNick
        WS_CloseSocket(v)
    WS_CloseSocket(server)
    WS_Shutdown()
ExitApp