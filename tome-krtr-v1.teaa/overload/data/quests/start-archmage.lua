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
kr_display_name = "마법폭발의 찢겨진 상처"
stables = 0
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "'너무나 광활한 공간' 은 원래 에이알 세계의 일부였지만, 마법폭발에 의해 떨어져 나가 별들 사이의 공허를 떠돌게 되었습니다.\n"
	desc[#desc+1] = "이곳은 최근 불안정해지기 시작하여, 앞을 가로막는 것들을 모조리 파괴하며 에이알 세계를 향해 날아올지도 모른다는 위협을 사람들에게 주기 시작했습니다.\n"
	desc[#desc+1] = "당신은 이곳에 들어가, 세 개의 웜홀을 안정화시키기 위해 알고 있는 공격 마법들을 모조리 퍼부어야 합니다.\n"
	desc[#desc+1] = "그 부유하는 섬들은 불안정하기 때문에, 무작위로 순간이동을 당할 수 있다는 사실을 기억해야 합니다. 하지만 나쁜 점만 있는 것은 아닙니다. 이곳에서는 당신의 낮은 레벨과는 상관 없이, 근거리 순간이동 주문을 완벽히 제어할 수 있게 됩니다.\n"
	if self:isCompleted("abashed") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 광활한 지역을 탐험하여, 세 개의 웜홀을 모두 닫았습니다.#WHITE#"
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
