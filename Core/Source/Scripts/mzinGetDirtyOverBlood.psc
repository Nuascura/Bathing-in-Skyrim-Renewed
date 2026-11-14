Scriptname mzinGetDirtyOverBlood extends activemagiceffect  
{ this script modifies the player's bloodiness }

import PO3_Events_AME
import StorageUtil

FormList Property WeapTypeList Auto
Keyword Property ActorTypeNPC Auto
mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto

Actor DirtyActor

; ---------- Events ----------

Event OnEffectStart(Actor Target, Actor Caster)
    DirtyActor = Target
    RegisterForEvents()
EndEvent

Event OnHitEx(ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked)
    UnregisterForAllHitEventsEx(self)
    RegisterForSingleUpdate(0.1)
EndEvent

Event OnUpdate()
    if !HasStringValue(DirtyActor, "mzin_BloodTexturePrefix")
        OlUtil.BeginOverlay("Blood", DirtyActor, 1.0, Menu.DirtOverlayTint)
    else
        OlUtil.UpdateAlpha("Blood", DirtyActor, 1.0)
    endIf
EndEvent

; ---------- Common Functions ----------

Function RegisterForEvents()
    RegisterForHitEventEx(self, ActorTypeNPC, WeapTypeList, aiBlockFilter = 0)
    RegisterForHitEventEx(self, aiPowerFilter = 1, aiBlockFilter = 0)
    RegisterForHitEventEx(self, aiBashFilter = 1, aiBlockFilter = 0)
EndFunction