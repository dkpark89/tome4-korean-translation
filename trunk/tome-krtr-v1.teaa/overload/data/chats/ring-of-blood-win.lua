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
	text = [[그래서, 피의 맛은 충분히 보셨습니까? 만족하셨습니까? 그랬으리라고 확신하지요. 당신은 그런 부류의 사람이니까요.
어찌 됐건, 당신에게 말했던 상품을 드려야겠군요.
원하신다면, 언제든지 다시 오셔도 좋습니다. 금화가 충분하시다면요.]],
	answers = {
		{"고맙네, 재미있었어!", action=function(npc, player) player:hasQuest("ring-of-blood"):reward(player) end},
	}
}

return "welcome"
