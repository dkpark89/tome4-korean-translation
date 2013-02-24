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

require "engine.krtrUtils"

newChat{ id="welcome",
	text = [[@playername@씨, 만나서 반갑습니다. 저는 마지막 희망에서 톨락 왕이 보낸 편지를 전해드리기 위해 왔습니다.
당신이 남긴 시체의 흔적들을 따라 왔습니다. 굉장히 인상적이더군요! 당신이 저희 편인 것이 참으로 행운입니다.
더 이상 대화는 됐고, 이 편지를 받으십시오. 저는 이제 가봐야 합니다.
#LIGHT_GREEN#그는 당신에게 봉인된 편지를 주고, 그림자 속으로 사라집니다.#LAST#]],
	answers = {
		{"자네의 용기에 감사하지.", action=function(npc, player)
			local o, item, inven_id = npc:findInAllInventories("Sealed Scroll of Last Hope")
			if o then
				npc:removeObject(inven_id, item, true)
				player:addObject(player.INVEN_INVEN, o)
				player:sortInven()
				game.logPlayer(player, "전령이 당신에게 %s 줬습니다.", o:getName{do_color=true}:addJosa("를"))
			end

			if game.level:hasEntity(npc) then game.level:removeEntity(npc) end
		end},
	}
}

return "welcome"
