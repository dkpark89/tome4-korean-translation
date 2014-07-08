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

for i = 1, 4 do
newEntity{ base = "BASE_LORE_RANDOM",
	define_as = "SUNWALL_LORE_NOTE"..i,
	name = "Loremaster Verutir's note", lore="sunwall-note-"..i, unique="Loremaster Verutir's note "..i,
	kr_name = "지식의 대가 베루티르의 쪽지",
	desc = [[어떤 지식이 담긴 종이 조각입니다.]],
	level_range = {1, 50},
	rarity = 50,
	encumber = 0,
}
end
