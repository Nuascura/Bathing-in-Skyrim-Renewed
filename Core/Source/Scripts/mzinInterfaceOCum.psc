Scriptname mzinInterfaceOCum

Function OCClearCum(OCumScript OCA_API, Actor akTarget, Bool abAllow) Global
    if !abAllow
       return
    endIf
    
    OCA_API.OnAnimationEvent(akTarget, "SoundPlay.FSTSwimSwim")
EndFunction