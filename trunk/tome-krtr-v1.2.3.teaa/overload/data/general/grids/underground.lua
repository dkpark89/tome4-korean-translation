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

newEntity{
	define_as = "UNDERGROUND_FLOOR",
	type = "floor", subtype = "underground",
	name = "floor", image = "terrain/underground_floor.png",
	kr_name = "바닥",
	display = '.', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	grow = "UNDERGROUND_TREE",
	nice_tiler = { method="replace", base={"UNDERGROUND_FLOOR", 50, 1, 20}},
}
for i = 1, 20 do
local add = nil
if rng.percent(50) then add = {{image="terrain/floor_mushroom_0"..rng.range(1,8)..".png"}} end
newEntity{base = "UNDERGROUND_FLOOR", define_as = "UNDERGROUND_FLOOR"..i, image = "terrain/underground_floor"..(1 + i % 8)..".png", add_mos=add}
end

local treesdef = {
	{"small_mushroom_01", {"shadow", "trunk", {"head_%02d", 1, 2}}},
	{"small_mushroom_02", {"shadow", "trunk", {"head_%02d", 1, 6}}},
	{"small_mushroom_03", {"shadow", "trunk", {"head_%02d", 1, 5}}},
	{"small_mushroom_04", {"shadow", "trunk", {"head_%02d", 1, 2}}},
	{"mushroom_01", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 2}}},
	{"mushroom_02", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 2}}},
	{"mushroom_03", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 2}}},
	{"mushroom_04", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 1}}},
	{"mushroom_05", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 1}}},
	{"mushroom_06", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 1}}},
	{"mushroom_07", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 1}}},
	{"mushroom_08", {tall=-1, "shadow", "trunk", {"head_%02d", 1, 4}}},
}

newEntity{
	define_as = "UNDERGROUND_TREE",
	type = "wall", subtype = "underground",
	name = "underground thick vegetation",
	kr_name = "지하의 두꺼운 초목",
	image = "terrain/tree.png",
	display = '#', color=colors.PURPLE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	nice_tiler = { method="replace", base={"UNDERGROUND_TREE", 100, 1, 30}},
	dig = "UNDERGROUND_FLOOR",
}
for i = 1, 30 do
	newEntity(class:makeNewTrees({base="UNDERGROUND_TREE", define_as = "UNDERGROUND_TREE"..i, image = "terrain/underground_floor.png"}, treesdef))
end

newEntity{
	define_as = "UNDERGROUND_LADDER_DOWN",
	type = "floor", subtype = "underground",
	name = "ladder to the next level", image = "terrain/underground_floor.png", add_displays = {class.new{image="terrain/ladder_down.png"}},
	kr_name = "다음 층으로의 사다리",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "UNDERGROUND_LADDER_UP",
	type = "floor", subtype = "underground",
	name = "ladder to the previous level", image = "terrain/underground_floor.png", add_displays = {class.new{image="terrain/ladder_up.png"}},
	kr_name = "이전 층으로의 사다리",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "UNDERGROUND_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "underground",
	name = "ladder to worldmap", image = "terrain/underground_floor.png", add_displays = {class.new{image="terrain/ladder_up_wild.png"}},
	kr_name = "지역 밖으로 나가는 사다리",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

for i = 1, 20 do
newEntity{
	define_as = "CRYSTAL_WALL"..(i > 1 and i or ""),
	type = "wall", subtype = "underground",
	name = "crystals",
	kr_name = "수정",
	image = "terrain/crystal_floor1.png",
	add_displays = class:makeCrystals("terrain/crystal_alpha"),
	display = '#', color=colors.LIGHT_BLUE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	dig = "CRYSTAL_FLOOR",
}
end

newEntity{
	define_as = "CRYSTAL_FLOOR",
	type = "floor", subtype = "underground",
	name = "floor", image = "terrain/crystal_floor1.png",
	kr_name = "바닥",
	display = '.', color=colors.LIGHT_UMBER, back_color=colors.UMBER,
	grow = "CRYSTAL_WALL",
	nice_tiler = { method="replace", base={"CRYSTAL_FLOOR", 100, 1, 8}},
}
for i = 1, 8 do newEntity{ base = "CRYSTAL_FLOOR", define_as = "CRYSTAL_FLOOR"..i, image = "terrain/crystal_floor"..i..".png"} end

newEntity{
	define_as = "CRYSTAL_LADDER_DOWN",
	type = "floor", subtype = "underground",
	name = "ladder to the next level", image = "terrain/crystal_floor1.png", add_displays = {class.new{image="terrain/crystal_ladder_down.png"}},
	kr_name = "다음 층으로의 사다리",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}
newEntity{
	define_as = "CRYSTAL_LADDER_UP",
	type = "floor", subtype = "underground",
	name = "ladder to the previous level", image = "terrain/crystal_floor1.png", add_displays = {class.new{image="terrain/crystal_ladder_up.png"}},
	kr_name = "이전 층으로의 사다리",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "CRYSTAL_LADDER_UP_WILDERNESS",
	type = "floor", subtype = "underground",
	name = "ladder to worldmap", image = "terrain/crystal_floor1.png", add_displays = {class.new{image="terrain/crystal_ladder_up.png"}},
	kr_name = "지역 밖으로 나가는 사다리",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}
