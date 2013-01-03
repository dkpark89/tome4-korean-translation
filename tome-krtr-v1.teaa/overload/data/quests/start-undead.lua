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

name = "The rotting stench of the dead"
kr_display_name = "망자의 썩은내"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 어떤 암흑의 힘에 의해 언데드로 소환되었습니다."
	desc[#desc+1] = "하지만 의식이 약간 잘못되었고 당신은 자아를 얻었습니다. 당신은 이 어두운 지역에서 벗어나 세상에 자신의 입지를 다져야합니다."
	if self:isCompleted("black-cloak") then
		desc[#desc+1] = "당신은 살아있는 것들 사이를 문제없이 돌아다니게 해주는 아주 특별한 망토를 찾아냈습니다."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("starter-zones")
	end
end

on_grant = function(self, who)
	local npc
	for uid, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "NECROMANCER" then npc = e break end
	end

	local Chat = require"engine.Chat"
	local chat = Chat.new("undead-start-game", npc, who)
	chat:invoke()
	self:setStatus(engine.Quest.COMPLETED, "talked-start")
end
