ScriptName mzinGetDirtyOverTime Extends ActiveMagicEffect
{ this script increases the player's dirtiness over time }

mzinBatheQuest Property BatheQuest Auto
mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto
mzinUtility Property mzinUtil Auto
mzinInit Property Init Auto

FormList Property DirtyActors Auto

FormList Property PlayerHouseLocationList Auto
FormList Property DungeonLocationList Auto
FormList Property SettlementLocationList Auto
FormList Property mzinAnimationInProcList Auto 
FormList Property SoapBonusSpellList Auto
FormList Property DirtinessSpellList Auto
FormList Property DirtinessThresholdList Auto

MagicEffect Property mzinDirtinessTier1p5Effect Auto
MagicEffect Property mzinDirtinessTier2Effect Auto
MagicEffect Property mzinDirtinessTier3Effect Auto

Spell Property mzinDirtinessTier1p5Spell Auto

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

Faction Property CreatureFaction Auto

Actor Property PlayerRef Auto

; local variables
Actor DirtyActor
Bool  DirtyActorIsPlayer
Float DirtAppliedLastUpdate
Float LocalDirtinessPercentage
Float LocalLastUpdateTime
Float SexDirt
Int SexTID

; ---------- Events ----------

Event OnEffectStart(Actor Target, Actor Caster)
	DirtyActor = Target
	DirtyActorIsPlayer = (Target == PlayerRef)
	RegisterForEvents()

	Int InitialDirtinessTier = (Self.GetMagnitude() As Int) - 1
	If DirtyActorIsPlayer
		LocalDirtinessPercentage = DirtinessPercentage.GetValue()
		if !(LocalDirtinessPercentage as int)
			LocalDirtinessPercentage = (DirtinessThresholdList.GetAt(InitialDirtinessTier) As GlobalVariable).GetValue()
		endIf
	Else
		If DirtyActors.Find(DirtyActor) == -1
			DirtyActors.AddForm(DirtyActor)
		EndIf
		LocalDirtinessPercentage = StorageUtil.GetFloatValue(DirtyActor, "BiS_Dirtiness", (DirtinessThresholdList.GetAt(InitialDirtinessTier) As GlobalVariable).GetValue())
	EndIf

	If !DirtyActor.HasMagicEffectWithKeyword(DirtinessTierKeyword)
		DirtyActor.RemoveSpell(mzinDirtinessTier1p5Spell)
		If InitialDirtinessTier >= 0 && InitialDirtinessTier < DirtinessThresholdList.GetSize()
			If LocalDirtinessPercentage >= Menu.OverlayApplyAt && LocalDirtinessPercentage < (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
				DirtyActor.AddSpell(mzinDirtinessTier1p5Spell)
			EndIf
			DirtyActor.AddSpell(DirtinessSpellList.GetAt(InitialDirtinessTier + 1) As Spell, False)
		Else
			LocalDirtinessPercentage = 0.0
			DirtyActor.AddSpell(DirtinessSpellList.GetAt(0) As Spell, False)
		EndIf
	EndIf

	BatheQuest.UpdateActorDirtPercent(Target, LocalDirtinessPercentage)
	CheckAlpha()
	
	Float LastUpdate = StorageUtil.GetFloatValue(DirtyActor, "BiS_LastUpdate", -100.0)
	Float CurrentGameTime = GameDaysPassed.GetValue()
	If LastUpdate == -100.0
		LocalLastUpdateTime = CurrentGameTime
		StorageUtil.SetFloatValue(DirtyActor, "BiS_LastUpdate", LocalLastUpdateTime)
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
EndEvent

Event OnObjectEquipped(Form WashProp, ObjectReference WashPropReference)
	If WashProp.HasKeyWord(WashPropKeyword) && !BatheQuest.IsRestricted(DirtyActor)
		if BatheQuest.IsInWater(DirtyActor)
			CloseInventory()
			BatheQuest.WashActor(DirtyActor, WashProp as MiscObject, false, DirtyActorIsPlayer)
		elseIf BatheQuest.IsUnderWaterfall(DirtyActor)
			CloseInventory()
			BatheQuest.WashActor(DirtyActor, WashProp as MiscObject, true, DirtyActorIsPlayer)
		endIf
	EndIf
EndEvent

Event OnUpdateGameTime()
	RunDirtCycleUpdate()
EndEvent

Event OnUpdate()
	RunDirtCycleUpdate()
EndEvent

Event OnDeath(actor akKiller)
	BatheQuest.UntrackActor(DirtyActor)
EndEvent

Event OnPlayerLoadGame()
	if GetState() == ""
		RegisterForEvents()
	endIf
	ModEvent.Send(ModEvent.Create("BiS_UpdateActorsAll"))
EndEvent

; ---------- Mod Events ----------

Event OnBiS_UpdateAlpha()
	CheckAlpha()
EndEvent

Event OnBiS_UpdateActorsAll()
	Utility.Wait(0.5)
	mzinUtil.LogTrace("OnBiS_UpdateActorsAll: " + DirtyActor.GetBaseObject().GetName())
	If DirtyActor.IsDead()
		OnDeath(none)
	ElseIf DirtyActor.Is3DLoaded()
		OlUtil.ClearDirtGameLoad(DirtyActor)
		If DirtyActor.HasMagicEffect(mzinDirtinessTier2Effect) || DirtyActor.HasMagicEffect(mzinDirtinessTier3Effect) \
		|| DirtyActor.HasMagicEffect(mzinDirtinessTier1p5Effect)
			mzinUtil.LogTrace("Adding dirt to: " + DirtyActor.GetBaseObject().GetName())
			OlUtil.ApplyDirt(DirtyActor, Menu.StartingAlpha, Menu.OverlayTint)
		Else
			mzinUtil.LogTrace("Actor is clean: " + DirtyActor.GetBaseObject().GetName())
		EndIf
		CheckAlpha()
		RenewDirtSpell()
	EndIf
EndEvent

Event OnBiS_ResetActorDirt(Float TimeToClean, Float TimeToCleanInterval, Bool UsedSoap)
	UnregisterEvents()
	if UsedSoap
		ResetDirtState(0.0, TimeToClean, TimeToCleanInterval)
		BatheQuest.ResetGDOTSpell(DirtyActor, 0.0)
	else
		ResetDirtState((DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue(), TimeToClean, TimeToCleanInterval)
		BatheQuest.ResetGDOTSpell(DirtyActor, (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue())
	endIf
EndEvent

Event OnBiS_PauseActorDirt()
	If GetState() == ""
		GoToState("PAUSED")
	EndIf
EndEvent

Event OnBiS_ResumeActorDirt()
	If GetState() == "PAUSED"
		GoToState("")
		RegisterForSingleUpdate(0.5)
	EndIf
EndEvent

; ---------- Common Functions ----------

Function RegisterForEvents()
	RegisterForModEvent("BiS_UpdateAlpha_" + DirtyActor.GetFormID(), "OnBiS_UpdateAlpha")
	RegisterForModEvent("BiS_ResumeActorDirt_" + DirtyActor.GetFormID(), "OnBiS_ResumeActorDirt")
	RegisterForModEvent("BiS_PauseActorDirt_" + DirtyActor.GetFormID(), "OnBiS_PauseActorDirt")
	RegisterForModEvent("BiS_ResetActorDirt_" + DirtyActor.GetFormID(), "OnBiS_ResetActorDirt")
	RegisterForModEvent("BiS_UpdateActorsAll", "OnBiS_UpdateActorsAll")
	
	If Init.IsSexLabInstalled
		If DirtyActorIsPlayer
			RegisterForModEvent("PlayerTrack_Start", "OnAnimationStart_SexLab")
			RegisterForModEvent("PlayerTrack_End", "OnAnimationEnd_SexLab")
		Else
			Int fid = DirtyActor.GetFormID()
			mzinInterfaceSexLab.TrackActor(Init.SL_API, DirtyActor, fid)
			RegisterForModEvent("BiS_" + fid + "Track_Start", "OnAnimationStart_SexLab")
			RegisterForModEvent("BiS_" + fid + "Track_End", "OnAnimationEnd_SexLab")
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
	If DirtyActorIsPlayer
		if UI.IsMenuOpen("InventoryMenu")
            UI.InvokeString("InventoryMenu", "_global.skse.CloseMenu", "InventoryMenu")
        endIf
		if UI.IsMenuOpen("TweenMenu")
            UI.InvokeString("InventoryMenu", "_global.skse.CloseMenu", "TweenMenu")
        endIf
	EndIf
EndFunction

; ---------- Core States ----------

State PAUSED
	Event OnBeginState()
		UnregisterEvents(false)
	EndEvent
	Event OnObjectEquipped(Form WashProp, ObjectReference WashPropReference)
	EndEvent
	Event OnUpdate()
	EndEvent
	Event OnUpdateGameTime()
	EndEvent
	Event OnBiS_UpdateAlpha()
	EndEvent
	Event OnBiS_UpdateActorsAll()
	EndEvent
	Event OnEndState()
	EndEvent
EndState

; ---------- Core Utilities ----------

Function ResetDirtState(Float TargetLevel, Float TimeToClean, Float TimeToCleanInterval)
	If Menu.StartingAlpha < TargetLevel
		TargetLevel = Menu.StartingAlpha
	EndIf
	If TimeToClean < TimeToCleanInterval
		TimeToClean = TimeToCleanInterval
	EndIf
	
	Utility.Wait(3.0)
	Float DirtToClean = ((LocalDirtinessPercentage - TargetLevel) / (TimeToClean / TimeToCleanInterval))

	if (StorageUtil.GetStringValue(DirtyActor, "mzin_DirtTexturePrefix", "") == "") || !(DirtToClean > 0)
		return
	endIf

	While LocalDirtinessPercentage > TargetLevel
		LocalDirtinessPercentage -= DirtToClean
		OlUtil.UpdateAlpha(DirtyActor, LocalDirtinessPercentage)
		Utility.Wait(TimeToCleanInterval)
	EndWhile
EndFunction

Function RunDirtCycleUpdate()
	ApplyDirt()
	Float CurrentGameTime = GameDaysPassed.GetValue()
	LocalLastUpdateTime = CurrentGameTime
	StorageUtil.SetFloatValue(DirtyActor, "BiS_LastUpdate", CurrentGameTime)
	RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
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

	CheckAlpha()
	RenewDirtSpell()
EndFunction

Int Function ApplyDirtSpell(bool abReverse = false)
	if abReverse
		Int Index = 0
		While Index < DirtinessSpellList.GetSize() - 1
			If LocalDirtinessPercentage < (DirtinessThresholdList.GetAt(Index) As GlobalVariable).GetValue()
				if DirtyActor.HasSpell(DirtinessSpellList.GetAt(Index) As Spell)
					Return 0
				else
					If DirtyActor.HasSpell(DirtinessSpellList.GetAt(Index + 1) As Spell) && DirtyActorIsPlayer
						mzinUtil.GameMessage(ExitTierMessageList.GetAt(Index + 1) As Message)
					EndIf
					mzinUtil.RemoveSpells(DirtyActor, DirtinessSpellList)
					DirtyActor.AddSpell(DirtinessSpellList.GetAt(Index) As Spell, False)
					Return Index
				endIf
			EndIf
			Index += 1
		EndWhile
	else
		Int Index = DirtinessSpellList.GetSize()
		While Index > 0
			Index -= 1
			If LocalDirtinessPercentage >= (DirtinessThresholdList.GetAt(Index - 1) As GlobalVariable).GetValue()
				if DirtyActor.HasSpell(DirtinessSpellList.GetAt(Index) As Spell)
					Return 0
				else
					mzinUtil.RemoveSpells(DirtyActor, SoapBonusSpellList)
					mzinUtil.RemoveSpells(DirtyActor, DirtinessSpellList)
					If DirtyActor.AddSpell(DirtinessSpellList.GetAt(Index) As Spell, False) && DirtyActorIsPlayer
						mzinUtil.GameMessage(EnterTierMessageList.GetAt(Index) As Message)
					EndIf
					Return Index
				endIf
			EndIf
		EndWhile
	endIf
	Return -1
EndFunction

Function ApplyDirtLeadInSpell()
	Float DirtinessThreshold = (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
	If Menu.OverlayApplyAt < DirtinessThreshold
		If LocalDirtinessPercentage >= Menu.OverlayApplyAt && LocalDirtinessPercentage < DirtinessThreshold
			DirtyActor.AddSpell(mzinDirtinessTier1p5Spell, false)
		Else
			DirtyActor.RemoveSpell(mzinDirtinessTier1p5Spell)
		EndIf
	EndIf
EndFunction

Function RenewDirtSpell()
	BatheQuest.UpdateActorDirtPercent(DirtyActor, LocalDirtinessPercentage)
	ApplyDirtSpell()
	ApplyDirtLeadInSpell()
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

Function CheckAlpha()
	If LocalDirtinessPercentage >= Menu.OverlayApplyAt
		Float Alpha = Menu.StartingAlpha + (LocalDirtinessPercentage * LocalDirtinessPercentage * LocalDirtinessPercentage)
		If Alpha > 1.0
			Alpha = 1.0
		EndIf
		if !(StorageUtil.GetStringValue(DirtyActor, "mzin_DirtTexturePrefix", "") == "")
			OlUtil.UpdateAlpha(DirtyActor, Alpha)
		endIf
	EndIf
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
		UnregisterEvents(false)
		if Menu.FadeDirtSex
			mzinAnimationInProcList.AddForm(DirtyActor)
			RegisterForSingleUpdate(0.5)
		endIf
	EndEvent
	Event OnUpdate()
		if LocalDirtinessPercentage != 1.0
			IncrementDirtFromSex(SexDirt / Menu.SexIntervalDirt)
			CheckAlpha()
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
EndState

State Animation_OStim
	Event OnBeginState()
		UnregisterEvents(false)
	EndEvent
	Event OnUpdate()
		if LocalDirtinessPercentage < 1.0
			IncrementDirtFromSex(SexDirt / Menu.SexIntervalDirt)
			CheckAlpha()
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
	BatheQuest.UpdateActorDirtPercent(DirtyActor, LocalDirtinessPercentage)
	GoToState("")
EndFunction

Bool Function IsActorInSexAnimation(Actor[] actorList)
	return actorList.Find(DirtyActor) != -1
EndFunction