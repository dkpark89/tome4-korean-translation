﻿-- ToME - Tales of Maj'Eyal
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

local mountain_editer = {method="borders_def", def="mountain"}

newEntity{
	define_as = "ROCKY_GROUND",
	type = "floor", subtype = "rock",
	name = "rocky ground", image = "terrain/rocky_ground.png",
	kr_name = "돌 투성이 바닥",
	display = '.', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	grow = "MOUNTAIN_WALL",
}

newEntity{
	define_as = "MOUNTAIN_WALL",
	type = "rockwall", subtype = "rock",
	name = "rocky mountain", image = "terrain/rocky_mountain.png",
	kr_name = "바위 산",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	air_level = -20,
	dig = "ROCKY_GROUND",
	nice_editer = mountain_editer,
	nice_tiler = { method="replace", base={"MOUNTAIN_WALL", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="MOUNTAIN_WALL", define_as = "MOUNTAIN_WALL"..i, image = "terrain/mountain5_"..i..".png"} end

newEntity{
	define_as = "ROCKY_SNOWY_TREE",
	type = "wall", subtype = "rock",
	name = "snowy tree", image = "terrain/rocky_snowy_tree.png",
	kr_name = "눈 쌓인 나무",
	display = '#', color=colors.WHITE, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "ROCKY_GROUND",
	nice_tiler = { method="replace", base={"ROCKY_SNOWY_TREE", 100, 1, 30} },
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="ROCKY_SNOWY_TREE", define_as = "ROCKY_SNOWY_TREE"..i, image = "terrain/rocky_ground.png", nice_tiler = false}, {
		{"small_elm", {"shadow", "trunk", "foliage_winter"}},
		{"elm", {tall=-1, "shadow", "trunk", "foliage_winter"}},
		{"pine", {tall=-1, "shadow", "trunk", {"foliage_winter_%02d", 1, 2}, shader_args={attenuation=14}}},
		{"small_narrow_pine", {"shadow", "trunk", {"foliage_winter_%02d", 1, 2}, shader_args={attenuation=14}}},
		{"small_wider_pine", {"shadow", "trunk", {"foliage_winter_%02d", 1, 2}, shader_args={attenuation=14}}},
		{"cypress", {tall=-1, "shadow", "trunk", {"foliage_winter_%02d",1,2}}},
		{"small_cypress", {tall=-1, "shadow", "trunk", {"foliage_winter_%02d",1,2}}},
		{"tiny_cypress", {"shadow", "trunk", {"foliage_winter_%02d",1,2}}},
		{"oak", {tall=-1, "shadow", {"trunk_%02d",1,2}, {"foliage_winter_%02d",1,2}}},
	}))
end

newEntity{
	define_as = "HARDMOUNTAIN_WALL",
	name = "hard rocky mountain", image = "terrain/rocky_mountain.png",
	kr_name = "단단한 바위 산",
	display = '#', color=colors.UMBER, back_color=colors.LIGHT_UMBER,
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	air_level = -20,
	nice_editer = mountain_editer,
	nice_tiler = { method="replace", base={"HARDMOUNTAIN_WALL", 70, 1, 6} },
}
for i = 1, 6 do newEntity{ base="HARDMOUNTAIN_WALL", define_as = "HARDMOUNTAIN_WALL"..i, image = "terrain/mountain5_"..i..".png"} end


-----------------------------------------
-- Rocky exits
-----------------------------------------
newEntity{
	define_as = "ROCKY_UP_WILDERNESS",
	name = "exit to the worldmap", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/worldmap.png"}},
	kr_name = "지역 밖으로 나가는 출구",
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "ROCKY_UP8",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP2",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP4",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}
newEntity{
	define_as = "ROCKY_UP6",
	name = "way to the previous level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "ROCKY_DOWN8",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_8.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN2",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_2.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN4",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_4.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "ROCKY_DOWN6",
	name = "way to the next level", image = "terrain/rocky_ground.png", add_displays = {class.new{image="terrain/way_next_6.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
