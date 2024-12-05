Scriptname mzinFilthyOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "") == ""
		Util.ClearDirt(akTarget)
		Util.BeginOverlay(akTarget, Menu.StartingAlpha)
	EndIf
	Util.SendAlphaUpdateEvent(akTarget)
EndEvent

mzinOverlayUtility Property Util Auto
mzinBatheMCMMenu Property Menu Auto
