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

	text = [[#LIGHT_GREEN#*당신과 멜린다는 해변을 거닐며 잠시 휴식을 취했습니다.
공기는 신선하고, 모래는 햇빛을 받아 어른거리며, 파도는 부드럽게 넘실거립니다.*#WHITE#

해변에 온 것은 정말 좋은 선택이었어요!
당신 덕분에 오늘 정말 환상적인 시간을 가질 수 있었어요.

#LIGHT_GREEN#*그녀는 동경의 감정을 담아 당신의 눈을 바라보았습니다.*#WHITE#]],
	answers = {
		{"#LIGHT_GREEN#[몸을 기울여 그녀에게 키스한다]#WHITE#", action=function() game.zone.start_yaech() end, jump="firstbase"},
	}
}

newChat{ id="firstbase",
	text = [[입술이 닿기 직전, 당신은 무언가가 굉장히 잘못된 듯한 기분이 들었습니다.
]],
	answers = {
		{"#LIGHT_GREEN#[계속...]#WHITE#"},
	}
}

return "welcome"
