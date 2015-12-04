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

newEntity{
	define_as = "BASE_BATTLEAXE",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="battleaxe", image = resolvers.image_material("2haxe", "metal"),
	moddable_tile = resolvers.moddable_tile("2haxe"),
	add_name = " (#COMBAT#)",
	display = "/", color=colors.SLATE,
	encumber = 3,
	rarity = 5,
	metallic = true,
	combat = { talented = "axe", damrange = 1.5, physspeed = 1, sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2} },
	desc = [[거대한 양손용 전투 도끼입니다.]],
	twohanded = true,
	ego_bonus_mult = 0.4,
	randart_able = "/data/general/objects/random-artifacts/melee.lua",
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "iron battleaxe", short_name = "iron",
	kr_name = "무쇠 대형도끼",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	material_level = 1,
	combat = {
		dam = resolvers.rngavg(11,17),
		apr = 1,
		physcrit = 4.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "steel battleaxe", short_name = "steel",
	kr_name = "강철 대형도끼",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	material_level = 2,
	combat = {
		dam = resolvers.rngavg(17,25),
		apr = 2,
		physcrit = 5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "dwarven-steel battleaxe", short_name = "d.steel",
	kr_name = "드워프강철 대형도끼",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	material_level = 3,
	combat = {
		dam = resolvers.rngavg(28,35),
		apr = 2,
		physcrit = 6.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "stralite battleaxe", short_name = "stralite",
	kr_name = "스트라라이트 대형도끼",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	material_level = 4,
	combat = {
		dam = resolvers.rngavg(40,48),
		apr = 3,
		physcrit = 7.5,
		dammod = {str=1.2},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	name = "voratun battleaxe", short_name = "voratun",
	kr_name = "보라툰 대형도끼",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	material_level = 5,
	combat = {
		dam = resolvers.rngavg(54, 60),
		apr = 4,
		physcrit = 8,
		dammod = {str=1.2},
	},
}
