﻿-- ToME - Tales of Maj'Eyal
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")


newEntity{
	power_source = {arcane=true},
	name = " of magic (#STATBONUS#)", suffix=true, instant_resolve=true,
	kr_display_name = "마법(#STATBONUS#)의 ",
	keywords = {magic=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {nature=true},
	name = " of willpower (#STATBONUS#)", suffix=true, instant_resolve=true,
	kr_display_name = "의지(#STATBONUS#)의 ",
	keywords = {will=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(8, 2) },
	},
}
newEntity{
	power_source = {psionic=true},
	name = " of cunning (#STATBONUS#)", suffix=true, instant_resolve=true,
	kr_display_name = "교활함(#STATBONUS#)의 ",
	keywords = {cun=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(8, 2) },
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of balance", suffix=true, instant_resolve=true,
	kr_display_name = "균형의 ",
	keywords = {balance=true},
	level_range = {10, 50},
	rarity = 10,
	cost = 20,
	wielder = {
		hate_regen_when_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
		equilibrium_regen_when_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
		psi_regen_when_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of seeing ", suffix=true, instant_resolve=true,
	kr_display_name = "관측의 ",
	keywords = {seeing=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		see_stealth = resolvers.mbonus_material(20, 5),
		see_invisible = resolvers.mbonus_material(20, 5),
		infravision=resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "augmenting ", prefix=true, instant_resolve=true,
	kr_display_name = "증대된 ",
	keywords = {augment=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 60,
	wielder = {
		inc_damage = {
			[DamageType.ACID] = resolvers.mbonus_material(7, 3),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(7, 3),
			[DamageType.FIRE] = resolvers.mbonus_material(7, 3),
			[DamageType.COLD] = resolvers.mbonus_material(7, 3),
			[DamageType.ARCANE] = resolvers.mbonus_material(7, 3),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "eldritch ", prefix=true, instant_resolve=true,
	kr_display_name = "섬뜩한 ",
	keywords = {eldritch=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 20,
	wielder = {
		max_mana = resolvers.mbonus_material(70, 40),
		mana_regen = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
		mana_regen_when_hit = resolvers.mbonus_material(23, 7, function(e, v) v=v/10 return 0, v end),
	},
	resolvers.charmt(Talents.T_MANAFLOW, {1,2}, 40),
}

newEntity{
	power_source = {antimagic=true},
	name = "cleansing ", prefix=true, instant_resolve=true,
	kr_display_name = "깨끗한 ",
	keywords = {cleanse=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 9,
	wielder = {
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	kr_display_name = "단열 ",
	keywords = {insulating=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	kr_display_name = "접지 ",
	keywords = {grounding=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of knowledge", suffix=true, instant_resolve=true,
	kr_display_name = "지식의 ",
	keywords = {knowledge=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 20,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(3, 3),
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 2),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of arcana", suffix=true, instant_resolve=true,
	kr_display_name = "마법사의 ",
	keywords = {arcana=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 20,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 2),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "aegis ", prefix=true, instant_resolve=true,
	kr_display_name = "보호 ",
	keywords = {aegis=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 30,
	wielder = {
		max_life=resolvers.mbonus_material(30, 30),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		talents_types_mastery = {
			["spell/aegis"] = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of madness", suffix=true, instant_resolve=true,
	kr_display_name = "미치광이의 ",
	keywords = {madness=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 60,
	resolvers.charmt(Talents.T_HATEFUL_WHISPER, {2,3,4}, 15),
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(9, 1),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the Brotherhood", suffix=true, instant_resolve=true,
	kr_display_name = "조합원의 ",
	keywords = {Brotherhood=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	resolvers.charmt(Talents.T_ARCANE_EYE, 5, 30),
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(9, 1),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of earthrunes", suffix=true, instant_resolve=true,
	kr_display_name = "대지의 룬의 ",
	keywords = {earthrunes=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 20,
	resolvers.charmt(Talents.T_STONE_WALL, {1,2,3}, 80),
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_armor = resolvers.mbonus_material(5, 1),
	},
}

newEntity{
	power_source = {technique=true},
	name = "stabilizing ", prefix=true, instant_resolve=true,
	kr_display_name = "안정된 ",
	keywords = {stabilize=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		combat_physresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "clarifying ", prefix=true, instant_resolve=true,
	kr_display_name = "명백한 ",
	keywords = {clarifying=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "shielding ", prefix=true, instant_resolve=true,
	kr_display_name = "보호하는 ",
	keywords = {shield=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		combat_spellresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of decomposition", suffix=true, instant_resolve=true,
	kr_display_name = "분해의 ",
	keywords = {decomp=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 60,
	wielder = {
		resists = {
			[DamageType.ACID] = resolvers.mbonus_material(7, 3),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(7, 3),
			[DamageType.FIRE] = resolvers.mbonus_material(7, 3),
			[DamageType.COLD] = resolvers.mbonus_material(7, 3),
		},
	},
}

-- Damage and Resists
newEntity{
	power_source = {nature=true},
	name = " of fire (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "화염(#RESIST#)의 ",
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.FIRE] = (e.wielder.resists[engine.DamageType.FIRE] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.FIRE]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of frost (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "냉기(#RESIST#)의 ",
	keywords = {frost=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.COLD] = (e.wielder.resists[engine.DamageType.COLD] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.COLD]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of nature (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "자연(#RESIST#)의 ",
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.NATURE] = (e.wielder.resists[engine.DamageType.NATURE] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.NATURE]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of lightning (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "전기(#RESIST#)의 ",
	keywords = {lightning=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.LIGHTNING] = (e.wielder.resists[engine.DamageType.LIGHTNING] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.LIGHTNING]*1.5) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of light (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "빛(#RESIST#)의 ",
	keywords = {light=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHT] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.LIGHT] = (e.wielder.resists[engine.DamageType.LIGHT] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.LIGHT]*1.5) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of darkness (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "어둠(#RESIST#)의 ",
	keywords = {darkness=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.DARKNESS] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.DARKNESS] = (e.wielder.resists[engine.DamageType.DARKNESS] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.DARKNESS]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of corrosion (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "부식(#RESIST#)의 ",
	keywords = {corrosion=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.ACID] = (e.wielder.resists[engine.DamageType.ACID] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.ACID]*1.5) end),
}

-- rare resists
newEntity{
	power_source = {arcane=true},
	name = " of blight (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "황폐(#RESIST#)의 ",
	keywords = {blight=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.BLIGHT] = (e.wielder.resists[engine.DamageType.BLIGHT] or 0) + (e.wielder.inc_damage[engine.DamageType.BLIGHT]) end),
}

newEntity{
	power_source = {nature=true},
	name = " of the mountain (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "산맥(#RESIST#)의 ",
	keywords = {mountain=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.PHYSICAL] = (e.wielder.resists[engine.DamageType.PHYSICAL] or 0) + (e.wielder.inc_damage[engine.DamageType.PHYSICAL]) end),
}

newEntity{
	power_source = {psionic=true},
	name = " of the mind (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "정신(#RESIST#)의 ",
	keywords = {mind=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.MIND] = (e.wielder.resists[engine.DamageType.MIND] or 0) + (e.wielder.inc_damage[engine.DamageType.MIND]) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of time (#RESIST#)", suffix=true, instant_resolve=true,
	kr_display_name = "시간(#RESIST#)의 ",
	keywords = {time=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.TEMPORAL] = (e.wielder.resists[engine.DamageType.TEMPORAL] or 0) + (e.wielder.inc_damage[engine.DamageType.TEMPORAL]) end),
}

-- Arcane Damage doesn't get resist too so we give it +mana instead
newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	kr_display_name = "어른거리는 ",
	keywords = {shimmering=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 6,
	wielder = {
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(10, 10) },
		max_mana = resolvers.mbonus_material(100, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of warding", suffix=true, instant_resolve=true,
	kr_display_name = "보호의 ",
	keywords = {warding=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 15,
	resolvers.charmt(Talents.T_CIRCLE_OF_WARDING, 3, 40),
}
newEntity{
	power_source = {psionic=true},
	name = "focusing ", prefix=true, instant_resolve=true,
	kr_display_name = "집중시키는 ",
	keywords = {focus=true},
	level_range = {15, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		psi_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
	},
}
newEntity{
	power_source = {psionic=true},
	name = "fearwoven ", prefix=true, instant_resolve=true,
	kr_display_name = "공포가 엮인 ",
	keywords = {fearwoven=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		inc_damage = {
			[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5),
		},
		max_hate = resolvers.mbonus_material(10, 5),
		combat_mindpower = resolvers.mbonus_material(5, 5),
		combat_mindcrit = resolvers.mbonus_material(4, 1),
	},	
}
newEntity{
	power_source = {psionic=true},
	name = "psion's ", prefix=true, instant_resolve=true,
	kr_display_name = "염동력자 ",
	keywords = {psion=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		inc_damage = {
			[DamageType.MIND] = resolvers.mbonus_material(15, 5),
		},
		max_psi = resolvers.mbonus_material(30, 10),
		combat_mindpower = resolvers.mbonus_material(5, 5),
		combat_mindcrit = resolvers.mbonus_material(4, 1),
	},	
}
newEntity{
	power_source = {psionic=true},
	name = "mindwoven ", prefix=true, instant_resolve=true,
	kr_display_name = "정신이 엮인 ",
	keywords = {mindwoven=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(4, 2),
		combat_mindcrit = resolvers.mbonus_material(4, 2),
	},
}
newEntity{
	power_source = {arcane=true},
	name = "spellwoven ", prefix=true, instant_resolve=true,
	kr_display_name = "주문엮인 ",
	keywords = {spellwoven=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(4, 2),
		combat_spellcrit = resolvers.mbonus_material(4, 2),
	},
}