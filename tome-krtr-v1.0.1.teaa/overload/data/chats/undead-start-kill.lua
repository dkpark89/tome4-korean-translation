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
	text = [[#LIGHT_GREEN#*그가 바닥에 무릎을 꿇습니다.*#WHITE#
제발 살려줘! 나도 알고보면 불쌍한 사람이야. 이제 너를 붙잡지 않을테니. 나를 놓아줘!]],
	answers = {
		{"허나 거절한다!", jump="welcome2"},
	}
}

newChat{ id="welcome2",
	text = [[하지만, 하지만 너는 내... 너...
너는 내가 필요해! 네가 지상에서 무슨 일을 할 수 있을거라 생각하는건데? 너를 발견하는 사람들은 모두 언데드인 너를 죽이려고 들걸?
너는 강하지만, 너 혼자서 그들을 다 쓰러뜨릴 수는 없어!]],
	answers = {
		{"그래서, 네 녀석의 목적은?", jump="what"},
		{"[그를 죽인다]", action=function(npc, player)
			npc.die = nil
			npc:doEmote("으아아아악... 하지만 이곳에 있는 언데드는 너 뿐만이 아니다! 너는 곧 파괴될 것이다!", 60)
			npc:die(player)
		end},
	}
}

newChat{ id="what",
	text = [[난 너에게 네 정체를 숨길 수 있는 망토를 줄 수 있어!
이것만 있으면 네 주위의 사람들은 너를 평범한 사람으로 보게 되고, 너는 지상에서 하고 싶은 일을 마음껏 할 수 있어!
Please!]],
	answers = {
		{"정보에 대해선 감사를 표하도록 하지. 이제 죽어줘야겠다. [그를 죽인다]", action=function(npc, player)
			npc.die = nil
			npc:doEmote("으아아아악... 하지만 이곳에 있는 언데드는 너 뿐만이 아니다! 너는 곧 파괴될 것이다!", 60)
			npc:die(player)
		end},
	}
}

return "welcome"
