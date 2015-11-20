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

newEntity{
	define_as = "PORTAL_BACK",
	name = "Demonic Portal", image = "terrain/lava_floor.png", add_displays = {class.new{image="terrain/demon_portal.png"}},
	kr_name = "악마의 관문",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET,
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[이 관문은 마즈'에이알과 연결되어 있는 것 같습니다. 돌아가기 위해서 이 것을 사용해야 할 것 같습니다.]],

	on_move = function(self, x, y, who)
		if who == game.player then
			require("engine.ui.Dialog"):yesnoPopup("다시 또 그 곳에", "마즈'에이알로 돌아갑니까? (먼저 드래보르에게서 전리품을 챙기는 것이 좋습니다)", function(ret)
				if not ret then
					game:onLevelLoad("wilderness-1", function(zone, level)
						local spot = level:pickSpot{type="farportal-end", subtype="demon-plane-arrival"}
						who.wild_x, who.wild_y = spot.x, spot.y
					end)
					game:changeLevel(1, "wilderness")
					game.logPlayer(who, "#VIOLET#당신은 소용돌이 치는 관문으로 들어섰고, 눈 깜짝할 사이에 마즈'에이알의 다이카라 부근으로 돌아왔습니다.")
				end
			end, "취소", "돌아가기")
		end
	end,
}
