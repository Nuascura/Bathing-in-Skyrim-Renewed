ScriptName mzinPlayBathingAnimation Extends ActiveMagicEffect
{ this script plays bathing and showering animations based on properties }

mzinInit Property Init Auto
mzinBatheMCMMenu Property Menu Auto

Bool Property UsingSoap Auto
Bool Property Showering Auto

Spell Property PlayBatheAnimationWithSoap Auto
Spell Property PlayBatheAnimationWithoutSoap Auto
Spell Property PlayShowerAnimationWithSoap Auto
Spell Property PlayShowerAnimationWithoutSoap Auto

FormList Property DirtinessSpellList Auto

FormList Property BathingAnimationLoopCountList Auto
FormList Property BathingAnimationLoopCountListFollowers Auto

GlobalVariable Property GetSoapyStyle Auto
GlobalVariable Property GetSoapyStyleFollowers Auto

GlobalVariable Property BathingAnimationStyle Auto
GlobalVariable Property BathingAnimationStyleFollowers Auto

GlobalVariable Property ShoweringAnimationStyle Auto
GlobalVariable Property ShoweringAnimationStyleFollowers Auto

GlobalVariable Property GetDressedAfterBathingEnabled Auto
GlobalVariable Property GetDressedAfterBathingEnabledFollowers Auto
GlobalVariable Property BathingIgnoredArmorSlotsMask Auto
GlobalVariable Property BathingIgnoredArmorSlotsMaskFollowers Auto

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

Form[] Clothing
Actor  BathingActor
Bool   BathingActorIsPlayer
Int AnimationStyle
Float[] AnimSet

Event OnEffectStart(Actor Target, Actor Caster)
	BathingActor = Target
	ForbidSex(BathingActor, Forbid = true)
	BathingActorIsPlayer = (Target == Game.GetPlayer())

	StartAnimation()
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	ForbidSex(BathingActor, Forbid = false)
EndEvent

; bathing
Function PresetSequence1()
	Int DirtinessTier = 0
	Int AnimationCyclesRemaining = 0
	Int DirtinessTierIndex = DirtinessSpellList.GetSize()

	While DirtinessTierIndex
		DirtinessTierIndex -= 1
		If BathingActor.HasSpell(DirtinessSpellList.GetAt(DirtinessTierIndex) As Spell)
			DirtinessTier = DirtinessTierIndex
		EndIf
	EndWhile

	if BathingActorIsPlayer
		AnimationCyclesRemaining = (BathingAnimationLoopCountList.GetAt(DirtinessTier) As GlobalVariable).GetValue() As Int
	else
		AnimationCyclesRemaining = (BathingAnimationLoopCountListFollowers.GetAt(DirtinessTier) As GlobalVariable).GetValue() As Int
	endIf

	if !showering
		Debug.SendAnimationEvent(BathingActor, "IdleWarmHandsCrouched")
		Utility.Wait(3)
		Debug.SendAnimationEvent(BathingActor, "IdleStop")
		Utility.Wait(1.5)
	endIf

	GetSoapy()

	While AnimationCyclesRemaining > 0	
		AnimationCyclesRemaining -= 1	
		Debug.SendAnimationEvent(BathingActor, "IdleWarmArms")
		Utility.Wait(2)
		Debug.SendAnimationEvent(BathingActor, "IdleStop")
		Utility.Wait(1)
	EndWhile

	RinseOff()
	StopAnimation()
