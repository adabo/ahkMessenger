/*
Title: AHK Messenger
Author: adabo, RaptorX

	Legend:
		MESG|| = Message
		NWCD|| = New code
		USRN|| = User name
		RQST|| = Request Code
		USLS|| = User list
        NKCH|| = User Changed Nick
*/

#include <ws>
#include <SCI>
#include <chatGUI>
#include <attach>
#singleinstance force

type := "client"
OnExit, ExitRoutine

; GUI
    CreateGui()
	WS_Startup()

	;Port/Socket setup
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, test ? "127.0.0.1" : "99.23.4.199", "12345")
	WS_HandleEvents(client, "READ")
    
	WS_Send(client, "USRN||" . EdNick)
return

WS_OnRead(socket){
	Global sci, CodeID, EdNick, nickList
	static firstVist
	
	WS_Recv(socket, ServerMessage)

    msgType :=  SubStr(ServerMessage, 1 , 6)
    StringTrimLeft, ServerMessage, ServerMessage, 6

    if (msgTYpe == "USLS||")
    {

    	RegexMatch(ServerMessage, "^(.+?)\|\|", match)
        StringTrimLeft, ServerMessage, ServerMessage, strLen(match1) + 2
    	
    	Gui, Main: Default
    	lV_Delete()
    	Loop, Parse, ServerMessage, %A_Space%
			LV_Add("" ,"", A_LoopField) ;The username
        StringReplace, nickList, ServerMessage, %EdNick%%a_space%,,A
        sci[1].SetKeywords(1,nickList)
        sci[1].AddText(strLen(str := "Notice: " match1 . " has connected.`n"), str), sci.ScrollCaret()
    }
	else if (msgType == "CODE||")
	{
		Gui, Code: Default
		RegexMatch(ServerMessage, "^(.+?)\|\|", match)
		StringTrimLeft, ServerMessage, ServerMessage, strLen(match1) + 2 ;Get requested name from message

		;============== check if name exist in listview ===================;
		while (match1 != rowText)
		{
    		LV_GetText(rowText, A_Index, 2)
    		if (match1 == rowText) ;Compare username from message to name in listview
    			LV_Modify(A_Index, "Icon" . 3)
    	}
		LV_ModifyCol(1)
		;===================================================================;

	    sci[2].ClearAll(), sci[2].AddText(strLen(str:=ServerMessage), str), sci[2].ScrollCaret()
	}
	else if (msgType == "MESG||")
	{
        IfWinnotActive, ahkMessenger Client
            soundplay, *48
    	sci[1].AddText(strLen(str:=ServerMessage "`n"), str), sci[1].ScrollCaret()
	}
	else if (msgType == "NWCD||")
	{
    	Gui, Code: Default
		if (ServerMessage == NickName) ;Do not add icon to Own Nickname
		{
			if (!firstVist)
			{
				LV_Add("Icon" . 0, "", ServerMessage) ;The username
				LV_ModifyCol(1)
				firstVist++
			}
			return
		}

		;============== check if name exist in listview ===================;
    	loop % LV_GetCount()
    	{
    		LV_GetText(rowText, A_Index, 2)
    		if (ServerMessage == rowText)
    		{
    			namExist := True
    			LV_Modify(A_Index, "Icon" . 1, "")
    			break
    		}
    		else
    			namExist := False
    	}
    	if (!namExist)
			LV_Add("Icon" . 1, "", ServerMessage)


		;===================================================================;

		LV_ModifyCol(1)
		sci[1].AddText(strLen(str:= "Notice: New code from: """ . ServerMessage . """`n"), str)
	}
	else if (msgType == "DISC||")
	{
		Gui, Main: Default
		loop % LV_GetCount()
		{
			LV_GetText(nm, A_Index, 2)
				if (nm == ServerMessage)
					lV_Delete(A_Index)
		}
	}
    else if(msgType == "NKCH||")
    {
    	RegexMatch(ServerMessage, "^(.+?)\|\|", gOldNick) ; Old nick
    	StringTrimLeft, ServerMessage, ServerMessage, strLen(gOldNick1) + 2

    	RegexMatch(ServerMessage, "^(.+?)\|\|", gNewNick) ; Old nick
    	StringTrimLeft, ServerMessage, ServerMessage, strLen(gNewNick1) + 2
    	
       	Gui, Main: Default
    	lV_Delete()
    	Loop, Parse, ServerMessage, %A_Space%
			LV_Add("" ,"", A_LoopField) ;The username
        StringReplace, nickList, ServerMessage, %EdNick%%a_space%,,A
        sci[1].SetKeywords(1,nickList)
        sci[1].AddText(strLen(str:="Notice: " gOldNick1 . " has changed their nick to: " . gNewNick1 . "`n"), str), sci[1].ScrollCaret()
    }

}

MainGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
