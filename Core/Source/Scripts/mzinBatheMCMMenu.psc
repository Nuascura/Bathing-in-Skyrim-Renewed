ScriptName mzinBatheMCMMenu Extends SKI_ConfigBase
{ this script displays the MCM menu for mod configuration }

; Modified
mzinTextureUtility Property TexUtil Auto
mzinOverlayUtility Property Util Auto
mzinInit Property Init Auto

Formlist Property mzinDirtyActorsList Auto

Int OverlayApplyAtOID_S
Int StartingAlphaOID_S
Int TexSetCountOID_T
Int RedetectDirtSetsOID_T
Int OverlayProgressOID_T
Int DirtinessPerSexOID_S
Int VictimMultOID_S
Int RemoveAllOverlaysOID_T
Int PapSetSaveOID_T
Int PapSetLoadOID_T
Int FadeTatsFadeTimeOID_S
Int FadeTatsSoapMultOID_S
Int SexIntervalDirtOID_S
Int SexIntervalOID_S
Int FadeDirtSexToggleID
Int TimeToCleanOID_S
Int TimeToCleanIntervalOID_S
Int ShynessToggleID
Int ShyDistanceOID_S
Int UnForbidOID_T

Bool IsConfigOpen = false
Float Property FadeTatsFadeTime = 8.0 Auto Hidden
Float Property FadeTatsSoapMult = 2.0 Auto Hidden
Float Property DirtinessPerSexActor = 0.04 Auto Hidden
Float Property VictimMult = 2.5 Auto Hidden
Float Property OverlayApplyAt = 0.40 Auto Hidden
Float Property StartingAlpha = 0.15 Auto Hidden
Bool Property FadeDirtSex = true Auto Hidden
Float Property SexIntervalDirt = 35.0 Auto Hidden
Float Property SexInterval = 1.0 Auto Hidden
Float Property TimeToClean = 10.0 Auto Hidden
Float Property TimeToCleanInterval = 0.25 Auto Hidden
Bool Property Shyness = True Auto Hidden
Int Property ShyDistance = 2800 Auto Hidden
Bool Property AutoPlayerTFC = False Auto Hidden

Float[] Property AnimCustomMSet Auto
Float Property AnimCustomMSet1Freq = 0.00 Auto
Float[] Property AnimCustomFSet Auto
Float Property AnimCustomFSet1Freq = 0.00 Auto
Float Property AnimCustomFSet2Freq = 0.00 Auto
Float Property AnimCustomFSet3Freq = 0.00 Auto
Float[] Property AnimCustomMSetFollowers Auto
Float Property AnimCustomMSet1FreqFollowers = 0.00 Auto
Float[] Property AnimCustomFSetFollowers Auto
Float Property AnimCustomFSet1FreqFollowers = 0.00 Auto
Float Property AnimCustomFSet2FreqFollowers = 0.00 Auto
Float Property AnimCustomFSet3FreqFollowers = 0.00 Auto

;  Modified
Int Property ScriptVersion = 14 AutoReadOnly

; references
Actor Property PlayerRef Auto

Spell Property GetDirtyOverTimeReactivatorCloakSpell Auto
FormList Property GetDirtyOverTimeSpellList Auto

; toggle values
GlobalVariable Property BathingInSkyrimEnabled Auto
GlobalVariable Property DialogTopicEnabled Auto
GlobalVariable Property WaterRestrictionEnabled Auto

; soap settings
GlobalVariable Property GetSoapyStyle Auto
GlobalVariable Property GetSoapyStyleFollowers Auto

; hotkey settings
mzinBatheCheckStatusQuest Property CheckStatusQuest Auto
mzinBatheQuest Property BatheQuest Auto
GlobalVariable Property CheckStatusKeyCode Auto
GlobalVariable Property BatheKeyCode Auto
GlobalVariable Property ShowerKeyCode Auto

; animation settings
FormList Property BathingAnimationLoopCountList Auto
FormList Property BathingAnimationLoopCountListFollowers Auto
GlobalVariable Property BathingAnimationStyle Auto
GlobalVariable Property BathingAnimationStyleFollowers Auto
GlobalVariable Property ShoweringAnimationStyle Auto
GlobalVariable Property ShoweringAnimationStyleFollowers Auto

; undress settings
GlobalVariable Property GetDressedAfterBathingEnabled Auto
GlobalVariable Property GetDressedAfterBathingEnabledFollowers Auto
GlobalVariable Property BathingIgnoredArmorSlotsMask Auto
GlobalVariable Property BathingIgnoredArmorSlotsMaskFollowers Auto

; dirtiness settings
FormList Property DirtyActors Auto
FormList Property DirtinessSpellList Auto
FormList Property DirtinessThresholdList Auto
GlobalVariable Property DirtinessUpdateInterval Auto
GlobalVariable Property DirtinessPercentage Auto
GlobalVariable Property DirtinessPerHourPlayerHouse Auto
GlobalVariable Property DirtinessPerHourSettlement Auto
GlobalVariable Property DirtinessPerHourDungeon Auto
GlobalVariable Property DirtinessPerHourWilderness Auto

; soap lists
FormList Property SoapBonusSpellList Auto

; local variables
String[] BathingAnimationStyleArray
String[] ShoweringAnimationStyleArray
String[] GetSoapyStyleArray

Bool[] UndressArmorSlotArray
Bool[] UndressArmorSlotArrayFollowers
Bool[] TrackedActorsToggleValuesArray

String[] AutomateFollowerBathingArray
GlobalVariable Property AutomateFollowerBathing Auto
String[] AnimCustomTierCondArray
Int Property AnimCustomTierCond = 1 Auto
Int Property AnimCustomTierCondFollowers = 1 Auto

; constants
String DisplayFormatPercentage = "{1}%"
String DisplayFormatDecimal = "{2}"

String Function GetModVersion()
	return "2.2.0"
EndFunction

Int Function GetVersion()
	Return ScriptVersion
EndFunction

Event OnConfigOpen()
	IsConfigOpen = true
	if !(BathingInSkyrimEnabled.GetValue() as bool)
		Pages = new String[1]
		Pages[0] = "$BIS_PAGE_SYSTEM_OVERVIEW"
	elseIf (BathingInSkyrimEnabled.GetValue() as bool)
		Pages = new String[5]
		Pages[0] = "$BIS_PAGE_SYSTEM_OVERVIEW"
		Pages[1] = "$BIS_PAGE_SETTINGS"
		Pages[2] = "$BIS_PAGE_ANIMATIONS"
		Pages[3] = "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		Pages[4] = "$BIS_PAGE_TRACKED_ACTORS"
	endIf
EndEvent
Function VersionUpdate()
	; automate follower bathing
	AutomateFollowerBathingArray = new String[3]
	AutomateFollowerBathingArray[0] = "$BIS_L_AUTOMATE_FOLLOWER_BATHING_DISABLED"
	AutomateFollowerBathingArray[1] = "$BIS_L_AUTOMATE_FOLLOWER_BATHING_TRACKEDONLY"
	AutomateFollowerBathingArray[2] = "$BIS_L_AUTOMATE_FOLLOWER_BATHING_ALL"

	; bathing animation styles
	BathingAnimationStyleArray = new String[3]
	BathingAnimationStyleArray[0] = "$BIS_L_ANIM_STYLE_NONE"
	BathingAnimationStyleArray[1] = "$BIS_L_ANIM_STYLE_DEFAULT"
	BathingAnimationStyleArray[2] = "$BIS_L_ANIM_STYLE_CUSTOM"

	; showering animation styles
	ShoweringAnimationStyleArray = new String[4]
	ShoweringAnimationStyleArray[0] = "$BIS_L_SHOWER_OVERRIDE_NONE"
	ShoweringAnimationStyleArray[1] = "$BIS_L_SHOWER_OVERRIDE_DEFAULT"
	ShoweringAnimationStyleArray[2] = "$BIS_L_SHOWER_OVERRIDE_CUSTOM"

	; soap effect styles
	GetSoapyStyleArray = new String[3]
	GetSoapyStyleArray[0] = "$BIS_L_SOAP_STYLE_NONE"
	GetSoapyStyleArray[1] = "$BIS_L_SOAP_STYLE_STATIC"
	GetSoapyStyleArray[2] = "$BIS_L_SOAP_STYLE_ANIMATED"

	; undress array
	UndressArmorSlotArray = new Bool[32]
	UndressArmorSlotArrayFollowers = new Bool[32]
	UndressArmorSlotToggleIDs = new Int[32]
	UndressArmorSlotToggleIDsFollowers = new Int[32]

	; tracked actors array
	TrackedActorsToggleIDs = new Int[128]

	; animation frequency arrays
	AnimCustomMSet = new Float[1]
	AnimCustomFSet = new Float[3]
	AnimCustomMSetFollowers = new Float[1]
	AnimCustomFSetFollowers = new Float[3]

	; set tiered conditioning
	AnimCustomTierCondArray = new String[3]
	AnimCustomTierCondArray[0] = "$BIS_L_ANIM_TIERCOND_NONE"
	AnimCustomTierCondArray[1] = "$BIS_L_ANIM_TIERCOND_DIRTINESS"
	AnimCustomTierCondArray[2] = "$BIS_L_ANIM_TIERCOND_DANGER"
EndFunction
Function SetLocalArrays()
	AnimCustomMSet[0] = AnimCustomMSet1Freq
	AnimCustomFSet[0] = AnimCustomFSet1Freq
	AnimCustomFSet[1] = AnimCustomFSet2Freq
	AnimCustomFSet[2] = AnimCustomFSet3Freq
	AnimCustomMSetFollowers[0] = AnimCustomMSet1FreqFollowers
	AnimCustomFSetFollowers[0] = AnimCustomFSet1FreqFollowers
	AnimCustomFSetFollowers[1] = AnimCustomFSet2FreqFollowers
	AnimCustomFSetFollowers[2] = AnimCustomFSet3FreqFollowers
EndFunction
String Function GetModState()
	if BathingInSkyrimEnabled.GetValue() == 1
		return "$BIS_TXT_ENABLED"
	elseIf BathingInSkyrimEnabled.GetValue() == 0
		return "$BIS_TXT_DISABLED"
	elseIf BathingInSkyrimEnabled.GetValue() == -1
		return "$BIS_TXT_WORKING"
	else
		return "$BIS_TXT_ERRORED" ; function default
	endIf
EndFunction

; initialize events
Event OnConfigInit()
	if CurrentVersion == 0
		VersionUpdate()
		Debug.Notification("BISR: Installed Bathing in Skyrim " + GetModVersion())
	endIf
EndEvent
Event OnVersionUpdate(Int Version)
	if CurrentVersion != 0
		VersionUpdate()
		Debug.Notification("BISR: Updated Bathing in Skyrim " + GetModVersion())
	endIf
EndEvent
Event OnPageReset(String Page)
	If !(BathingInSkyrimEnabled.GetValue() as bool) || (Page == "$BIS_PAGE_SYSTEM_OVERVIEW")
		DisplaySystemOverviewPage()
	ELseIf Page == ""
		DisplaySplashPage()
	ElseIf Page == "$BIS_PAGE_SETTINGS"
		DisplaySettingsPage()
	ElseIf Page == "$BIS_PAGE_ANIMATIONS"
		DisplayAnimationsPage()
	ElseIf Page == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		DisplayAnimationsPageFollowers()
	ElseIf Page == "$BIS_PAGE_TRACKED_ACTORS"
		DisplayTrackedActorsPage()
	EndIf		
EndEvent
Event OnConfigClose()
	IsConfigOpen = false
EndEvent

; display pages
Function DisplaySplashPage()
	UnloadCustomContent()
	LoadCustomContent("Bathing in Skyrim.dds", 56, 63)
EndFunction
Function DisplaySystemOverviewPage()
	UnloadCustomContent()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$BIS_HEADER_SETUP")
	ModStateOID_T = AddTextOption("$BIS_L_MODSTATE", GetModState())
	AddEmptyOption()
	AddHeaderOption("$BIS_HEADER_SAVELOAD")
	PapSetSaveOID_T = AddTextOption("$BIS_L_SAVE_SETTINGS", "$BIS_L_SAVE", (!(BathingInSkyrimEnabled.GetValue() as bool)) as int)
	PapSetLoadOID_T = AddTextOption("$BIS_L_LOAD_SETTINGS", "$BIS_L_LOAD", (!(BathingInSkyrimEnabled.GetValue() as bool)) as int)
	SetCursorPosition(1)
	AddHeaderOption("")
	AddTextOption("$BIS_L_MODVERSION", GetModVersion(), OPTION_FLAG_DISABLED)
	AddTextOption("$BIS_L_VERSION", GetVersion(), OPTION_FLAG_DISABLED)
