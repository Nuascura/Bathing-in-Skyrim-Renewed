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
	float setTotal = PapyrusUtil.AddFloatValues(fList)
	float f = Utility.RandomFloat(0, 1)
	If setTotal > 0
		int i = 0
		float setRange = 0
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

Armor[] Function GetActorClothing(Actor TargetActor, Bool bIsPlayer, Keyword[] kwBlacklist)
	Form[] EquippedItems = SPE_Utility.FilterFormsByKeyword(PO3_SKSEFunctions.AddAllEquippedItemsToArray(TargetActor), kwBlacklist, false, true)
	If bIsPlayer
		return SPE_Utility.FilterBySlotMask(EquippedItems, GetCombinedSlotMask(Menu.ArmorSlotArray), false)
	Else
		return SPE_Utility.FilterBySlotMask(EquippedItems, GetCombinedSlotMask(Menu.ArmorSlotArrayFollowers), false)
	EndIf
EndFunction

Int[] Function StripActorClothing(Actor TargetActor, Armor[] aArr)
	Int iIndex = aArr.Length
	Int[] iArr = Utility.CreateIntArray(aArr.Length, 0)
	While iIndex
		iIndex -= 1
		iArr[iIndex] = TargetActor.GetWornItemID(aArr[iIndex].GetSlotMask())
		TargetActor.UnequipItemEX(aArr[iIndex], 0, False)
	EndWhile
	return iArr
EndFunction

Form[] Function GetActorWeapons(Actor TargetActor)
	Form[] arr = new Form[3]
	arr[0] = PO3_SKSEFunctions.GetEquippedAmmo(TargetActor) ; Ammo
	arr[1] = TargetActor.GetEquippedWeapon(false) ; right hand
	arr[2] = TargetActor.GetEquippedWeapon(true) ; left hand
	return arr
EndFunction

Int[] Function StripActorWeapons(Actor TargetActor, Form[] aArr)
	Int[] iArr = new Int[3]
	if aArr[0]
		iArr[0] = 0
		TargetActor.UnequipItemEX(aArr[0], 0, False) ; Ammo
	endIf
	if aArr[1]
		iArr[1] = TargetActor.GetEquippedItemID(1)
		TargetActor.UnequipItemEX(aArr[1], 1, False) ; right hand
	endIf
	if aArr[2]
		iArr[2] = TargetActor.GetEquippedItemID(0)
		TargetActor.UnequipItemEX(aArr[2], 2, False) ; left hand
	endIf
	return iArr
EndFunction

Function ExitWieldState(Actor TargetActor)
	if TargetActor.isWeaponDrawn()
        float break
        while TargetActor.IsWeaponDrawn() && break < 5
			TargetActor.SheatheWeapon()
			Utility.Wait(0.25)
            break += 0.25
		endWhile
		Utility.Wait(0.5)
    endIf
EndFunction

Function DressActorEx(Actor TargetActor, Armor[] Clothing, Int[] ClothingID, Form[] Objects, Int[] ObjectsID)
	If menu.SkipItemHash
		ClothingID = Utility.CreateIntArray(Clothing.Length, 0)
		ObjectsID = Utility.CreateIntArray(Objects.Length, 0)
	EndIf

	Int Index = Clothing.Length
	While Index
		Index -= 1
		If Clothing[Index]
			EquipItemByIDEx(TargetActor, Clothing[Index], 0)
		EndIf
	EndWhile

	Index = Objects.Length
	While Index
		Index -= 1
		If Objects[Index]
			EquipItemByIDEx(TargetActor, Objects[Index], ObjectsID[Index], Index)
		EndIf
	EndWhile
EndFunction

Function EquipItemByIDEx(Actor TargetActor, Form uItem, int iItemID = 0, int iEquipSlot = 0)
	if iItemID
		TargetActor.EquipItemByID(uItem, iItemID, iEquipSlot)
	else
		TargetActor.EquipItemEx(uItem, iEquipSlot)
	endIf
EndFunction

Function SetFreeCam(bool bToggle)
	bToggle = Menu.AutoPlayerTFC && bToggle
	if bToggle
		if Game.GetCameraState() != 3
			MiscUtil.SetFreeCameraState(true, 5.0)
		endIf
		Game.DisablePlayerControls(false, True, True, False, True, True, True, 0)
	else
		if Game.GetCameraState() == 3
			MiscUtil.SetFreeCameraState(false)
		endIf
	endIf
EndFunction

Function SetHUDInstanceFlag(bool bToggle)
	bToggle = Menu.AutoHideUI && bToggle
	UI.SetBool("HUD Menu", "_root.HUDMovieBaseInstance._visible", bToggle)
EndFunction

Int Function GetDangerTier(Actor TargetActor, FormList kwListSafe, FormList kwListCivil, FormList kwListHostile)
	Location CurrentLocation = TargetActor.GetCurrentLocation()
	Location[] LocationList = SPE_Cell.GetExteriorLocations(TargetActor.GetParentCell())
	if CurrentLocation
		If TargetActor.IsInInterior() && LocationHasKeyWordInList(CurrentLocation, kwListSafe)
			return 4
		ElseIf LocationHasKeyWordInList(CurrentLocation, kwListCivil) \
			|| (TargetActor.IsInInterior() && ExteriorHasKeyWordInList(LocationList, kwListCivil))
			return 3
		ElseIf LocationHasKeyWordInList(CurrentLocation, kwListHostile) \
			|| (TargetActor.IsInInterior() && ExteriorHasKeyWordInList(LocationList, kwListHostile))
			return 1
		endIf
	endIf
	return 2
EndFunction

Int Function GetDirtinessTier(Actor TargetActor, FormList TargetSpellList)
	Int DirtinessTierIndex = TargetSpellList.GetSize()
	While DirtinessTierIndex
		DirtinessTierIndex -= 1
		If TargetActor.HasSpell(TargetSpellList.GetAt(DirtinessTierIndex) As Spell)
			return DirtinessTierIndex
		EndIf
	EndWhile
EndFunction
