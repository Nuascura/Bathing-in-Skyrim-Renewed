ScriptName mzinBatheQuest Extends Quest
{ this script handles some functions needed by other scripts }

mzinInit Property Init Auto
mzinBatheMCMMenu Property Menu Auto
mzinInterfaceSexlab Property SexlabInt Auto
mzinOverlayUtility Property OlUtil Auto
mzinUtility Property mzinUtil Auto
mzinBathePlayerAlias Property PlayerAlias Auto

GlobalVariable Property WaterRestrictionEnabled Auto
GlobalVariable Property GetSoapyStyle Auto
GlobalVariable Property GetSoapyStyleFollowers Auto

GlobalVariable Property BatheKeyCode Auto
GlobalVariable Property ShowerKeyCode Auto
GlobalVariable Property CheckStatusKeyCode Auto

GlobalVariable Property DirtinessPercentage Auto

FormList Property DirtyActors Auto
FormList Property WashPropList Auto
FormList Property SoapBonusSpellList Auto
FormList Property DirtinessSpellList Auto
FormList Property DirtinessThresholdList Auto
FormList Property WaterfallList Auto
FormList Property SoapBonusMessageList Auto
FormList Property GetDirtyOverTimeSpellList Auto

Keyword Property SoapKeyword Auto
Keyword Property AnimationKeyword Auto

Spell Property PlayBathingAnimation Auto
Spell Property SoapyAppearanceSpell Auto
Spell Property SoapyAppearanceAnimatedSpell Auto

Message Property BathingNeedsWaterMessage Auto
Message Property BathingWithSoapMessage Auto
Message Property BathingWithoutSoapMessage Auto
Message Property ShoweringWithSoapMessage Auto
Message Property ShoweringWithoutSoapMessage Auto

Message Property ShoweringNeedsWaterMessage Auto
Message Property DirtinessStatusMessage Auto

Actor Property PlayerRef Auto

Quest Property mzinGawkers Auto

Function RegForEvents()
	RegisterForModEvent("BiS_WashActor", "OnBiS_WashActor")
	RegisterForModEvent("BiS_WashActorFinish", "OnBiS_WashActorFinish")
EndFunction

Event OnBiS_WashActor(Form akDirtyActor, Form akWashProp, Bool abDoShower, bool abDoPlayerTeammates = false, Bool abDoAnimate = false, Bool abFullClean = false, Bool abDoSoap = false)
	If akDirtyActor as Actor
		WashActor(akDirtyActor as Actor, akWashProp as MiscObject, abDoShower, abDoPlayerTeammates, abDoAnimate, abFullClean, abDoSoap)
	Else
		mzinUtil.LogTrace("OnBiS_WashActor(): Received invalid actor: " + akDirtyActor)
	EndIf
EndEvent

Event OnBiS_WashActorFinish(Form akBathingActor, Form akWashProp, Bool abUsingSoap = false)
	If akBathingActor as Actor
		WashActorFinish(akBathingActor as Actor, akWashProp as MiscObject, abUsingSoap)
	Else
		mzinUtil.LogTrace("OnBiS_WashActorFinish(): Received invalid actor: " + akBathingActor)
	EndIf
EndEvent

Event OnKeyDown(Int KeyCode)
	If !Utility.IsInMenuMode()
		UnregisterForAllKeys()
		If KeyCode == CheckStatusKeyCode.GetValueInt()
			mzinUtil.GameMessage(DirtinessStatusMessage, DirtinessPercentage.GetValue() * 100)
		ElseIf (KeyCode == BatheKeyCode.GetValueInt() && TryWashActor(PlayerRef, None, false)) \
		|| (KeyCode == ShowerKeyCode.GetValueInt() && TryWashActor(PlayerRef, None, true))
			return
		Endif
		RegisterHotKeys()
	EndIf
EndEvent

Function RegisterHotKeys()
	UnregisterForAllKeys()
	If BatheKeyCode.GetValueInt() != 0
		RegisterForKey(BatheKeyCode.GetValueInt())
	EndIf
	If ShowerKeyCode.GetValueInt() != 0
		RegisterForKey(ShowerKeyCode.GetValueInt())
	EndIf
	If CheckStatusKeyCode.GetValueInt() != 0
		RegisterForKey(CheckStatusKeyCode.GetValueInt())
	EndIf
