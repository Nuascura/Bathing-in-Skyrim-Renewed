Scriptname mzinOverlayUtility extends Quest

import PO3_SKSEFunctions
import StorageUtil
import NiOverride

String[] Areas
Actor Property PlayerRef Auto
mzinTextureUtility Property TexUtil Auto
mzinUtility Property mzinUtil Auto

Event OnInit()
	Areas = new String[4]
	Areas[0] = "Body"
	Areas[1] = "Hands"
	Areas[2] = "Feet"
	Areas[3] = "Face"
EndEvent 

Function BeginOverlay(String OvlTag, Actor akTarget, Float Alpha = 1.0, Int Tint = 0xFFFFFF)
	String TextureToApply
	Int Gender = akTarget.GetLeveledActorBase().GetSex()
	Int i = 0
	String TexPrefix = 	GetStringValue(akTarget, "mzin_" + OvlTag + "TexturePrefix", "")
	If TexPrefix == ""
		TexPrefix = TexUtil.PickRandomOverlaySet(OvlTag, Gender, akTarget)
		if TexPrefix == ""
			return
		endIf
		SetStringValue(akTarget, "mzin_" + OvlTag + "TexturePrefix", TexPrefix)
	EndIf
	TextureToApply = TexPrefix + OvlTag + "FX"
	While i < Areas.Length
		ReadyOverlay(akTarget, Gender as Bool, Areas[i], (TextureToApply + Areas[i] + ".dds"), Alpha, Tint)
		i += 1
	EndWhile
EndFunction

Function ReadyOverlay(Actor akTarget, Bool Gender, String Area, String TextureToApply, Float Alpha, Int Tint)
	Int SlotToUse = GetEmptySlot(akTarget, Gender, Area)
	If SlotToUse != -1
		ApplyOverlay(akTarget, Gender, Area, SlotToUse, TextureToApply, Alpha, Tint)
	Else
		mzinUtil.LogTrace("Error applying overlay to area: " + Area)
	EndIf
EndFunction

Function ApplyOverlay(Actor akTarget, Bool Gender, String Area, String OverlaySlot, String TextureToApply, Float Alpha, Int Tint)
	String Node = Area + " [ovl" + OverlaySlot + "]"
	If !HasOverlays(akTarget)
		AddOverlays(akTarget)
	EndIf
	AddNodeOverrideString(akTarget, Gender, Node, 9, 0, TextureToApply, TRUE)
	AddNodeOverrideInt(akTarget, Gender, Node, 0, 0, 0, TRUE)
	AddNodeOverrideInt(akTarget, Gender, Node, 7, 0, 0, TRUE)
	
	AddNodeOverrideInt(akTarget, Gender, Node, 7, -1, Tint, TRUE)
    AddNodeOverrideInt(akTarget, Gender, Node, 0, -1, 0, TRUE)
    AddNodeOverrideFloat(akTarget, Gender, Node, 8, -1, Alpha, TRUE)
	AddNodeOverrideFloat(akTarget, Gender, Node, 3, -1, 0.0, TRUE)
	AddNodeOverrideFloat(akTarget, Gender, Node, 2, -1, 0.0, TRUE)
	
	ApplyNodeOverrides(akTarget)
EndFunction

Function UpdateAlpha(String OvlTag, Actor akTarget, Float Alpha)
	String Node
	Bool Result = false
	Bool Gender = akTarget.GetLeveledActorBase().GetSex() as Bool
	String TexPath = GetStringValue(akTarget, "mzin_" + OvlTag + "TexturePrefix")
	String MatchString
	Int i = Areas.Length
	While i > 0
		i -= 1
		Int j = GetNumSlots(Areas[i])
		MatchString = (TexPath + OvlTag + "FX" + Areas[i] + ".dds")
		While j > 0 && !Result
			j -= 1
			Node = Areas[i] + " [ovl" + j + "]"
			If GetNodeOverrideString(akTarget, Gender, Node, 9, 0) == MatchString
				AddNodeOverrideFloat(akTarget, Gender, Node, 8, -1, Alpha, TRUE)
				Result = true
			EndIf
		EndWhile
		Result = false
	EndWhile
EndFunction

String Function GetLastNode(String OvlTag, Actor akTarget, Int aiArea)
	String Node
	Bool Gender = akTarget.GetLeveledActorBase().GetSex() as Bool
	String MatchString = (GetStringValue(akTarget, "mzin_" + OvlTag + "TexturePrefix") + OvlTag + "FX" + Areas[aiArea] + ".dds")
	Int i = GetNumSlots(Areas[aiArea])
	While i > 0
		i -= 1
		Node = Areas[aiArea] + " [ovl" + i + "]"
		If GetNodeOverrideString(akTarget, Gender, Node, 9, 0) == MatchString
			return Node
		EndIf
	EndWhile
	Return ""
