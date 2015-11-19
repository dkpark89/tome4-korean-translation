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
	text = [[#LIGHT_GREEN#*벤이 패배한 채로 당신의 발치에 쓰러졌습니다.*#WHITE#
나...나를 저주에서 구해줘서... *콜록*... 저주에서 구해줘서 고맙네.
나는 이럴... 이런 것을 바란 것이 아니네...
#LIGHT_GREEN#*그는 마지막으로 피를 토하고 죽었습니다, 그의 저주가 사라짐과 동시에, 그의 얼굴에 웃음이 떠오릅니다.*#WHITE#]],
	answers = {
		{"편히 잠들게.", action=function(npc, player) player:setQuestStatus("lumberjack-cursed", engine.Quest.COMPLETED) end},
	}
}

return "welcome"
