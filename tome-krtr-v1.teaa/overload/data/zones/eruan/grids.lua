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
load("/data/general/grids/water.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/sand.lua")
load("/data/general/grids/mountain.lua")


newEntity{
	define_as = "CHARRED_SCAR_PORTAL",
	name = "Farportal: Charred Scar",
	kr_display_name = "장거리포탈: 검게탄 상처",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/ocean_water_grass_5_1.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[장거리포탈은 눈깜박할 새에 놀랄만큼 먼거리를 이동하는 수단입니다. 이것을 이용하기 위해서는 보통 어떤 물건이 필요합니다. 이 것이 썅방향으로의 사용이 가능한 것인지도 짐작이 가지 않습니다.
이것은 서쪽의 검게탄 상처에 연결된 것으로 보입니다. 불붙은 화산에서는 죽음의 주문만이 가능합니다...]],

	orb_portal = {
		change_level = 1,
		change_zone = "charred-scar",
		message = "#VIOLET#당신은 소용돌이 치는 포탈로 들어섰습니다. 눈을 깜박이자 포탈의 흔적은 없고, 화산의 중심인 지옥같은 땅에 서 있는 것을 알아차립니다...",
		on_preuse = function(self, who)
			-- Find all portals and deactivate them
			for i = -4, 4 do for j = -4, 4 do if game.level.map:isBound(who.x + i, who.y + j) then
				local g = game.level.map(who.x + i, who.y + j, engine.Map.TERRAIN)
				if g.define_as and g.define_as == "CHARRED_SCAR_PORTAL" then g.orb_portal = nil end
			end end end
		end,
		on_use = function(self, who)
			who:setQuestStatus("pre-charred-scar", engine.Quest.DONE)
		end,
	},
}

newEntity{ base = "CHARRED_SCAR_PORTAL", define_as = "CCHARRED_SCAR_PORTAL",
	image = "terrain/ocean_water_grass_5_1.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
	end,
}
