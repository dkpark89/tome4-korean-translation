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

name = "The Sect of Kryl-Feijan"
kr_display_name = "크릴-페이얀의 종파"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 어두운 지하실에서 크릴-페이얀이라는 이름의 악마를 숭배하는 자들을 발견했습니다."
	desc[#desc+1] = "그들은 인간을 제물로 삼아, 악마를 이 세계에 불러내려고 하고 있습니다."
	if self:isStatus(self.DONE) then
		desc[#desc+1] = "당신은 사제들을 물리치고 여자를 구했습니다. 그녀는 마지막 희망에 있는 부자 상인의 딸이라고 합니다."
	elseif self:isStatus(self.FAILED) then
		if self.not_saved then
			desc[#desc+1] = "당신은 지하실에서 그녀를 호위하는데 실패했습니다."
		else
			desc[#desc+1] = "당신은 사제들을 제 시간에 물리치지 못했습니다. 그녀의 몸은 안에서 자라고 있던 악마에게 찢겨졌습니다."
		end
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if not sub then
		if self:isStatus(engine.Quest.DONE) then
			game:setAllowedBuild("cosmetic_race_human_redhead", true)
		end
	end
end
