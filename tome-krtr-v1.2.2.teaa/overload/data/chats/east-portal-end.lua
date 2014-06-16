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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*관문에서 나오자, 로브를 걸친 인간이 당신을 맞았습니다.*#WHITE#
반갑네, @playername@!
나는 메라나스라고 하네. 앙골웬의 전령이기도 하지. 나는 자네가 돌아오지 않는 것을 염려한 톨락 왕의 명령을 받아, 이곳에 왔다네.
우리는 탄넨을 주시해오고 있었다네. 자네가 그의 본색을 드러내줘서 기쁘군. 그리고 그를 막아준 것도 말이야. 우리는 자네가 한 일에 감사를 느끼고, 아마 그에 대한 보답도 해줄 수 있을 것 같다네.
우리는 그가 조사한 관문에 대한 정보를 연구했네. 나에게 필요한 재료들을 주면, 자네를 위해 장거리 관문을 만들어주겠네. 바로 여기서, 지금 즉시 말일세!]],
	answers = {
		{"아, 탄넨하고는 그다지 친한 사이도 아니였으니까요. 도와주셔서 감사합니다. 여기 재료들이 있습니다. [그에게 단검과 다이아몬드를 준다]", action=function(npc, player) player:hasQuest("east-portal"):create_portal(npc, player) end},
	}
}

return "welcome"