EndFunction
Function DisplayAnimationsPage()
	UnloadCustomContent()
	
	SetCursorFillMode(TOP_TO_BOTTOM)
		
	AddHeaderOption("$BIS_HEADER_PLAYER_SETTINGS")
	BathingAnimationStyleMenuID = AddMenuOption("$BIS_L_ANIM_STYLE", BathingAnimationStyleArray[BathingAnimationStyle.GetValue() As Int])
	ShoweringAnimationStyleMenuID = AddMenuOption("$BIS_L_SHOWER_OVERRIDE", ShoweringAnimationStyleArray[ShoweringAnimationStyle.GetValue() As Int], (!(BathingAnimationStyle.GetValue() as bool)) as int)
	GetSoapyStyleMenuID = AddMenuOption("$BIS_L_SOAP_STYLE", GetSoapyStyleArray[GetSoapyStyle.GetValue() As Int])
	AutoPlayerTFCID = AddToggleOption("$BIS_L_AUTOPLAYERTFC", AutoPlayerTFC)

	AddHeaderOption("$BIS_HEADER_ANIM_LOOP")
	int ANIM_LOOP_FLAG
	if (BathingAnimationStyle.GetValue() == 1) || (((BathingAnimationStyle.GetValue() as bool)) && (ShoweringAnimationStyle.GetValue() == 1))
		ANIM_LOOP_FLAG = OPTION_FLAG_NONE
	else
		ANIM_LOOP_FLAG = OPTION_FLAG_DISABLED
	endIf
	BathingAnimationLoopsTier0SliderID = AddSliderOption("$BIS_L_ANIM_LOOP_CLEAN", (BathingAnimationLoopCountList.GetAt(0) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)
	BathingAnimationLoopsTier1SliderID = AddSliderOption("$BIS_L_ANIM_LOOP_NOT_DIRTY", (BathingAnimationLoopCountList.GetAt(1) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)
	BathingAnimationLoopsTier2SliderID = AddSliderOption("$BIS_L_ANIM_LOOP_DIRTY", (BathingAnimationLoopCountList.GetAt(2) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)
	BathingAnimationLoopsTier3SliderID = AddSliderOption("$BIS_L_ANIM_LOOP_FILTHY", (BathingAnimationLoopCountList.GetAt(3) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)

	AddHeaderOption("$BIS_HEADER_CUSTOM_FREQ")
	int CUSTOM_FREQ_FLAG
	if (BathingAnimationStyle.GetValue() == 2) || (((BathingAnimationStyle.GetValue() as bool)) && (ShoweringAnimationStyle.GetValue() == 2))
		CUSTOM_FREQ_FLAG = OPTION_FLAG_NONE
	else
		CUSTOM_FREQ_FLAG = OPTION_FLAG_DISABLED
	endIf
	AnimCustomMSet1SliderID = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_MSet1", AnimCustomMSet1Freq, "{0}", CUSTOM_FREQ_FLAG)
	AnimCustomFSet1SliderID = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_FSet1", AnimCustomFSet1Freq, "{0}", CUSTOM_FREQ_FLAG)
	AnimCustomFSet2SliderID = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_FSet2", AnimCustomFSet2Freq, "{0}", CUSTOM_FREQ_FLAG)
	if MiscUtil.FileExists("data/meshes/actors/character/behaviors/FNIS_Bathing_in_Skyrim_JVraven_Behavior.hkx")
		AnimCustomFSet3SliderID = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_FSet3", AnimCustomFSet3Freq, "{0}", CUSTOM_FREQ_FLAG)
	endIf
	AddHeaderOption("$BIS_HEADER_COND_ANIM")
	AnimCustomTierCondMenuID = AddMenuOption("$BIS_L_ANIM_TIERCOND", AnimCustomTierCondArray[AnimCustomTierCond], CUSTOM_FREQ_FLAG)

	SetCursorPosition(1)

	UndressArmorSlotArray = GetUnignoredArmorSlots(BathingIgnoredArmorSlotsMask)	

	AddHeaderOption("$BIS_HEADER_GET_DRESSED")
	GetDressedAfterBathingEnabledToggleID = AddToggleOption("$BIS_L_ENABLED", GetDressedAfterBathingEnabled.GetValue() As Bool)	
	AddHeaderOption("$BIS_HEADER_GET_NAKED_BASIC")
	UndressArmorSlotToggleIDs[0]  = AddToggleOption("$BIS_L_SLOT_30", UndressArmorSlotArray[0])
	UndressArmorSlotToggleIDs[1]  = AddToggleOption("$BIS_L_SLOT_31", UndressArmorSlotArray[1])
	UndressArmorSlotToggleIDs[2]  = AddToggleOption("$BIS_L_SLOT_32", UndressArmorSlotArray[2])
	UndressArmorSlotToggleIDs[3]  = AddToggleOption("$BIS_L_SLOT_33", UndressArmorSlotArray[3])
	UndressArmorSlotToggleIDs[4]  = AddToggleOption("$BIS_L_SLOT_34", UndressArmorSlotArray[4])
	UndressArmorSlotToggleIDs[5]  = AddToggleOption("$BIS_L_SLOT_35", UndressArmorSlotArray[5])
	UndressArmorSlotToggleIDs[6]  = AddToggleOption("$BIS_L_SLOT_36", UndressArmorSlotArray[6])
	UndressArmorSlotToggleIDs[7]  = AddToggleOption("$BIS_L_SLOT_37", UndressArmorSlotArray[7])
	UndressArmorSlotToggleIDs[8]  = AddToggleOption("$BIS_L_SLOT_38", UndressArmorSlotArray[8])
	UndressArmorSlotToggleIDs[9]  = AddToggleOption("$BIS_L_SLOT_39", UndressArmorSlotArray[9])
	UndressArmorSlotToggleIDs[10] = AddToggleOption("$BIS_L_SLOT_40", UndressArmorSlotArray[10])
	UndressArmorSlotToggleIDs[11] = AddToggleOption("$BIS_L_SLOT_41", UndressArmorSlotArray[11])
	UndressArmorSlotToggleIDs[12] = AddToggleOption("$BIS_L_SLOT_42", UndressArmorSlotArray[12])
	UndressArmorSlotToggleIDs[13] = AddToggleOption("$BIS_L_SLOT_43", UndressArmorSlotArray[13])	
	AddHeaderOption("$BIS_HEADER_GET_NAKED_EXTENDED")
	UndressArmorSlotToggleIDs[14] = AddToggleOption("$BIS_L_SLOT_44", UndressArmorSlotArray[14])
	UndressArmorSlotToggleIDs[15] = AddToggleOption("$BIS_L_SLOT_45", UndressArmorSlotArray[15])
	UndressArmorSlotToggleIDs[16] = AddToggleOption("$BIS_L_SLOT_46", UndressArmorSlotArray[16])
	UndressArmorSlotToggleIDs[17] = AddToggleOption("$BIS_L_SLOT_47", UndressArmorSlotArray[17])
	UndressArmorSlotToggleIDs[18] = AddToggleOption("$BIS_L_SLOT_48", UndressArmorSlotArray[18])
	UndressArmorSlotToggleIDs[19] = AddToggleOption("$BIS_L_SLOT_49", UndressArmorSlotArray[19])
	UndressArmorSlotToggleIDs[20] = AddToggleOption("$BIS_L_SLOT_50", UndressArmorSlotArray[20])
	UndressArmorSlotToggleIDs[21] = AddToggleOption("$BIS_L_SLOT_51", UndressArmorSlotArray[21])
	UndressArmorSlotToggleIDs[22] = AddToggleOption("$BIS_L_SLOT_52", UndressArmorSlotArray[22])
	UndressArmorSlotToggleIDs[23] = AddToggleOption("$BIS_L_SLOT_53", UndressArmorSlotArray[23])
	UndressArmorSlotToggleIDs[24] = AddToggleOption("$BIS_L_SLOT_54", UndressArmorSlotArray[24])
	UndressArmorSlotToggleIDs[25] = AddToggleOption("$BIS_L_SLOT_55", UndressArmorSlotArray[25])
	UndressArmorSlotToggleIDs[26] = AddToggleOption("$BIS_L_SLOT_56", UndressArmorSlotArray[26])
	UndressArmorSlotToggleIDs[27] = AddToggleOption("$BIS_L_SLOT_57", UndressArmorSlotArray[27])
	UndressArmorSlotToggleIDs[28] = AddToggleOption("$BIS_L_SLOT_58", UndressArmorSlotArray[28])
	UndressArmorSlotToggleIDs[29] = AddToggleOption("$BIS_L_SLOT_59", UndressArmorSlotArray[29])
	UndressArmorSlotToggleIDs[30] = AddToggleOption("$BIS_L_SLOT_60", UndressArmorSlotArray[30])
	UndressArmorSlotToggleIDs[31] = AddToggleOption("$BIS_L_SLOT_61", UndressArmorSlotArray[31])
EndFunction
Function DisplayAnimationsPageFollowers()
	UnloadCustomContent()
	
	SetCursorFillMode(TOP_TO_BOTTOM)
		
	AddHeaderOption("$BIS_HEADER_FOLLOWER_SETTINGS")
	BathingAnimationStyleMenuIDFollowers = AddMenuOption("$BIS_L_ANIM_STYLE", BathingAnimationStyleArray[BathingAnimationStyleFollowers.GetValue() As Int])
	ShoweringAnimationStyleMenuIDFollowers = AddMenuOption("$BIS_L_SHOWER_OVERRIDE", ShoweringAnimationStyleArray[ShoweringAnimationStyleFollowers.GetValue() As Int], (!(BathingAnimationStyleFollowers.GetValue() as bool)) as int)
	GetSoapyStyleMenuIDFollowers = AddMenuOption("$BIS_L_SOAP_STYLE", GetSoapyStyleArray[GetSoapyStyleFollowers.GetValue() As Int])

	AddHeaderOption("$BIS_HEADER_ANIM_LOOP")
	int ANIM_LOOP_FLAG
	if (BathingAnimationStyleFollowers.GetValue() == 1) || (((BathingAnimationStyleFollowers.GetValue() as bool)) && (ShoweringAnimationStyleFollowers.GetValue() == 1))
		ANIM_LOOP_FLAG = OPTION_FLAG_NONE
	else
		ANIM_LOOP_FLAG = OPTION_FLAG_DISABLED
	endIf
	BathingAnimationLoopsTier0SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_LOOP_CLEAN", (BathingAnimationLoopCountListFollowers.GetAt(0) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)
	BathingAnimationLoopsTier1SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_LOOP_NOT_DIRTY", (BathingAnimationLoopCountListFollowers.GetAt(1) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)
	BathingAnimationLoopsTier2SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_LOOP_DIRTY", (BathingAnimationLoopCountListFollowers.GetAt(2) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)
	BathingAnimationLoopsTier3SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_LOOP_FILTHY", (BathingAnimationLoopCountListFollowers.GetAt(3) As GlobalVariable).GetValue(), "{0}", ANIM_LOOP_FLAG)

	AddHeaderOption("$BIS_HEADER_CUSTOM_FREQ")
	int CUSTOM_FREQ_FLAG
	if (BathingAnimationStyleFollowers.GetValue() == 2) || (((BathingAnimationStyleFollowers.GetValue() as bool)) && (ShoweringAnimationStyleFollowers.GetValue() == 2))
		CUSTOM_FREQ_FLAG = OPTION_FLAG_NONE
	else
		CUSTOM_FREQ_FLAG = OPTION_FLAG_DISABLED
	endIf
	AnimCustomMSet1SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_MSet1", AnimCustomMSet1FreqFollowers, "{0}", CUSTOM_FREQ_FLAG)
	AnimCustomFSet1SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_FSet1", AnimCustomFSet1FreqFollowers, "{0}", CUSTOM_FREQ_FLAG)
	AnimCustomFSet2SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_FSet2", AnimCustomFSet2FreqFollowers, "{0}", CUSTOM_FREQ_FLAG)
	if MiscUtil.FileExists("data/meshes/actors/character/behaviors/FNIS_Bathing_in_Skyrim_JVraven_Behavior.hkx")
		AnimCustomFSet3SliderIDFollowers = AddSliderOption("$BIS_L_ANIM_STYLE_CUSTOM_FSet3", AnimCustomFSet3FreqFollowers, "{0}", CUSTOM_FREQ_FLAG)
	endIf
	AddHeaderOption("$BIS_HEADER_COND_ANIM")
	AnimCustomTierCondMenuIDFollowers = AddMenuOption("$BIS_L_ANIM_TIERCOND", AnimCustomTierCondArray[AnimCustomTierCondFollowers], CUSTOM_FREQ_FLAG)

	SetCursorPosition(1)

	UndressArmorSlotArrayFollowers = GetUnignoredArmorSlots(BathingIgnoredArmorSlotsMaskFollowers)	

	AddHeaderOption("$BIS_HEADER_GET_DRESSED")
	GetDressedAfterBathingEnabledToggleIDFollowers = AddToggleOption("$BIS_L_ENABLED", GetDressedAfterBathingEnabledFollowers.GetValue() As Bool)	
	AddHeaderOption("$BIS_HEADER_GET_NAKED_BASIC")
	UndressArmorSlotToggleIDsFollowers[0]  = AddToggleOption("$BIS_L_SLOT_30", UndressArmorSlotArrayFollowers[0])
	UndressArmorSlotToggleIDsFollowers[1]  = AddToggleOption("$BIS_L_SLOT_31", UndressArmorSlotArrayFollowers[1])
	UndressArmorSlotToggleIDsFollowers[2]  = AddToggleOption("$BIS_L_SLOT_32", UndressArmorSlotArrayFollowers[2])
	UndressArmorSlotToggleIDsFollowers[3]  = AddToggleOption("$BIS_L_SLOT_33", UndressArmorSlotArrayFollowers[3])
	UndressArmorSlotToggleIDsFollowers[4]  = AddToggleOption("$BIS_L_SLOT_34", UndressArmorSlotArrayFollowers[4])
	UndressArmorSlotToggleIDsFollowers[5]  = AddToggleOption("$BIS_L_SLOT_35", UndressArmorSlotArrayFollowers[5])
	UndressArmorSlotToggleIDsFollowers[6]  = AddToggleOption("$BIS_L_SLOT_36", UndressArmorSlotArrayFollowers[6])
	UndressArmorSlotToggleIDsFollowers[7]  = AddToggleOption("$BIS_L_SLOT_37", UndressArmorSlotArrayFollowers[7])
	UndressArmorSlotToggleIDsFollowers[8]  = AddToggleOption("$BIS_L_SLOT_38", UndressArmorSlotArrayFollowers[8])
	UndressArmorSlotToggleIDsFollowers[9]  = AddToggleOption("$BIS_L_SLOT_39", UndressArmorSlotArrayFollowers[9])
	UndressArmorSlotToggleIDsFollowers[10] = AddToggleOption("$BIS_L_SLOT_40", UndressArmorSlotArrayFollowers[10])
	UndressArmorSlotToggleIDsFollowers[11] = AddToggleOption("$BIS_L_SLOT_41", UndressArmorSlotArrayFollowers[11])
	UndressArmorSlotToggleIDsFollowers[12] = AddToggleOption("$BIS_L_SLOT_42", UndressArmorSlotArrayFollowers[12])
	UndressArmorSlotToggleIDsFollowers[13] = AddToggleOption("$BIS_L_SLOT_43", UndressArmorSlotArrayFollowers[13])	
	AddHeaderOption("$BIS_HEADER_GET_NAKED_EXTENDED")
	UndressArmorSlotToggleIDsFollowers[14] = AddToggleOption("$BIS_L_SLOT_44", UndressArmorSlotArrayFollowers[14])
	UndressArmorSlotToggleIDsFollowers[15] = AddToggleOption("$BIS_L_SLOT_45", UndressArmorSlotArrayFollowers[15])
	UndressArmorSlotToggleIDsFollowers[16] = AddToggleOption("$BIS_L_SLOT_46", UndressArmorSlotArrayFollowers[16])
	UndressArmorSlotToggleIDsFollowers[17] = AddToggleOption("$BIS_L_SLOT_47", UndressArmorSlotArrayFollowers[17])
	UndressArmorSlotToggleIDsFollowers[18] = AddToggleOption("$BIS_L_SLOT_48", UndressArmorSlotArrayFollowers[18])
	UndressArmorSlotToggleIDsFollowers[19] = AddToggleOption("$BIS_L_SLOT_49", UndressArmorSlotArrayFollowers[19])
	UndressArmorSlotToggleIDsFollowers[20] = AddToggleOption("$BIS_L_SLOT_50", UndressArmorSlotArrayFollowers[20])
	UndressArmorSlotToggleIDsFollowers[21] = AddToggleOption("$BIS_L_SLOT_51", UndressArmorSlotArrayFollowers[21])
	UndressArmorSlotToggleIDsFollowers[22] = AddToggleOption("$BIS_L_SLOT_52", UndressArmorSlotArrayFollowers[22])
	UndressArmorSlotToggleIDsFollowers[23] = AddToggleOption("$BIS_L_SLOT_53", UndressArmorSlotArrayFollowers[23])
	UndressArmorSlotToggleIDsFollowers[24] = AddToggleOption("$BIS_L_SLOT_54", UndressArmorSlotArrayFollowers[24])
	UndressArmorSlotToggleIDsFollowers[25] = AddToggleOption("$BIS_L_SLOT_55", UndressArmorSlotArrayFollowers[25])
	UndressArmorSlotToggleIDsFollowers[26] = AddToggleOption("$BIS_L_SLOT_56", UndressArmorSlotArrayFollowers[26])
	UndressArmorSlotToggleIDsFollowers[27] = AddToggleOption("$BIS_L_SLOT_57", UndressArmorSlotArrayFollowers[27])
	UndressArmorSlotToggleIDsFollowers[28] = AddToggleOption("$BIS_L_SLOT_58", UndressArmorSlotArrayFollowers[28])
	UndressArmorSlotToggleIDsFollowers[29] = AddToggleOption("$BIS_L_SLOT_59", UndressArmorSlotArrayFollowers[29])
	UndressArmorSlotToggleIDsFollowers[30] = AddToggleOption("$BIS_L_SLOT_60", UndressArmorSlotArrayFollowers[30])
	UndressArmorSlotToggleIDsFollowers[31] = AddToggleOption("$BIS_L_SLOT_61", UndressArmorSlotArrayFollowers[31])
EndFunction

Function DisplaySettingsPage()

	UnloadCustomContent()
	
	SetCursorFillMode(TOP_TO_BOTTOM)
	
	AddHeaderOption("$BIS_HEADER_GENERAL")

	DialogTopicEnableToggleID = AddToggleOption("$BIS_L_ENABLED_DIALOG_TOPIC", DialogTopicEnabled.GetValue() As Bool)
	AutomateFollowerBathingMenuID = AddMenuOption("$BIS_L_AUTOMATE_FOLLOWER_BATHING", AutomateFollowerBathingArray[AutomateFollowerBathing.GetValue() As Int])
	WaterRestrictionEnableToggleID = AddToggleOption("$BIS_L_WATER_RESTRICT",WaterRestrictionEnabled.GetValue() As Bool)
	UpdateIntervalSliderID = AddSliderOption("$BIS_L_UPDATE_INTERVAL", DirtinessUpdateInterval.GetValue(), DisplayFormatDecimal)
	AddHeaderOption("$BIS_HEADER_HOTKEYS")
	CheckStatusKeyMapID = AddKeyMapOption("$BIS_L_STATUS_HOTKEY", CheckStatusKeyCode.GetValue() As Int)
	BatheKeyMapID = AddKeyMapOption("$BIS_L_BATHE_HOTKEY", BatheKeyCode.GetValue() As Int)
	ShowerKeyMapID = AddKeyMapOption("$BIS_L_SHOWER_HOTKEY", ShowerKeyCode.GetValue() As Int)

	If Game.GetModByName("FadeTattoos.esp") != 255
		AddHeaderOption("$BIS_HEADER_FADE_TATTOOS")
		FadeTatsFadeTimeOID_S = AddSliderOption("$BIS_L_FADETATSADVANCE", FadeTatsFadeTime, DisplayFormatDecimal)
		FadeTatsSoapMultOID_S = AddSliderOption("$BIS_L_FADETATSMULT", FadeTatsSoapMult, DisplayFormatDecimal)
	EndIf
	
	If FadeDirtSex
		SetCursorPosition(36)
		AddHeaderOption("$BIS_HEADER_FADEDIRTSEX")
		AddTextOption("$BIS_L_FADEDIRT_NPCNV_{" + ((DirtinessPerSexActor / SexIntervalDirt) * 100.0) + "}", "")
		AddTextOption("$BIS_L_FADEDIRT_NPCV_{" + (((DirtinessPerSexActor * VictimMult)/ SexIntervalDirt) * 100.0) + "}", "")
		AddTextOption("$BIS_L_FADEDIRT_CREATURENV_{" + (((DirtinessPerSexActor * 2) / SexIntervalDirt) * 100.0) + "}", "")
		AddTextOption("$BIS_L_FADEDIRT_CREATUREV_{" + (((DirtinessPerSexActor * 2 * VictimMult) / SexIntervalDirt) * 100.0) + "}", "")
	EndIf
	
	SetCursorPosition(1)

	AddHeaderOption("$BIS_HEADER_DIRT_RATE")
	DirtinessPerHourPlayerHouseSliderID = AddSliderOption("$BIS_L_IN_PLAYERHOUSE", DirtinessPerHourPlayerHouse.GetValue() * 100, DisplayFormatPercentage)
	DirtinessPerHourSettlementSliderID = AddSliderOption("$BIS_L_IN_SETTLEMENTS", DirtinessPerHourSettlement.GetValue() * 100, DisplayFormatPercentage)
	DirtinessPerHourDungeonSliderID = AddSliderOption("$BIS_L_IN_DUNGEONS", DirtinessPerHourDungeon.GetValue() * 100, DisplayFormatPercentage)
	DirtinessPerHourWildernessSliderID = AddSliderOption("$BIS_L_IN_WILDERNESS", DirtinessPerHourWilderness.GetValue() * 100, DisplayFormatPercentage)
	AddHeaderOption("$BIS_HEADER_DIRT_THRESHOLDS")
	DirtinessThresholdTier1SliderID = AddSliderOption("$BIS_L_GET_NOT_DIRTY", (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue() * 100, DisplayFormatPercentage)
	DirtinessThresholdTier2SliderID = AddSliderOption("$BIS_L_GET_DIRTY", (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue() * 100, DisplayFormatPercentage)
	DirtinessThresholdTier3SliderID = AddSliderOption("$BIS_L_GET_FILTHY", (DirtinessThresholdList.GetAt(2) As GlobalVariable).GetValue() * 100, DisplayFormatPercentage)
	
	SetCursorPosition(19)
	AddHeaderOption("$BIS_HEADER_OVERLAYS")
	OverlayApplyAtOID_S = AddSliderOption("$BIS_L_OVERLAYAPPLY", OverlayApplyAt * 100.0, "$BIS_L_OVERLAYAPPLYDISPLAY_{}")
	StartingAlphaOID_S = AddSliderOption("$BIS_L_OVERLAYALPHA", StartingAlpha * 100.0, DisplayFormatPercentage)
	TimeToCleanOID_S = AddSliderOption("$BIS_L_OVERLAYTIMETOCLEAN", TimeToClean, DisplayFormatDecimal)
	TimeToCleanIntervalOID_S = AddSliderOption("$BIS_L_OVERLAYTIMETOCLEANINTERVAL", TimeToCleanInterval, DisplayFormatDecimal)
	TexSetCountOID_T = AddTextOption("$BIS_L_OVERLAYTEXSETCOUNT_{" + TexUtil.DirtSetCount + "}", "")
	RedetectDirtSetsOID_T = AddTextOption("$BIS_L_OVERLAYREDETECT", "")
	RemoveAllOverlaysOID_T = AddTextOption("$BIS_L_OVERLAYREMOVEALL", "")
	OverlayProgressOID_T = AddTextOption("", "$BIS_L_INACTIVE")
	
	If Init.IsSexlabInstalled
		AddHeaderOption("$BIS_HEADER_SEX")
		DirtinessPerSexOID_S = AddSliderOption("$BIS_L_DIRTPERSEX", DirtinessPerSexActor * 100.0, DisplayFormatPercentage)
		VictimMultOID_S = AddSliderOption("$BIS_L_VICTIMMULT", VictimMult, DisplayFormatDecimal)
		FadeDirtSexToggleID = AddToggleOption("$BIS_L_FADEDIRTSEX", FadeDirtSex)
		
		If FadeDirtSex
			SexIntervalDirtOID_S = AddSliderOption("$BIS_L_SEXINTERVALDIRT", SexIntervalDirt, DisplayFormatDecimal)
			SexIntervalOID_S = AddSliderOption("$BIS_L_SEXINTERVAL", SexInterval, DisplayFormatDecimal)
		Else
			SexIntervalDirtOID_S = AddSliderOption("$BIS_L_SEXINTERVALDIRT", SexIntervalDirt, DisplayFormatDecimal, OPTION_FLAG_DISABLED)
			SexIntervalOID_S = AddSliderOption("$BIS_L_SEXINTERVAL", SexInterval, DisplayFormatDecimal, OPTION_FLAG_DISABLED)
		EndIf
	EndIf

	AddHeaderOption("$BIS_HEADER_MISC")
	ShynessToggleID = AddToggleOption("$BIS_L_SHYNESSTOGGLE", Shyness)
	ShyDistanceOID_S = AddSliderOption("$BIS_L_SHYDISTANCE", ShyDistance, DisplayFormatDecimal)
	
	AddHeaderOption("$BIS_HEADER_DEBUG")
	UnForbidOID_T = AddTextOption("$BIS_L_UNFORBID", "")
	
EndFunction
Function DisplayTrackedActorsPage()
	Int TrackedActorsCount = DirtyActors.GetSize()
	If TrackedActorsCount > 128
		TrackedActorsCount = 128
	EndIf

	UnloadCustomContent()
	
	SetCursorFillMode(TOP_TO_BOTTOM)

	AddHeaderOption("$BIS_HEADER_TRACKED_ACTORS")
	Int Index = TrackedActorsCount
	While Index
		Index -= 1
		Actor DirtyActor = DirtyActors.GetAt(Index) As Actor
		String DirtinessString = ""
		If DirtyActor.HasSpell(DirtinessSpellList.GetAt(0) As Spell)
			DirtinessString = "$BIS_TXT_CLEAN"
		EndIf
		If DirtyActor.HasSpell(DirtinessSpellList.GetAt(1) As Spell)
			DirtinessString = "$BIS_TXT_NOTDIRTY"
		EndIf
		If DirtyActor.HasSpell(DirtinessSpellList.GetAt(2) As Spell)
			DirtinessString = "$BIS_TXT_DIRTY"
		EndIf
		If DirtyActor.HasSpell(DirtinessSpellList.GetAt(3) As Spell)
			DirtinessString = "$BIS_TXT_FILTHY"
		EndIf
		TrackedActorsToggleIDs[Index] = AddTextOption(DirtyActor.GetActorBase().GetName(), DirtinessString, OPTION_FLAG_NONE)
	EndWhile
EndFunction

; OnOptionDefault
Event OnOptionDefault(Int OptionID)
	If CurrentPage == "$BIS_PAGE_SYSTEM_OVERVIEW" || CurrentPage == ""
		HandleOnOptionDefaultSystemOverviewPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_SETTINGS"
		HandleOnOptionDefaultSettingsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS"
		HandleOnOptionDefaultAnimationsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		HandleOnOptionDefaultAnimationsPageFollowers(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_TRACKED_ACTORS"
		HandleOnOptionDefaultTrackedActorsPage(OptionID)
	EndIf
EndEvent
Function HandleOnOptionDefaultAnimationsPage(Int OptionID)
	; menus
	If OptionID == BathingAnimationStyleMenuID
		BathingAnimationStyle.SetValue(1)
		SetMenuOptionValue(OptionID, BathingAnimationStyleArray[BathingAnimationStyle.GetValue() As Int])
	ElseIf OptionID == ShoweringAnimationStyleMenuID
		ShoweringAnimationStyle.SetValue(0)
		SetMenuOptionValue(OptionID, ShoweringAnimationStyleArray[ShoweringAnimationStyle.GetValue() As Int])
	ElseIf OptionID == GetSoapyStyleMenuID
		GetSoapyStyle.SetValue(1)
		SetMenuOptionValue(OptionID, GetSoapyStyleArray[GetSoapyStyle.GetValue() As Int])
	ElseIf OptionID == AnimCustomTierCondMenuID
		AnimCustomTierCond = 1
		SetMenuOptionValue(OptionID, AnimCustomTierCondArray[AnimCustomTierCond])

	; sliders
	ElseIf OptionID == BathingAnimationLoopsTier0SliderID
		(BathingAnimationLoopCountList.GetAt(0) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountList.GetAt(0) As GlobalVariable).GetValue(), "{0}")
	ElseIf OptionID == BathingAnimationLoopsTier1SliderID
		(BathingAnimationLoopCountList.GetAt(1) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountList.GetAt(1) As GlobalVariable).GetValue(), "{0}")
	ElseIf OptionID == BathingAnimationLoopsTier2SliderID
		(BathingAnimationLoopCountList.GetAt(2) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountList.GetAt(2) As GlobalVariable).GetValue(), "{0}")
	ElseIf OptionID == BathingAnimationLoopsTier3SliderID
		(BathingAnimationLoopCountList.GetAt(3) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountList.GetAt(3) As GlobalVariable).GetValue(), "{0}")
	
	ElseIf OptionID == AnimCustomMSet1SliderID
		AnimCustomMSet1Freq = 0
		AnimCustomMSet[0] = AnimCustomMSet1Freq
		SetSliderOptionValue(OptionID, AnimCustomMSet1Freq, "{0}")
	ElseIf OptionID == AnimCustomFSet1SliderID
		AnimCustomFSet1Freq = 0
		AnimCustomFSet[0] = AnimCustomFSet1Freq
		SetSliderOptionValue(OptionID, AnimCustomFSet1Freq, "{0}")
	ElseIf OptionID == AnimCustomFSet2SliderID
		AnimCustomFSet2Freq = 0
		AnimCustomFSet[1] = AnimCustomFSet2Freq
		SetSliderOptionValue(OptionID, AnimCustomFSet2Freq, "{0}")
	ElseIf OptionID == AnimCustomFSet3SliderID
		AnimCustomFSet3Freq = 0
		AnimCustomFSet[2] = AnimCustomFSet3Freq
		SetSliderOptionValue(OptionID, AnimCustomFSet3Freq, "{0}")

	; toggles
	ElseIf OptionID == AutoPlayerTFCID
		AutoPlayerTFC = False
	ElseIf OptionID == GetDressedAfterBathingEnabledToggleID
		GetDressedAfterBathingEnabled.SetValue(1)
		SetToggleOptionValue(OptionID, GetDressedAfterBathingEnabled.GetValue() As Bool)
	Else 
		Int UndressArmorSlotIndex = UndressArmorSlotToggleIDs.Find(OptionID)
		If UndressArmorSlotIndex >= 0
			If UndressArmorSlotIndex <= 13 ; undress 30-43 by default
				IgnoreArmorSlot(BathingIgnoredArmorSlotsMask, UndressArmorSlotIndex + 30, False)
				SetToggleOptionValue(OptionID, True)
			Else ; ignore 44-62 by default
				IgnoreArmorSlot(BathingIgnoredArmorSlotsMask, UndressArmorSlotIndex + 30, True)
				SetToggleOptionValue(OptionID, False)
			EndIf
		EndIf
	EndIf	
EndFunction
Function HandleOnOptionDefaultAnimationsPageFollowers(Int OptionID)	
	; menus
	If OptionID == BathingAnimationStyleMenuIDFollowers
		BathingAnimationStyleFollowers.SetValue(1)
		SetMenuOptionValue(OptionID, BathingAnimationStyleArray[BathingAnimationStyleFollowers.GetValue() As Int])
	ElseIf OptionID == ShoweringAnimationStyleMenuIDFollowers
		ShoweringAnimationStyleFollowers.SetValue(0)
		SetMenuOptionValue(OptionID, BathingAnimationStyleArray[BathingAnimationStyleFollowers.GetValue() As Int])
	ElseIf OptionID == GetSoapyStyleMenuIDFollowers
		GetSoapyStyleFollowers.SetValue(1)
		SetMenuOptionValue(OptionID, GetSoapyStyleArray[GetSoapyStyleFollowers.GetValue() As Int])
	ElseIf OptionID == AnimCustomTierCondMenuIDFollowers
		AnimCustomTierCondFollowers = 1
		SetMenuOptionValue(OptionID, AnimCustomTierCondArray[AnimCustomTierCondFollowers])

	; sliders
	ElseIf OptionID == BathingAnimationLoopsTier0SliderIDFollowers
		(BathingAnimationLoopCountListFollowers.GetAt(0) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountListFollowers.GetAt(0) As GlobalVariable).GetValue(), "{0}")
	ElseIf OptionID == BathingAnimationLoopsTier1SliderIDFollowers
		(BathingAnimationLoopCountListFollowers.GetAt(1) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountListFollowers.GetAt(1) As GlobalVariable).GetValue(), "{0}")
	ElseIf OptionID == BathingAnimationLoopsTier2SliderIDFollowers
		(BathingAnimationLoopCountListFollowers.GetAt(2) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountListFollowers.GetAt(2) As GlobalVariable).GetValue(), "{0}")
	ElseIf OptionID == BathingAnimationLoopsTier3SliderIDFollowers
		(BathingAnimationLoopCountListFollowers.GetAt(3) As GlobalVariable).SetValue(1)
		SetSliderOptionValue(OptionID, (BathingAnimationLoopCountListFollowers.GetAt(3) As GlobalVariable).GetValue(), "{0}")

	ElseIf OptionID == AnimCustomMSet1SliderIDFollowers
		AnimCustomMSet1FreqFollowers = 0
		AnimCustomMSetFollowers[0] = AnimCustomMSet1FreqFollowers
		SetSliderOptionValue(OptionID, AnimCustomMSet1FreqFollowers, "{0}")
	ElseIf OptionID == AnimCustomFSet1SliderIDFollowers
		AnimCustomFSet1FreqFollowers = 0
		AnimCustomFSetFollowers[0] = AnimCustomFSet1FreqFollowers
		SetSliderOptionValue(OptionID, AnimCustomFSet1FreqFollowers, "{0}")
	ElseIf OptionID == AnimCustomFSet2SliderIDFollowers
		AnimCustomFSet2FreqFollowers = 0
		AnimCustomFSetFollowers[1] = AnimCustomFSet2FreqFollowers
		SetSliderOptionValue(OptionID, AnimCustomFSet2FreqFollowers, "{0}")
	ElseIf OptionID == AnimCustomFSet3SliderIDFollowers
		AnimCustomFSet3FreqFollowers = 0
		AnimCustomFSetFollowers[2] = AnimCustomFSet3FreqFollowers
		SetSliderOptionValue(OptionID, AnimCustomFSet3FreqFollowers, "{0}")

	; toggles
	ElseIf OptionID == GetDressedAfterBathingEnabledToggleIDFollowers
		GetDressedAfterBathingEnabledFollowers.SetValue(1)
		SetToggleOptionValue(OptionID, GetDressedAfterBathingEnabledFollowers.GetValue() As Bool)
	Else 
		Int UndressArmorSlotIndex = UndressArmorSlotToggleIDsFollowers.Find(OptionID)
		If UndressArmorSlotIndex >= 0
			If UndressArmorSlotIndex <= 13 ; undress 30-43 by default
				IgnoreArmorSlot(BathingIgnoredArmorSlotsMaskFollowers, UndressArmorSlotIndex + 30, False)
				SetToggleOptionValue(OptionID, True)
			Else ; ignore 44-62 by default
				IgnoreArmorSlot(BathingIgnoredArmorSlotsMaskFollowers, UndressArmorSlotIndex + 30, True)
				SetToggleOptionValue(OptionID, False)
			EndIf
		EndIf
	EndIf	
