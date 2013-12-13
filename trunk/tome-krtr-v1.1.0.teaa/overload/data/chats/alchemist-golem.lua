﻿-- ToME - Tales of Maj'Eyal
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

local change_inven = function(npc, player)
	local d
	local titleupdator = player:getEncumberTitleUpdator(("Equipment(%s) <=> Inventory(%s)"):format(npc.name:capitalize(), player.name:capitalize())) --@@ 한글화 필요
	d = require("mod.dialogs.ShowEquipInven").new(titleupdator(), npc, nil, function(o, inven, item, button, event)
		if not o then return end
		local ud = require("mod.dialogs.UseItemDialog").new(event == "button", npc, o, item, inven, function(_, _, _, stop)
			d:generate()
			d:generateList()
			d:updateTitle(titleupdator())
			if stop then game:unregisterDialog(d) end
		end, true, player)
		game:registerDialog(ud)
	end, nil, player)
	game:registerDialog(d)
end

local change_talents = function(npc, player)
	local LevelupDialog = require "mod.dialogs.LevelupDialog"
	local ds = LevelupDialog.new(npc, nil, nil)
	game:registerDialog(ds)
end

local change_tactics = function(npc, player)
	game.party:giveOrders(npc)
end

local change_control = function(npc, player)
	game.party:select(npc)
end

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
	{"I want to change your equipment.", action=change_inven}, --@@ 한글화 필요
	{"I want to change your talents.", action=change_talents}, --@@ 한글화 필요
	{"I want to change your tactics.", action=change_tactics}, --@@ 한글화 필요
	{"I want to take direct control.", action=change_control}, --@@ 한글화 필요
	{"이름을 바꿔주고 싶은데.", action=change_name},
	{"아무 것도 아냐. 그냥 가자."},
}

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*골렘이 단조로운 음색으로 말합니다.*#WHITE#
네, 주인님.]],
	answers = ans
}

return "welcome"
