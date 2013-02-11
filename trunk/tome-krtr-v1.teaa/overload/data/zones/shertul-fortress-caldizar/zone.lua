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

return {
	name = "Unknown Sher'Tul Fortress",
	kr_display_name = "미지의 쉐르'툴 요새",
	display_name = function(x, y)
		local zn = game.level.map.attrs(x or game.player.x, y or game.player.y, "zonename")
		if zn then return "Unknown Sher'Tul Fortress ("..zn..")"
		else return "Unknown the Sher'Tul Fortress" end
	end,
	kr_display_name_f = function(x, y)
		local zn = game.level.map.attrs(x or game.player.x, y or game.player.y, "zonename")
		if zn then return "미지의 쉐르'툴 요새 ("..zn..")"
		else return "미지의 쉐르'툴 요새" end
	end,
	variable_zone_name = true,
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	level_range = {100, 100},
	max_level = 1,
	width = 40, height = 20,
	all_lited = true,
	persistent = "zone",
	ambient_music = "Dreaming of Flying.ogg",
	no_level_connectivity = true,
	no_worldport = true,
	zero_gravity = true,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "zones/shertul-fortress-caldizar",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},
	post_process = function(level)
		-- Setup zones
		for _, z in ipairs(level.custom_zones) do
			if z.type == "zonename" then
				for x = z.x1, z.x2 do for y = z.y1, z.y2 do
					game.level.map.attrs(x, y, "zonename", z.subtype)
				end end
			elseif z.type == "particle" then
				if z.reverse then z.x1, z.x2, z.y1, z.y2 = z.x2, z.x1, z.y2, z.y1 end
				level.map:particleEmitter(z.x1, z.y1, math.max(z.x2-z.x1, z.y2-z.y1) + 1, z.subtype, {
					tx = z.x2 - z.x1,
					ty = z.y2 - z.y1,
				})
			end
		end

		local Map = require "engine.Map"
		level.background_particle1 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.8, size_min = 1, size_max = 3})
		level.background_particle2 = require("engine.Particles").new("starfield_static", 1, {width=Map.viewport.width, height=Map.viewport.height, nb=300, a_min=0.5, a_max = 0.9, size_min = 4, size_max = 8})
	end,
	on_enter = function(lev, old_lev, zone)
		local Dialog = require("engine.ui.Dialog")
		Dialog:simpleLongPopup("미지의 쉐르'툴 요새", "갑작스런 충격과 함께, 당신은 어쩐지 익숙한 곳에 있음을 발견했습니다... 이곳의 부드러운 벽과 온화한 빛이 당신의 요새를 떠올리게 만듭니다. 하지만 뭔가가 다른 것 같기도 합니다. 웅웅거리는 소리가 어디선가 들려오고, 신체가 거의 무게가 없는 것처럼 가벼워지는 것을 느끼며, 작은 움직임만으로도 허공에 나아갈 수 있게 되었습니다. 당신은 자신이 더이상 마즈'에이알에 있지 않다는 이상한 느낌이 듭니다... 갑자기 앞쪽에 끔찍하면서도 환상적인 존재가 있음이 느껴지고, 당신의 모든 신경들이 떨려옴을 느낍니다.", 500)
	end,

	background = function(level, x, y, nb_keyframes)
		local Map = require "engine.Map"
		level.background_particle1.ps:toScreen(x, y, true, 1)
		local parx, pary = level.map.mx / (level.map.w - Map.viewport.mwidth), level.map.my / (level.map.h - Map.viewport.mheight)
		level.background_particle2.ps:toScreen(x - parx * 40, y - pary * 40, true, 1)
	end,
}
