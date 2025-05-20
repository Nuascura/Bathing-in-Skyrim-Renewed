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

Event OnPlayerLoadGame()
	RegisterForEvents()
	UpdateAllActors()
EndEvent

Event OnBiS_UpdateAlpha(Form akTarget)
	If akTarget == DirtyActor
		CheckAlpha()
	EndIf
EndEvent

Event OnBiS_UpdateActorsAll()
	Utility.Wait(0.5)
	If DirtyActor.IsDead()
		OnDeath(none)
	ElseIf DirtyActor.Is3DLoaded()
		mzinUtil.LogTrace("OnBiS_UpdateActorsAll: " + DirtyActor.GetBaseObject().GetName())
		CheckDirt()
		CheckAlpha()
		RenewDirtSpell()
	EndIf
EndEvent

Event OnBiS_CleanActorDirt(Form akTarget, Float TimeToClean, Float TimeToCleanInterval, Bool UsedSoap)
	Float LowerLimit = (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue()
	If UsedSoap
		LowerLimit = 0.0
	ElseIf Menu.StartingAlpha < LowerLimit
		LowerLimit = Menu.StartingAlpha
	EndIf
	If akTarget == DirtyActor
		Utility.Wait(3.0)
		Float DirtToClean = ((LocalDirtinessPercentage - LowerLimit) / (TimeToClean / TimeToCleanInterval))
		While LocalDirtinessPercentage != LowerLimit
			LocalDirtinessPercentage -= DirtToClean
			If LocalDirtinessPercentage < LowerLimit
				LocalDirtinessPercentage = LowerLimit
			EndIf
			OlUtil.UpdateAlpha(DirtyActor, LocalDirtinessPercentage)
			Utility.Wait(TimeToCleanInterval)
		EndWhile
	EndIf
EndEvent

Event OnBiS_SexMethodToggle()
	CheckSexEvents()
EndEvent

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

Event OnUpdateGameTime()
	RunDirtCycleUpdate()
EndEvent

Event OnUpdate()
	RunDirtCycleUpdate()
EndEvent

State Animation_SexLab
	Event OnBeginState()
		UnregisterForUpdate()
		UnregisterForUpdateGameTime()
		if Menu.FadeDirtSex
			mzinAnimationInProcList.AddForm(DirtyActor)
			RegisterForSingleUpdate(0.5)
		endIf
	EndEvent
	Event OnUpdate()
		if LocalDirtinessPercentage != 1.0
			IncrementDirtFromSex(SexDirt / Menu.SexIntervalDirt)
			RenewDirtSpell()
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
		UnregisterForUpdate()
		UnregisterForUpdateGameTime()
	EndEvent
	Event OnUpdate()
		if LocalDirtinessPercentage < 1.0
			IncrementDirtFromSex(SexDirt / Menu.SexIntervalDirt)
			RenewDirtSpell()
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

Function RunDirtCycleUpdate()
	ApplyDirt()
	Float CurrentGameTime = GameDaysPassed.GetValue()
	LocalLastUpdateTime = CurrentGameTime
	StorageUtil.SetFloatValue(DirtyActor, "BiS_LastUpdate", CurrentGameTime)
	RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
EndFunction
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

Function CloseInventory()
	If DirtyActorIsPlayer
		if UI.IsMenuOpen("InventoryMenu")
            UI.InvokeString("InventoryMenu", "_global.skse.CloseMenu", "InventoryMenu")
        endIf
	EndIf
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

Int Function ApplyDirtSpell()
	Int Index = DirtinessSpellList.GetSize()
	While Index > 0
		Index -= 1
		If LocalDirtinessPercentage >= (DirtinessThresholdList.GetAt(Index - 1) As GlobalVariable).GetValue()
			if DirtyActor.HasSpell(DirtinessSpellList.GetAt(Index) As Spell)
				return 0
			else
				RemoveSpells(SoapBonusSpellList)
				RemoveSpells(DirtinessSpellList)
				DirtyActor.AddSpell(DirtinessSpellList.GetAt(Index) As Spell, False)
				Return Index
			endIf
		EndIf
	EndWhile
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

	Int DirtinessTier = ApplyDirtSpell()
	ApplyDirtLeadInSpell()
	
	If DirtyActorIsPlayer && DirtinessTier > 0
		Message ExitMessage = ExitTierMessageList.GetAt(DirtinessTier - 1) As Message
		If ExitMessage
			mzinUtil.GameMessage(ExitMessage)
		EndIf
		Message EnterMessage = EnterTierMessageList.GetAt(DirtinessTier) As Message
		If EnterMessage
			mzinUtil.GameMessage(EnterMessage)
		EndIf
	EndIf
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

Function RemoveSpells(FormList SpellFormList)
	Int SpellListIndex = SpellFormList.GetSize()
	While SpellListIndex
		SpellListIndex -= 1
		DirtyActor.RemoveSpell(SpellFormList.GetAt(SpellListIndex) As Spell)	
	EndWhile
EndFunction

Function CheckDirt()
	OlUtil.ClearDirtGameLoad(DirtyActor)
	If DirtyActor.HasMagicEffect(mzinDirtinessTier2Effect) || DirtyActor.HasMagicEffect(mzinDirtinessTier3Effect) \
	|| DirtyActor.HasMagicEffect(mzinDirtinessTier1p5Effect)
		mzinUtil.LogTrace("Adding dirt to: " + DirtyActor.GetBaseObject().GetName())
		OlUtil.ApplyDirt(DirtyActor, Menu.StartingAlpha, Menu.OverlayTint)
	Else
		mzinUtil.LogTrace("Actor is clean: " + DirtyActor.GetBaseObject().GetName())
	EndIf
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

Function RegisterForEvents()
	RegisterForModEvent("BiS_UpdateAlpha", "OnBiS_UpdateAlpha")
	RegisterForModEvent("BiS_UpdateActorsAll", "OnBiS_UpdateActorsAll")
	RegisterForModEvent("BiS_CleanActorDirt", "OnBiS_CleanActorDirt")
	
	CheckSexEvents()
EndFunction

Function CheckSexEvents()
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

Event OnDeath(actor akKiller)
	BatheQuest.UntrackActor(DirtyActor)
EndEvent

Function UpdateAllActors()
	int BiS_UpdateAllActorsEvent = ModEvent.Create("BiS_UpdateActorsAll")
    If (BiS_UpdateAllActorsEvent)
        ModEvent.Send(BiS_UpdateAllActorsEvent)
    EndIf
EndFunction