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

-- Quest for the the breeding pits
name = "Desperate Measures"
kr_name = "극단적 조치"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 죽어가는 태양의 기사를 만났고, 그에게서 진정한 혐오체가 존재하는 오크 번식용 동굴에 대한 이야기를 들었습니다."
	if self:isStatus(engine.Quest.COMPLETED, "wuss-out") then
		desc[#desc+1] = "아에린이 이에 대한 대처를 할 수 있도록, 당신은 그녀에게 이 정보를 보고하기로 결심했습니다."
		if self:isStatus(engine.Quest.COMPLETED, "wuss-out-done") then
			desc[#desc+1] = "아에린은 그에 대한 대처로 파병을 할 것이라 말했습니다."
		end
	else
		desc[#desc+1] = "당신은 스스로의 힘으로 그 곳을 정화하여 오크들에게 끔찍한 일격을 가하기로 결정했습니다."
		if self:isStatus(engine.Quest.COMPLETED, "genocide") then
			desc[#desc+1] = "혐오체의 처리가 완료되었습니다."
		end
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end

reveal = function(self)
	local spot = game.level:pickSpot{type="world-encounter", subtype="orc-breeding-pits-spawn"}
	if not spot then return end

	local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN):cloneFull()
	g.name = "Entrance to the orc breeding pit"
	g.kr_name = "오크 번식용 동굴로의 입구"
	g.display='>' g.color_r=colors.GREEN.r g.color_g=colors.GREEN.g g.color_b=colors.GREEN.b g.notice = true
	g.change_level=1 g.change_zone="orc-breeding-pit" g.glow=true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/ladder_down.png"}
	g:altered()
	g:initGlow()
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
	return true
end
