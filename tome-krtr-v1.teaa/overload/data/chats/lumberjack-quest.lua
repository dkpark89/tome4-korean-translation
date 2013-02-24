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
	text = [[#LIGHT_GREEN#*당신 앞에 흙과 피로 칠갑이 된 사람이 나타났습니다. 그는 지금 당장이라도 숨이 넘어갈 듯이 보이며, 반쯤 미쳐있습니다.*#WHITE#
부탁드립니다! 제발 도와주십시오! #{bold}#그놈#{normal}#이 제 마을에 있는 사람들을 마구잡이로 학살하고 있습니다! 제발!
#LIGHT_GREEN#*그는 손가락으로 근처에 있는 숲을 가리킵니다.*#WHITE#]],
	answers = {
		{"제가 가서 뭐라도 해보겠습니다.", action=function(npc, player) player:grantQuest("lumberjack-cursed") end},
		{"그건 내가 상관할 일이 아니다. 썩 꺼져!"},
	}
}

return "welcome"
