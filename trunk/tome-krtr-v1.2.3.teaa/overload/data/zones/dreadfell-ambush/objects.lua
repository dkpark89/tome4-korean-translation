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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "UKRUK_NOTE",
	name = "hastily written log", lore="ukruk-log",
	kr_name = "급히 적어놓은 기록",
	desc = [[우크룩이 남긴 종이 조각입니다.]],
	rarity = false,
	encumberance = 0,
}
