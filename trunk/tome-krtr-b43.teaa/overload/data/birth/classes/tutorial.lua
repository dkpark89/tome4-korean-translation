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

newBirthDescriptor{
	type = "class",
	name = "Tutorial Adventurer",
	desc = {
		"Adventurers have a generic talent set to teach to young ones.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			["Tutorial Adventurer"] = "allow",
		},
	},
	copy = {
		max_life = 100,
		mana_regen = 0.2,
		life_regen = 1,
		mana_rating = 7,
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Tutorial Adventurer",
	desc = {
		"Adventurers have a generic talent set to teach to young ones.",
	},
	not_on_random_boss = true,
	stats = { str=10, con=5, dex=8, mag=10, wil=5, cun=5 },
	talents_types = {
		["technique/combat-training"]={true, 0.3},
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_WEAPON_COMBAT] = 2,
		[ActorTalents.T_ARMOUR_TRAINING] = 3,
		[ActorTalents.T_WEAPONS_MASTERY] = 2,
	},
	copy = {
		unused_stats = 0, unused_talents = 0, unused_generics = 0, unused_talents_types = 0,
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000},
		},
	},
}
