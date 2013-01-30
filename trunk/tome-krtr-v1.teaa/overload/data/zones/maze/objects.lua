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

load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 2 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "torn diary page", lore="maze-note-"..i,
	kr_display_name = "찢겨진 일기장", --@@ lore 번역시 수정 필요
	desc = [[어떤 모험가가 남긴 일기장입니다.]],
	rarity = false,
}
end

newEntity{ base = "BASE_LORE", define_as = "NOTE_LEARN_TRAP",
	name = "the perfect killing device", lore="maze-note-trap", unique=true, no_unique_lore=true,
	kr_display_name = "완벽한 살해 도구", --@@ lore 번역시 수정 필요
	desc = [[불행한 도적이 남긴, 독구름 함정을 만드는 방법이 적힌 쪽지입니다.]],
	rarity = false,
}
