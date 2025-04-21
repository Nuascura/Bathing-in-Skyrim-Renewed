Scriptname mzinInterfaceOCum

Function OCClearCum(Quest kOCumScript, Actor akTarget) Global
    if kOCumScript
        (kOCumScript as OCumScript).OnAnimationEvent(akTarget, "SoundPlay.FSTSwimSwim")
    endIf
EndFunction