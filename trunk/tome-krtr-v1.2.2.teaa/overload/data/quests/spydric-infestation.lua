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

name = "Eight legs of wonder"
kr_name = "여덟 다리의 불가사의한 존재"
desc = function(self, who)
	local desc = {}
	if not self:isCompleted() and not self:isEnded() then
		desc[#desc+1] = "당신은 알드훈골의 공동에 들어가서, 태양의 기사 라심을 찾아보기로 했습니다."
		desc[#desc+1] = "하지만 이곳의 거미들은 결코 작지 않습니다. 조심할 필요가 있습니다..."
	else
		desc[#desc+1] = "#LIGHT_GREEN#당신은 알드훈골에서 운골뢰를 죽이고, 태양의 기사를 구했습니다."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrance
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "ARDHUNGOL")
		g:resolve() g:resolve(nil, true)
		local spot = level:pickSpot{type="zone-pop", subtype="ardhungol"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)
	game.logPlayer(game.player, "그녀가 당신의 지도에 알드훈골의 위치를 표시해줬습니다.")
end

portal_back = function(self, who)
	who:setQuestStatus(self.id, engine.Quest.COMPLETED)

	-- Reveal entrance
	local g = mod.class.Grid.new{
		show_tooltip=true, always_remember = true,
		name="Portal back to the Gates of Morning",
		kr_name = "아침의 문으로 돌아가는 관문",
		display='>', color=colors.GOLD,
		notice = true,
		change_level=1, change_zone="town-gates-of-morning",
		image = "terrain/granite_floor1.png", add_mos={{image="terrain/demon_portal.png"}},
	}
	g:resolve() g:resolve(nil, true)
	game.zone:addEntity(game.level, g, "terrain", who.x, who.y)
	game.logPlayer(who, "당신의 바로 밑에 관문이 나타났습니다. 관문이 생김과 동시에, 라심이 관문으로 달려갔습니다.")
end
