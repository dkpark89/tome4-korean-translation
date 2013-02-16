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
	text = [[#LIGHT_GREEN#*그는 그의 무릎을 바닥에 떨어뜨립니다.*#WHITE#
제발 살려줘! 나도 불쌍한 사람이라고. 이제 널 멈추지 않을테니. 날 떠나게 해줘!]],
	answers = {
		{"허나 거절한다!", jump="welcome2"},
	}
}

newChat{ id="welcome2",
	text = [[그러나, 그러나, 너는 내... 너...
넌 내가 필요해! 네 녀석이 지상에서 무슨 일을 할 수 있을거라 생각해? 네 녀석을 보는 것들은 모두 네 녀석을 죽이려고 들 걸.
넌 강하지만 너 혼자서 그들을 다 쓰러뜨릴 순 없을걸!]],
	answers = {
		{"그래서, 네 녀석의 목적이 뭐냐?", jump="what"},
		{"[그를 죽인다]", action=function(npc, player)
			npc.die = nil
			npc:doEmote("아아아악... 넌 혼자야! 넌 파괴 될 거야!", 60)
			npc:die(player)
		end},
	}
}

newChat{ id="what",
	text = [[난 너에게 네 정체를 숨길 수 있는 망토를 줄 수 있어!
이것만 있으면 네 주위의 사람들은 너를 평범한 사람으로 볼 거야. 이것만 있으면 넌 네 볼일을 볼 수 있을걸.
Please!]],
	answers = {
		{"정보에 대해선 감사하지. 이제 죽어줘야 겠다. [그를 죽인다]", action=function(npc, player)
			npc.die = nil
			npc:doEmote("아아아악... 넌 혼자야! 넌 파괴 될 거야!", 60)
			npc:die(player)
		end},
	}
}

return "welcome"
