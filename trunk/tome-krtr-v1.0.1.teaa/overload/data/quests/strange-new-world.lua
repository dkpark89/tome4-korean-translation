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

name = "Strange new world"
kr_name = "새롭고 낯선 세상"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 장거리 관문을 타고 넘어와, 한 동굴에 도착했습니다. 아마 동대륙으로 넘어온 것 같습니다."
	desc[#desc+1] = "도착과 동시에, 당신은 한 엘프와 오크가 싸우고 있는 것을 발견하였습니다."

	if self:isCompleted("sided-fillarel") then
		desc[#desc+1] = "당신은 엘프 숙녀의 편에 서기로 했습니다."
	elseif self:isCompleted("sided-krogar") then
		desc[#desc+1] = "당신은 오크의 편에 서기로 했습니다."
	end

	if self:isCompleted("helped-fillarel") then
		desc[#desc+1] = "필라렐은 남동쪽으로 가서 고위 태양의 기사 아에린을 만나보라고 말했습니다."
	elseif self:isCompleted("helped-krogar") then
		desc[#desc+1] = "크로가르는 서쪽으로 가서 크룩 무리를 살펴보라고 말했습니다."
	end
	return table.concat(desc, "\n")
end

krogar_dies = function(self, npc)
	if self:isCompleted("sided-fillarel") then game.player:setQuestStatus(self.id, self.COMPLETED, "helped-fillarel")
	else
		game.player:setQuestStatus(self.id, self.COMPLETED, "helped-krogar")
		npc:doEmote(game.player.descriptor.race.." 서쪽으로 가서, 크룩 무리를 찾아라!", 120)
	end
end

fillarel_dies = function(self, npc)
	if self:isCompleted("sided-krogar") then game.player:setQuestStatus(self.id, self.COMPLETED, "helped-krogar")
	else
		game.player:setQuestStatus(self.id, self.COMPLETED, "helped-fillarel")
		npc:doEmote(game.player.descriptor.race..", 남동쪽으로 가서 아에린에게 지금 있었던 일을 말해주십시오!", 120)
	end
end
