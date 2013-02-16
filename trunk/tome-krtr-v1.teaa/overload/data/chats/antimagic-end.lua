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
	text = [[훌륭했네! 자네는 마법사가 만들어낸 화염 또는 폭풍도 검과 화살에 상대가 되지 않는다는 걸 입증했네! 오게, 우리의 방식을 배우게. 자네는 준비가 됐네.
#LIGHT_GREEN#*그가 당신에게 포션을 건넵니다.*#WHITE#
이걸 마시게. 우리는 매우 희귀한 종류의 드레이크에게서 이 것을 추출해 냈네. 이건 자네에게 마법에 맞서 싸울 수 있고 마법을 취소하는 힘을 줄 걸세, 하지만 자네는 영원히 마법을 사용할 수 없게 됨을 잊지 말게나.]],
	answers = {
		{"감사합니다. 저는 이제부터 마법이 승리하지 않게 할 것입니다! #LIGHT_GREEN#[포션을 마신다]", action=function(npc, player) player:setQuestStatus("antimagic", engine.Quest.COMPLETED) end},
	}
}

return "welcome"
