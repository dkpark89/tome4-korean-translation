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

newChat{ id="kyless",
	text = [[#VIOLET#*킬레스는 죽기 직전인 상태로 땅에 쓰러져 있습니다. 그의 손에는 책 한 권이 들려있습니다.*#LAST#
부탁이네! 내가 죽기 전에, 마지막 한 가지 부탁만 들어주게. 이 책을 파괴해주게. 그것은 내가 아니였네. 이 책이 우리를 이렇게 만들었네. 이 책은 파괴되어야 하네!]],
	answers = {
		{
			"그러죠. #LIGHT_GREEN#[책을 파괴한다]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_good_choice(player)
			end,
			jump="destroy_book"
		},
		{
			"미안하게 됐지만, 저도 이 책이 필요합니다. #LIGHT_GREEN#[책을 파괴하지 않는다]#LAST#",
			action=function(npc, player)
				player:hasQuest("keepsake"):on_evil_choice(player)
				player:hasQuest("keepsake"):on_keep_book(player)
			end,
			jump="keep_book"
		}
	}
}

newChat{ id="destroy_book",
	text = [[#VIOLET#*당신은 책을 파괴했습니다. 그 일을 끝낸 당신은, 킬레스가 이미 죽어있는 것을 발견했습니다.*#LAST#]],
	answers = {
		{"잘 있게, 킬레스."},
	}
}

newChat{ id="keep_book",
	text = [[#VIOLET#*당신은 책을 챙겼습니다. 그 일을 끝낸 당신은, 킬레스가 이미 죽어있는 것을 발견했습니다.*#LAST#]],
	answers = {
		{"잘 있게, 킬레스."},
	}
}

return "kyless"
