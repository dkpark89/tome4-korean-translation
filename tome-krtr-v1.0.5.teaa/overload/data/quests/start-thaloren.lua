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

name = "Madness of the Ages"
kr_name = "시대의 광기"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "탈로레의 숲은 타락했습니다. 오염이 번지고 있습니다. 수호자였던 곰 노르고스는 미쳐버렸다고 합니다.\n"
	desc[#desc+1] = "숲의 서쪽 경계에는 음울한 기운이 생겨나고 있습니다. 그곳에 있는 것들은... 뒤틀렸습니다.\n"
	if self:isCompleted("norgos") then
		if self:isCompleted("norgos-invaded") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 노르고스 동굴을 탐험하여, 쉬브고로스의 침략을 막았습니다.#WHITE#"
		else
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 노르고스 동굴을 탐험하여, 그에게 안식을 안겨줬습니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '노르고스 동굴' 을 탐험해야 합니다.#WHITE#"
	end
	if self:isCompleted("heart-gloom") then
		if self:isCompleted("heart-gloom-purified") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 어둠의 심장을 탐험하여, 꿈꾸는 자를 죽였습니다.#WHITE#"
		else
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 어둠의 심장을 탐험하여, 시듦의 원천을 죽였습니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '어둠의 심장' 을 탐험해야 합니다.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("norgos") and self:isCompleted("heart-gloom") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-zones")
		end
	end
end
