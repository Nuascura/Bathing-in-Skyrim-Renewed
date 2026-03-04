Scriptname PlayerBarefootQuestScript extends Quest  

import NiOverride
import NetImmerse
import SlaveTats

PBFConfig Property Config Auto

Actor Property PlayerRef Auto
spell Property DamageSpeedSpell1 Auto
spell Property DamageSpeedSpell2 Auto
spell Property DamageSpeedSpell3 Auto
spell Property DamageSpeedSpell4 Auto

spell Property DirtyFeetSpell1 Auto
spell Property DirtyFeetSpell2 Auto
spell Property DirtyFeetSpell3 Auto
spell Property DirtyFeetSpell4 Auto
spell Property DirtyFeetSpell5 Auto

Spell Property PBFWashFeetSpell Auto

ActiveMagicEffect Property CurrentDamageSpeedEffect Auto
ActiveMagicEffect Property CurrentDamageBarterEffect Auto

GlobalVariable Property FeetDirtiness Auto
GlobalVariable Property FeetRoughness Auto
GlobalVariable Property FeetPain Auto

GlobalVariable Property StepsBarefoot Auto
GlobalVariable Property PlayerIsBarefoot Auto
GlobalVariable Property PlayerCellType Auto
GlobalVariable Property PlayerLastSurfaceType  Auto  

GlobalVariable Property PlayerLastSurfaceDirtiness  Auto  

Sound Property PainSound Auto
Sound Property PainSoundMale Auto

Keyword Property zbfWornAnkles Auto Hidden
Keyword Property zad_DeviousAnkleShackles Auto Hidden
Keyword Property SexlabNoStrip Auto Hidden

float LastUpdateTime = 0.0
Armor CurrentFootwear = None

Race Property WerewolfRace auto

Function PlayerLoadsGame()
	;UnregisterForUpdate()
	If Game.GetModByName("SexLab.esm") != 255
		SexlabNoStrip = (Game.GetFormFromFile(0x02F16E, "SexLab.esm") as Keyword)
	EndIf
	If Game.GetModByName("ZaZAnimationPack.esm") != 255
		zbfWornAnkles = (Game.GetFormFromFile(0x008A4C, "ZaZAnimationPack.esm") as Keyword)
	EndIf
	If Game.GetModByName("Devious Devices - Integration.esm") != 255
		zad_DeviousAnkleShackles = (Game.GetFormFromFile(0x05F4BB, "Devious Devices - Integration.esm") as Keyword)
	EndIf
	;RegisterForSingleUpdate(1.0)
EndFunction

; Bathing In Skyrim support: if the dirtiness percentage decreases,
; the player has bathed and so we clean their feet too.
GlobalVariable Property DirtinessPercentage Auto
Bool BISLoaded = False
Float LastDirtinessPercentage = 0.0

Function DetectBIS()
	if Game.GetModByName("Bathing in Skyrim.esp") != 255
		BISLoaded = True
		DirtinessPercentage = (Game.GetFormFromFile(0x00000DA8, "Bathing in Skyrim.esp") as GlobalVariable)
	endif
EndFunction

; 0: owned interior (clean)
; 1: owned interior (jail/mine/cave)
; 2: city (skydome)
; 3: unowned interior
; 4: wilderness
Int Function GetCurrentLocationType()
	if (Weather.GetSkyMode() == 2)
		PlayerCellType.SetValue(2)
		return 2
	elseif (Weather.GetSkyMode() == 3)
		PlayerCellType.SetValue(4)
		return 4
	endif

	if (PlayerRef.GetParentCell().GetActorOwner() == None && PlayerRef.GetParentCell().GetFactionOwner() == None)
		PlayerCellType.SetValue(3)
		return 3
	else
		String CellName = PlayerRef.GetParentCell().GetName()
		if (StringUtil.Find(CellName, " Mine") != -1 || StringUtil.Find(CellName, " Dungeon") != -1 || StringUtil.Find(CellName, " Jail") != -1)
			PlayerCellType.SetValue(1)
			return 1
		else
			PlayerCellType.SetValue(0)
			return 0
		endif
	endif
EndFunction

