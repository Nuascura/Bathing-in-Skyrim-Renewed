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

Event OnPlayerLoadGame()
	if BatheQuest.BathingInSkyrimEnabled.GetValue() As Bool
		BatheQuest.RegisterHotKeys()
		BatheQuest.RegForEvents()
	endIf
EndEvent

Event OnUpdate()
	CycleFollowers()
EndEvent

Function RunCycleHelper()
	RegisterForSingleUpdate(1.0)
EndFunction

Function CycleFollowers()
	Debug.Trace("mzin CycleFollowers()")
	Actor[] PlayerFollowers = PO3_SKSEfunctions.GetPlayerFollowers()
	int i = 0
	while i < PlayerFollowers.Length
		if DirtyActors.Find(PlayerFollowers[i]) != -1 || AutomateFollowerBathing.GetValue() == 2
			MiscObject WashProp = BatheQuest.TryFindWashProp(PlayerFollowers[i])
			if WashProp && !BatheQuest.IsInCommmonRestriction(PlayerFollowers[i])
				if PO3_SKSEfunctions.IsActorInWater(PlayerFollowers[i])
					BatheQuest.BatheActor(PlayerFollowers[i], WashProp)
				ElseIf BatheQuest.IsUnderWaterfall(PlayerFollowers[i])
					BatheQuest.ShowerActor(PlayerFollowers[i], WashProp)
				EndIf
			EndIf
		endIf
		i += 1
	endWhile
EndFunction