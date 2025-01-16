Scriptname mzinOverlayUtility extends Quest

String[] Areas
String[] Property AreasTexNames Auto Hidden
Actor Property PlayerRef Auto
mzinTextureUtility Property TexUtil Auto
mzinUtility Property mzinUtil Auto

Event OnInit()
	Areas = new String[4]
	Areas[0] = "Body"
	Areas[1] = "Hands"
	Areas[2] = "Feet"
	Areas[3] = "Face"
	
	AreasTexNames = new String[4]
	AreasTexNames[0] = "Body"
	AreasTexNames[1] = "Hands"
	AreasTexNames[2] = "Feet"
	AreasTexNames[3] = "Face"
EndEvent 

Function BeginOverlay(Actor akTarget, Float Alpha)
	String TextureToApply
	Int Gender = akTarget.GetLeveledActorBase().GetSex()
	Int i = 0
	String TexPrefix = 	StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "")
	If TexPrefix == ""
		TexPrefix = TexUtil.PickRandomDirtSet(Gender)
		StorageUtil.SetStringValue(akTarget, "mzin_DirtTexturePrefix", TexPrefix)
	EndIf
	TextureToApply = TexPrefix + "DirtFX"
	;StorageUtil.SetStringValue(akTarget, "mzin_DirtTexturePath", TextureToApply)
	While i < Areas.Length
		ReadyOverlay(akTarget, Gender as Bool, Areas[i], (TextureToApply + AreasTexNames[i] + ".dds"), Alpha)
		i += 1
	EndWhile
EndFunction

Function ReadyOverlay(Actor akTarget, Bool Gender, String Area, String TextureToApply, Float Alpha)
	Int SlotToUse = GetEmptySlot(akTarget, Gender, Area)
	If SlotToUse != -1
		ApplyOverlay(akTarget, Gender, Area, SlotToUse, TextureToApply, Alpha)
	Else
		mzinUtil.LogTrace("Error applying overlay to area: " + Area)
	EndIf
EndFunction

Function ApplyOverlay(Actor akTarget, Bool Gender, String Area, String OverlaySlot, String TextureToApply, Float Alpha)
	String Node = Area + " [ovl" + OverlaySlot + "]"
	If !NiOverride.HasOverlays(akTarget)
		NiOverride.AddOverlays(akTarget)
	EndIf
	NiOverride.AddNodeOverrideString(akTarget, Gender, Node, 9, 0, TextureToApply, TRUE)
	NiOverride.AddNodeOverrideInt(akTarget, Gender, Node, 0, 0, 0, TRUE)
	NiOverride.AddNodeOverrideInt(akTarget, Gender, Node, 7, 0, 0, TRUE)
	
	NiOverride.AddNodeOverrideInt(akTarget, Gender, Node, 7, -1, 0, TRUE)
    NiOverride.AddNodeOverrideInt(akTarget, Gender, Node, 0, -1, 0, TRUE)
    NiOverride.AddNodeOverrideFloat(akTarget, Gender, Node, 8, -1, Alpha, TRUE)
	NiOverride.AddNodeOverrideFloat(akTarget, Gender, Node, 2, -1, 0.0, TRUE)
	NiOverride.AddNodeOverrideFloat(akTarget, Gender, Node, 3, -1, 0.0, TRUE)
	NiOverride.ApplyNodeOverrides(akTarget)
EndFunction

Function UpdateAlpha(Actor akTarget, Float Alpha)
	String Node
	Bool Result = false
	Bool Gender = akTarget.GetLeveledActorBase().GetSex() as Bool
	String TexPath = StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix")
	String MatchString
	Int i = Areas.Length
	While i > 0
		i -= 1
		Int j = GetNumSlots(Areas[i])
		MatchString = (TexPath + "DirtFX" + AreasTexNames[i] + ".dds")
		While j > 0 && !Result
			j -= 1
			Node = Areas[i] + " [ovl" + j + "]"
			If NiOverride.GetNodeOverrideString(akTarget, Gender, Node, 9, 0) == MatchString
				NiOverride.AddNodeOverrideFloat(akTarget, Gender, Node, 8, -1, Alpha, TRUE)
				Result = true
			EndIf
		EndWhile
		Result = false
	EndWhile
EndFunction

Int Function GetEmptySlot(Actor akTarget, Bool Gender, String Area)
	Int i = GetNumSlots(Area)
	String TexPath
	While i > 0
		i -= 1
		TexPath = NiOverride.GetNodeOverrideString(akTarget, Gender, Area + " [ovl" + i + "]", 9, 0)
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
		Return NiOverride.GetNumBodyOverlays()
	ElseIf Area == "Hands"
		Return NiOverride.GetNumHandOverlays()
	ElseIf Area == "Feet"
		Return NiOverride.GetNumFeetOverlays()
	Else
		Return NiOverride.GetNumFaceOverlays()
	EndIf
EndFunction