Event OnInit()
	Game.GetPlayer().AddSpell(PBFWashFeetSpell)
	DetectBIS()
	LastUpdateTime = Utility.GetCurrentGameTime()
	RegisterForUpdate(1)
	GoToState("Shod")
EndEvent

Int Function GetDirtinessTier(float dirty)
	if (dirty <= 0.03)
		return -1 ;None
	elseif (dirty <= 0.1)
		return 0 ;Light
	elseif (dirty <= 0.3)
		return 1 ;Medium
	elseif(dirty <= 0.9)
		return 2 ;Heavy
	else
		return 3 ;Extreme
	endif
EndFunction

Int Function GetPainTier(float pain)
	int result = (pain / 0.25) as int
	if (result >= 4)
		result = 3
	endif
	return result
EndFunction

Bool Function IsPlayerBarefoot()
	Armor boots = PlayerRef.GetWornForm(0x00000080) as Armor
	return (boots == None || boots == Config.BarefootFootwearException) && PlayerRef.GetActorBase().GetRace() != WerewolfRace
EndFunction

Function UpdateTattoo(int tier)
	
	int template = JValue.retain(JMap.object())
	JMap.setStr(template, "texture", "BarefootRealism\\barefoot_*")

	remove_tattoos(PlayerRef, template, true, false)

	if (tier != -1)
		JMap.setStr(template, "texture", "BarefootRealism\\barefoot_*")
	
		int tattoo = JValue.retain(JArray.object())
		query_available_tattoos(template, tattoo)
		add_tattoo(PlayerRef, JArray.GetObj(tattoo, 3 - tier))

		JValue.release(tattoo)
	endif
	
	synchronize_tattoos(PlayerRef, silent=True)
	JValue.release(template)
EndFunction

Spell Function ClearDirtinessSpells()
	PlayerRef.RemoveSpell(DirtyFeetSpell1)
	PlayerRef.RemoveSpell(DirtyFeetSpell2)
	PlayerRef.RemoveSpell(DirtyFeetSpell3)
	PlayerRef.RemoveSpell(DirtyFeetSpell4)
	PlayerRef.RemoveSpell(DirtyFeetSpell5)
EndFunction

Spell Function ClearPainSpells()
	PlayerRef.RemoveSpell(DamageSpeedSpell1)
	PlayerRef.RemoveSpell(DamageSpeedSpell2)
	PlayerRef.RemoveSpell(DamageSpeedSpell3)
	PlayerRef.RemoveSpell(DamageSpeedSpell4)
EndFunction

Spell Function GetDirtinessSpell(Int tier)
	if (tier == -1)
		return DirtyFeetSpell1
	elseif (tier == 0)
		return DirtyFeetSpell2
	elseif (tier == 1)
		return DirtyFeetSpell3
	elseif (tier == 2)
		return DirtyFeetSpell4
	else
		return DirtyFeetSpell5
	endif
EndFunction

Spell Function GetPainSpell(Int tier)
	if (tier == 0)
		return DamageSpeedSpell1
	elseif (tier == 1)
		return DamageSpeedSpell2
	elseif (tier == 2)
		return DamageSpeedSpell3
	else
		return DamageSpeedSpell4
	endif
EndFunction

