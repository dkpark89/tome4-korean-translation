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

name = "Hidden treasure"
kr_display_name = "숨겨진 보물"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 숨겨진 보물이 있는 곳으로 가기 위한 모든 단서를 찾았습니다. 이곳은 트롤 늪의 세 번째 지역을 통해 갈 수 있습니다."
	desc[#desc+1] = "하지만, 이곳은 매우 위험한 곳인 것 같습니다. 조심할 필요가 있습니다."
	if self:isEnded() then
		desc[#desc+1] = "당신은 빌을 해치웠습니다. 그의 보물들은 이제 당신의 것입니다."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then who:setQuestStatus(self.id, engine.Quest.DONE) end
end

on_grant = function(self)
	if game.level.level == 3 then
		self:enter_level3()
	end
end

enter_level3 = function(self)
	if game.level.hidden_way_to_bill then return end

	-- Reveal entrance to level 4
	local g = game.zone:makeEntityByName(game.level, "terrain", "GRASS_DOWN6"):clone()
	g.name = "way to the hidden trollmire treasure"
	g.kr_display_name = "트롤 늪의 숨겨진 보물이 있는 곳으로 가는 길",
	g.desc = "조심하십시오!"
	g.change_level_check = function()
		require("engine.ui.Dialog"):yesnoPopup("위험...", "이 길은 강력한 트롤이 있는 곳과 연결되어 있습니다. 주변에 피의 흔적이 가득합니다. 정말 가시겠습니까?", function(ret)
			if ret then game:changeLevel(4) end
		end, "예", "아니오")
		return true
	end
	local level = game.level
	local spot = level.default_down
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
	level.hidden_way_to_bill = true

	require("engine.ui.Dialog"):simplePopup("숨겨진 보물", "보물로 가는 길은 동쪽에 있는 것 같습니다. 하지만 조심하십시오. 그곳에 기다리고 있는 것은 죽음일지도 모릅니다.")
end