EndFunction

Bool Function TryWashActor(Actor DirtyActor, MiscObject WashProp, Bool Shower = false)
	If WashProp == None
		WashProp = TryFindWashProp(DirtyActor)
	EndIf
	If !IsRestricted(DirtyActor)
		If Shower
			If IsUnderWaterfall(DirtyActor)
				WashActor(DirtyActor, WashProp, true, (DirtyActor == PlayerRef))
				return true
			Else
				mzinUtil.GameMessage(ShoweringNeedsWaterMessage)
			EndIf
		Else
			If IsInWater(DirtyActor)
				WashActor(DirtyActor, WashProp, false, (DirtyActor == PlayerRef))
				return true
			Else
				mzinUtil.GameMessage(BathingNeedsWaterMessage)
			EndIf
		EndIf
	EndIf
	return false
EndFunction

Function WashActor(Actor DirtyActor, MiscObject WashProp, Bool DoShower = false, Bool DoPlayerTeammates = false, Bool DoAnimate = true, Bool DoFullClean = false, Bool DoSoap = false)
	Bool DirtyActorIsPlayer = (DirtyActor == PlayerRef)
	Bool UsedSoap = false
	If DirtyActorIsPlayer
		UnregisterForAllKeys()
		mzinInterfaceFrostfall.MakeWet(Init.FrostfallRunning_var, 1000.0, Init.IsFrostFallInstalled)
		OlUtil.SendBathePlayerModEvent()
	EndIf
	If DoPlayerTeammates
		PlayerAlias.RunCycleHelper()
	endIf

	if DoAnimate
		If WashProp && WashProp.HasKeyWord(SoapKeyword)
			UsedSoap = true
			DirtyActor.RemoveItem(WashProp, 1, True, None)
		EndIf
		if DirtyActorIsPlayer
			If DoShower
				if UsedSoap
					mzinUtil.GameMessage(ShoweringWithSoapMessage)
				else
					mzinUtil.GameMessage(ShoweringWithoutSoapMessage)
				endIf
			else
				if UsedSoap
					mzinUtil.GameMessage(BathingWithSoapMessage)
				else
					mzinUtil.GameMessage(BathingWithoutSoapMessage)
				endIf
			EndIf
		EndIf
		StorageUtil.SetFormValue(DirtyActor, "mzin_LastWashProp", WashProp)
		StorageUtil.SetIntValue(DirtyActor, "mzin_LastWashState", DoShower as int)
		DirtyActor.AddSpell(PlayBathingAnimation, False)
	else
		If DoSoap
			GetSoapy(DirtyActor)
		EndIf
		If DoFullClean
			UsedSoap = true
		EndIf
	endIf

	DirtyActor.ClearExtraArrows()
	SPE_ObjectRef.RemoveDecals(DirtyActor, true)
	SexlabInt.SlClearCum(DirtyActor)
	mzinInterfacePaf.ClearPafDirt(Init.PAF_API, DirtyActor, Init.IsPAFInstalled)
	mzinInterfaceOCum.OCClearCum(Init.OCA_API, DirtyActor, Init.IsOCumInstalled)
	mzinInterfaceFadeTats.FadeTats(Init.FadeTats_API, DirtyActor, UsedSoap, Menu.FadeTatsFadeTime, Menu.FadeTatsSoapMult, Init.IsFadeTattoosInstalled)
	
	SendCleanDirtEvent(DirtyActor, UsedSoap)

	; ----

	if !DoAnimate
		If DoSoap
			GetUnsoapy(DirtyActor)
		EndIf
		WashActorFinish(DirtyActor, WashProp, UsedSoap)
	endIf
	
	OlUtil.SendBatheModEvent(DirtyActor as Form)
EndFunction

