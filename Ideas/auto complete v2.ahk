Gui, Main: Default
Gui, Main: Add, ListView, r10, Column
	LV_Add("", "Apple")
	LV_Add("", "Grape")
	LV_Add("", "Muffin")
	LV_Add("", "Banana")
Gui, Main: Add, Edit, w300 vGuiMessage gMessageInput HwndESmg +WantTab
Gui, Main: Show
return

MessageInput:
	Gui, Main: Submit, NoHide
	SendMessage, 0x00B0,,,, AHK_ID%Esmg%             ; Get Caret position
	caretPos := MakeShort(ErrorLevel)                ; Assign to variable
	StringMid, leftChars, GuiMessage, 0, %caretPos%  ; Grab all text BEFORE (to the left) of the caret
	if (RegexMatch(leftChars, "ix)\s?(\w+)\t$", m))  ; Test if a Tab was pressed
	{
		loop % LV_GetCount()
		{
			LV_GetText(rowText, A_Index, 1)
			sub := SubStr(rowText, 1, StrLen(m1))
			StringLower, sub, sub
			if (m1 == sub)
			{
				startOfWord := caretPos - (StrLen(m1) + 1)
				SendMessage, 0x00B1, startOfWord, caretPos,, AHK_ID%ESmg%  ; EM_SETSEL
				SendMessage, 0x00C2,, &rowText,, AHK_ID%ESmg%  ; EM_REPLACESEL
			}
		}
	}
return

MakeShort(Long) {
 return Long & 0xffff
}