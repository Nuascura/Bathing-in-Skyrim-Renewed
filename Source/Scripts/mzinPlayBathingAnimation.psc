ScriptName mzinPlayBathingAnimation Extends ActiveMagicEffect
{ this script plays bathing and showering animations based on properties }

mzinInit Property Init Auto

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

Idle Property BathingAnimationStop Auto

Idle Property mzinBatheA1_S1_Soap Auto
Idle Property mzinBatheA1_end_Soap Auto
Idle Property mzinBatheA1_S1_Cloth Auto
Idle Property mzinBatheA1_end_Cloth Auto

Idle Property mzinBatheA2_S1_Soap Auto
Idle Property mzinBatheA2_end_Soap Auto
Idle Property mzinBatheA2_S1_Cloth Auto
Idle Property mzinBatheA2_end_Cloth Auto

Idle Property mzinBatheA3_S1_Soap Auto
Idle Property mzinBatheA3_end_Soap Auto
Idle Property mzinBatheA3_S1_Cloth Auto
Idle Property mzinBatheA3_end_Cloth Auto

Idle Property mzinBatheA4_S0 Auto

Idle Property mzinBatheMA1_S1_Soap Auto
Idle Property mzinBatheMA1_end_Soap Auto
Idle Property mzinBatheMA1_S1_Cloth Auto
Idle Property mzinBatheMA1_end_Cloth Auto

Idle Property mzinBatheMA2_S1_Soap Auto
Idle Property mzinBatheMA2_end_Soap Auto
Idle Property mzinBatheMA2_S1_Cloth Auto
Idle Property mzinBatheMA2_end_Cloth Auto

Idle Property mzinBatheMA3_S1_Soap Auto
Idle Property mzinBatheMA3_end_Soap Auto
Idle Property mzinBatheMA3_S1_Cloth Auto
Idle Property mzinBatheMA3_end_Cloth Auto

Message Property BathingCompleteMessage Auto

Package Property StopMovementPackage Auto

Form[] Clothing
Actor  BathingActor
Bool   BathingActorIsPlayer
Bool   BathingActorIsFemale

String AnimationEventNameToSend
String AnimationEventNameToReceive
Bool AnimationSequenceComplete
Int AnimationCyclesRemaining

Int BailOutSecondsPerLoop = 60
Int BailOutSecondsRemaining

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
Function PlayBathingAnimationDefault()
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
Function PlayBathingAnimationCustom1(Idle animStart, Idle animEnd, Float animDuration)
	; plays either Tween's for men or Baka's for women

	if !Showering
		Debug.SendAnimationEvent(BathingActor, "IdleSearchingChest")
		Utility.Wait(3)
		Debug.SendAnimationEvent(BathingActor, "IdleStop")
		Utility.Wait(0.5)
	endIf

   if ForceCustomAnimationDuration.GetValue() As Float != 0
		;Debug.Notification("Ducation: " + ForceCustomAnimationDuration.GetValue() as Float + " sec.")
		animDuration = ForceCustomAnimationDuration.GetValue() As Float
   endIf

	BathingActor.PlayIdle(animStart)
    Utility.Wait(1)
	GetSoapy()
	Utility.Wait(animDuration)
	BathingActor.PlayIdle(animEnd)
	Utility.Wait(3.5)
	;Debug.SendAnimationEvent(BathingActor, "ResetRoot")
	Debug.SendAnimationEvent(BathingActor, "IdleForceDefaultState") ; if this isn't here, animEnd seems to lock Actor controls for a certain amount of time
	Utility.Wait(0.5)
	RinseOff(Showering)
	StopAnimation()
EndFunction
Function PlayBathingAnimationCustom2(Idle anim, Float animDuration)
	; plays krzp's animation, only for bathing
	; total anim time is 30 seconds. Subtract 1 due to the wait function below

   if ForceCustomAnimationDuration.GetValue() As Float != 0
		;Debug.Notification("Ducation: " + ForceCustomAnimationDuration.GetValue() as Float + " sec.")
		animDuration = ForceCustomAnimationDuration.GetValue() As Float
   endIf

	BathingActor.PlayIdle(anim)
    Utility.Wait(1)
	GetSoapy()
	Utility.Wait(animDuration)
	Debug.SendAnimationEvent(BathingActor, "IdleForceDefaultState")
	Utility.Wait(0.5)
	RinseOff()
	StopAnimation()
EndFunction