Function SynchronizeSpells()
	; A bit hacky. Use the current effect's magnitude to find out which tier it is;
	; if the tiers don't match, then remove the current spell and apply the new one.
	if (PlayerIsBarefoot.GetValue() == 0)
		return
	endif

	int currentSpeedTier
	if CurrentDamageSpeedEffect == None
		currentSpeedTier = 0
	elseif CurrentDamageSpeedEffect.GetMagnitude() == -20.0
		currentSpeedTier = 1
	elseif CurrentDamageSpeedEffect.GetMagnitude() == -40.0
		currentSpeedTier = 2
	elseif CurrentDamageSpeedEffect.GetMagnitude() == -60.0
		currentSpeedTier = 3
	endif
	
	If !Config.SpeedDamageSpells
		if currentSpeedTier != 0
			ClearPainSpells()
		endif
	Else
		int requiredSpeedTier = GetPainTier(FeetPain.GetValue())
		if requiredSpeedTier != currentSpeedTier
			ClearPainSpells()
			PlayerRef.AddSpell(GetPainSpell(requiredSpeedTier), Config.SpellDebug)
		endif
	EndIf
	
	int currentBarterTier
	if CurrentDamageBarterEffect == None
		currentBarterTier = -2
	elseif CurrentDamageBarterEffect.GetMagnitude() == -10.0
		currentBarterTier = -1
	elseif CurrentDamageBarterEffect.GetMagnitude() == -20.0
		currentBarterTier = 0
	elseif CurrentDamageBarterEffect.GetMagnitude() == -30.0
		currentBarterTier = 1
	elseif CurrentDamageBarterEffect.GetMagnitude() == -40.0
		currentBarterTier = 2
	elseif CurrentDamageBarterEffect.GetMagnitude() == -50.0
		currentBarterTier = 3
	endif
	
	If !Config.BarterDamageSpells
		if currentBarterTier != -2
			ClearDirtinessSpells()
		EndIf
	Else
		int requiredBarterTier = GetDirtinessTier(FeetDirtiness.GetValue())
		if requiredBarterTier != currentBarterTier
			ClearDirtinessSpells()
			PlayerRef.AddSpell(GetDirtinessSpell(requiredBarterTier), Config.SpellDebug)
		endif
	EndIf
	
EndFunction

Float Function Clamp(Float val, Float min, Float max)
	if (val < min)
		val = min
	endif
	if (val > max)
		val = max
	endif
	return val
EndFunction

Float Function GetStaggerChance()
;Stagger chance scales exponentially
;The default is set so that f completely pampered feet (toughness 0) the chance is 10% (once every 10 steps, on average)
;For completely tough (toughness 1) the chance is 0.1%
	float base = Config.StaggerMultiplier * Math.pow(2.71828, Config.StaggerExponent * FeetRoughness.GetValue())
	; Base is calculated for running, for sprinting/walking/sneaking the values are scaled
	
	if (PlayerRef.IsSprinting())
		base *= Config.SprintingStaggerModifier
	elseif (!PlayerRef.IsRunning())
		base *= Config.WalkingStaggerModifier
	elseif (PlayerRef.IsSneaking())
		base *= Config.SneakingStaggerModifier
	endif

	; Also scale by the "roughness coefficient" inferred from the cell type and the surface roughness
	Int PlaceType = GetCurrentLocationType()
	Int SurfaceType = PlayerLastSurfaceType.GetValueInt()
	;Debug.Trace("PBF: PlaceType: " + PlaceType + ". SurfaceType: " + SurfaceType)
	base *= Config.LocationRoughness[PlaceType] * Config.SurfaceRoughness[SurfaceType]
	
	return base
EndFunction

Float Function GetCurrentDirtinessRate()
; How quickly do the player's feet get dirty (score per step)
	Int PlaceType = GetCurrentLocationType()
	int SurfaceType = PlayerLastSurfaceType.GetValueInt()

	if (SurfaceType == -1)
		SurfaceType = 0
	endif

	float surfaceDirtiness = Config.SurfaceDirtiness[SurfaceType]
	; Exterior and is raining: wet feet (TODO: separate magic effect?)
	if ((Weather.GetSkyMode() == 2 || Weather.GetSkyMode() == 3) && Weather.GetCurrentWeather().GetClassification() == 2)
		surfaceDirtiness = surfaceDirtiness * 2
	endif

	float target = surfaceDirtiness * Config.LocationDirtiness[PlaceType]
	PlayerLastSurfaceDirtiness.SetValue(target)
	float delta = target - FeetDirtiness.GetValue() 
	if (delta > 0)
		return Config.PositiveDeltaDirtinessMultiplier * delta
	else
		return Config.NegativeDeltaDirtinessMultiplier * delta
	endif
EndFunction