EndFunction
Function PresetSequence2(Idle anim, Float animDuration)
	; plays either Tween's for men or Baka's for women

	if !Showering
		Debug.SendAnimationEvent(BathingActor, "IdleSearchingChest")
		Utility.Wait(3)
		Debug.SendAnimationEvent(BathingActor, "IdleStop")
		Utility.Wait(0.5)
	endIf

    if ForceCustomAnimationDuration.GetValue() As Float != 0
		;Debug.Notification("Duration: " + ForceCustomAnimationDuration.GetValue() as Float + " sec.")
		animDuration = ForceCustomAnimationDuration.GetValue() As Float
    endIf

	BathingActor.PlayIdle(anim)
    Utility.Wait(1)
	GetSoapy()
	Utility.Wait(animDuration)
	Debug.SendAnimationEvent(BathingActor, "IdleForceDefaultState") ; if this isn't here, animEnd seems to lock Actor controls for a certain amount of time
	Utility.Wait(0.5)
	RinseOff(Showering)
	StopAnimation()
EndFunction
Function PresetSequence3(Idle anim, Float animDuration)
	; plays krzp's animation, only for bathing
	; total anim time is 30 seconds. Subtract 1 due to the wait function below

    if ForceCustomAnimationDuration.GetValue() As Float != 0
		;Debug.Notification("Duration: " + ForceCustomAnimationDuration.GetValue() as Float + " sec.")
		animDuration = ForceCustomAnimationDuration.GetValue() As Float
    endIf

	BathingActor.PlayIdle(anim)
    Utility.Wait(1)
	GetSoapy()
	Utility.Wait(animDuration - 1)
	Debug.SendAnimationEvent(BathingActor, "IdleForceDefaultState")
	Utility.Wait(0.5)
	RinseOff()
	StopAnimation()
EndFunction
Function PresetSequence4(Idle anim, Float stage1, Float stage2, Float animDuration)
	; plays JVraven's animation, only for bathing
	; total anim time varies. 

	Debug.Trace("mzin_: " + anim + ", " + stage1 + ", " + stage2 + ", " + animDuration)

    if ForceCustomAnimationDuration.GetValue() As Float != 0
		;Debug.Notification("Duration: " + ForceCustomAnimationDuration.GetValue() as Float + " sec.")
		animDuration = ForceCustomAnimationDuration.GetValue() As Float
    endIf

	BathingActor.PlayIdle(anim)
    Utility.Wait(stage1)
	GetSoapy()
	Utility.Wait(stage2 - stage1)
	GetUnsoapy()
	Utility.Wait(animDuration - stage2)

	Debug.SendAnimationEvent(BathingActor, "IdleForceDefaultState")
	Utility.Wait(0.5)
	
	StopAnimation()
EndFunction

; helpers
Function StartAnimation()
	If BathingActorIsPlayer
		AnimationStyle = BathingAnimationStyle.GetValue() as int
	else
		AnimationStyle = BathingAnimationStyleFollowers.GetValue() as int
	EndIf

	If AnimationStyle > 0 && !BathingActor.IsSwimming()
		GetNaked()
		If BathingActorIsPlayer
			Game.ForceThirdPerson()
			BathingActor.SetHeadTracking(false)
			Game.DisablePlayerControls(True, True, False, False, True, True, True)
			UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", false)
			if Menu.AutoPlayerTFC 
				ToggleTFC(true)
			endIf
			if showering
				AnimationStyle = ShoweringAnimationStyle.GetValue() as int
			endIf
			if BathingActor.GetActorBase().GetSex() == 1
				AnimSet = Menu.AnimCustomFSet
			else
				AnimSet = Menu.AnimCustomMSet
			endIf
		else
			ActorUtil.AddPackageOverride(BathingActor, StopMovementPackage, 1)
			BathingActor.EvaluatePackage()
			if showering
				AnimationStyle = ShoweringAnimationStyleFollowers.GetValue() as int
			endIf
			if BathingActor.GetActorBase().GetSex() == 1
				AnimSet = Menu.AnimCustomFSetFollowers
			else
				AnimSet = Menu.AnimCustomMSetFollowers
			endIf
		EndIf
		Debug.SendAnimationEvent(BathingActor, "IdleStop_Loose")
		if BathingActor.GetActorBase().GetSex() == 1
			GetAnimationFemale(AnimationStyle + GetPresetSequence(AnimSet), showering)
		else
			GetAnimationMale(AnimationStyle + GetPresetSequence(AnimSet), showering)
		endIf
	else
		EffectFinish()
	EndIf
