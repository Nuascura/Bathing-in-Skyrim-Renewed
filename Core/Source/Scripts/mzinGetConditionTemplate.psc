Scriptname mzinGetConditionTemplate extends activemagiceffect  

import ModEvent

Actor targetActor
Int targetEvent
String Property hostState Auto
GlobalVariable Property targetTier Auto

Event OnEffectStart(Actor Target, Actor Caster)
    GoToState(hostState)
    RegisterForSingleUpdate(5.0)
    targetActor = Target
EndEvent

State Condition_Swimming
    Event OnUpdate()
        targetEvent = Create("BiS_DecreaseActorDirt_" + targetActor.GetFormID())
        If targetEvent
            PushFloat(targetEvent, targetTier.GetValue())
            PushFloat(targetEvent, 2.0)
            PushFloat(targetEvent, 0.0)
            PushBool(targetEvent, true)
            Send(targetEvent)
        Else
            Release(targetEvent)
        EndIf
    EndEvent
EndState