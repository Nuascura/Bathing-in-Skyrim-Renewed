Scriptname mzinDirtyOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "") == ""
		OlUtil.ClearDirt(akTarget)
		OlUtil.BeginOverlay(akTarget, Menu.StartingAlpha)
	EndIf
	OlUtil.SendAlphaUpdateEvent(akTarget)
EndEvent

mzinOverlayUtility Property OlUtil Auto
mzinBatheMCMMenu Property Menu Auto
