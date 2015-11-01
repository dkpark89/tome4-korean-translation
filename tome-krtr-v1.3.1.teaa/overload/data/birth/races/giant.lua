-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
--                       Giants                         --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Giant",
	locked = function() return profile.mod.allow_build.race_giant end,
	locked_desc = "Powerful beings that tower over all, but the bigger they are, the harder they fall...",
	desc = {
		[[#{italic}#"Giant"#{normal}# is a catch-all term for humanoids which are typically over eight feet in height.  Their origins, cultures, and relationships to other races differ wildly, but they tend to live as refugees and outcasts, shunned by smaller sentient races who usually see them as a threat.]],
	},
	descriptor_choices =
	{
		subrace =
		{
			Ogre = "allow",
			__ALL__ = "disallow",
		},
	},
	copy = {
		type = "giant", subtype="giant",
	},
}

---------------------------------------------------------
--                       Ogres                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Ogre",
	locked = function() return profile.mod.allow_build.race_ogre end,
	locked_desc = [[Forged in the hatred of ages long passed,
made for a war that they've come to outlast.
Their forgotten birthplace lies deep underground,
its tunnels ruined so it wouldn't be found.
Past burglars have failed, but their data's immortal;
to start, look where halflings once tinkered with portals...]],
	desc = {
		"Ogres are an altered form of Human, created in the Age of Allure as workers and warriors for the Conclave.",
		"Inscriptions have granted them magical and physical power far beyond their natural limits, but their dependence on runic magic made them a favored target during the Spellhunt, forcing them to take refuge among the Shalore.",
		"Their preference for simple and direct solutions has given them an undeserved reputation as dumb brutes, despite their extraordinary talent with runes and their humble, dutiful nature.",
		"They possess the #GOLD#Ogric Wrath#WHITE# talent, which grants them critical chance and power, as well as resistance to confusion and stuns, when their attacks miss or are blocked.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, -1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +2 Magic, -2 Willpower, +2 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 13",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 30%",
	},
	moddable_attachement_spots = "race_ogre",
	inc_stats = { str=3, mag=2, wil=-2, cun=2, dex=-1, con=0 },
	experience = 1.3,
	talents_types = { ["race/ogre"]={true, 0} },
	talents = { [ActorTalents.T_OGRE_WRATH]=1 },
	copy = {
		moddable_tile = "ogre_#sex#",
		random_name_def = "shalore_#sex#", random_name_max_syllables = 4,
		default_wilderness = {"playerpop", "shaloren"},
		starting_zone = "scintillating-caves",
		starting_quest = "start-shaloren",
		faction = "shalore",
		starting_intro = "ogre",
		life_rating = 13,
		size_category = 4,
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10, dur=5, power=15}),
		resolvers.inventory({id=true, transmo=false, alter=function(o) o.inscription_data.cooldown=18 o.inscription_data.apply=15 o.inscription_data.power=25 end, {type="scroll", subtype="rune", name="biting gale rune", ego_chance=-1000, ego_chance=-1000}}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
	},
	experience = 1.3,
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	cosmetic_unlock = {
		cosmetic_race_human_redhead = {
			{name="Redhead [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" end end},
		},
		cosmetic_bikini =  {
			{name="Bikini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Bikini if not o then print("No bikini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_BIKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
			{name="Mankini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Mankini if not o then print("No mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_MANKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Male" end},
		},
	},
}
