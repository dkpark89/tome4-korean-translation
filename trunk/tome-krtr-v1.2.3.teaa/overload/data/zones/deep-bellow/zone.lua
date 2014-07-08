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

return {
	name = "The Deep Bellow",
	kr_name = "깊은 울림",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	tier1 = true,
--	all_remembered = true,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Straight Into Ambush.ogg",
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 14,
			min_floor = 700,
			floor = "UNDERGROUND_FLOOR",
			wall = "UNDERGROUND_TREE",
			up = "UNDERGROUND_LADDER_UP",
			down = "UNDERGROUND_LADDER_DOWN",
			door = "UNDERGROUND_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {6, 9},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				up = "IRON_COUNCIL",
			}, },
		},
		[3] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/deep-bellow-last",
				},
				actor = {
					nb_npc = {0, 0},
				},
				object = {
					nb_object = {1, 1},
				},
			},
		},
	},
	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE"..level.level)

		game.state:makeWeather(level, 4, {max_nb=4, speed={0.3, 0.4}, alpha={0.23, 0.35}, particle_name="weather/spore_mist_%02d"})
	end,
}
