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
	text = [[@playername@, 그대에게 맡길 임무가 있다네. 부정한 저습지에 갑자기 거미들이 폭증하고 있다고 하더군.
그곳에 가서 문제의 원인을 찾게.]],
	answers = {
		{"그러겠습니다, 위대한 감시자여.", action=function() game:changeLevel(1, "unhallowed-morass") end},
		{"죄송합니다. 그 일은 할 수 없을 것 같습니다.", action=function(npc, player) player:setQuestStatus("start-point-zero", engine.Quest.FAILED) end},
	}
}

return "welcome"
