Scriptname mzinGetDirtyOverBlood extends activemagiceffect  
{ this script modifies the player's bloodiness }

import ModEvent
import PO3_Events_AME
import StorageUtil

FormList Property WeapTypeList Auto
Keyword Property ActorTypeNPC Auto
GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property DirtinessUpdateInterval Auto
mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto
mzinBatheQuest Property BatheQuest Auto

Actor DirtyActor
Float LocalLastUpdateTime

; ---------- Events ----------

Event OnEffectStart(Actor Target, Actor Caster)
    Utility.Wait(2.5)
    StartBloodCycle(Target)
EndEvent

Event OnHitEx(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    UnregisterForAllHitEventsEx(self)
    RegisterForSingleUpdate(0.25)
EndEvent

Event OnUpdate()
    RenewBloodCycle()
EndEvent

Event OnUpdateGameTime()
    If OlUtil.GetAlphaOverride("Blood", DirtyActor) < 1.0
        DecayBlood()
    EndIf
    RegisterForEvents()
    RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
EndEvent

; ---------- Core States ----------

State NotBloody
    Event OnBeginState()
        RegisterForEvents()
    EndEvent
	Event OnUpdate()
        OlUtil.BeginOverlay("Blood", DirtyActor, 1.0)
        RenewBloodCycle()
    EndEvent
EndState

State IsBloody
	Event OnUpdate()
        OlUtil.UpdateAlpha("Blood", DirtyActor, 1.0)
        RenewBloodCycle()
    EndEvent
EndState

; ---------- Common Functions ----------

Function RegisterForEvents()
    RegisterForHitEventEx(self, ActorTypeNPC, WeapTypeList, aiBlockFilter = 0)
    RegisterForHitEventEx(self, aiPowerFilter = 1, aiBlockFilter = 0)
    RegisterForHitEventEx(self, aiBashFilter = 1, aiBlockFilter = 0)
EndFunction

Function UpdateDirt()
    If BatheQuest.GetActorDirtinessPercent(DirtyActor) > Menu.BloodDirtyMin
        Return
    EndIf
    int targetEvent = Create("BiS_IncreaseActorDirtiness_" + DirtyActor.GetFormID())
    PushFloat(targetEvent, Menu.BloodDirtyMin)
    PushFloat(targetEvent, 4.2)
    PushFloat(targetEvent, 0.0)
    PushBool(targetEvent, false)
    PushBool(targetEvent, true)
    Send(targetEvent)
EndFunction

; ---------- Core Utilities ----------

Function StartBloodCycle(Actor Target)
    DirtyActor = Target
    
    if HasStringValue(DirtyActor, "mzin_BloodTexturePrefix")
        GoToState("IsBloody")
    else
        GoToState("NotBloody")
    endIf

    Float LastUpdate = GetFloatValue(DirtyActor, "BiS_LastUpdate", -100.0)
	Float CurrentGameTime = GameDaysPassed.GetValue()
	If LastUpdate == -100.0
		LocalLastUpdateTime = CurrentGameTime
		RegisterForSingleUpdateGameTime(1.0)
	Else
		LocalLastUpdateTime = LastUpdate
		Float UpdateIntervalInGameTime = (DirtinessUpdateInterval.GetValue() / 24)
		If CurrentGameTime > LocalLastUpdateTime + UpdateIntervalInGameTime
			RegisterForSingleUpdate(0.1)
		Else
			RegisterForSingleUpdateGameTime(UpdateIntervalInGameTime - (CurrentGameTime - LocalLastUpdateTime))
		EndIf
	EndIf
EndFunction

Function DecayBlood()
    ; todo
EndFunction

Function RenewBloodCycle()
    UpdateDirt()
    RegisterForSingleUpdateGameTime(DirtinessUpdateInterval.GetValue())
EndFunction