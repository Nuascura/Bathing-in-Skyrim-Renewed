Scriptname mzinCleanOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	If StorageUtil.GetStringValue(akTarget, "mzin_DirtTexturePrefix", "") != "" && !akTarget.HasMagicEffect(mzinDirtinessTier1p5Effect)
		OlUtil.ClearDirt(akTarget)
	ElseIf akTarget.HasMagicEffect(mzinDirtinessTier1p5Effect)
		OlUtil.SendAlphaUpdateEvent(akTarget)
	EndIf
EndEvent

mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto
MagicEffect Property mzinDirtinessTier1p5Effect Auto
