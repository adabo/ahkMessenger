;// Includes
    #Include lib\ws.ahk

;// Directives
    #singleinstance Force
    OnExit, ExitRoutine

;// Variables
    WS_LOGTOCONSOLE := 1
    ;// global trm      := "!"
    global trm      := chr(13) chr(10)
    ;// trm:=chr(4)

;// Program start
    initialize_WS()  ;
return

WS_OnAccept(skt){
    skt := WS_Accept(skt, client_ip, client_port)
    client[skt] := new client(skt)
    nck := client[skt].nick := "Guest" A_TickCount
    WS_Send(skt, "USRN||" nck trm)
    sleep 100
    i:=0
    loop
    {
        random, r, 97, 99
        if (old == r)
            continue
        else
            protJOIN(skt,"#" chr(r),nck)
        old:=r,i++
        if (i == 2)
            break
    }
}

initialize_WS(){
    WS_Startup()
    server := WS_Socket("TCP", "IPv4")
    WS_Bind(server, "0.0.0.0", "12345")
    WS_Listen(server)
    WS_HandleEvents(server, "ACCEPT READ CLOSE")
}

WS_OnRead(skt){
    WS_Recv(skt, c),ClientMessage:=rtrim(c,"`n"),nck := client[skt].nick
    Loop, Parse, ClientMessage, `n
    {
        if !(ClientMessage := rtrim(A_LoopField,"`r`n"))
            return
        getRegexArgs(ClientMessage,arg1,arg2,arg3,arg4,arg5),protType := arg1
        ;// mb(arg1,arg2,arg3,arg4,arg5)
        if      (protType == "MESG")
            protMESG(skt,arg2,nck,arg3)
        else if (protType == "NWCN")
            protNWCN()
        else if (protType == "JOIN")
            protJOIN(skt,arg2,nck)
        else if (protType == "NKCH")
            protNKCH(skt,arg2,nck)
        else if (protType == "NWCD")
            protNWCD()
    }
}

protMESG(skt,chn,nck="",msg=""){
    for n,s in client.chanKeep[chn]
        WS_Send(s, "MESG||" chn "||" nck "||" msg trm)
}

protNWCN(){
    
}

protJOIN(skt,chn,nck){
    client[skt].addChan(chn)
    for n,s in client.chanKeep[chn]
        WS_Send(s, "JOIN||" chn "||" nck "||" client.getNkList(chn) trm)
}

protNKCH(skt,nnk,onk){
    dlist := [],clist:=[],j:=0
    onk := client[skt].nick
    client[skt].nick := nnk
    for i,c in client[skt].chans
        for n in client.chanKeep[c]
            dlist[++j] := n
    for i,n in dlist
        for ii,nn in dlist
            if (n==clist[ii])
                break
            else if (i ==ii)
                clist[ii] := n,WS_Send(client.getSock(n), "NKCH||" onk "||" nnk)
    ;// client.chanKeep[chn,this.nick] := this.sock
}

protNWCD(){
    
}

WS_Close(){
}

getRegexArgs(str, byref a1,byref a2,byref a3 = "",byref a4 = "",byref a5 = ""){
    ;// Find terminator code "¥"    
    RegexReplace(str, "\|\|", "", cnt)
    loop, %cnt%
        search.="(.*)\|\|"
    search .= "(.*)"
    RegexMatch(str, "^" search, a)
}

mb(x*){
    for a,b in x
        list.=b "`n"
    MsgBox,% list
}

tt(x*){
    for a,b in x
        list.=b "`n"
    ToolTip,% list
}

db(x*){
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
            client.setGetSock(val,this.sock)
    }

    setGetSock(nck,skt){
        client.sockNick[nck]:=skt
    }

    getSock(nck){
        return client.sockNick[nck]
    }

    addChan(chn){
    	static chans:=[],i:=1
    	this.chans[i++] := chn
    	client.chanKeep[chn,this.nick] := this.sock
    }

    getNkList(chn){
    	for n in client.chanKeep[chn]
    		list .= n " "
    	return trim(list," ")
    }
} ;
/*
f1::
*/
~*Esc::
ExitRoutine:
    WS_CloseSocket(server)  ;//
    WS_Shutdown()
ExitApp
