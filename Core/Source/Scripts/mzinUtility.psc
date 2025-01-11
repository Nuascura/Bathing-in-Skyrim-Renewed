Scriptname mzinUtility extends Quest  

mzinBatheMCMMenu Property Menu Auto

string Function GetModVersion()
    return Menu.GetModVersion()
EndFunction

Function LogTrace(String LogMessage, Bool Force = False)
    if LogMessage
        if Force || true ;to-do: Menu.LogTrace
	        Debug.Trace("Mzin: " + LogMessage)
        endIf
    endIf
EndFunction

Function LogNotification(String LogMessage, Bool Force = False)
    if LogMessage
        if Force
            Debug.Notification("BISR: " + LogMessage)
        elseIf true ;to-do: Menu.LogNotification
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
        if true ;to-do: Menu.GameMessage
            return LogMessage.Show(afArg1, afArg2, afArg3, afArg4, afArg5, afArg6, afArg7, afArg8, afArg9)
        endIf
    endIf
    return 0
EndFunction

Bool Function ExteriorHasKeyWordInList(Location[] ExteriorLocation, FormList KeyWordList)
	int i = 0
	while i < ExteriorLocation.Length
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
	Int KeyWordListIndex = KeyWordList.GetSize()	
	While KeyWordListIndex
		KeyWordListIndex -= 1
		If CurrentLocation.HasKeyWord(KeyWordList.GetAt(KeyWordListIndex) As KeyWord)
			Return True
		EndIf		
	EndWhile
	Return False
EndFunction