ScriptName mzinBathePlayerAlias Extends ReferenceAlias

mzinBatheQuest Property BatheQuest Auto
FormList Property DirtyActors Auto
GlobalVariable Property AutomateFollowerBathing Auto

Actor Property PlayerRef Auto

Event OnPlayerLoadGame() ; run only when mod is "enabled"
	BatheQuest.RegisterHotKeys()
	BatheQuest.RegForEvents()

	RegisterForModEvent("BiS_BatheEvent_" + PlayerRef.GetFormID(), "OnBiS_BatheEvent")
EndEvent

Event OnBiS_BatheEvent(Bool abArg)
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