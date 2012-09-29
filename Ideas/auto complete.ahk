Gui, Main: Default
Gui, Main: Add, ListView, r10, Column
	LV_Add("", "Apple")
	LV_Add("", "Grape")
	LV_Add("", "Muffin")
	LV_Add("", "Banana")
Gui, Main: Add, Edit, w100 vGuiMessage gMessageInput HwndESmg +WantTab
Gui, Main: Show
return

MessageInput:
	Gui, Main: Submit, NoHide
	if (RegexMatch(GuiMessage, "(\t)$"))
	{
		if (pos := RegexMatch(GuiMessage, "ix)\s?(\w+)\s$", m))
		{
			loop % LV_GetCount()
			{
				LV_GetText(rowText, A_Index, 1)
				sub := SubStr(rowText, 1, StrLen(m1))
				StringLower, sub, sub
				if (m1 == sub)
				{
					StringTrimRight, GuiMessage, GuiMessage, % StrLen(m1) + 1
					GuiControl, Text, %ESmg%, %GuiMessage%%rowText%
					SendInput, {End}
				}
			}
		}
	}
return