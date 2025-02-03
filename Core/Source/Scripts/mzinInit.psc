Scriptname mzinInit extends Quest  

String Property PAPYUTILstate = "$BIS_L_NULL" Auto Hidden
String Property PO3PEstate = "$BIS_L_NULL" Auto Hidden
String Property SKEE64state = "$BIS_L_NULL" Auto Hidden
String Property SPEstate = "$BIS_L_NULL" Auto Hidden

Bool Property IsSexlabInstalled = false Auto Hidden
Bool Property IsSexlabArousedInstalled = false Auto Hidden
Bool Property IsDdsInstalled = false Auto Hidden
Bool Property IsZazInstalled = false Auto Hidden
Bool Property IsWadeInWaterInstalled = false Auto Hidden
Bool Property IsMalignisAnimInstalled = false Auto Hidden
Bool Property IsFadeTattoosInstalled = false Auto Hidden
Bool Property IsFrostFallInstalled = false Auto Hidden
Bool Property IsPAFInstalled = false Auto Hidden
Bool Property IsOCumInstalled = false Auto Hidden

Keyword Property zad_DeviousHeavyBondage Auto Hidden
Keyword Property zad_DeviousSuit Auto Hidden

Faction Property ZazSlaveFaction Auto Hidden
Faction Property SLAExhibitionistFaction Auto Hidden
Faction Property SexLabForbiddenActors Auto Hidden

MagicEffect Property LokiWaterSlowdownEffect Auto Hidden

Quest Property PAF_API Auto Hidden
Quest Property OCA_API Auto Hidden
Quest Property FadeTats_API Auto Hidden

GlobalVariable Property FrostfallRunning_var Auto Hidden

Keyword[] Property KeywordIgnoreItem Auto

Event OnInit()
	DoHardCheck()
	DoSoftCheck()
	SetInternalVariables()
EndEvent

Bool Function DoHardCheck()
	int i = 0

	PAPYUTILstate = "$BIS_L_NULL"
	if (SKSE.GetPluginVersion("PapyrusUtil") != -1 || SKSE.GetPluginVersion("papyrusutil plugin") != -1) && (PapyrusUtil.GetVersion() >= 30)
		PAPYUTILstate = "$BIS_TXT_INSTALLED"
		i += 1
	endIf

	PO3PEstate = "$BIS_L_NULL"
	if SKSE.GetPluginVersion("powerofthree's Papyrus Extender") != -1 && (PO3_SKSEFunctions.GetPapyrusExtenderVersion()[0] >= 5)
		PO3PEstate = "$BIS_TXT_INSTALLED"
		i += 1
	endIf

	SKEE64state = "$BIS_L_NULL"
	if SKSE.GetPluginVersion("skee") != -1
		SKEE64state = "$BIS_TXT_INSTALLED"
		i += 1
	endIf

	SPEstate = "$BIS_L_NULL"
	if SKSE.GetPluginVersion("ScrabsPapyrusExtender") >= 0x02010030
		SPEstate = "$BIS_TXT_INSTALLED"
		i += 1
	endIf

	if i == 4
		return true
	else
		return false
	endIf
EndFunction

Int Function DoSoftCheck()
	int i = 0

	IsSexlabInstalled = false
	If Game.GetModByName("SexLab.esm") != 255
		IsSexlabInstalled = true
		i += 1
	EndIf

	IsSexlabArousedInstalled = false
	If Game.GetModByName("SexLabAroused.esm") != 255
		IsSexlabArousedInstalled = true
		i += 1
	EndIf

	IsDdsInstalled = false
	If Game.GetModByName("Devious Devices - Integration.esm") != 255
		IsDdsInstalled = true
		i += 1
	EndIf
	
	IsZazInstalled = false
	If Game.GetModByName("ZaZAnimationPack.esm") != 255
		IsZazInstalled = true
		i += 1
	EndIf

	IsWadeInWaterInstalled = false
	If Game.GetModByName("WadeInWater.esp") != 255 || Game.GetModByName("SinkOrSwim.esp") != 255
		IsWadeInWaterInstalled = true
		i += 1
	EndIf

	IsFadeTattoosInstalled = false
	If Game.GetModByName("FadeTattoos.esp") != 255
		IsFadeTattoosInstalled = true
		i += 1
	EndIf

	IsFrostFallInstalled = false
	If Game.GetModByName("Frostfall.esp") != 255
		IsFrostFallInstalled = true
		i += 1
	EndIf

	IsPAFInstalled = false
	If Game.GetModByName("PeeAndFart.esp") != 255
		IsPAFInstalled = true
		i += 1
	EndIf

	IsOCumInstalled = false
	If Game.GetModByName("OCum.esp") != 255
		IsOCumInstalled = true
		i += 1
	EndIf

	IsMalignisAnimInstalled = false
	If MiscUtil.FileExists("data/meshes/actors/character/behaviors/FNIS_Bathing_in_Skyrim_Malignis_Behavior.hkx")
		IsMalignisAnimInstalled = true
		i += 1
	EndIf

	return i
EndFunction

Function SetInternalVariables()
	KeywordIgnoreItem = new Keyword[5]
	KeywordIgnoreItem[0] = Keyword.GetKeyword("zad_QuestItem")
	KeywordIgnoreItem[1] = Keyword.GetKeyword("zad_Lockable")
	KeywordIgnoreItem[2] = Keyword.GetKeyword("zad_InventoryDevice")
	KeywordIgnoreItem[3] = Keyword.GetKeyword("zbfWornDevice")
	KeywordIgnoreItem[4] = Keyword.GetKeyword("SexLabNoStrip")

	If IsWadeInWaterInstalled
		If Game.GetModByName("WadeInWater.esp") != 255
			LokiWaterSlowdownEffect = Game.GetFormFromFile(0x000D62, "WadeInWater.esp") as MagicEffect
		ElseIf Game.GetModByName("SinkOrSwim.esp") != 255
			LokiWaterSlowdownEffect = Game.GetFormFromFile(0x000D62, "SinkOrSwim.esp") as MagicEffect
		EndIf
	EndIf
	If IsZazInstalled
		ZazSlaveFaction = Game.GetFormFromFile(0x000096AE, "ZaZAnimationPack.esm") as Faction
	EndIf
	If IsSexlabInstalled
		SexLabForbiddenActors  = Game.GetFormFromFile(0x049068, "SexLab.esm") as Faction
	EndIf
	If IsSexlabArousedInstalled
		SLAExhibitionistFaction = Game.GetFormFromFile(0x0713DA, "SexLabAroused.esm") as Faction
	EndIf
	If IsDdsInstalled
		zad_DeviousHeavyBondage = Game.GetFormFromFile(0x0005226C, "Devious Devices - Integration.esm") as Keyword
		zad_DeviousSuit = Game.GetFormFromFile(0x0002AFA3, "Devious Devices - Assets.esm") as Keyword
	EndIf
	If IsPAFInstalled
		PAF_API = Quest.GetQuest("PAF_MainQuest") ;0x0012C8
	EndIf
	If IsOCumInstalled
		OCA_API = Quest.GetQuest("OCumQuest") ;0x001800
	EndIf
	If IsFadeTattoosInstalled
		FadeTats_API = Quest.GetQuest("FadeTattoos_main") ;0x000D62
	EndIf
	If IsFrostFallInstalled
		FrostfallRunning_var = Game.GetFormFromFile(0x06DCFB, "Frostfall.esp") as GlobalVariable
	EndIf
EndFunction