EndFunction

Int Function GetEmptySlot(Actor akTarget, Bool Gender, String Area)
	Int i = GetNumSlots(Area)
	String TexPath
	While i > 0
		i -= 1
		TexPath = GetNodeOverrideString(akTarget, Gender, Area + " [ovl" + i + "]", 9, 0)
		If TexPath == "" || TexPath == "actors\\character\\overlays\\default.dds"
			mzinUtil.LogTrace("GetEmptySlot: Slot " + i + " chosen for area: " + area + " on " + akTarget.GetBaseObject().GetName())
			Return i
		EndIf
	EndWhile
	mzinUtil.LogTrace("GetEmptySlot: Error: Could not find a free slot in area: " + Area + " on "  + akTarget.GetBaseObject().GetName())
	Return -1
EndFunction

Int Function GetNumSlots(String Area)
	If Area == "Body"
		Return GetNumBodyOverlays()
	ElseIf Area == "Hands"
		Return GetNumHandOverlays()
	ElseIf Area == "Feet"
		Return GetNumFeetOverlays()
	ElseIf Area == "Face"
		Return GetNumFaceOverlays()
	EndIf
	mzinUtil.LogTrace("GetNumSlots: Error: Failed to recognize Overlay Area from String.")
	Return 0
EndFunction

Function RemoveDirtGameLoad(Actor akTarget) ; Clears all dirt overlays from all sets from all overlay slots but takes a long time
	mzinUtil.LogTrace("Called RemoveDirtGameLoad on " + akTarget.GetBaseObject().GetName())
	int Gender = akTarget.GetLeveledActorBase().GetSex()
	String TexPath
	String RacePath = mzinUtil.GetRacePath(akTarget)
	String[] TexPrefixes
	String Node
	Int i = 0
	if Gender as bool
		TexPrefixes = TexUtil.TexPathsF
	else
		TexPrefixes = TexUtil.TexPathsM
	endIf
	While i < Areas.Length
		Int j = GetNumSlots(Areas[i])
		While j > 0
			j -= 1
			Node = Areas[i] + " [ovl" + j + "]"
			Int k = TexUtil.DirtSetCount[Gender]
			While k > 0
				k -= 1
				TexPath = GetNodeOverrideString(akTarget, Gender as Bool, Node, 9, 0)
				If TexPath == (TexPrefixes[k] + RacePath + "DirtFX" + Areas[i] + ".dds") || TexPath == ""
					RemoveOverlayNode(akTarget, Gender as Bool, Node)
					;mzinUtil.LogTrace("Removing overlay from slot " + j + " of area: " + Areas[i] + " on " + akTarget.GetBaseObject().GetName())
				EndIf
			EndWhile
		EndWhile
		i += 1
	EndWhile
	ApplyNodeOverrides(akTarget)
	UnSetStringValue(akTarget, "mzin_DirtTexturePrefix")
EndFunction

Function RemoveBloodGameLoad(Actor akTarget) ; Clears all blood overlays from all sets from all overlay slots but takes a long time
	mzinUtil.LogTrace("Called RemoveBloodGameLoad on " + akTarget.GetBaseObject().GetName())
	int Gender = akTarget.GetLeveledActorBase().GetSex()
	String TexPath
	String RacePath = mzinUtil.GetRacePath(akTarget)
	String[] TexPrefixes
	String Node
	Int i = 0
	if Gender as bool
		TexPrefixes = TexUtil.TexPathsF
	else
		TexPrefixes = TexUtil.TexPathsM
	endIf
	While i < Areas.Length
		Int j = GetNumSlots(Areas[i])
		While j > 0
			j -= 1
			Node = Areas[i] + " [ovl" + j + "]"
			Int k = TexUtil.BloodSetCount[Gender]
			While k > 0
				k -= 1
				TexPath = GetNodeOverrideString(akTarget, Gender as Bool, Node, 9, 0)
				If TexPath == (TexPrefixes[k] + RacePath + "BloodFX" + Areas[i] + ".dds") || TexPath == ""
					RemoveOverlayNode(akTarget, Gender as Bool, Node)
					;mzinUtil.LogTrace("Removing overlay from slot " + j + " of area: " + Areas[i] + " on " + akTarget.GetBaseObject().GetName())
				EndIf
			EndWhile
		EndWhile
		i += 1
	EndWhile
	ApplyNodeOverrides(akTarget)
	UnSetStringValue(akTarget, "mzin_BloodTexturePrefix")
