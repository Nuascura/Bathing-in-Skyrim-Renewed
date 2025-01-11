ScriptName mzinBatheCheckStatusQuest Extends Quest
{ this script reports the player's current dirtiness percentage }

GlobalVariable Property CheckStatusKeyCode Auto
GlobalVariable Property DirtyLevel Auto

Message Property DirtinessStatusMessage Auto

Event OnInit()
	RegisterHotKeys()
EndEvent

Function RegisterHotKeys()
	RegisterForKey(CheckStatusKeyCode.GetValueInt())
EndFunction

Function UnRegisterHotKeys()
	UnRegisterForKey(CheckStatusKeyCode.GetValueInt())
EndFunction

Event OnKeyDown(Int KeyCode)

	; don't trigger while in menu
	If Utility.IsInMenuMode()
		Return
	EndIf
	
	; display dirty level
	If KeyCode == CheckStatusKeyCode.GetValueInt()
		DirtinessStatusMessage.Show(DirtyLevel.GetValue() * 100)
	Endif
	
EndEvent
