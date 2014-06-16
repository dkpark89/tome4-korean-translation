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

name = "From bellow, it devours"
kr_name = "울림 속의 포식자"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 간신히 레크놀을 탈출하였으며, 이제 당신의 막대한 부와 힘을 원하는 마음은 10 배로 증폭되었습니다."
	desc[#desc+1] = "당신의 모험가 경력을 쌓을 때가 온 것 같습니다. 철의 왕좌 깊은 곳에는 '깊은 울림' 이라는 곳이 있습니다."
	desc[#desc+1] = "오랫동안 봉인된 곳이지만 여전히 존재하는 곳이며, 가끔 모험가들은 부를 위해 이곳에 들어가고는 했습니다."
	desc[#desc+1] = "아직까지는 아무도 살아 돌아오지 못했지만, 당신은 레크놀에서도 살아남았습니다. 당신이라면 가능할 것입니다."
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end
