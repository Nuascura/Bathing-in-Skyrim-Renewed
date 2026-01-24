ScriptName mzinBatheQuest Extends Quest
{ this script handles some functions needed by other scripts }

import PO3_SKSEFunctions

mzinInit Property Init Auto
mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto
mzinUtility Property mzinUtil Auto

GlobalVariable Property WaterRestrictionEnabled Auto
GlobalVariable Property GetSoapyStyle Auto
GlobalVariable Property GetSoapyStyleFollowers Auto

GlobalVariable Property DirtinessPercentage Auto

GlobalVariable Property GameDaysPassed Auto

FormList Property DirtyActors Auto
FormList Property WashPropList Auto
FormList Property SoapBonusSpellList Auto
FormList Property DirtinessSpellList Auto
FormList Property DirtinessThresholdList Auto
FormList Property WaterfallList Auto
FormList Property SoapBonusMessageList Auto
FormList Property GetDirtyOverTimeSpellList Auto

Keyword Property WashPropKeyword Auto
Keyword Property SoapKeyword Auto
Keyword Property AnimationKeyword Auto

Spell Property PlayBathingAnimation Auto

Message Property BathingNeedsWaterMessage Auto
Message Property BathingWithSoapMessage Auto
Message Property BathingWithoutSoapMessage Auto
Message Property ShoweringNeedsWaterMessage Auto
Message Property ShoweringWithSoapMessage Auto
Message Property ShoweringWithoutSoapMessage Auto

Actor Property PlayerRef Auto

Quest Property mzinGawkers Auto

Function RegForEvents()
	RegisterForModEvent("BiS_WashActor", "OnBiS_WashActor")
	RegisterForModEvent("BiS_WashActorFinish", "OnBiS_WashActorFinish")
EndFunction

Event OnBiS_WashActor(Form akDirtyActor, Form akWashProp = none, Bool abDoShower = false, bool abDoPlayerTeammates = false, Bool abDoAnimate = false, Bool abFullClean = false)
	If akDirtyActor as Actor
		WashActor(akDirtyActor as Actor, akWashProp as MiscObject, abDoShower, abDoPlayerTeammates, abDoAnimate, abFullClean)
	Else
		mzinUtil.LogTrace("OnBiS_WashActor(): Received invalid actor: " + akDirtyActor)
	EndIf
EndEvent

Event OnBiS_WashActorFinish(Form akBathingActor, Form akWashProp = none, Bool abFullClean = false)
	If akBathingActor as Actor
		WashActorFinish(akBathingActor as Actor, akWashProp as MiscObject, abFullClean)
	Else
		mzinUtil.LogTrace("OnBiS_WashActorFinish(): Received invalid actor: " + akBathingActor)
	EndIf
EndEvent

Bool Function TryWashActor(Actor DirtyActor, MiscObject WashProp, Bool Shower = false, Bool PlayerTeammates = false)
	If WashProp == None
		WashProp = TryFindWashProp(DirtyActor)
	EndIf
	If !IsRestricted(DirtyActor)
		If Shower
			If IsUnderWaterfall(DirtyActor)
				WashActor(DirtyActor, WashProp, true, PlayerTeammates && Menu.AutomateFollowerBathing.GetValue() > 0)
				return true
			Else
				mzinUtil.GameMessage(ShoweringNeedsWaterMessage)
			EndIf
		Else
			If IsInWater(DirtyActor)
				WashActor(DirtyActor, WashProp, false, PlayerTeammates && Menu.AutomateFollowerBathing.GetValue() > 0)
				return true
			Else
				mzinUtil.GameMessage(BathingNeedsWaterMessage)
			EndIf
		EndIf
	EndIf
	return false
EndFunction

