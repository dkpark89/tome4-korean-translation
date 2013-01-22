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
--                      Constructs                     --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Construct",
	kr_display_name = "구조체",
	locked = function() return profile.mod.allow_build.construct and true or "hide" end,
	locked_desc = "",
	desc = {
		"구조체는 자연적인 생물이 아닙니다.",
		"구조체는 대부분 골렘이지만, 형태와 양식, 그리고 능력은 다양합니다.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			["Runic Golem"] = "allow",
		},
	},
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

newBirthDescriptor
{
	type = "subrace",
	name = "Runic Golem",
	kr_display_name = "룬 골렘",
	locked = function() return profile.mod.allow_build.construct_runic_golem and true or "hide" end,
	locked_desc = "",
	desc = {
		"룬 골렘은 마법의 힘으로 움직이는 단단한 바위 피조물입니다.",
		"특정한 직업의 능력을 가질수는 없지만, 다양한 고유 능력을 지니고 있습니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+3, 민첩-2, 체격+3",
		"#LIGHT_BLUE# * 마법+2, 의지+2, 교활함-5",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 13",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 50%",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
		class =
		{
			__ALL__ = "disallow",
			None = "allow",
		},
		subclass =
		{
			__ALL__ = "disallow",
		},
	},
	inc_stats = { str=3, con=3, wil=2, mag=2, dex=-2, cun=-5 },
	talents_types = {
		["golem/arcane"]={true, 0.3},
		["golem/fighting"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_MANA_POOL]=1,
		[ActorTalents.T_STAMINA_POOL]=1,
	},
	copy = {
		resolvers.generic(function(e) e.descriptor.class = "Golem" e.descriptor.subclass = "Golem" end),
		resolvers.genericlast(function(e) e.faction = "undead" end),
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "ruins-kor-pul",
		starting_quest = "start-allied",
		blood_color = colors.GREY,
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "점술사의 오브"} end),

		mana_regen = 0.5,
		mana_rating = 7,
		inscription_restrictions = { ["inscriptions/runes"] = true, },
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10}),

		type = "construct", subtype="golem", image = "npc/alchemist_golem.png",
		starting_intro = "ghoul",
		life_rating=13,
		poison_immune = 1,
		cut_immune = 1,
		stun_immune = 1,
		fear_immune = 1,
		construct = 1,

		moddable_tile = "runic_golem",
		moddable_tile_nude = true,
	},
	experience = 1.5,
}
