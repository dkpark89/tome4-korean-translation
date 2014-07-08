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

local grass_editer = { method="borders_def", def="grass"}
local grasswm_editer = { method="borders_def", def="grass_wm"}

newEntity{
	define_as = "GRASS",
	type = "floor", subtype = "grass",
	name = "grass", image = "terrain/grass.png",
	kr_name = "풀밭",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	grow = "TREE",
	nice_tiler = { method="replace", base={"GRASS_PATCH", 100, 1, 14}},
	nice_editer = grass_editer,
}
for i = 1, 14 do newEntity{ base = "GRASS", define_as = "GRASS_PATCH"..i, image = ("terrain/grass/grass_main_%02d.png"):format(i) } end

newEntity{
	define_as = "GRASS_SHORT",
	type = "floor", subtype = "grass",
	name = "grass", image = "terrain/grass.png",
	kr_name = "풀밭",
	display = '.', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	grow = "TREE",
--	nice_tiler = { method="replace", base={"GRASS_PATCH", 100, 1, 14}},
	nice_editer = grasswm_editer,
}

local treesdef = {
	{"small_elm", {"shadow", "trunk", "foliage_summer"}},
	{"small_elm", {"shadow", "trunk", "foliage_summer"}},
	{"elm", {tall=-1, "shadow", "trunk", "foliage_summer"}},
	{"elm", {tall=-1, "shadow", "trunk", "foliage_summer"}},
	{"light_pine", {tall=-1, "shadow", "trunk", {"foliage_%02d",1,4}}},
	{"light_small_wider_pine", {"shadow", "trunk", {"foliage_%02d",1,4}}},
	{"light_small_narrow_pine", {"shadow", "trunk", {"foliage_%02d",1,4}}},
	{"cypress", {tall=-1, "shadow", "trunk", {"foliage_%02d",1,4}}},
	{"small_cypress", {tall=-1, "shadow", "trunk", {"foliage_%02d",1,4}}},
	{"tiny_cypress", {"shadow", "trunk", {"foliage_%02d",1,4}}},
	{"oak", {tall=-1, "shadow", "trunk_01", {"foliage_summer_%02d",1,2}}},
	{"oak", {tall=-1, "shadow", "trunk_02", {"foliage_summer_%02d",3,4}}},
	{"small_oak", {"shadow", "trunk_01", {"foliage_summer_%02d",1,2}}},
	{"small_oak", {"shadow", "trunk_02", {"foliage_summer_%02d",3,4}}},
}

newEntity{
	define_as = "TREE",
	type = "wall", subtype = "grass",
	name = "tree",
	kr_name = "나무",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
	nice_tiler = { method="replace", base={"TREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="TREE", define_as = "TREE"..i, image = "terrain/grass.png"}, treesdef))
end

newEntity{
	define_as = "HARDTREE",
	type = "wall", subtype = "grass",
	name = "tall thick tree",
	kr_name = "크고 두꺼운 나무",
	image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN, back_color={r=44,g=95,b=43},
	always_remember = true,
	does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	nice_tiler = { method="replace", base={"HARDTREE", 100, 1, 30}},
	nice_editer = grass_editer,
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="HARDTREE", define_as = "HARDTREE"..i, image = "terrain/grass.png"}, treesdef))
end

newEntity{
	define_as = "FLOWER",
	type = "floor", subtype = "grass",
	name = "flower", image = "terrain/flower.png",
	kr_name = "꽃밭",
	display = ';', color=colors.YELLOW, back_color={r=44,g=95,b=43},
	grow = "TREE",
	nice_tiler = { method="replace", base={"FLOWER", 100, 1, 6+7}},
	nice_editer = grass_editer,
}
for i = 1, 6+7 do newEntity{ base = "FLOWER", define_as = "FLOWER"..i, image = "terrain/grass.png", add_mos = {{image = "terrain/"..(i<=6 and "flower_0"..i..".png" or "mushroom_0"..(i-6)..".png")}}} end

newEntity{
	define_as = "ROCK_VAULT",
	type = "wall", subtype = "grass",
	name = "huge loose rock", image = "terrain/grass.png", add_mos = {{image="terrain/huge_rock.png"}},
	kr_name = "흔들리는 거대한 바위",
	display = '+', color=colors.GREY, back_color={r=44,g=95,b=43},
	notice = true,
	always_remember = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	door_player_check = "바위를 밀어보니, 흔들립니다. 다른 곳으로 옮길 수 있을 것 같습니다.",
	door_opened = "GRASS",
	dig = "GRASS",
	nice_editer = grass_editer,
}

-----------------------------------------
-- Forest road
-----------------------------------------
newEntity{
	define_as = "GRASS_ROAD_STONE",
	type = "floor", subtype = "grass", road="oldstone",
	name = "old road", image = "terrain/grass.png",
	kr_name = "오래된 길",
	display = '=', color=colors.DARK_GREY,
	always_remember = true,
	nice_editer = grass_editer,
	nice_editer2 = { method="roads_def", def="oldstone" },
}
newEntity{
	define_as = "GRASS_ROAD_DIRT",
	type = "floor", subtype = "grass", road="dirt",
	name = "old road", image = "terrain/grass.png",
	kr_name = "오래된 길",
	display = '=', color=colors.DARK_GREY,
	always_remember = true,
	nice_editer = grass_editer,
	nice_editer2 = { method="roads_def", def="dirt" },
}

-----------------------------------------
-- Grassy exits
-----------------------------------------
newEntity{
	define_as = "GRASS_UP_WILDERNESS",
	type = "floor", subtype = "grass",
	name = "exit to the worldmap", image = "terrain/grass.png", add_mos = {{image="terrain/worldmap.png"}},
	kr_name = "지역 밖으로 나가는 출구",
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
	nice_editer = grass_editer,
}

newEntity{
	define_as = "GRASS_UP8",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_8.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_UP2",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_2.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_UP4",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_4.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_UP6",
	type = "floor", subtype = "grass",
	name = "way to the previous level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_6.png"}},
	kr_name = "이전 층으로의 길",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
	nice_editer = grass_editer,
}

newEntity{
	define_as = "GRASS_DOWN8",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_8.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_DOWN2",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_2.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_DOWN4",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_4.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
newEntity{
	define_as = "GRASS_DOWN6",
	type = "floor", subtype = "grass",
	name = "way to the next level", image = "terrain/grass.png", add_mos = {{image="terrain/way_next_6.png"}},
	kr_name = "다음 층으로의 길",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
	nice_editer = grass_editer,
}
