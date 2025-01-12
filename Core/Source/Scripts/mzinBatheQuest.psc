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

Spell Property PlayBatheAnimationWithSoap Auto
Spell Property PlayBatheAnimationWithoutSoap Auto
Spell Property PlayShowerAnimationWithSoap Auto
Spell Property PlayShowerAnimationWithoutSoap Auto
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

Event OnBiS_WashActor(Form akDirtyActor, Form akWashProp, Bool Animate = false, Bool FullClean = false, Bool DoSoap = false, Bool Shower)
	;mzinUtil.LogMessageBox("Receive event")
	If akDirtyActor as Actor
		WashActor(akDirtyActor as Actor, akWashProp as MiscObject, Animate, FullClean, DoSoap, Shower)
	Else
		mzinUtil.LogTrace("OnBiS_WashActor(): Received invalid actor: " + akDirtyActor)
	EndIf
EndEvent

Event OnBiS_WashActorFinish(Form akBathingActor, Bool abUsingSoap = false)
	If akBathingActor as Actor
		WashActorFinish(akBathingActor as Actor, UsedSoap = abUsingSoap)
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
	If WashProp && !IsInCommmonRestriction(DirtyActor)
		If Shower
			If (!(WaterRestrictionEnabled.GetValue() As Bool) || IsUnderWaterfall(DirtyActor))
				WashActor(DirtyActor, WashProp, DoShower = true)
				return true
			Else
				mzinUtil.GameMessage(ShoweringNeedsWaterMessage)
			EndIf
		Else
			If IsInWater(DirtyActor)
				WashActor(DirtyActor, WashProp, DoShower = false)
				return true
			Else
				mzinUtil.GameMessage(BathingNeedsWaterMessage)
			EndIf
		EndIf
	EndIf
	return false
EndFunction

Function WashActor(Actor DirtyActor, MiscObject WashProp, Bool Animate = true, Bool FullClean = false, Bool DoSoap = false, Bool DoShower = false)
	Bool DirtyActorIsPlayer = (DirtyActor == PlayerRef)
	Bool UsedSoap = false
	If DirtyActorIsPlayer
		UnregisterForAllKeys()
		PlayerAlias.RunCycleHelper()
		mzinInterfaceFrostfall.MakeWet(1000.0)
		OlUtil.SendBathePlayerModEvent()
	EndIf

	if Animate
		If WashProp && WashProp.HasKeyWord(SoapKeyword)
			UsedSoap = true
			DirtyActor.RemoveItem(WashProp, 1, True, None)
			if DoShower
				DirtyActor.AddSpell(PlayShowerAnimationWithSoap, False)
				If DirtyActorIsPlayer
					mzinUtil.GameMessage(ShoweringWithSoapMessage)
				EndIf
			else
				DirtyActor.AddSpell(PlayBatheAnimationWithSoap, False)
				If DirtyActorIsPlayer
					mzinUtil.GameMessage(BathingWithSoapMessage)
				EndIf
			EndIf
		Else
			if DoShower
				DirtyActor.AddSpell(PlayShowerAnimationWithoutSoap, False)
				If DirtyActorIsPlayer
					mzinUtil.GameMessage(ShoweringWithSoapMessage)
				EndIf
			else
				DirtyActor.AddSpell(PlayBatheAnimationWithoutSoap, False)	
				If DirtyActorIsPlayer
					mzinUtil.GameMessage(BathingWithSoapMessage)
				EndIf
			EndIf
		EndIf
		StorageUtil.SetFormValue(DirtyActor, "mzin_LastWashProp", WashProp)
	else
		If DoSoap
			GetSoapy(DirtyActor)
		EndIf
		If FullClean
			UsedSoap = true
		EndIf
	endIf

	DirtyActor.ClearExtraArrows()
	SPE_ObjectRef.RemoveDecals(DirtyActor, true)
	SexlabInt.SlClearCum(DirtyActor)
	mzinInterfacePaf.ClearPafDirt(DirtyActor)
	mzinInterfaceOCum.OCClearCum(DirtyActor)
	mzinInterfaceFadeTats.FadeTats(DirtyActor, UsedSoap, Menu.FadeTatsFadeTime, Menu.FadeTatsSoapMult)
	
	SendCleanDirtEvent(DirtyActor, UsedSoap)

	; ----

	if !Animate
		If DoSoap
			GetUnsoapy(DirtyActor)
		EndIf
		WashActorFinish(DirtyActor, WashProp, UsedSoap)
	endIf
	
	OlUtil.SendBatheModEvent(DirtyActor as Form)
