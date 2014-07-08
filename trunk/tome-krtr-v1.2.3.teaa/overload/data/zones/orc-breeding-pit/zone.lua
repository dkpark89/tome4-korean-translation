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
	name = "Orc breeding pits",
	kr_name = "오크 번식용 동굴",
	level_range = {30, 60},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	persistent = "zone",
--	all_remembered = true,
--	all_lited = true,
	ambient_music = "Thrall's Theme.ogg",
	min_material_level = 4,
	max_material_level = 5,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 23,
			min_floor = 900,
			floor = "UNDERGROUND_FLOOR",
			wall = "UNDERGROUND_TREE",
			up = "UNDERGROUND_LADDER_UP",
			down = "UNDERGROUND_LADDER_DOWN",
			door = "UNDERGROUND_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {40, 50},
			guardian = "GREATMOTHER",
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {3, 6},
		},
	},
	post_process = function(level)
		-- Place a lore note on each level
		if level.level == 2 then 
			game:placeRandomLoreObject("BREEDING_HISTORY2")
			game:placeRandomLoreObject("BREEDING_HISTORY3")
			game:placeRandomLoreObject("BREEDING_HISTORY4")
		elseif level.level == 3 then 
			game:placeRandomLoreObject("BREEDING_HISTORY5")
		end

		for uid, e in pairs(level.entities) do if e.faction ~= "neutral" then e.faction="orc-pride" end end
	end,
	on_enter = function(lev, old_lev, newzone)
		if newzone and not game.level.shown_warning then
			require("engine.ui.Dialog"):simplePopup("오크 번식용 동굴", "당신은 작은 지하 구조물에 도착했습니다. 거기에는 오크들이 있었고, 그들은 당신을 발견하자 소리를 쳤습니다. '어미들을 보호하라!'")
			game.level.shown_warning = true
		end
	end,
	levels =
	{
		[1] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "zones/orc-breeding-pit-first",
			}, actor = {
				nb_npc = {0, 0},
			}, },
		},
		[3] = { width = 15, height = 15, generator = {map = {min_floor=120}} },
	},
}
