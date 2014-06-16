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

require "engine.krtrUtils"

return {
	name = "Sludgenest",
	kr_name = "진창의 보금자리",
	level_range = {35, 45},
	level_scheme = "player",
	max_level = 3,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
--	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	ambient_music = "Together We Are Strong.ogg",
	no_level_connectivity = true,
	max_material_level = 4,
	objects_cost_modifier = 0.05,
	generator =  {
		map = {
			class = "engine.generator.map.Octopus",
			main_radius = {0.1, 0.2},
			arms_radius = {0.05, 0.15},
			arms_range = {0.7, 0.8},
			nb_rooms = {6, 10},
			['#'] = "SLIME_WALL",
			['.'] = "SLIME_FLOOR",
			up = "SLIME_UP",
			down = "SLIME_DOWN",
			door = "SLIME_DOOR",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {20, 30},
			guardian = "CORRUPTED_OOZEMANCER",
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {4, 10},
		},
	},

	levels = {
		[1] = {
			all_lited = true,
			generator =  {
				map = {
					class = "mod.class.generator.map.Caldera",
					mountain = "JUNGLE_TREE",
					tree = "JUNGLE_TREE",
					grass = "JUNGLE_GRASS",
					water = {"SLIME_FLOOR","SLIME_FLOOR","SLIME_FLOOR","SLIME_FLOOR","SLIME_FLOOR","SLIME_FLOOR","SLIME_WALL",},
					up = "JUNGLE_GRASS_UP_WILDERNESS",
					down = "SLIME_DOWN", down_center = true,
				},
			},
		},
		[3] = {
			width = 15, height = 15,
			generator =  {
				map = {
					class = "mod.class.generator.map.Caldera",
					mountain = "SLIME_WALL",
					tree = "SLIME_WALL",
					grass = "SLIME_FLOOR",
					water = "SLIME_FLOOR",
					up = "SLIME_UP",
					down = "SLIME_FLOOR",
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {9, 9},
				},
			},
		},
	},

	spawn_chance = 3,
	dangerlevel = 1,
	on_turn = function()
		if game.level.level == 1 then return end
		if game.turn % 10 ~= 0 then return end
		if not rng.percent(game.level.data.spawn_chance) then game.level.data.spawn_chance = game.level.data.spawn_chance + 1 return end

		local grids = core.fov.circle_grids(game.player.x, game.player.y, 10, true)
		local gs = {}
		for x, yy in pairs(grids) do for y, _ in pairs(yy) do
			if game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") then
				gs[#gs+1] = {x=x,y=y}
			end
		end end
		if #gs == 0 then return end

		local spot = rng.table(gs)
		local g = game.zone:makeEntityByName(game.level, "terrain", "SLIME_FLOOR")
		local filter = {}

		local dl = game.level.data.dangerlevel
		local add_level = 0
		local randelite = 10 + (dl / 10) ^ 1.6
		local randboss = (dl / 10) ^ 1.2 - 3

		if dl == 20 then require("engine.ui.Dialog"):simplePopup("진창의 보금자리", "벽에서 슬라임들이 튀어나오고, 시간이 지날수록 더욱 위험해집니다.") end
		if dl == 100 then world:gainAchievement("SLUDGENEST100", game.player) end
		if dl == 200 then world:gainAchievement("SLUDGENEST200", game.player) end
		if dl == 300 then world:gainAchievement("SLUDGENEST300", game.player) end
		if dl == 400 then world:gainAchievement("SLUDGENEST400", game.player) end
		if dl == 500 then world:gainAchievement("SLUDGENEST500", game.player) end

		if randboss > 0 and rng.percent(randboss) then filter = {random_boss = {power_source = {nature=true, psionic=true, technique=true}}}
		elseif randelite > 0 and rng.percent(randelite) then filter = {random_elite = {power_source = {nature=true, psionic=true, technique=true}}} end
		filter.add_levels = (filter.add_levels or 0) + math.floor(dl / 10)

		local m = game.zone:makeEntity(game.level, "actor", filter, nil, true)
		if g and m then
			m.exp_worth = 0
			game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
			game.zone:addEntity(game.level, m, "actor", spot.x, spot.y)
			game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
			m:setTarget(game.player)
			game.logSeen(m, "#YELLOW_GREEN#한 쪽 벽이 잠시 떨리다가, %s 변신합니다!", (m.kr_name or m.name):capitalize():addJosa("로"))

			game.level.data.dangerlevel = game.level.data.dangerlevel + 1
		end

		game.level.data.spawn_chance = 3
	end,

	foreground = function(level, dx, dx, nb_keyframes)
		if level.level == 1 then return end
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