Function WashActor(Actor DirtyActor, MiscObject WashProp = none, Bool DoShower = false, Bool DoPlayerTeammates = false, Bool DoAnimate = true, Bool DoFullClean = false)
	mzinUtil.Send_TargetedEvent(DirtyActor, "PauseActorDirt")

	Bool DirtyActorIsPlayer = (DirtyActor == PlayerRef)
	If DirtyActorIsPlayer
		UnregisterForAllKeys()
		mzinInterfaceFrostfall.MakeWet(Init.FrostfallRunning_var, 1000.0)
	EndIf

	If WashProp && WashProp.HasKeyWord(SoapKeyword) && DirtyActor.GetItemCount(WashProp) > 0
		DirtyActor.RemoveItem(WashProp, 1, True, None)
		DoFullClean = True
	EndIf

	if DoAnimate && !IsSubmerged(DirtyActor)
		if DirtyActorIsPlayer
			If DoShower
				if DoFullClean
					mzinUtil.GameMessage(ShoweringWithSoapMessage)
				else
					mzinUtil.GameMessage(ShoweringWithoutSoapMessage)
				endIf
			else
				if DoFullClean
					mzinUtil.GameMessage(BathingWithSoapMessage)
				else
					mzinUtil.GameMessage(BathingWithoutSoapMessage)
				endIf
			EndIf
		EndIf
		StorageUtil.SetFormValue(DirtyActor, "mzin_LastWashProp", WashProp)
		StorageUtil.SetIntValue(DirtyActor, "mzin_LastWashState", DoShower as int)
		DirtyActor.AddSpell(PlayBathingAnimation, False)
	Else
		WashActorFinish(DirtyActor, WashProp, DoFullClean)
	endIf

	mzinUtil.Send_ResetActorDirt(DirtyActor, DoFullClean)
	DirtyActor.ClearExtraArrows()
	SPE_ObjectRef.RemoveDecals(DirtyActor, true)
	mzinInterfaceSexLab.ClearCum(Init.SL_API, DirtyActor)
	mzinInterfaceOCum.OCClearCum(Init.OCA_API, DirtyActor)
	mzinInterfaceFadeTats.FadeTats(Init.FadeTats_API, DirtyActor, DoFullClean, Menu.FadeTatsFadeTime, Menu.FadeTatsSoapMult)
	mzinUtil.Send_BatheEvent(DirtyActor as Form, DoPlayerTeammates)
EndFunction

Function WashActorFinish(Actor DirtyActor, MiscObject WashProp = none, Bool DoFullClean = false)
	if (DirtyActor == PlayerRef || DirtyActors.Find(DirtyActor) != -1) \
	&& (DoFullClean || !DirtyActor.HasSpell(DirtinessSpellList.GetAt(0) As Spell))
		mzinUtil.RemoveSpells(DirtyActor, SoapBonusSpellList)
		If DoFullClean
			ApplySoapBonus(DirtyActor, WashProp)
		EndIf
	endIf
EndFunction

Function ResetGDOTSpell(Actor targetActor, Float targetValue)
	mzinUtil.RemoveSpells(targetActor, DirtinessSpellList)
	mzinUtil.RemoveSpells(targetActor, GetDirtyOverTimeSpellList)
	Int index = 0
	if targetValue != GetActorDirtPercent(targetActor)
		UpdateActorDirtPercent(targetActor, targetValue)
	endIf
	targetActor.AddSpell(GetGDOTSpell(targetValue, GetDirtyOverTimeSpellList.GetSize()), False)
	StorageUtil.SetFloatValue(targetActor, "BiS_LastUpdate", GameDaysPassed.GetValue())
EndFunction

Spell Function GetGDOTSpell(Float targetValue, int iMax, int iInit = 0)
	While iInit < iMax
		if targetValue <= (DirtinessThresholdList.GetAt(iInit) As GlobalVariable).GetValue()
			return GetDirtyOverTimeSpellList.GetAt(iInit) As Spell
		endIf
		iInit += 1
	EndWhile
	return GetDirtyOverTimeSpellList.GetAt(iInit) As Spell
EndFunction

Function ApplySoapBonus(Actor DirtyActor, MiscObject WashProp)
	If WashProp
		Int Index = GetSoapIndex(WashProp)
		DirtyActor.AddSpell(SoapBonusSpellList.GetAt(Index) As Spell, False)
		If DirtyActor == PlayerRef
			mzinUtil.GameMessage(SoapBonusMessageList.GetAt(Index) As Message)
		EndIf
	EndIf
EndFunction

Int Function GetSoapIndex(MiscObject WashProp)
	Int Index = WashPropList.Find(WashProp)
	If Index != -1
		return Index
	Else
		If WashProp.HasKeyword(SoapKeyword)
			return 1
		Else
			return 0
		EndIf
	EndIf
EndFunction

MiscObject Function TryFindWashProp(Actor DirtyActor)
	Keyword[] kwWashPropValid = new Keyword[2]
	kwWashPropValid[0] = SoapKeyword
	kwWashPropValid[1] = WashPropKeyword
	Form[] MiscObjects = AddItemsOfTypeToArray(DirtyActor, 32)
	Form[] WashPropArray = SPE_Utility.FilterFormsByKeyword(MiscObjects, kwWashPropValid, true, false)
	if WashPropArray
		return WashPropArray[Utility.RandomInt(0, WashPropArray.Length)] as MiscObject
	endIf
	
	Return SPE_Utility.FilterFormsByKeyword(MiscObjects, kwWashPropValid, false, false)[Utility.RandomInt(0, WashPropArray.Length)] as MiscObject
EndFunction

Bool Function IsInWater(Actor DirtyActor)
	if Init.IsWadeInWaterInstalled
		return !(WaterRestrictionEnabled.GetValue() As Bool) || DirtyActor.HasMagicEffect(Init.LokiWaterSlowdownEffect)
	else
		return !(WaterRestrictionEnabled.GetValue() As Bool) || IsActorInWater(DirtyActor)
	endIf
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
	return IsConditionallyRestricted(DirtyActor) || IsTooShy(DirtyActor, PotentialGawker)
