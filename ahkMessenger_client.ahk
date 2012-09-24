/*
Title: AHK Messenger
Author: adabo, RaptorX

	Legend:
		MESG|| = Message
		NWCD|| = New code
		USRN|| = User name
		RQST|| = Request Code
		USLS|| = User list
*/

#include <ws>
#include <SCI>
#include <chatGUI>
#singleinstance force
; test := true

NickName := A_UserName
OnExit, ExitRoutine

; GUI
    CreateClientGui()

; Initialize
	;WS_LOGTOCONSOLE := 1
	WS_Startup()
    
; Port/Socket setup
	client := WS_Socket("TCP", "IPv4")
	WS_Connect(client, test ? "127.0.0.1" : "99.23.4.199", "12345")
	WS_HandleEvents(client, "READ")
	WS_Send(client, "USRN||" . NickName)
return

WS_OnRead(socket){
	Global sci, CodeID, NickName, nickList
	static firstVist
	
	WS_Recv(socket, ServerMessage)

    msgType :=  SubStr(ServerMessage, 1 , 6)
    StringTrimLeft, ServerMessage, ServerMessage, 6

    if (msgTYpe == "USLS||")
    {
    	Gui, CltMain: Default
    	lV_Delete()
    	Loop, Parse, ServerMessage, %A_Space%
			LV_Add("" ,"", A_LoopField) ;The username
        StringReplace, nickList, ServerMessage, %NickName%%a_space%,,A
        sci[1].SetKeywords(1,nickList)
    }
	else if (msgType == "CODE||")
	{
		Gui, CltCode: Default
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
    	sci[1].AddText(strLen(str:=ServerMessage "`n"), str), sci[1].ScrollCaret()
	}
	else if (msgType == "NWCD||")
	{
    	Gui, CltCode: Default
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
	}
	else if (msgType == "DISC||")
	{
		Gui, CltMain: Default
		loop % LV_GetCount()
		{
			LV_GetText(nm, A_Index, 2)
				if (nm == ServerMessage)
					lV_Delete(A_Index)
		}
	}
}

CltMainGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
