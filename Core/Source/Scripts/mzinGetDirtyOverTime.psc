ScriptName mzinGetDirtyOverTime Extends ActiveMagicEffect
{ this script increases the player's dirtiness over time }

import PO3_SKSEFunctions
import StorageUtil
import Math
import ModEvent

mzinBatheQuest Property BatheQuest Auto
mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto
mzinUtility Property mzinUtil Auto
mzinInit Property Init Auto

FormList Property PlayerHouseLocationList Auto
FormList Property DungeonLocationList Auto
FormList Property SettlementLocationList Auto
FormList Property mzinAnimationInProcList Auto 
FormList Property SoapBonusSpellList Auto
FormList Property DirtinessSpellList Auto
FormList Property DirtinessThresholdList Auto

FormList Property EnterTierMessageList Auto
FormList Property ExitTierMessageList Auto

GlobalVariable Property GameDaysPassed auto
GlobalVariable Property DirtinessUpdateInterval Auto
GlobalVariable Property DirtinessPercentage Auto
GlobalVariable Property DirtinessPerHourPlayerHouse Auto
GlobalVariable Property DirtinessPerHourDungeon Auto
GlobalVariable Property DirtinessPerHourSettlement Auto
GlobalVariable Property DirtinessPerHourWilderness Auto

Keyword Property WashPropKeyword Auto
Keyword Property ActorTypeCreature Auto
Keyword Property DirtinessTierKeyword Auto
Keyword Property AnimationKeyword Auto
Keyword Property TrackedBatherActor Auto

Faction Property TrackedBatherFaction Auto
Faction Property CreatureFaction Auto

Actor Property PlayerRef Auto

String Property DefaultState = "" Auto Hidden

; local variables
Actor DirtyActor
Bool  DirtyActorIsPlayer
Float DirtAppliedLastUpdate
Float LocalDirtinessPercentage
Float LocalLastUpdateTime
Float SexDirt
Int SexTID
Int DirtyActorFID

; ---------- Events ----------

Event OnEffectStart(Actor Target, Actor Caster)
	StartDirtCycle(Target)
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	If !akBaseObject.HasKeyWord(WashPropKeyword)
		Return
	EndIf

	If !BatheQuest.IsRestricted(DirtyActor)
		if BatheQuest.IsInWater(DirtyActor)
			CloseInventory()
			BatheQuest.WashActor(DirtyActor, akBaseObject as MiscObject, false, DirtyActorIsPlayer)
		elseIf BatheQuest.IsUnderWaterfall(DirtyActor)
			CloseInventory()
			BatheQuest.WashActor(DirtyActor, akBaseObject as MiscObject, true, DirtyActorIsPlayer)
		endIf
	EndIf
EndEvent

Event OnUpdateGameTime()
	OnUpdate()
EndEvent

Event OnUpdate()
	RunDirtCycle(BatheQuest.IsSubmerged(DirtyActor) || BatheQuest.IsWeatherWet(DirtyActor))
EndEvent

Event OnDeath(actor akKiller)
	BatheQuest.UntrackActor(DirtyActor)
EndEvent

Event OnPlayerLoadGame()
	if GetState() == DefaultState
		RegisterForEvents()
	endIf
	;Send(Create("BiS_UpdateActorsAll"))
EndEvent

; ---------- Mod Events ----------

Event OnBiS_UpdateActorsAll()
	Utility.Wait(0.5)
	mzinUtil.LogTrace("OnBiS_UpdateActorsAll: " + DirtyActor.GetBaseObject().GetName())
	If DirtyActor.IsDead()
		OnDeath(none)
	ElseIf DirtyActor.Is3DLoaded()
		OlUtil.ReapplyOverlays(DirtyActor)

		;Nioverride.ApplyNodeOverrides(DirtyActor)

		;if DirtyActor.IsOnMount()
			;DirtyActor.QueueNiNodeUpdate()
		;endIf
	EndIf
EndEvent

Event OnBiS_ResetActorDirtiness(Float TimeToClean, Float TimeToCleanInterval, Bool UsedSoap)
	UnregisterEvents()
	ResetDirtinessState((DirtinessThresholdList.GetAt((!UsedSoap) as int) As GlobalVariable).GetValue(), TimeToClean, TimeToCleanInterval)
	BatheQuest.ResetGDOTSpell(DirtyActor, (DirtinessThresholdList.GetAt((!UsedSoap) as int) As GlobalVariable).GetValue())
EndEvent

Event OnBiS_PauseActorDirtiness()
	If GetState() != DefaultState
		Return
	EndIf
	GoToState("PAUSED")
EndEvent

Event OnBiS_ResumeActorDirtiness()
	If GetState() != "PAUSED"
		Return
	EndIf
	GoToState(DefaultState)
EndEvent

Event OnBiS_ModActorDirtiness(Float afModAmount, Float afModRate, Float afModThreshold, Bool abDoOverlay, Bool abAutoResume)
	If GetState() != DefaultState
		Return
	EndIf
	GoToState("PAUSED")
	ModDirtinessState(afModAmount, afModRate, afModThreshold, abDoOverlay)
	if abAutoResume
		GoToState(DefaultState)
	endIf
EndEvent

Event OnBiS_IncreaseActorDirtiness(Float afTargetLevel, Float afModRate, Float afModThreshold, Bool abDoOverlay, Bool abAutoResume)
	If (GetState() != DefaultState) || (LocalDirtinessPercentage >= afTargetLevel)
		Return
	EndIf
	GoToState("PAUSED")
	ModDirtinessState_Increase(afTargetLevel, (afTargetLevel - LocalDirtinessPercentage) / afModRate, afModRate, afModThreshold, abDoOverlay)
	if abAutoResume
		GoToState(DefaultState)
	endIf
EndEvent

Event OnBiS_DecreaseActorDirtiness(Float afTargetLevel, Float afModRate, Float afModThreshold, Bool abDoOverlay, Bool abAutoResume)
	If (GetState() != DefaultState) || (LocalDirtinessPercentage <= afTargetLevel)
		Return
	EndIf
	GoToState("PAUSED")
	ModDirtinessState_Decrease(afTargetLevel, (LocalDirtinessPercentage - afTargetLevel) / afModRate, afModRate, afModThreshold, abDoOverlay)
	if abAutoResume
		GoToState(DefaultState)
	endIf
EndEvent

Event OnBiS_SetDefaultState(String abStateName)
	String CurrentState = GetState()
	If !CurrentState || (CurrentState == DefaultState)
		GoToState(abStateName)
		RunDirtCycle(true)
	EndIf
	DefaultState = abStateName
EndEvent

; ---------- Common Functions ----------

Function RegisterForEvents()
	RegisterForModEvent("BiS_SetDefaultState_" + DirtyActorFID, "OnBiS_SetDefaultState")
	RegisterForModEvent("BiS_ModActorDirtiness_" + DirtyActorFID, "OnBiS_ModActorDirtiness")
	RegisterForModEvent("BiS_IncreaseActorDirtiness_" + DirtyActorFID, "OnBiS_IncreaseActorDirtiness")
	RegisterForModEvent("BiS_DecreaseActorDirtiness_" + DirtyActorFID, "OnBiS_DecreaseActorDirtiness")
	RegisterForModEvent("BiS_ResumeActorDirtiness_" + DirtyActorFID, "OnBiS_ResumeActorDirtiness")
	RegisterForModEvent("BiS_PauseActorDirtiness_" + DirtyActorFID, "OnBiS_PauseActorDirtiness")
	RegisterForModEvent("BiS_ResetActorDirtiness_" + DirtyActorFID, "OnBiS_ResetActorDirtiness")
	RegisterForModEvent("BiS_UpdateActorsAll", "OnBiS_UpdateActorsAll")
	
	If Init.IsSexLabInstalled
		If DirtyActorIsPlayer
			RegisterForModEvent("PlayerTrack_Start", "OnAnimationStart_SexLab")
			RegisterForModEvent("PlayerTrack_End", "OnAnimationEnd_SexLab")
		Else
			mzinInterfaceSexLab.TrackActor(Init.SL_API, DirtyActor, DirtyActorFID)
			RegisterForModEvent("BiS_" + DirtyActorFID + "Track_Start", "OnAnimationStart_SexLab")
			RegisterForModEvent("BiS_" + DirtyActorFID + "Track_End", "OnAnimationEnd_SexLab")
		EndIf
	EndIf
	If Init.IsOStimInstalled
		If DirtyActorIsPlayer
			RegisterForModEvent("ostim_start", "OnAnimationStart_OStim")
			RegisterForModEvent("ostim_scenechanged", "OnAnimationChange_OStim")
			RegisterForModEvent("ostim_orgasm", "OnAnimationOrgasm_OStim")
			RegisterForModEvent("ostim_end", "OnAnimationEnd_OStim")
		Else
			RegisterForModEvent("ostim_thread_start", "OnAnimationStart_OStim")
			RegisterForModEvent("ostim_thread_scenechanged", "OnAnimationChange_OStim")
			RegisterForModEvent("ostim_actor_orgasm", "OnAnimationOrgasm_OStim")
			RegisterForModEvent("ostim_thread_end", "OnAnimationEnd_OStim")
		EndIf
	EndIf
EndFunction

Function UnregisterEvents(Bool ModEvents = True)
	UnregisterForUpdate()
	UnregisterForUpdateGameTime()
	If ModEvents
		UnregisterForAllModEvents()
	EndIf
EndFunction

Function CloseInventory()
	If !DirtyActorIsPlayer
		Return
	EndIf
	UI.InvokeString("InventoryMenu", "_global.skse.CloseMenu", "InventoryMenu")
	UI.InvokeString("TweenMenu", "_global.skse.CloseMenu", "TweenMenu")
	UI.InvokeString("FavoritesMenu", "_global.skse.CloseMenu", "FavoritesMenu")
EndFunction

Function Send_GDOTStateChange(string StateName = "")
	int targetEvent = Create("BiS_GDOTStateChange_" + DirtyActorFID)
	PushString(targetEvent, StateName)
	PushString(targetEvent, DefaultState)
	Send(targetEvent)
EndFunction

; ---------- Core States ----------

State PAUSED
	Event OnBeginState()
		Send_GDOTStateChange("PAUSED")
	EndEvent
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnUpdate()
	EndEvent
	Event OnUpdateGameTime()
	EndEvent
	Event OnBiS_UpdateActorsAll()
	EndEvent
	Event OnEndState()
		Send_GDOTStateChange()
		RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
	EndEvent
EndState

State SILENT
	Event OnBeginState()
		Send_GDOTStateChange(DefaultState)
		UnregisterEvents(false)
	EndEvent
	Event OnUpdate()
	EndEvent
	Event OnUpdateGameTime()
	EndEvent
EndState

; ---------- Core Utilities ----------

Function StartDirtCycle(Actor Target)
	DirtyActor = Target
	DirtyActorIsPlayer = (Target == PlayerRef)
	DirtyActorFID = Target.GetFormID()
	RegisterForEvents()
	Send_GDOTStateChange()

	Int InitialDirtinessTier = (Self.GetMagnitude() As Int)
	If DirtyActorIsPlayer
		LocalDirtinessPercentage = DirtinessPercentage.GetValue()
		if !(LocalDirtinessPercentage as int)
			LocalDirtinessPercentage = (DirtinessThresholdList.GetAt(InitialDirtinessTier) As GlobalVariable).GetValue()
		endIf
	Else
		DirtyActor.AddToFaction(TrackedBatherFaction)
		LocalDirtinessPercentage = GetFloatValue(DirtyActor, "BiS_Dirtiness", (DirtinessThresholdList.GetAt(InitialDirtinessTier) As GlobalVariable).GetValue())
	EndIf

	AddKeywordToRef(DirtyActor, TrackedBatherActor)

	If !DirtyActor.HasMagicEffectWithKeyword(DirtinessTierKeyword)
		If !InitialDirtinessTier
			LocalDirtinessPercentage = 0.0
		Else
			ApplyDirtLeadIn(Menu.OverlayAlphaMin)
		EndIf
		DirtyActor.AddSpell(DirtinessSpellList.GetAt(InitialDirtinessTier) As Spell, False)
	EndIf

	BatheQuest.SetActorDirtinessPercent(Target, LocalDirtinessPercentage)
	ProgressAlpha()

	Float LastUpdate = GetFloatValue(DirtyActor, "BiS_LastUpdate", -100.0)
	Float CurrentGameTime = GameDaysPassed.GetValue()
	If LastUpdate == -100.0
		LocalLastUpdateTime = CurrentGameTime
		SetFloatValue(DirtyActor, "BiS_LastUpdate", LocalLastUpdateTime)
		RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
	Else
		LocalLastUpdateTime = LastUpdate
		Float UpdateIntervalInGameTime = (DirtinessUpdateInterval.GetValue() / 24)
		If CurrentGameTime > LocalLastUpdateTime + UpdateIntervalInGameTime
			mzinUtil.LogTrace("Running update now on " + DirtyActor.GetBaseObject().GetName())
			RegisterForSingleUpdate(0.1)
		Else
			mzinUtil.LogTrace("Running update in " + (UpdateIntervalInGameTime - (CurrentGameTime - LocalLastUpdateTime)) + " on " + DirtyActor.GetBaseObject().GetName())
			RegisterForSingleUpdateGameTime(UpdateIntervalInGameTime - (CurrentGameTime - LocalLastUpdateTime))
		EndIf
	EndIf
EndFunction

Function ResetDirtinessState(Float TargetLevel, Float TimeToClean, Float TimeToCleanInterval)
	; Lowers the Alpha value of a target actor's overlays to the Alpha value at which typical overlays begin applying

	If Menu.OverlayAlphaMin < TargetLevel
		TargetLevel = Menu.OverlayAlphaMin
	EndIf
	If TimeToClean < TimeToCleanInterval
		TimeToClean = TimeToCleanInterval
	EndIf

	Bool BreakCondition = DirtyActor.HasMagicEffectWithKeyword(AnimationKeyword)

	Float DirtToClean = OlUtil.GetAlphaOverride("Dirt", DirtyActor)
	Float BloodToClean = OlUtil.GetAlphaOverride("Blood", DirtyActor)
	Float SumToClean = LocalDirtinessPercentage
	If DirtToClean > SumToClean
		SumToClean = DirtToClean
	EndIf
	If BloodToClean > SumToClean
		SumToClean = BloodToClean
	EndIf

	Float AmtToClean = ((SumToClean - TargetLevel) / (TimeToClean / TimeToCleanInterval))
	if !(AmtToClean > 0)
		return
	endIf
	
	Utility.Wait(3.0)

	While (SumToClean != TargetLevel) && (DirtyActor.HasMagicEffectWithKeyword(AnimationKeyword) == BreakCondition)
		if TargetLevel > (SumToClean - AmtToClean)
			SumToClean = TargetLevel
		Else
			SumToClean -= AmtToClean
		endIf
		if DirtToClean > SumToClean
			DirtToClean -= AmtToClean
			OlUtil.UpdateAlpha("Dirt", DirtyActor, DirtToClean)
		endIf
		if BloodToClean > SumToClean
			BloodToClean -= AmtToClean
			OlUtil.UpdateAlpha("Blood", DirtyActor, BloodToClean)
		endIf
		Utility.Wait(TimeToCleanInterval)
	EndWhile

	LocalDirtinessPercentage = SumToClean
EndFunction

Function ModDirtinessState(Float ModAmount, Float ModRate, Float ModThreshold, Bool DoOverlay)
	; Lowers or raises the dirt percentage and overlay alpha of a target actor

	ModAmount += LocalDirtinessPercentage

	If !ModRate
		return
	EndIf
	if ModAmount > LocalDirtinessPercentage
		If ModAmount > 1.0
			ModAmount = 1.0
		EndIf
		ModDirtinessState_Increase(ModAmount, (ModAmount - LocalDirtinessPercentage) / ModRate, ModRate, ModThreshold, DoOverlay)
	elseIf ModAmount < LocalDirtinessPercentage
		If ModAmount < 0.0
			ModAmount = 0.0
		EndIf
		ModDirtinessState_Decrease(ModAmount, (LocalDirtinessPercentage - ModAmount) / ModRate, ModRate, ModThreshold, DoOverlay)
	endIf
EndFunction

Function ModDirtinessState_Increase(Float ModTarget, Float ModIncrement, Float ModRate, Float ModThreshold, Bool DoOverlay)
	If DoOverlay
		Float fAlpha_Dirt = OlUtil.GetAlphaOverride("Dirt", DirtyActor)
		Float fAlpha_Blood = OlUtil.GetAlphaOverride("Blood", DirtyActor)
		Float fAugend = LocalDirtinessPercentage

		If fAlpha_Dirt < fAugend && HasStringValue(DirtyActor, "mzin_DirtTexturePrefix")
			fAugend = fAlpha_Dirt
		EndIf
		If fAlpha_Blood < fAugend && HasStringValue(DirtyActor, "mzin_BloodTexturePrefix")
			fAugend = fAlpha_Blood
		EndIf

		If !(ModThreshold as int)
			ModThreshold = Menu.DirtOverlayApplyAt
		EndIf

		While fAugend != ModTarget
			If ModTarget < (fAugend + ModIncrement)
				fAugend = ModTarget
			Else
				fAugend += ModIncrement
			EndIf
			If fAlpha_Dirt
				If fAlpha_Dirt < fAugend
					OlUtil.UpdateAlpha("Dirt", DirtyActor, fAugend)
				EndIf
			ElseIf fAugend >= ModThreshold
				OlUtil.BeginOverlay("Dirt", DirtyActor, ModThreshold, Menu.DirtOverlayTint)
			EndIf
			If fAlpha_Blood && (fAlpha_Blood < fAugend)
				OlUtil.UpdateAlpha("Blood", DirtyActor, fAugend)
			EndIf
			Utility.Wait(ModRate)
		EndWhile
	EndIf
	LocalDirtinessPercentage = ModTarget
	SetLastUpdate()
	RenewDirtSpell(false)
EndFunction

Function ModDirtinessState_Decrease(Float ModTarget, Float ModDecrement, Float ModRate, Float ModThreshold, Bool DoOverlay)
	If DoOverlay
		Float fAlpha_Dirt = OlUtil.GetAlphaOverride("Dirt", DirtyActor)
		Float fAlpha_Blood = OlUtil.GetAlphaOverride("Blood", DirtyActor)
		Float fMinuend = LocalDirtinessPercentage

		If fAlpha_Dirt > fMinuend && HasStringValue(DirtyActor, "mzin_DirtTexturePrefix")
			fMinuend = fAlpha_Dirt
		EndIf
		If fAlpha_Blood > fMinuend && HasStringValue(DirtyActor, "mzin_BloodTexturePrefix")
			fMinuend = fAlpha_Blood
		EndIf
		
		If !(ModThreshold as int)
			ModThreshold = Menu.DirtOverlayApplyAt
		EndIf

		While fMinuend != ModTarget
			If ModTarget > (fMinuend - ModDecrement)
				fMinuend = ModTarget
			Else
				fMinuend -= ModDecrement
			EndIf
			If (fMinuend < ModThreshold)
				if fAlpha_Dirt
					OlUtil.RemoveOverlay("Dirt", DirtyActor, true)
					fAlpha_Dirt = 0.0
				endIf
				if fAlpha_Blood
					OlUtil.RemoveOverlay("Blood", DirtyActor, true)
					fAlpha_Blood = 0.0
				endIf
			else
				if fAlpha_Dirt > fMinuend
					OlUtil.UpdateAlpha("Dirt", DirtyActor, fMinuend)
				endIf
				if fAlpha_Blood > fMinuend
					OlUtil.UpdateAlpha("Blood", DirtyActor, fMinuend)
				endIf
			EndIf
			Utility.Wait(ModRate)
		EndWhile
	EndIf
	LocalDirtinessPercentage = ModTarget
	SetLastUpdate()
	RenewDirtSpell(true)
EndFunction

Function RunDirtCycle(bool skipDirt = false)
	if !skipDirt
		ApplyDirt()
	endIf
	SetLastUpdate()
	RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
EndFunction

Function SetLastUpdate()
	Float CurrentGameTime = GameDaysPassed.GetValue()
	LocalLastUpdateTime = CurrentGameTime
	SetFloatValue(DirtyActor, "BiS_LastUpdate", CurrentGameTime)
EndFunction

Function ApplyDirt()
	Float HoursPassed = (GameDaysPassed.GetValue() - LocalLastUpdateTime) * 24
	Float DirtPerHour = GetDirtPerHour()

	Float DirtAdded = (DirtPerHour * HoursPassed)
	If DirtAppliedLastUpdate <= 0.0
		DirtAppliedLastUpdate = DirtAdded
	EndIf

	Float DirtAppliedThisUpdate = (DirtAdded + DirtAppliedLastUpdate) / 2.0
	DirtAppliedLastUpdate = DirtAppliedThisUpdate
			
	LocalDirtinessPercentage += DirtAppliedThisUpdate
	If LocalDirtinessPercentage > 1.0
		LocalDirtinessPercentage = 1.0
	EndIf

	ProgressAlpha()
	RenewDirtSpell()
EndFunction

Int Function GetCurrentDirtSpellIndex(Int Index, Int Constraint)
	While Index <= Constraint
		If DirtyActor.HasSpell(DirtinessSpellList.GetAt(Index) As Spell)
			Return Index
		EndIf
		Index += 1
	EndWhile
	Return -1
EndFunction

Int Function RegressDirtSpell()
	Int Index = 0
	While Index < DirtinessSpellList.GetSize() - 1
		If LocalDirtinessPercentage < (DirtinessThresholdList.GetAt(Index + 1) As GlobalVariable).GetValue()
			if DirtyActor.HasSpell(DirtinessSpellList.GetAt(Index) As Spell)
				Return Index
			else
				If DirtyActorIsPlayer
					mzinUtil.GameMessage(ExitTierMessageList.GetAt(GetCurrentDirtSpellIndex(Index + 1, DirtinessSpellList.GetSize())) As Message)
				EndIf
				RemoveAddedSpells(DirtyActor, "", mzinUtil.arrkwDirtinessSpell, false)
				DirtyActor.AddSpell(DirtinessSpellList.GetAt(Index) As Spell, False)
				Return Index
			endIf
		EndIf
		Index += 1
	EndWhile
	Return -1
EndFunction

Int Function ProgressDirtSpell()
	Int Index = DirtinessSpellList.GetSize()
	While Index > 0
		Index -= 1
		If LocalDirtinessPercentage >= (DirtinessThresholdList.GetAt(Index) As GlobalVariable).GetValue()
			if DirtyActor.HasSpell(DirtinessSpellList.GetAt(Index) As Spell)
				Return Index
			else
				RemoveAddedSpells(DirtyActor, "", mzinUtil.arrkwSoapBonusSpell, false)
				RemoveAddedSpells(DirtyActor, "", mzinUtil.arrkwDirtinessSpell, false)
				If DirtyActorIsPlayer
					mzinUtil.GameMessage(EnterTierMessageList.GetAt(Index) As Message)
				EndIf
				DirtyActor.AddSpell(DirtinessSpellList.GetAt(Index) As Spell, False)
				Return Index
			endIf
		EndIf
	EndWhile
	Return -1
EndFunction

Function ApplyDirtLeadIn(Float targetAlpha)
	If (LocalDirtinessPercentage >= Menu.DirtOverlayApplyAt) && !HasStringValue(DirtyActor, "mzin_DirtTexturePrefix")
		OlUtil.BeginOverlay("Dirt", DirtyActor, targetAlpha, Menu.DirtOverlayTint)
	EndIf
EndFunction

Function RenewDirtSpell(bool abRegress = false)
	BatheQuest.SetActorDirtinessPercent(DirtyActor, LocalDirtinessPercentage)
	ApplyDirtLeadIn(Menu.OverlayAlphaMin)
	if abRegress
		RegressDirtSpell()
	else
		ProgressDirtSpell()
	endIf
EndFunction

Float Function GetDirtPerHour()
	Location CurrentLocation = DirtyActor.GetCurrentLocation()
	Location[] LocationList = SPE_Cell.GetExteriorLocations(DirtyActor.GetParentCell())
	if CurrentLocation
		If DirtyActor.IsInInterior() && mzinUtil.LocationHasKeyWordInList(CurrentLocation, PlayerHouseLocationList)
			return DirtinessPerHourPlayerHouse.GetValue()
		ElseIf mzinUtil.LocationHasKeyWordInList(CurrentLocation, SettlementLocationList) \
			|| (DirtyActor.IsInInterior() && mzinUtil.ExteriorHasKeyWordInList(LocationList, SettlementLocationList))
			return DirtinessPerHourSettlement.GetValue()
		ElseIf mzinUtil.LocationHasKeyWordInList(CurrentLocation, DungeonLocationList) \
			|| (DirtyActor.IsInInterior() && mzinUtil.ExteriorHasKeyWordInList(LocationList, DungeonLocationList))
			return DirtinessPerHourDungeon.GetValue()
		endIf
	endIf
	return DirtinessPerHourWilderness.GetValue() ; default case
EndFunction

Function ProgressAlpha()
	if HasStringValue(DirtyActor, "mzin_DirtTexturePrefix")
		Float Alpha = Menu.OverlayAlphaMin + pow(LocalDirtinessPercentage, 3)
		If Alpha > 1.0
			Alpha = 1.0
		EndIf
		OlUtil.UpdateAlpha("Dirt", DirtyActor, Alpha)
	endIf
EndFunction















; ---------- Sex-related Functions ----------

Event OnAnimationStart_SexLab(Form FormRef, int tid)
	SexTID = tid
	SexDirt = GetAnimationDirt(mzinInterfaceSexLab.GetSexActors(Init.SL_API, tid), mzinInterfaceSexLab.IsVictim(Init.SL_API, tid, DirtyActor))
	GoToState("Animation_SexLab")
EndEvent
Event OnAnimationEnd_SexLab(Form FormRef, int tid)
	AnimationDirtNoFade()
	EndAnimationState()
	Send_GDOTStateChange()
EndEvent

Event OnAnimationStart_OStim(string EventName, string StrArg, float ThreadID, Form Sender)
	int tid
	if DirtyActorIsPlayer
		tid = 0
	else
		tid = ThreadID as int
	endIf
	Actor[] actorList = mzinInterfaceOStim.GetActors(tid)
	if IsActorInSexAnimation(actorList)
		SexTID = tid
		SexDirt = GetAnimationDirt(actorList, mzinInterfaceOStim.IsActorVictim(DirtyActor, tid))
		GoToState("Animation_OStim")
	endIf
EndEvent
Event OnThreadChange_OStim(string EventName, string SceneID, float ThreadID, Form Sender)
	if DirtyActorIsPlayer || (ThreadID as int) == SexTID
		if Menu.FadeDirtSex
			if (mzinInterfaceOStim.IsSceneSexual(SceneID) && !mzinInterfaceOStim.IsSceneTransition(SceneID))			
				if !mzinAnimationInProcList.HasForm(DirtyActor)
					mzinAnimationInProcList.AddForm(DirtyActor)
					RegisterForSingleUpdate(0.5)
				endIf
			else
				if mzinAnimationInProcList.HasForm(DirtyActor)
					mzinAnimationInProcList.RemoveAddedForm(DirtyActor)
					UnregisterForUpdate()
				endIf
			endIf
		endIf
	endIf
EndEvent
Event OnAnimationOrgasm_OStim(string EventName, string SceneID, float ThreadID, Form Sender)
	if DirtyActorIsPlayer || (ThreadID as int) == SexTID
		AnimationDirtNoFade()
	endIf
EndEvent
Event OnAnimationEnd_OStim(string EventName, string Json, float ThreadID, Form Sender)
	if DirtyActorIsPlayer || (ThreadID as int) == SexTID
		AnimationDirtNoFade(mzinInterfaceOStim.GetExcitementPercentage(DirtyActor))
		EndAnimationState()
		Send_GDOTStateChange()
	endIf
EndEvent

Float Function GetAnimationDirt(Actor[] actorList, bool isVictim)
	Int i = actorList.Length
	Actor CurrentActor
	While i > 0
		i -= 1
		CurrentActor = actorList[i]
		If CurrentActor != DirtyActor
			If CurrentActor.IsInFaction(CreatureFaction) || CurrentActor.HasKeyWord(ActorTypeCreature)
				SexDirt += (2.0 * Menu.DirtinessPerSexActor)
			Else
				SexDirt += Menu.DirtinessPerSexActor
			EndIf
		EndIf
	EndWhile
	If isVictim
		SexDirt *= Menu.VictimMult
	EndIf
	return SexDirt
EndFunction

State Animation_SexLab
	Event OnBeginState()
		Send_GDOTStateChange("Animation_SexLab")
		UnregisterEvents(false)
		if Menu.FadeDirtSex
			mzinAnimationInProcList.AddForm(DirtyActor)
			RegisterForSingleUpdate(0.5)
		endIf
	EndEvent
	Event OnUpdate()
		if LocalDirtinessPercentage != 1.0
			IncrementDirtFromSex(SexDirt / Menu.SexIntervalDirt)
			ProgressAlpha()
			RegisterForSingleUpdate(Menu.SexInterval)
		endIf
	EndEvent
	Event OnUpdateGameTime()
		if !mzinInterfaceSexLab.IsActorActive(Init.SL_API, DirtyActor)
			EndAnimationState()
		endIf
	EndEvent
	Event OnEndState()
		SexDirt = 0.0
		SexTID = 0
		RegisterForSingleUpdate(0.5)
	EndEvent
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
EndState

State Animation_OStim
	Event OnBeginState()
		Send_GDOTStateChange("Animation_OStim")
		UnregisterEvents(false)
	EndEvent
	Event OnUpdate()
		if LocalDirtinessPercentage < 1.0
			IncrementDirtFromSex(SexDirt / Menu.SexIntervalDirt)
			ProgressAlpha()
			if mzinAnimationInProcList.HasForm(DirtyActor)
				RegisterForSingleUpdate(Menu.SexInterval)
			endIf
		endIf
	EndEvent
	Event OnUpdateGameTime()
		if !mzinInterfaceOStim.IsActorActive(DirtyActor)
			EndAnimationState()
		endIf
	EndEvent
	Event OnEndState()
		SexDirt = 0.0
		SexTID = 0
		RegisterForSingleUpdate(0.5)
	EndEvent
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
EndState

Function AnimationDirtNoFade(float modifier = 1.0)
	if !Menu.FadeDirtSex
		IncrementDirtFromSex(SexDirt, modifier)
	endIf
EndFunction

Function IncrementDirtFromSex(Float base, Float mod = 1.0)
	LocalDirtinessPercentage += base * mod
	If LocalDirtinessPercentage > 1.0
		LocalDirtinessPercentage = 1.0
	EndIf
EndFunction

Function EndAnimationState()
	mzinAnimationInProcList.RemoveAddedForm(DirtyActor)
	BatheQuest.SetActorDirtinessPercent(DirtyActor, LocalDirtinessPercentage)
	GoToState(DefaultState)
EndFunction

Bool Function IsActorInSexAnimation(Actor[] actorList)
	return actorList.Find(DirtyActor) != -1
EndFunction