Scriptname mzinAnimationActorGuard extends activemagiceffect  

Event OnEffectStart(Actor Target, Actor Caster)
	Utility.Wait(2.0)
	Target.RemoveSpell(PlayBathingAnimation)
EndEvent

Spell Property PlayBathingAnimation Auto