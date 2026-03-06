Scriptname WA_BathStatusQuestScript extends SKI_WidgetBase

Import WA_Utils
Import WA_WidgetPosition

Actor Property PlayerREF Auto
String Property LoadedBathMod Auto Hidden
String Property LoadedNeedMod Auto Hidden

Bool BathIneedPosition = false
Bool BathIWantPosition = false
Bool BathVitalityPosition = false
Bool BathVisible = true
String BathEvolution = "Alpha-based"
String BathBaseColor = "White"
String BathIconStyle = "Colored"
Int	BathSize = 120
Int BathHotkey = -1

Int BathStage1Alpha = 0
Int BathStage2Alpha = 33
Int BathStage3Alpha = 66
Int BathStage4Alpha = 100

;Bathing mod
MagicEffect DirtinessStage2Effect 
MagicEffect DirtinessStage3Effect
MagicEffect DirtinessStage4Effect
MagicEffect DirtinessStage5Effect
MagicEffect BloodinessStage2Effect
MagicEffect BloodinessStage3Effect
MagicEffect BloodinessStage4Effect
MagicEffect BloodinessStage5Effect

; iNeed
GlobalVariable iNeedThirst
GlobalVariable iNeedHunger
GlobalVariable iNeedFatigue

; RND iWant
GlobalVariable iWantBathLevel
GlobalVariable iWantBathLevel00Alpha
GlobalVariable iWantBathLevel01Alpha
GlobalVariable iWantBathLevel02Alpha
GlobalVariable iWantBathLevel03Alpha
GlobalVariable iWantBathLevel00Color
GlobalVariable iWantBathLevel01Color
GlobalVariable iWantBathLevel02Color
GlobalVariable iWantBathLevel03Color

; Vitality Mode
GlobalVariable VitalityWidgetPos
GlobalVariable VitalityWidgetXOffset
GlobalVariable VitalityWidgetYOffset
GlobalVariable VitalityWidgetOrientation
GlobalVariable VitalityWidgetShown
GlobalVariable VitalityWidgetType

Bool Property iNeedPosition
	Bool Function Get()
		Return BathIneedPosition
	EndFunction

	Function Set(bool a_val)
		BathIneedPosition = a_val
		If (Ready)
			OnWidgetReset()
		EndIf
	EndFunction
EndProperty

Bool Property iWantPosition
	Bool Function Get()
		Return BathIWantPosition
	EndFunction

	Function Set(bool a_val)
		BathIWantPosition = a_val
		UpdateIWantEvolution()
		If (Ready)
			OnWidgetReset()
		EndIf
	EndFunction
EndProperty

Bool Property VitalityPosition
	Bool Function Get()
		Return BathVitalityPosition
	EndFunction

	Function Set(bool a_val)
		BathVitalityPosition = a_val
		If (Ready)
			OnWidgetReset()
		EndIf
	EndFunction
EndProperty

Bool Property Visible
	Bool Function Get()
		Return BathVisible
	EndFunction

	Function Set(bool a_val)
		BathVisible = a_val
		If (Ready)
			UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", BathVisible) 
		EndIf
	EndFunction
EndProperty

Int Property Size
	Int Function Get()
		Return BathSize
	EndFunction

	Function Set(int a_val)
		BathSize = a_val
		If (Ready)
			UpdateScale()
		EndIf
	EndFunction
EndProperty

String Property Evolution
	String Function Get()
		Return BathEvolution
	EndFunction

	Function Set(String a_val)
		BathEvolution = a_val
		if iWantPosition
			UpdateIWantEvolution()
		else
			If (Ready)
				UpdateStatus()
			EndIf
		endIf
	EndFunction
EndProperty

