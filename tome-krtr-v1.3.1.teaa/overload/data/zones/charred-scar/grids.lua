-- ToME - Tales of Maj'Eyal
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

load("/data/general/grids/basic.lua")
load("/data/general/grids/lava.lua", function(e) if e.define_as == "LAVA_FLOOR" then e.on_stand = nil end end)

local lava_editer = {method="borders_def", def="lava"}

newEntity{
	define_as = "FAR_EAST_PORTAL",
	type = "floor", subtype = "lava",
	name = "Farportal: the Far East",
	kr_name = "장거리 관문 : 동대륙",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/lava_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[장거리 관문은 눈 깜짝할 사이에 놀랄만큼 먼 거리를 이동하는 수단입니다. 이 관문을 사용하기 위해서는 보통 어떤 물건이 필요합니다.]],
	nice_editer = lava_editer,

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			spot = {type="farportal-end", subtype="fareast"},
		},
		message = "#VIOLET#당신은 소용돌이 치는 관문으로 들어섰습니다. 눈 깜짝할 사이에 관문의 흔적은 없어지고, 동대륙에 도착한 자신을 발견하였습니다.",
	},
}

newEntity{ base = "FAR_EAST_PORTAL", define_as = "CFAR_EAST_PORTAL",
	image = "terrain/lava_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(y, y, 3, "farportal_lightning")
	end,
}
