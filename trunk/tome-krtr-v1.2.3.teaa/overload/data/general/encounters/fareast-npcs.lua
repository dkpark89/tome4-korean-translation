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

class = require("mod.class.WorldNPC")

newEntity{
	name = "Sun Paladins patrol",
	kr_name = "태양의 기사 순찰대",
	type = "patrol", subtype = "sunwall",
	display = 'p', color = colors.GOLD,
	faction = "sunwall",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	cant_be_moved = false,
	ai = "world_patrol", ai_state = {route_kind="sunwall"},
	on_encounter = {
		type="ambush",
		width=14,
		height=14,
		nb={3, 4},
		filters={{special_rarity="humanoid_random_boss", subtype="human", random_boss={
			nb_classes=1, force_classes = {['Sun Paladin']=true},
			rank=3, ai = "tactical",
			life_rating=function(v) return v * 1.4 + 3 end,
			loot_quality = "store",
			loot_quantity = 1,
			no_loot_randart = true,
		}}}
	},
}

newEntity{
	name = "Anorithil patrol",
	kr_name = "아노리실 순찰대",
	type = "patrol", subtype = "sunwall",
	display = 'p', color = colors.YELLOW,
	faction = "sunwall",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	cant_be_moved = false,
	ai = "world_patrol", ai_state = {route_kind="sunwall"},
	on_encounter = {
		type="ambush",
		width=14,
		height=14,
		nb={3, 4},
		filters={{special_rarity="humanoid_random_boss", subtype="shalore", random_boss={
			nb_classes=1, force_classes = {['Anorithil']=true},
			rank=3, ai = "tactical",
			life_rating=function(v) return v * 1.4 + 3 end,
			loot_quality = "store",
			loot_quantity = 1,
			no_loot_randart = true,
		}}}
	},
}

newEntity{
	name = "Orcs patrol",
	kr_name = "오크 순찰대",
	type = "patrol", subtype = "orc pride",
	display = 'o', color = colors.GREY,
	faction = "orc-pride",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 8,
	ai = "world_patrol", ai_state = {route_kind="orc-pride"},
	on_encounter = {type="ambush", width=14, height=14, nb={6,10}, filters={{type="humanoid", subtype="orc"}}},
}
