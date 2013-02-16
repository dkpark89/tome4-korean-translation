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
	text = [[#LIGHT_GREEN#*당신이 정신을 차리자 검은 로브를 입은 사람이 보입니다. 보아하니 그는 당신을 무시하고 있는 듯 합니다.*#WHITE#
#LIGHT_GREEN#*당신은 어떤 종류의 소환 마법진 위에 서있습니다, 이 마법진이 당신의 움직임을 방해하는 듯 싶습니다.*#WHITE#
Oh yes! YES, one more for my collection. My collection, yes. A powerful one indeed!]],
	answers = {
		{"[듣는다]", jump="welcome2"},
	}
}

newChat{ id="welcome2",
	text = [[A powerful tool against my enemies. Yes, yes. They all hate me, but I will show them my power!
I will show them! SHOW THEM!]],
	answers = {
		{"나는 도구가 아냐! 날 보내줘!", jump="welcome3"},
	}
}

newChat{ id="welcome3",
	text = [[넌 말할 수 없어. 넌 말해선 안됀다고! 넌 노예야, 도구라고!
넌 내꺼야! 조용히 해!
#LIGHT_GREEN#*As his mind drifts off you notice part of the summoning circle is fading. You can probably escape!*#WHITE#
]],
	answers = {
		{"[공격한다]", action=function(npc, player)
			local floor = game.zone:makeEntityByName(game.level, "terrain", "SUMMON_CIRCLE_BROKEN")
			game.zone:addEntity(game.level, floor, "terrain", 22, 3)
		end},
	}
}

return "welcome"
