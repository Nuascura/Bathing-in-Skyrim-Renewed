ScriptName mzinPlayBathingAnimation Extends ActiveMagicEffect
{ this script plays bathing and showering animations based on properties }

mzinInit Property Init Auto
mzinBatheMCMMenu Property Menu Auto
mzinBatheQuest Property BatheQuest Auto
mzinUtility Property mzinUtil Auto

Bool Property UsingSoap Auto
Bool Property Showering Auto

Spell Property PlayBatheAnimationWithSoap Auto
Spell Property PlayBatheAnimationWithoutSoap Auto
Spell Property PlayShowerAnimationWithSoap Auto
Spell Property PlayShowerAnimationWithoutSoap Auto

FormList Property DirtinessSpellList Auto

FormList Property BathingAnimationLoopCountList Auto
FormList Property BathingAnimationLoopCountListFollowers Auto
FormList Property PlayerHouseLocationList Auto
FormList Property DungeonLocationList Auto
FormList Property SettlementLocationList Auto

GlobalVariable Property GetSoapyStyle Auto
GlobalVariable Property GetSoapyStyleFollowers Auto

GlobalVariable Property BathingAnimationStyle Auto
GlobalVariable Property BathingAnimationStyleFollowers Auto

GlobalVariable Property ShoweringAnimationStyle Auto
GlobalVariable Property ShoweringAnimationStyleFollowers Auto

GlobalVariable Property GetDressedAfterBathingEnabled Auto
GlobalVariable Property GetDressedAfterBathingEnabledFollowers Auto

GlobalVariable Property ForceCustomAnimationDuration Auto

Spell Property SoapyAppearanceSpell Auto
Spell Property SoapyAppearanceAnimatedSpell Auto

Idle Property mzinBatheA1_S1_Soap Auto
Idle Property mzinBatheA1_S1_Cloth Auto

Idle Property mzinBatheA2_S1_Soap Auto
Idle Property mzinBatheA2_S1_Cloth Auto

Idle Property mzinBatheA3_S1_Soap Auto
Idle Property mzinBatheA3_S1_Cloth Auto

Idle Property mzinBatheA4_S0 Auto

Idle Property mzinBatheA5_T1 Auto
Idle Property mzinBatheA5_T2 Auto
Idle Property mzinBatheA5_T3 Auto
Idle Property mzinBatheA5_T4 Auto

Idle Property mzinBatheMA1_S1_Soap Auto
Idle Property mzinBatheMA1_S1_Cloth Auto

Idle Property mzinBatheMA2_S1_Soap Auto
Idle Property mzinBatheMA2_S1_Cloth Auto

Idle Property mzinBatheMA3_S1_Soap Auto
Idle Property mzinBatheMA3_S1_Cloth Auto

Message Property BathingCompleteMessage Auto

Package Property StopMovementPackage Auto

Armor[] Clothing
Actor  BathingActor
Bool   BathingActorIsPlayer
Int AnimationStyle
Int ShowerStyle
Int TieredSetCondition
Float[] AnimSet
Int Property DirtinessTier
	Int Function Get()
		Int DirtinessTierIndex = DirtinessSpellList.GetSize()
		While DirtinessTierIndex
			DirtinessTierIndex -= 1
			If BathingActor.HasSpell(DirtinessSpellList.GetAt(DirtinessTierIndex) As Spell)
				return DirtinessTierIndex
			EndIf
		EndWhile
	EndFunction
EndProperty
Int Property DangerTier
	Int Function Get()
		Location CurrentLocation = BathingActor.GetCurrentLocation()
		Location[] LocationList = SPE_Cell.GetExteriorLocations(BathingActor.GetParentCell())
		if CurrentLocation
			If BathingActor.IsInInterior() && mzinUtil.LocationHasKeyWordInList(CurrentLocation, PlayerHouseLocationList)
				return 4
			ElseIf mzinUtil.LocationHasKeyWordInList(CurrentLocation, SettlementLocationList) \
				|| (BathingActor.IsInInterior() && mzinUtil.ExteriorHasKeyWordInList(LocationList, SettlementLocationList))
				return 3
			ElseIf mzinUtil.LocationHasKeyWordInList(CurrentLocation, DungeonLocationList) \
				|| (BathingActor.IsInInterior() && mzinUtil.ExteriorHasKeyWordInList(LocationList, DungeonLocationList))
				return 1
			endIf
		endIf
		return 2
	EndFunction
EndProperty

Event OnEffectStart(Actor Target, Actor Caster)
	BathingActor = Target
	ForbidSex(BathingActor, Forbid = true)
	BathingActorIsPlayer = (Target == BatheQuest.PlayerRef)
	RegisterAnimationEvent()
	StartAnimation()
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	ForbidSex(BathingActor, Forbid = false)
EndEvent

