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

name = "Serpentine Invaders"
kr_display_name = "음흉한 침략자"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "나가들이 슬라지쉬 늪지(the slazish fens)를 침략합니다. 태양의 장벽(The Sunwall)은 두 전선에서 동시에 싸울 수 없습니다. 너무 늦기전에 당신이 침략자들을 막아야 합니다.\n 침략자들의 포탈을 찾아 파괴하십시오."
	if self:isCompleted("slazish") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 나가 포탈을 파괴했습니다. 침략이 멈췄습니다.#WHITE#"

		if self:isCompleted("return") then
			desc[#desc+1] = "#LIGHT_GREEN#* 당신은 서역 사람들이 극동지역이라 부르던 바르'에이알(Var'Eyal)로 돌아왔습니다.#WHITE#"
		else
			desc[#desc+1] = "#SLATE#* 하지만 당신은 머나먼 땅에 떨어졌습니다. 아침의 문(the Gates of Morning)으로 돌아갈 방법을 찾아야 합니다.#WHITE#"
		end
	else
		desc[#desc+1] = "#SLATE#* 당신은 나가를 막아야합니다.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("return") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
--			who:grantQuest(who.celestial_race_start_quest)
		end
	end
end
