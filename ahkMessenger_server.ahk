/*
    ahkMessenger v0.33
    author: adabo
    email: abel4@msn.com
*/


;// Includes
    #Include lib\ws.ahk

;// Directives
    #singleinstance Force
    OnExit, ExitRoutine

;// Variables
    WS_LOGTOCONSOLE := 1
    global trm      := chr(13) chr(10)

;// Program start
    initialize_WS()  ;
return

initialize_WS(){
    WS_Startup()
    server := WS_Socket("TCP", "IPv4")
    WS_Bind(server, "0.0.0.0", "12345")
    WS_Listen(server)
    WS_HandleEvents(server, "ACCEPT READ CLOSE")
}

WS_OnAccept(skt){
    skt := WS_Accept(skt, client_ip, client_port)
    client[skt] := new client(skt)
    nck := client[skt].nick := "Guest" A_TickCount
    WS_Send(skt, "USRN||" nck trm)
    protJOIN(skt,"#a",nck)
}

WS_OnRead(skt){
    WS_Recv(skt, c),ClientMessage:=rtrim(c,"`n"),nck := client[skt].nick
    if (substr(str:=ClientMessage,2,1) == "W")
    {
        StringReplace, str,str, `r,,All
        getRegexArgs(str,arg1,arg2,arg3)
        protNWCD(skt,arg3,arg2)
        return
    }
    Loop, Parse, ClientMessage, `n
    {
        if !(ClientMessage := rtrim(A_LoopField,"`r`n"))
            return
        getRegexArgs(ClientMessage,arg1,arg2,arg3,arg4,arg5),protType := arg1
        if      (protType == "MESG")
            protMESG(skt,arg2,nck,arg3)
        else if (protType == "JOIN")
            protJOIN(skt,arg2,nck)
        else if (protType == "NKCH")
            protNKCH(skt,arg2,nck)
        else if (protType == "RQCD")
            protRQCD(skt,arg2,arg3)
    }
}

protMESG(skt,chn,nck="",msg=""){
    for n,s in client.chanKeep[chn]
        WS_Send(s, "MESG||" chn "||" nck "||" msg trm)
}

protJOIN(skt,chn,nck){
    if (client[skt].chans[chn])
    {
        WS_Send(skt, "JOIN||" chn "||" "||||You are already in '" chn "'")
        return
    }
    client[skt].addChan(chn)
    for n,s in client.chanKeep[chn]
        WS_Send(s, "JOIN||" chn "||" nck "||" client.getNkList(chn) trm)
}

protNKCH(skt,nnk,onk){
    StringReplace,nnk,nnk,%a_space%,,All
    onk := client[skt].nick
    client[skt].nick := nnk
    for c in client[skt].chans
        for n in client.chanKeep[c]
            list.=n " "
    sort,list,UD%a_space%
    list:=trim(list," ")
    loop,parse,list,%a_space%
        WS_Send(client.getSock(a_loopfield), "NKCH||" onk "||" nnk trm)
    client.removeNick(skt,onk,nnk)
}

protNWCD(skt,cod,ver){
    nck := client[skt].nick
    client[skt].addCode(cod,ver)
    for c in client.chanKeep
        for n, s in client.chanKeep[c]
            list.=s " "
    sort,list,UD%A_Space%
    list:=trim(list," ")
    loop, parse, list, %A_Space%
        if A_LoopField
            WS_Send(A_LoopField, "NWCD||" ver "||" nck "||Notice: """ nck """ submitted new code." trm)
}

protRQCD(skt,nck,ver){
    WS_Send(skt, "RQCD||" nck "||" ver "||" client[client.getsock(nck)].codes[ver] trm)
}

WS_OnClose(skt){
    for c in client.chanKeep
        for n,s in client.chanKeep[c]
        {
            if (s == skt)
                client.chanKeep[c].Remove(n)
            if (s != skt)
                list.=s " "
        }
    sort,list,UD%A_Space%
    list:=trim(list," ")
    loop,parse,list, %a_space%
        WS_Send(a_loopfield,"DISC||" client[skt].nick)
    client.sockNick.Remove(client[skt].nick)
    client[skt]:=""
    WS_CloseSocket(skt)
}

getRegexArgs(str, byref a1,byref a2,byref a3 = "",byref a4 = "",byref a5 = ""){
    RegexReplace(str, "\|\|", "", cnt)
    loop, %cnt%
        search.="(.*)\|\|"
    search .= "(.*)"
    RegexMatch(str, "^" search, a)
}

m(x*){
    for a,b in x
        list.=b "`n"
    MsgBox,% list
}

t(x*){
    for a,b in x
        list.=b "`n"
    ToolTip,% list
}

d(x*){
    for a,b in x
        list.=b "|"
    OutputDebug,%list%
}

class client {
	static chanKeep:=[],sockNick:=[]

    __New(val){
    	this.sock:=val
    }
    
    __Set(key,val){
        if (key == "nick")
            client.setSockNick(val,this.sock)
    }

    addCode(cod,ver){
        static codes:=[]
        this.codes[ver]:=cod
    }

    setSockNick(nck,skt){
        client.sockNick[nck]:=skt
    }

    getSock(nck){
        return client.sockNick[nck]
    }

    removeNick(skt,onk,nnk){
        client.sockNick.Remove(onk)
        client.setSockNick(nnk,skt)
        for c in client[skt].chans
        {
            client.chanKeep[c].Remove(onk)
            client.chanKeep[c,nnk] := skt
        }
    }

    addChan(chn){
    	static chans:=[]
    	this.chans[chn] := 1
    	client.chanKeep[chn,this.nick] := this.sock
    }

    getNkList(chn){
    	for n in client.chanKeep[chn]
    		list .= n " "
    	return trim(list," ")
    }
} ;

;// ~*Esc::
ExitRoutine:
    WS_CloseSocket(server)  ;//
    WS_Shutdown()
ExitApp
