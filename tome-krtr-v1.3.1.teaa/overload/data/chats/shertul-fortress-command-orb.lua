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

local has_rod = function(npc, player)
	return player:findInAllInventoriesBy("define_as", "ROD_OF_RECALL") and not player:isQuestStatus("shertul-fortress", engine.Quest.COMPLETED, "butler")
end
local read = player:attr("speaks_shertul")

newChat{ id="welcome",
	text = [[*#LIGHT_GREEN#에이알 세계 전체를 보여주고 있는 오브입니다. 아마 이 요새를 제어할 때 사용하는 오브 같습니다.
]]..(not read and [[글자가 적혀 있지만, 모르는 문자입니다.#WHITE#*
#{italic}#"Rokzan krilt copru."#{normal}#]] or [[#WHITE#*#{italic}#"제어의 장대를 넣으시오."#{normal}#]]),
	answers = {
		{"[오브를 조사한다]", jump="examine", cond=has_rod},
		{"[요새의 비행을 시작한다 -- #LIGHT_RED#시험용으로만#LAST#]", action=function(npc, player) player:hasQuest("shertul-fortress"):fly() end, cond=function() return config.settings.cheat end},
		{"[리치의 의식을 시작한다]", cond=function(npc, player) local q = player:hasQuest("lichform") return q and q:check_lichform(player) end, action=function(npc, player) player:setQuestStatus("lichform", engine.Quest.COMPLETED) end},
		{"[오브를 놔두고 떠난다]"},
	}
}

newChat{ id="examine",
	text = [[*#LIGHT_GREEN#이 오브는 순수한 수정으로 만들어진 것 같으며, 지금까지 알려진 세계의 지도를 아주 정확하게 그려내고 있습니다. 금지된 땅인, 남쪽 대륙까지 포함해서 말이죠.
되돌림의 장대와 딱 맞는 모양과 크기의 구멍이 뚫려 있습니다.#WHITE#*]],
	answers = {
		{"[장대를 집어넣는다]", jump="activate"},
		{"[오브를 놔두고 떠난다]"},
	}
}
newChat{ id="activate",
	text = [[*#LIGHT_GREEN#장대를 오브 근처에 가져다 대자, 오브가 진동하면서 반응합니다.
갑자기 방의 구석진 곳에서 그림자가 나타났습니다! 당신은 장대를 즉시 멀리 떨어뜨렸지만, 그림자는 사라지지 않습니다.
이 그림자는 이곳으로 오면서 당신과 싸운 공포들과 비슷하게 생겼지만, 부패의 정도가 덜한 것 같습니다.
다른 공포들과는 달리 약간이나마 인간의 형체를 띄고 있지만, 이것도 머리가 없으며 팔다리는 촉수처럼 생겼습니다. 적대적인 존재는 아닌 것 같습니다.#WHITE#*]],
	answers = {
		{"[오브를 놔두고 떠난다]", action=function(npc, player)
			player:hasQuest("shertul-fortress"):spawn_butler()
		end,},
	}
}

return "welcome"
