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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")

newEntity{
	define_as = "OLD_FOREST",
	name = "way to the old forest", image = "terrain/grass.png", add_displays = {class.new{image = "terrain/way_next_8.png"}},
	kr_name = "오래된 숲으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 4, change_zone = "old-forest", force_down = true,
}

newEntity{
	define_as = "SHERTUL_FORTRESS_DRY",
	name = "entrance to the Sher'Tul ruins",
	kr_name = "쉐르'툴 폐허로의 입구",
	display = '>', color=colors.PURPLE, image = "terrain/marble_floor.png", add_mos = {{image = "terrain/stair_down.png"}},
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "shertul-fortress",
	change_level_check = function(self, who)
		if who.player and game.party:knownLore("old-forest-note-5") then
			game.logPlayer(who, "#ANTIQUE_WHITE#당신은 이전에 발견한 보석이 열쇠가 되어 딱 맞을 것 같은 구멍을 발견했습니다. 보석을 집어넣자, 다음 층으로의 길이 나타납니다.")
			who:setQuestStatus("shertul-fortress", engine.Quest.COMPLETED, "entered")
		else
			game.logPlayer(who, "#ANTIQUE_WHITE#이 길은 막혀있는 것으로 보입니다. 아마 열쇠가 필요할 것 같습니다.")
			return true
		end
	end,
}

newEntity{
	define_as = "SHERTUL_FORTRESS_FLOOD",
	name = "entrance to the Sher'Tul ruins",
	kr_name = "쉐르'툴 폐허로의 입구",
	display = '>', color=colors.PURPLE, image = "terrain/underwater/subsea_floor_02.png", add_mos = {{image = "terrain/stair_down.png"}},
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "shertul-fortress",
	change_level_check = function(self, who)
		if who.player and game.party:knownLore("old-forest-note-5") then
			game.logPlayer(who, "#ANTIQUE_WHITE#당신은 이전에 발견한 보석이 열쇠가 되어 딱 맞을 것 같은 구멍을 발견했습니다. 보석을 집어넣자, 다음 층으로의 길이 나타납니다.")
			who:setQuestStatus("shertul-fortress", engine.Quest.COMPLETED, "entered")
		else
			game.logPlayer(who, "#ANTIQUE_WHITE#이 길은 막혀있는 것으로 보입니다. 아마 열쇠가 필요할 것 같습니다.")
			return true
		end
	end,
}
