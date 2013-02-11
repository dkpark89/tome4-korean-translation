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

load("/data/general/grids/basic.lua")
load("/data/general/grids/underground.lua")

for i = 1, 20 do
newEntity{
	define_as = "CRYSTAL_WALL"..(i > 1 and i or ""),
	type = "wall", subtype = "underground",
	name = "crystals",
	kr_display_name = "수정",
	image = "terrain/oldstone_floor.png",
	add_displays = class:makeCrystals("terrain/crystal_alpha"),
	display = '#', color=colors.LIGHT_BLUE, back_color=colors.UMBER,
	always_remember = true,
	can_pass = {pass_wall=1},
	does_block_move = true,
	block_sight = true,
	dig = "CRYSTAL_FLOOR",
}
end

newEntity{ base = "DOWN", define_as = "ESCAPE_REKNOR", name="Escape route from Reknor", kr_display_name = "레크놀에서의 탈출로", change_zone="reknor-escape", change_level=3, change_zone_auto_stairs = true }
newEntity{ base = "DOWN", define_as = "DEEP_BELLOW", name="The Deep Bellow", kr_display_name = "깊은 울림", glow=true, change_zone="deep-bellow" }

newEntity{ define_as = "STATUE1",
	display = '@', image="terrain/oldstone_floor.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_dwarf_taxman.png", z=18, display_y=-1, display_h=2}},
	name = "The Dwarven Empire Incarnate",
	kr_display_name = "드워프 제국의 화신",
	does_block_move = true,
	block_sight = true,
}
newEntity{ define_as = "STATUE2",
	display = '@', image="terrain/oldstone_floor.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_dwarf_mage.png", z=18, display_y=-1, display_h=2}},
	name = "Mystic of the Empire",
	kr_display_name = "제국의 비전술사",
	does_block_move = true,
	block_sight = true,
}
newEntity{ define_as = "STATUE3",
	display = '@', image="terrain/oldstone_floor.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_dwarf_axeman.png", z=18, display_y=-1, display_h=2}},
	name = "Warrior of the Empire",
	kr_display_name = "제국의 전사",
	does_block_move = true,
	block_sight = true,
}
newEntity{ define_as = "STATUE4",
	display = '@', image="terrain/oldstone_floor.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_dwarf_warrior.png", z=18, display_y=-1, display_h=2}},
	name = "Defender of the Empire",
	kr_display_name = "제국의 수호자",
	does_block_move = true,
	block_sight = true,
}
newEntity{ define_as = "STATUE5",
	display = '@', image="terrain/oldstone_floor.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_dwarf_axeman2.png", z=18, display_y=-1, display_h=2}},
	name = "Warrior of the Empire",
	kr_display_name = "제국의 전사",
	does_block_move = true,
	block_sight = true,
}
newEntity{ define_as = "STATUE6",
	display = '@', image="terrain/oldstone_floor.png", add_displays = {mod.class.Grid.new{image="terrain/statues/statue_dwarf_archer.png", z=18, display_y=-1, display_h=2}},
	name = "Warrior of the Empire",
	kr_display_name = "제국의 전사",
	does_block_move = true,
	block_sight = true,
}
