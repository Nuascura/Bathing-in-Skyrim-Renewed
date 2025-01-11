Scriptname mzinInit extends Quest  

Bool Property IsSexlabInstalled = false Auto Hidden
Bool Property IsDdsInstalled = false Auto Hidden
Bool Property IsZazInstalled = false Auto Hidden
Bool Property IsWadeInWaterInstalled = false Auto Hidden
Bool Property IsMalignisAnimInstalled = false Auto Hidden

Keyword Property zad_DeviousHeavyBondage Auto Hidden
Keyword Property zad_DeviousSuit Auto Hidden

Faction Property ZazSlaveFaction Auto Hidden

Keyword[] Property KeywordIgnoreItem Auto

Event OnInit()
	DoSoftCheck()
	SetInternalArray()
EndEvent

Function DoSoftCheck()
	IsSexlabInstalled = false
	If Game.GetModByName("SexLab.esm") != 255
		IsSexlabInstalled = true
	EndIf

	IsDdsInstalled = false
	If Game.GetModByName("Devious Devices - Integration.esm") != 255
		zad_DeviousHeavyBondage = Game.GetFormFromFile(0x0005226C, "Devious Devices - Integration.esm") as Keyword
		zad_DeviousSuit = Game.GetFormFromFile(0x0002AFA3, "Devious Devices - Assets.esm") as Keyword
		IsDdsInstalled = true
	EndIf
	
	IsZazInstalled = false
	If Game.GetModByName("ZaZAnimationPack.esm") != 255
		ZazSlaveFaction = Game.GetFormFromFile(0x000096AE, "ZaZAnimationPack.esm") as Faction
		IsZazInstalled = true
	EndIf

	IsWadeInWaterInstalled = false
	If Game.GetModByName("WadeInWater.esp") != 255
		IsWadeInWaterInstalled = true
	EndIf

	IsMalignisAnimInstalled = false
	If MiscUtil.FileExists("data/meshes/actors/character/behaviors/FNIS_Bathing_in_Skyrim_Malignis_Behavior.hkx")
		IsMalignisAnimInstalled = true
	EndIf
EndFunction

Function SetInternalArray()
	KeywordIgnoreItem = new Keyword[5]
	KeywordIgnoreItem[0] = Keyword.GetKeyword("zad_QuestItem")
	KeywordIgnoreItem[1] = Keyword.GetKeyword("zad_Lockable")
	KeywordIgnoreItem[2] = Keyword.GetKeyword("zad_InventoryDevice")
	KeywordIgnoreItem[3] = Keyword.GetKeyword("zbfWornDevice")
	KeywordIgnoreItem[4] = Keyword.GetKeyword("SexLabNoStrip")
EndFunction