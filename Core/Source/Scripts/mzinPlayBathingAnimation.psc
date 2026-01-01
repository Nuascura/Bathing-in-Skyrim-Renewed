ScriptName mzinPlayBathingAnimation Extends ActiveMagicEffect
{ this script plays bathing and showering animations based on properties }

mzinInit Property Init Auto
mzinBatheMCMMenu Property Menu Auto
mzinBatheQuest Property BatheQuest Auto
mzinUtility Property mzinUtil Auto

Keyword Property SoapKeyword Auto

Spell Property PlayBathingAnimation Auto

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


Actor   BathingActor
Bool    BathingActorIsPlayer
Bool    BathingActorIsFemale
Bool    BathingActorIsShowering

Float[] AnimSet
Armor[] Clothing
Int[]   ClothingID
Form[]  Objects
Int[]   ObjectsID
Idle    SelectedStyle
MiscObject WashProp
Bool       WashPropIsSoap
String[] AnimEvents

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
	BathingActorIsPlayer = (Target == BatheQuest.PlayerRef)
	BathingActorIsFemale = BathingActor.GetActorBase().GetSex()
	ForbidSex(BathingActor, Forbid = true)

	BathingActorIsShowering = StorageUtil.PluckIntValue(BathingActor, "mzin_LastWashState") as Bool
	WashProp = StorageUtil.PluckFormValue(BathingActor, "mzin_LastWashProp") as MiscObject
	WashPropIsSoap = (WashProp && WashProp.HasKeyWord(SoapKeyword))
	
	GoToState("StartSequence")
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	StopAnimation(ResetState = false)
EndEvent

State StartSequence
	Event OnBeginState()
		Int AnimStyle
		Int AnimStyleSwr
		String AnimState = ""
		Int AnimTierCond
		LockActor()
		StripActor()

		If BathingActorIsPlayer
			AnimStyle = BathingAnimationStyle.GetValue() as int
			AnimStyleSwr = ShoweringAnimationStyle.GetValue() as int
			if BathingActorIsFemale
				AnimSet = Menu.AnimCustomFSet
			else
				AnimSet = Menu.AnimCustomMSet
			endIf
			AnimTierCond = Menu.AnimCustomTierCond
		else
			AnimStyle = BathingAnimationStyleFollowers.GetValue() as int
			AnimStyleSwr = ShoweringAnimationStyleFollowers.GetValue() as int
			if BathingActorIsFemale
				AnimSet = Menu.AnimCustomFSetFollowers
			else
				AnimSet = Menu.AnimCustomMSetFollowers
			endIf
			AnimTierCond = Menu.AnimCustomTierCondFollowers
		EndIf

		If AnimStyle > 0
			if BathingActorIsPlayer
				SetFreeCam(Menu.AutoPlayerTFC && true)
				Game.DisablePlayerControls(false, True, True, False, True, True, True, 0)
			endIf
			if BathingActorIsFemale
				AnimState = StartAnimationFemale(GetPresetSequence(AnimSet, AnimStyle, AnimStyleSwr), BathingActorIsShowering, AnimTierCond)
			else 
				AnimState = StartAnimationMale(GetPresetSequence(AnimSet, AnimStyle, AnimStyleSwr), BathingActorIsShowering, AnimTierCond)
			endIf
		EndIf

		if AnimState == ""
			GoToState("FinishSequence")
		else
			RegisterForEvents()
			GoToState("InSequence" + AnimState)
		endIf
	EndEvent
EndState
State FinishSequence
	Event OnBeginState()
		OnUpdate()
	EndEvent
	Event OnUpdate()
		if BathingActorIsPlayer
			SetFreeCam(Menu.AutoPlayerTFC && false)
		endIf
		DressActor()
		UnlockActor()
		ForbidSex(BathingActor, Forbid = false)
		SendWashActorFinishModEvent(BathingActor, WashProp, WashPropIsSoap)
		BathingActor.RemoveSpell(PlayBathingAnimation)
	EndEvent
	Event OnEffectFinish(Actor Target, Actor Caster)
		; Keep empty
	EndEvent
EndState
State InSequenceDefault
	Event OnBeginState()
		Int AnimationCyclesRemaining = 0

		RinseOn()

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
	EndEvent
