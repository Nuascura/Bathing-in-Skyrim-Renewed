Scriptname mzinInterfaceSexlab extends Quest  

Quest SlQuest

Event OnInit()
	RegisterForModEvent("mzin_Int_PlayerLoadsGame", "On_mzin_Int_PlayerLoadsGame")
EndEvent

Event On_mzin_Int_PlayerLoadsGame(string eventName, string strArg, float numArg, Form sender)
	PlayerLoadsGame()
EndEvent

Function PlayerLoadsGame()
	If Game.GetModByName("SexLab.esm") != 255
		If GetState() != "Installed"
			GoToState("Installed")
		EndIf
	
	Else
		If GetState() != ""
			GoToState("")
		EndIf
	EndIf
EndFunction

Bool Function GetIsInterfaceActive()
	If GetState() == "Installed"
		Return true
	EndIf
	Return false
EndFunction

; Installed =======================================

State Installed
	Actor[] Function GetSexActors(Int tid)
		Return mzinIntSexlab.GetSexActors(SlQuest, tid)
	EndFunction

	Bool Function SlIsActorActive(Actor akTarget)
		Return mzinIntSexlab.SlIsActorActive(SlQuest, akTarget)
	EndFunction

	Bool Function SlIsVictim(Int tid, Actor akTarget)
		Return mzinIntSexlab.SlIsVictim(SlQuest, tid, akTarget)
	EndFunction

	Function SlClearCum(Actor akTarget)
		mzinIntSexlab.SlClearCum(SlQuest, akTarget)
	EndFunction
EndState

; Not Installed ====================================

Actor[] Function GetSexActors(Int tid)
	Actor[] Blah = new Actor[1]
	Return Blah
EndFunction

Bool Function SlIsActorActive(Actor akTarget)
	Return false
EndFunction

Bool Function SlIsVictim(Int tid, Actor akTarget)
	Return false
EndFunction

Function SlClearCum(Actor Target)
EndFunction

Event OnEndState()
	Utility.Wait(5.0) ; Wait before entering active state to help avoid making function calls to scripts that may not have initialized yet.
	
	SlQuest = Game.GetFormFromFile(0x000D62, "SexLab.esm") as Quest
EndEvent
