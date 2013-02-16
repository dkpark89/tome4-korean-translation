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
	text = [[#LIGHT_GREEN#*당신이 멈추기 전 흙과 피로 칠갑이 된 사람이 나타납니다. 그는 반쯤 탈진해있고 넋도 나가있는 듯 합니다.*#WHITE#
제발! 당신이 꼭 도와주셔야 합니다! #{bold}#그 녀석#{normal}# 이 마을에 살고있는 사람들을 모두 죽이고 있습니다! 제발 도와주십시오!
#LIGHT_GREEN#*그는 손가락으로 근방의 숲쪽을 가리킨다.*#WHITE#]],
	answers = {
		{"제가 가서 뭔가 할 수 있는지 한번 알아보죠.", action=function(npc, player) player:grantQuest("lumberjack-cursed") end},
		{"그건 내가 상관할바가 아니니. 저리 가버려!"},
	}
}

return "welcome"
