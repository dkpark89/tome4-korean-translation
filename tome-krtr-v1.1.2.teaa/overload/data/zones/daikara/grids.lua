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

load("/data/general/grids/basic.lua")
load("/data/general/grids/mountain.lua")
load("/data/general/grids/lava.lua", function(e) e.on_stand = nil end)

newEntity{
	define_as = "RIFT",
	name = "Temporal Rift", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/temporal_instability_yellow.png"}},
	kr_name = "시간의 균열",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[어디론가 알지 못할 곳으로 갈 수 있는 균열입니다...]],
	change_level = 1, change_zone = "temporal-rift",
	change_level_check = function() -- Forbid going back
		if not game.player:hasQuest("temporal-rift") then
			require("engine.ui.Dialog"):yesnoPopup("시간의 균열", "정말 들어가기를 원합니까? 도착하는 곳이 어디인지, 또 돌아오는 것이 가능할지 아무도 모릅니다.", function(ret)
				if ret then game:changeLevel(1, "temporal-rift") end
			end, "예", "아니오")
			return true
		end
		game.log("이 균열은 너무나 불안정하여 들어갈 수 없습니다.")
		return true
	end
}
