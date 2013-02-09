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

load("/data/general/grids/basic.lua")
load("/data/general/grids/fortress.lua")
load("/data/general/grids/void.lua")

newEntity{
	define_as = "COMMAND_ORB",
	name = "Sher'Tul Control Orb", image = "terrain/solidwall/solid_floor1.png", add_displays = {class.new{image="terrain/shertul_control_orb_blue.png"}},
	kr_display_name = "쉐르'툴 제어 오브",
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		return true
	end,
}

newEntity{
	define_as = "FARPORTAL",
	name = "Exploratory Farportal",
	kr_display_name = "탐험용 장거리 관문",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/solidwall/solid_floor1.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[놀라운 거리를 눈 깜박할 새에 갈 수 있는 장거리 관문입니다. 강력한 쉐르'툴 종족이 남긴 것입니다.
이 장거리 관문은 다른 관문과 연결되어 있지 않습니다. 탐험을 위해 만들어졌고, 어디로 보낼지 알 수가 없습니다.
자동적으로 돌아오는 관문이 만들어지지만, 도착지점에서 가까운 곳이 아닐 수도 있습니다.]],

	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return true end
		local Dialog = require "engine.ui.Dialog"
		Dialog:simplePopup("장거리 관문", "장거리 관문은 비활성화 상태인 것 같습니다.")
		return true
	end,
}

newEntity{ base = "FARPORTAL", define_as = "CFARPORTAL",
	image = "terrain/solidwall/solid_floor1.png",
	add_displays = {
		class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3},
	},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
	end,
}
