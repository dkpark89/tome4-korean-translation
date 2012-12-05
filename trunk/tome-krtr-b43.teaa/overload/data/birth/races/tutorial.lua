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

---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Tutorial Human",
	kr_display_name = "연습게임용 인간 ",
	desc = {
		"연습게임에 쓰이는 특수 종족.",
	},
	descriptor_choices =
	{
		subrace =
		{
			["Tutorial Human"] = "allow",
			__ALL__ = "disallow",
		},
	},
	talents = {},
	experience = 1.0,
	copy = {
		faction = "allied-kingdoms",
		type = "humanoid", subtype="human",
	},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Tutorial Basic",
	kr_display_name = "연습게임용 기본 종족",
	desc = {
		"데르스 북쪽 출신의 인간. 어디로보나 평범하기 그지없는 사람.",
	},
	copy = {
		default_wilderness = {1, 1, "wilderness"},
		starting_zone = "tutorial",
		starting_quest = "tutorial",
		starting_intro = "tutorial",
		moddable_tile = "human_#sex#",
		moddable_tile_base = "base_cornac_01.png",
	},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Tutorial Stats",
	kr_display_name = "연습게임용 능력치",
	desc = {
		"데르스 북쪽 출신의 인간. 어디로보나 평범하기 그지없는 사람.",
	},
	copy = {
		default_wilderness = {1, 1, "wilderness"},
		starting_zone = "tutorial-combat-stats",
		starting_quest = "tutorial-combat-stats",
		starting_intro = "tutorial-combat-stats",
		moddable_tile = "human_#sex#",
		moddable_tile_base = "base_cornac_01.png",
	},
}
