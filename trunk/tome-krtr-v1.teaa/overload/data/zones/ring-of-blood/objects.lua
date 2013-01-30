-- ToME - Tales of Maj'Eyal
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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_RING",
	power_source = {psionic=true},
	define_as = "RING_OF_BLOOD", rarity=false,
	name = "Bloodcaller", unique=true, image = "object/artifact/jewelry_ring_bloodcaller.png",
	kr_display_name = "피의 선도자", kr_unided_name = "피의 반지",
	desc = [[피의 경기장의 시행에서 승리했고, 이것이 그 보상입니다.]],
	unided_name = "bloody ring",
	rarity = false,
	cost = 300,
	material_level = 4,
	wielder = {
		combat_mentalresist = -7,
		fatigue = -5,
		life = 35,
		life_leech_chance = 15,
		life_leech_value = 30,
	},
}