String Property BaseColor
	String Function Get()
		Return BathBaseColor
	EndFunction

	Function Set(String a_val)
		BathBaseColor = a_val
		if iWantPosition
			Int futurColor = 0
			if (BathBaseColor == "Green")
				futurColor = 1
			endIf
			iWantBathLevel00Color.SetValue(futurColor as Float)
		else
			If (Ready)
				UpdateStatus()
			EndIf
		endIf
	EndFunction
EndProperty

String Property IconStyle
	String Function Get()
		Return BathIconStyle
	EndFunction

	Function Set(String a_val)
		BathIconStyle = a_val
		If (Ready)
			UpdateStatus()
		EndIf
	EndFunction
EndProperty

Int Property Stage1Alpha
	Int Function Get()
		Return BathStage1Alpha
	EndFunction

	Function Set(int a_val)
		BathStage1Alpha = a_val
		if iWantPosition
			iWantBathLevel00Alpha.SetValue(BathStage1Alpha as Float)
		else
			If (Ready)
				UpdateStatus()
			EndIf
		endIf
	EndFunction
EndProperty

Int Property Stage2Alpha
	Int Function Get()
		Return BathStage2Alpha
	EndFunction

	Function Set(int a_val)
		BathStage2Alpha = a_val
		if iWantPosition
			iWantBathLevel01Alpha.SetValue(BathStage2Alpha as Float)
		else
			If (Ready)
				UpdateStatus()
			EndIf
		endIf
	EndFunction
EndProperty

Int Property Stage3Alpha
	Int Function Get()
		Return BathStage3Alpha
	EndFunction

	Function Set(int a_val)
		BathStage3Alpha = a_val
		if iWantPosition
			iWantBathLevel02Alpha.SetValue(BathStage3Alpha as Float)
		else
			If (Ready)
				UpdateStatus()
			EndIf
		endIf
	EndFunction
EndProperty

Int Property Stage4Alpha
	Int Function Get()
		Return BathStage4Alpha
	EndFunction

	Function Set(int a_val)
		BathStage4Alpha = a_val
		if iWantPosition
			iWantBathLevel03Alpha.SetValue(BathStage4Alpha as Float)
		else
			If (Ready)
				UpdateStatus()
			EndIf
		endIf
	EndFunction
EndProperty

Int Property Hotkey
	Int Function Get()
		Return BathHotkey
	EndFunction

	Function Set(int a_val)
		BathHotkey = a_val
		RegisterForKey(BathHotkey)
	EndFunction
EndProperty

Function SetX(Float afX)
	If (Ready)
		X = afX
	EndIf
EndFunction

Function SetY(Float afY)
	If (Ready)
		Y = afY
	EndIf
EndFunction

Function SetHorizontalAnchor(String asAnchor)
	If (Ready)
		HAnchor = asAnchor
	EndIf
EndFunction

Function SetVerticalAnchor(String asAnchor)
	If (Ready)
		VAnchor = asAnchor
	EndIf
EndFunction

Function SetTransparency(Float afAlpha)
	If (Ready)
		Alpha = afAlpha
	EndIf
EndFunction

String Function GetWidgetSource()
	Return "WA/WA_BathStatus.swf"
EndFunction

String Function GetWidgetType()
	Return "WA_BathStatusQuestScript"
EndFunction

Function UpdateScale()
	UI.SetInt(HUD_MENU, WidgetRoot + ".Scale", BathSize) 
EndFunction

