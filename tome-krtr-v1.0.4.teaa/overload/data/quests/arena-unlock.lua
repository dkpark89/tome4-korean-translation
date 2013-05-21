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

name = "The agent of the arena"
kr_name = "투기장의 중개인"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 한 도적으로부터, 투기장의 참가자격을 위해 전사로서의 가치를 증명해 보이라는 요구를 받았습니다."
	if self:isCompleted() then
		desc[#desc+1] = "당신은 성공적으로 적들을 물리쳤고, 투기장에 참가할 자격을 얻었습니다!"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then who:setQuestStatus(self.id, engine.Quest.DONE) end
end
