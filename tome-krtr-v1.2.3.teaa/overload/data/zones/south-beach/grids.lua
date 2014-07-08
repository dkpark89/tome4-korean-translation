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
load("/data/general/grids/sand.lua")

newEntity{ base = "SAND",
	define_as = "UMBRELLA",
	type = "floor", subtype = "sand",
	name = "lovely umbrella", image = "terrain/sandfloor.png", add_mos = {{image="terrain/picnic_umbrella.png"}},
	kr_name = "사랑스러운 우산",
	display = '~', color=colors.PINK, back_color={r=93,g=79,b=22},
	does_block_move = true,
}

newEntity{ base = "SAND",
	define_as = "BASKET",
	type = "floor", subtype = "sand",
	name = "picnic basket", image = "terrain/sandfloor.png", add_mos = {{image="terrain/picnic_basket.png"}},
	kr_name = "소풍 바구니",
	display = '_', color=colors.PINK, back_color={r=93,g=79,b=22},
}

newEntity{
	define_as = "BEACH_UP",
	type = "floor", subtype = "grass",
	name = "exit to the worldmap", image = "terrain/grass.png", add_mos = {{image="terrain/worldmap.png"}},
	kr_name = "지역 밖으로 나가는 출구",
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	change_level_check = function()
		local q = game.player:hasQuest("love-melinda")
		local melinda = game.party:findMember{type="Girlfriend"}
		if not q or not melinda then return false end
		if q:isStatus(engine.Quest.FAILED) then
			return false
		elseif q:isStatus(engine.Quest.COMPLETED, "saved-beach") then
			local chat = require("engine.Chat").new("melinda-beach-end", melinda, game.player)
			chat:invoke()
		else
-- chat if you successfully defend her?
			game.log("아직 해변에서의 낭만적인 시간을 다 보내지 않았습니다.")
		end
		return true
	end,
}
