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

local function recharge(npc, player)
	player:showEquipInven("재충전할 물건을 고르시오", function(o) return o.recharge_cost and o.power and o.max_power and o.power < o.max_power end, function(o, inven, item)
		local cost = math.ceil(o.recharge_cost * (o.max_power / (o.use_talent and o.use_talent.power or o.use_power.power)))
		if cost > player.money then require("engine.ui.Dialog"):simplePopup("금화가 부족합니다", "비용으로 금화가 "..cost.." 개 필요합니다.") return true end
		require("engine.ui.Dialog"):yesnoPopup("재충전합니까?", "비용으로 금화 "..cost.." 개가 필요합니다.", function(ok) if ok then
			o.power = o.max_power
			player:incMoney(-cost)
			player.changed = true
		end end, "예", "아니오")
		return true
	end)

end

newChat{ id="welcome",
	text = [[@playername@씨, 제 가게에 오신것을 환영합니다.]],
	answers = {
		{"자네가 가진 물건들을 보여주게.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"내 장비중 몇가지를 재충전하고 싶은데.", action=recharge},
		{"미안, 난 가봐야 할 것 같군!"},
	}
}

return "welcome"
