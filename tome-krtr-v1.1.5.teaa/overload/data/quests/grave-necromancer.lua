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

name = "And now for a grave"
kr_name = "그리고 죽은 자를 위해"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "마지막 희망의 운그롤은, 당신에게 아내의 친구였으며 최근 실종된 셀리아의 행방을 찾아줄 것을 부탁했습니다. 그녀는 남편이 죽은 뒤로, 그가 묻힌 마지막 희망 공동묘지의 능묘를 자주 들렀다고 합니다."
	if self:isCompleted("note") then
		desc[#desc+1] = "당신은 마지막 희망 공동묘지에서 셀리아를 찾던 도중, 쪽지를 하나 발견했습니다. 그 안에는 셀리아가 그녀의 생명을 연장시키기 위해, 어둠의 마법과 관련된 실험들을 하고 있다는 내용이 적혀있었습니다... 그리고 그녀가 임신했다는 사실도 말이죠."
	end
	if self:isCompleted("coffins") then
		desc[#desc+1] = "당신은 셀리아를 추적하여, 그녀의 남편이 묻힌 마지막 희망 공동묘지의 능묘에 왔습니다. 그녀는 이곳에 있는 시체 몇 구에게 자유를 선사한 것 같습니다."
	end
	if self:isCompleted("kill") then
		desc[#desc+1] = "당신은 셀리아가 그녀의 섬뜩한 실험들을 멈추고, 영원한 휴식을 취할 수 있게 만들어줬습니다."
	elseif self:isCompleted("kill-necromancer") then
		desc[#desc+1] = "당신은 그녀의 실패한 실험들을 멈추고, 영원한 휴식을 취할 수 있게 만들어줬습니다. 그리고 자신의 실험을 위해, 그녀의 심장을 챙겼습니다. 그녀처럼 실험을 실패로 만들지는 않을 것입니다."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
