ScriptName mzinBathePlayerAlias Extends ReferenceAlias

mzinBatheQuest Property BatheQuest Auto
FormList Property DirtyActors Auto
GlobalVariable Property AutomateFollowerBathing Auto

Actor Property PlayerRef Auto

Bool Reapplying

Event OnPlayerLoadGame() ; run only when mod is "enabled"
	BatheQuest.RegisterHotKeys()
	BatheQuest.RegForEvents()
EndEvent

Event OnUpdate()
	CycleFollowers()
EndEvent

Function RunCycleHelper()
	RegisterForSingleUpdate(1.0)
EndFunction

Function CycleFollowers()
	if AutomateFollowerBathing.GetValue() < 1
		return
	endIf
	Actor[] PlayerFollowers = PO3_SKSEfunctions.GetPlayerFollowers()
	int i = 0
	while i < PlayerFollowers.Length
		if DirtyActors.Find(PlayerFollowers[i]) != -1 || AutomateFollowerBathing.GetValue() == 2
			MiscObject WashProp = BatheQuest.TryFindWashProp(PlayerFollowers[i])
			if WashProp && !BatheQuest.IsInCommmonRestriction(PlayerFollowers[i])
				if BatheQuest.IsInWater(PlayerFollowers[i])
					BatheQuest.WashActor(PlayerFollowers[i], WashProp, DoShower = false)
				ElseIf BatheQuest.IsUnderWaterfall(PlayerFollowers[i])
					BatheQuest.WashActor(PlayerFollowers[i], WashProp, DoShower = true)
				EndIf
			EndIf
		endIf
		i += 1
	endWhile
EndFunction