EndFunction
Function HandleOnOptionDefaultSystemOverviewPage(Int OptionID)
	If OptionID == ModStateOID_T
		BathingInSkyrimEnabled.SetValue(-1)
		SetTextOptionValue(OptionID, "$BIS_TXT_DISABLED", false)
		DisableBathingInSkyrim()
	endIf
EndFunction
Function HandleOnOptionDefaultSettingsPage(Int OptionID)
	; toggles
	If OptionID == DialogTopicEnableToggleID
		DialogTopicEnabled.SetValue(1)
		SetToggleOptionValue(OptionID, DialogTopicEnabled.GetValue() As Bool)
	ElseIf OptionID == WaterRestrictionEnableToggleID
		WaterRestrictionEnabled.SetValue(1)
		SetToggleOptionValue(OptionID, WaterRestrictionEnabled.GetValue() As Bool)
	ElseIf OptionID == FadeDirtSexToggleID
		FadeDirtSex = true
		SetToggleOptionValue(OptionID, FadeDirtSex)
	ElseIf OptionID == ShynessToggleID
		Shyness = true
		SetToggleOptionValue(OptionID, Shyness)
	; sliders
	ElseIf OptionID == UpdateIntervalSliderID
		DirtinessUpdateInterval.SetValue(1.0)
		SetSliderOptionValue(OptionID, DirtinessUpdateInterval.GetValue(), DisplayFormatDecimal)
	ElseIf OptionID == DirtinessPerHourPlayerHouseSliderID
		DirtinessPerHourPlayerHouse.SetValue(0.00)
		SetSliderOptionValue(OptionID, DirtinessPerHourPlayerHouse.GetValue() * 100, DisplayFormatPercentage)
	ElseIf OptionID == DirtinessPerHourSettlementSliderID
		DirtinessPerHourSettlement.SetValue(0.01)
		SetSliderOptionValue(OptionID, DirtinessPerHourSettlement.GetValue() * 100, DisplayFormatPercentage)
	ElseIf OptionID == DirtinessPerHourDungeonSliderID
		DirtinessPerHourDungeon.SetValue(0.025)
		SetSliderOptionValue(OptionID, DirtinessPerHourDungeon.GetValue() * 100, DisplayFormatPercentage)
	ElseIf OptionID == DirtinessPerHourWildernessSliderID
		DirtinessPerHourWilderness.SetValue(0.015)
		SetSliderOptionValue(OptionID, DirtinessPerHourWilderness.GetValue() * 100, DisplayFormatPercentage)
	ElseIf OptionID == DirtinessThresholdTier1SliderID
		(DirtinessThresholdList.GetAt(0) As GlobalVariable).SetValue(0.20)
		SetSliderOptionValue(OptionID, (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue() * 100, DisplayFormatPercentage)
	ElseIf OptionID == DirtinessThresholdTier2SliderID
		(DirtinessThresholdList.GetAt(1) As GlobalVariable).SetValue(0.60)
		SetSliderOptionValue(OptionID, (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue() * 100, DisplayFormatPercentage)
	ElseIf OptionID == DirtinessThresholdTier3SliderID
		(DirtinessThresholdList.GetAt(2) As GlobalVariable).SetValue(0.98)
		SetSliderOptionValue(OptionID, (DirtinessThresholdList.GetAt(2) As GlobalVariable).GetValue() * 100, DisplayFormatPercentage)	
	ElseIf OptionID == SexIntervalDirtOID_S
		SexIntervalDirt = 35.0
		SetSliderOptionValue(OptionID, SexIntervalDirt, DisplayFormatDecimal)
	ElseIf OptionID == SexIntervalOID_S
		SexIntervalDirt = 1.0
		SetSliderOptionValue(OptionID, SexIntervalDirt, DisplayFormatDecimal)	
	; menus
	ElseIf OptionID == AutomateFollowerBathingMenuID
		AutomateFollowerBathing.SetValue(1)
		SetMenuOptionValue(OptionID, AutomateFollowerBathingArray[AutomateFollowerBathing.GetValue() As Int])
	EndIf
EndFunction
Function HandleOnOptionDefaultTrackedActorsPage(Int OptionID)
EndFunction

; OnOptionHighlight
Event OnOptionHighlight(Int OptionID)
	If CurrentPage == "$BIS_PAGE_SYSTEM_OVERVIEW" || CurrentPage == ""
		HandleOnOptionHighlightSystemOverviewPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_SETTINGS"
		HandleOnOptionHighlightSettingsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS"
		HandleOnOptionHighlightAnimationsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		HandleOnOptionHighlightAnimationsPageFollowers(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_TRACKED_ACTORS"
		HandleOnOptionHighlightTrackedActorsPage(OptionID)
	EndIf	
EndEvent
Function HandleOnOptionHighlightAnimationsPage(Int OptionID)
	If OptionID == BathingAnimationStyleMenuID
		SetInfoText("$BIS_DESC_ANIM_STYLE")
	ElseIf OptionID == ShoweringAnimationStyleMenuID
		SetInfoText("$BIS_DESC_SHOWER_OVERRIDE")
	ElseIf OptionID == GetSoapyStyleMenuID
		SetInfoText("$BIS_DESC_SOAP_STYLE")
	ElseIf OptionID == AutoPlayerTFCID
		SetInfoText("$BIS_DESC_AUTOPLAYERTFC")
	ElseIf OptionId == BathingAnimationLoopsTier0SliderID
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER0")
	ElseIf OptionId == BathingAnimationLoopsTier1SliderID
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER1")
	ElseIf OptionId == BathingAnimationLoopsTier2SliderID
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER2")
	ElseIf OptionId == BathingAnimationLoopsTier3SliderID
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER3")
	ElseIf OptionId == AnimCustomMSet1SliderID
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_MSet1")
	ElseIf OptionId == AnimCustomFSet1SliderID
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_FSet1")
	ElseIf OptionId == AnimCustomFSet2SliderID
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_FSet2")
	ElseIf OptionId == AnimCustomFSet3SliderID
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_FSet3")
	ElseIf OptionId == AnimCustomTierCondMenuID
		SetInfoText("$BIS_DESC_ANIM_TIERCOND")
	ElseIf OptionID == GetDressedAfterBathingEnabledToggleID
		SetInfoText("$BIS_DESC_GET_DRESSED")
	Else
		SetInfoText("$BIS_DESC_GET_NAKED")
	EndIf
EndFunction
Function HandleOnOptionHighlightAnimationsPageFollowers(Int OptionID)
	If OptionID == BathingAnimationStyleMenuIDFollowers
		SetInfoText("$BIS_DESC_ANIM_STYLE")
	ElseIf OptionID == ShoweringAnimationStyleMenuIDFollowers
		SetInfoText("$BIS_DESC_SHOWER_OVERRIDE")
	ElseIf OptionID == GetSoapyStyleMenuIDFollowers
		SetInfoText("$BIS_DESC_SOAP_STYLE")
	ElseIf OptionId == BathingAnimationLoopsTier0SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER0")
	ElseIf OptionId == BathingAnimationLoopsTier1SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER1")
	ElseIf OptionId == BathingAnimationLoopsTier2SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER2")
	ElseIf OptionId == BathingAnimationLoopsTier3SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_LOOP_TIER3")
	ElseIf OptionId == AnimCustomMSet1SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_MSet1")
	ElseIf OptionId == AnimCustomFSet1SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_FSet1")
	ElseIf OptionId == AnimCustomFSet2SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_FSet2")
	ElseIf OptionId == AnimCustomFSet3SliderIDFollowers
		SetInfoText("$BIS_DESC_ANIM_STYLE_CUSTOM_FSet3")
	ElseIf OptionId == AnimCustomTierCondMenuIDFollowers
		SetInfoText("$BIS_DESC_ANIM_TIERCOND")
	ElseIf OptionID == GetDressedAfterBathingEnabledToggleIDFollowers
		SetInfoText("$BIS_DESC_GET_DRESSED")
	Else
		SetInfoText("$BIS_DESC_GET_NAKED")
	EndIf
EndFunction
Function HandleOnOptionHighlightSystemOverviewPage(Int OptionID)
	If OptionID == ModStateOID_T
		SetInfoText("$BIS_DESC_ENABLE_MOD")
	ElseIf OptionID == PapSetSaveOID_T
		SetInfoText("$BIS_DESC_SAVE_SETTINGS")
	ElseIf OptionID == PapSetLoadOID_T
		SetInfoText("$BIS_DESC_LOAD_SETTINGS")
	EndIf
EndFunction
Function HandleOnOptionHighlightSettingsPage(Int OptionID)
	If OptionID == DialogTopicEnableToggleID
		SetInfoText("$BIS_DESC_ENABLE_DIALOG_TOPIC")
	ElseIf OptionID == AutomateFollowerBathingMenuID
		SetInfoText("$BIS_DESC_AUTOMATE_FOLLOWER_BATHING")
	ElseIf OptionID == WaterRestrictionEnableToggleID
		SetInfoText("$BIS_DESC_WATER_RESTRICT")
	ElseIf OptionID == UpdateIntervalSliderID
		SetInfoText("$BIS_DESC_UPDATE_INTERVAL")
	ElseIf OptionID == CheckStatusKeyMapID
		SetInfoText("$BIS_DESC_STATUS_HOTKEY")
	ElseIf OptionID == BatheKeyMapID
		SetInfoText("$BIS_DESC_BATHE_HOTKEY")
	ElseIf OptionID == ShowerKeyMapID
		SetInfoText("$BIS_DESC_SHOWER_HOTKEY")
	ElseIf OptionID == DirtinessPerHourPlayerHouseSliderID
		SetInfoText("$BIS_DESC_RATE_IN_PLAYERHOUSE")
	ElseIf OptionID == DirtinessPerHourSettlementSliderID
		SetInfoText("$BIS_DESC_RATE_IN_SETTLEMENT")
	ElseIf OptionID == DirtinessPerHourDungeonSliderID
		SetInfoText("$BIS_DESC_RATE_IN_DUNGEON")
	ElseIf OptionID == DirtinessPerHourWildernessSliderID
		SetInfoText("$BIS_DESC_RATE_IN_WILDERNESS")
	ElseIf OptionId == DirtinessThresholdTier1SliderID
		SetInfoText("$BIS_DESC_THRESHOLD_1")
	ElseIf OptionId == DirtinessThresholdTier2SliderID
		SetInfoText("$BIS_DESC_THRESHOLD_2")
	ElseIf OptionId == DirtinessThresholdTier3SliderID
		SetInfoText("$BIS_DESC_THRESHOLD_3")
	ElseIf OptionId == OverlayProgressOID_T
		SetInfoText("$BIS_DESC_OVERLAYPROGRESS")
	ElseIf OptionId == OverlayApplyAtOID_S
		SetInfoText("$BIS_DESC_OVERLAYAPPLY")
	ElseIf OptionId == StartingAlphaOID_S
		SetInfoText("$BIS_DESC_OVERLAYALPHA")
	ElseIf OptionId == DirtinessPerSexOID_S
		SetInfoText("$BIS_DESC_DIRTPERSEX")
	ElseIf OptionId == VictimMultOID_S
		SetInfoText("$BIS_DESC_VICTIMMULT")
	ElseIf OptionId == TexSetCountOID_T
		SetInfoText("$BIS_DESC_OVERLAYTEXSETCOUNT")
	ElseIf OptionId == RedetectDirtSetsOID_T
		SetInfoText("$BIS_DESC_OVERLAYREDETECT")
	ElseIf OptionId == RemoveAllOverlaysOID_T
		SetInfoText("$BIS_DESC_OVERLAYREMOVEALL")
	ElseIf OptionId == PapSetSaveOID_T
		SetInfoText("$BIS_DESC_PAPSETSAVE")
	ElseIf OptionId == PapSetLoadOID_T
		SetInfoText("$BIS_DESC_PAPSETLOAD")
	ElseIf OptionId == FadeTatsFadeTimeOID_S
		SetInfoText("$BIS_DESC_FADETATSADVANCE")
	ElseIf OptionId == FadeTatsSoapMultOID_S
		SetInfoText("$BIS_DESC_FADETATSMULT")
	ElseIf OptionId == FadeDirtSexToggleID
		SetInfoText("$BIS_DESC_FADEDIRTSEX")
	ElseIf OptionId == SexIntervalDirtOID_S
		SetInfoText("$BIS_DESC_SEXINTERVALDIRT")
	ElseIf OptionId == SexIntervalOID_S
		SetInfoText("$BIS_DESC_SEXINTERVAL")
	ElseIf OptionId == TimeToCleanOID_S
		SetInfoText("$BIS_DESC_TIMETOCLEAN")
	ElseIf OptionId == TimeToCleanIntervalOID_S
		SetInfoText("$BIS_DESC_TIMETOCLEANINTERVAL")
	ElseIf OptionId == ShynessToggleID
		SetInfoText("$BIS_DESC_SHYNESSTOGGLE")
	ElseIf OptionId == ShyDistanceOID_S
		SetInfoText("$BIS_DESC_SHYDISTANCE")
	ElseIf OptionId == UnForbidOID_T
		SetInfoText("$BIS_DESC_UNFORBID")
	EndIf
EndFunction
Function HandleOnOptionHighlightTrackedActorsPage(Int OptionID)
	Int Index = TrackedActorsToggleIDs.Find(OptionID)	
	If Index >= 0
		If TrackedActorsToggleValuesArray[Index] == False
			SetInfoText("$BIS_DESC_STOP_TRACKING_ACTOR")
		EndIf
	EndIf
EndFunction

; OnOptionKeyMapChange
Event OnOptionKeyMapChange(Int OptionID, Int KeyCode, String ConflictControl, String ConflictName)
	Bool Continue = True
	
	If ConflictControl != ""
		
		If ConflictName != ""
			ConflictName = "(" + ConflictName + ")"
		EndIf

		Continue = ShowMessage("$BIS_MSG_KEYMAPCONFLICT_{" + ConflictControl + "}{" + ConflictName + "}", True)		
	EndIf
	
	If Continue == True
		If OptionID == CheckStatusKeyMapID
			CheckStatusKeyCode.Value = KeyCode
		ElseIf OptionID == BatheKeyMapID
			BatheKeyCode.Value = KeyCode
			
		ElseIf OptionID == ShowerKeyMapID
			ShowerKeyCode.Value = KeyCode
		EndIf
		BatheQuest.RegisterHotKeys()
		SetKeymapOptionValue(OptionID, KeyCode)
	EndIf
EndEvent

; OnOptionSelect
Event OnOptionSelect(Int OptionID)
	If CurrentPage == "$BIS_PAGE_SYSTEM_OVERVIEW" || CurrentPage == ""
		HandleOnOptionSelectSystemOverviewPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_SETTINGS"
		HandleOnOptionSelectSettingsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS"
		HandleOnOptionSelectAnimationsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		HandleOnOptionSelectAnimationsPageFollowers(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_TRACKED_ACTORS"
		HandleOnOptionSelectTrackedActorsPage(OptionID)
	EndIf	
EndEvent
Function HandleOnOptionSelectAnimationsPage(Int OptionID)
	If OptionID == AutoPlayerTFCID
		AutoPlayerTFC = !AutoPlayerTFC
		SetToggleOptionValue(OptionID, AutoPlayerTFC)
	ElseIf OptionID == GetDressedAfterBathingEnabledToggleID
		GetDressedAfterBathingEnabled.SetValue((!GetDressedAfterBathingEnabled.GetValue() As Bool) As Int)
		SetToggleOptionValue(OptionID, GetDressedAfterBathingEnabled.GetValue() As Bool)
	Else
		Int UndressArmorSlotIndex = UndressArmorSlotToggleIDs.Find(OptionID)
		If UndressArmorSlotIndex >= 0
			UndressArmorSlotArray[UndressArmorSlotIndex] = !UndressArmorSlotArray[UndressArmorSlotIndex]
			IgnoreArmorSlot(BathingIgnoredArmorSlotsMask, UndressArmorSlotIndex + 30, !UndressArmorSlotArray[UndressArmorSlotIndex])
			SetToggleOptionValue(OptionID, UndressArmorSlotArray[UndressArmorSlotIndex])
		EndIf
	EndIf
EndFunction
Function HandleOnOptionSelectAnimationsPageFollowers(Int OptionID)
	If OptionID == GetDressedAfterBathingEnabledToggleIDFollowers
		GetDressedAfterBathingEnabledFollowers.SetValue((!GetDressedAfterBathingEnabledFollowers.GetValue() As Bool) As Int)
		SetToggleOptionValue(OptionID, GetDressedAfterBathingEnabledFollowers.GetValue() As Bool)
	Else
		Int UndressArmorSlotIndex = UndressArmorSlotToggleIDsFollowers.Find(OptionID)
		If UndressArmorSlotIndex >= 0
			UndressArmorSlotArrayFollowers[UndressArmorSlotIndex] = !UndressArmorSlotArrayFollowers[UndressArmorSlotIndex]
			IgnoreArmorSlot(BathingIgnoredArmorSlotsMaskFollowers, UndressArmorSlotIndex + 30, !UndressArmorSlotArrayFollowers[UndressArmorSlotIndex])
			SetToggleOptionValue(OptionID, UndressArmorSlotArrayFollowers[UndressArmorSlotIndex])
		EndIf
	EndIf
EndFunction
Function HandleOnOptionSelectSystemOverviewPage(Int OptionID)
	If OptionID == ModStateOID_T
		If BathingInSkyrimEnabled.GetValue() As Bool && ShowMessage("$BIS_MSG_ASK_DISABLE", True) == True
			BathingInSkyrimEnabled.SetValue(-1)
			SetTextOptionValue(OptionID, "$BIS_TXT_WORKING", false)
			DisableBathingInSkyrim()
			SetTextOptionValue(OptionID, "$BIS_TXT_DISABLED", false)
		Else
			BathingInSkyrimEnabled.SetValue(-1)
			SetTextOptionValue(OptionID, "$BIS_TXT_WORKING", false)
			ShowMessage("$BIS_MSG_ASK_ENABLE", false)
			EnableBathingInSkyrim()
		EndIf
	ElseIf OptionID == PapSetSaveOID_T
		SetTextOptionValue(PapSetSaveOID_T, "$BIS_TXT_SAVING", false)
		if SavePapyrusSettings()
			SetTextOptionValue(PapSetSaveOID_T, "$BIS_TXT_DONE", false)
		else
			SetTextOptionValue(PapSetLoadOID_T, "$BIS_TXT_ERRORED", false)
		endIf
	ElseIf OptionID == PapSetLoadOID_T
		SetTextOptionValue(PapSetLoadOID_T, "$BIS_TXT_LOADING", false)
		if LoadPapyrusSettings()
			SetTextOptionValue(PapSetLoadOID_T, "$BIS_TXT_DONE", false)
		else
			SetTextOptionValue(PapSetLoadOID_T, "$BIS_TXT_ERRORED", false)
		endIf
	EndIf
EndFunction
Function HandleOnOptionSelectSettingsPage(Int OptionID)
	If OptionID == DialogTopicEnableToggleID
		DialogTopicEnabled.SetValue((!DialogTopicEnabled.GetValue() As Bool) As Int)
		SetToggleOptionValue(OptionID, DialogTopicEnabled.GetValue() As Bool)
	ElseIf OptionID == WaterRestrictionEnableToggleID
		WaterRestrictionEnabled.SetValue((!WaterRestrictionEnabled.GetValue() As Bool) As Int)
		SetToggleOptionValue(OptionID, WaterRestrictionEnabled.GetValue() As Bool)
	ElseIf OptionID == RedetectDirtSetsOID_T
		TexUtil.DirtSetCount = TexUtil.InitTexSets()
		SetTextOptionValue(OverlayProgressOID_T, "$BIS_TXT_DONE", false)
		ForcePageReset()
	ElseIf OptionID == RemoveAllOverlaysOID_T
		RemoveAllOverlays()
	ElseIf OptionID == FadeDirtSexToggleID
		FadeDirtSex = !FadeDirtSex
		SetToggleOptionValue(OptionID, FadeDirtSex)
		ForcePageReset() 
	ElseIf OptionID == ShynessToggleID
		Shyness = !Shyness
		SetToggleOptionValue(OptionID, Shyness)
	ElseIf OptionID == UnForbidOID_T
		SetTextOptionValue(UnForbidOID_T, "$BIS_TXT_WORKING", false)
		UnForbidAllActor()
		SetTextOptionValue(UnForbidOID_T, "$BIS_TXT_DONE", false)
	EndIf	
EndFunction
Function HandleOnOptionSelectTrackedActorsPage(Int OptionID)
	Int Index = TrackedActorsToggleIDs.Find(OptionID)
	If Index >= 0
		If ShowMessage("$BIS_MSG_ASK_STOP_TRACK", True) == True
			Actor DirtyActor = DirtyActors.GetAt(Index) As Actor
			RemoveSpells(DirtyActor, GetDirtyOverTimeSpellList)
			RemoveSpells(DirtyActor, DirtinessSpellList)
			RemoveSpells(DirtyActor, SoapBonusSpellList)
			DirtyActors.RemoveAddedForm(DirtyActor)
			ForcePageReset()
		EndIf
	EndIf
EndFunction

; OnOptionMenuAccept
Event OnOptionMenuAccept(Int OptionID, Int MenuItemIndex)
	If CurrentPage == "$BIS_PAGE_SETTINGS"
		HandleOnOptionMenuAcceptSettingsPage(OptionID, MenuItemIndex)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS"
		HandleOnOptionMenuAcceptAnimationsPage(OptionID, MenuItemIndex)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		HandleOnOptionMenuAcceptAnimationsPageFollowers(OptionID, MenuItemIndex)
	EndIf
EndEvent
Function HandleOnOptionMenuAcceptSettingsPage(Int OptionID, Int MenuItemIndex)
	If OptionID == AutomateFollowerBathingMenuID
		If MenuItemIndex >= 0 && MenuItemIndex < AutomateFollowerBathingArray.Length
			SetMenuOptionValue(OptionID, AutomateFollowerBathingArray[MenuItemIndex])
			AutomateFollowerBathing.SetValue(MenuItemIndex)
		EndIf
	endIf
EndFunction
Function HandleOnOptionMenuAcceptAnimationsPage(Int OptionID, Int MenuItemIndex)
	If OptionID == BathingAnimationStyleMenuID
		If MenuItemIndex >= 0 && MenuItemIndex < BathingAnimationStyleArray.Length
			SetMenuOptionValue(OptionID, BathingAnimationStyleArray[MenuItemIndex])
			BathingAnimationStyle.SetValue(MenuItemIndex)
			ForcePageReset()
		EndIf
	ElseIf OptionID == ShoweringAnimationStyleMenuID
		If MenuItemIndex >= 0 && MenuItemIndex < ShoweringAnimationStyleArray.Length
			SetMenuOptionValue(OptionID, ShoweringAnimationStyleArray[MenuItemIndex])
			ShoweringAnimationStyle.SetValue(MenuItemIndex)
			ForcePageReset()
		EndIf
	ElseIf OptionID == GetSoapyStyleMenuID
		If MenuItemIndex >= 0 && MenuItemIndex < GetSoapyStyleArray.Length
			SetMenuOptionValue(OptionID, GetSoapyStyleArray[MenuItemIndex])
			GetSoapyStyle.SetValue(MenuItemIndex)
		EndIf
	ElseIf OptionID == AnimCustomTierCondMenuID
		If MenuItemIndex >= 0 && MenuItemIndex < AnimCustomTierCondArray.Length
			SetMenuOptionValue(OptionID, AnimCustomTierCondArray[MenuItemIndex])
			AnimCustomTierCond = MenuItemIndex
		EndIf
	EndIf
EndFunction
Function HandleOnOptionMenuAcceptAnimationsPageFollowers(Int OptionID, Int MenuItemIndex)
	If OptionID == BathingAnimationStyleMenuIDFollowers
		If MenuItemIndex >= 0 && MenuItemIndex < BathingAnimationStyleArray.Length
			SetMenuOptionValue(OptionID, BathingAnimationStyleArray[MenuItemIndex])
			BathingAnimationStyleFollowers.SetValue(MenuItemIndex)
			ForcePageReset()
		EndIf
	ElseIf OptionID == ShoweringAnimationStyleMenuIDFollowers
		If MenuItemIndex >= 0 && MenuItemIndex < ShoweringAnimationStyleArray.Length
			SetMenuOptionValue(OptionID, ShoweringAnimationStyleArray[MenuItemIndex])
			ShoweringAnimationStyleFollowers.SetValue(MenuItemIndex)
			ForcePageReset()
		EndIf
	ElseIf OptionID == GetSoapyStyleMenuIDFollowers
		If MenuItemIndex >= 0 && MenuItemIndex < GetSoapyStyleArray.Length
			SetMenuOptionValue(OptionID, GetSoapyStyleArray[MenuItemIndex])
			GetSoapyStyleFollowers.SetValue(MenuItemIndex)
		EndIf
	ElseIf OptionID == AnimCustomTierCondMenuIDFollowers
		If MenuItemIndex >= 0 && MenuItemIndex < AnimCustomTierCondArray.Length
			SetMenuOptionValue(OptionID, AnimCustomTierCondArray[MenuItemIndex])
			AnimCustomTierCondFollowers = MenuItemIndex
		EndIf
	EndIf
EndFunction

; OnOptionMenuOpen
Event OnOptionMenuOpen(Int OptionID)
	If CurrentPage == "$BIS_PAGE_SETTINGS"
		HandleOnOptionMenuOpenSettingsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS"
		HandleOnOptionMenuOpenAnimationsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		HandleOnOptionMenuOpenAnimationsPageFollowers(OptionID)
	EndIf
EndEvent
Function HandleOnOptionMenuOpenSettingsPage(Int OptionID)
	If OptionID == AutomateFollowerBathingMenuID
		SetMenuDialogOptions(AutomateFollowerBathingArray)
		SetMenuDialogStartIndex(AutomateFollowerBathing.GetValue() As Int)
		SetMenuDialogDefaultIndex(1)
	EndIf
EndFunction
Function HandleOnOptionMenuOpenAnimationsPage(Int OptionID)
	If OptionID == BathingAnimationStyleMenuID
		SetMenuDialogOptions(BathingAnimationStyleArray)
		SetMenuDialogStartIndex(BathingAnimationStyle.GetValue() As Int)
		SetMenuDialogDefaultIndex(1)
	ElseIf OptionID == ShoweringAnimationStyleMenuID
		SetMenuDialogOptions(ShoweringAnimationStyleArray)
		SetMenuDialogStartIndex(ShoweringAnimationStyle.GetValue() As Int)
		SetMenuDialogDefaultIndex(0)
	ElseIf OptionID == GetSoapyStyleMenuID
		SetMenuDialogOptions(GetSoapyStyleArray)
		SetMenuDialogStartIndex(GetSoapyStyle.GetValue() As Int)
		SetMenuDialogDefaultIndex(1)
	ElseIf OptionID == AnimCustomTierCondMenuID
		SetMenuDialogOptions(AnimCustomTierCondArray)
		SetMenuDialogStartIndex(AnimCustomTierCond)
		SetMenuDialogDefaultIndex(1)
	EndIf
EndFunction
Function HandleOnOptionMenuOpenAnimationsPageFollowers(Int OptionID)
	If OptionID == BathingAnimationStyleMenuIDFollowers
		SetMenuDialogOptions(BathingAnimationStyleArray)
		SetMenuDialogStartIndex(BathingAnimationStyleFollowers.GetValue() As Int)
		SetMenuDialogDefaultIndex(1)
	ElseIf OptionID == ShoweringAnimationStyleMenuIDFollowers
		SetMenuDialogOptions(ShoweringAnimationStyleArray)
		SetMenuDialogStartIndex(ShoweringAnimationStyleFollowers.GetValue() As Int)
		SetMenuDialogDefaultIndex(0)
	ElseIf OptionID == GetSoapyStyleMenuIDFollowers
		SetMenuDialogOptions(GetSoapyStyleArray)
		SetMenuDialogStartIndex(GetSoapyStyleFollowers.GetValue() As Int)
		SetMenuDialogDefaultIndex(1)
	ElseIf OptionID == AnimCustomTierCondMenuIDFollowers
		SetMenuDialogOptions(AnimCustomTierCondArray)
		SetMenuDialogStartIndex(AnimCustomTierCond)
		SetMenuDialogDefaultIndex(1)
	EndIf
EndFunction

; OnOptionSliderAccept
Event OnOptionSliderAccept(Int OptionID, Float OptionValue)
	If CurrentPage == "$BIS_PAGE_SETTINGS"
		HandleOnOptionSliderAcceptSettingsPage(OptionID, OptionValue)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS"
		HandleOnOptionSliderAcceptAnimationsPage(OptionID, OptionValue)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		HandleOnOptionSliderAcceptAnimationsPageFollowers(OptionID, OptionValue)
	EndIf	
EndEvent
Function HandleOnOptionSliderAcceptAnimationsPage(Int OptionID, Float OptionValue)
	Float SliderValue = OptionValue
	String DisplayFormat = "{0}"

	If OptionID == BathingAnimationLoopsTier0SliderID
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountList.GetAt(0) As GlobalVariable).SetValue(SliderValue)
	ElseIf OptionID == BathingAnimationLoopsTier1SliderID
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountList.GetAt(1) As GlobalVariable).SetValue(SliderValue)
	ElseIf OptionID == BathingAnimationLoopsTier2SliderID
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountList.GetAt(2) As GlobalVariable).SetValue(SliderValue)
	ElseIf OptionID == BathingAnimationLoopsTier3SliderID
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountList.GetAt(3) As GlobalVariable).SetValue(SliderValue)

	ElseIf OptionID == AnimCustomMSet1SliderID
		DisplayFormat = "{0}"
		AnimCustomMSet1Freq = SliderValue
		AnimCustomMSet[0] = AnimCustomMSet1Freq
	ElseIf OptionID == AnimCustomFSet1SliderID
		DisplayFormat = "{0}"
		AnimCustomFSet1Freq = SliderValue
		AnimCustomFSet[0] = AnimCustomFSet1Freq
	ElseIf OptionID == AnimCustomFSet2SliderID
		DisplayFormat = "{0}"
		AnimCustomFSet2Freq = SliderValue
		AnimCustomFSet[1] = AnimCustomFSet2Freq
	ElseIf OptionID == AnimCustomFSet3SliderID
		DisplayFormat = "{0}"
		AnimCustomFSet3Freq = SliderValue
		AnimCustomFSet[2] = AnimCustomFSet3Freq
	EndIf
		
	SetSliderOptionValue(OptionID, SliderValue, DisplayFormat)	