; bathing
Function PresetSequenceDefault()
	Int AnimationCyclesRemaining = 0

	if BathingActorIsPlayer
		AnimationCyclesRemaining = (BathingAnimationLoopCountList.GetAt(DirtinessTier) As GlobalVariable).GetValue() As Int
	else
		AnimationCyclesRemaining = (BathingAnimationLoopCountListFollowers.GetAt(DirtinessTier) As GlobalVariable).GetValue() As Int
	endIf

	GetSoapy()

	While AnimationCyclesRemaining > 0	
		AnimationCyclesRemaining -= 1	
		Debug.SendAnimationEvent(BathingActor, "IdleWarmArms")
		Utility.Wait(2)
		Debug.SendAnimationEvent(BathingActor, "IdleStop")
		Utility.Wait(1)
	EndWhile

	StopAnimation(true)
EndFunction
Function PresetSequenceDebug(Idle anim, Float animDuration)
	if ForceCustomAnimationDuration.GetValue() > 0
		animDuration = ForceCustomAnimationDuration.GetValue()
	endIf
	BathingActor.PlayIdle(anim)
	Utility.Wait(animDuration)
	StopAnimation()
EndFunction

; helpers
Function StartAnimation()
	SetAutoTerminate()

	If BathingActorIsPlayer
		AnimationStyle = BathingAnimationStyle.GetValue() as int
		ShowerStyle = ShoweringAnimationStyle.GetValue() as int
	else
		AnimationStyle = BathingAnimationStyleFollowers.GetValue() as int
		ShowerStyle = ShoweringAnimationStyleFollowers.GetValue() as int
	EndIf

	If AnimationStyle > 0 && !BathingActor.IsSwimming()
		GetNaked()
		If BathingActorIsPlayer
			Game.ForceThirdPerson()
			BathingActor.SetHeadTracking(false)
			Game.DisablePlayerControls(True, True, False, False, True, True, True)
			UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", false)
			if Menu.AutoPlayerTFC 
				SetFreeCam(true)
			endIf
			if BathingActor.GetActorBase().GetSex() == 1
				AnimSet = Menu.AnimCustomFSet
			else
				AnimSet = Menu.AnimCustomMSet
			endIf
			TieredSetCondition = Menu.AnimCustomTierCond
		else
			ActorUtil.AddPackageOverride(BathingActor, StopMovementPackage, 1)
			BathingActor.EvaluatePackage()
			if BathingActor.GetActorBase().GetSex() == 1
				AnimSet = Menu.AnimCustomFSetFollowers
			else
				AnimSet = Menu.AnimCustomMSetFollowers
			endIf
			TieredSetCondition = Menu.AnimCustomTierCondFollowers
		EndIf
		Debug.SendAnimationEvent(BathingActor, "IdleStop_Loose")
		if BathingActor.GetActorBase().GetSex() == 1
			GetAnimationFemale(GetPresetSequence(AnimSet, AnimationStyle, ShowerStyle), showering, TieredSetCondition)
		else
			GetAnimationMale(GetPresetSequence(AnimSet, AnimationStyle, ShowerStyle), showering, TieredSetCondition)
		endIf
	else
		EffectFinish()
	EndIf
EndFunction
int Function GetPresetSequence(float[] animList, int animStyle, int overrideStyle)
	; Vanilla Animations
	If animStyle == 1
		return animStyle

	; Custom Animations
	elseIf showering
		if overrideStyle == 0
			return animStyle + mzinUtil.GetRandomFromNormalization(animList)
		else
			return 2 ; to-do adjust when more showering styles are available
		endIf
	else
		return animStyle + mzinUtil.GetRandomFromNormalization(animList)
	endIf