EndState
State InSequenceCustom
	Event OnBeginState()
		if BathingActor.PlayIdle(SelectedStyle)
			SetAutoTerminate(75.0)
		else
			SetAutoTerminate(2.5)
		endIf
	EndEvent
EndState

; Debug Bathing
Function PresetSequenceDebug(Idle anim, Float animDuration)
	if ForceCustomAnimationDuration.GetValue() > 0
		animDuration = ForceCustomAnimationDuration.GetValue()
	endIf
	BathingActor.PlayIdle(anim)
	Utility.Wait(animDuration)
	StopAnimation()
EndFunction

; helpers
Function LockActor()
	BathingActor.SetHeadTracking(false)
	If BathingActorIsPlayer
		Game.DisablePlayerControls(False, True, True, False, True, True, True, 0)
		Game.SetPlayerAIDriven(true)
		if Game.GetCameraState() == 0
			Game.ForceThirdPerson()
		endIf
		if Menu.AutoHideUI
			UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", false)
		endIf
	else
		BathingActor.AllowPCDialogue(false)
		ActorUtil.AddPackageOverride(BathingActor, StopMovementPackage, 1)
		BathingActor.EvaluatePackage()
	EndIf
EndFunction
Function UnlockActor()
	If BathingActorIsPlayer
		Game.EnablePlayerControls(abLooking = false)
		Game.SetPlayerAIDriven(false)
		UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", true)
		mzinUtil.GameMessage(BathingCompleteMessage)
	else
		BathingActor.AllowPCDialogue(true)
		ActorUtil.RemovePackageOverride(BathingActor, StopMovementPackage)
		BathingActor.EvaluatePackage()
	EndIf
	BathingActor.SetHeadTracking(true)
EndFUnction

int Function GetPresetSequence(float[] animList, int animStyle, int overrideStyle)
	; Vanilla Animations
	If animStyle == 1 || (BathingActorIsShowering && overrideStyle == 1)
		return 1

	; Custom Animations
	else
		if !(BathingActorIsShowering && overrideStyle)
			return animStyle + mzinUtil.GetRandomFromNormalization(animList)
		else
			return overrideStyle ; to-do adjust when more showering styles are available
		endIf
	endIf
EndFunction

String Function StartAnimationFemale(int aiPreset, bool abOverride = false, int aiTierCond)
	if aiPreset == 1
		return "Default"
	else
		If aiPreset == 2
			Idle[] BathingStyle = new Idle[3]
			if WashPropIsSoap
				BathingStyle[0] = mzinBatheA1_S1_Soap
				BathingStyle[1] = mzinBatheA2_S1_Soap
				BathingStyle[2] = mzinBatheA3_S1_Soap
			else
				BathingStyle[0] = mzinBatheA1_S1_Cloth
				BathingStyle[1] = mzinBatheA2_S1_Cloth
				BathingStyle[2] = mzinBatheA3_S1_Cloth
			endIf
			if abOverride
				SelectedStyle = BathingStyle[0]
			else
				SelectedStyle = BathingStyle[Utility.RandomInt(0, BathingStyle.Length - 1)]
			endIf
			RinseOn()
		elseIf aiPreset == 3
			SelectedStyle = mzinBatheA4_S0
		elseIf aiPreset == 4
			Idle[] BathingStyle = new Idle[4]
			BathingStyle[0] = mzinBatheA5_T1
			BathingStyle[1] = mzinBatheA5_T2
			BathingStyle[2] = mzinBatheA5_T3
			BathingStyle[3] = mzinBatheA5_T4
			if aiTierCond == 1
				SelectedStyle = BathingStyle[DirtinessTier]
			elseIf aiTierCond == 2
				SelectedStyle = BathingStyle[DangerTier]
			else
				SelectedStyle = BathingStyle[Utility.RandomInt(0, BathingStyle.Length - 1)]
			endIf
		endIf
		
		if SelectedStyle
			return "Custom"
		endIf
	endIf
	return ""
