Scriptname mzinInterfaceOCum

Function OCClearCum(Quest kOCumScript, Actor akTarget, Bool abAllow) Global
    if !abAllow
       return
    endIf
    
    (kOCumScript as OCumScript).OnAnimationEvent(akTarget, "SoundPlay.FSTSwimSwim")
EndFunction