EndFunction
Function GetAnimationFemale(int aiPreset, bool abOverride = false, int aiTierCond)
	int randomStyle = 0
	if aiPreset == 1
		RinseOn()
		PresetSequenceDefault()
	elseIf aiPreset == 2
		Idle[] BathingStyle = new Idle[3]
		if UsingSoap
			BathingStyle[0] = mzinBatheA1_S1_Soap
			BathingStyle[1] = mzinBatheA2_S1_Soap
			BathingStyle[2] = mzinBatheA3_S1_Soap
		else
			BathingStyle[0] = mzinBatheA1_S1_Cloth
			BathingStyle[1] = mzinBatheA2_S1_Cloth
			BathingStyle[2] = mzinBatheA3_S1_Cloth
		endIf

		if !abOverride
			randomStyle = Utility.RandomInt(0, BathingStyle.Length - 1)
		endIf

		RinseOn()
		BathingActor.PlayIdle(BathingStyle[randomStyle])
	elseIf aiPreset == 3
		BathingActor.PlayIdle(mzinBatheA4_S0)
	elseIf aiPreset == 4
		Idle[] BathingStyle = new Idle[4]
		BathingStyle[0] = mzinBatheA5_T1
		BathingStyle[1] = mzinBatheA5_T2
		BathingStyle[2] = mzinBatheA5_T3
		BathingStyle[3] = mzinBatheA5_T4

		if aiTierCond == 1
			randomStyle = DirtinessTier
		elseIf aiTierCond == 2
			randomStyle = DangerTier
		else
			randomStyle = Utility.RandomInt(0, BathingStyle.Length - 1)
		endIf

		BathingActor.PlayIdle(BathingStyle[randomStyle])
	endIf
EndFunction
Function GetAnimationMale(int aiPreset, bool abOverride = false, int aiTierCond)
	int randomStyle = 0

	If aiPreset == 1
		RinseOn()
		PresetSequenceDefault()
	elseIf aiPreset == 2
		Idle[] BathingStyle = new Idle[3]
		if UsingSoap
			BathingStyle[0] = mzinBatheMA1_S1_Soap
			BathingStyle[1] = mzinBatheMA2_S1_Soap
			BathingStyle[2] = mzinBatheMA3_S1_Soap
		else
			BathingStyle[0] = mzinBatheMA1_S1_Cloth
			BathingStyle[1] = mzinBatheMA2_S1_Cloth
			BathingStyle[2] = mzinBatheMA3_S1_Cloth
		endIf

		if !abOverride
			randomStyle = Utility.RandomInt(0, BathingStyle.Length - 1)
		endIf

		RinseOn()
		BathingActor.PlayIdle(BathingStyle[randomStyle])
	endIf
EndFunction
Function EffectFinish()
	SendWashActorFinishModEvent(BathingActor, UsingSoap)
	BathingActor.RemoveSpell(PlayBatheAnimationWithSoap)
	BathingActor.RemoveSpell(PlayBatheAnimationWithoutSoap)
	BathingActor.RemoveSpell(PlayShowerAnimationWithSoap)
	BathingActor.RemoveSpell(PlayShowerAnimationWithoutSoap)
EndFunction
Function GetSoapy()
	If UsingSoap
		If BathingActorIsPlayer
			If GetSoapyStyle.GetValue() == 1
				BathingActor.AddSpell(SoapyAppearanceSpell, False)
			ElseIf GetSoapyStyle.GetValue() == 2
				BathingActor.AddSpell(SoapyAppearanceAnimatedSpell, False)
			EndIf
		Else
			If GetSoapyStyleFollowers.GetValue() == 1
				BathingActor.AddSpell(SoapyAppearanceSpell, False)
			ElseIf GetSoapyStyleFollowers.GetValue() == 2
				BathingActor.AddSpell(SoapyAppearanceAnimatedSpell, False)
			EndIf
		EndIf
	EndIf
EndFunction
Function GetUnsoapy()
	If BathingActor.HasSpell(SoapyAppearanceSpell)
		BathingActor.RemoveSpell(SoapyAppearanceSpell)
	ElseIf BathingActor.HasSpell(SoapyAppearanceAnimatedSpell)
		BathingActor.RemoveSpell(SoapyAppearanceAnimatedSpell)
	EndIf
EndFunction

Function GetNaked()
	Form[] EquippedItems = PO3_SKSEFunctions.AddAllEquippedItemsToArray(BathingActor)
	EquippedItems = SPE_Utility.FilterFormsByKeyword(EquippedItems, Init.KeywordIgnoreItem, false, true)
	If BathingActorIsPlayer
		Clothing = SPE_Utility.FilterBySlotMask(EquippedItems, mzinUtil.GetCombinedSlotMask(Menu.ArmorSlotArray), false)
	Else
		Clothing = SPE_Utility.FilterBySlotMask(EquippedItems, mzinUtil.GetCombinedSlotMask(Menu.ArmorSlotArrayFollowers), false)
	EndIf

	BathingActor.SheatheWeapon()
    while (BathingActor.IsWeaponDrawn())
        Utility.wait(0.1)
    endwhile
	
	Int Index = Clothing.Length
	While Index
		Index -= 1
		BathingActor.UnequipItem(Clothing[Index], False, True)	
		Debug.Trace("mzin GetNaked(): Clothing[Index]: " + Clothing[Index] + " at index " + Index)
	EndWhile
	
	; weapons
	BathingActor.UnequipItemEX(BathingActor.GetEquippedWeapon(True),  2, False) ; left hand
	BathingActor.UnequipItemEX(BathingActor.GetEquippedWeapon(False), 1, False) ; right hand
