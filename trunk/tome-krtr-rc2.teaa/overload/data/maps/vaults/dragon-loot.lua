﻿-- ToME - Tales of Maj'Eyal
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

setStatusAll{no_teleport=true}

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

startx = 7
starty = 0

defineTile('.', "FLOOR")
defineTile('~', "LAVA_FLOOR")
defineTile('#', "HARDWALL")
defineTile('+', "DOOR")
defineTile('X', "DOOR_VAULT")
defineTile('I', "FLOOR", nil, {random_filter={add_levels=10,name="fire imp"}})
defineTile('D', "FLOOR", {random_filter={add_levels=15, tome_mod="gvault"}}, {random_filter={add_levels=15,name="fire wyrm"}})

return {
[[#######X#######]],
[[###D+D+.#...###]],
[[#######.##..D##]],
[[###~~~...###+##]],
[[#.##~..#..~#..#]],
[[#.D#~.###.~#D.#]],
[[#..+...#..~#+##]],
[[##+#~~...~~~.~#]],
[[#..###I~~###+##]],
[[#....#####...~#]],
[[#~##.+..+...~~#]],
[[#~~~~#..####~~#]],
[[##~I~##D#~~~I##]],
[[###############]],
}
