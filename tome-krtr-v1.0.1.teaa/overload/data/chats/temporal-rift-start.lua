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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*키 크고, 마치 별과 같이 빛나는 남자가 갑자기 나타났습니다.*#WHITE#
오 이런, 또 다른 *모험가* 로군! 자신의 이해력을 뛰어넘는 것들을 마구 어지럽히면 안된다네!
특히 시간과 관련된 일에는 간섭하면 안된다네. 시간은 아주 빠르게 지나가고 약간의 충격에도 쉽게 방해받거든!
#LIGHT_GREEN#*그는 당신을 보다 가까이서 살펴봅니다.*#WHITE#
자네라면 가능할 것 같군. 나를 도와주게. 내가 시간의 흐름을 바로잡는 동안, 저 괴물들과 싸워주게. 자네가 이곳에서 나가는 길은 그것 뿐이라네!]],
	answers = {
		{"하지만 이것들은 대체 뭐...", action = function(npc, player) game:changeLevel(2) game.player:grantQuest("temporal-rift") end},
	}
}

return "welcome"