EndFunction
Function GetDressed()
	If (BathingActorIsPlayer == True  && GetDressedAfterBathingEnabled.GetValue() As Bool) \
	|| (BathingActorIsPlayer == False && GetDressedAfterBathingEnabledFollowers.GetValue() As Bool)
		
		Int Index = Clothing.Length
		
		While Index
			Index -= 1
			If Clothing[Index]
				BathingActor.EquipItem(Clothing[Index], False, True)
			EndIf
		EndWhile
	EndIf
EndFunction
Function RinseOn()
	if !Showering
		Debug.SendAnimationEvent(BathingActor, "IdleSearchingChest")
		Utility.Wait(3)
		Debug.SendAnimationEvent(BathingActor, "IdleStop")
		Utility.Wait(0.5)
	endIf
EndFunction
Function RinseOff()
	if Showering
		Debug.SendAnimationEvent(BathingActor, "IdleWarmArms")
	else
		Debug.SendAnimationEvent(BathingActor, "IdleSearchingChest")
	endIf
	GetUnsoapy()
	Utility.Wait(3)

	Debug.SendAnimationEvent(BathingActor, "IdleStop")
	Utility.Wait(0.7)

	if !Showering
		Debug.SendAnimationEvent(BathingActor, "IdleWipeBrow")
		Utility.Wait(3)
	endIf
EndFunction
Function StopAnimation(bool PlayRinseOff = false)
	UnregisterForUpdate()
	Debug.SendAnimationEvent(BathingActor, "IdleForceDefaultState")
	Utility.Wait(0.5)

	if PlayRinseOff
		RinseOff()
		Debug.SendAnimationEvent(BathingActor, "IdleStop_Loose")
	EndIf

	GetDressed()

	If BathingActorIsPlayer
		SetFreeCam(false)
		UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", true)
		Game.EnablePlayerControls()
		BathingActor.SetHeadTracking(true)
		mzinUtil.GameMessage(BathingCompleteMessage)
	else
		ActorUtil.RemovePackageOverride(BathingActor, StopMovementPackage)
		BathingActor.EvaluatePackage()
	EndIf

	Utility.Wait(0.5)

	EffectFinish()
EndFunction

Function ForbidSex(Actor akTarget, Bool Forbid)
	If Init.IsSexlabInstalled && akTarget
		Faction SexLabForbiddenActors  = Game.GetFormFromFile(0x049068, "SexLab.esm") as Faction
		If Forbid
			akTarget.AddToFaction(SexLabForbiddenActors)
		Else
			akTarget.RemoveFromFaction(SexLabForbiddenActors)
		EndIf
	EndIf
EndFunction

Function SendWashActorFinishModEvent(Form akBathingActor, Bool abUsingSoap)
    int BiS_WashActorFinishModEvent = ModEvent.Create("BiS_WashActorFinish")
    If (BiS_WashActorFinishModEvent)
        ModEvent.PushForm(BiS_WashActorFinishModEvent, akBathingActor)
		ModEvent.PushBool(BiS_WashActorFinishModEvent, abUsingSoap)
        ModEvent.Send(BiS_WashActorFinishModEvent)
    EndIf
EndFunction

Function SetFreeCam(bool toggle)
	if toggle
		if Game.GetCameraState() != 3
			MiscUtil.SetFreeCameraState(true)
		endIf
	else
		if Game.GetCameraState() == 3
			MiscUtil.SetFreeCameraState(false)
		endIf
	endIf
EndFunction

Function SetAutoTerminate()
	RegisterForSingleUpdate(180.0) ; 3 minutes
EndFunction

Function RegisterAnimationEvent()
	RegisterForAnimationEvent(BathingActor, "mzin_GetSoapy")
	RegisterForAnimationEvent(BathingActor, "mzin_GetUnsoapy")
	RegisterForAnimationEvent(BathingActor, "mzin_StopAnimationWithIdle")
	RegisterForAnimationEvent(BathingActor, "mzin_StopAnimation")
EndFunction

Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	if asEventName == "mzin_GetSoapy"
		GetSoapy()
	elseIf asEventName == "mzin_GetUnsoapy"
		GetUnsoapy()
	elseIf asEventName == "mzin_StopAnimationWithIdle"
		StopAnimation(true)
	elseIf asEventName == "mzin_StopAnimation"
		StopAnimation(false)
	EndIf
EndEvent

Event OnUpdate()
	StopAnimation()
EndEvent