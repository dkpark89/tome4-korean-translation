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

local layout = game.state:alternateZone(short_name, {"FLOODED", 2})
local is_flooded = layout == "FLOODED"

return {
	name = "Lake of Nur",
	kr_name = "누르 호수",
	level_range = {15, 25},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = 2,
	max_material_level = 3,
	is_flooded = is_flooded,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room"},
			lite_room_chance = 0,
			['.'] = {"WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR_BUBBLE"},
			['#'] = "WATER_WALL",
			up = "WATER_UP",
			down = "WATER_DOWN",
			door = "WATER_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 25},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			all_lited = true,
			day_night = true,
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/lake-nur",
				},
				actor = {
					nb_npc = {0, 0},
				},
				object = {
					nb_object = {0, 0},
				},
				trap = {
					nb_trap = {0, 0},
				},
			},
		},
		[2] = {
			underwater = true,
			generator = {
				actor = {
					filters = {{special_rarity="water_rarity"}},
				},
			},
		},
		[3] = {
			underwater = is_flooded,
			generator = is_flooded and {
				map = {
					down = "SHERTUL_FORTRESS_FLOOD",
					['.'] = {"WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR","WATER_FLOOR_BUBBLE"},
					force_last_stair = true,
				},
				actor = {
					filters = {{special_rarity="water_rarity"},{special_rarity="horror_water_rarity"}},
					nb_npc = {30, 35},
				},
			} or {
				map = {
					['.'] = "FLOOR",
					['#'] = "WALL",
					up = "UP",
					door = "DOOR",
					down = "SHERTUL_FORTRESS_DRY",
					force_last_stair = true,
				},
			},
		},
	},
	post_process = function(level)
		if level.level == 1 then
			game.state:makeWeather(level, 6, {max_nb=3, chance=1, dir=110, speed={0.1, 0.6}, alpha={0.4, 0.6}, particle_name="weather/dark_cloud_%02d"})
		end

		if level.level == 3 then
			game.state:makeAmbientSounds(level, {
				horror={ chance=400, volume_mod=1.5, files={"ambient/horror/ambient_horror_sound_01","ambient/horror/ambient_horror_sound_02","ambient/horror/ambient_horror_sound_03","ambient/horror/ambient_horror_sound_04","ambient/horror/ambient_horror_sound_05","ambient/horror/ambient_horror_sound_06"}},
			})
		end
	end,

	on_enter = function(lev, old_lev, newzone)
		local Dialog = require("engine.ui.Dialog")
		if lev == 2 and not game.level.shown_warning then
			Dialog:simplePopup("누르 호수", "당신은 물 속에 잠긴 폐허로 내려갔습니다. 벽은 매우 오래된 고대의 것으로 보이고, 이 장소에는 아직도 어떤 힘이 남아 있는 것 같습니다.")
			game.level.shown_warning = true
		elseif lev == 3 and not game.level.shown_warning and not game.level.data.is_flooded then
			game.level.shown_warning = true
			game.party:learnLore("lake-nur-not-flooded")
		elseif lev == 3 and not game.level.shown_warning and game.level.data.is_flooded then
			Dialog:simpleLongPopup("누르 호수", "다음 층으로 내려가면서, 물이 침범하지 못하는 어떤 종류의 마법 장벽을 지나쳤습니다. 하지만 이 장벽에 문제가 있었는지, 다음 층 역시 물에 잠긴 상태입니다.", 400)
			game.level.shown_warning = true
		end
	end,
}
