Scriptname mzinDirtyOverlayLeadIn extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
    OlUtil.ClearDirt(akTarget)
	If StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "") == ""
		OlUtil.BeginOverlay(akTarget, Menu.StartingAlpha, Menu.OverlayTint)
	EndIf
    OlUtil.SendAlphaUpdateEvent(akTarget)
EndEvent

mzinOverlayUtility Property OlUtil Auto
mzinBatheMCMMenu Property Menu Auto
