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

local change_weapon = function(npc, player)
	local inven = player:getInven("INVEN")
	player:showInventory("골렘이 착용할 양손무기를 선택하세요.", inven, function(o) return o.type == "weapon" and o.twohanded end, function(o, item)
		player:removeObject(inven, item, true)
		local ro = npc:wearObject(o, true, true)
		if ro then
			if type(ro) == "table" then player:addObject(inven, ro) end
		elseif not ro then
			player:addObject(inven, o)
		else
			game.logPlayer(player, "골렘이 착용 중인 장비 : %s", o:getName{do_color=true, no_count=true})
		end
		player:sortInven()
		player:useEnergy()
		return true
	end)
end

local change_armour = function(npc, player)
	local inven = player:getInven("INVEN")
	player:showInventory("골렘이 착용할 갑옷을 선택하세요. (모든 종류 가능)", inven, function(o) return o.type == "armor" and o.slot == "BODY" end, function(o, item)
		player:removeObject(inven, item, true)
		local ro = npc:wearObject(o, true, true)
		if ro then
			if type(ro) == "table" then player:addObject(inven, ro) end
		elseif not ro then
			player:addObject(inven, o)
		else
			game.logPlayer(player, "골렘이 착용 중인 장비 : %s.", o:getName{do_color=true, no_count=true})
		end
		player:sortInven()
		player:useEnergy()
		return true
	end)
end

local change_gem = function(npc, player, gemid)
	local inven = player:getInven("INVEN")
	player:showInventory("골렘에게 박아넣을 보석을 선택하세요.", inven, function(o) return o.type == "gem" and o.material_level and o.material_level <= player:getTalentLevelRaw(player.T_GEM_GOLEM) end, function(o, item)
		o = player:removeObject(inven, item)
		local gems = golem:getInven("GEM")
		local old = golem:removeObject(gems, gemid)
		if old then player:addObject(inven, old) end

		-- Force "wield"
		golem:addObject(gems, o)
		game.logSeen(player, "%s %s의 몸에 %s 박아넣습니다.", (player.kr_name or player.name):capitalize():addJosa("이"), (golem.kr_name or golem.name), o:getName{do_color=true}:addJosa("를"))

		player:sortInven()
		player:useEnergy()
		return true
	end)
end
local change_gem1 = function(npc, player) return change_gem(npc, player, 1) end
local change_gem2 = function(npc, player) return change_gem(npc, player, 2) end

local change_name = function(npc, player)
	local d = require("engine.dialogs.GetText").new("골렘의 이름을 바꿉니다.", "이름", 2, 25, function(name)
		if name then
			npc.name = name.." (servant of "..player.name..")"
			npc.kr_name = name.." ("..(player.kr_name or player.name).."의 부하)"
			npc.changed = true
		end
	end)
	game:registerDialog(d)
end

local ans = {
	{"무기를 바꿔주고 싶은데.", action=change_weapon},
	{"방어구를 바꿔주고 싶은데.", action=change_armour},
	{"이름을 바꿔주고 싶은데.", action=change_name},
	{"아무 것도 아냐. 그냥 가자."},
}

if player:knowTalent(player.T_GEM_GOLEM) then
	local gem1 = golem:getInven("GEM")[1]
	local gem2 = golem:getInven("GEM")[2]
	table.insert(ans, 3, {("첫 번째 보석을 바꿔주고 싶은데 %s."):format(gem1 and "(현재: "..gem1:getName{}..")" or ""), action=change_gem1})
	table.insert(ans, 4, {("두 번째 보석을 바꿔주고 싶은데 %s."):format(gem2 and "(현재: "..gem2:getName{}..")" or ""), action=change_gem2})
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*골렘이 단조로운 음색으로 말합니다.*#WHITE#
네, 주인님.]],
	answers = ans
}

return "welcome"
