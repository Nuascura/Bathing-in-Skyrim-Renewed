Scriptname mzinCleanOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	OlUtil.ClearDirt(akTarget)
	If akTarget.HasMagicEffect(mzinDirtinessTier1p5Effect)
		OlUtil.BeginOverlay(akTarget, Menu.StartingAlpha)
	EndIf
EndEvent

mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property OlUtil Auto
MagicEffect Property mzinDirtinessTier1p5Effect Auto
