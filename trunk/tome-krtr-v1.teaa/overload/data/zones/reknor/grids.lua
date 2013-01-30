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

newEntity{
	define_as = "FAR_EAST_PORTAL",
	name = "Farportal: the Far East",
	kr_display_name = "장거리포탈: 동대륙",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/marble_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[장거리포탈은 눈깜박할 새에 놀랄만큼 먼거리를 이동하는 수단입니다. 이것을 이용하기 위해서는 보통 어떤 물건이 필요합니다. 이 것이 썅방향으로의 사용이 가능한 것인지도 짐작이 가지 않습니다.
이 것은 일부 소문만이 알려진 동대륙으로 가는 것으로 보입니다...]],

	orb_portal = {
		change_level = 1,
		change_zone = "unremarkable-cave",
		change_wilderness = {
			level_name = "wilderness-1",
			spot = {type="farportal-end", subtype="fareast"},
		},
		after_zone_teleport = {
			x = 98, y = 25,
		},
		message = "#VIOLET#당신은 소용돌이 치는 포탈로 들어섰습니다. 눈을 깜박이자 포탈의 흔적은 없고, 익숙하지 않은 동굴에 서 있는 것을 알아차립니다...",
		on_use = function(self, who)
			game.state:goneEast()
			who:setQuestStatus("wild-wild-east", engine.Quest.DONE)
		end,
	},
}

newEntity{ base = "FAR_EAST_PORTAL", define_as = "CFAR_EAST_PORTAL",
	name = "Farportal: the Far East",
	kr_display_name = "장거리포탈: 동대륙",
	image = "terrain/marble_floor.png",
	add_displays = {
		class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3},
--		class.new{image="terrain/farportal-void-vortex.png", z=18, display_x=-1, display_y=-1, display_w=3, display_h=3},
	},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
	end,
}

newEntity{
	define_as = "IRON_THRONE_EDICT",
	name = "Iron Throne Edict", lore="iron-throne-reknor-edict",
	kr_display_name = "철의 왕좌 칙령", --@@ lore 번역시 수정 필요
	desc = [["철의 왕좌에 사는 모든 시민에 대한 칙령. 우리 황국은 오랫동안 지속될 것이다."]],
	image = "terrain/marble_floor.png",
	display = '_', color=colors.GREEN, back_color=colors.DARK_GREY,
	add_displays = {class.new{image="terrain/signpost.png"}},
	always_remember = true,
	on_move = function(self, x, y, who)
		if who.player then game.party:learnLore(self.lore) end
	end,
}