Function UpdateStatus()
	; on update defining the transparency or color of the widget depending on current keep it clean magic effect
	If (Ready)
		if (!iWantPosition)
			if ((!VitalityPosition) || (VitalityPosition && VitalityWidgetShown.GetValue() && VitalityWidgetType.GetValueInt() == 1)) 
			; if VitalityPositioning : only show if the widget is shown and is in the type of icons
				if (VitalityPosition)
					Int vitalityHotkey = GetVitalityWidgetHotkey().GetValue() as Int
					if BathHotkey != vitalityHotkey
						Hotkey = GetVitalityWidgetHotkey().GetValue() as Int
					endif
					Visible = GetExtWidgetAlpha() as Bool
				endif
				if (BathEvolution == "Color-based" || BathEvolution == "Color&Alpha-based")
					if (PlayerRef.HasMagicEffect(DirtinessStage3Effect) || (BloodinessStage3Effect && PlayerRef.HasMagicEffect(BloodinessStage3Effect)))
						UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBathColorLevel", 4)
						; for the colors : 1 = white, 2 = colored, 3 = green, 4 = orange, 5 = red
					elseif (PlayerRef.HasMagicEffect(DirtinessStage4Effect) || (BloodinessStage4Effect && PlayerRef.HasMagicEffect(BloodinessStage4Effect)) || (DirtinessStage5Effect && PlayerRef.HasMagicEffect(DirtinessStage5Effect)) || (BloodinessStage5Effect && PlayerRef.HasMagicEffect(BloodinessStage5Effect)))
						UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBathColorLevel", 5)
					else
						if (BathBaseColor == "White")
							UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBathColorLevel", 1)
						else
							UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBathColorLevel", 3)
						endIf
					endIf
					if (BathEvolution == "Color-based")
						SetTransparency(80)
					endif
				endIf
				if (BathEvolution == "Alpha-based" || BathEvolution == "Color&Alpha-based")
					
					if (PlayerRef.HasMagicEffect(DirtinessStage2Effect) || (BloodinessStage2Effect && PlayerRef.HasMagicEffect(BloodinessStage2Effect)))
						SetTransparency(BathStage2Alpha)
					elseif (PlayerRef.HasMagicEffect(DirtinessStage3Effect) || (BloodinessStage3Effect && PlayerRef.HasMagicEffect(BloodinessStage3Effect)))
						SetTransparency(BathStage3Alpha)
					elseif (PlayerRef.HasMagicEffect(DirtinessStage4Effect) || (BloodinessStage4Effect && PlayerRef.HasMagicEffect(BloodinessStage4Effect)) || (DirtinessStage5Effect && PlayerRef.HasMagicEffect(DirtinessStage5Effect)) || (BloodinessStage5Effect && PlayerRef.HasMagicEffect(BloodinessStage5Effect)))
						SetTransparency(BathStage4Alpha)
					else
						SetTransparency(BathStage1Alpha)
					endIf
					if (BathEvolution == "Alpha-based")
						if (BathIconStyle == "Colored")
							UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBathColorLevel", 2)
						else
							UI.InvokeInt(HUD_MENU, WidgetRoot + ".setBathColorLevel", 1)
						endif
					endif
				endIf
			else ; if VitalityPositioning and icons not visible then hide bathIcon
				Visible = false
			endIf
		else
			if PlayerRef.HasMagicEffect(DirtinessStage2Effect) || (BloodinessStage2Effect && PlayerRef.HasMagicEffect(BloodinessStage2Effect))
				iWantBathLevel.SetValue(1.0)
			elseif (PlayerRef.HasMagicEffect(DirtinessStage3Effect) || (BloodinessStage3Effect && PlayerRef.HasMagicEffect(BloodinessStage3Effect)))
				iWantBathLevel.SetValue(2.0)
			elseif (PlayerRef.HasMagicEffect(DirtinessStage4Effect) || (BloodinessStage4Effect && PlayerRef.HasMagicEffect(BloodinessStage4Effect)) || (DirtinessStage5Effect && PlayerRef.HasMagicEffect(DirtinessStage5Effect)) || (BloodinessStage5Effect && PlayerRef.HasMagicEffect(BloodinessStage5Effect)))
				iWantBathLevel.SetValue(3.0)
			else
				iWantBathLevel.SetValue(0.0)
			endIf
		endIf
	EndIf
EndFunction

