﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	power_source = {technique=true},
	name = "bright ", prefix=true, instant_resolve=true,
	kr_name = "밝은 ",
	keywords = {bright=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 1,
	wielder = {
		lite=resolvers.mbonus_material(3, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the sun", suffix=true, instant_resolve=true,
	kr_name = "태양의 ",
	keywords = {sun=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	resolvers.charmt(Talents.T_SUN_FLARE, 3, 30),
	wielder = {
		inc_damage={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
		},
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		lite=resolvers.mbonus_material(2, 1),
		damage_affinity = { [DamageType.LIGHT] = 5 },
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the moons", suffix=true, instant_resolve=true,
	kr_name = "달의 ",
	keywords = {moons=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	resolvers.charmt(Talents.T_MOONLIGHT_RAY, 4, 8),
	wielder = {
		inc_damage={
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
		},
		infravision=resolvers.mbonus_material(3, 2),
		damage_affinity = { [DamageType.DARKNESS] = 5 },
	},
}

newEntity{
	power_source = {arcane=true},
	name = "scorching ", prefix=true, instant_resolve=true,
	kr_name = "뜨거운 ",
	keywords = {scorching=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus_material(20, 10)},
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(5, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "burglar's ", prefix=true, instant_resolve=true,
	kr_name = "강도의 ",
	keywords = {burglar=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 20,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(8, 3),
		},
		lite = -10,
		infravision = resolvers.mbonus_material(5, 4),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	kr_name = "명석함의 ",
	keywords = {clarity=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		see_stealth = resolvers.mbonus_material(20, 5),
		see_invisible = resolvers.mbonus_material(20, 5),
		trap_detect_power = resolvers.mbonus_material(15, 10),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of health", suffix=true, instant_resolve=true,
	kr_name = "생명력의 ",
	keywords = {health=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 10,
	wielder = {
		max_life=resolvers.mbonus_material(40, 40),
	},
}

newEntity{
	power_source = {nature=true},
	name = "survivor's ", prefix=true, instant_resolve=true,
	kr_name = "생존자 ",
	keywords = {survivor=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 12,
	wielder = {
		combat_physresist = resolvers.mbonus_material(10, 5),		
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "preserving ", prefix=true, instant_resolve=true,
	kr_name = "지키는 ",
	keywords = {preserve=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 20,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		life_regen = resolvers.mbonus_material(54, 11, function(e, v) v=v/10 return 0, v end),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "piercing ", prefix=true, instant_resolve=true,
	kr_name = "관통 ",
	keywords = {piercing=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		combat_apr = resolvers.mbonus_material(10, 5),
		resists_pen = { 
			all = resolvers.mbonus_material(10, 5),
		},
		lite = resolvers.mbonus_material(1, 1),
	},	
}

newEntity{
	power_source = {psionic=true},
	name = "dreamer's ", prefix=true, instant_resolve=true,
	kr_name = "몽상가 ",
	keywords = {guide=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 50,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 4),
		combat_mindpower = resolvers.mbonus_material(8, 4),
		combat_mindcrit = resolvers.mbonus_material(8, 4),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "void-walker's ", prefix=true, instant_resolve=true,
	kr_name = "공허를 걷는 ",
	keywords = {void=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 50,
	wielder = {
		resist_all_on_teleport = resolvers.mbonus_material(10, 10),
		defense_on_teleport = resolvers.mbonus_material(10, 10),
		effect_reduction_on_teleport = resolvers.mbonus_material(20, 10),
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(5, 5),
			[DamageType.TEMPORAL] = resolvers.mbonus_material(5, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "nightwalker's ", prefix=true, instant_resolve=true,
	kr_name = "밤에 걷는 ",
	keywords = {nightwalker=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 50,
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5),
		combat_physcrit = resolvers.mbonus_material(3, 3),
		combat_critical_power = resolvers.mbonus_material(10, 10),
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 3),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of illusion", suffix=true, instant_resolve=true,
	kr_name = "환상의 ",
	keywords = {illusion=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 50,
	wielder = {
		combat_def = resolvers.mbonus_material(10, 5),
		combat_mentalresist = resolvers.mbonus_material(10, 10),
		combat_physresist = resolvers.mbonus_material(10, 10),
		combat_spellresist = resolvers.mbonus_material(10, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of corpselight", suffix=true, instant_resolve=true,
	kr_name = "시쳇빛의 ",
	keywords = {corpselight=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 50,
	resolvers.charmt(Talents.T_RETCH, {1,2}, 30),
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
		combat_spellcrit = resolvers.mbonus_material(3, 3),
		see_invisible = resolvers.mbonus_material(10, 5),
		infravision = resolvers.mbonus_material(3, 3),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		undead = 1,
		no_breath = 1,
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of the zealot", suffix=true, instant_resolve=true,
	kr_name = "광신도의 ",
	keywords = {zealot=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 10,
	wielder = {
		combat_spellresist = resolvers.mbonus_material(10, 5),
		resists={
			all = 3
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of focus", suffix=true, instant_resolve=true,
	kr_name = "집중력의 ",
	keywords = {focus=true},
	level_range = {1, 50},
	rarity = 15,
	cost = 10,
	wielder = {
		inc_damage = {
			[DamageType.MIND] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 3),
		},
	},	
}

newEntity{
	power_source = {arcane=true},
	name = "ethereal ", prefix=true, instant_resolve=true,
	kr_name = "에테르 ",
	keywords = {ethereal=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 50,
	encumber = -1,
	wielder = {
		lite = 2,
		combat_spellpower = resolvers.mbonus_material(12, 5),
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 3),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "watchleader's ", prefix=true, instant_resolve=true,
	kr_name = "감시통솔자 ",
	keywords = {watchleader=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	resolvers.charmt(Talents.T_TRACK, {2,3,4,5}, 40),
	wielder = {
		lite = resolvers.mbonus_material(3, 3),
		blind_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
		confusion_immune = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		see_stealth = resolvers.mbonus_material(20, 5),
		see_invisible = resolvers.mbonus_material(20, 5),
		trap_detect_power = resolvers.mbonus_material(15, 10),
	},
}