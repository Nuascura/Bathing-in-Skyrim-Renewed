ScriptName mzinBathePlayerAlias Extends ReferenceAlias

mzinUtility Property mzinUtil Auto
mzinBatheQuest Property BatheQuest Auto
FormList Property DirtyActors Auto
GlobalVariable Property AutomateFollowerBathing Auto
GlobalVariable Property BatheKeyCode Auto
GlobalVariable Property ModifierKeyCode Auto
GlobalVariable Property CheckStatusKeyCode Auto
GlobalVariable Property DirtinessPercentage Auto
Message Property DirtinessStatusMessage Auto

Actor Property PlayerRef Auto

Event OnPlayerLoadGame() ; run only when mod is "enabled"
	BatheQuest.RegForEvents()
	RegisterHotKeys()

	RegisterForModEvent("BiS_BatheEvent_" + PlayerRef.GetFormID(), "OnBiS_BatheEvent_Player")
	RegisterForModEvent("BiS_GDOTStateChange_" + PlayerRef.GetFormID(), "OnBiS_GDOTStateChange_Player")
EndEvent

; ---------- Bathing Event ----------

Event OnBiS_BatheEvent_Player(Bool abArg)
	if abArg
		Utility.Wait(1.0)
		CycleTeammate(PO3_SKSEfunctions.GetPlayerFollowers(), BatheQuest.GetGawker(PlayerRef))
	endIf
EndEvent

Function CycleTeammate(Actor[] PlayerFollowers, Actor LastGawker)
	int i = 0
	if AutomateFollowerBathing.GetValue() == 1.0 ; Tracked Only
		while i < PlayerFollowers.Length
			if DirtyActors.HasForm(PlayerFollowers[i])
				TryWashTeammate(PlayerFollowers[i], LastGawker)
			endIf
			i += 1
		endWhile
	elseIf AutomateFollowerBathing.GetValue() == 2.0 ; All Teammates
		while i < PlayerFollowers.Length
			TryWashTeammate(PlayerFollowers[i], LastGawker)
			i += 1
		endWhile
	endIf
EndFunction

Function TryWashTeammate(Actor akTarget, Actor akGawker)
	MiscObject WashProp = BatheQuest.TryFindWashProp(akTarget)
	if WashProp && !(BatheQuest.IsRestricted(akTarget, akGawker))
		if BatheQuest.IsInWater(akTarget)
			BatheQuest.WashActor(akTarget, WashProp, DoShower = false)
		ElseIf BatheQuest.IsUnderWaterfall(akTarget)
			BatheQuest.WashActor(akTarget, WashProp, DoShower = true)
		EndIf
	EndIf
EndFunction

; ---------- Hotkey Event ----------

Event OnBiS_GDOTStateChange_Player(string NewState, string DefaultState)
	if NewState && (NewState != DefaultState)
		GoToState("PauseKeyCheck")
	endIf
EndEvent

State PauseKeyCheck
	Event OnKeyDown(Int KeyCode)
		If Utility.IsInMenuMode() || SPE_Actor.GetPlayerSpeechTarget() || UI.IsTextInputEnabled()
			mzinUtil.LogTrace("Received OnKeyDown event, but player state was toggled.")
		EndIf
	EndEvent
	Event OnBiS_GDOTStateChange_Player(string NewState, string DefaultState)
		if !NewState || (NewState == DefaultState)
			GoToState("")
		endIf
	EndEvent
EndState

Event OnKeyDown(Int KeyCode)
	If Utility.IsInMenuMode() || SPE_Actor.GetPlayerSpeechTarget() || UI.IsTextInputEnabled()
		return
	EndIf
	
	UnregisterForAllKeys()
	If KeyCode == CheckStatusKeyCode.GetValue() as int
		ObjectReference crosshairRef = Game.GetCurrentCrosshairRef()
		If crosshairRef as Actor
			mzinUtil.LogNotification(crosshairRef.GetBaseObject().GetName() + " feels " + Math.Floor(StorageUtil.GetFloatValue(crosshairRef, "BiS_Dirtiness") * 100.0) + "% dirty.")
		Else
			mzinUtil.GameMessage(DirtinessStatusMessage, DirtinessPercentage.GetValue() * 100)
		EndIf
	ElseIf KeyCode == BatheKeyCode.GetValue() as int
		if Input.IsKeyPressed(ModifierKeyCode.GetValue() as int) 
			if BatheQuest.TryWashActor(PlayerRef, None, true, true)
				return
			endIf
		else
			if BatheQuest.TryWashActor(PlayerRef, None, false, true)
				return
			endIf
		endIf
	EndIf
	RegisterHotKeys()
EndEvent

Function RegisterHotKeys()
	UnregisterForAllKeys()
	If BatheKeyCode.GetValue() as int != 0
		RegisterForKey(BatheKeyCode.GetValue() as int)
	EndIf
	If CheckStatusKeyCode.GetValue() as int != 0
		RegisterForKey(CheckStatusKeyCode.GetValue() as int)
	EndIf
EndFunction