Function UpdateIWantEvolution()
	if BathIWantPosition
		if (BathEvolution == "Alpha-based" || BathEvolution == "Color&Alpha-based")
			; Setting the right alpha values for each stage
			iWantBathLevel00Alpha.SetValue(BathStage1Alpha as Float)
			iWantBathLevel01Alpha.SetValue(BathStage2Alpha as Float)
			iWantBathLevel02Alpha.SetValue(BathStage3Alpha as Float)
			iWantBathLevel03Alpha.SetValue(BathStage4Alpha as Float)
			
			if (BathEvolution == "Alpha-based")
				; Setting all icons to white
				iWantBathLevel00Color.SetValue(0.0)
				iWantBathLevel01Color.SetValue(0.0)
				iWantBathLevel02Color.SetValue(0.0)
				iWantBathLevel03Color.SetValue(0.0)
			endif
		endif
		if (BathEvolution == "Color-based" || BathEvolution == "Color&Alpha-based")
			
			; Setting the right colors for each stage
			Int stage1Color = 0
			if (BathBaseColor == "Green")
				stage1Color = 1
			endIf
			iWantBathLevel00Color.SetValue(stage1Color as Float)
			iWantBathLevel01Color.SetValue(2.0)
			iWantBathLevel02Color.SetValue(3.0)
			iWantBathLevel03Color.SetValue(4.0)
			
			if (BathEvolution == "Color-based")
				; Setting all icons to alpha = 100
				iWantBathLevel00Alpha.SetValue(100.0)
				iWantBathLevel01Alpha.SetValue(100.0)
				iWantBathLevel02Alpha.SetValue(100.0)
				iWantBathLevel03Alpha.SetValue(100.0)
			endif
		endif
	else
		; set all stages to alpha = 0
		iWantBathLevel00Alpha.SetValue(0.0)
		iWantBathLevel01Alpha.SetValue(0.0)
		iWantBathLevel02Alpha.SetValue(0.0)
		iWantBathLevel03Alpha.SetValue(0.0)
	endIf
EndFunction

Event OnInit()
	Parent.OnInit()
	
	If LoadedNeedMod == "iNeed"
		BathIneedPosition = true
	ElseIf LoadedNeedMod == "iWant"
		Visible = false
		BathIWantPosition = true
	ElseIf LoadedNeedMod == "Vitality Mode"
		BathVitalityPosition = true
	EndIf
EndEvent

