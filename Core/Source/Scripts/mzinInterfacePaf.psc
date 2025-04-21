Scriptname mzinInterfacePaf

Function ClearPafDirt(Quest kPAF_MainQuestScript, Actor DirtyActor) Global
    if kPAF_MainQuestScript
        (kPAF_MainQuestScript as PAF_MainQuestScript).Bathe(DirtyActor)
    endIf
EndFunction