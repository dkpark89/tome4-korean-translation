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
	name = "Temporal Rift",
	kr_name = "시간의 균열",
	display_name = function(x, y)
		if game.level.level == 2 then return "Temporal Rift: Lumberjack village"
		elseif game.level.level == 3 then return "Temporal Rift: Daikara"
		elseif game.level.level == 4 then return "Temporal Rift: Lake of Nur"
		end
		return "Temporal Rift"
	end,
	kr_display_name = function(x, y)
		if game.level.level == 2 then return "시간의 균열 : 나무꾼 마을"
		elseif game.level.level == 3 then return "시간의 균열 : 다이카라"
		elseif game.level.level == 4 then return "시간의 균열 : 누르의 호수"
		end
		return "시간의 균열"
	end,
	variable_zone_name = true,
	level_range = {16, 30},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 60, height = 25,
--	all_remembered = true,
	all_lited = true,
	no_worldport = true,
	persistent = "zone",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
	},
	color_shown = {0.7, 0.6, 0.8, 1},
	color_obscure = {0.7*0.6, 0.6*0.6, 0.8*0.6, 0.6},
	ambient_music = "Through the Dark Portal.ogg",
	levels =
	{
		[1] = { zero_gravity = true,
			generator = {
			map = {
				class = "engine.generator.map.Forest",
				floor = "VOID",
				wall = "SPACETIME_RIFT",
				up = "VOID",
				down = "RIFT",
				edge_entrances = {4,6},
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				filters = {{type="elemental", subtype="temporal",}},
				nb_npc = {15, 25},
			},
		} },
		[2] = {
			width = 25, height = 25,
			generator = {
			map = {
				class = "engine.generator.map.Static",
				map = "towns/lumberjack-village",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				filters = {{type="horror", subtype="temporal",}},
				nb_npc = {3, 3},
			},
		} },
		[3] = {
			width = 50, height = 50,
			generator = {
			map = {
				class = "engine.generator.map.Roomer",
				nb_rooms = 10,
				edge_entrances = {2,8},
				rooms = {"forest_clearing","rocky_snowy_trees"},
				['.'] = "ROCKY_GROUND",
				['T'] = "ROCKY_SNOWY_TREE",
				['#'] = "MOUNTAIN_WALL",
				up = "ROCKY_GROUND",
				down = "ROCKY_GROUND",
				door = "ROCKY_GROUND",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				filters = {{type="horror", subtype="temporal",}},
				nb_npc = {15, 25},
			},
		} },
		[4] = {
			width = 50, height = 50,
			generator = {
			map = {
				class = "engine.generator.map.Static",
				map = "zones/lake-nur",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {0, 0},
			},
		} },
	},

	post_process = function(level)
		if level.level == 1 then
			local Map = require "engine.Map"
			if core.shader.allow("volumetric") then
				level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}})
			else
				level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
			end
			if config.settings.tome.weather_effects and core.shader.allow("distort") then
				level.foreground_particle = require("engine.Particles").new("temporalsnow", 1, {width=Map.viewport.width, height=Map.viewport.height, r=0.65, g=0.25, b=1, rv=-0.001, gv=0, bv=-0.001, factor=2, dir=math.rad(110+180)})
			end
		end

		if level.level <= 2 then
			game.state:makeWeather(level, 6, {max_nb=7, chance=1, dir=120, speed={0.1, 0.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})
		else
			game.state:makeWeather(level, 6, {max_nb=12, chance=1, dir=120, speed={0.1, 0.9}, r=0.2, g=0.4, b=1, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})
		end
	end,

	on_enter = function(lev, old_lev, newzone)
		game.player:attr("temporal_touched", 1)

		local Dialog = require("engine.ui.Dialog")
		if lev == 1 and not game.level.shown_warning then
			Dialog:simplePopup("시간의 균열", "균열로 들어서자, 시공간이 왜곡되면서 당신은 길을 잃었습니다. 이 공간은... 이질적입니다.")
			game.level.shown_warning = true
		elseif lev == 2 and not game.level.shown_warning then
			Dialog:simplePopup("시간의 균열", "이곳은 마즈'에이알의 숲으로 보이지만, 뭔가 이상하게 왜곡된 느낌이 듭니다. 조심하는 편이 좋을 것 같습니다...")
			game.level.shown_warning = true
			require("mod.class.generator.actor.Random").new(game.zone, game.level.map, game.level, {}):generateGuardian("BEN_CRUTHDAR_ABOMINATION")
		elseif lev == 3 and not game.level.shown_warning then
			Dialog:simplePopup("시간의 균열", "균열로 들어서자, 다이카라 산맥처럼 보이는 곳이 나옵니다. 하지만 뭔지 모르게... 다른 곳 같습니다.")
			game.level.shown_warning = true
			require("mod.class.generator.actor.Random").new(game.zone, game.level.map, game.level, {}):generateGuardian("ABOMINATION_RANTHA")
		elseif lev == 4 and not game.level.shown_warning then
			Dialog:simplePopup("시간의 균열", "이곳의 평화는 무언가에 의해 깨졌습니다.")
			game.level.shown_warning = true

			local m1 = game.zone:makeEntityByName(game.level, "actor", "CHRONOLITH_TWIN")
			game.zone:addEntity(game.level, m1, "actor", 26, 8)
			local m2 = game.zone:makeEntityByName(game.level, "actor", "CHRONOLITH_CLONE")
			game.zone:addEntity(game.level, m2, "actor", 29, 8)
			m1.brother = m2
			m2.brother = m1
		end
	end,

	portal_next = function(npc)
		local g = game.zone:makeEntityByName(game.level, "terrain", "RIFT")
		local oe = game.level.map(npc.x, npc.y, engine.Map.TERRAIN)
		if oe:attr("temporary") and oe.old_feat then 
			oe.old_feat = g
		else
			game.zone:addEntity(game.level, g, "terrain", npc.x, npc.y)
		end
	end,

	foreground = function(level, x, y, nb_keyframes)
		if not config.settings.tome.weather_effects or not level.foreground_particle then return end
		level.foreground_particle.ps:toScreen(x, y, true, 1)
	end,

	background = function(level, x, y, nb_keyframes)
		if level.level ~= 1 then return end

		local Map = require "engine.Map"
		if level.starfield_shader and level.starfield_shader.shad then
			level.starfield_shader.shad:use(true)
			core.display.drawQuad(x, y, Map.viewport.width, Map.viewport.height, 1, 1, 1, 1)
			level.starfield_shader.shad:use(false)
		elseif level.background_particle then
			level.background_particle.ps:toScreen(x, y, true, 1)
		end
	end,
}
