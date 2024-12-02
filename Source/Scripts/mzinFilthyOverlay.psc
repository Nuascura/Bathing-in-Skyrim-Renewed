Scriptname mzinFilthyOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	;String TextureToApply = "FilthFX.dds"
	;Util.ClearDirt(akTarget)
	;Util.BeginOverlay(akTarget, TextureToApply, 1.0)
	;Util.SendAlphaUpdateEvent(akTarget)
EndEvent

mzinOverlayUtility Property Util Auto
mzinBatheMCMMenu Property Menu Auto