Event OnGameReload()
	Parent.OnGameReload()
	
	; checking what bath mod is loaded
	LoadedBathMod = "None Found"
	if GetDABDirtinessStage2Effect() != none ; if Dirt and Blood is loaded
		LoadedBathMod = "Dirt And Blood"
		DirtinessStage2Effect = GetDABDirtinessStage2Effect()
		DirtinessStage3Effect = GetDABDirtinessStage3Effect()
		DirtinessStage4Effect = GetDABDirtinessStage4Effect()
		DirtinessStage5Effect = GetDABDirtinessStage5Effect()
		BloodinessStage2Effect = GetDABBloodinessStage2Effect()
		BloodinessStage3Effect = GetDABBloodinessStage3Effect()
		BloodinessStage4Effect = GetDABBloodinessStage4Effect()
		BloodinessStage5Effect = GetDABBloodinessStage5Effect()
	elseif GetBISDirtinessStage2Effect() != none ; if Bathing In Skyrim is loaded
		LoadedBathMod = "Bathing In Skyrim"
		DirtinessStage2Effect = GetBISDirtinessStage2Effect()
		DirtinessStage3Effect = GetBISDirtinessStage3Effect()
		DirtinessStage4Effect = GetBISDirtinessStage4Effect()
		DirtinessStage5Effect = GetBISDirtinessStage5Effect()
	elseif (GetKICDirtinessStage2Effect() != none) ; if Keep it clean is loaded
		LoadedBathMod = "Keep It Clean"
		DirtinessStage2Effect = GetKICDirtinessStage2Effect()
		DirtinessStage3Effect = GetKICDirtinessStage3Effect()
		DirtinessStage4Effect = GetKICDirtinessStage4Effect()
	endif
	
	; checking if a need mod is loaded and if yes load the necessary variables from it
	LoadedNeedMod = "None Found"
	if (GetINeedQuest() != None) ; if iNeed is detected
		LoadedNeedMod = "iNeed"
		iNeedThirst = GetINeedThirst()
		iNeedHunger = GetINeedHunger()
		iNeedFatigue = GetINeedFatigue()
		RegisterForModEvent("_SN_StatusUpdated", "OnStatusUpdate")
		RegisterForModEvent("_SN_UIConfigured", "OnUIConfig")
	elseif (GetRNDBathLevel() != None) ; if RND iWant is detected
		LoadedNeedMod = "iWant"
		iWantBathLevel = GetRNDBathLevel()
		iWantBathLevel00Alpha = GetRNDBathLevel00Alpha()
		iWantBathLevel01Alpha = GetRNDBathLevel01Alpha()
		iWantBathLevel02Alpha = GetRNDBathLevel02Alpha()
		iWantBathLevel03Alpha = GetRNDBathLevel03Alpha()
		iWantBathLevel00Color = GetRNDBathLevel00Color()
		iWantBathLevel01Color = GetRNDBathLevel01Color()
		iWantBathLevel02Color = GetRNDBathLevel02Color()
		iWantBathLevel03Color = GetRNDBathLevel03Color()
		UpdateIWantEvolution()
	elseif (GetVitalityWidgetPos() != None) ; if Vitality Mode is detected
		LoadedNeedMod = "Vitality Mode"
		VitalityWidgetPos = GetVitalityWidgetPos()
		VitalityWidgetXOffset = GetVitalityWidgetXOffset()
		VitalityWidgetYOffset = GetVitalityWidgetYOffset()
		VitalityWidgetOrientation = GetVitalityWidgetOrientation()
		VitalityWidgetShown = GetVitalityWidgetShown()
		VitalityWidgetType = GetVitalityWidgetType()
		RegisterForModEvent("VitalityModeMeterReset", "OnVitalityModeMeterReset")
	endif
	
	RegisterForKey(BathHotkey)
	
	UpdateStatus()
EndEvent

