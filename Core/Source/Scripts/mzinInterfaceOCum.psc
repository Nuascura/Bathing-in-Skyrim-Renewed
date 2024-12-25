Scriptname mzinInterfaceOCum

Function OCClearCum(Actor akTarget) Global
    if Game.GetModByName("OCum.esp") != 255
        OCumScript kOCumScript = Quest.GetQuest("OCumScript") as OCumScript
        OCumMaleScript kOCumMaleScript = Quest.GetQuest("OCumMaleScript") as OCumMaleScript

        kOCumScript.CleanCumTexturesFromActor(akTarget)
        kOCumScript.UnsetActorDataFloats(akTarget)
        
        OCumUtils.RemoveItem(akTarget, kOCumMaleScript.CumMeshPussy)
        OCumUtils.RemoveItem(akTarget, kOCumMaleScript.CumMeshAnal)
        OCumUtils.RemoveItem(akTarget, kOCumMaleScript.UrethraNode)
    endIf
EndFunction