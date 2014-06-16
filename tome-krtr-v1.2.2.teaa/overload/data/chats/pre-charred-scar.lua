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
	text = [[*#LIGHT_GREEN#갑자기 당신의 머리 속에서 목소리가 들립니다.#WHITE#*
@playername7@여, 태양의 장벽의 고위 태양의 기사, 아에린입니다. 아노리실의 힘을 빌어 그대와 대화를 하고 있습니다.
그대에게 전해줄 긴급한 정보가 있습니다. 그대가 찾던 지팡이의 행방을 찾아냈습니다.]],
	answers = {
		{"어딥니까?!", jump="where"},
	}
}

newChat{ id="where",
	text = [[우리 순찰대 중 하나의 말에 의하면, 대륙 남쪽 에류안 사막 부근에서 오크들의 수상한 움직임이 있었다고 합니다.
많은 수의 오크들이 무언가를 지키고 있었다고 하는데, 그 생김새가 그대가 말한 지팡이와 유사했다고 합니다.
가서 조사를 해보십시오. 아마 이 기회가 그대의 유일한 기회가 될 것 같습니다.]],
	answers = {
		{"지금 당장 가도록 하죠!"},
	}
}
return "welcome"
