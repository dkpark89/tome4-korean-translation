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

require "engine.krtrUtils"

newChat{ id="welcome",
	action = function(npc, player) player:attr("invulnerable", 1) end,
	text = [[#LIGHT_GREEN#*키 크고, 마치 별과 같이 빛나는 남자가 갑자기 나타났습니다.*#WHITE#
*그것* 둘을 모두 파괴했나? 이거, 처음 만났을 때 내가 너무 서두른 것 같아 미안하군 그래. 하지만 시간의 흐름을 바로잡는 것은 굉장히 머리 아픈 일이거든.
이제 가봐야겠네. 아직도 할 일이 너무나 많거든. 대신 이걸 받게. 자네에게 도움이 될걸세.
#LIGHT_GREEN#*당신이 답을 하기도 전에 그는 다시 사라졌으며, 관문이 하나 열렸습니다. 마즈'에이알로 통하...는 통로였으면 좋겠다는 생각이 듭니다.*#WHITE#]],
	answers = {
		{"네...", action = function(npc, player)
			player:attr("invulnerable", -1)
			local o = game.zone:makeEntityByName(game.level, "object", "RUNE_RIFT")
			if o then
				o:identify(true)
				game.zone:addEntity(game.level, o, "object")
				player:addObject(player.INVEN_INVEN, o)
				game.log("시간의 감시자가 당신에게 %s 주었습니다.", o:getName{do_color=true}:addJosa("를"))
			end

			game:setAllowedBuild("chronomancer")
			game:setAllowedBuild("chronomancer_temporal_warden", true)

			local g = game.zone:makeEntityByName(game.level, "terrain", "RIFT")
			g.change_level = 3
			g.change_zone = "daikara"
			local oe = game.level.map(player.x, player.y, engine.Map.TERRAIN)
			if oe:attr("temporary") and oe.old_feat then 
				oe.old_feat = g
			else
				game.zone:addEntity(game.level, g, "terrain", player.x, player.y)
			end
		end},
	}
}

return "welcome"
