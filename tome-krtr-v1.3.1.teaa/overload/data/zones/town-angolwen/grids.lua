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
load("/data/general/grids/mountain.lua")

newEntity{ base = "GRASS", define_as = "FIELDS",
	name="cultivated fields",
	kr_name = "경작지",
	display=';', image="terrain/cultivation.png",
	nice_tiler = { method="replace", base={"FIELDS", 100, 1, 4}},
}
for i = 1, 4 do newEntity{ base = "FIELDS", define_as = "FIELDS"..i, image="terrain/grass.png", add_mos={{image="terrain/cultivation0"..i..".png"}} } end

newEntity{ base = "FLOOR", define_as = "COBBLESTONE",
	name="cobblestone road",
	kr_name = "조약돌 포장도로",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}

newEntity{ base = "FLOOR", define_as = "ROCK",
	name="magical rock",
	kr_name = "마법의 바위",
	image="terrain/grass.png", add_displays = {class.new{image="terrain/maze_rock.png", z=4}},
	does_block_move = true
}

newEntity{ base = "DEEP_WATER", define_as = "FOUNTAIN",
	name="fountain",
	kr_name = "분수",
		does_block_move = true,
	block_move=function(self, x, y, e, act, couldpass)
		if e and e.player and act then game.party:learnLore("angolwen-fountain") end
		return true
	end,
}

newEntity{ base = "DEEP_WATER", define_as = "FOUNTAIN_MAIN",
	name="fountain",
	does_block_move = true,
	add_displays = {class.new{
		z = 17,
		image = "terrain/statues/angolwen_fountain.png",
		display_w = 6, display_h = 5,
		display_x = -2.5, display_y = -2,
}