EndFunction
int Function GetPresetSequence(float[] animList)
	int i = 0
	float f = Utility.RandomFloat(0, 1)
	float total = 0
	float setRange = 0
	If AnimationStyle == 1
		return 0
	elseIf showering
		return 0 ; to-do
	else
		while i < animList.length
			total += animList[i]
			i += 1
		endWhile
		If total > 0
			i = 0
			while i < animList.length
				setRange += (animList[i] / total)
				if f < setRange
					return i
				endIf
				i += 1
			endWhile
			return animList.length - 1
		else
			return Utility.RandomInt(0, animList.length - 1)
		endIf
	endIf
EndFunction
Function GetAnimationFemale(int aiPreset, bool abOverride = false)
	int randomStyle = 0

	if aiPreset == 1
		PresetSequence1()
	elseIf aiPreset == 2
		Idle[] BathingStyle = new Idle[3]
		String[] BathingStyleInterval = new String[3]
		if UsingSoap
			BathingStyle[0] = mzinBatheA1_S1_Soap
			BathingStyle[1] = mzinBatheA2_S1_Soap
			BathingStyle[2] = mzinBatheA3_S1_Soap
		else
			BathingStyle[0] = mzinBatheA1_S1_Cloth
			BathingStyle[1] = mzinBatheA2_S1_Cloth
			BathingStyle[2] = mzinBatheA3_S1_Cloth
		endIf
		BathingStyleInterval[0] = "31.1"
		BathingStyleInterval[1] = "38.5"
		BathingStyleInterval[2] = "31"

		if !abOverride
			randomStyle = Utility.RandomInt(0, BathingStyle.Length - 1)
		endIf

		PresetSequence2(BathingStyle[randomStyle], BathingStyleInterval[randomStyle] as float)
	elseIf aiPreset == 3
		PresetSequence3(mzinBatheA4_S0, 29.85)
	elseIf aiPreset == 4
		Idle[] BathingStyle = new Idle[4]
		BathingStyle[0] = mzinBatheA5_T1
		BathingStyle[1] = mzinBatheA5_T2
		BathingStyle[2] = mzinBatheA5_T3
		BathingStyle[3] = mzinBatheA5_T4
		String[] BathingStyleInterval = new String[4]
		BathingStyleInterval[0] = "3,8,10.7"
		BathingStyleInterval[1] = "6,23,25"
		BathingStyleInterval[2] = "8,36,39.4"
		BathingStyleInterval[3] = "8,54,64.2"

		randomStyle = Utility.RandomInt(0, BathingStyle.Length - 1)

		String[] randomStyleInterval = StringUtil.Split(BathingStyleInterval[randomStyle], ",")
		PresetSequence4(BathingStyle[randomStyle], randomStyleInterval[0] as float, randomStyleInterval[1] as float, randomStyleInterval[2] as float)
	endIf
EndFunction
Function GetAnimationMale(int aiPreset, bool abOverride = false)
	int randomStyle = 0

	If aiPreset == 1
		PresetSequence1()
	elseIf aiPreset == 2
		Idle[] BathingStyle = new Idle[3]
		String[] BathingStyleInterval = new String[3]
		if UsingSoap
			BathingStyle[0] = mzinBatheMA1_S1_Soap
			BathingStyle[1] = mzinBatheMA2_S1_Soap
			BathingStyle[2] = mzinBatheMA3_S1_Soap
		else
			BathingStyle[0] = mzinBatheMA1_S1_Cloth
			BathingStyle[1] = mzinBatheMA2_S1_Cloth
			BathingStyle[2] = mzinBatheMA3_S1_Cloth
		endIf
		BathingStyleInterval[0] = "31"
		BathingStyleInterval[1] = "30.5"
		BathingStyleInterval[2] = "47"

		if !abOverride
			randomStyle = Utility.RandomInt(0, BathingStyle.Length - 1)
		endIf

		PresetSequence2(BathingStyle[randomStyle], BathingStyleInterval[randomStyle] as float)
	endIf
