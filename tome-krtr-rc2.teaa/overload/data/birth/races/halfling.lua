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
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Halfling",
	kr_display_name = "하플링",
	desc = {
		"하플링은 대부분 키가 4피트를 넘지 못하는 조그만 종족입니다.",
		"생각한 일을 행동에 옮기는 기민함은 인간과 비슷하지만, 계획성과 학습능력은 더 뛰어납니다.",
		"하플링의 군대는 많은 왕국들을 굴복시켰으며 미혹의 시대 이래로 인간 왕국과 힘의 균형을 유지해오고 있습니다.",
		"하플링은 기민하며, 운이 좋고, 힘은 약하지만 몸은 튼튼합니다.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Halfling = "allow",
		},
		subclass = {
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	copy = {
		faction = "allied-kingdoms",
		type = "humanoid", subtype="halfling",
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "halfling",
		size_category = 2,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	cosmetic_unlock = {
		cosmetic_race_human_redhead = {
			{name="Redhead [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" end end},
		},
	},
}

---------------------------------------------------------
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Halfling",
	kr_display_name = "하플링",
	desc = {
		"하플링은 대부분 키가 4피트를 넘지 못하는 조그만 종족입니다",
		"생각한 일을 행동에 옮기는 기민함은 인간과 비슷하지만, 계획성과 학습능력은 더 뛰어납니다.",
		"하플링의 군대는 많은 왕국들을 굴복시켰으며 미혹의 시대 이래로 인간 왕국과 힘의 균형을 유지해오고 있습니다.",
		"몇 턴 동안 치명타를 가할 기회를 향상시켜주는 #GOLD#작은이의 행운#WHITE#을 사용할 수 있습니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘-3, 민첩+3, 체격+1",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+3",
		"#LIGHT_BLUE# * 행운+5",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 12",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 20%",
	},
	inc_stats = { str=-3, dex=3, con=1, cun=3, lck=5, },
	experience = 1.20,
	talents_types = { ["race/halfling"]={true, 0} },
	talents = {
		[ActorTalents.T_HALFLING_LUCK]=1,
	},
	copy = {
		moddable_tile = "halfling_#sex#",
		random_name_def = "halfling_#sex#",
		life_rating = 12,
	},
}
