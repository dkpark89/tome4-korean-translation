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
	define_as = "BASE_RING",
	slot = "FINGER",
	type = "jewelry", subtype="ring", image = resolvers.image_material("ring", {"copper", "steel", "gold", "stralite", "voratun"}),
	display = "=",
	encumber = 0.1,
	rarity = 6,
	desc = [[반지는 다양한 마법적 특성을 가질 수 있습니다.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	-- Most rings are ego items
	egos = "/data/general/objects/egos/rings.lua", egos_chance = { prefix=resolvers.mbonus(50, 40), suffix=resolvers.mbonus(50, 40) }, egos_chance_decay = 0.5,
}
newEntity{
	define_as = "BASE_AMULET",
	slot = "NECK",
	type = "jewelry", subtype="amulet", image = resolvers.image_material("amulet", {"copper", "steel", "gold", "stralite", "voratun"}),
	display = '"',
	encumber = 0.1,
	rarity = 8,
	desc = [[목걸이는 다양한 마법적 특성을 가질 수 있습니다.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/amulets.lua", egos_chance = { prefix=resolvers.mbonus(50, 40), suffix=resolvers.mbonus(50, 40) }, egos_chance_decay = 0.5,
}

newEntity{ base = "BASE_RING",
	name = "copper ring", color = colors.UMBER,
	unided_name = "copper ring", short_name = "copper",
	kr_name = "구리 반지", kr_unided_name = "구리 반지",
	level_range = {1, 10},
	cost = 1,
	material_level = 1,
}
newEntity{ base = "BASE_RING",
	name = "steel ring", color = colors.SLATE,
	unided_name = "steel ring", short_name = "steel",
	kr_name = "강철 반지", kr_unided_name = "강철 반지",
	level_range = {10, 20},
	cost = 2,
	material_level = 2,
}
newEntity{ base = "BASE_RING",
	name = "gold ring", color = colors.YELLOW,
	unided_name = "gold ring", short_name = "gold",
	kr_name = "황금 반지", kr_unided_name = "황금 반지",
	level_range = {20, 30},
	cost = 5,
	material_level = 3,
}
newEntity{ base = "BASE_RING",
	name = "stralite ring", color = {r=50, g=50, b=50},
	unided_name = "stralite ring", short_name = "stralite",
	kr_name = "스트라라이트 반지", kr_unided_name = "스트라라이트 반지",
	level_range = {30, 40},
	cost = 10,
	material_level = 4,
}
newEntity{ base = "BASE_RING",
	name = "voratun ring", color = colors.WHITE,
	unided_name = "voratun ring", short_name = "voratun",
	kr_name = "보라툰 반지", kr_unided_name = "보라툰 반지",
	level_range = {40, 50},
	cost = 15,
	material_level = 5,
}

newEntity{ base = "BASE_AMULET",
	name = "copper amulet", color = colors.UMBER,
	unided_name = "copper amulet", short_name = "copper",
	kr_name = "구리 목걸이", kr_unided_name = "구리 목걸이",
	level_range = {1, 10},
	cost = 1,
	material_level = 1,
}
newEntity{ base = "BASE_AMULET",
	name = "steel amulet", color = colors.SLATE,
	unided_name = "steel amulet", short_name = "steel",
	kr_name = "강철 목걸이", kr_unided_name = "강철 목걸이",
	level_range = {10, 20},
	cost = 2,
	material_level = 2,
}
newEntity{ base = "BASE_AMULET",
	name = "gold amulet", color = colors.YELLOW,
	unided_name = "gold amulet", short_name = "gold",
	kr_name = "황금 목걸이", kr_unided_name = "황금 목걸이",
	level_range = {20, 30},
	cost = 5,
	material_level = 3,
}
newEntity{ base = "BASE_AMULET",
	name = "stralite amulet", color = {r=50, g=50, b=50},
	unided_name = "stralite amulet", short_name = "stralite",
	kr_name = "스트라라이트 목걸이", kr_unided_name = "스트라라이트 목걸이",
	level_range = {30, 40},
	cost = 10,
	material_level = 4,
}
newEntity{ base = "BASE_AMULET",
	name = "voratun amulet", color = colors.WHITE,
	unided_name = "voratun amulet", short_name = "voratun",
	kr_name = "보라툰 목걸이", kr_unided_name = "보라툰 목걸이",
	level_range = {40, 50},
	cost = 15,
	material_level = 5,
}
