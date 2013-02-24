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
	text = [[#LIGHT_GREEN#*당신은 오브에 손을 가져다 대었습니다.*#WHITE#
전투에 참가하시려면 금화 150 개를 지불하셔야 합니다.]],
	answers = {
		{"[금화 150 개를 지불한다]", jump="pay",
			cond=function(npc, player)
				return player:hasQuest("ring-of-blood") and player:hasQuest("ring-of-blood"):find_master() and player.money >= 150
			end,
			action=function(npc, player) player:incMoney(-150) end
		},
		{"[떠난다]"},
	}
}

newChat{ id="pay",
	text = [[전투가 시작됩니다!]],
	answers = {
		{"한번 해보자고!", action=function(npc, player) player:hasQuest("ring-of-blood"):start_game() end},
	}
}

return "welcome"