EndFunction
Function HandleOnOptionSliderAcceptAnimationsPageFollowers(Int OptionID, Float OptionValue)
	Float SliderValue = OptionValue
	String DisplayFormat = "{0}"

	If OptionID == BathingAnimationLoopsTier0SliderIDFollowers
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountListFollowers.GetAt(0) As GlobalVariable).SetValue(SliderValue)
	ElseIf OptionID == BathingAnimationLoopsTier1SliderIDFollowers
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountListFollowers.GetAt(1) As GlobalVariable).SetValue(SliderValue)
	ElseIf OptionID == BathingAnimationLoopsTier2SliderIDFollowers
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountListFollowers.GetAt(2) As GlobalVariable).SetValue(SliderValue)
	ElseIf OptionID == BathingAnimationLoopsTier3SliderIDFollowers
		DisplayFormat = "{0}"
		(BathingAnimationLoopCountListFollowers.GetAt(3) As GlobalVariable).SetValue(SliderValue)

	ElseIf OptionID == AnimCustomMSet1SliderIDFollowers
		DisplayFormat = "{0}"
		AnimCustomMSet1FreqFollowers = SliderValue
		AnimCustomMSetFollowers[0] = AnimCustomMSet1FreqFollowers
	ElseIf OptionID == AnimCustomFSet1SliderIDFollowers
		DisplayFormat = "{0}"
		AnimCustomFSet1FreqFollowers = SliderValue
		AnimCustomFSetFollowers[0] = AnimCustomFSet1FreqFollowers
	ElseIf OptionID == AnimCustomFSet2SliderIDFollowers
		DisplayFormat = "{0}"
		AnimCustomFSet2FreqFollowers = SliderValue
		AnimCustomFSetFollowers[1] = AnimCustomFSet2FreqFollowers
	ElseIf OptionID == AnimCustomFSet3SliderIDFollowers
		DisplayFormat = "{0}"
		AnimCustomFSet3FreqFollowers = SliderValue
		AnimCustomFSetFollowers[2] = AnimCustomFSet3FreqFollowers
	EndIf
		
	SetSliderOptionValue(OptionID, SliderValue, DisplayFormat)	
