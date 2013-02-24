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

newChat{ id="welcome",
	text = [[고맙네, @playername@! 제국의 부를 위해 우리 둘 다 살아남았군. 나는 이 소식을 알린 다음, 휴식을 취해야 겠네.
다시는 그렇게 죽음이 임박한 상황에 처하고 싶지 않군 그래.
그럼 잘있게.]],
	answers = {
		{"제국을 위하여! 잘 있게나.", action=function(npc, player)
			npc:disappear()
			world:gainAchievement("NORGAN_SAVED", player)
		end},
	}
}

return "welcome"
