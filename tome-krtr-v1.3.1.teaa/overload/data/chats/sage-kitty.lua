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
	text = [[#LIGHT_GREEN#*당신 앞에 작고 귀여운 오렌지색 고양이가 서있습니다. 고양이는 배고파 보이며, 당신을 쳐다보고 있습니다.*#WHITE#
야오오옹?
]],
	answers = {
		{"와, 고양이잖아!", jump="kitty"},
		{"고양이에게 쓸 시간은 없어!"},
	}
}

newChat{ id="kitty",
	text = [[#LIGHT_GREEN#*고양이가 당신의 다리를 부비면서 가르랑거립니다.*#WHITE#
가르르르르릉.
]],
	answers = {
		{"흠, 혹시 이 맛있게 생긴 트롤 내장 좋아하니? #LIGHT_GREEN#[내장을 먹이로 준다]#WHITE#", jump="pet", cond=function(npc, player) return game.party:hasIngredient("TROLL_INTESTINE") end},
		{"미안, 작은 친구. 너를 도와줄 수 없을 것 같아."},		
	}
}

newChat{ id="pet",
	text = [[#LIGHT_GREEN#*먹이를 다 먹은 고양이는 행복해보입니다. 잠시 후, 고양이가 주위를 거닐기 시작했습니다. 당신은 언제부턴가 고양이가 어디로 갔는지 놓쳐버렸습니다.*#WHITE#]],
	answers = {
		{"#LIGHT_GREEN#[떠난다]", action=function(npc, player)
			game.state.kitty_fed = true
		end},		
	}
}

return "welcome"
