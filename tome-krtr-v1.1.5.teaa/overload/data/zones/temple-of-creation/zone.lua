-- ToME - Tales of Maj'Eyal
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

return {
	name = "Temple of Creation",
	kr_name = "창조의 사원",
	level_range = {30, 40},
	level_scheme = "player",
	max_level = 3,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 70, height = 70,
--	all_remembered = true,
--	all_lited = true,
	underwater = true,
	persistent = "zone",
	ambient_music = "Inside a dream.ogg",
	-- Apply a bluish tint to all the map
	color_shown = {0.5, 1, 0.8, 1},
	color_obscure = {0.5*0.6, 1*0.6, 0.8*0.6, 0.6},
	min_material_level = 3,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 16,
			min_floor = 1200,
			floor = "WATER_FLOOR",
			wall = "WATER_WALL",
			up = "WATER_UP",
			down = "WATER_DOWN",
			door = "WATER_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {30, 40},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_object = {6, 9},
		},
	},
	levels =
	{
		[1] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/temple-of-creation-first",
				},
				actor = {
					nb_npc = {10, 10},
				},
			},
			no_level_connectivity = true,
		},
		[3] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/temple-of-creation-last",
				},
				actor = {
					nb_npc = {7, 7},
				},
			},
			no_level_connectivity = true,
		},
	},
	post_process = function(level)
		if level.level == 1 then
			game:placeRandomLoreObject("NOTE1")
		elseif level.level == 2 then
			game:placeRandomLoreObject("NOTE2")
			game:placeRandomLoreObject("NOTE3")
		end
	end,

	on_enter = function(lev, old_lev, newzone)
		if newzone then
			game.logPlayer(game.player, "#AQUAMARINE#당신은 깊은 바다 중에서도 가장 깊은 곳에 도착했습니다. 위쪽을 쳐다보자 희미하게 반짝이는 빛만 보입니다.")
			game.logPlayer(game.player, "#AQUAMARINE#원래는 압력에 의해 찌그러져야 정상이지만, 기이하게도 그 어떤 불편함도 느껴지지 않습니다.")
			game.logPlayer(game.player, "#AQUAMARINE#왼쪽에 보이는 대형 산호 건축물을 제외하면, 주변에는 온통 바닷물 뿐입니다. 저곳이 창조의 사원인 것 같습니다.")
		end
	end,
}
