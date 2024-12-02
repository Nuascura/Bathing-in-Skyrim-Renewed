Scriptname mzinTextureUtility extends Quest  

String[] Property TexNamez Auto Hidden
String[] Property TexPaths Auto Hidden
Int Property DirtSetCount Auto Hidden

mzinBatheMCMMenu Property Menu Auto

Event OnInit()
	TexNamez = new String[3]
	TexNamez[0] = "DirtFXBody.dds"
	TexNamez[1] = "DirtFXHands.dds"
	TexNamez[2] = "DirtFXFace.dds"


	TexPaths = new String[5]
	TexPaths[0] = "\\mzin\\Bathe\\"
	TexPaths[1] = "\\mzin\\Bathe\\Set2\\"
	TexPaths[2] = "\\mzin\\Bathe\\Set3\\"
	TexPaths[3] = "\\mzin\\Bathe\\Set4\\"
	TexPaths[4] = "\\mzin\\Bathe\\Set5\\"
	
	Utility.Wait(4.0)
	DirtSetCount = InitTexSets()
EndEvent

Int Function InitTexSets()
	Int SetCount = 1 ; vanilla
	Int TexCount
	String SetPrefix
	
	Int i = 1 ; Vanilla set is a given. Starting optional sets = 1
	While i <= 4
		TexCount = 0
		SetPrefix = "data/Textures/mzin/Bathe/Set" + (i+1) + "/"
		int j = 0
		While j < TexNamez.Length
			Menu.UpdateProgressRedetectDirtSets((TexPaths[i] + TexNamez[j]))
			Debug.Trace("mzin: Checking: " + SetPrefix + TexNamez[j])
			If MiscUtil.FileExists(SetPrefix + TexNamez[j])
				Debug.Trace("mzin_: Dirt Set " + (i + 1) + ": Found " + TexNamez[j])
				TexCount += 1
			Else
				Debug.Trace("mzin_: Warning: Dirt Set " + (i + 1) + ": DOES NOT EXIST: " + TexNamez[j])
			EndIf
			j += 1
		EndWhile
		If TexCount == 3 ; Complete texture set
			Debug.Trace("mzin_: Complete set found!! Set " + i)
			SetCount += 1
		
		ElseIf TexCount == 0
			Debug.Trace("mzin_: Empty set detected. Ending search")
			Return SetCount
		Else
			Debug.Messagebox("mzin_: Error: InitTexSets(): Incomplete texture set detected for set " + i + ". There should be 2 texture files per set but Mzin detected only " + TexCount + " files. One or more files are either missing or named incorrectly. You need to fix this first! Check your papyrus log. Search 'mzin'")
			Return -1
		EndIf
		i += 1
	EndWhile
	Return SetCount
EndFunction

String Function PickRandomDirtSet()
	Int SetSelect = Utility.RandomInt(1, DirtSetCount)
	If SetSelect == 1
		Return "\\mzin\\Bathe\\"
	Else
		Return "\\mzin\\Bathe\\Set" + SetSelect + "\\"
	EndIf
EndFunction