Float Function GetCurrentPainRate()
	int SurfaceType = PlayerLastSurfaceType.GetValueInt()

	if (SurfaceType == -1)
		SurfaceType = 0
	endif
	
	Int PlaceType = GetCurrentLocationType()
	
	; This might be a bit overengineered. The idea is that the pain increase dramatically decreases when feet roughness
	; is greater than the total surface roughness. Let's say the feet roughness is 0 and the player is walking around Whiterun
	; (location roughness 1.0, surface roughness 0.4 for a total of 0.4). Then, with the default settings, the pain increase 
	; is 0.01 * (0.4 / (0 + 1)) ^ 4 = 0.000256 per step or 0.256 per thousand steps (will take a whole day to clear).
	; If the roughness is 0.4, we get 0.01 * (0.4 / 1.4)^4; 0.067 per thousand steps, about 6 hours to clear.
	; If the roughness is 1, we get 0.016, about 1.5 hours to clear.
	; TODO perhaps come up with something simpler.
	float score = Config.LocationRoughness[PlaceType] * Config.SurfaceRoughness[SurfaceType] / (FeetRoughness.GetValue() + 1)
	return Config.PainIncreaseMul * Math.Pow(score, Config.PainIncreaseExp)
EndFunction	

Function CleanFeet()
	UpdateTattoo(-1)
	ClearDirtinessSpells()
	FeetDirtiness.SetValue(0)
	PlayerRef.AddSpell(GetDirtinessSpell(-1), Config.SpellDebug)
EndFunction

Function TrackBISGlobal()
	if BISLoaded
		if LastDirtinessPercentage > DirtinessPercentage.GetValue()
			CleanFeet()
		endif
		LastDirtinessPercentage = DirtinessPercentage.GetValue()
	endif
EndFunction

Auto State Shod

Event OnUpdate()
	;/
	if zbfWornAnkles == None
		zbfWornAnkles = Keyword.GetKeyword("zbfWornAnkles")
	endif
	if zad_DeviousAnkleShackles == None
		zad_DeviousAnkleShackles = Keyword.GetKeyword("zad_DeviousAnkleShackles")
	endif
	/;
	If IsPlayerBarefoot()
		if !Config.FootwearChangeableInCombat && PlayerRef.IsInCombat()
			Debug.Notification("You can't remove footwear during combat!")
			PlayerRef.EquipItem(CurrentFootwear)
			Return
		endif
		
		if (Config.BarterDamageSpells)
			PlayerRef.AddSpell(GetDirtinessSpell(GetDirtinessTier(FeetDirtiness.GetValue())), Config.SpellDebug)
		EndIf
		if (Config.SpeedDamageSpells)
			PlayerRef.AddSpell(GetPainSpell(GetPainTier(FeetPain.GetValue())), Config.SpellDebug)
		EndIf
		
		;Register for walking animations
		RegisterForAnimationEvent(PlayerRef, "FootLeft")
		RegisterForAnimationEvent(PlayerRef, "FootRight")
		
		PlayerIsBarefoot.SetValue(1)

		GoToState("Barefoot")
	EndIf
	
	Armor boots = PlayerRef.GetWornForm(0x00000080) as Armor
	If boots != none
		If !boots.HasKeyword(SexlabNoStrip)
			if ((PlayerRef.WornHasKeyword(zbfWornAnkles) || PlayerRef.WornHasKeyword(zad_DeviousAnkleShackles)) && Config.AnkleCuffsPreventFootwear) && (!Config.AnkleCuffsAllowShoes || StringUtil.Find(boots.getname(), " Shoes") == -1)
				Debug.MessageBox("Your fetters are preventing you from wearing these boots.")
				PlayerRef.UnequipItem(boots)
			EndIf
		EndIf
	EndIf
	
	CurrentFootwear = boots

	float CurrentTime = Utility.GetCurrentGameTime()
	float TimePassed = CurrentTime - LastUpdateTime
	LastUpdateTime = CurrentTime

	FeetRoughness.SetValue(Clamp(FeetRoughness.GetValue() - TimePassed * Config.RoughnessDecay, 0, 1))
	FeetPain.SetValue(Clamp(FeetPain.GetValue() - TimePassed * Config.PainDecay, 0, 1))

	TrackBISGlobal()
	;RegisterForSingleUpdate(1.0)
EndEvent

EndState

State Barefoot