Event OnWidgetReset()
	UpdateScale()
	Parent.OnWidgetReset()
	UI.InvokeBool(HUD_MENU, WidgetRoot + ".setVisible", BathVisible)
	If (iNeedPosition || VitalityPosition)
		Int WidgetPos
		Int WidgetXOffset
		Int WidgetYOffset
		Int WidgetOrientation
		float x_offset = 0
		float y_offset = 0
		float ineedIconHeight = 40
		float ineedIconWidth = 41
		Int displayedIcons = 0
		
		If iNeedPosition
			Int HungerPenalty = iNeedHunger.GetValue() as Int
			Int ThirstPenalty = iNeedThirst.GetValue() as Int
			Int FatiguePenalty = iNeedFatigue.GetValue() as Int
			Int extWidgetEvolutionType = GetExtWidgetEvolutionType()
			WidgetOrientation = GetExtWidgetOrientation()
			WidgetPos = GetExtWidgetPosition()
			WidgetXOffset = GetExtWidgetXOffset()
			WidgetYOffset = GetExtWidgetYOffset()
			
			
			; Finding the number of ineed icons displayed on screen
			If (extWidgetEvolutionType == 1)
				; NotifHUD : 0=disabled, 1 = Color-based, 2=Alpha-based, 3=Color&Alpha-based
				displayedIcons +=3
			ElseIf (extWidgetEvolutionType > 1)
				If HungerPenalty >= 0
					displayedIcons += 1
				EndIf
				If ThirstPenalty >= 0
					displayedIcons += 1
				EndIf
				If FatiguePenalty >= 0
					displayedIcons += 1
				EndIf
			EndIf
			If IsExtWidgetDiseaseShown()
				displayedIcons += 1
			EndIf
			
			
			
			; Setting to update at the same events as ineed widget
			RegisterForModEvent("_SN_StatusUpdated", "OnStatusUpdate")
			RegisterForModEvent("_SN_UIConfigured", "OnUIConfig")
		ElseIf VitalityPosition
			WidgetPos = VitalityWidgetPos.GetValue() as Int
			WidgetXOffset = VitalityWidgetXOffset.GetValue() as Int
			WidgetYOffset = VitalityWidgetYOffset.GetValue() as Int
			WidgetOrientation = VitalityWidgetOrientation.GetValue() as Int
			displayedIcons = 3
			RegisterForModEvent("VitalityModeMeterReset", "OnVitalityModeMeterReset")
			if WidgetPos == 6
				WidgetPos += 1
			endif
		EndIf
		
		; Setting the position of the Keep it clean widget the same way the position of the ineed/vitality widget is set
		; but with an offset depending on the number of ineed icons displayed and the orientation and position set in ineed MCM
		
		If WidgetOrientation == 0
			y_offset = displayedIcons * ineedIconHeight
		Else
			x_offset = displayedIcons * ineedIconWidth
		EndIf
		
		If  WidgetPos == 0
				SetX(1270 + WidgetXOffset - 5 - x_offset)
				SetY(710 + WidgetYOffset - 5 - y_offset)
				SetHorizontalAnchor("right")
				SetVerticalAnchor("bottom")
			ElseIf WidgetPos == 1
				SetX(20 + WidgetXOffset - 4 + x_offset)
				SetY(710 + WidgetYOffset - 5 - y_offset)
				SetHorizontalAnchor("left")
				SetVerticalAnchor("bottom")
			ElseIf WidgetPos == 2
				SetX(1270 + WidgetXOffset - 5 - x_offset)
				SetY(20 + WidgetYOffset - 4 + y_offset)
				SetHorizontalAnchor("right")
				SetVerticalAnchor("top")
			ElseIf WidgetPos == 3
				SetX(20 + WidgetXOffset - 4 + x_offset)
				SetY(20 + WidgetYOffset - 4 + y_offset)
				SetHorizontalAnchor("left")
				SetVerticalAnchor("top")
			ElseIf WidgetPos == 4
				SetX(1270 + WidgetXOffset - x_offset - 5)	;middle,right
				SetY(420 + WidgetYOffset - y_offset - 6)
				SetHorizontalAnchor("right")
				SetVerticalAnchor("bottom")
			ElseIf WidgetPos == 5
				SetX(20 + WidgetXOffset + x_offset - 4)	;middle,left
				SetY(420 + WidgetYOffset - y_offset - 6)
				SetHorizontalAnchor("left")
				SetVerticalAnchor("bottom")
			ElseIf WidgetPos == 6
				SetX(585 + WidgetXOffset + x_offset - 7)	;bottom, mid
				SetY(720 + WidgetYOffset - y_offset - 5)
				SetHorizontalAnchor("left")
				SetVerticalAnchor("bottom")
			Else
				SetX(585 + WidgetXOffset + x_offset - 7)	;top, mid
				SetY(65 + WidgetYOffset + y_offset - 5)
				SetHorizontalAnchor("left")
				SetVerticalAnchor("top")
		EndIf
		
		UpdateStatus()
	EndIf
EndEvent

Event OnKeyDown(Int aiKeyCode)
	If aiKeyCode == BathHotkey && !Utility.IsInMenuMode() && !UI.IsTextInputEnabled() && !BathIWantPosition
		Visible = !BathVisible
	EndIf
EndEvent

Event OnStatusUpdate(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	OnWidgetReset()
EndEvent

Event OnUIConfig(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	OnWidgetReset()
EndEvent

Event OnVitalityModeMeterReset(string a_eventName, string a_strArg, float a_numArg, Form a_sender)
	OnWidgetReset()
EndEvent
