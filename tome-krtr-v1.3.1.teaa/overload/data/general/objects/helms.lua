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
	define_as = "BASE_HELM",
	slot = "HEAD",
	type = "armor", subtype="head",
	add_name = " (#ARMOR#)",
	display = "]", color=colors.SLATE, image = resolvers.image_material("helm", "metal"),
	moddable_tile = resolvers.moddable_tile("helm"),
	require = { talent = { Talents.T_ARMOUR_TRAINING }, },
	encumber = 3,
	rarity = 7,
	metallic = true,
	desc = [[머리 전체를 보호할 수 있는 큰 투구입니다. 뭐, 환기와 시야 방해 문제가 있지만 말이죠.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/helm.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_HELM",
	name = "iron helm", short_name = "iron",
	kr_name = "무쇠 투구",
	level_range = {1, 20},
	cost = 5,
	material_level = 1,
	wielder = {
		combat_armor = 3,
		fatigue = 5,
	},
}

newEntity{ base = "BASE_HELM",
	name = "dwarven-steel helm", short_name = "d.steel",
	kr_name = "드워프강철 투구",
	level_range = {20, 40},
	cost = 7,
	material_level = 3,
	wielder = {
		combat_armor = 4,
		fatigue = 4,
	},
}

newEntity{ base = "BASE_HELM",
	name = "voratun helm", short_name = "voratun",
	kr_name = "보라툰 투구",
	level_range = {40, 50},
	cost = 10,
	material_level = 5,
	wielder = {
		combat_armor = 5,
		fatigue = 5,
	},
}
