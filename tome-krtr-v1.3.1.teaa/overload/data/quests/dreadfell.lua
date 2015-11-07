-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

-- Quest for the Dreadfell
name = "The Island of Dread"
kr_name = "두려움의 섬"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 검게 탄 상처 북쪽에 '두려움의 영역' 이라고 불리는, 폐허가 된 탑이 하나 있다는 말을 들었습니다."
	desc[#desc+1] = "소문에 의하면 그곳에는 강력한 언데드가 있어, 그곳에 간 사람들은 어느 누구도 살아 돌아오지 못했다고 합니다."
	desc[#desc+1] = "이제 당신이 그곳을 탐험해 진실을 파헤칠 시간입니다. 파헤치는 김에, 보물도 말이지요.""
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		game.state:storesRestock()
	end
end
