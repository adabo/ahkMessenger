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

; Objects
occupiedChannels := Object()
channelChat      := Object()
channelNicks     := Object()

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
	Sleep 100
	WS_Send(client, "COMD||/JOIN #Main")
	currentChan := "#Main"
return

WS_OnRead(socket){
	Global sci, CodeID, EdNick, nNickList, currentChan, occupiedChannels, channelNicks, channelChat
	static firstVist


    sci[1].GotoPos(sci[1].GetLength())
	WS_Recv(socket, ServerMessage)
    RegexMatch(ServerMessage, "^(\w+)\|\|(\w+)\|?\|?(#?\w+ ?\w+)?\|?\|?(.+)?", arg)
    RegexMatch(ServerMessage, "(TITL|CODE|MESG|NWCD|DISC|NKCH|COMD|CHAN)\|\|(ENTER|LEAVE|MOTD|HELP|EXIT|[\w\d:'# ]+)\|\|([#\w\d\s]+)?\|?\|?([\w\d\s]+)?\|?\|?([#\w\d\s]+)?\|?\|?", mch)
	OutputDebug **client** **WS_OnRead** mch1,2,3,4,5 = %mch1% %mch2% %mch3% %mch4% %mch5%
    ;tooltip %mch1% %mch2% %mch3% %mch4% %mch5%
    /*
    args =
    (
    		arg1 = %arg1%
        arg2 = %arg2%
        arg3 = %arg3%
        arg4 = %arg4%
    )
    */
    msgType :=  arg1
	if      (msgType == "TITL")
    {
    	OutputDebug **client** **TITLE** arg2 = %arg2%
    	Gui, Main: Default
    	SB_SetText("Socket: " . arg2, 1)
    }
	else if (msgType == "CODE")
	{
		Gui, Code: Default
		nNick := arg2, nCode := arg3
		OutputDebug **client** **CODE** nNick, nCode = %nNick%, %nCode%
		;============== check if name exist in listview ===================;
		while (nNick != rowText)
		{
    		LV_GetText(rowText, A_Index, 2)
    		if (nNick == rowText)  ; Compare username from message to name in listview
    			LV_Modify(A_Index, "Icon" . 3)
    	}
		LV_ModifyCol(1)
		;===================================================================;
        sci[2].setReadOnly(false)
	    sci[2].ClearAll(), sci[2].AddText(strLen(str:=nCode), str), sci[2].GotoPos(sci[2].GetLength())
        sci[2].setReadOnly(true)
	}
	else if (msgType == "MESG")
	{
		nCmd := nNick := arg2, nChan := arg3, nMsg  := arg4
		OutputDebug **client** **MESG** nNick, nChan, nMsg = %nNick% %nChan% %nMsg%
		OutputDebug **client** **else if msgtype == MESG** nNick = %nNick%, nChan = %nChan%, nMsg = %nMsg%
		if (nCmd == "leave")
		{
			OutputDebug **Client** **if nCmd == leave**
		}
		if (nNick == "Server")
		{
			OutputDebug **client** **if currentChan == occupiedChannels[nChan]]**
	    	sci[1].setReadOnly(false)
	        sci[1].AddText(strLen(str:=nNick . ": " . nMsg "`n"), str), sci[1].GotoPos(sci[1].GetLength())
	        sci[1].setReadOnly(true)
		}
		else if (toLower(currentChan) == toLower(occupiedChannels[nChan]))  ; Checks if the message came from the focused chatroom
		{
			OutputDebug **client** **if currentChan == occupiedChannels[nChan]]**
	    	sci[1].setReadOnly(false)
	        sci[1].AddText(strLen(str:=nNick . ": " . nMsg "`n"), str), sci[1].GotoPos(sci[1].GetLength())
	        sci[1].setReadOnly(true)
	        IfWinnotActive, ahkMessenger Client
	        {
	        	loop 6
	        	{
	       			Gui, Main: Flash
	       			Sleep 500
	        	}
	            soundplay, *48
	        }
		}
		else
		{
			channelChat[nChan] .= nNick . ": " . nMsg "`n"  ; Store unfocused chatroom messages in array
		}
	}
	else if (msgType == "NWCD")
	{
		OutputDebug **client** **NWCD**
		nNick := arg2
    	Gui, Code: Default
		if (nNick == EdNick) ;Do not add icon to Own Nickname
		{
			if (!firstVist)
			{
				LV_Add("Icon" . 0, "", nNick) ;The username
				LV_ModifyCol(1)
				firstVist++
			}
			return
		}

		;============== check if name exist in listview ===================;
    	loop % LV_GetCount()
    	{
    		LV_GetText(rowText, A_Index, 2)
    		if (nNick == rowText)
    		{
    			namExist := True
    			LV_Modify(A_Index, "Icon" . 1, "")
    			break
    		}
    		else
    			namExist := False
    	}
    	if (!namExist)
			LV_Add("Icon" . 1, "", nNick)

		;===================================================================;

		LV_ModifyCol(1)
        sci[1].setReadOnly(false)
		sci[1].AddText(strLen(str:= "Notice: New code from: """ . nNick . """`n"), str)
        sci[1].setReadOnly(true)
	}
	else if (msgType == "DISC")
	{
		Gui, Main: Default
		nNick := arg2
		OutputDebug **client** **DISC** arg2 = %arg2%
    	sci[1].setReadOnly(false)
        sci[1].AddText(strLen(str:="Notice: '" . nNick . "' has diconnected.`n"), str), sci[1].GotoPos(sci[1].GetLength())
        sci[1].setReadOnly(true)
		loop % LV_GetCount()
		{
			LV_GetText(nm, A_Index, 2)
			if (nm == nNick)
			{
				OutputDebug **client** **if nm == nNick**
				lV_Delete(A_Index)
			}
		}
	}
    else if (msgType == "NKCH")
    {
    	nOldNick := mch2, nNick := mch3, nNickList := mch4, nChan := mch5
    	OutputDebug **client** **NKCH** nOldNick, nNick, nNickList, nChan = %nOldNick% %nNick% %nNickList% %nChan%

        /*
        	When a remote client changes their nick, the server
        	will send messages to all the clients that occupy
        	the same channels of said client.
        */
    	if (nChan == currentChan)
    	{
    		OutputDebug **client** **if nChan == currentChan** %nChan% == %currentChan%
	       	Gui, Main: Default
	    	lV_Delete()
	    	Loop, Parse, nNickList, %A_Space%
				LV_Add("" ,"", A_LoopField) ;The username
			channelNicks[nChan] := nNickList
	        sci[1].SetKeywords(1,nNickList)
	        sci[1].setReadOnly(false)
	        sci[1].AddText(strLen(str:="Notice: " nOldNick . " has changed their nick to: " . nNick . "`n"), str), sci[1].GotoPos(sci[1].GetLength())
	        sci[1].setReadOnly(true)
    	}
    	else
    	{
    		OutputDebug **client** **else if nchan != currentChan**
        	channelChat[nChan] .= "Notice: " nOldNick . " has changed their nick to: " . nNick . "`n"
        	channelNicks[nChan] := nNickList
    	}
    }
    else if (msgType == "COMD")
	{
		nMsg := mch2
		OutputDebug **client** **COMD** nMsg = %nMsg%
    	sci[1].setReadOnly(false)
    	sci[1].AddText(strLen(str:=nMsg "`n"), str), sci[1].GotoPos(sci[1].GetLength())
        sci[1].setReadOnly(true)
    }
    else if (msgType == "CHAN")
    {
    	nCmd := mch2, nChan := mch3, nNickList := mch4, nNick := mch5
    	OutputDebug **client** **CHAN** nCmd, nChan, nNickList, nNick = %nCmd% %nChan% %nNickList% %nNick%
    	if (nCmd == "ENTER")
    	{
    		OutputDebug **client** **if nChan == ENTER**
    		channelNicks[nChan] := nNickList
    		if (!occupiedChannels[nChan])                              ;
    		{                                                          ; Determines if the "ENTER" message was from
                sci[1].GetText(sci[1].GetLength()+1, sci1Text)         ; Copy chatlog to display when switching back
                sci[1].setReadOnly(false)
                channelChat[currentChan] := sci1Text                   ; a new client joining or your first "ENTER"/
                sci[1].ClearAll()
				sci[1].setReadOnly(true)
				occupiedChannels[nChan] := nChan, currentChan := arg3  ;
		        for k, v in occupiedChannels                           ;
		        {
		        	OutputDebug **client** *for kv in occupiedChannels** k, v = %k% %v%
		        	if (v == currentChan)
		        		v := "[" . v . "]"
		        	chanList .= v . " "
		        }
		    	Gui, Main: Default
		        SB_SetText(chanList, 3)
    		}

			if     (currentChan == nChan)  ; Use condition so the message log only updates the channel that is focused.
			{                              ; This condition is used to update the listview when a new client Joins the channel
				OutputDebug **client** **if currentChan == nChan** currentChan, nChan = %currentChan%, %nChan%
		    	sci[1].setReadOnly(false)
		        sci[1].AddText(strLen(str:="Notice: " . nNick . " has entered " . nChan . "`n"), str), sci[1].GotoPos(sci[1].GetLength())
		        sci[1].setReadOnly(true)
		    	Gui, Main: Default
		    	lV_Delete()
		    	Loop, Parse, nNickList, %A_Space%, %A_Space%
					LV_Add("" ,"", A_LoopField)  ; The username
			}
    	}
    }
}

;==== For DEBUGGING ONLY 
~*Esc::
;==== End DEBUG
MainGuiClose:
ExitRoutine:
	WS_CloseSocket(client)
	WS_Shutdown()
    ExitApp