EndFunction

Function WashActorFinish(Actor DirtyActor, MiscObject WashProp = none, Bool UsedSoap = false)
	if StorageUtil.HasFormValue(DirtyActor, "mzin_LastWashProp")
		WashProp = StorageUtil.PluckFormValue(DirtyActor, "mzin_LastWashProp") as MiscObject
	endIf

	if (DirtyActor == PlayerRef || DirtyActors.Find(DirtyActor) != -1) \
	&& (UsedSoap || !DirtyActor.HasSpell(GetDirtyOverTimeSpellList.GetAt(0) As Spell))
		RemoveSpells(DirtyActor, SoapBonusSpellList)
		RemoveSpells(DirtyActor, DirtinessSpellList)
		RemoveSpells(DirtyActor, GetDirtyOverTimeSpellList)
		StorageUtil.SetFloatValue(DirtyActor, "BiS_LastUpdate", Utility.GetCurrentGameTime())
		
		If WashProp
			ApplySoapBonus(DirtyActor, WashProp)
			DirtyActor.AddSpell(GetDirtyOverTimeSpellList.GetAt(0) As Spell, False)
			If DirtyActor != PlayerRef
				StorageUtil.SetFloatValue(DirtyActor, "BiS_Dirtiness", 0.0)
			EndIf
		Else
			DirtyActor.AddSpell(GetDirtyOverTimeSpellList.GetAt(1) As Spell, False)
			If DirtyActor != PlayerRef
				StorageUtil.SetFloatValue(DirtyActor, "BiS_Dirtiness", (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue())
			EndIf
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

Bool Function IsUnderWaterfall(Actor DirtyActor)
	; If Game.FindClosestReferenceOfAnyTypeInListFromRef(WaterfallList, DirtyActor, 128.0)				; Hazarduss
		; Return True																					; Hazarduss
	; EndIf																								; Hazarduss
	
	; ===================================== HAZARDUSS - Start edit ==============================================
; HAZARDUSS - 2021/09: Extending the range of waterfall detection.  
; This is necessary because the shower code does not always trigger when standing at the bottom of a waterfall.
; This is likely because certain water static objects in 'WaterfallList' do not extend across the full height of the actual waterfall.
; So we need to make sure that if the character is standing at any height (Z position) at or below the water static object, they should be able to shower.

	; ObjectReference closestWaterfall = Game.FindClosestReferenceOfAnyTypeInListFromRef(WaterfallList, DirtyActor, 12800.0)	
	ObjectReference closestWaterfall = Game.FindClosestReferenceOfAnyTypeInListFromRef(WaterfallList, DirtyActor, 3000.0)	
	
	; If Game.FindClosestReferenceOfAnyTypeInListFromRef(WaterfallList, DirtyActor, 1280.0)	
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
			mzinUtil.LogTrace("IsUnderWaterfall = true")
			; mzinUtil.LogNotification("IsUnderWaterfall = true")
		Return True
		else
			mzinUtil.LogNotification("A waterfall detected nearby")
			mzinUtil.LogTrace("A waterfall detected nearby")
			
		EndIf
	Else
		mzinUtil.LogNotification("There is no waterfall to shower under")
		mzinUtil.LogTrace("There is no waterfall to shower under")
	EndIf
	; 
	; ===================================== HAZARDUSS - End edit ==============================================

	; mzinUtil.LogNotification("IsUnderWaterfall = False")
	; mzinUtil.LogTrace("IsUnderWaterfall = False")
	; mzinUtil.LogMessageBox("IsUnderWaterfall = False")

	Return False
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

Bool Function IsInCommmonRestriction(Actor DirtyActor)
	return (IsDeviceBlocked(DirtyActor) || !IsPermitted(DirtyActor) || IsTooShy(DirtyActor) || DirtyActor.IsSwimming() || IsBathing(DirtyActor))
EndFunction

Bool Function IsInWater(Actor DirtyActor)
	return (!(WaterRestrictionEnabled.GetValue() As Bool) || PO3_SKSEfunctions.IsActorInWater(DirtyActor) \
	|| (Init.IsWadeInWaterInstalled && DirtyActor.HasMagicEffect(Game.GetFormFromFile(0x000D62, "WadeInWater.esp") as MagicEffect)))
EndFunction

Bool Function IsBathing(Actor DirtyActor)
	return DirtyActor.HasMagicEffectWithKeyword(AnimationKeyword)
EndFunction

Bool Function IsDeviceBlocked(Actor akTarget)
	If Init.IsDdsInstalled
		If akTarget.WornHasKeyword(Init.zad_DeviousHeavyBondage)
			mzinUtil.LogNotification("You can't wash yourself with your hands tied")
			Return True
		ElseIf akTarget.WornHasKeyword(Init.zad_DeviousSuit)
			mzinUtil.LogNotification("You can't wash yourself while wearing this suit")
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
EndFunction

Bool Function IsPermitted(Actor akTarget)
	Int Index = StorageUtil.FormListFind(none, "BiS_ForbiddenActors", akTarget)
	If Index != -1
		Int ForbiddenCount = StorageUtil.StringListCount(akTarget, "BiS_ForbiddenString") - 1
		String ForbiddenString = StorageUtil.StringListGet(akTarget, "BiS_ForbiddenString", ForbiddenCount)
		If ForbiddenString != ""
			mzinUtil.LogNotification(ForbiddenString)
		Else
			mzinUtil.LogTrace("IsPermitted: Blank string retrieved for index " + ForbiddenCount + " on actor " + akTarget)
		EndIf
		
		; Send forbidden bathe attempt modevent
		Int ForbiddenBatheAttempt = ModEvent.Create("BiS_ForbiddenBatheAttempt")
		If (ForbiddenBatheAttempt)
			ModEvent.PushForm(ForbiddenBatheAttempt, akTarget)
			ModEvent.Send(ForbiddenBatheAttempt)
		EndIf
		Return False
	Else
		Return True
	EndIf
EndFunction

Bool Function IsTooShy(Actor akTarget)
	If Menu.Shyness
		If Game.GetModByName("SexLabAroused.esm") != 255
			Faction ExhibitionistFact = Game.GetFormFromFile(0x0713DA, "SexLabAroused.esm") as Faction
			If ExhibitionistFact != None
				If akTarget.GetFactionRank(ExhibitionistFact) >= 0
					Return False
				EndIf
			EndIf
		EndIf
		
		mzinGawkers.Stop()
		mzinGawkers.Start()
		Utility.Wait(0.1)

		Actor Gawker
		Int i = 0 
		While i < mzinGawkers.GetNumAliases()
			Gawker = (mzinGawkers.GetNthAlias(i) as ReferenceAlias).GetReference() as Actor
			If Gawker != None && Gawker != akTarget
				If !IsGawkerSlave(Gawker)
					If Gawker.HasLOS(PlayerRef)
						DoShyMessage(akTarget, Gawker)
						Return True
					EndIf
					If !akTarget.IsInInterior()
						If akTarget.GetDistance(Gawker) < Menu.ShyDistance
							DoShyMessage(akTarget, Gawker)
							Return True
						EndIf
					EndIf
				EndIf
			EndIf
			i += 1
		EndWhile
		Return False
	
	Else
		Return False
	EndIf
EndFunction

Function DoShyMessage(Actor akTarget, Actor Gawker)
	If akTarget == PlayerRef
		mzinUtil.LogNotification("No way am I bathing in front of " + Gawker.GetBaseObject().GetName())
	Else
		mzinUtil.LogNotification(akTarget.GetBaseObject().GetName() + ": You're joking right? I'm not bathing in front of " + Gawker.GetBaseObject().GetName())
	EndIf
EndFunction

Bool Function IsGawkerSlave(Actor Gawker)
	If Init.IsZazInstalled
		If Gawker.IsInFaction(Init.ZazSlaveFaction)
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
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