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

name = "From Death, Life"
kr_name = "죽음에서, 삶으로"
stables = 0
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "이 필멸자들의 세상에서 벌어지는 일들은 당신의 진정한 목적 - 죽음을 정복하는 것 - 에 비하면 사소한 것일 뿐입니다."
	desc[#desc+1] = "당신은 연구를 통해 이 주제에 대한 것을 대부분 밝혀냈지만, 이 영광스러운 재탄생을 위해서는 준비해야 할 것이 있습니다."
	desc[#desc+1] = "필요한 것은 다음과 같습니다 :"

	if who.level >= 20 then desc[#desc+1] = "#LIGHT_GREEN#* 당신은 충분한 경험을 쌓았습니다.#WHITE#"
	else desc[#desc+1] = "#SLATE#* 이 의식을 위해서는 자신이 가치 있고, 경험이 충만하며, 어느 정도의 힘을 가지고 있다는 것을 보일 필요가 있습니다.#WHITE#" end

	if self:isCompleted("heart") then desc[#desc+1] = "#LIGHT_GREEN#* 당신은 다른 사령술사로부터 심장을 '추출' 해냈습니다.#WHITE#"
	else desc[#desc+1] = "#SLATE#* 강력한 사령술사의 맥동하는 심장이 필요합니다.#WHITE#" end

	if who:isQuestStatus("shertul-fortress", self.COMPLETED, "butler") then
		desc[#desc+1] = "#LIGHT_GREEN#* 쉐르'툴 요새 이일크구르가 적당한 장소일 것 같습니다.#WHITE#"

		if who:hasQuest("shertul-fortress").shertul_energy >= 40 then
			desc[#desc+1] = "#LIGHT_GREEN#* 이일크구르에 충분한 에너지가 있습니다.#WHITE#"

			if who:knowTalent(who.T_LICHFORM) then desc[#desc+1] = "#LIGHT_GREEN#* 이제 당신은 리치의 길을 걷게 되었습니다.#WHITE#"
			else desc[#desc+1] = "#SLATE#* 이일크구르의 제어 오브를 사용해서 의식을 시작할 수 있습니다.#WHITE#" end
		else desc[#desc+1] = "#SLATE#* 당신의 재탄생을 위해서는 충분한 양의 에너지가 필요합니다. (40 에너지)#WHITE#" end
	else
		desc[#desc+1] = "#SLATE#* 외딴 곳이며 에너지를 끌어모을 수 있는, 적합한 장소가 의식에 필요합니다.#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:learnTalent(who.T_LICHFORM, true, 1, {no_unlearn=true})
		require("engine.ui.Dialog"):simplePopup("리치 변신", "죽음의 비밀이 당신 앞에 모습을 드러냈습니다! '리치 변신' 기술을 사용할 수 있게 되었습니다!")
	end
end

check_lichform = function(self, who)
	if self:isStatus(self.DONE) then return end
	if who.level < 20 then return end
	if not self:isCompleted("heart") then return end
	local q = who:hasQuest("shertul-fortress")
	if not q then return end
	if not q:isCompleted("butler") then return end
	if q.shertul_energy < 40 then return end
	if not who:knowTalentType("spell/necrosis") then return end

	return true
end
