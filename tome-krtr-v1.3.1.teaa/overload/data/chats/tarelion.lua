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
	text = [[거기 자네 말일세. 그래, 자네, 젊은이!
보아하니 여행길을 걷고 있는 모양인데, 바깥 세상의 온갖 것들을 경험하기 위한 여행 말이야. 상상이 되는군. 여하튼, 이곳에서 배운 우리의 지식을 잊지 말게나. 세상의 부자들은 모두 잘 살고 있지만, 지식의 선물이 없다면 그들이 존재하는 의미는 어디에 있겠는가? 또한 모든 변화는 미래로 나아가기 위한 연구의 재원이 되어야 한다네. 그 이상의 이유는 없지. 알겠는가?]], 
	answers = {
		{"어, 물론이죠... 이제 가보겠습니다."},
		{"잠깐! 당신은... 당신은 밖에서 만났던 그 견습 마법사 아닙니까?", cond=function(npc, player) return player:isQuestStatus("mage-apprentice", engine.Quest.DONE) and player:getCun() >= 35 end, jump="apprentice"},
	}
}

newChat{ id="apprentice",
	text = [[오, 눈치가 빠르군 그래, 애송이! 그렇다네, 그럴 기분이 들면 나는 가끔 견습 마법사 행세를 하며 여행을 다니지. 이를 통해, 나는 다른 사람들의 눈에 띄지 않은 채 내 연구를 진행할 수 있어. 그러다가 앙골웬의 목적에 공감하면서 실력이 있다고 생각되는 사람을 만나면 더 좋고 말이야. 게다가, 꽤 재미있는 일 아닌가!]],
	answers = {
		{"어, 물론이죠... 이제 가보겠습니다."},
	}
}

return "welcome"
