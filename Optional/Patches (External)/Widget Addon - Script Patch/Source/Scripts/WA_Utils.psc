Scriptname WA_Utils  Hidden 

; iNeed support
Quest function GetINeedQuest() global
    return Game.GetFormFromFile(0xD62, "iNeed.esp") as Quest
endFunction

GlobalVariable function GetINeedThirst() global
    return Game.GetFormFromFile(0x4378, "iNeed.esp") as GlobalVariable
endFunction

GlobalVariable function GetINeedHunger() global
    return Game.GetFormFromFile(0x12DB, "iNeed.esp") as GlobalVariable
endFunction

GlobalVariable function GetINeedFatigue() global
    return Game.GetFormFromFile(0x12DC, "iNeed.esp") as GlobalVariable
endFunction

; RND Support
GlobalVariable function GetRNDBathLevel() global
    return Game.GetFormFromFile(0x9F7BD, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel00Alpha() global
    return Game.GetFormFromFile(0x931AC, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel01Alpha() global
    return Game.GetFormFromFile(0x931AD, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel02Alpha() global
    return Game.GetFormFromFile(0x931AE, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel03Alpha() global
    return Game.GetFormFromFile(0x931AF, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel00Color() global
    return Game.GetFormFromFile(0x931B0, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel01Color() global
    return Game.GetFormFromFile(0x931B1, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel02Color() global
    return Game.GetFormFromFile(0x931B2, "iWant RND Widgets.esp") as GlobalVariable
endFunction

GlobalVariable function GetRNDBathLevel03Color() global
    return Game.GetFormFromFile(0x931B3, "iWant RND Widgets.esp") as GlobalVariable
endFunction

; Vitality Mode Support
GlobalVariable function GetVitalityWidgetPos() global
    return Game.GetFormFromFile(0x74FDC, "VitalityMode.esp") as GlobalVariable
endFunction

GlobalVariable function GetVitalityWidgetXOffset() global
    return Game.GetFormFromFile(0x14C2E, "VitalityMode.esp") as GlobalVariable
endFunction

GlobalVariable function GetVitalityWidgetYOffset() global
    return Game.GetFormFromFile(0x14C2F, "VitalityMode.esp") as GlobalVariable
endFunction

GlobalVariable function GetVitalityWidgetOrientation() global
    return Game.GetFormFromFile(0x74FDD, "VitalityMode.esp") as GlobalVariable
endFunction

GlobalVariable function GetVitalityWidgetShown() global
    return Game.GetFormFromFile(0x4C78F, "VitalityMode.esp") as GlobalVariable
endFunction

GlobalVariable function GetVitalityWidgetType() global
    return Game.GetFormFromFile(0x74FDB, "VitalityMode.esp") as GlobalVariable
endFunction

GlobalVariable function GetVitalityWidgetHotkey() global
    return Game.GetFormFromFile(0x14C22, "VitalityMode.esp") as GlobalVariable
endFunction

Quest function GetVitalityQuest() global
    return Game.GetFormFromFile(0x5901, "VitalityMode.esp") as Quest
endFunction

; Keep It Clean
MagicEffect function GetKICDirtinessStage2Effect() global
    return Game.GetFormFromFile(0xFBDBA, "Keep It Clean.esp") as MagicEffect
endFunction

MagicEffect function GetKICDirtinessStage3Effect() global
    return Game.GetFormFromFile(0xFBDB6, "Keep It Clean.esp") as MagicEffect
endFunction

MagicEffect function GetKICDirtinessStage4Effect() global
    return Game.GetFormFromFile(0x1564EE, "Keep It Clean.esp") as MagicEffect
endFunction

; Bathing in Skyrim
MagicEffect function GetBISDirtinessStage2Effect() global
    return Game.GetFormFromFile(0x27, "Bathing in Skyrim.esp") as MagicEffect
endFunction

MagicEffect function GetBISDirtinessStage3Effect() global
    return Game.GetFormFromFile(0x28, "Bathing in Skyrim.esp") as MagicEffect
endFunction

MagicEffect function GetBISDirtinessStage4Effect() global
    return Game.GetFormFromFile(0x29, "Bathing in Skyrim.esp") as MagicEffect
endFunction

MagicEffect function GetBISDirtinessStage5Effect() global
    return Game.GetFormFromFile(0x4B, "Bathing in Skyrim.esp") as MagicEffect
endFunction

; Dirt and Blood
MagicEffect function GetDABDirtinessStage2Effect() global
    return Game.GetFormFromFile(0x80D, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

MagicEffect function GetDABDirtinessStage3Effect() global
    return Game.GetFormFromFile(0x80E, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

MagicEffect function GetDABDirtinessStage4Effect() global
    return Game.GetFormFromFile(0x80F, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

MagicEffect function GetDABDirtinessStage5Effect() global
    return Game.GetFormFromFile(0x83B, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

MagicEffect function GetDABBloodinessStage2Effect() global
    return Game.GetFormFromFile(0x810, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

MagicEffect function GetDABBloodinessStage3Effect() global
    return Game.GetFormFromFile(0x811, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

MagicEffect function GetDABBloodinessStage4Effect() global
    return Game.GetFormFromFile(0x812, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

MagicEffect function GetDABBloodinessStage5Effect() global
    return Game.GetFormFromFile(0x83A, "Dirt and Blood - Dynamic Visuals.esp") as MagicEffect
endFunction

; ERRORS
function RaiseINeedQuestError() global
    debug.trace("[WA][ERROR] Fatal WA - iNeed error occurred.")
endFunction

function RaiseBathingModError() global
    debug.trace("[WA][ERROR] Fatal WA - Bathing Mod not found.")
	debug.messagebox("Widget Addon : no bathing mod found. Please install either Keep It Clean, Bathing In Skyrim or Dirt And Blood.")
endFunction