EndFunction
Function HandleOnOptionSliderAcceptSettingsPage(Int OptionID, Float OptionValue)
	Float SliderValue = OptionValue
	String DisplayFormat = DisplayFormatPercentage

	If OptionID == UpdateIntervalSliderID
		DisplayFormat = DisplayFormatDecimal
		DirtinessUpdateInterval.SetValue(SliderValue)
	ElseIf OptionID == DirtinessPerHourPlayerHouseSliderID
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue / 100.0
		DirtinessPerHourPlayerHouse.SetValue(SliderValue)
	ElseIf OptionID == DirtinessPerHourSettlementSliderID
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue / 100.0
		DirtinessPerHourSettlement.SetValue(SliderValue)
	ElseIf OptionID == DirtinessPerHourDungeonSliderID
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue / 100.0
		DirtinessPerHourDungeon.SetValue(SliderValue)
		DisplayFormat = DisplayFormatPercentage
	ElseIf OptionID == DirtinessPerHourWildernessSliderID
		SliderValue = OptionValue / 100.0	
		DirtinessPerHourWilderness.SetValue(SliderValue)

	ElseIf OptionID == DirtinessThresholdTier1SliderID
	
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue / 100.0

		; clamp threshold
		If SliderValue > (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
			SliderValue = (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
		EndIf
		
		(DirtinessThresholdList.GetAt(0) As GlobalVariable).SetValue(SliderValue)
		
	ElseIf OptionID == DirtinessThresholdTier2SliderID
	
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue / 100.0

		; clamp threshold
		If SliderValue > (DirtinessThresholdList.GetAt(2) As GlobalVariable).GetValue()
			SliderValue = (DirtinessThresholdList.GetAt(2) As GlobalVariable).GetValue()
		ElseIf SliderValue < (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue()
			SliderValue = (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue()
		EndIf

		(DirtinessThresholdList.GetAt(1) As GlobalVariable).SetValue(SliderValue)
		
	ElseIf OptionID == DirtinessThresholdTier3SliderID
	
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue / 100.0

		; clamp threshold
		If SliderValue < (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
			SliderValue = (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue()
		EndIf
	
		(DirtinessThresholdList.GetAt(2) As GlobalVariable).SetValue(SliderValue)
	
	ElseIf OptionID == OverlayApplyAtOID_S
		DisplayFormat = "$BIS_L_OVERLAYAPPLYDISPLAY_{}"
		SliderValue = OptionValue
		OverlayApplyAt = SliderValue / 100.0
		UpdateAllActors()
	ElseIf OptionID == StartingAlphaOID_S
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue
		StartingAlpha = SliderValue / 100.0
		UpdateAllActors()
	ElseIf OptionID == DirtinessPerSexOID_S
		DisplayFormat = DisplayFormatPercentage
		SliderValue = OptionValue
		DirtinessPerSexActor = SliderValue / 100.0
		ForcePageReset()
	ElseIf OptionID == VictimMultOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		VictimMult = SliderValue
		ForcePageReset()
	ElseIf OptionID == SexIntervalDirtOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		SexIntervalDirt = SliderValue
		ForcePageReset()
	ElseIf OptionID == SexIntervalOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		SexInterval = SliderValue
	ElseIf OptionID == TimeToCleanOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		TimeToClean = SliderValue
	ElseIf OptionID == TimeToCleanIntervalOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		TimeToCleanInterval = SliderValue
	ElseIf OptionID == ShyDistanceOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		ShyDistance = SliderValue as Int
	ElseIf OptionID == FadeTatsFadeTimeOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		FadeTatsFadeTime = SliderValue
	ElseIf OptionID == FadeTatsSoapMultOID_S
		DisplayFormat = DisplayFormatDecimal
		SliderValue = OptionValue
		FadeTatsSoapMult = SliderValue
	EndIf
	
	SetSliderOptionValue(OptionID, OptionValue, DisplayFormat)
EndFunction

; OnOptionSliderOpen
Event OnOptionSliderOpen(Int OptionID)
	If CurrentPage == "$BIS_PAGE_SETTINGS"
		HandleOnOptionSliderOpenSettingsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS"
		HandleOnOptionSliderOpenAnimationsPage(OptionID)
	ElseIf CurrentPage == "$BIS_PAGE_ANIMATIONS_FOLLOWERS"
		HandleOnOptionSliderOpenAnimationsPageFollowers(OptionID)
	EndIf		
EndEvent
Function HandleOnOptionSliderOpenAnimationsPage(Int OptionID)
	Float SliderValue = 0.0
	String DisplayFormat = "{0}"

	If OptionID == BathingAnimationLoopsTier0SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountList.GetAt(0) As GlobalVariable).GetValue() As Int
	ElseIf OptionID == BathingAnimationLoopsTier1SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountList.GetAt(1) As GlobalVariable).GetValue() As Int
	ElseIf OptionID == BathingAnimationLoopsTier2SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountList.GetAt(2) As GlobalVariable).GetValue() As Int
	ElseIf OptionID == BathingAnimationLoopsTier3SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountList.GetAt(3) As GlobalVariable).GetValue() As Int

	ElseIf OptionID == AnimCustomMSet1SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomMSet1Freq
	ElseIf OptionID == AnimCustomFSet1SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomFSet1Freq
	ElseIf OptionID == AnimCustomFSet2SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomFSet2Freq
	ElseIf OptionID == AnimCustomFSet3SliderID
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomFSet3Freq
	EndIf

	; set slider value
	SetSliderDialogStartValue(SliderValue)
	SetSliderOptionValue(OptionID, SliderValue, DisplayFormat)
EndFunction
Function HandleOnOptionSliderOpenAnimationsPageFollowers(Int OptionID)
	Float SliderValue = 0.0
	String DisplayFormat = "{0}"

	If OptionID == BathingAnimationLoopsTier0SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountListFollowers.GetAt(0) As GlobalVariable).GetValue() As Int
	ElseIf OptionID == BathingAnimationLoopsTier1SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountListFollowers.GetAt(1) As GlobalVariable).GetValue() As Int
	ElseIf OptionID == BathingAnimationLoopsTier2SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountListFollowers.GetAt(2) As GlobalVariable).GetValue() As Int
	ElseIf OptionID == BathingAnimationLoopsTier3SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(1.0, 10.0)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (BathingAnimationLoopCountListFollowers.GetAt(3) As GlobalVariable).GetValue() As Int

	ElseIf OptionID == AnimCustomMSet1SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomMSet1FreqFollowers
	ElseIf OptionID == AnimCustomFSet1SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomFSet1FreqFollowers
	ElseIf OptionID == AnimCustomFSet2SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomFSet2FreqFollowers
	ElseIf OptionID == AnimCustomFSet3SliderIDFollowers
		DisplayFormat = "{0}"
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(0.0)
		SliderValue = AnimCustomFSet3FreqFollowers
	EndIf

	; set slider value
	SetSliderDialogStartValue(SliderValue)
	SetSliderOptionValue(OptionID, SliderValue, DisplayFormat)
