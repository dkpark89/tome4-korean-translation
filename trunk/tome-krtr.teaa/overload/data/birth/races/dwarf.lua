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
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Dwarf",
	desc = {
		"Dwarves are a secretive people, hailing from their underground home of the Iron Throne.",
		"They are a sturdy race and are known for their masterwork, yet they are not well loved, having left other races to fend for themselves in past conflicts.",
		"All dwarves are united under the Empire and their love of money.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Dwarf = "allow",
		},
	},
	copy = {
		faction = "iron-throne",
		type = "humanoid", subtype="dwarf",
		calendar = "dwarf",
		default_wilderness = {"playerpop", "dwarf"},
		starting_zone = "reknor-escape",
		starting_quest = "start-dwarf",
		starting_intro = "dwarf",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},
	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Dwarf",
	desc = {
		"Dwarves are a secretive people, hailing from their underground home of the Iron Throne.",
		"They are a sturdy race and are known for their masterwork, yet they are not well loved, having left other races to fend for themselves in past conflicts.",
		"They possess the #GOLD#Resilience of the Dwarves#WHITE# which allows them to increase their armour, physical and spell saves for a few turns.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +4 Strength, -2 Dexterity, +3 Constitution",
		"#LIGHT_BLUE# * -2 Magic, +3 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 12",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 25%",
	},
	inc_stats = { str=4, con=3, wil=3, mag=-2, dex=-2 },
	talents_types = { ["race/dwarf"]={true, 0} },
	talents = {
		[ActorTalents.T_DWARF_RESILIENCE]=1,
	},
	copy = {
		moddable_tile = "dwarf_#sex#",
		moddable_tile_ornament = {male="beard_02", female="braid_01"},
		random_name_def = "dwarf_#sex#",
		life_rating=12,
	},
	experience = 1.25,
}
