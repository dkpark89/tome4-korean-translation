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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore/orc-prides.lua")

newEntity{ base = "BASE_LORE",
	define_as = "NOTE_LORE",
	name = "draft note", lore="grushnak-pride-note",
	kr_display_name = "설계도면", --@@ lore 번역시 수정 필요
	desc = [[쪽지입니다.]],
	rarity = false,
	encumberance = 0,
}

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "BREEDING_HISTORY"..i,
	name = "Clinician Korbek's experimental notes", lore="orc-breeding-"..i,
	kr_display_name = "임상 의학자 코르벡의 실험 기록", --@@ lore 번역시 수정 필요
	desc = [[새로운 오크가 태어났다...]],
	rarity = false,
}
end
newEntity{ base = "BASE_LORE",
	define_as = "BREEDING_HISTORY5",
	name = "Captain Gumlarat's report", lore="orc-breeding-5",
	kr_display_name = "굼라랏 장군의 보고서", --@@ lore 번역시 수정 필요
	desc = [[새로운 오크가 태어났다...]],
	rarity = false,
}