Event OnUpdate()
	;/
	if zbfWornAnkles == None
		zbfWornAnkles = Keyword.GetKeyword("zbfWornAnkles")
	endif
	if zad_DeviousAnkleShackles == None
		zad_DeviousAnkleShackles = Keyword.GetKeyword("zad_DeviousAnkleShackles")
	endif
	/;
	If !IsPlayerBarefoot()
		Armor boots = PlayerRef.GetWornForm(0x00000080) as Armor
		If PlayerRef.GetActorBase().GetRace() != WerewolfRace
			if !Config.FootwearChangeableInCombat && PlayerRef.IsInCombat()
				Debug.Notification("You can't put footwear on during combat!")
				PlayerRef.UnequipItem(boots)
				Return
			endif

			If !boots.HasKeyword(SexlabNoStrip)
				if ((PlayerRef.WornHasKeyword(zbfWornAnkles) || PlayerRef.WornHasKeyword(zad_DeviousAnkleShackles)) && Config.AnkleCuffsPreventFootwear) && (!Config.AnkleCuffsAllowShoes || StringUtil.Find(boots.getname(), " Shoes") == -1)
					Debug.MessageBox("As you try to put the boots on, you realise that you can't fit your shackled ankles into them.")
					PlayerRef.UnequipItem(boots)
					return
				EndIf
			EndIf
		EndIf
		
		CurrentFootwear = boots
		
		ClearDirtinessSpells()
		ClearPainSpells()

		UnregisterForAnimationEvent(PlayerRef, "FootLeft")
		UnregisterForAnimationEvent(PlayerRef, "FootRight")
		PlayerIsBarefoot.SetValue(0)

		GoToState("Shod")
	EndIf

	float CurrentTime = Utility.GetCurrentGameTime()
	float TimePassed = CurrentTime - LastUpdateTime
	LastUpdateTime = CurrentTime

	FeetRoughness.SetValue(Clamp(FeetRoughness.GetValue() - TimePassed * Config.RoughnessDecay, 0, 1))
	FeetPain.SetValue(Clamp(FeetPain.GetValue() - TimePassed * Config.PainDecay, 0, 1))
	
	TrackBISGlobal()
	SynchronizeSpells()
	;RegisterForSingleUpdate(1.0)
EndEvent


Event OnAnimationEvent(ObjectReference aktarg, String EventName)

		if (Utility.RandomFloat(0.0, 1.0) < GetStaggerChance())
			Debug.SendAnimationEvent(PlayerRef, "staggerStart")
			PlayerRef.CreateDetectionEvent(PlayerRef, 10)
			if Config.StaggerSound
				Int PainSoundInstance
				if PlayerRef.GetActorBase().GetSex() == 1
					PainSoundInstance = PainSound.Play(PlayerRef)
				else
					PainSoundInstance = PainSoundMale.Play(PlayerRef)
				endif
				Sound.SetInstanceVolume(PainSoundInstance, (Config.StaggerSoundVolume / 100.0))
			endif
		endif

		StepsBarefoot.SetValue(StepsBarefoot.GetValue() + 1)
	
		float OldDirtiness = FeetDirtiness.GetValue()
		float NewDirtiness = OldDirtiness + GetCurrentDirtinessRate()

		Clamp(NewDirtiness, 0, 1)
		FeetDirtiness.SetValue(NewDirtiness)
		if (GetDirtinessTier(OldDirtiness) != GetDirtinessTier(NewDirtiness))
			UpdateTattoo(GetDirtinessTier(NewDirtiness))
			ClearDirtinessSpells()
			PlayerRef.AddSpell(GetDirtinessSpell(GetDirtinessTier(NewDirtiness)), Config.SpellDebug)
		endif

		float OldPain = FeetPain.GetValue()
		float PainIncrease = GetCurrentPainRate()
		float NewPain = OldPain + PainIncrease
		
		Clamp(NewPain, 0, 1)
		FeetPain.SetValue(NewPain)
			if (GetPainTier(OldPain) != GetPainTier(NewPain))
				ClearPainSpells()
				PlayerRef.AddSpell(GetPainSpell(GetPainTier(NewPain)), Config.SpellDebug)
			endif

		float OldRoughness = FeetRoughness.GetValue()
		float NewRoughness = OldRoughness + PainIncrease * Config.RoughnessIncreaseMul

		Clamp(NewRoughness, 0, 1)
		FeetRoughness.SetValue(NewRoughness)

EndEvent

EndState