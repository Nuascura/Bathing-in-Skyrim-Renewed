Scriptname mzinFilthyOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "") == "" && !akTarget.HasMagicEffect(mzinDirtinessTier1p5Effect)
		OlUtil.ApplyDirt(akTarget, Menu.StartingAlpha)
	ElseIf StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "") != ""
		OlUtil.SendAlphaUpdateEvent(akTarget)
	EndIf
EndEvent

mzinOverlayUtility Property OlUtil Auto
mzinBatheMCMMenu Property Menu Auto
MagicEffect Property mzinDirtinessTier1p5Effect Auto