-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local Talents = require("engine.interface.ActorTalents")
local Stats = require("engine.interface.ActorStats")
local DamageType = require "engine.DamageType"

-------------------------------------------------------
-- Techniques------------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {technique=true},
	name = "mighty ", prefix=true, instant_resolve=true,
	kr_display_name = "강력한 ",
	keywords = {mighty=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		combat_dam = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(6, 1),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "ranger's ", prefix=true, instant_resolve=true,
	kr_display_name = "순찰대 ",
	keywords = {ranger=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 1),
		},
	},
	resolvers.generic(function(e)
		e.combat.range = math.min(e.combat.range + 1, 10)
	end),
}

newEntity{
	power_source = {technique=true},
	name = "steady ", prefix=true, instant_resolve=true,
	kr_display_name = "정밀한 ",
	keywords = {steady=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 15,
	wielder={
		combat_atk = resolvers.mbonus_material(10, 5),
		talent_cd_reduction={[Talents.T_STEADY_SHOT]=1},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of power", suffix=true, instant_resolve=true,
	kr_display_name = "세력의 ",
	keywords = {power=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(14, 8), },
		resists_pen={ [DamageType.PHYSICAL] = resolvers.mbonus_material(14, 8), },
	},
}

-- Greater 
newEntity{
	power_source = {technique=true},
	name = "swiftstrike ", prefix=true, instant_resolve=true,
	kr_display_name = "빠른공격 ",
	keywords = {swiftstrike=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 30,
	combat = {
		physspeed = -0.1,
		travel_speed = 2,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of true flight", suffix=true, instant_resolve=true,
	kr_display_name = "참비행의 ",
	keywords = {flight=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.generic(function(e)
		e.combat.range = math.min(e.combat.range + 1, 10)
	end),
	wielder = {
		combat_atk = resolvers.mbonus_material(10, 5),
		combat_physcrit = resolvers.mbonus_material(10, 5),
	},
}

-------------------------------------------------------
-- Arcane Egos-----------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {arcane=true},
	name = " of fire", suffix=true, instant_resolve=true,
	kr_display_name = "화염의 ",
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	combat = {
		ranged_project={[DamageType.FIRE] = resolvers.mbonus_material(15, 5)},
	},
	wielder = {
		inc_damage={ [DamageType.FIRE] = resolvers.mbonus_material(14, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of cold", suffix=true, instant_resolve=true,
	kr_display_name = "냉기의 ",
	keywords = {cold=true},
	level_range = {15, 50},
	rarity = 5,
	cost = 6,
	combat = {
		ranged_project={[DamageType.COLD] = resolvers.mbonus_material(15, 5)},
	},
	wielder = {
		inc_damage={ [DamageType.COLD] = resolvers.mbonus_material(14, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of acid", suffix=true, instant_resolve=true,
	kr_display_name = "산성의 ",
	keywords = {cunning=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	combat = {
		ranged_project={[DamageType.ACID] = resolvers.mbonus_material(15, 5)},
	},
	wielder = {
		inc_damage={ [DamageType.ACID] = resolvers.mbonus_material(14, 8), },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of lightning", suffix=true, instant_resolve=true,
	kr_display_name = "뇌전의 ",
	keywords = {lightning=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	combat = {
		ranged_project={[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 5)},
	},
	wielder = {
		inc_damage={ [DamageType.LIGHTNING] = resolvers.mbonus_material(14, 8), },
	},
}

-- Greater
newEntity{
	power_source = {arcane=true},
	name = "penetrating ", prefix=true, instant_resolve=true,
	kr_display_name = "관통 ",
	keywords = {penetrating=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		apr = resolvers.mbonus_material(25, 5),
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(20, 5),
		},
		damage_shield_penetrate = resolvers.mbonus_material(50, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "runic ", prefix=true, instant_resolve=true,
	kr_display_name = "룬 ",
	keywords = {runic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(6, 1),
		},
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "warden's ", prefix=true, instant_resolve=true,
	kr_display_name = "감시원 ",
	keywords = {wardens=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 1),
		},
		resists_pen = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
		inc_damage = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
		ammo_reload_speed = resolvers.mbonus_material(4, 1),
		quick_weapon_swap = 1,
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of recursion", suffix=true, instant_resolve=true,
	kr_display_name = "재귀의 ",
	keywords = {recursion=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	combat = {
		talent_on_hit = { [Talents.T_SHOOT] = {level=1, chance=10} },
		convert_damage = { [DamageType.TEMPORAL] = resolvers.mbonus_material(25, 25),}
	}
}

-------------------------------------------------------
-- Nature/Antimagic Egos:------------------------------
-------------------------------------------------------
-- **  NEED SOME LESSER ** --
newEntity{
	power_source = {nature=true},
	name = "fungal ", prefix=true, instant_resolve=true,
	kr_display_name = "균사체 ",
	keywords = {fungal=true},
	level_range = {1, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		talents_types_mastery = {
			["wild-gift/fungus"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
	charm_power = resolvers.mbonus_material(100, 5),
	charm_power_def = {add=50, max=200, floor=true},
	resolvers.charm("5턴간 생명력 %d 재생", 20,
		function(self, who)
			who:setEffect(who.EFF_REGENERATION, 5, {power=self:getCharmPower()/5})
			return {id=true, used=true}
		end
	),
}

-- Greater
newEntity{
	power_source = {nature=true},
	name = "blazebringer's ", prefix=true, instant_resolve=true,
	kr_display_name = "화염유발자 ",
	keywords = {blaze=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		global_speed_add = resolvers.mbonus_material(5, 1, function(e, v) v=v/100 return 0, v end),
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		ranged_project={
			[DamageType.FIRE] = resolvers.mbonus_material(30, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "caustic ", prefix=true, instant_resolve=true,
	kr_display_name = "부식성 ",
	keywords = {caustic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		life_regen = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		resists_pen = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		ranged_project={
			[DamageType.ACID_BLIND] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "glacial ", prefix=true, instant_resolve=true,
	kr_display_name = "차가운 ",
	keywords = {glacial=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		combat_armor = resolvers.mbonus_material(10, 5),
		resists_pen = {
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		ranged_project={
			[DamageType.ICE] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "thunderous ", prefix=true, instant_resolve=true,
	kr_display_name = "우레같은 ",
	keywords = {thunder=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 1),
		},
		resists_pen = {
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		ranged_project={
			[DamageType.LIGHTNING_DAZE] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of nature", suffix=true, instant_resolve=true,
	kr_display_name = "자연의 ",
	keywords = {nature=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		resists = { all = resolvers.mbonus_material(8, 2) },
		resists_pen = {
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		ranged_project = { 
			[DamageType.NATURE] = resolvers.mbonus_material(30, 5),
		},
	},
}

-- Antimagic
newEntity{
	power_source = {antimagic=true},
	name = " of dampening", suffix=true, instant_resolve=true,
	kr_display_name = "축축함의 ",
	keywords = {dampening=true},
	level_range = {1, 50},
	rarity = 18,
	cost = 22,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(8, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5),
		},
		combat_spellresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "mage-hunter's ", prefix=true, instant_resolve=true,
	kr_display_name = "마법사-사냥꾼 ",
	keywords = {magehunters=true},
	level_range = {30, 50},
	rarity = 18,
	cost = 22,
	greater_ego = 1,
	combat = {
		talent_on_hit = { [Talents.T_MANA_CLASH] = {level=1, chance=10} },
	},
	wielder = {
		talents_types_mastery = {
			["wild-gift/antimagic"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		ranged_project = { 
			[DamageType.MANABURN] = resolvers.mbonus_material(20, 5),
		},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "throat-seeking ", prefix=true, instant_resolve=true,
	kr_display_name = "침묵 ",
	keywords = {throat=true},
	level_range = {30, 50},
	rarity = 18,
	cost = 22,
	greater_ego = 1,
	wielder = {
		resists_pen = {
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
		},
	},
	combat = {
		ranged_project = { 
			[DamageType.NATURE] = resolvers.mbonus_material(20, 5),
		},
		special_on_crit = {desc="상대를 침묵시킴", fct=function(combat, who, target)
			if target:canBe("silence") then
				target:setEffect(target.EFF_SILENCED, 2, {apply_power=who:combatAttack(), no_ct_effect=true})
			end
		end},
	},
}


-------------------------------------------------------
-- Psionic Egos ---------------------------------------
-------------------------------------------------------
-- **  NEED SOME LESSER ** --

-- Greater
newEntity{
	power_source = {psionic=true},
	name = "psychic's ", prefix=true, instant_resolve=true,
	kr_display_name = "초능력자 ",
	keywords = {psychic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(6, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 1),
		},
	},
}
