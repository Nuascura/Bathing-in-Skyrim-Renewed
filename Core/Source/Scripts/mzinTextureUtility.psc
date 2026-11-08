Scriptname mzinTextureUtility extends Quest  

import MiscUtil
import StringUtil

String[] Property TexNamesD Auto Hidden
String[] Property TexNamesB Auto Hidden
String[] Property TexPathsF Auto Hidden
String[] Property TexPathsM Auto Hidden
Int[] Property DirtSetCount Auto Hidden
Int[] Property BloodSetCount Auto Hidden

mzinBatheMCMMenu Property Menu Auto
mzinUtility Property mzinUtil Auto

Event OnInit()
	TexNamesD = new String[4]
	TexNamesD[0] = "DirtFXBody.dds"
	TexNamesD[1] = "DirtFXHands.dds"
	TexNamesD[2] = "DirtFXFeet.dds"
	TexNamesD[3] = "DirtFXFace.dds"

	TexNamesB = new String[4]
	TexNamesB[0] = "BloodFXBody.dds"
	TexNamesB[1] = "BloodFXHands.dds"
	TexNamesB[2] = "BloodFXFeet.dds"
	TexNamesB[3] = "BloodFXFace.dds"

	TexPathsF = new String[5]
	TexPathsF[0] = "\\mzin\\Bathe\\Set1\\F\\"
	TexPathsF[1] = "\\mzin\\Bathe\\Set2\\F\\"
	TexPathsF[2] = "\\mzin\\Bathe\\Set3\\F\\"
	TexPathsF[3] = "\\mzin\\Bathe\\Set4\\F\\"
	TexPathsF[4] = "\\mzin\\Bathe\\Set5\\F\\"

	TexPathsM = new String[5]
	TexPathsM[0] = "\\mzin\\Bathe\\Set1\\M\\"
	TexPathsM[1] = "\\mzin\\Bathe\\Set2\\M\\"
	TexPathsM[2] = "\\mzin\\Bathe\\Set3\\M\\"
	TexPathsM[3] = "\\mzin\\Bathe\\Set4\\M\\"
	TexPathsM[4] = "\\mzin\\Bathe\\Set5\\M\\"

	DirtSetCount = new Int[2]
	DirtSetCount[0] = 0
	DirtSetCount[1] = 0

	BloodSetCount = new Int[2]
	BloodSetCount[0] = 0
	BloodSetCount[1] = 0
EndEvent

Function UtilInit()
	OnInit()

	DetectTexSets()
EndFunction

Function DetectTexSets()
	DirtSetCount[0] = InitTexSets(0, TexNamesD) ; male
	DirtSetCount[1] = InitTexSets(1, TexNamesD) ; female

	BloodSetCount[0] = InitTexSets(0, TexNamesB) ; male
	BloodSetCount[1] = InitTexSets(1, TexNamesB) ; female
EndFunction

Int Function InitTexSets(int aiSex, string[] TexNames)
	; this is a relatively heavy function. Should not be run with OnInit()

	Int SetCount
	Int TexCount
	String SetPrefix
	String SetGender = GetStringFromSex(aiSex)
	String[] TexPaths = GetTexPathFromSex(aiSex)
	
	While SetCount < TexPaths.Length
		SetCount += 1
		SetPrefix = "data/Textures/mzin/Bathe/Set" + SetCount + "/" + SetGender + "/"
		TexCount = 0
		While TexCount < TexNames.Length && FileExists(SetPrefix + TexNames[TexCount])
			Menu.UpdateProgressRedetectTexSets((TexPaths[SetCount] + TexNames[TexCount]))
			mzinUtil.LogTrace("Verified: " + SetPrefix + TexNames[TexCount])
			TexCount += 1
		EndWhile
		If TexCount == TexNames.Length ; Complete texture set
			mzinUtil.LogTrace("Complete set found!! Set " + SetCount + "(" + SetGender + ")")
		ElseIf TexCount == 0
			mzinUtil.LogTrace("Empty set detected. Ending search")
			Return SetCount - 1
		Else
			mzinUtil.LogTrace("Warning: " + Split(TexNames[0], "FX")[0] + " Set " + SetCount + ": InitTexSets() halted after receiving a DNE for " + TexNames[TexCount])
			mzinUtil.LogMessageBox("Error: InitTexSets(): Incomplete texture set detected for set " + SetCount + "(" + SetGender + "). There should be " + TexNames.Length + " texture files per set but Mzin detected only " + TexCount + " files. One or more files are either missing or named incorrectly. You need to fix this first! Check your papyrus log. Search 'mzin'")
			Return -1
		EndIf
	EndWhile
	Return SetCount
EndFunction

String Function PickRandomOverlaySet(string aiTag, int aiSex, actor akActor)
	string ret = ""
	if aiTag == "Dirt" && DirtSetCount[aiSex]
		ret = "\\mzin\\Bathe\\Set" + Utility.RandomInt(1, DirtSetCount[aiSex]) + "\\" + GetStringFromSex(aiSex) + "\\"
	elseIf aiTag == "Blood" && BloodSetCount[aiSex]
		ret = "\\mzin\\Bathe\\Set" + Utility.RandomInt(1, BloodSetCount[aiSex]) + "\\" + GetStringFromSex(aiSex) + "\\"
	endIf
	if ret
		ret += mzinUtil.GetRacePath(akActor)
	endIf
	mzinUtil.LogTrace("Selected texture path for " + akActor + " at:" + ret)
	return ret
EndFunction

String Function GetStringFromSex(int aiSex)
	if aiSex as bool
		return "F"
	else
		return "M"
	endIf
EndFunction

String[] Function GetTexPathFromSex(int aiSex)
	if aiSex
		return TexPathsF
	else
		return TexPathsM
	endIf
EndFunction