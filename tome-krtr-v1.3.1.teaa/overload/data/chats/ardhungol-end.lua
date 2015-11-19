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
	text = [[#LIGHT_GREEN#*그 괴물 같던 거미가 쓰러지자, 당신은 무언가를 발견하였습니다... 그녀의 뱃속이 꾸물거리더니, 갑자기 폭발했습니다! 키 큰 흑인 남성이 뿜어져 나온 내장들을 밟으며 걸어나왔습니다. 그의 주변에서 찬란한 금색 빛이 나고 있습니다.*#WHITE#
태양의 이름으로! 다시는 사람의 얼굴을 볼 수 없을 줄 알았는데!
감사합니다. 제 이름은 라심이라고 합니다. 당신에게 빚을 졌군요.
]],
	answers = {
		{"당신의 아내가 보내서 왔습니다. 그녀는 당신을 걱정하고 있었습니다.", jump="leave"},
	}
}

newChat{ id="leave",
	text = [[아, 나의 사랑스러운 아내여!
어쨌든, 이제 자유가 됐으니 아침의 문으로 가는 관문을 만들 수 있습니다. 제가 살면서 평생 볼 거미들을 요 며칠 사이에 다 본 것 같군요.]],
	answers = {
		{"자, 갑시다!", action=function(npc, player) player:hasQuest("spydric-infestation"):portal_back(player) end},
	}
}

return "welcome"
