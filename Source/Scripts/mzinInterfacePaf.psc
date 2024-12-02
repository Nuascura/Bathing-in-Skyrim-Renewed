Scriptname mzinInterfacePaf

Function ClearPafDirt(Actor DirtyActor) Global
    if Game.GetModByName("PeeAndFart.esp") != 255
        PAF_MainQuestScript.GetApi().Bathe(DirtyActor)
    endIf
EndFunction