EndFunction
Function HandleOnOptionSliderOpenSettingsPage(Int OptionID)
	Float SliderValue = 0.0
	String DisplayFormat = DisplayFormatPercentage

	; get slider value
	If OptionID == UpdateIntervalSliderID
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogRange(0.25, 5.0)
		SetSliderDialogInterval(0.25)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (DirtinessUpdateInterval.GetValue())
	ElseIf OptionID == DirtinessPerHourPlayerHouseSliderID
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (DirtinessPerHourPlayerHouse.GetValue() * 100.0)
	ElseIf OptionID == DirtinessPerHourSettlementSliderID
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(1.0)
		SliderValue = (DirtinessPerHourSettlement.GetValue() * 100.0)
	ElseIf OptionID == DirtinessPerHourDungeonSliderID
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(2.5)
		SliderValue = (DirtinessPerHourDungeon.GetValue() * 100.0)
	ElseIf OptionID == DirtinessPerHourWildernessSliderID
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(1.5)
		SliderValue = (DirtinessPerHourWilderness.GetValue() * 100.0)
	ElseIf OptionID == DirtinessThresholdTier1SliderID
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(20.0)
		SliderValue = ((DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue() * 100.0)
	ElseIf OptionID == DirtinessThresholdTier2SliderID
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(60.0)
		SliderValue = ((DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue() * 100.0)
	ElseIf OptionID == DirtinessThresholdTier3SliderID
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SetSliderDialogDefaultValue(98.0)
		SliderValue = ((DirtinessThresholdList.GetAt(2) As GlobalVariable).GetValue() * 100.0)
	
	ElseIf OptionID == OverlayApplyAtOID_S
		DisplayFormat = "$BIS_L_OVERLAYAPPLYDISPLAY_{}"
		SetSliderDialogDefaultValue(40.0)
		SetSliderDialogRange(0.0, ((DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue() * 100.0))
		SetSliderDialogInterval(1.0)
		SliderValue = OverlayApplyAt * 100.0	
	ElseIf OptionID == StartingAlphaOID_S
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogDefaultValue(15.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SliderValue = StartingAlpha * 100.0
	ElseIf OptionID == DirtinessPerSexOID_S
		DisplayFormat = DisplayFormatPercentage
		SetSliderDialogDefaultValue(4.0)
		SetSliderDialogRange(0.0, 100.0)
		SetSliderDialogInterval(0.5)
		SliderValue = DirtinessPerSexActor * 100.0
	ElseIf OptionID == VictimMultOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(2.5)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.1)
		SliderValue = VictimMult
	ElseIf OptionID == SexIntervalDirtOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(35.0)
		SetSliderDialogRange(0.0, 200.0)
		SetSliderDialogInterval(0.5)
		SliderValue = SexIntervalDirt
	ElseIf OptionID == SexIntervalOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(1.0)
		SetSliderDialogRange(0.5, 10.0)
		SetSliderDialogInterval(0.5)
		SliderValue = SexInterval
	ElseIf OptionID == TimeToCleanOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(10.0)
		SetSliderDialogRange(0.0, 30.0)
		SetSliderDialogInterval(0.5)
		SliderValue = TimeToClean
	ElseIf OptionID == TimeToCleanIntervalOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(0.25)
		SetSliderDialogRange(0.01, 5.0)
		SetSliderDialogInterval(0.01)
		SliderValue = TimeToCleanInterval
	ElseIf OptionID == ShyDistanceOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(2000.0)
		SetSliderDialogRange(0.0, 6000.0)
		SetSliderDialogInterval(200.0)
		SliderValue = ShyDistance
	ElseIf OptionID == FadeTatsFadeTimeOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(8.0)
		SetSliderDialogRange(0.0, 1000.0)
		SetSliderDialogInterval(1.0)
		SliderValue = FadeTatsFadeTime
	ElseIf OptionID == FadeTatsSoapMultOID_S
		DisplayFormat = DisplayFormatDecimal
		SetSliderDialogDefaultValue(2.0)
		SetSliderDialogRange(0.0, 10.0)
		SetSliderDialogInterval(0.1)
		SliderValue = FadeTatsSoapMult
	EndIf
	
	; set slider value
	SetSliderDialogStartValue(SliderValue)
	SetSliderOptionValue(OptionID, SliderValue, DisplayFormat)
EndFunction

; helper functions
Function EnableBathingInSkyrim()
	Utility.Wait(1.0)
	VersionUpdate()
	TexUtil.UtilInit()

	PlayerRef.AddSpell(GetDirtyOverTimeSpellList.GetAt(1) As Spell, False)
	PlayerRef.AddSpell(GetDirtyOverTimeReactivatorCloakSpell, False)

	BatheQuest.Start()
	BatheQuest.RegisterHotKeys()
	BatheQuest.RegForEvents()

	BathingInSkyrimEnabled.SetValue(1)

	Debug.Notification("BISR: Enabled Bathing in Skyrim.")
	Debug.Trace("Mzin: Player enabled Bathing in Skyrim. Mod version: " + GetModVersion() + "; Script version: " + GetVersion())
EndFunction
Function DisableBathingInSkyrim()
	PlayerRef.RemoveSpell(GetDirtyOverTimeReactivatorCloakSpell)
	
	RemoveAllOverlays()
	
	RemoveSpells(PlayerRef, GetDirtyOverTimeSpellList)
	RemoveSpells(PlayerRef, DirtinessSpellList)
	RemoveSpells(PlayerRef, SoapBonusSpellList)
	StorageUtil.UnSetFloatValue(PlayerRef, "BiS_Dirtiness")
	StorageUtil.UnSetFloatValue(PlayerRef, "BiS_LastUpdate")
	StorageUtil.UnSetStringValue(PlayerRef, "mzin_DirtTexturePrefix")

	Int DirtyActorIndex = DirtyActors.Getsize()
	If DirtyActorIndex > 0
		While DirtyActorIndex
			DirtyActorIndex -= 1
			Actor DirtyActor = DirtyActors.GetAt(DirtyActorIndex) As Actor
			RemoveSpells(DirtyActor, GetDirtyOverTimeSpellList)
			RemoveSpells(DirtyActor, DirtinessSpellList)
			RemoveSpells(DirtyActor, SoapBonusSpellList)
			
			StorageUtil.UnSetFloatValue(DirtyActor, "BiS_Dirtiness")
			StorageUtil.UnSetFloatValue(DirtyActor, "BiS_LastUpdate")
			StorageUtil.UnSetStringValue(DirtyActor, "mzin_DirtTexturePrefix")
		EndWhile
		DirtyActors.Revert()
	EndIf

	BatheQuest.Stop()
			
	BathingInSkyrimEnabled.SetValue(0)

	Debug.Notification("BISR: Disabled Bathing in Skyrim.")
	Debug.Trace("Mzin: Player disabled Bathing in Skyrim.")

	ForcePageReset()
EndFunction
Function RemoveSpells(Actor DirtyActor, FormList SpellFormList)
	Int SpellListIndex = SpellFormList.GetSize()
	While SpellListIndex
		SpellListIndex -= 1
		DirtyActor.RemoveSpell(SpellFormList.GetAt(SpellListIndex) As Spell)	
	EndWhile
EndFunction

Bool[] Function GetUnignoredArmorSlots(GlobalVariable IgnoredArmorSlotsMask)
	Bool[] UnignoredArmorSlots = new Bool[32]
	
	Int CurrentBathingIgnoredArmorSlotsMask = IgnoredArmorSlotsMask.GetValue() As Int
	
	Int Index = UnignoredArmorSlots.Length
	While Index
		Index -= 1
		Int ArmorSlotMask = Armor.GetMaskForSlot(Index + 30)
		If Math.LogicalAnd(ArmorSlotMask, CurrentBathingIgnoredArmorSlotsMask) == ArmorSlotMask		
			UnignoredArmorSlots[Index] = False	
		Else
			UnignoredArmorSlots[Index] = True
		EndIf
	EndWhile
	
	Return UnignoredArmorSlots
EndFunction
Function IgnoreArmorSlot(GlobalVariable IgnoredArmorSlotsMask, Int ArmorSlot, Bool Ignore)
	Int ArmorSlotMask = Armor.GetMaskForSlot(ArmorSlot)
	Int CurrentBathingIgnoredArmorSlotsMask = IgnoredArmorSlotsMask.GetValue() As Int
	
	Int NewBathingIgnoredArmorSlotsMask
	If Ignore == True
		NewBathingIgnoredArmorSlotsMask = Math.LogicalOr(ArmorSlotMask, CurrentBathingIgnoredArmorSlotsMask)
	Else
		NewBathingIgnoredArmorSlotsMask = Math.LogicalXor(ArmorSlotMask, CurrentBathingIgnoredArmorSlotsMask)
	EndIf
	
	IgnoredArmorSlotsMask.SetValue(NewBathingIgnoredArmorSlotsMask)
EndFunction

Function UpdateProgressRedetectDirtSets(String CurrentTex)
	If IsConfigOpen
		SetTextOptionValue(OverlayProgressOID_T, "$BIS_NOTIF_CHECKINGSET_{" + CurrentTex + "}", false)
	EndIF
EndFunction

Function RemoveAllOverlays()
	; Do player
	DoRemoveAllOverlays(PlayerRef)
	
	; Do other Npcs
	Int i = mzinDirtyActorsList.GetSize()
	Actor CurrentActor
	While i > 0
		i -= 1
		CurrentActor = mzinDirtyActorsList.GetAt(i) as Actor
		DoRemoveAllOverlays(CurrentActor)
	EndWhile
	If IsConfigOpen
		SetTextOptionValue(OverlayProgressOID_T, "$BIS_TXT_DONE", false)
	EndIf
EndFunction

Function DoRemoveAllOverlays(Actor akTarget)
	If IsConfigOpen
		SetTextOptionValue(OverlayProgressOID_T, "$BIS_NOTIF_PROCING_{" + akTarget.GetBaseObject().GetName() + "}", false)
	EndIf
	Util.ClearDirtGameLoad(akTarget)
EndFunction

Bool Function SavePapyrusSettings()
	if JsonUtil.JsonExists("BathingInSkyrim/Settings.json")
		if JsonUtil.IsPendingSave("BathingInSkyrim/Settings.json")
			if !ShowMessage("$BIS_MSG_SAVE_WARN_1")
				return false
			endIf
		else
			if !ShowMessage("$BIS_MSG_ASK_SAVE")
				return false
			endIf
		endIf
	endIf

	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "DialogTopicEnabled", DialogTopicEnabled.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "AutomateFollowerBathing", AutomateFollowerBathing.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "WaterRestrictionEnabled", WaterRestrictionEnabled.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "GetSoapyStyle", GetSoapyStyle.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "GetSoapyStyleFollowers", GetSoapyStyleFollowers.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "CheckStatusKeyCode", CheckStatusKeyCode.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BatheKeyCode", BatheKeyCode.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "ShowerKeyCode", ShowerKeyCode.GetValueInt())
	
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationStyle", BathingAnimationStyle.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationStyleFollowers", BathingAnimationStyleFollowers.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "ShoweringAnimationStyle", ShoweringAnimationStyle.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "ShoweringAnimationStyleFollowers", ShoweringAnimationStyleFollowers.GetValueInt())
	
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "GetDressedAfterBathingEnabled", GetDressedAfterBathingEnabled.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "GetDressedAfterBathingEnabledFollowers", GetDressedAfterBathingEnabledFollowers.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingIgnoredArmorSlotsMask", BathingIgnoredArmorSlotsMask.GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingIgnoredArmorSlotsMaskFollowers", BathingIgnoredArmorSlotsMaskFollowers.GetValueInt())
	
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessUpdateInterval", DirtinessUpdateInterval.GetValue())
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPercentage", DirtinessPercentage.GetValue())
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourPlayerHouse", DirtinessPerHourPlayerHouse.GetValue())
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourSettlement", DirtinessPerHourSettlement.GetValue())
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourDungeon", DirtinessPerHourDungeon.GetValue())
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourWilderness", DirtinessPerHourWilderness.GetValue())
	
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessThreshold0", (DirtinessThresholdList.GetAt(0) As GlobalVariable).GetValue())
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessThreshold1", (DirtinessThresholdList.GetAt(1) As GlobalVariable).GetValue())
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessThreshold2", (DirtinessThresholdList.GetAt(2) As GlobalVariable).GetValue())
	
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount0", (BathingAnimationLoopCountList.GetAt(0) As GlobalVariable).GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount1", (BathingAnimationLoopCountList.GetAt(1) As GlobalVariable).GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount2", (BathingAnimationLoopCountList.GetAt(2) As GlobalVariable).GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount3", (BathingAnimationLoopCountList.GetAt(3) As GlobalVariable).GetValueInt())
	
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers0", (BathingAnimationLoopCountListFollowers.GetAt(0) As GlobalVariable).GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers1", (BathingAnimationLoopCountListFollowers.GetAt(1) As GlobalVariable).GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers2", (BathingAnimationLoopCountListFollowers.GetAt(2) As GlobalVariable).GetValueInt())
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers3", (BathingAnimationLoopCountListFollowers.GetAt(3) As GlobalVariable).GetValueInt())

	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomMSet1Freq", AnimCustomMSet1Freq)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet1Freq", AnimCustomFSet1Freq)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet2Freq", AnimCustomFSet2Freq)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet3Freq", AnimCustomFSet3Freq)
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "AnimCustomTierCond", AnimCustomTierCond)
	
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomMSet1FreqFollowers", AnimCustomMSet1FreqFollowers)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet1FreqFollowers", AnimCustomFSet1FreqFollowers)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet2FreqFollowers", AnimCustomFSet2FreqFollowers)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet3FreqFollowers", AnimCustomFSet3FreqFollowers)
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "AnimCustomTierCondFollowers", AnimCustomTierCondFollowers)
	
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerSexActor", DirtinessPerSexActor)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "VictimMult", VictimMult)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "OverlayApplyAt", OverlayApplyAt)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "StartingAlpha", StartingAlpha)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "SexIntervalDirt", SexIntervalDirt)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "SexInterval", SexInterval)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "TimeToClean", TimeToClean)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "TimeToCleanInterval", TimeToCleanInterval)

	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "ShyDistance", ShyDistance)
	
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "FadeDirtSex", FadeDirtSex as Int)
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "Shyness", Shyness as Int)
	JsonUtil.SetIntValue("BathingInSkyrim/Settings.json", "AutoPlayerTFC", AutoPlayerTFC as Int)

	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "FadeTatsFadeTime", FadeTatsFadeTime)
	JsonUtil.SetFloatValue("BathingInSkyrim/Settings.json", "FadeTatsSoapMult", FadeTatsSoapMult)
	
	JsonUtil.Save("BathingInSkyrim/Settings.json")

	ShowMessage("$BIS_MSG_COMPLETED_SAVE", False)
	return True
