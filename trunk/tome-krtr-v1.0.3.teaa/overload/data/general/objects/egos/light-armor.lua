﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

load("/data/general/objects/egos/armor.lua")

newEntity{
	power_source = {nature=true},
	name = "troll-hide ", prefix=true, instant_resolve=true,
	kr_name = "트롤 가죽 ",
	keywords = {troll=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 12,
	cost = 14,
	wielder = {
		life_regen = resolvers.mbonus_material(60, 15, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "nimble ", prefix=true, instant_resolve=true,
	kr_name = "민첩한 ",
	keywords = {nimble=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 22,
	cost = 35,
	wielder = {
		combat_def_ranged = resolvers.mbonus_material(8, 2),
		movement_speed = 0.1,
		inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(3, 2), },
	},
}
newEntity{
	power_source = {technique=true},
	name = "marauder's ", prefix=true, instant_resolve=true,
	kr_name = "약탈자 ",
	keywords = {marauder=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_DEX] = resolvers.mbonus_material(7, 3),
		},
		combat_def = resolvers.mbonus_material(8, 2),
		combat_physresist = resolvers.mbonus_material(15, 5),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the sky", suffix=true, instant_resolve=true,
	kr_name = "창공의 ",
	keywords = {sky=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 35,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 10),
			[DamageType.COLD] = resolvers.mbonus_material(20, 10),
		},
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(6, 2),
		},
		combat_def = resolvers.mbonus_material(8, 2),
		combat_def_ranged = resolvers.mbonus_material(8, 2),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of Toknor", suffix=true, instant_resolve=true,
	kr_name = "토크놀의 ",
	keywords = {toknor=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 30,
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5),
		combat_physcrit = resolvers.mbonus_material(3, 3),
		combat_critical_power = resolvers.mbonus_material(10, 10),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the wind", suffix=true, instant_resolve=true,
	kr_name = "바람의 ",
	keywords = {wind=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	resolvers.charmt(Talents.T_SECOND_WIND, {3,4,5}, 35),
	wielder = {
		max_life = resolvers.mbonus_material(60, 40, function(e, v) return 0, -v end),
		combat_armor = resolvers.mbonus_material(7, 3, function(e, v) return 0, -v end),

		combat_physcrit = resolvers.mbonus_material(7, 3),
		combat_apr = resolvers.mbonus_material(15, 5),
		combat_def = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {nature=true},
	name = "multi-hued ", prefix=true, instant_resolve=true,
	kr_name = "무지개빛 ",
	keywords = {multihued=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 29,
	cost = 47,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(8, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5),
		},
		on_melee_hit={
			[DamageType.ACID] = resolvers.mbonus_material(8, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "caller's ", prefix=true, instant_resolve=true,
	kr_name = "선도자 ",
	keywords = {callers=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 29,
	cost = 47,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(8, 5),
			[DamageType.COLD] = resolvers.mbonus_material(8, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 5),
		},
		comnbat_mindpower = resolvers.mbonus_material(10, 5),
	},
}

