Scriptname mzinFilthyOverlay extends ActiveMagicEffect  

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Debug.Trace("Mzin: FilthyOverlay OnEffectStart")
	; this script is unused. Supposedly, we apply a new texture set of four dds files specific to Filth.

	;String TextureToApply = "FilthFX.dds"
	;Util.ClearDirt(akTarget)
	;Util.BeginOverlay(akTarget, TextureToApply, 1.0)
	;Util.SendAlphaUpdateEvent(akTarget)
EndEvent

mzinOverlayUtility Property Util Auto
mzinBatheMCMMenu Property Menu Auto
