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

local layout = game.state:alternateZone(short_name, {"TWISTED", 2})
if layout == "TWISTED" then

return {
	name = "Scintillating Caves",
	kr_name = "번뜩이는 동굴",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 5,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 30, height = 30,
--	all_remembered = true,
	tier1 = true,
	tier1_escort = 2,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Mystery.ogg",
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 5,
			rooms = {"random_room", {"money_vault",5}},
			lite_room_chance = 20,
			['.'] = "CRYSTAL_FLOOR",
			['#'] = {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",},
			up = "CRYSTAL_LADDER_UP",
			down = "CRYSTAL_LADDER_DOWN",
			door = "CRYSTAL_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {12, 16},
			filters = { {max_ood=2}, },
			guardian = "SPELLBLAZE_CRYSTAL",
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
				up = "CRYSTAL_LADDER_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObject("NOTE")
	end,

	foreground = function(level, dx, dx, nb_keyframes)
		local tick = core.game.getTime()
		local sr, sg, sb
		sr = 4 + math.sin(tick / 2000) / 2
		sg = 3 + math.sin(tick / 2700)
		sb = 3 + math.sin(tick / 3200)
		local max = math.max(sr, sg, sb)
		sr = sr / max
		sg = sg / max
		sb = sb / max

		level.map:setShown(sr, sg, sb, 1)
		level.map:setObscure(sr * 0.6, sg * 0.6, sb * 0.6, 1)
	end,

	on_enter = function(lev)
		if lev == 1 and not game.level.data.warned then
			game.level.data.warned = true
			require("engine.ui.Dialog"):simplePopup("동굴...", "동굴에 들어서자, 당신은 이곳의 마법이 대지를 왜곡시켜 모든 것을 날카롭게 되었다는 느낌을 받았습니다.")
		end
	end,
}

else

return {
	name = "Scintillating Caves",
	kr_name = "번뜩이는 동굴",
	level_range = {1, 5},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
	tier1 = true,
	tier1_escort = 2,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Mystery.ogg",
	max_material_level = 2,
	generator =  {
		map = {
			class = "engine.generator.map.Cavern",
			zoom = 14,
			min_floor = 700,
			floor = "CRYSTAL_FLOOR",
			wall = {"CRYSTAL_WALL","CRYSTAL_WALL2","CRYSTAL_WALL3","CRYSTAL_WALL4","CRYSTAL_WALL5","CRYSTAL_WALL6","CRYSTAL_WALL7","CRYSTAL_WALL8","CRYSTAL_WALL9","CRYSTAL_WALL10","CRYSTAL_WALL11","CRYSTAL_WALL12","CRYSTAL_WALL13","CRYSTAL_WALL14","CRYSTAL_WALL15","CRYSTAL_WALL16","CRYSTAL_WALL17","CRYSTAL_WALL18","CRYSTAL_WALL19","CRYSTAL_WALL20",},
			up = "CRYSTAL_LADDER_UP",
			down = "CRYSTAL_LADDER_DOWN",
			door = "CRYSTAL_FLOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			filters = { {max_ood=2}, },
			guardian = "SPELLBLAZE_CRYSTAL",
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
				up = "CRYSTAL_LADDER_UP_WILDERNESS",
			}, },
		},
	},

	post_process = function(level)
		-- Place a lore note on each level
		game:placeRandomLoreObjectScale("NOTE", 5, level.level)
	end,

	foreground = function(level, dx, dx, nb_keyframes)
		local tick = core.game.getTime()
		local sr, sg, sb
		sr = 4 + math.sin(tick / 2000) / 2
		sg = 3 + math.sin(tick / 2700)
		sb = 3 + math.sin(tick / 3200)
		local max = math.max(sr, sg, sb)
		sr = sr / max
		sg = sg / max
		sb = sb / max

		level.map:setShown(sr, sg, sb, 1)
		level.map:setObscure(sr * 0.6, sg * 0.6, sb * 0.6, 1)
	end,
}

end