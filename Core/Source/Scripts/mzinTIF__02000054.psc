;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname mzinTIF__02000054 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
RemoveSpells(akSpeaker, GetDirtyOverTimeSpellList)
RemoveSpells(akSpeaker, DirtinessSpellList)
RemoveSpells(akSpeaker, SoapBonusSpellList)
DirtyActors.RemoveAddedForm(akSpeaker)
Utility.Wait(2.0) ; Give time for the magic effec to end which normally would only re-add storageUtil variables. See GetDirtyOverTime Mgef
StorageUtil.UnSetFloatValue(akSpeaker, "BiS_Dirtiness")
StorageUtil.UnSetFloatValue(akSpeaker, "BiS_LastUpdate")
Util.ClearDirtGameLoad(akSpeaker)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Function RemoveSpells(Actor DirtyActor, FormList SpellFormList)
	Int SpellListIndex = SpellFormList.GetSize()
	While SpellListIndex
		SpellListIndex -= 1
		DirtyActor.RemoveSpell(SpellFormList.GetAt(SpellListIndex) As Spell)	
	EndWhile
EndFunction

FormList Property DirtyActors Auto

FormList Property GetDirtyOverTimeSpellList Auto
FormList Property DirtinessSpellList Auto
FormList Property SoapBonusSpellList Auto

mzinOverlayUtility Property Util Auto