EndFunction
String Function StartAnimationMale(int aiPreset, bool abOverride = false, int aiTierCond)
	If aiPreset == 1
		return "Default"
	else
		If aiPreset == 2
			Idle[] BathingStyle = new Idle[3]
			if WashPropIsSoap
				BathingStyle[0] = mzinBatheMA1_S1_Soap
				BathingStyle[1] = mzinBatheMA2_S1_Soap
				BathingStyle[2] = mzinBatheMA3_S1_Soap
			else
				BathingStyle[0] = mzinBatheMA1_S1_Cloth
				BathingStyle[1] = mzinBatheMA2_S1_Cloth
				BathingStyle[2] = mzinBatheMA3_S1_Cloth
			endIf
			if abOverride
				SelectedStyle = BathingStyle[0]
			else
				SelectedStyle = BathingStyle[Utility.RandomInt(0, BathingStyle.Length - 1)]
			endIf
			RinseOn()
		endIf

		if SelectedStyle
			return "Custom"
		endIf
	endIf
	return ""
EndFunction
Function StopAnimation(bool PlayRinseOff = false, bool ResetState = true)
	if ResetState
		UnregisterForEvents()
		Debug.SendAnimationEvent(BathingActor, "IdleForceDefaultState")
		Utility.Wait(0.5)
	EndIf

	if PlayRinseOff
		RinseOff()
		Debug.SendAnimationEvent(BathingActor, "IdleStop_Loose")
		Utility.Wait(0.5)
	EndIf

	GoToState("FinishSequence")
EndFunction

Function GetSoapy()
	If WashPropIsSoap
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

Function StripActor()
	Form[] EquippedItems = PO3_SKSEFunctions.AddAllEquippedItemsToArray(BathingActor)
	EquippedItems = SPE_Utility.FilterFormsByKeyword(EquippedItems, Init.KeywordIgnoreItem, false, true)
	If BathingActorIsPlayer
		Clothing = SPE_Utility.FilterBySlotMask(EquippedItems, mzinUtil.GetCombinedSlotMask(Menu.ArmorSlotArray), false)
	Else
		Clothing = SPE_Utility.FilterBySlotMask(EquippedItems, mzinUtil.GetCombinedSlotMask(Menu.ArmorSlotArrayFollowers), false)
	EndIf
	ClothingID = Utility.CreateIntArray(Clothing.Length, 0)
	
	Int Index = Clothing.Length
	While Index
		Index -= 1
		ClothingID[Index] = BathingActor.GetWornItemID(Clothing[Index].GetSlotMask())
		BathingActor.UnequipItemEX(Clothing[Index], 0, False)
	EndWhile
	
	; weapons
	Objects = new Form[3]
	ObjectsID = new Int[3]
	Objects[0] = PO3_SKSEFunctions.GetEquippedAmmo(BathingActor) ; Ammo
	ObjectsID[0] = BathingActor.GetEquippedItemID(0)
	if Objects[0]
		BathingActor.UnequipItemEX(Objects[0], 0, False) ; Ammo
	endIf
	Objects[1] = BathingActor.GetEquippedObject(1) ; right hand
	ObjectsID[1] = BathingActor.GetEquippedItemID(1)
	if Objects[1]
		if Objects[1] as spell
			BathingActor.UnequipSpell(Objects[1] as spell, 1)
		else
			BathingActor.UnequipItemEX(Objects[1], 1, False) ; right hand
		endIf
	endIf
	Objects[2] = BathingActor.GetEquippedObject(0) ; left hand
	ObjectsID[2] = BathingActor.GetEquippedItemID(0)
	if Objects[2]
		if Objects[2] as spell
			BathingActor.UnequipSpell(Objects[2] as spell, 0)
		else
			BathingActor.UnequipItemEX(Objects[2], 2, False) ; left hand
		endIf
	endIf
	
	if BathingActor.isWeaponDrawn()
        float break
        while BathingActor.IsWeaponDrawn() && break < 5
			BathingActor.SheatheWeapon()
			Utility.Wait(0.25)
            break += 0.25
		endWhile
		Utility.Wait(0.5)
    endIf
EndFunction
Function DressActor()
	If (BathingActorIsPlayer == True  && GetDressedAfterBathingEnabled.GetValue() As Bool) \
	|| (BathingActorIsPlayer == False && GetDressedAfterBathingEnabledFollowers.GetValue() As Bool)
		
		Int Index = Clothing.Length
		While Index
			Index -= 1
			If Clothing[Index]
				BathingActor.EquipItemByID(Clothing[Index], ClothingID[Index], 0)
			EndIf
		EndWhile

		if Objects[0]
			BathingActor.EquipItemByID(Objects[0], ObjectsID[0], 0) ; Ammo
		endIf
		if Objects[1]
			if Objects[1] as spell
				BathingActor.EquipSpell(Objects[1] as spell, 1)
			else
				BathingActor.EquipItemByID(Objects[1], ObjectsID[1], 1) ; right hand
			endIf
		endIf
		if Objects[2]
			if Objects[2] as spell
				BathingActor.EquipSpell(Objects[2] as spell, 0)
			else
				BathingActor.EquipItemByID(Objects[2], ObjectsID[2], 2) ; left hand
			endIf
		endIf
	EndIf