EndFunction

Function RemoveOverlayGameLoad(Actor akTarget)
	RemoveDirtGameLoad(akTarget)
	RemoveBloodGameLoad(akTarget)
EndFunction

Function RemoveOverlay(String OvlTag, Actor akTarget, Bool UnsetPrefix) ; Clears the first texture it finds from each overlay area - faster
	mzinUtil.LogTrace("Clearing overlay from " + akTarget.GetBaseObject().GetName())
	Bool Gender = akTarget.GetLeveledActorBase().GetSex() as Bool
	String TexPath
	String Node
	String MatchString
	String TexPrefix = GetStringValue(akTarget, "mzin_" + OvlTag + "TexturePrefix", "")
	Bool Result = false
	Int i = 0
	While i < Areas.Length
		Int j = GetNumSlots(Areas[i])
		MatchString = (TexPrefix + OvlTag + "FX" + Areas[i] + ".dds")
		While j > 0 && !Result
			j -= 1
			Node = Areas[i] + " [ovl" + j + "]"
			TexPath = GetNodeOverrideString(akTarget, Gender, Node, 9, 0)
			;mzinUtil.LogTrace("RemoveOverlay(): Target: " + akTarget.GetBaseObject().GetName() + ". Node: " + Node + ". TexPath: " + TexPath + ". MatchString: " + MatchString)
			If TexPath == MatchString
				RemoveOverlayNode(akTarget, Gender, Node)
				Result = true
				mzinUtil.LogTrace("_mzin_: Removing overlay from slot " + j + " of area: " + Areas[i] + " on " + akTarget.GetBaseObject().GetName())
			EndIf
		EndWhile
		Result = false
		i += 1
	EndWhile
	ApplyNodeOverrides(akTarget)
	if UnsetPrefix
		UnSetStringValue(akTarget, "mzin_" + OvlTag + "TexturePrefix")
	endIf
EndFunction

Function RemoveOverlayNode(Actor akTarget, Bool Gender, String Node)
	AddNodeOverrideString(akTarget, Gender, Node, 9, 0, "actors\\character\\overlays\\default.dds", true)
	
	RemoveNodeOverride(akTarget, Gender, Node, 9, 0)
	RemoveNodeOverride(akTarget, Gender, Node, 7, -1)
	RemoveNodeOverride(akTarget, Gender, Node, 0, -1)
	RemoveNodeOverride(akTarget, Gender, Node, 8, -1)
	RemoveNodeOverride(akTarget, Gender, Node, 2, -1)
	RemoveNodeOverride(akTarget, Gender, Node, 3, -1)
EndFunction

Function ApplyDirt(Actor akTarget, Float Alpha, Int Tint, Bool UnsetPrefix = true)
	RemoveOverlay("Dirt", akTarget, UnsetPrefix)
	BeginOverlay("Dirt", akTarget, Alpha, Tint)
EndFunction

Function ReapplyDirt(Actor akTarget)
	If !HasStringValue(akTarget, "mzin_DirtTexturePrefix")
		Return
	EndIf

	String Node = GetLastNode("Dirt", akTarget, 0)
	ApplyDirt(akTarget, \
	GetNodeOverrideFloat(akTarget, akTarget.GetLeveledActorBase().GetSex(), Node, 8, -1), \
	GetNodeOverrideInt(akTarget, akTarget.GetLeveledActorBase().GetSex(), Node, 7, -1), \
	false)
EndFunction

Function ApplyBlood(Actor akTarget, Int Tint, Bool UnsetPrefix = true)
	RemoveOverlay("Blood", akTarget, UnsetPrefix)
	BeginOverlay("Blood", akTarget, 100.0, Tint)
EndFunction

Function ReapplyBlood(Actor akTarget)
	If !HasStringValue(akTarget, "mzin_BloodTexturePrefix")
		Return
	EndIf

	String Node = GetLastNode("Blood", akTarget, 0)
	ApplyDirt(akTarget, \
	GetNodeOverrideFloat(akTarget, akTarget.GetLeveledActorBase().GetSex(), Node, 4, -1), \
	GetNodeOverrideInt(akTarget, akTarget.GetLeveledActorBase().GetSex(), Node, 7, -1), \
	false)
EndFunction