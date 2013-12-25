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

local layout = game.state:alternateZone(short_name, {"INVASION", 2})
local is_invaded = layout == "INVASION"

return {
	name = "Murgol Lair",
	kr_name = "무르골 동굴",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	tier1 = true,
--	all_remembered = true,
--	all_lited = true,
	ambient_music = "Enemy at the gates.ogg",
	persistent = "zone",
	max_material_level = 2,
	no_random_lore = true,
	is_invaded = is_invaded,
	underwater = true,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room"},
			lite_room_chance = 100,
			['.'] = {"WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR_BUBBLE"},
			['#'] = "WATER_WALL",
			up = "WATER_UP",
			down = "WATER_DOWN",
			door = "WATER_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			guardian = is_invaded and "NASHVA" or "MURGOL",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_object = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "WATER_UP_WILDERNESS",
			}, },
		},
	},
	
	on_enter = function(lev)
		if lev == 1 and not game.level.data.warned and game.zone.is_invaded then
			game.level.data.warned = true
			require("engine.ui.Dialog"):simplePopup("무르골 동굴", "당신이 동굴에 들어가자, 저 멀리서 싸우는 소리가 들려옵니다. 누군가가 이미 동굴에 침입한 것 같습니다.")
		end
	end,
}
