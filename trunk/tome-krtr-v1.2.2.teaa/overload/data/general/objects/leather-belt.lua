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

newEntity{
	define_as = "BASE_LEATHER_BELT",
	slot = "BELT",
	type = "armor", subtype="belt",
	display = "(", color=colors.UMBER, image = resolvers.image_material("belt", "leather"),
	encumber = 1,
	rarity = 6,
	desc = [[허리에 두르는 허리띠입니다.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/belt.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}

newEntity{ base = "BASE_LEATHER_BELT",
	name = "rough leather belt", short_name = "rough",
	kr_name = "거친가죽 허리띠",
	level_range = {1, 20},
	cost = 1,
	material_level = 1,
}

newEntity{ base = "BASE_LEATHER_BELT",
	name = "hardened leather belt", short_name = "hardened",
	kr_name = "경화가죽 허리띠",
	level_range = {20, 40},
	cost = 2,
	material_level = 3,
}

newEntity{ base = "BASE_LEATHER_BELT",
	name = "drakeskin leather belt", short_name = "drakeskin",
	kr_name = "용가죽 허리띠",
	level_range = {40, 50},
	cost = 4,
	material_level = 5,
}
