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

-- Quest for Trollmire & Amon Sul
name = "Of trolls and damp caves"
kr_name = "트롤과 눅눅한 동굴"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "보물과 명예를 찾아, 코르'풀 유적 아래에 있는 동굴과 트롤 늪을 탐험하라!\n"
	if self:isCompleted("trollmire") then
		if self:isCompleted("trollmire-flooded") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 트롤 늪을 탐험하여, 트롤 샥스를 물리쳤습니다.#WHITE#"
		else
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 트롤 늪을 탐험하여, 트롤 프록스를 물리쳤습니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '트롤 늪' 을 탐험해, 그곳에 무슨 위험이 도사리는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	if self:isCompleted("kor-pul") then
		if self:isCompleted("kor-pul-invaded") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 코르'풀 유적을 탐험하여, 잡아먹힌 자를 물리쳤습니다.#WHITE#"
		else
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 코르'풀 유적을 탐험하여, 음영을 물리쳤습니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '코르'풀' 유적을 탐험해, 그곳에 무슨 위험이 도사리는지 밝혀내고 보물을 찾아내야 합니다!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("kor-pul") and self:isCompleted("trollmire") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-zones")
		end
	end
end