EndFunction

Bool Function LoadPapyrusSettings()
	; Simple config health check
	if !JsonUtil.JsonExists("BathingInSkyrim/Settings.json")
		ShowMessage("$BIS_MSG_LOAD_WARN_1", false)
		return false
	ElseIf !(JsonUtil.Load("BathingInSkyrim/Settings.json") && JsonUtil.IsGood("BathingInSkyrim/Settings.json"))
		ShowMessage("$BIS_MSG_LOAD_WARN_2", false)
		return false
	else
		if !ShowMessage("$BIS_MSG_ASK_LOAD")
			return false
		endIf
	endIf

	DialogTopicEnabled.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "DialogTopicEnabled"))
	AutomateFollowerBathing.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "AutomateFollowerBathing"))
	WaterRestrictionEnabled.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "WaterRestrictionEnabled"))
	GetSoapyStyle.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "GetSoapyStyle"))
	GetSoapyStyleFollowers.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "GetSoapyStyleFollowers"))
	CheckStatusKeyCode.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "CheckStatusKeyCode"))
	BatheKeyCode.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BatheKeyCode"))
	ShowerKeyCode.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "ShowerKeyCode"))
	
	BathingAnimationStyle.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationStyle"))
	BathingAnimationStyleFollowers.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationStyleFollowers"))
	ShoweringAnimationStyle.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "ShoweringAnimationStyle"))
	ShoweringAnimationStyleFollowers.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "ShoweringAnimationStyleFollowers"))
	
	GetDressedAfterBathingEnabled.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "GetDressedAfterBathingEnabled"))
	GetDressedAfterBathingEnabledFollowers.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "GetDressedAfterBathingEnabledFollowers"))
	BathingIgnoredArmorSlotsMask.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingIgnoredArmorSlotsMask"))
	BathingIgnoredArmorSlotsMaskFollowers.SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingIgnoredArmorSlotsMaskFollowers"))
	
	DirtinessUpdateInterval.SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessUpdateInterval"))
	DirtinessPercentage.SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPercentage"))
	DirtinessPerHourPlayerHouse.SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourPlayerHouse"))
	DirtinessPerHourSettlement.SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourSettlement"))
	DirtinessPerHourDungeon.SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourDungeon"))
	DirtinessPerHourWilderness.SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerHourWilderness"))
	
	(DirtinessThresholdList.GetAt(0) As GlobalVariable).SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessThreshold0"))
	(DirtinessThresholdList.GetAt(1) As GlobalVariable).SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessThreshold1"))
	(DirtinessThresholdList.GetAt(2) As GlobalVariable).SetValue(JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessThreshold2"))
	
	(BathingAnimationLoopCountList.GetAt(0) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount0"))
	(BathingAnimationLoopCountList.GetAt(1) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount1"))
	(BathingAnimationLoopCountList.GetAt(2) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount2"))
	(BathingAnimationLoopCountList.GetAt(3) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCount3"))
	
	(BathingAnimationLoopCountListFollowers.GetAt(0) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers0"))
	(BathingAnimationLoopCountListFollowers.GetAt(1) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers1"))
	(BathingAnimationLoopCountListFollowers.GetAt(2) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers2"))
	(BathingAnimationLoopCountListFollowers.GetAt(3) As GlobalVariable).SetValueInt(JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "BathingAnimationLoopCountFollowers3"))
	
	AnimCustomMSet1Freq = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomMSet1Freq")
	AnimCustomFSet1Freq = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet1Freq")
	AnimCustomFSet2Freq = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet2Freq")
	AnimCustomFSet3Freq = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet3Freq")
	AnimCustomTierCond = JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "AnimCustomTierCond")

	AnimCustomMSet1FreqFollowers = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomMSet1FreqFollowers")
	AnimCustomFSet1FreqFollowers = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet1FreqFollowers")
	AnimCustomFSet2FreqFollowers = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet2FreqFollowers")
	AnimCustomFSet3FreqFollowers = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "AnimCustomFSet3FreqFollowers")
	AnimCustomTierCondFollowers = JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "AnimCustomTierCondFollowers")

	DirtinessPerSexActor = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "DirtinessPerSexActor")
	StartingAlpha = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "StartingAlpha")
	VictimMult = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "VictimMult")
	OverlayApplyAt = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "OverlayApplyAt")
	SexIntervalDirt = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "SexIntervalDirt")
	SexInterval = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "SexInterval")
	TimeToClean = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "TimeToClean")
	TimeToCleanInterval = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "TimeToCleanInterval")
	
	ShyDistance = JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "ShyDistance")
	
	FadeDirtSex = JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "FadeDirtSex")
	Shyness = JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "Shyness")
	AutoPlayerTFC = JsonUtil.GetIntValue("BathingInSkyrim/Settings.json", "AutoPlayerTFC")

	FadeTatsFadeTime = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "FadeTatsFadeTime")
	FadeTatsSoapMult = JsonUtil.GetFloatValue("BathingInSkyrim/Settings.json", "FadeTatsSoapMult")
	
	SetLocalArrays()
	BatheQuest.RegisterHotKeys()
	
	ShowMessage("$BIS_MSG_COMPLETED_LOAD", False)
	return true