EndFunction
Function StopAnimation()
	Debug.SendAnimationEvent(BathingActor, "IdleStop_Loose")

	GetDressed()

	If BathingActorIsPlayer
		ToggleTFC(false)
		UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", true)
		Game.EnablePlayerControls()
		BathingActor.SetHeadTracking(true)
		BathingCompleteMessage.Show()
	else
		ActorUtil.RemovePackageOverride(BathingActor, StopMovementPackage)
		BathingActor.EvaluatePackage()
	EndIf

	Utility.Wait(0.5)

	EffectFinish()
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
	Clothing = new Form[33]

	Int CurrentIgnoreArmorSlotMask = 0 
	If BathingActorIsPlayer
		CurrentIgnoreArmorSlotMask = BathingIgnoredArmorSlotsMask.GetValue() As Int
	Else
		CurrentIgnoreArmorSlotMask = BathingIgnoredArmorSlotsMaskFollowers.GetValue() As Int
	EndIf

	BathingActor.SheatheWeapon()
    while (BathingActor.IsWeaponDrawn())
        Utility.wait(0.1)
    endwhile
	
	Int Index = Clothing.Length
	If Init.IsSexlabInstalled
		While Index
			Index -= 1
			Int ArmorSlotMask = Armor.GetMaskForSlot(Index + 30)
			If Math.LogicalAnd(ArmorSlotMask, CurrentIgnoreArmorSlotMask) != ArmorSlotMask
				Clothing[Index] = BathingActor.GetWornForm(ArmorSlotMask)
				If Clothing[Index]
					If !Clothing[Index].HasKeyword(Init.SexLabNoStrip)
						BathingActor.UnequipItem(Clothing[Index], False, True)
					EndIf
				EndIf
			EndIf		
		EndWhile
	Else
		While Index
			Index -= 1
			Int ArmorSlotMask = Armor.GetMaskForSlot(Index + 30)
			If Math.LogicalAnd(ArmorSlotMask, CurrentIgnoreArmorSlotMask) != ArmorSlotMask
				Clothing[Index] = BathingActor.GetWornForm(ArmorSlotMask)
				If Clothing[Index]
					BathingActor.UnequipItem(Clothing[Index], False, True)
				EndIf
			EndIf		
		EndWhile
	EndIf
	
	; weapons
	BathingActor.UnequipItemEX(BathingActor.GetEquippedWeapon(True),  2, False) ; left hand
	BathingActor.UnequipItemEX(BathingActor.GetEquippedWeapon(False), 1, False) ; right hand
EndFunction
Function GetDressed()
	If (BathingActorIsPlayer == True  && GetDressedAfterBathingEnabled.GetValue() As Bool) \
	|| (BathingActorIsPlayer == False && GetDressedAfterBathingEnabledFollowers.GetValue() As Bool)
		
		Int ClothingIndex = Clothing.Length
		
		If Init.IsSexlabInstalled
			While ClothingIndex
				ClothingIndex -= 1
				If Clothing[ClothingIndex] && !Clothing[ClothingIndex].HasKeyword(Init.SexLabNoStrip)
					BathingActor.EquipItem(Clothing[ClothingIndex], False, True)
				EndIf
			EndWhile
		Else
			While ClothingIndex
				ClothingIndex -= 1
				If Clothing[ClothingIndex]
					BathingActor.EquipItem(Clothing[ClothingIndex], False, True)
				EndIf
			EndWhile
		EndIf
	EndIf
EndFunction
Function RinseOff(bool Showering = false)
	Debug.SendAnimationEvent(BathingActor, "IdleStop")
	Utility.Wait(1)

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

Function ToggleTFC(bool toggle)
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