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

local iname = iname
local idata = idata
local obj = obj
local inven = inven
local item = item
local replace_same = replace_same
local answers = {}

for i = 1, player.max_inscriptions do
	local name = player.inscriptions[i]
	if (not replace_same or replace_same.."_"..i == name) then
		local t = player:getTalentFromId("T_"..name)
		answers[#answers+1] = {t.name, action=function(npc, player)
			player:setInscription(i, iname, idata, true, true, {obj=obj}, replace_same)
			player:removeObject(inven, item)
		end, on_select=function(npc, player)
			game.tooltip_x, game.tooltip_y = 1, 1
			game:tooltipDisplayAtMap(game.w, game.h, "#GOLD#"..t.name.."#LAST#\n"..tostring(player:getTalentFullDescription(t)))
		end, }
	end
end

if not replace_same and player.inscriptions_slots_added < 2 and player.unused_talents_types > 0 then
	answers[#answers+1] = {"#{bold}#기술 계열 점수#{normal}#로 각인의 제한을 늘릴 수 있습니다.", action=function(npc, player)
		player.unused_talents_types = player.unused_talents_types - 1
		player.max_inscriptions = player.max_inscriptions + 1
		player.inscriptions_slots_added = player.inscriptions_slots_added + 1
		player:setInscription(nil, iname, idata, true, true, {obj=obj})
		player:removeObject(inven, item)
	end}
end

answers[#answers+1] = {"취소"}

newChat{ id="welcome",
	text = replace_same and [[당신은 같은 종류의 각인을 너무 많이 새기려고 했습니다. 더 이상 같은 각인을 추가로 새길 수는 없으며, 이미 새겼던 각인과 바꿀 수만 있습니다. 각인을 바꿀 경우, 이전에 새겼던 각인은 사라지게 됩니다.]]
	or [[당신은 최대 각인 제한에 다다랐습니다. (주입물 / 룬 포함)
만약 아직 사용하지 않은 #{bold}#기술 계열 점수#{normal}#가 있다면, 이것을 사용해서 추가로 각인을 새길 수 있습니다. (최대 각인 제한은 5 개)
이미 새겼던 각인들 중 하나를 없애고, 새로운 각인을 새길 수도 있습니다.
단, 이 경우 이전에 새겼던 각인은 사라지게 됩니다.]],
	answers = answers,
}

return "welcome"