; helpers
Function StartAnimation()
	If BathingActorIsPlayer == False
		ActorUtil.AddPackageOverride(BathingActor, StopMovementPackage, 1)
		BathingActor.EvaluatePackage()
	EndIf

	ActorBase BathingActorBase = BathingActor.GetActorBase()
	if (BathingActorBase.GetSex() == 1)
	   BathingActorIsFemale = true
	   ;Debug.Notification("Actor is female")
	else
		BathingActorIsFemale = false
	   ;Debug.Notification("Actor is male")
	endIf
	
	GetNaked()

	Int DirtinessTier = 0
	
	Int DirtinessTierIndex = DirtinessSpellList.GetSize()
	While DirtinessTierIndex
		DirtinessTierIndex -= 1
		If BathingActor.HasSpell(DirtinessSpellList.GetAt(DirtinessTierIndex) As Spell)
			DirtinessTier = DirtinessTierIndex
		EndIf
	EndWhile

	Int AnimationStyle = 0
	If BathingActorIsPlayer
		If Showering
			AnimationStyle = ShoweringAnimationStyle.GetValue() As Int
		Else
			AnimationStyle = BathingAnimationStyle.GetValue() As Int
			If AnimationStyle == 2
				if BathingActorIsFemale
					AnimationStyle = Utility.RandomInt(2, 5)
					;AnimationStyle = 5
				else
					AnimationStyle = Utility.RandomInt(2, 4)
				endIf
				;Debug.Notification("Random animation: " + AnimationStyle)
			endIf
		EndIf
		AnimationCyclesRemaining = (BathingAnimationLoopCountList.GetAt(DirtinessTier) As GlobalVariable).GetValue() As Int
	Else
		If Showering
			AnimationStyle = ShoweringAnimationStyleFollowers.GetValue() As Int
		Else
			AnimationStyle = BathingAnimationStyleFollowers.GetValue() As Int
		EndIf
		AnimationCyclesRemaining = (BathingAnimationLoopCountListFollowers.GetAt(DirtinessTier) As GlobalVariable).GetValue() As Int
	EndIf

	If AnimationStyle > 0 && !BathingActor.IsSwimming()
	
		If BathingActorIsPlayer
			Game.ForceThirdPerson()
			BathingActor.SetHeadTracking(false)
			Game.DisablePlayerControls(True, True, False, False, True, True, True)
		EndIf

		BathingActor.PlayIdle(BathingAnimationStop)

		if AnimationStyle == 1
			PlayBathingAnimationDefault()
		elseIf AnimationStyle == 2
			if BathingActorIsFemale
				if (UsingSoap)
					PlayBathingAnimationCustom1(mzinBatheA1_S1_Soap, mzinBatheA1_end_Soap, 31.1)
				else
					PlayBathingAnimationCustom1(mzinBatheA1_S1_Cloth, mzinBatheA1_end_Cloth, 31.1)
				endIf
			else
				if (UsingSoap)
					PlayBathingAnimationCustom1(mzinBatheMA1_S1_Soap, mzinBatheMA1_end_Soap, 31)
				else
					PlayBathingAnimationCustom1(mzinBatheMA1_S1_Cloth, mzinBatheMA1_end_Cloth, 31)
				endIf
			endIf
		elseIf AnimationStyle == 3
			if BathingActorIsFemale
				if (UsingSoap)
					PlayBathingAnimationCustom1(mzinBatheA2_S1_Soap, mzinBatheA2_end_Soap, 38.5)
				else
					PlayBathingAnimationCustom1(mzinBatheA2_S1_Cloth, mzinBatheA2_end_Cloth, 38.5)
				endIf
			else
				if (UsingSoap)
					PlayBathingAnimationCustom1(mzinBatheMA2_S1_Soap, mzinBatheMA2_end_Soap, 30.5)
				else
					PlayBathingAnimationCustom1(mzinBatheMA2_S1_Cloth, mzinBatheMA2_end_Cloth, 30.5)
				endIf
			endIf
		elseIf AnimationStyle == 4
			if BathingActorIsFemale
				if UsingSoap
					PlayBathingAnimationCustom1(mzinBatheA3_S1_Soap, mzinBatheA3_end_Soap, 31)
				else
					PlayBathingAnimationCustom1(mzinBatheA3_S1_Cloth, mzinBatheA3_end_Cloth, 31)
				endIf
			else 
				if UsingSoap
					PlayBathingAnimationCustom1(mzinBatheMA3_S1_Soap, mzinBatheMA3_end_Soap, 47)
				else
					PlayBathingAnimationCustom1(mzinBatheMA3_S1_Cloth, mzinBatheMA3_end_Cloth, 47)
				endIf
			endIf
		elseIf AnimationStyle == 5
			PlayBathingAnimationCustom2(mzinBatheA4_S0, 29)
		endIf

	EndIf
EndFunction
Function StopAnimation()
	BathingActor.PlayIdle(BathingAnimationStop)

	If BathingActor.HasSpell(SoapyAppearanceSpell)
		BathingActor.RemoveSpell(SoapyAppearanceSpell)
	EndIf

	If BathingActor.HasSpell(SoapyAppearanceAnimatedSpell)
		BathingActor.RemoveSpell(SoapyAppearanceAnimatedSpell)
	EndIf

	GetDressed()

	If !BathingActorIsPlayer
		ActorUtil.RemovePackageOverride(BathingActor, StopMovementPackage)
		BathingActor.EvaluatePackage()
	else
		Game.EnablePlayerControls()
		BathingActor.SetHeadTracking(true)
		BathingCompleteMessage.Show()
	EndIf

	Utility.Wait(0.5)

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

	Debug.SendAnimationEvent(BathingActor, "IdleWipeBrow")
	Utility.Wait(3)
EndFunction

Function StartAnimationSequence(String AnimationEventToPlay, String AnimationEventToWaitFor)
	AnimationSequenceComplete = False
	AnimationEventNameToSend = AnimationEventToPlay
	AnimationEventNameToReceive = AnimationEventToWaitFor
	Debug.SendAnimationEvent(BathingActor, AnimationEventNameToSend)
	Utility.Wait(1)
	Self.RegisterForAnimationEvent(BathingActor, AnimationEventNameToReceive)
	AnimationCyclesRemaining -= 1
EndFunction
Event OnAnimationEvent(ObjectReference Source, string EventName)
	If Source == BathingActor && EventName == AnimationEventNameToReceive
		If AnimationCyclesRemaining > 0
			AnimationCyclesRemaining -= 1
			Utility.Wait(0.5)
			BailOutSecondsRemaining = BailOutSecondsPerLoop
			Debug.SendAnimationEvent(BathingActor, AnimationEventNameToSend)
		Else
			AnimationSequenceComplete = True
			Self.UnregisterForAnimationEvent(BathingActor, AnimationEventNameToReceive)
		EndIf
	EndIf
EndEvent

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