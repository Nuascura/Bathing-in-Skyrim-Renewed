Scriptname mzinWashActivator extends ObjectReference

Event OnActivate(ObjectReference akActionRef)
    BatheQuest.TryWashActor(akActionRef as Actor, NONE, TRUE)
EndEvent

mzinBatheQuest Property BatheQuest Auto