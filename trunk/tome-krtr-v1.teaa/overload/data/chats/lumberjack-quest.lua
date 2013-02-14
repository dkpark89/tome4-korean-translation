﻿-- ToME - Tales of Maj'Eyal
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
	text = [[#LIGHT_GREEN#*Before you stands a man covered in dirt and blood. He is out of breath and half mad.*#WHITE#
제발! 당신이 꼭 도와주셔야 합니다! #{bold}#IT#{normal}# is slaughtering everybody in my village! 제발요!
#LIGHT_GREEN#*He points his finger at the nearby forest.*#WHITE#]],
	answers = {
		{"제가 가서 뭔가 할 수 있는지 한번 알아보죠.", action=function(npc, player) player:grantQuest("lumberjack-cursed") end},
		{"This is not my problem. 저리 가버려!"},
	}
}

return "welcome"
