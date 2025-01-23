Scriptname mzinInterfacePaf

Function ClearPafDirt(Quest kPAF_MainQuestScript, Actor DirtyActor, Bool abAllow) Global
    if abAllow
        (kPAF_MainQuestScript as PAF_MainQuestScript).Bathe(DirtyActor)
    endIf
EndFunction