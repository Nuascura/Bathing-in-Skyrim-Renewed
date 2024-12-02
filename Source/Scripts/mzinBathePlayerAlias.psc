ScriptName mzinBathePlayerAlias Extends ReferenceAlias

mzinBatheQuest Property BatheQuest Auto
Spell Property GetDirtyOverTimeReactivatorCloakSpell Auto

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