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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "LINANIIL_LECTURE",
	subtype = "lecture on humility", unique=true, no_unique_lore=true, not_in_stores=false,
	name = "Lecture on Humility by Archmage Linaniil", lore="angolwen-linaniil-lecture",
	kr_name = "마도사 리나니일의 겸손에 대한 강의",
	desc = [[마도사 리나니일의 겸손에 대한 강의입니다. 첫 번째 시대와 마법폭발에 관한 이야기입니다.]],
	rarity = false,
	cost = 2,
}

newEntity{ base = "BASE_LORE",
	define_as = "TARELION_LECTURE_MAGIC",
	subtype = "magic teaching", unique=true, no_unique_lore=true, not_in_stores=false,
	name = "'What is Magic' by Archmage Tarelion", lore="angolwen-tarelion-magic",
	kr_name = "마도사 타렐리온의 강의 '마법이란 무엇인가'",
	desc = [[마도사 타렐리온의 마법의 본질에 대한 강의입니다.]],
	rarity = false,
	cost = 2,
}