Function WashActorFinish(Actor DirtyActor, MiscObject WashProp = none, Bool UsedSoap = false)
	if (DirtyActor == PlayerRef || DirtyActors.Find(DirtyActor) != -1) \
	&& (UsedSoap || !DirtyActor.HasSpell(DirtinessSpellList.GetAt(0) As Spell))
		RemoveSpells(DirtyActor, SoapBonusSpellList)
		RemoveSpells(DirtyActor, DirtinessSpellList)
		RemoveSpells(DirtyActor, GetDirtyOverTimeSpellList)
		StorageUtil.SetFloatValue(DirtyActor, "BiS_LastUpdate", Utility.GetCurrentGameTime())
		If WashProp
			UpdateActorDirtPercent(DirtyActor, 0.0)
			ApplySoapBonus(DirtyActor, WashProp)
			DirtyActor.AddSpell(GetDirtyOverTimeSpellList.GetAt(0) As Spell, False)
		Else
			UpdateActorDirtPercent(DirtyActor, (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue())
			DirtyActor.AddSpell(GetDirtyOverTimeSpellList.GetAt(1) As Spell, False)
		EndIf
	endIf

	if DirtyActor == PlayerRef
		RegisterHotKeys()
	EndIf
EndFunction

Function ApplySoapBonus(Actor DirtyActor, MiscObject WashProp)
	If WashProp
		Int Index = GetWashPropIndex(WashProp)
		Spell SoapBonusSpell = SoapBonusSpellList.GetAt(Index) As Spell
		DirtyActor.AddSpell(SoapBonusSpell, False)
		If DirtyActor == PlayerRef
			mzinUtil.GameMessage(SoapBonusMessageList.GetAt(Index) As Message)
		EndIf
	EndIf
EndFunction

Function RemoveSpells(Actor DirtyActor, FormList SpellsFormList)
	Int Index = SpellsFormList.GetSize()
	While Index
		Index -= 1
		DirtyActor.RemoveSpell(SpellsFormList.GetAt(Index) As Spell)	
	EndWhile
EndFunction

MiscObject Function TryFindWashProp(Actor DirtyActor)
	Int WashPropIndex = WashPropList.GetSize()

	While WashPropIndex
		WashPropIndex -= 1
		MiscObject WashProp = WashPropList.GetAt(WashPropIndex) As MiscObject
		If DirtyActor.GetItemCount(WashProp) > 0
			Return WashProp
		EndIf		
	EndWhile
	
	Return None
EndFunction
Int Function GetWashPropIndex(MiscObject Soap)
	Int WashPropIndex = WashPropList.GetSize()

	While WashPropIndex
		WashPropIndex -= 1		
		If WashPropList.GetAt(WashPropIndex) As MiscObject == Soap
			Return WashPropIndex
		EndIf		
	EndWhile
	
	Return -1
EndFunction

Bool Function IsInWater(Actor DirtyActor)
	return (!(WaterRestrictionEnabled.GetValue() As Bool) || PO3_SKSEfunctions.IsActorInWater(DirtyActor) \
	|| (Init.IsWadeInWaterInstalled && DirtyActor.HasMagicEffect(Init.LokiWaterSlowdownEffect)))
EndFunction

Bool Function IsUnderWaterfall(Actor DirtyActor)
	If !(WaterRestrictionEnabled.GetValue() As Bool)
		Return True
	EndIf

	ObjectReference closestWaterfall = Game.FindClosestReferenceOfAnyTypeInListFromRef(WaterfallList, DirtyActor, 3000.0)	
	
	If closestWaterfall

		mzinUtil.LogTrace("player_Z() = " + DirtyActor.GetPositionZ() + "     Waterfall_Z = " + closestWaterfall.GetPositionZ() + "  diff_Z = " + (DirtyActor.GetPositionZ() - closestWaterfall.GetPositionZ()) as float)
		; mzinUtil.LogNotification("player_Z() = " + DirtyActor.GetPositionZ() + "     Waterfall_Z = " + closestWaterfall.GetPositionZ() + "  diff_Z = " + (DirtyActor.GetPositionZ() - closestWaterfall.GetPositionZ()) as float)
		mzinUtil.LogTrace("player_X() = " + DirtyActor.GetPositionX() + "     Waterfall_X() = " + closestWaterfall.GetPositionX() + "  diff_X = " + (DirtyActor.GetPositionX() - closestWaterfall.GetPositionX()) as float)
		; mzinUtil.LogNotification("player_X() = " + DirtyActor.GetPositionX() + "     Waterfall_X() = " + closestWaterfall.GetPositionX() + "  diff_X = " + (DirtyActor.GetPositionX() - closestWaterfall.GetPositionX()) as float)
		mzinUtil.LogTrace("player_Y() = " + DirtyActor.GetPositionY() + "     Waterfall_Y() = " + closestWaterfall.GetPositionY() + "  diff_Y = " + (DirtyActor.GetPositionY() - closestWaterfall.GetPositionY()) as float)
		; mzinUtil.LogNotification("player_Y() = " + DirtyActor.GetPositionY() + "     Waterfall_Y() = " + closestWaterfall.GetPositionY() + "  diff_Y = " + (DirtyActor.GetPositionY() - closestWaterfall.GetPositionY()) as float)


		; PC can shower when standing within 2 character lengths of the waterfall (256 units), and at any height below it.
		if (DirtyActor.GetPositionZ() <= closestWaterfall.GetPositionZ() + 1280.0) \
		&& (math.abs(DirtyActor.GetPositionX() - closestWaterfall.GetPositionX()) <= 256.0) \
		&& (math.abs(DirtyActor.GetPositionY() - closestWaterfall.GetPositionY()) <= 256.0)
			Return True
		else
			mzinUtil.LogTrace("There is a waterfall nearby, but the player isn't under it.")
		EndIf
	EndIf

	Return False
EndFunction

Bool Function IsRestricted(Actor DirtyActor, Actor PotentialGawker = None)
	return IsInCommmonRestriction(DirtyActor) || IsTooShy(DirtyActor, PotentialGawker)
EndFunction

Bool Function IsInCommmonRestriction(Actor DirtyActor)
	return (IsDeviceBlocked(DirtyActor) || IsNotPermitted(DirtyActor) || IsInInvalidCondition(DirtyActor))
EndFunction

Bool Function IsInInvalidCondition(Actor DirtyActor)
	return DirtyActor.IsSwimming() || DirtyActor.HasMagicEffectWithKeyword(AnimationKeyword) || PO3_SKSEfunctions.IsActorUnderwater(DirtyActor)
EndFunction

Bool Function IsDeviceBlocked(Actor akTarget)
	If Init.IsDdsInstalled
		If akTarget.WornHasKeyword(Init.zad_DeviousHeavyBondage)
			if akTarget == PlayerRef
				mzinUtil.LogNotification("You can't wash yourself with your hands tied")
			endIf
			Return True
		ElseIf akTarget.WornHasKeyword(Init.zad_DeviousSuit)
			if akTarget == PlayerRef
				mzinUtil.LogNotification("You can't wash yourself while wearing this suit")
			endIf
			Return True
		EndIf
	EndIf
	Return False
EndFunction

Bool Function IsNotPermitted(Actor akTarget)
	Int Index = StorageUtil.FormListFind(none, "BiS_ForbiddenActors", akTarget)
	If Index != -1
		Int ForbiddenCount = StorageUtil.StringListCount(akTarget, "BiS_ForbiddenString") - 1
		String ForbiddenString = StorageUtil.StringListGet(akTarget, "BiS_ForbiddenString", ForbiddenCount)
		If ForbiddenString != ""
			mzinUtil.LogNotification(ForbiddenString)
		Else
			mzinUtil.LogTrace("IsNotPermitted: Blank string retrieved for index " + ForbiddenCount + " on actor " + akTarget)
		EndIf
		
		; Send forbidden bathe attempt modevent
		Int ForbiddenBatheAttempt = ModEvent.Create("BiS_ForbiddenBatheAttempt")
		If (ForbiddenBatheAttempt)
			ModEvent.PushForm(ForbiddenBatheAttempt, akTarget)
			ModEvent.Send(ForbiddenBatheAttempt)
		EndIf
		Return True
	Else
		Return False
	EndIf
EndFunction

Bool Function IsTooShy(Actor akTarget, Actor akGawker = none)
	If Menu.Shyness
		If Init.IsSexlabArousedInstalled && akTarget.GetFactionRank(Init.SLAExhibitionistFaction) >= 0
			Return False
		EndIf

		If !akGawker
			akGawker = GetGawker(akTarget)
		EndIf
		
		If akGawker
			if akTarget == PlayerRef
				mzinUtil.LogNotification("No way am I bathing in front of " + akGawker.GetBaseObject().GetName() + "!")
			elseIf akTarget.IsPlayerTeammate()
				mzinUtil.LogNotification(akTarget.GetBaseObject().GetName() + ": You're joking, right? I'm not bathing in front of " +  akGawker.GetBaseObject().GetName() + "!")
			else
				mzinUtil.LogNotification(akTarget.GetBaseObject().GetName() + " refuses to bathe in front of " + akGawker.GetBaseObject().GetName() + ".")
			endIf
			Return True
		EndIf
	EndIf
	Return False
EndFunction

Actor Function GetGawker(Actor akActor)
	mzinGawkers.Stop()
	if mzinGawkers.Start()
		Actor Gawker = (mzinGawkers.GetNthAlias(0) as ReferenceAlias).GetReference() as Actor
		mzinGawkers.Stop()
		If Gawker && Gawker != akActor
			return Gawker
		EndIf
	endIf
	return none
EndFunction

Function GetSoapy(Actor akActor)
	If akActor == PlayerRef
		If GetSoapyStyle.GetValue() == 1
			akActor.AddSpell(SoapyAppearanceSpell, False)
		ElseIf GetSoapyStyle.GetValue() == 2
			akActor.AddSpell(SoapyAppearanceAnimatedSpell, False)
		EndIf
	Else
		If GetSoapyStyleFollowers.GetValue() == 1
			akActor.AddSpell(SoapyAppearanceSpell, False)
		ElseIf GetSoapyStyleFollowers.GetValue() == 2
			akActor.AddSpell(SoapyAppearanceAnimatedSpell, False)
		EndIf
	EndIf
EndFunction

Function GetUnsoapy(Actor akActor)
	If akActor.HasSpell(SoapyAppearanceSpell)
		akActor.RemoveSpell(SoapyAppearanceSpell)
	ElseIf akActor.HasSpell(SoapyAppearanceAnimatedSpell)
		akActor.RemoveSpell(SoapyAppearanceAnimatedSpell)
	EndIf
EndFunction

Function UntrackActor(Actor DirtyActor, Bool abRemoveOverlays = true)
	if abRemoveOverlays
		OlUtil.ClearDirtGameLoad(DirtyActor)
	endIf

	RemoveSpells(DirtyActor, GetDirtyOverTimeSpellList)
	RemoveSpells(DirtyActor, DirtinessSpellList)
	RemoveSpells(DirtyActor, SoapBonusSpellList)

	DirtyActors.RemoveAddedForm(DirtyActor)

	StorageUtil.UnSetFloatValue(DirtyActor, "BiS_Dirtiness")
	StorageUtil.UnSetFloatValue(DirtyActor, "BiS_LastUpdate")
	StorageUtil.UnSetStringValue(DirtyActor, "mzin_DirtTexturePrefix")
	StorageUtil.UnSetFormValue(DirtyActor, "mzin_LastWashProp")
	StorageUtil.UnSetIntValue(DirtyActor, "mzin_LastWashState")
EndFunction

Function UpdateActorDirtPercent(Actor akActor, float afNewValue)
	If akActor == PlayerRef
		DirtinessPercentage.SetValue(afNewValue)
	elseIf DirtyActors.Find(akActor) != -1
		StorageUtil.SetFloatValue(akActor, "BiS_Dirtiness", afNewValue)
	EndIf
EndFunction

Function SendCleanDirtEvent(Form akTarget, Bool UsedSoap)
	int BiS_CleanActorDirtEvent = ModEvent.Create("BiS_CleanActorDirt")
    If (BiS_CleanActorDirtEvent)
		ModEvent.PushForm(BiS_CleanActorDirtEvent, akTarget)
		ModEvent.PushFloat(BiS_CleanActorDirtEvent, Menu.TimeToClean)
		ModEvent.PushFloat(BiS_CleanActorDirtEvent, Menu.TimeToCleanInterval)
		ModEvent.PushBool(BiS_CleanActorDirtEvent, UsedSoap)
        ModEvent.Send(BiS_CleanActorDirtEvent)
    EndIf
EndFunction