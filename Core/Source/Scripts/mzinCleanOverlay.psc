Scriptname mzinCleanOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Util.ClearDirt(akTarget)
	If akTarget.HasMagicEffect(mzinDirtinessTier1p5Effect)
		Util.BeginOverlay(akTarget, Menu.StartingAlpha)
	EndIf
EndEvent

mzinBatheMCMMenu Property Menu Auto
mzinOverlayUtility Property Util Auto
MagicEffect Property mzinDirtinessTier1p5Effect Auto
