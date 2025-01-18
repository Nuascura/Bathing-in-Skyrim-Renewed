ScriptName mzinGetDirtyOverTime Extends ActiveMagicEffect
{ this script increases the player's dirtiness over time }

mzinBatheQuest Property BatheQuest Auto
mzinInterfaceSexlab Property SexlabInt Auto
mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto
mzinUtility Property mzinUtil Auto
mzinInit Property Init Auto

FormList Property DirtyActors Auto

FormList Property PlayerHouseLocationList Auto
FormList Property DungeonLocationList Auto
FormList Property SettlementLocationList Auto
FormList Property mzinAnimationInProcList Auto 
FormList Property GetDirtyOverTimeSpellList Auto
FormList Property SoapBonusSpellList Auto
FormList Property DirtinessSpellList Auto
FormList Property DirtinessThresholdList Auto

MagicEffect Property mzinDirtinessTier1p5Effect Auto
MagicEffect Property mzinDirtinessTier2Effect Auto
MagicEffect Property mzinDirtinessTier3Effect Auto

Spell Property mzinDirtinessTier1p5Spell Auto

FormList Property EnterTierMessageList Auto
FormList Property ExitTierMessageList Auto

GlobalVariable Property DirtinessUpdateInterval Auto
GlobalVariable Property DirtinessPercentage Auto
GlobalVariable Property DirtinessPerHourPlayerHouse Auto
GlobalVariable Property DirtinessPerHourDungeon Auto
GlobalVariable Property DirtinessPerHourSettlement Auto
GlobalVariable Property DirtinessPerHourWilderness Auto

GlobalVariable Property TimeScale Auto

Keyword Property WashPropKeyword Auto
Keyword Property ActorTypeCreature Auto

Faction Property CreatureFaction Auto

Actor Property PlayerRef Auto

; local variables
Actor DirtyActor
Bool  DirtyActorIsPlayer
Float DirtAppliedLastUpdate
Float LocalDirtinessPercentage
Float LocalLastUpdateTime
Float SexDirt

Event OnPlayerLoadGame()
	RegisterForEvents()

	CheckDirt()
	CheckAlpha()
EndEvent

Event OnBiS_UpdateAlpha(Form akTarget)
	If akTarget == DirtyActor
		CheckAlpha()
	EndIf
EndEvent

Event OnBiS_UpdateActorsAll()
	RenewDirtSpell()
EndEvent

Event OnBiS_SexMethodToggle()
	CheckSexEvents()
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

Event OnAnimationStart(int tid, bool HasPlayer)
	Actor[] actorList = SexlabInt.GetSexActors(tid)
	;mzinUtil.LogMessageBox("tid" + tid + "\nHasPlayer: " + HasPlayer + "\nFadeDirtSex: " + Menu.FadeDirtSex + "\nactorList.Find(DirtyActor): " + actorList.Find(DirtyActor) + "\nLocalDirtinessPercentage: " + LocalDirtinessPercentage + "\n\nDirtyActor: " + DirtyActor + "\n\nactorList: " + actorList)
	If Menu.FadeDirtSex && actorList.Find(DirtyActor) >= 0 && LocalDirtinessPercentage < 1.0
		If !mzinAnimationInProcList.HasForm(DirtyActor)
			mzinAnimationInProcList.AddForm(DirtyActor)
			Int i = actorList.Length
			mzinUtil.LogTrace("Sex started on " + DirtyActor.GetBaseObject().GetName())
			SexDirt = 0.0
			Float SexDirtiness = 0.0
			Actor CurrentActor
			While i > 0
				i -= 1
				CurrentActor = actorList[i]
				If CurrentActor != DirtyActor
					If CurrentActor.IsInFaction(CreatureFaction) || CurrentActor.HasKeyWord(ActorTypeCreature)
						SexDirtiness += (2.0 * Menu.DirtinessPerSexActor)
					Else
						SexDirtiness += Menu.DirtinessPerSexActor
					EndIf
				EndIf
			EndWhile
			Bool IsVictim = SexlabInt.SlIsVictim(tid, DirtyActor)
			If IsVictim
				SexDirtiness *= Menu.VictimMult
			EndIf
			While SexlabInt.SlIsActorActive(DirtyActor) && LocalDirtinessPercentage != 1.0
				LocalDirtinessPercentage += (SexDirtiness / Menu.SexIntervalDirt)
				If LocalDirtinessPercentage > 1.0
					LocalDirtinessPercentage = 1.0
				EndIf
				RenewDirtSpell()
				Utility.Wait(Menu.SexInterval)
			EndWhile
			If DirtyActor != PlayerRef
				StorageUtil.SetFloatValue(DirtyActor, "BiS_Dirtiness", LocalDirtinessPercentage)
			EndIf
			mzinAnimationInProcList.RemoveAddedForm(DirtyActor)
		EndIf
	EndIf
EndEvent

Event OnAnimationEnd(int tid, bool HasPlayer)
	If !Menu.FadeDirtSex
		Float SexDirtiness = 0.0
		Actor[] actorList = SexlabInt.GetSexActors(tid)
		Actor CurrentActor
		Int i = actorList.Length
		If actorList.Find(DirtyActor) >= 0
			While i > 0
				i -= 1
				CurrentActor = actorList[i]
				If CurrentActor != DirtyActor
					If CurrentActor.IsInFaction(CreatureFaction) || CurrentActor.HasKeyWord(ActorTypeCreature)
						SexDirtiness += (2.0 * Menu.DirtinessPerSexActor)
					Else
						SexDirtiness += Menu.DirtinessPerSexActor
					EndIf
				EndIf
			EndWhile
			SexDirt = SexDirtiness
			;SexLabFramework SexLab = SexLabUtil.GetAPI()
			Bool IsVictim = SexlabInt.SlIsVictim(tid, DirtyActor)
			If IsVictim
				SexDirt *= Menu.VictimMult
			EndIf
			mzinUtil.LogTrace(DirtyActor.GetBaseObject().GetName() + " gained " + SexDirt + " dirtiness from sex. IsVictim: " + IsVictim)
			RegisterForSingleUpdate(0.1)
		EndIf
	EndIf
EndEvent

Event OnEffectStart(Actor Target, Actor Caster)
	RegisterForEvents()
	DirtyActor = Target
	DirtyActorIsPlayer = (Target == PlayerRef)

	Int InitialDirtinessTier = (Self.GetMagnitude() As Int) - 1
	DirtyActor.RemoveSpell(mzinDirtinessTier1p5Spell)
	If InitialDirtinessTier >= 0 && InitialDirtinessTier < DirtinessThresholdList.GetSize()
		LocalDirtinessPercentage = (DirtinessThresholdList.GetAt(InitialDirtinessTier) As GlobalVariable).GetValue()
		If LocalDirtinessPercentage >= Menu.OverlayApplyAt && LocalDirtinessPercentage < (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
			DirtyActor.AddSpell(mzinDirtinessTier1p5Spell)
		EndIf
		DirtyActor.AddSpell(DirtinessSpellList.GetAt(InitialDirtinessTier + 1) As Spell, False)
	Else
		LocalDirtinessPercentage = 0.0
		DirtyActor.AddSpell(DirtinessSpellList.GetAt(0) As Spell, False)
	EndIf

	If DirtyActorIsPlayer
		DirtinessPercentage.SetValue(LocalDirtinessPercentage)
	ElseIf DirtyActors.Find(DirtyActor) == -1
		DirtyActors.AddForm(DirtyActor)
	EndIf
	
	If !DirtyActorIsPlayer
		LocalDirtinessPercentage = StorageUtil.GetFloatValue(DirtyActor, "BiS_Dirtiness", (DirtinessThresholdList.GetAt(InitialDirtinessTier) As GlobalVariable).GetValue())
	EndIf

	CheckAlpha()
	
	Float LastUpdate = StorageUtil.GetFloatValue(DirtyActor, "BiS_LastUpdate", -100.0)
	If LastUpdate == -100.0
		LocalLastUpdateTime = Utility.GetCurrentGameTime()
		StorageUtil.SetFloatValue(DirtyActor, "BiS_LastUpdate", LocalLastUpdateTime)
		RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
	Else
		LocalLastUpdateTime = LastUpdate
		Float UpdateIntervalInGameTime = (DirtinessUpdateInterval.GetValue() / 24)
		If Utility.GetCurrentGameTime() > LocalLastUpdateTime + UpdateIntervalInGameTime
			mzinUtil.LogTrace("Running update now on " + DirtyActor.GetBaseObject().GetName())
			RegisterForSingleUpdate(0.1)
		Else
			mzinUtil.LogTrace("Running update in " + (UpdateIntervalInGameTime - (Utility.GetCurrentGameTime() - LocalLastUpdateTime)) + " on " + DirtyActor.GetBaseObject().GetName())
			RegisterForSingleUpdateGameTime(UpdateIntervalInGameTime - (Utility.GetCurrentGameTime() - LocalLastUpdateTime))
		EndIf
	EndIf
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	If DirtyActorIsPlayer == False && DirtyActors.Find(DirtyActor) != -1
		StorageUtil.SetFloatValue(DirtyActor, "BiS_Dirtiness", LocalDirtinessPercentage)
	EndIf
EndEvent
Event OnUpdateGameTime()
	RunDirtCycleUpdate()
EndEvent
Event OnUpdate()
	RunDirtCycleUpdate()
EndEvent
Function RunDirtCycleUpdate()
	ApplyDirt()
	Float CurrentGameTime = Utility.GetCurrentGameTime()
	LocalLastUpdateTime = CurrentGameTime
	StorageUtil.SetFloatValue(DirtyActor, "BiS_LastUpdate", CurrentGameTime)
	RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
EndFunction
Event OnObjectEquipped(Form WashProp, ObjectReference WashPropReference)
	If WashProp.HasKeyWord(WashPropKeyword) && !BatheQuest.IsInCommmonRestriction(DirtyActor)
		if !(BatheQuest.WaterRestrictionEnabled.GetValue() As Bool) || PO3_SKSEfunctions.IsActorInWater(DirtyActor)
			CloseInventory()
			BatheQuest.WashActor(DirtyActor, WashProp as MiscObject, DoShower = false)
		elseIf !(BatheQuest.WaterRestrictionEnabled.GetValue() As Bool) || BatheQuest.IsUnderWaterfall(DirtyActor)
			CloseInventory()
			BatheQuest.WashActor(DirtyActor, WashProp as MiscObject, DoShower = true)
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
	Float HoursPassed = (Utility.GetCurrentGameTime() - LocalLastUpdateTime) * 24
	Float DirtPerHour = GetDirtPerHour()

	Float DirtAdded = (DirtPerHour * HoursPassed)
	DirtAdded += SexDirt
	SexDirt = 0.0
	If DirtAppliedLastUpdate <= 0.0
		DirtAppliedLastUpdate = DirtAdded
	EndIf

	Float DirtAppliedThisUpdate = (DirtAdded + DirtAppliedLastUpdate) / 2.0
	DirtAppliedLastUpdate = DirtAppliedThisUpdate
			
	LocalDirtinessPercentage += DirtAppliedThisUpdate
	If LocalDirtinessPercentage > 1.0
		LocalDirtinessPercentage = 1.0
	EndIf

	RenewDirtSpell()
EndFunction

Function RenewDirtSpell()
	If DirtyActorIsPlayer
		DirtinessPercentage.SetValue(LocalDirtinessPercentage)
	Else
		StorageUtil.SetFloatValue(DirtyActor, "BiS_Dirtiness", LocalDirtinessPercentage)
	EndIf

	Message EnterMessage = None
	Message ExitMessage = None

	Int Index = 0
	While Index < DirtinessSpellList.GetSize() - 1	

		Spell DirtinessSpell = DirtinessSpellList.GetAt(Index) As Spell
		Spell NextDirtinessSpell = DirtinessSpellList.GetAt(Index + 1) As Spell
		
		Float DirtinessThreshold = (DirtinessThresholdList.GetAt(Index) As GlobalVariable).GetValue()

		If DirtyActor.HasSpell(DirtinessSpell) && LocalDirtinessPercentage >= DirtinessThreshold

			RemoveSpells(SoapBonusSpellList)

			DirtyActor.RemoveSpell(DirtinessSpell)
			DirtyActor.AddSpell(NextDirtinessSpell, False)

			ExitMessage = ExitTierMessageList.GetAt(Index) As Message
			If EnterMessage == None
				EnterMessage = EnterTierMessageList.GetAt(Index + 1) As Message
			EndIf

		EndIf
		
		Index += 1
	
	EndWhile
	
	Float DirtyThreshold = (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
	If Menu.OverlayApplyAt < DirtyThreshold
		If LocalDirtinessPercentage >= Menu.OverlayApplyAt && LocalDirtinessPercentage < DirtyThreshold
			DirtyActor.AddSpell(mzinDirtinessTier1p5Spell, false) ; this function sends to mzinDirtyOverlay.psc
		Else
			DirtyActor.RemoveSpell(mzinDirtinessTier1p5Spell)
		EndIf
		CheckAlpha()
	EndIf
	
	If DirtyActorIsPlayer
		If ExitMessage
			mzinUtil.GameMessage(ExitMessage)
		EndIf
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
	If DirtyActor.HasMagicEffect(mzinDirtinessTier2Effect) || DirtyActor.HasMagicEffect(mzinDirtinessTier3Effect)
		mzinUtil.LogTrace("Adding dirt to: " + DirtyActor.GetBaseObject().GetName())
		OlUtil.ApplyDirt(DirtyActor, Menu.StartingAlpha)
	ElseIf DirtyActor.HasMagicEffect(mzinDirtinessTier1p5Effect)
		OlUtil.ApplyDirt(DirtyActor, Menu.StartingAlpha)
		mzinUtil.LogTrace("Adding fade in dirt to: " + DirtyActor.GetBaseObject().GetName())
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
		if !StorageUtil.GetStringValue(DirtyActor, "mzin_DirtTexturePrefix", "") == ""
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
	If Init.IsSexlabInstalled
		RegisterForModEvent("HookAnimationStart", "OnAnimationStart")
		RegisterForModEvent("HookAnimationEnd", "OnAnimationEnd")
	EndIf
EndFunction
