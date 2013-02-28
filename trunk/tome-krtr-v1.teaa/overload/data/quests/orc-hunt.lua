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

-- Orc Hunting
name = "Let's hunt some Orc"
kr_display_name = "오크 사냥 시간"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "마지막 희망의 장로는 당신을 철의 왕좌에서 깊이 내려간 곳에 있는 오래된 드워프 왕국인, 레크놀로 보냈습니다. 당신은 그곳에서 오크의 존재를 조사하기로 했습니다."
	desc[#desc+1] = "잃어버린 지팡이와 그들 사이에 연관 관계가 있는지 찾아내야 합니다."
	desc[#desc+1] = "하지만 조심해야 합니다 -- 드워프들도 오랜 세월 동안 이 오래된 곳을 탐험하지 않았으니까요."
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal reknor entrance
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "REKNOR")
		local spot = level:pickSpot{type="zone-pop", subtype="reknor"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)
	game.logPlayer(game.player, "장로가 당신의 지도에 레크놀의 위치를 표시해줬습니다. 여기서 북서쪽으로 조금 떨어진 곳입니다.")
end
