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
load("/data/general/grids/mountain.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/sand.lua")

newEntity{
	define_as = "FLOOR_ROAD_STONE",
	type = "floor", subtype = "floor", road="oldstone",
	name = "old road", image = "terrain/marble_floor.png",
	kr_name = "오래된 길",
	display = '=', color=colors.DARK_GREY,
	always_remember = true,
	nice_editer2 = { method="roads_def", def="oldstone" },
}

newEntity{
	define_as = "WEST_PORTAL",
	name = "Farportal: Last Hope",
	kr_name = "장거리 관문 : 마지막 희망",
	display = '&', color_r=255, color_g=0, color_b=220, back_color=colors.VIOLET, image = "terrain/marble_floor.png",
	notice = true,
	always_remember = true,
	show_tooltip = true,
	desc = [[장거리 관문은 눈 깜짝할 사이에 놀랄만큼 먼 거리를 이동하는 수단입니다. 이것을 사용하기 위해서는 보통 어떤 물건이 필요하며, 이 관문이 쌍방향으로 사용이 가능한 것인지조차도 알 수 없습니다.
이 관문의 목표지점은 마즈'에이알의 도시, 마지막 희망의 근방인 것 같습니다.]],

	orb_portal = {
		change_level = 1,
		change_zone = "wilderness",
		change_wilderness = {
			spot = {type="farportal-end", subtype="last-hope"},
		},
		message = "#VIOLET#당신은 소용돌이 치는 관문으로 들어섰습니다. 눈 깜짝할 사이에 관문의 흔적은 없어지고, 자신이 마지막 희망의 변두리에 있다는 것을 알아차립니다...",
		on_use = function(self, who)
		end,
	},
}
newEntity{ base = "WEST_PORTAL", define_as = "CWEST_PORTAL",
	image = "terrain/marble_floor.png",
	add_displays = {class.new{image="terrain/farportal-base.png", display_x=-1, display_y=-1, display_w=3, display_h=3}},
	on_added = function(self, level, x, y)
		level.map:particleEmitter(x, y, 3, "farportal_vortex")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
		level.map:particleEmitter(x, y, 3, "farportal_lightning")
	end,
}

local gold_mountain_editer = {method="borders_def", def="gold_mountain"}
newEntity{
	define_as = "GOLDEN_MOUNTAIN",
	type = "rockwall", subtype = "grass",
	name = "Sunwall mountain", image = "terrain/golden_mountain5_1.png",
	kr_name = "태양의 장벽 산맥",
	display = '#', color=colors.GOLD, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
	nice_editer = gold_mountain_editer,
	nice_tiler = { method="replace", base={"GOLDEN_MOUNTAIN_WALL", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="GOLDEN_MOUNTAIN", define_as = "GOLDEN_MOUNTAIN_WALL"..i, image = "terrain/golden_mountain5_"..i..".png"} end

newEntity{ define_as = "FENS",
	name = "Way into the Slazish fens",
	kr_name = "슬라지쉬 늪지로의 길",
	display = '>', color = colors.YELLOW,
	image="terrain/marble_floor.png", add_displays = {class.new{image="terrain/golden_cave_entrance02.png", z=8}},
	change_zone="slazish-fen", change_level = 1,
}
