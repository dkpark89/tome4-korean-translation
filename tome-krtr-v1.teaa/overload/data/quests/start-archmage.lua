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

name = "Spellblaze Fallouts"
kr_display_name = "스펠블레이즈의 낙오자들"
stables = 0
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "수줍은 광활(The Abashed Expanse)는 에이알(Eyal)의 일부로, 스펠블레이즈(the Spellblaze)에 의해 떨어져나가 별들 사이의 공허로 내던져졌습니다.\n"
	desc[#desc+1] = "그것은 최근 불안정해지기 시작했고, 앞을 가로막는 것들을 모조리 파괴하며 에이알(Eyal)을 향해 날아오고 있습니다.\n"
	desc[#desc+1] = "당신은 그 안에 들어가 웜홀에 아무 주문이나 발사하여 세 개의 웜홀을 안정화 해야합니다.\n"
	desc[#desc+1] = "조심하십시오. 그 떠돌이 섬은 불안정하기 때문에 무작위로 공간이동을 당할 수도 있습니다. 하지만 나쁜 점만 있는것은 아닙니다. 당신은 레벨에 상관없이 근거리 공간이동 주문(Phase Door)을 완벽히 제어할 수 있게됩니다.\n"
	if self:isCompleted("abashed") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 광활(the expanse)을 탐험하여 세 개의 웜홀을 모두 닫았습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 "..self.stables.." 웜홀을 닫았습니다.#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("abashed") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			world:gainAchievement("ABASHED_EXPANSE", game.player)
			who:grantQuest(who.archmage_race_start_quest)
		end
	end
	if status == self.FAILED then
		who:grantQuest(who.archmage_race_start_quest)
	end
end

on_grant = function(self, who)
	local npc
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "TARELION" then npc = e break end
	end
	if not npc then return end
	local x, y = util.findFreeGrid(npc.x, npc.y, 10, true, {[engine.Map.ACTOR]=true})
	if not x or not y then return end

	who:move(x, y, true)

	local Chat = require"engine.Chat"
	local chat = Chat.new("tarelion-start-archmage", npc, who)
	chat:invoke()
end

stabilized = function(self)
	self.stables = self.stables + 1
end
