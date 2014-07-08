-- ToME - Tales of Maj'Eyal
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

local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_SLING",
	slot = "MAINHAND",
	type = "weapon", subtype="sling",
	display = "}", color=colors.UMBER, image = resolvers.image_material("sling", "leather"),
	moddable_tile = resolvers.moddable_tile("sling"),
	encumber = 4,
	rarity = 7,
	combat = { talented = "sling", accuracy_effect = "mace", sound = "actions/sling", sound_miss = "actions/sling", },
	archery_kind = "sling",
	archery = "sling",
	require = { talent = { Talents.T_SHOOT }, },
	proj_image = resolvers.image_material("shot_s", "metal"),
	desc = [[투석구는 돌이나 금속을 적에게 세게 던지는데 사용합니다.]],
	randart_able = "/data/general/objects/random-artifacts/ranged.lua",
	egos = "/data/general/objects/egos/sling.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_SLING",
	name = "rough leather sling", short_name = "rough",
	kr_name = "거친가죽 투석구",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		range = 6,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "cured leather sling", short_name = "cured",
	kr_name = "가공가죽 투석구",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		range = 7,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "hardened leather sling", short_name = "hardened",
	kr_name = "경화가죽 투석구",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		range = 8,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "reinforced leather sling", short_name = "reinforced",
	kr_name = "강화가죽 투석구",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		range = 9,
		physspeed = 0.8,
	},
}

newEntity{ base = "BASE_SLING",
	name = "drakeskin leather sling", short_name = "drakeskin",
	kr_name = "용가죽 투석구",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		range = 10,
		physspeed = 0.8,
	},
}

------------------ AMMO -------------------

newEntity{
	define_as = "BASE_SHOT",
	slot = "QUIVER",
	moddable_tile = "shotbag",
	type = "ammo", subtype="shot",
	add_name = " (#COMBAT_AMMO#)",
	display = "{", color=colors.UMBER, image = resolvers.image_material("shot", "metal"),
	encumber = 3,
	rarity = 7,
	combat = { talented = "sling", accuracy_effect = "mace", damrange = 1.2},
	proj_image = resolvers.image_material("shot_s", "metal"),
	archery_ammo = "sling",
	desc = [[투석은 투석구에 재어 적을 죽이기위해 사용합니다.]],
	randart_able = "/data/general/objects/random-artifacts/ammo.lua",
	egos = "/data/general/objects/egos/ammo.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
	resolvers.shooter_capacity(),
}

newEntity{ base = "BASE_SHOT",
	name = "pouch of iron shots", short_name = "iron",
	kr_name = "무쇠 투석뭉치",
	level_range = {1, 10},
	require = { stat = { dex=11 }, },
	cost = 2,
	material_level = 1,
	combat = {
		capacity = resolvers.rngavg(10, 25),
		dam = resolvers.rngavg(12,17),
		apr = 1,
		physcrit = 4,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "pouch of steel shots", short_name = "steel",
	kr_name = "강철 투석뭉치",
	level_range = {10, 20},
	require = { stat = { dex=16 }, },
	cost = 5,
	material_level = 2,
	combat = {
		capacity = resolvers.rngavg(12, 25),
		dam = resolvers.rngavg(17,24),
		apr = 2,
		physcrit = 4.5,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "pouch of dwarven-steel shots", short_name = "d.steel",
	kr_name = "드워프강철 투석뭉치",
	level_range = {20, 30},
	require = { stat = { dex=24 }, },
	cost = 10,
	material_level = 3,
	combat = {
		capacity = resolvers.rngavg(14, 25),
		dam = resolvers.rngavg(28,37),
		apr = 3,
		physcrit = 5,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "pouch of stralite shots", short_name = "stralite",
	kr_name = "스트라라이트 투석뭉치",
	level_range = {30, 40},
	require = { stat = { dex=35 }, },
	cost = 15,
	material_level = 4,
	combat = {
		capacity = resolvers.rngavg(16, 25),
		dam = resolvers.rngavg(40,47),
		apr = 5,
		physcrit = 5.5,
		dammod = {dex=0.7, cun=0.5},
	},
}

newEntity{ base = "BASE_SHOT",
	name = "pouch of voratun shots", short_name = "voratun",
	kr_name = "보라툰 투석뭉치",
	level_range = {40, 50},
	require = { stat = { dex=48 }, },
	cost = 25,
	material_level = 5,
	combat = {
		capacity = resolvers.rngavg(18, 25),
		dam = resolvers.rngavg(50, 57),
		apr = 6,
		physcrit = 7,
		dammod = {dex=0.7, cun=0.5},
	},
}
