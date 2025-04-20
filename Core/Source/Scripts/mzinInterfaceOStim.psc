Scriptname mzinInterfaceOStim

Actor[] Function GetActors(Int tid) Global
    return OThread.GetActors(tid)
EndFunction

Float Function GetExcitementPercentage(Actor act) Global
    return OActor.GetExcitement(act) / 100
EndFunction

Bool Function IsActorActive(Actor act) Global
    return OActor.IsInOStim(act)
EndFunction

Bool Function IsActorVictim(Actor act, Int tid) Global
    return IsSceneAggressive(tid) && !OMetadata.HasActorTag(OThread.GetScene(tid), OThread.GetActorPosition(tid, act), "dominant")
EndFunction

Bool Function IsSceneAggressive(Int tid) Global
    String SceneID = OThread.GetScene(tid)
    int i = OMetadata.GetActorCount(SceneID)
    While i
        i -= 1
        If OMetadata.HasActorTag(SceneID, i, "dominant")
            Return true
        EndIf
    EndWhile
    Return false
EndFunction

Bool Function IsSceneSexual(String sid) Global
    return OMetadata.HasActionTagOnAny(sid, "sexual")
EndFunction

Bool Function IsSceneTransition(String sid) Global
    return OMetadata.IsTransition(sid)
EndFunction