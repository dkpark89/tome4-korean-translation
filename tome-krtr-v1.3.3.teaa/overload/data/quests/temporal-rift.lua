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

name = "Back and Back and Back to the Future"
kr_name = "다시 또 그리고 한번 더 미래로"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "어떤 알지 못할 종류의 시간적 이상 상황을 통과하자, 당신은 이 또 다른 시간축에 있는 괴물들을 처치해달라는 시간의 감시자를 만났습니다.\n"
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("twin") and self:isCompleted("clone") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			local Chat = require "engine.Chat"
			local chat = Chat.new("temporal-rift-end", {name="Temporal Warden", kr_name="시간의 감시자"}, who)
			chat:invoke()
		end
	end
end
