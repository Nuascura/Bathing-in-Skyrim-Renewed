Scriptname mzinInterfaceOCum

Function OCClearCum(Actor akTarget) Global
    if Game.GetModByName("OCum.esp") != 255
        OCumScript kOCumScript = Quest.GetQuest("OCumQuest") as OCumScript
        kOCumScript.OnAnimationEvent(akTarget, "SoundPlay.FSTSwimSwim")
    endIf
EndFunction