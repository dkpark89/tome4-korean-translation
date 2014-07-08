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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/burntland.lua")

newEntity{ base = "ALTAR",
	define_as = "ALTAR_CORRUPT",
	on_move = function(self, x, y, who)
		if not who.player then return end
		local o, item, inven = who:findInAllInventoriesBy("define_as", "SANDQUEEN_HEART")
		if not o then return end

		require("engine.ui.Dialog"):yesnoPopup("지렁이 여왕의 심장", "제단이 심장에 대해서 반응하는 것 같습니다. 심장을 여기서 타락시킬 수 있을 것 같습니다.", function(ret)
			if ret then return end
			local o = game.zone:makeEntityByName(game.level, "object", "CORRUPTED_SANDQUEEN_HEART", true)
			if o then
				who:removeObject(inven, item, true)
				o:identify(true)
				who:addObject(who.INVEN_INVEN, o)
				who:sortInven(who.INVEN_INVEN)
				game.log("#GREEN#당신은 제단에 심장을 놓았습니다. 그러자 심장은 새로운 타락의 힘으로 인해 쭈그러들면서 뒤흔들리고 진동했습니다.")
			end
		end, "취소", "타락시킴", nil, true)
	end,
}
