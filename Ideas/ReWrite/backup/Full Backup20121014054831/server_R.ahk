OnExit, ExitRoutine

; includes
    #singleinstance force

; Initialize
    WS_LOGTOCONSOLE := 1
    WS_Startup()
    server := WS_Socket("TCP", "IPv4")
    WS_Bind(server, "127.0.0.1", "80")
    WS_Listen(server)
    WS_HandleEvents(server, "ACCEPT READ CLOSE")

return

WS_OnAccept(socket){
    WS_Accept(socket, client_ip, client_port)
    ;Outputdebug **Server>>WS_OnAccept**
}

WS_OnRead(socket){
    WS_Recv(socket, ClientMessage)
    ;Outputdebug **Server>>WS_OnRead** **START**
    RegexReplace(ClientMessage, "\|\|", "", count)
    tt(count)
    loop, %count%
        search.="(.*)\|\|"
    search .= "(.*)"
    RegexMatch(ClientMessage, "^" . search, arg)
    msgType := arg1, data := arg2, cmd := arg3, prm := arg4
    ;Outputdebug **Server>>WS_OnRead**  %msgType%, %data%, %ClientMessage%
    if      (msgType == "NWCN")
    {
        client[socket] := new client(socket)
        client[socket].addNick(n := "Guest" . A_TickCount)
        client[socket].addChan("#Server")
        WS_Send(socket, "USRN||" . n)
        ;sleep 
        ;WS_Send(socket, "JOIN||#Server||" . n)
        Outputdebug % "**Server>>WS_OnRead>>NWCN** " . client[socket].sock
    }

    else if (msgType == "MESG")
    {
        /*
            arg1 = MESG
            arg2 = Channel
            arg3 = User input
		*/
        prm := arg4
        Outputdebug **Server>>WS_OnRead>>MESG** %prm%
    }
    else if (msgType == "COMD")
    {
        RegexMatch(arg2, "^\/(\w+)? (.*)", arg)
        /* 
            arg1 = COMD
            arg2 = Parameter
		*/
        ;mb(arg1, arg2, arg3, arg4, arg5)
        cmd := arg1 == "nick" ? "NKCH" : arg1, prm := arg2
        if      (cmd = "JOIN")
        {
            client[socket].addChan(InStr(prm, "#") ? prm : prm := "#" . prm)
            ;Outputdebug % "**Server>>WS_OnRead>>COMD>>JOIN** prm=" . prm
        }
        else if (cmd == "NKCH")
        {
            /*
                arg1 = socket
                arg2 = Full client message
                arg3 = #Channel
			*/
            data := arg3
            ;Outputdebug % "**Server>>WS_OnRead>>COMD>>NKCH** " . client[socket].nick
        }
    }
    serverSend(socket, msgType, data, cmd, prm)
    ;Outputdebug **Server>>WS_OnRead** **END**
}

serverSend(s, m, d, c = "", p = ""){
    if      (m == "MESG")
    {
        /*
            m = msgType
            d = Channel
            c = User Input (message)
		*/
        nickName := client[s].getNick()
        joker := client.addChan(["channelsTheNickIsIn"])
        Outputdebug **Server>>serverSend>>MESG** s=%s%, m=%m%, c=%c%, d=%d%, nickName=%nickName%
        for sock in joker
        {
            for chan, nick in joker[sock]
            {
                ;Outputdebug **Server>>serverSend>>MESG>>for sock in joker** %sock%, %chan%, %nick%
                if (d == chan)
                    WS_Send(sock, "MESG||" . chan . "||" . nickName . "||" . c)
            }
        }
    }
    else if (m == "COMD")
    {
        c := upperCase(c)
        ;Outputdebug **Server>>serverSend>>COMD** s=%s%, m=%m%, d=%d%, c=%c%, d=%d%
        if (c == "JOIN")
        {
            /*
                p = #Channel
			*/
            ClientOrigin := client[s].getNick()
            penguin := client.addChan(["channelsTheNickIsIn"])
            for a in penguin
                for ch, nk in penguin[a]
                    if (ch = p)
                        listofnicks .= nk . " "
            penguin := client.addChan(["channelsTheNickIsIn"])
            for sock in penguin
                for chan, nick in penguin[sock]
                    if (chan = p)
                        WS_Send(sock, "JOIN||" . p . "||" . ClientOrigin . "||" . listofnicks)
            ;Outputdebug **Server>>serverSend>>COMD>>JOIN**
        }
        if (c == "NKCH")
        {
            joker := client.addChan(["channelsTheNickIsIn"])[s]
            for chan, nick in joker
                joker[chan] := p
            /*
                m = COMD
                d = Full message
                c = NKCH
                p = New Nickname
			*/
            oldNick := client[s].getNick()
            client[s].addNick(p)
            ;Outputdebug **Server>>serverSend>>MESG** s=%s%, m=%m%, d=%d%, c=%c%, d=%d%, nickName=%nickName%
            tmp := []

            penguin := client.addChan(["channelsTheNickIsIn"])
            for a in penguin
                for b, c in penguin[a]
                    tmp[b,c] := 1


            joker := client.addChan(["channelsTheNickIsIn"])[s]
            for chan, nick in joker
            {
                for soc in penguin
                    for c, n in penguin[soc]
                        if (c = chan)
                        {
                            listofnicks := ""
                            for a,b in tmp[chan]
                                listofnicks .= a . " "

                            WS_Send(soc, "NKCH||" . oldNick . "||" . p . "||" . c . "||" . listofnicks)
                            ;mb(oldNick, p,c)
                            sleep 20
                        }
            }
            ;Outputdebug **Server>>serverSend>>COMD>>NKCH**
        }
    }
}

WS_OnClose(socket){
    penguin := client.addChan(["channelsTheNickIsIn"])
    penguin[socket] := ""
}

class client {
   __New(aSock){
      this.sock := aSock
   }

    addNick(anick){
        this.nick := anick
    }

    addChan(achan = ""){
        static channelsTheNickIsIn := []  ;//, listOfAllChannelsAndNicksInIt := []
        if isObject(achan)
        {
            list := achan.1, out := %list%
            return out
        }
        channelsTheNickIsIn[this.sock, achan] := this.nick
        ;//listOfAllChannelsAndNicksInIt[achan, this.nick] := 1
    }
    getNick(aSock = ""){
        if this.nick
        return this.nick
    }
}

upperCase(s){
    StringUpper, s, s
    return s
}

mb(x*){
    for a,b in x
        list.=a "=" b "`n"
    MsgBox,% list
}

tt(x*){
    for a,b in x
        list.=a "=" b "`n"
    ToolTip,% list
}

^F1::
    joker := client.addChan()
    for nick in joker
        for chan in joker[nick]
            if (chan)
                msgbox, %nick%|%chan%
return

^F2::
    joker := client.addChan(["channelsTheNickIsIn"])

    for sock in joker{
        msgbox %sock%
        for chan, nick in joker[sock]
            msgbox, %sock%|%chan%|%nick%
    }
return

;~*Esc::
ExitRoutine:
    WS_CloseSocket(server)
    WS_Shutdown()
ExitApp