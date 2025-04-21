Scriptname mzinInterfaceSexLab

Actor[] Function GetSexActors(Quest SlQuest, Int tid) Global
	if SlQuest
		Return (SLQuest as SexlabFramework).GetController(tid).Positions
	endIf
	Return (new Actor[1])
EndFunction

Bool Function IsActorActive(Quest SlQuest, Actor akTarget) Global
	if SlQuest
		Return (SLQuest as SexlabFramework).IsActorActive(akTarget)
	endIf
	Return false
EndFunction

Bool Function IsVictim(Quest SlQuest, Int tid, Actor akTarget) Global
	if SlQuest
		Return (SLQuest as SexlabFramework).IsVictim(tid, akTarget)
	endIf
	Return False
EndFunction

Function ClearCum(Quest SlQuest, Actor akTarget) Global
	if SlQuest
		(SLQuest as SexlabFramework).ClearCum(akTarget)
	endIf
EndFunction