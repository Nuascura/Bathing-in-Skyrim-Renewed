Scriptname mzinInterfacePaf

Function ClearPafDirt(PAF_MainQuestScript PAF_API, Actor DirtyActor, Bool abAllow) Global
    if abAllow
        PAF_API.Bathe(DirtyActor)
    endIf
EndFunction