Function ClearDirtGameLoad(Actor akTarget) ; Clears all dirt overlays from all sets from all overlay slots but takes a long time
	int Gender = akTarget.GetLeveledActorBase().GetSex()
	String TexPath
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
				TexPath = NiOverride.GetNodeOverrideString(akTarget, Gender as Bool, Node, 9, 0)
				;mzinUtil.LogTrace("ClearDirt(): Target: " + akTarget.GetBaseObject().GetName() + ". Node: " + Node + ". TexPath: " + TexPath)
				If TexPath == (TexPrefixes[k] + "DirtFX" + AreasTexNames[i] + ".dds") || TexPath == ""
					RemoveOverlay(akTarget, Gender as Bool, Node)
					;mzinUtil.LogTrace("Removing overlay from slot " + j + " of area: " + Areas[i] + " on " + akTarget.GetBaseObject().GetName())
				EndIf
			EndWhile
		EndWhile
		i += 1
	EndWhile
	If akTarget != PlayerRef
		NiOverride.ApplyNodeOverrides(akTarget)
		NiOverride.RemoveOverlays(akTarget)
	EndIf	
EndFunction

Function ClearDirt(Actor akTarget) ; Clears the first dirt overlay it finds from each overlay area - faster
	mzinUtil.LogTrace("Clearing dirt from " + akTarget.GetBaseObject().GetName())
	;StorageUtil.UnSetStringValue(akTarget, "mzin_DirtTexturePrefix")
	Bool Gender = akTarget.GetLeveledActorBase().GetSex() as Bool
	String TexPath
	String Node
	String MatchString
	String TexPrefix = StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "")
	Bool Result = false
	Int i = 0
	While i < Areas.Length
		Int j = GetNumSlots(Areas[i])
		MatchString = (TexPrefix + "DirtFX" + AreasTexNames[i] + ".dds")
		While j > 0 && !Result
			j -= 1
			Node = Areas[i] + " [ovl" + j + "]"
			TexPath = NiOverride.GetNodeOverrideString(akTarget, Gender, Node, 9, 0)
			;mzinUtil.LogTrace("ClearDirt(): Target: " + akTarget.GetBaseObject().GetName() + ". Node: " + Node + ". TexPath: " + TexPath + ". MatchString: " + MatchString)
			If TexPath == MatchString
				RemoveOverlay(akTarget, Gender, Node)
				Result = true
				mzinUtil.LogTrace("_mzin_: Removing overlay from slot " + j + " of area: " + Areas[i] + " on " + akTarget.GetBaseObject().GetName())
			EndIf
		EndWhile
		Result = false
		i += 1
	EndWhile
	If akTarget != PlayerRef
		NiOverride.ApplyNodeOverrides(akTarget)
		NiOverride.RemoveOverlays(akTarget)
	EndIf
	StorageUtil.UnSetStringValue(akTarget, "mzin_DirtTexturePrefix")
EndFunction

Function RemoveOverlay(Actor akTarget, Bool Gender, String Node)
	;mzinUtil.LogTrace("ClearDirt(): Target: " + akTarget.GetBaseObject().GetName() + ". Node: " + Node + ". Clearing ! TexPath: " + TexPath)
	NiOverride.AddNodeOverrideString(akTarget, Gender, Node, 9, 0, "actors\\character\\overlays\\default.dds", true)
	
	NiOverride.RemoveNodeOverride(akTarget, Gender, Node, 9, 0)
	NiOverride.RemoveNodeOverride(akTarget, Gender, Node, 7, -1)
	NiOverride.RemoveNodeOverride(akTarget, Gender, Node, 0, -1)
	NiOverride.RemoveNodeOverride(akTarget, Gender, Node, 8, -1)
	NiOverride.RemoveNodeOverride(akTarget, Gender, Node, 2, -1)
	NiOverride.RemoveNodeOverride(akTarget, Gender, Node, 3, -1)
EndFunction

Function ApplyDirt(Actor akTarget, Float Alpha)
	ClearDirt(akTarget)
	BeginOverlay(akTarget, Alpha)
EndFunction

Function SendBathePlayerModEvent()
    SendModEvent("BiS_BathePlayerEvent")
EndFunction

Function SendBatheModEvent(Form akBatheActor)
    int BiS_BatheModEvent = ModEvent.Create("BiS_BatheEvent")
    If (BiS_BatheModEvent)
        ModEvent.PushForm(BiS_BatheModEvent, akBatheActor)
        ModEvent.Send(BiS_BatheModEvent)
    EndIf
EndFunction

Function SendAlphaUpdateEvent(Form akTarget)
    int BiS_UpdateAlphaModEvent = ModEvent.Create("BiS_UpdateAlpha")
    If (BiS_UpdateAlphaModEvent)
        ModEvent.PushForm(BiS_UpdateAlphaModEvent, akTarget)
        ModEvent.Send(BiS_UpdateAlphaModEvent)
    EndIf
EndFunction
