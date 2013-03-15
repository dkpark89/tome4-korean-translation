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

newChat{ id="caravan",
	text = [[#VIOLET#*마지막 상인이 죽기 직전, 당신은 그를 보았습니다. 그의 눈에 차오른 증오를 보았습니다.*#LAST#
우리는 오늘까지만 하면 이 일을 끝낼 수 있었다. 이 자비심 없는 놈아!]],
	answers = {
		{
			"그렇다면 너에게도 내 무자비함을 보여주지. #LIGHT_GREEN#[그를 죽인다]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_evil_choice(player)
				player:hasQuest("keepsake"):on_caravan_destroyed_chat_over(player)
			end
		},
		{
			"미안하게 됐군. #LIGHT_GREEN#[그를 돕는다]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_good_choice(player)
			end,
			jump="apology"
		},
	}
}

newChat{ id="apology",
	text = [[#VIOLET#*당신이 그를 도와주기 전에, 그는 땅에 쓰러져 죽음을 맞이했습니다.*#LAST#]],
	answers = {
		{
			"...",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_caravan_destroyed_chat_over(player)
			end,
		},
	}
}

return "caravan"