EndFunction

Function UpdateAllActors()
	int Bis_UpdateAllActorsEvent = ModEvent.Create("BiS_UpdateActorsAll")
    If (Bis_UpdateAllActorsEvent)
        ModEvent.Send(Bis_UpdateAllActorsEvent)
    EndIf
EndFunction

Function UnForbidAllActor()
	Int i = StorageUtil.FormListCount(none, "BiS_ForbiddenActors")
	Actor CurrentActor
	While i > 0
		i -= 1
		CurrentActor = StorageUtil.FormlistGet(none, "BiS_ForbiddenActors", i) as Actor
		StorageUtil.StringListClear(CurrentActor, "BiS_ForbiddenString")
		StorageUtil.FormListClear(CurrentActor, "BiS_ForbiddenSenders")
	EndWhile
	StorageUtil.FormListClear(none, "BiS_ForbiddenActors")
EndFunction

; ---------- MCM Internal Variables ----------

; menu - Settings
Int ModStateOID_T
Int DialogTopicEnableToggleID
Int AutomateFollowerBathingMenuID
Int WaterRestrictionEnableToggleID
Int UpdateIntervalSliderID
Int DirtinessPerHourPlayerHouseSliderID
Int DirtinessPerHourSettlementSliderID
Int DirtinessPerHourDungeonSliderID
Int DirtinessPerHourWildernessSliderID
Int DirtinessThresholdTier1SliderID
Int DirtinessThresholdTier2SliderID
Int DirtinessThresholdTier3SliderID
Int CheckStatusKeyMapID
Int BatheKeyMapID
Int ShowerKeyMapID

; menu - Animations - Left
Int BathingAnimationStyleMenuID
Int ShoweringAnimationStyleMenuID
Int GetSoapyStyleMenuID
Int AutoPlayerTFCID
Int BathingAnimationLoopsTier0SliderID
Int BathingAnimationLoopsTier1SliderID
Int BathingAnimationLoopsTier2SliderID
Int BathingAnimationLoopsTier3SliderID
Int AnimCustomMSet1SliderID
Int AnimCustomFSet1SliderID
Int AnimCustomFSet2SliderID
Int AnimCustomFSet3SliderID
Int AnimCustomTierCondMenuID

; menu - Animations - Right
Int   GetDressedAfterBathingEnabledToggleID
Int[] UndressArmorSlotToggleIDs

; menu - Animations - Followers - Left
Int BathingAnimationStyleMenuIDFollowers
Int ShoweringAnimationStyleMenuIDFollowers
Int GetSoapyStyleMenuIDFollowers
Int BathingAnimationLoopsTier0SliderIDFollowers
Int BathingAnimationLoopsTier1SliderIDFollowers
Int BathingAnimationLoopsTier2SliderIDFollowers
Int BathingAnimationLoopsTier3SliderIDFollowers
Int AnimCustomMSet1SliderIDFollowers
Int AnimCustomFSet1SliderIDFollowers
Int AnimCustomFSet2SliderIDFollowers
Int AnimCustomFSet3SliderIDFollowers
Int AnimCustomTierCondMenuIDFollowers

; menu - Animations - Followers - Right
Int   GetDressedAfterBathingEnabledToggleIDFollowers
Int[] UndressArmorSlotToggleIDsFollowers

; menu - Tracked NPCs
Int[] TrackedActorsToggleIDs

; --------------------------------------------
