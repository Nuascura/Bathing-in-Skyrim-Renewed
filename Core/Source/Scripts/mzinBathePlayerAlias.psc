ScriptName mzinBathePlayerAlias Extends ReferenceAlias

mzinBatheQuest Property BatheQuest Auto
Spell Property GetDirtyOverTimeReactivatorCloakSpell Auto
FormList Property DirtyActors Auto
GlobalVariable Property AutomateFollowerBathing Auto

Actor Property PlayerRef Auto

Bool Reapplying

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	If Reapplying == False
		Reapplying = True
		PlayerRef.RemoveSpell(GetDirtyOverTimeReactivatorCloakSpell)
		Utility.Wait(1)
		PlayerRef.AddSpell(GetDirtyOverTimeReactivatorCloakSpell, False)
		Reapplying = False
	EndIf
EndEvent

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
				if PO3_SKSEfunctions.IsActorInWater(PlayerFollowers[i])
					BatheQuest.WashActor(PlayerFollowers[i], WashProp, DoShower = false)
				ElseIf BatheQuest.IsUnderWaterfall(PlayerFollowers[i])
					BatheQuest.WashActor(PlayerFollowers[i], WashProp, DoShower = true)
				EndIf
			EndIf
		endIf
		i += 1
	endWhile
EndFunction