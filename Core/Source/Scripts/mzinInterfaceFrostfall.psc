Scriptname mzinInterfaceFrostfall

Function MakeWet(Float amount) Global
    If Game.GetModByName("Frostfall.esp") != 255
        if (Game.GetFormFromFile(0x06DCFB, "Frostfall.esp") as GlobalVariable).GetValueInt() == 2
            FrostUtil.ModPlayerWetness(amount, limit = -1.0)
        endIf
    endIf
EndFunction