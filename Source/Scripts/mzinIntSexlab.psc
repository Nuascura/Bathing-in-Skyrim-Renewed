Scriptname mzinIntSexlab Hidden 

Actor[] Function GetSexActors(Quest SlQuest, Int tid) Global
	;(SLQuest as SexlabFramework).HookActors(tid as String)
	Return (SLQuest as SexlabFramework).GetController(tid).Positions
EndFunction

Bool Function SlIsActorActive(Quest SlQuest, Actor akTarget) Global
	Return (SLQuest as SexlabFramework).IsActorActive(akTarget)
EndFunction

Bool Function SlIsVictim(Quest SlQuest, Int tid, Actor akTarget) Global
	Return (SLQuest as SexlabFramework).IsVictim(tid, akTarget)
EndFunction

Function SlClearCum(Quest SlQuest, Actor akTarget) Global
	(SLQuest as SexlabFramework).ClearCum(akTarget)
EndFunction
