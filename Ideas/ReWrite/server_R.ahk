OnExit, ExitRoutine

;//Includes
    #singleinstance Force

;//Initialize
    WS_LOGTOCONSOLE := 1
    WS_Startup()
    server := WS_Socket("TCP", "IPv4")
    WS_Bind(server, "0.0.0.0", "12345")
    WS_Listen(server)
    WS_HandleEvents(server, "ACCEPT READ CLOSE")
return

;//Funcions
WS_OnAccept(socket){
    WS_Accept(socket, client_ip, client_port)
    ;Outputdebug **Server>>WS_OnAccept**
}

WS_OnRead(socket){
    WS_Recv(socket, ClientMessage)
    ;mb(ClientMessage)
    ;Outputdebug **Server>>WS_OnRead** **START** %ClientMessage%
    ;newcode := 
    if (instr(ClientMessage, "NWCD"))
        StringReplace, ClientMessage, ClientMessage, `r,, All
    RegexReplace(ClientMessage, "\|\|", "", count)
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
        client[socket].chanKeep("#Server")
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
            client[socket].chanKeep(InStr(prm, "#") ? prm : prm := "#" . prm)
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
    else if (msgType == "NWCD")
    {
        /*
            arg2/data = version number
            arg3/cmd  = code
        */
         client[socket].codeKeep(arg3,data)
        ;nickName := client[socket].getNick()
        /*
        t := client[socket].codeKeep(["cd"])
        for a, b in t
            for c, d in t[a]
                mb(a,b,c,d, "!!!!", nickName)
        */
    }
    OnSend(socket, msgType, data, cmd, prm)
    ;Outputdebug **Server>>WS_OnRead** **END**
}

OnSend(s, m, d, c = "", p = ""){
    Global code := []
    if      (m == "MESG")
    {
        /*
            m = msgType
            d = Channel
            c = User Input (message)
		*/
        nickName := client[s].getNick()
        joker := client.chanKeep(["channelsTheNickIsIn"])
        ;Outputdebug **Server>>OnSend>>MESG** s=%s%, m=%m%, c=%c%, d=%d%, nickName=%nickName%
        for sock in joker
        {
            for chan, nick in joker[sock]
            {
                ;Outputdebug **Server>>OnSend>>MESG>>for sock in joker** %sock%, %chan%, %nick%
                if (d == chan)
                    WS_Send(sock, "MESG||" . chan . "||" . nickName . "||" . c)
            }
        }
    }
    else if (m == "COMD")
    {
        c := upperCase(c)
        ;Outputdebug **Server>>OnSend>>COMD** s=%s%, m=%m%, d=%d%, c=%c%, d=%d%
        if (c == "JOIN")
        {
            /*
                p = #Channel
			*/
            ClientOrigin := client[s].getNick()
            penguin := client.chanKeep(["channelsTheNickIsIn"])
            for a in penguin
                for ch, nk in penguin[a]
                    if (ch = p)
                        listofnicks .= nk . " "
            penguin := client.chanKeep(["channelsTheNickIsIn"])
            for sock in penguin
                for chan, nick in penguin[sock]
                    if (chan = p)
                        WS_Send(sock, "JOIN||" . p . "||" . ClientOrigin . "||" . listofnicks)
            ;Outputdebug **Server>>OnSend>>COMD>>JOIN**
        }
        if (c == "NKCH")
        {
            joker := client.chanKeep(["channelsTheNickIsIn"])[s]
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
            ;Outputdebug **Server>>OnSend>>MESG** s=%s%, m=%m%, d=%d%, c=%c%, d=%d%, nickName=%nickName%
            tmp := []

            penguin := client.chanKeep(["channelsTheNickIsIn"])
            for a in penguin
                for b, c in penguin[a]
                    tmp[b,c] := 1


            joker := client.chanKeep(["channelsTheNickIsIn"])[s]
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
            ;Outputdebug **Server>>OnSend>>COMD>>NKCH**
        }
    }
    else if (m == "NWCD")
    {
        /*
            m = NWCD
            d = Version
            c = Code
        */
        nickName := client[s].getNick()
        nicksCode := c
        tmp := []
        penguin := client.chanKeep(["channelsTheNickIsIn"])
        for a in penguin
            for b, c in penguin[a]
            {
                tmp[b,c] := 1
            }
        joker := client.chanKeep(["channelsTheNickIsIn"])[s]
        for chan, nick in joker
        {
            for soc in penguin
                for c, n in penguin[soc]
                    if (c = chan)
                    {
                        listofnicks := ""
                        for a,b in tmp[chan]
                            listofnicks .= a . " "
                        ;mb(listofnicks)
                        ;WS_Send(soc, "NKCH||" . oldNick . "||" . p . "||" . c . "||" . listofnicks)
                        WS_Send(soc, "NWCD||" . nickName . "||" . d)
                        ;mb(oldNick, p,c)
                        sleep 20
                    }
        }
        ;Outputdebug **Server>>OnSend>>COMD>>NKCH**
    }
    else if (m == "RQCD")
    {
        /*
            d   = Nickname
            c   = version
        */
        nickName := d, v := c
        for sock, cls in client
        {
            if (client[sock].getNick() == nickName)
            {
                code1 := client[sock].codeKeep(["cd"])[sock,v]
                ;mb("RQCD||" v "||" d . "||" code1)
                WS_Send(s, "RQCD||" v "||" d . "||" code1)
            }
        }
    }
}

WS_OnClose(socket){
    penguin := client.chanKeep(["channelsTheNickIsIn"])
    penguin[socket] := ""
    client[socket] := ""
}

upperCase(s){
    StringUpper, s, s
    return s
}

mb(x*){
    for a,b in x
        list.=b "`n"
    MsgBox,% list
}

tt(x*){
    for a,b in x
        list.=a "=" b "`n"
    ToolTip,% list
}

class client {
   __New(aSock){
      this.sock := aSock
   }

    addNick(anick){
        this.nick := anick
    }

    chanKeep(achan = ""){
        static channelsTheNickIsIn := []
        if isObject(achan)
        {
            list := achan.1, out := %list%
            return out
        }
        channelsTheNickIsIn[this.sock, achan] := this.nick
    }

    codeKeep(aCode = "", ver = ""){
        static cd := []
        if isObject(aCode)
        {
            list := aCode.1, out := %list%
            return out
        }
        cd[this.sock, ver] := aCode
    }

    getNick(aSock = ""){
        if this.nick
        return this.nick
    }
}

/*
^F1::
    joker := client.chanKeep()
    for nick in joker
        for chan in joker[nick]
            if (chan)
                msgbox, %nick%|%chan%
return

^F2::
    joker := client.chanKeep(["channelsTheNickIsIn"])

    for sock in joker{
        msgbox %sock%
        for chan, nick in joker[sock]
            msgbox, %sock%|%chan%|%nick%
    }
return
~*Esc::
*/

ExitRoutine:
    WS_CloseSocket(server)
    WS_Shutdown()
ExitApp