EndFunction

Bool Function IsConditionallyRestricted(Actor DirtyActor)
	return IsDeviceBlocked(DirtyActor) || IsActorAnimating(DirtyActor) || DirtyActor.GetSitState() || IsNotPermitted(DirtyActor)
EndFunction

Bool Function IsActorAnimating(Actor DirtyActor)
	return DirtyActor.HasMagicEffectWithKeyword(AnimationKeyword) \
	|| mzinInterfaceSexLab.IsActorActive(Init.SL_API, DirtyActor) \
	|| (Init.IsOstimInstalled && mzinInterfaceOStim.IsActorActive(DirtyActor))
EndFunction

Bool Function IsDeviceBlocked(Actor akTarget)
	If Init.IsDeviousDevicesInstalled
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

		If akTarget == PlayerRef
			If !akGawker
				akGawker = GetGawker(akTarget)
			EndIf
			If akGawker && akGawker.HasLOS(akTarget)
				mzinUtil.LogNotification("No way am I bathing in front of " + akGawker.GetBaseObject().GetName() + "!")
				Return True
			EndIf
		ElseIf akTarget.IsPlayerTeammate()
			If !akGawker
				akGawker = GetGawker(akTarget)
			EndIf
			If akGawker && akGawker.HasLOS(akTarget)
				mzinUtil.LogNotification(akTarget.GetBaseObject().GetName() + ": You're joking, right? I'm not bathing in front of " +  akGawker.GetBaseObject().GetName() + "!")
				Return True
			EndIf
		Else
			If SPE_Actor.GetDetectedActors(akTarget)
				Return True
			EndIf
		EndIf
	EndIf
	Return False
EndFunction

Bool Function IsSubmerged(Actor akTarget)
	Return (akTarget.IsSwimming() || IsActorUnderwater(akTarget))
EndFunction

Bool Function IsWeatherWet(Actor akTarget)
	; This function is able to differentiate functional interiors from functional exteriors using the following logic:
		; Interior WorldSpace Cells flagged as Not Interior have an exterior location.
		; Exterior WorldSpace Cells flagged as Not Interior lack an exterior location.
		
	if akTarget.GetWorldSpace() && (GetWeatherType() < 2)
		Location[] ExteriorLocations = SPE_Cell.GetExteriorLocations(akTarget.GetParentCell())
		return !(ExteriorLocations && ExteriorLocations[0])
	endIf
	Return !akTarget.IsInInterior() && (GetWeatherType() < 2)
EndFunction

Actor Function GetGawker(Actor akActor)
	if mzinGawkers.Start()
		Actor Gawker = (mzinGawkers.GetNthAlias(0) as ReferenceAlias).GetReference() as Actor
		mzinGawkers.Reset()
		mzinGawkers.Stop()
		If Gawker && Gawker != akActor
			return Gawker
		EndIf
	endIf
	return none
EndFunction

Function UntrackActor(Actor DirtyActor, Bool abRemoveOverlays = true)
	if abRemoveOverlays
		OlUtil.ClearDirtGameLoad(DirtyActor)
	else
		StorageUtil.UnSetStringValue(DirtyActor, "mzin_DirtTexturePrefix")
	endIf

	mzinUtil.RemoveSpells(DirtyActor, GetDirtyOverTimeSpellList)
	mzinUtil.RemoveSpells(DirtyActor, DirtinessSpellList)
	mzinUtil.RemoveSpells(DirtyActor, SoapBonusSpellList)

	DirtyActors.RemoveAddedForm(DirtyActor)

	StorageUtil.UnSetFloatValue(DirtyActor, "BiS_Dirtiness")
	StorageUtil.UnSetFloatValue(DirtyActor, "BiS_LastUpdate")
	StorageUtil.UnSetFormValue(DirtyActor, "mzin_LastWashProp")
	StorageUtil.UnSetIntValue(DirtyActor, "mzin_LastWashState")

	if Init.IsSexLabInstalled
		if DirtyActor != PlayerRef
			mzinInterfaceSexLab.UntrackActor(Init.SL_API, DirtyActor, DirtyActor.GetFormID())
		endIf
	endIf
EndFunction

Function UpdateActorDirtPercent(Actor akActor, float afNewValue)
	If akActor == PlayerRef
		DirtinessPercentage.SetValue(afNewValue)
	elseIf DirtyActors.Find(akActor) != -1
		StorageUtil.SetFloatValue(akActor, "BiS_Dirtiness", afNewValue)
	EndIf
EndFunction

Float Function GetActorDirtPercent(Actor akActor)
	If akActor == PlayerRef
		return DirtinessPercentage.GetValue()
	ElseIf DirtyActors.Find(akActor) != -1
		StorageUtil.GetFloatValue(akActor, "BiS_Dirtiness")
	EndIf
EndFunction