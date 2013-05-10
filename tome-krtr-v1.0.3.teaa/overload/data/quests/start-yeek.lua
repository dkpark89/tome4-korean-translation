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

name = "Following The Way"
kr_name = "'한길' 을 따라서"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 이크들을 위협하는 두 무리를 제거하라는 임무를 받았습니다.\n"
	desc[#desc+1] = "'한길' 을 보호하고, 적을 물리치십시오.\n"
	if self:isCompleted("murgol") then
		if self:isCompleted("murgol-invaded") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 수중지역을 탐험하여, 나가 침략자인 숙녀 나쉬바를 물리쳤습니다.#WHITE#"
		else
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 수중지역을 탐험하여, 무르골을 물리쳤습니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 '무르골의 수중동굴' 을 탐험해야 합니다.#WHITE#"
	end
	if self:isCompleted("ritch") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 릿치 터널을 탐험하여, 그들의 여왕을 물리쳤습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 '릿치 터널' 을 탐험해야 합니다.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("ritch") and self:isCompleted("murgol") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("rel-tunnel")
			game.logPlayer(game.player, "당신은 마즈'에이알로 향하는 터널로 가서, 세상을 탐험해야 합니다.")
		end
	end
end
