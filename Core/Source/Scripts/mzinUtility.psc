Scriptname mzinUtility extends Quest  

mzinBatheMCMMenu Property Menu Auto

string Function GetModVersion()
    return Menu.GetModVersion()
EndFunction

Bool Function IsActorInWater(Actor akActor) global
	mzinBatheQuest BatheQuest = Quest.GetQuest("mzinBatheQuest") as mzinBatheQuest
	return BatheQuest.IsInWater(akActor) || BatheQuest.IsUnderWaterfall(akActor)
EndFunction

Function LogTrace(String LogMessage, Bool Force = False)
    if LogMessage
        if Force || Menu.LogTrace
	        Debug.Trace("Mzin: " + LogMessage)
        endIf
    endIf
EndFunction

Function LogNotification(String LogMessage, Bool Force = False)
    if LogMessage
        if Force
            Debug.Notification("BiSR: " + LogMessage)
        elseIf Menu.LogNotification
            Debug.Notification(LogMessage)
        endIf
    endIf
EndFunction

Function LogMessageBox(String LogMessage)
    if LogMessage
        Debug.MessageBox(LogMessage)
    endIf
EndFunction

Int Function GameMessage(Message LogMessage, float afArg1 = 0.0, float afArg2 = 0.0, float afArg3 = 0.0, float afArg4 = 0.0, float afArg5 = 0.0, float afArg6 = 0.0, float afArg7 = 0.0, float afArg8 = 0.0, float afArg9 = 0.0)
    if LogMessage
        if Menu.GameMessage
            return LogMessage.Show(afArg1, afArg2, afArg3, afArg4, afArg5, afArg6, afArg7, afArg8, afArg9)
        endIf
    endIf
    return 0
EndFunction

Bool Function ExteriorHasKeyWordInList(Location[] ExteriorLocation, FormList KeyWordList)
	if !ExteriorLocation
		return false
	endIf
	int i = 0
	while i < ExteriorLocation.Length && ExteriorLocation[i]
		Int KeyWordListIndex = KeyWordList.GetSize()	
		While KeyWordListIndex
			KeyWordListIndex -= 1
			If ExteriorLocation[i].HasKeyWord(KeyWordList.GetAt(KeyWordListIndex) As KeyWord)
				Return True
			EndIf		
		EndWhile
		i += 1
	endWhile
	Return False
EndFunction

Bool Function LocationHasKeyWordInList(Location CurrentLocation, FormList KeyWordList)
	if !CurrentLocation
		return false
	endIf
	Int KeyWordListIndex = KeyWordList.GetSize()	
	While KeyWordListIndex
		KeyWordListIndex -= 1
		If CurrentLocation.HasKeyWord(KeyWordList.GetAt(KeyWordListIndex) As KeyWord)
			Return True
		EndIf		
	EndWhile
	Return False
EndFunction

Int Function GetCombinedSlotMask(int[] slotArray)
	slotArray = PapyrusUtil.RemoveInt(slotArray, 0)

	int slotMask = 0
	int index = slotArray.length
	while index
		index -= 1
		slotMask = Math.LogicalOr(slotMask, Armor.GetMaskForSlot(slotArray[index]))
	endWhile
	return slotMask
EndFunction

int Function GetRandomFromNormalization(float[] fList)
	float setTotal = 0
	float setRange = 0
	float f = Utility.RandomFloat(0, 1)
	int i = 0
	while i < fList.length
		setTotal += fList[i]
		i += 1
	endWhile
	If setTotal > 0
		i = 0
		while i < fList.length
			setRange += (fList[i] / setTotal)
			if f < setRange
				return i
			endIf
			i += 1
		endWhile
		return fList.length - 1
	else
		return Utility.RandomInt(0, fList.length - 1)
	endIf
EndFunction

Bool[] Function RetrieveSlotState(int[] array1, bool[] array2)
	array2 = Utility.CreateBoolArray(array2.length)
	int index = array2.length
	while index
		index -= 1
		array2[index] = (array1.Find(index + 30) != -1)
	endWhile
	return array2
EndFunction

Int[] Function RenewSlotState(int[] array1, bool[] array2)
	array1 = Utility.CreateIntArray(array2.length)
	int index = array2.length
	while index
		index -= 1
		if array2[index]
			array1[index] = index + 30
		endIf
	endWhile
	return array1
EndFunction
