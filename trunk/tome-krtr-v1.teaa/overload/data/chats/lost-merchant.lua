﻿-- ToME - Tales of Maj'Eyal
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
	text = [[살려주세요! 저를 살려주시면 전 무엇이든지..
*#LIGHT_GREEN#'암살단 단장'이 상인의 얼굴을 쳤습니다.#WHITE#*닥쳐!]],
	answers = {
		{"미안, 난 가봐야 할 것 같아!", action = function(npc, player) npc.can_talk = nil end},
	}
}

newChat{ id="welcome2",
	text = [[저좀 여기서 내보내주세요!]],
	answers = {
		{"이리와, 여기에 나가는 길이 있어!", action = function(npc, player) npc.can_talk = nil npc.cant_be_moved = nil end},
	}
}

if game.player:hasQuest("lost-merchant") and game.player:hasQuest("lost-merchant"):is_assassin_alive() then
	return "welcome"
else
	return "welcome2"
end
