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

newEntity{
	power_source = {technique=true},
	name = " of the badger", suffix=true,
	kr_display_name = "오소리의 ",
	keywords = {badger=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 20,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
}

newEntity{
	power_source = {technique=true},
	name = " of strength", suffix=true, instant_resolve=true,
	kr_display_name = "힘의 ",
	keywords = {strength=true},
	level_range = {10, 50},
	rarity = 6,
	cost = 10,
	wielder = {
		inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(4, 1) },
	},
}

newEntity{
	power_source = {technique=true},
	name = " of delving", suffix=true, instant_resolve=true,
	kr_display_name = "탐구의 ",
	keywords = {delving=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 20,
	wielder = {
		lite = 1,
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 1),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of endurance", suffix=true, instant_resolve=true,
	keywords = {endurance=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "miner's ", prefix=true, instant_resolve=true,
	kr_display_name = "광부 ",
	keywords = {miner=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		infravision = resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {nature=true},
	name = "woodsman's ", prefix=true, instant_resolve=true,
	kr_display_name = "나무꾼 ",
	keywords = {woodsman=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists = { [DamageType.NATURE] = resolvers.mbonus_material(5, 10), },
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the Iron Throne", suffix=true, instant_resolve=true,
	kr_display_name = "철의 왕좌의 ",
	keywords = {['iron.throne']=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		max_life = resolvers.mbonus_material(20, 20),
		max_stamina = resolvers.mbonus_material(15, 15),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {technique=true},
	name = " of Reknor", suffix=true, instant_resolve=true,
	kr_display_name = "레크놀의 ",
	keywords = {reknor=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(5, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(5, 5),
		},
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {technique=true},
	name = "brutal ", prefix=true, instant_resolve=true,
	kr_display_name = "잔인한 ",
	keywords = {brutal=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 70,
	wielder = {
		combat_dam = resolvers.mbonus_material(5, 5),
		combat_apr = resolvers.mbonus_material(4, 4),
		combat_critical_power = resolvers.mbonus_material(10, 10),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {psionic=true},
	name = "dream-smith's ", prefix=true, instant_resolve=true,
	kr_display_name = "꿈의연마 ",
	keywords = {smiths=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		melee_project={
			[DamageType.DREAMFORGE] = resolvers.mbonus_material(10, 5),
		},
		combat_mentalresist = resolvers.mbonus_material(5, 5),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {technique=true},
	name = "soldier's ", prefix=true, instant_resolve=true,
	kr_display_name = "병사 ",
	keywords = {soldier=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 15,
	wielder = {
		combat_def = resolvers.mbonus_material(4, 4),
		combat_armor = resolvers.mbonus_material(3, 2),
	},
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
}

newEntity{
	power_source = {arcane=true},
	name = "bloodhexed ", prefix=true, instant_resolve=true,
	kr_display_name = "피의매혹 ",
	keywords = {bloodhexed=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(7, 3),
		},
		combat_physcrit = resolvers.mbonus_material(5, 1),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "crystalomancer's ", prefix=true, instant_resolve=true,
	kr_display_name = "수정술사 ",
	keywords = {crystal=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		max_mana = resolvers.mbonus_material(40, 20),
		combat_spellcrit = resolvers.mbonus_material(4, 1),
	},
}

newEntity{
	power_source = {technique=true},
	name = "shattering ", prefix=true, instant_resolve=true,
	kr_display_name = "분쇄 ",
	keywords = {shattering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 3) end),
	wielder = {
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "sapper's ", prefix=true, instant_resolve=true,
	kr_display_name = "공병 ",
	keywords = {sapper=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		combat_atk = resolvers.mbonus_material(7, 3),
		infravision = resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {nature=true},
	name = "dwarven ", prefix=true, instant_resolve=true,
	kr_display_name = "드워프 ",
	keywords = {dwarven=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(7, 3),
		combat_physresist = resolvers.mbonus_material(7, 3),
		combat_spellresist = resolvers.mbonus_material(7, 3),
		max_life = resolvers.mbonus_material(70, 40),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of quickening", suffix=true, instant_resolve=true,
	kr_display_name = "활발함의 ",
	keywords = {quickening=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		spell_cooldown_reduction = 0.1,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of predation", suffix=true, instant_resolve=true,
	kr_display_name = "포식의 ",
	keywords = {predation=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 1),
		},
		combat_dam = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of deeplife", suffix=true, instant_resolve=true,
	kr_display_name = "심연생활의 ",
	keywords = {deeplife=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		infravision = resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of wreckage", suffix=true, instant_resolve=true,
	kr_display_name = "잔해의 ",
	keywords = {wreckage=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	resolvers.charmt(Talents.T_PERFECT_STRIKE, {2,3,4}, 26),
	resolvers.generic(function(e) e.digspeed = math.ceil(e.digspeed / 2) end),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 1),
		},
		combat_apr = resolvers.mbonus_material(10, 5),
	},
}
