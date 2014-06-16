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

name = "Future Echoes"
kr_name = "미래의 메아리"
stables = 0
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "부정한 저습지는 영점 주변에 있는 '지역' 의 이름입니다."
	desc[#desc+1] = "그곳에 사는 시간의 거미들은 쉴 새 없이 자라면서, 아무나 닥치는대로 공격하기 시작했습니다. 당신은 그곳에서 무슨 일이 일어나고 있는지 조사해야 합니다."
	if self:isCompleted("morass") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 저습지를 탐험하여, 무당거미 여왕을 처치했습니다. 이 거미에게서 이상한 흔적을 찾아내었습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 '부정한 저습지' 를 탐험해야 합니다.#WHITE#"
	end
	if self:isCompleted("saved") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 영점을 지켜냈습니다.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("saved") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			world:gainAchievement("UNHALLOWED_MORASS", game.player)
			who:grantQuest(who.chronomancer_race_start_quest)
		end
	end
	if status == self.FAILED then
		who:grantQuest(who.chronomancer_race_start_quest)
	end
end

on_grant = function(self, who)
	local npc
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "ZEMEKKYS" then npc = e break end
	end
	if not npc then return end
	local x, y = util.findFreeGrid(npc.x, npc.y, 10, true, {[engine.Map.ACTOR]=true})
	if not x or not y then return end

	who:move(x, y, true)

	local Chat = require"engine.Chat"
	local chat = Chat.new("zemekkys-start-chronomancers", npc, who)
	chat:invoke()
end
