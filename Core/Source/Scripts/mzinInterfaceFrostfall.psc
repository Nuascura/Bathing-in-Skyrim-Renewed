Scriptname mzinInterfaceFrostfall

Function MakeWet(GlobalVariable FrostfallRunning, Float amount, Bool abAllow) Global
    if !abAllow
        return
    endIf

    if FrostfallRunning.GetValueInt() == 2
        FrostUtil.ModPlayerWetness(amount, limit = -1.0)
    endIf
EndFunction