EndFunction

Function RinseOn()
	if !BathingActorIsShowering
		Debug.SendAnimationEvent(BathingActor, "IdleSearchingChest")
		Utility.Wait(3)
		Debug.SendAnimationEvent(BathingActor, "IdleStop")
		Utility.Wait(1.0)
	endIf
EndFunction
Function RinseOff()
	if BathingActorIsShowering
		Debug.SendAnimationEvent(BathingActor, "IdleWarmArms")
	else
		Debug.SendAnimationEvent(BathingActor, "IdleSearchingChest")
	endIf
	GetUnsoapy()
	Utility.Wait(3)

	Debug.SendAnimationEvent(BathingActor, "IdleStop")
	Utility.Wait(0.7)

	if !BathingActorIsShowering
		Debug.SendAnimationEvent(BathingActor, "IdleWipeBrow")
		Utility.Wait(3)
	endIf
EndFunction

Function ForbidSex(Actor akTarget, Bool Forbid)
	If Init.IsSexlabInstalled && akTarget
		If Forbid
			akTarget.AddToFaction(Init.SexLabForbiddenActors)
		Else
			akTarget.RemoveFromFaction(Init.SexLabForbiddenActors)
		EndIf
	EndIf
EndFunction

Function SetFreeCam(bool toggle)
	if toggle
		if Game.GetCameraState() != 3
			MiscUtil.SetFreeCameraState(true, 5.0)
		endIf
	else
		if Game.GetCameraState() == 3
			MiscUtil.SetFreeCameraState(false)
		endIf
	endIf
EndFunction

Function SetAutoTerminate(float afSeconds)
	RegisterForSingleUpdate(afSeconds)
EndFunction

Function SendWashActorFinishModEvent(Form akBathingActor, Form akWashProp, Bool abUsingSoap)
    int BiS_WashActorFinishModEvent = ModEvent.Create("BiS_WashActorFinish")
    If (BiS_WashActorFinishModEvent)
        ModEvent.PushForm(BiS_WashActorFinishModEvent, akBathingActor)
		ModEvent.PushForm(BiS_WashActorFinishModEvent, akWashProp)
		ModEvent.PushBool(BiS_WashActorFinishModEvent, abUsingSoap)
        ModEvent.Send(BiS_WashActorFinishModEvent)
    EndIf
EndFunction

Function RegisterForEvents()
	AnimEvents = new String[7]
	AnimEvents[0] = "mzin_GetSoapy"
	AnimEvents[1] = "mzin_GetUnsoapy"
	AnimEvents[2] = "mzin_StopAnimationWithIdle"
	AnimEvents[3] = "mzin_StopAnimation"
	AnimEvents[4] = "MTState"
	AnimEvents[5] = "SoundPlay.FSTSwimSwim"
	AnimEvents[6] = "SoundPlay"
	int i = AnimEvents.Length
	while i
		i -= 1
		RegisterForAnimationEvent(BathingActor, AnimEvents[i])
	endWhile
EndFunction

Function UnregisterForEvents()
	int i = AnimEvents.Length
	while i
		i -= 1
		UnregisterForAnimationEvent(BathingActor, AnimEvents[i])
	endWhile
EndFunction

Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	UnregisterForAnimationEvent(BathingActor, asEventName)
	if asEventName == "mzin_GetSoapy"
		GetSoapy()
	elseIf asEventName == "mzin_GetUnsoapy"
		GetUnsoapy()
	elseIf asEventName == "mzin_StopAnimationWithIdle"
		StopAnimation(true)
	elseIf asEventName == "mzin_StopAnimation"
		StopAnimation()
	else
		StopAnimation()
	EndIf
EndEvent

Event OnUpdate()
	StopAnimation()
EndEvent