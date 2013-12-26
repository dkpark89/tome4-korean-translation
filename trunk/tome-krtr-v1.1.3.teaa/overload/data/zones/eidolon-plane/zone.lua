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

require "engine.krtrUtils"

return {
	name = "Eidolon Plane",
	kr_name = "에이돌론의 차원",
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 1,
	width = 50, height = 50,
	all_remembered = true,
	all_lited = true,
	no_worldport = true,
	is_eidolon_plane = true,
	no_anomalies = true,
	zero_gravity = true,
	no_autoexplore = true,
	ambient_music = "Alchemist.ogg",
	generator =  {
		map = {
			class = "engine.generator.map.Empty",
			noise = "fbm_perlin",
			floor = "VOID",
			up = "VOID",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
	},

	effects = {"EFF_EIDOLON_PROTECT"},

	post_process = function(level, zone)
		local eidolon = zone:makeEntityByName(level, "actor", "EIDOLON", true)
		if eidolon then zone:addEntity(level, eidolon, "actor", 25, 25) end

		level.default_up = {x=22, y=25}
		level.default_down = {x=22, y=25}

		if level.level == 1 then
			local Map = require "engine.Map"
			if core.shader.allow("volumetric") then
				level.starfield_shader = require("engine.Shader").new("starfield", {size={Map.viewport.width, Map.viewport.height}, speed=200})
			else
				level.background_particle = require("engine.Particles").new("starfield", 1, {width=Map.viewport.width, height=Map.viewport.height})
			end
		end

		game.state:makeWeather(level, 6, {max_nb=1, chance=200, dir=120, speed={0.1, 0.9}, r=0.2, g=0.2, b=0.2, alpha={0.2, 0.4}, particle_name="weather/grey_cloud_%02d"})

		-- Can drop anything on the eidolon plane
		for x = 0, level.map.w - 1 do for y = 0, level.map.h - 1 do
			level.map.attrs(x, y, "on_drop", function(...) game.level.data.process_drops(...) end)
		end end
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

	-- Handle drops
	process_drops = function(who, dx, dy, idx, o)
		local map = game.level.map
		map:removeObject(dx, dy, idx)

		game.logPlayer(who, "에이돌론의 차원은 일반적인 세상처럼 물리적으로 존재하는 곳이 아닌 것 같습니다. 여기서는 아무것도 버릴 수가 없습니다. %s 소지품으로 되돌아옵니다.", o:getName{do_color=true}:capitalize():addJosa("가"))
		who:addObject(who.INVEN_INVEN, o)
	end,

	-- The Eidolon can *never* not exist
	on_turn = function()
		local eidolon = nil
		for uid, e in pairs(game.level.entities) do
			if e.define_as == "EIDOLON" then eidolon = e end
		end
		if not eidolon then
			eidolon = game.zone:makeEntityByName(game.level, "actor", "EIDOLON")
			local x, y = util.findFreeGrid(game.player.x, game.player.y, 10, true, {[engine.Map.ACTOR] = true})
			if x and y then game.zone:addEntity(game.level, eidolon, "actor", x, y) end
		elseif not eidolon.x or game.level.map(eidolon.x, eidolon.y, engine.Map.ACTOR) ~= eidolon then
			eidolon.deleteFromMap = false
			game.level:removeEntity(eidolon, true)
			local x, y = util.findFreeGrid(game.player.x, game.player.y, 10, true, {[engine.Map.ACTOR] = true})
			if x and y then game.zone:addEntity(game.level, eidolon, "actor", x, y) end
			eidolon.deleteFromMap = nil
		end
	end,

	eidolon_exit = function(to_worldmap)
		game:onTickEnd(function()
			local oldzone = game.zone
			local oldlevel = game.level
			local zone = game.level.source_zone
			local level = game.level.source_level

			local acts = {}
			for act, _ in pairs(game.party.members) do
				act:removeEffect(act.EFF_EIDOLON_PROTECT, true, true)
				act.invulnerable_others = nil
				acts[#acts+1] = act
				if oldlevel:hasEntity(act) then oldlevel:removeEntity(act) end
			end

			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			for _, act in ipairs(acts) do
				local x, y = util.findFreeGrid(oldlevel.data.eidolon_exit_x or 1, oldlevel.data.eidolon_exit_y or 1, 20, true, {[engine.Map.ACTOR]=true})
				if not x then
					x, y = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
					local tries = 0
					while not act:canMove(x, y) and tries < 100 do
						x, y = rng.range(0, game.level.map.w - 1), rng.range(0, game.level.map.h - 1)
						tries = tries + 1
					end
					if tries >= 100 then x = nil end
				end
				if x then
					act.x, act.y = nil, nil
					level:addEntity(act)
					act:move(x, y, true)
					act.changed = true
					game.level.map:particleEmitter(x, y, 1, "teleport")
				end
			end

			-- Reload MOs
			game.level.map:redisplay()
			game.level.map:recreate()
			game.uiset:setupMinimap(game.level)

			for uid, act in pairs(game.level.entities) do
				if act.setEffect then
					if game.level.data.zero_gravity then act:setEffect(act.EFF_ZERO_GRAVITY, 1, {})
					else act:removeEffect(act.EFF_ZERO_GRAVITY, nil, true) end
				end
			end

			if to_worldmap then
				game:changeLevel(1, game.player.last_wilderness or "wilderness", {temporary_zone_shift_back=game.level.temp_shift_zone and true or false, direct_switch=true})
			end

			game.logPlayer(game.player, "#LIGHT_RED#당신은 에이돌론의 차원을 벗어나, 물질계로 되돌아왔습니다!")
			game.player:updateMainShader()
			game:onLevelLoadRun()
		end)
	end,
}
