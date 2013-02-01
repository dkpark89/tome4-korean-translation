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

newEntity{
	define_as = "BASE_WAND",
	slot = "TOOL",
	type = "charm", subtype="wand",
	unided_name = "wand", id_by_type = true,
	kr_unided_name = "마법봉",
	display = "-", color=colors.WHITE, image = resolvers.image_material("wand", "wood"),
	encumber = 2,
	rarity = 12,
	add_name = "#CHARM# #CHARGES#",
	use_sound = "talents/spell_generic",
	desc = [[마법의 봉은 강력한 연금술사나 마도사가 주문을 집어넣기 위해 만듭니다. 들어있는 주문은 아무나 사용할 수 있습니다.]],
	egos = "/data/general/objects/egos/wands.lua", egos_chance = { prefix=resolvers.mbonus(20, 5), },
	addons = "/data/general/objects/egos/wands-powers.lua",
	power_source = {arcane=true},
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	talent_cooldown = "T_GLOBAL_CD",
}

newEntity{ base = "BASE_WAND",
	name = "elm wand", short_name = "elm",
	kr_display_name = "느릅나무 마법봉",
	color = colors.UMBER,
	level_range = {1, 10},
	cost = 1,
	material_level = 1,
	charm_power = resolvers.mbonus_material(15, 10),
}

newEntity{ base = "BASE_WAND",
	name = "ash wand", short_name = "ash",
	kr_display_name = "물푸레나무 마법봉",
	color = colors.UMBER,
	level_range = {10, 20},
	cost = 2,
	material_level = 2,
	charm_power = resolvers.mbonus_material(20, 20),
}

newEntity{ base = "BASE_WAND",
	name = "yew wand", short_name = "yew",
	kr_display_name = "주목 마법봉",
	color = colors.UMBER,
	level_range = {20, 30},
	cost = 3,
	material_level = 3,
	charm_power = resolvers.mbonus_material(25, 30),
}

newEntity{ base = "BASE_WAND",
	name = "elven-wood wand", short_name = "e.wood",
	kr_display_name = "엘프나무 마법봉",
	color = colors.UMBER,
	level_range = {30, 40},
	cost = 4,
	material_level = 4,
	charm_power = resolvers.mbonus_material(30, 40),
}

newEntity{ base = "BASE_WAND",
	name = "dragonbone wand", short_name = "dargonbone",
	kr_display_name = "용뼈 마법봉",
	color = colors.UMBER,
	level_range = {40, 50},
	cost = 5,
	material_level = 5,
	charm_power = resolvers.mbonus_material(35, 50),
}