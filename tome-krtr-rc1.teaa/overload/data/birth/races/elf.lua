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
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Elf",
	kr_display_name = "엘프",
	desc = {
		"엘프 종족은 흔히 엘프로 싸잡아 불리지만, 이는 잘못된 것입니다.",
		"엘프는 세 종족으로 나뉘어지며, 현재는 두 종족만이 남아있습니다.",
		"마법의 힘으로 영생을 누리는 샬로레 족을 제외하면, 엘프의 수명은 보통 천년 정도입니다.",
		"엘프 종족은 저마다 판이한 세계관을 지니고 있습니다.",
	},
	descriptor_choices =
	{
		subrace =
		{
			Shalore = "allow",
			Thalore = "allow",
			__ALL__ = "disallow",
		},
		subclass =
		{
			-- Only human and elves make sense to play celestials
			['Sun Paladin'] = "allow",
			Anorithil = "allow",
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	copy = {
		type = "humanoid", subtype="elf",
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},

	cosmetic_unlock = {
		cosmetic_race_human_redhead = {
			{name="Redhead [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" end end, check=function(birth) return birth.descriptors_by_type.sex == "Male" end},
			{name="Redhead [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" actor.moddable_tile_ornament={female="braid_redhead_02"} end end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
		},
	},
}

---------------------------------------------------------
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Shalore",
	kr_display_name = "샬로레",
	desc = {
		"샬로레 엘프 족은 마법과 깊은 관계에 있기에 과거 많은 대마법사를 배출하였습니다.",
		"그들의 뇌리에 아직도 선명히 남아있는 스펠블레이즈와 뒤이어 벌어진 스펠헌트 때문에, 마법을 숨기고 조용히 살고 있습니다.",
		"잠시동안 모든 행동을 가속할 수 있는 #GOLD#불멸의 은총#WHITE#을 사용할 수 있습니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘-2, 민첩+1, 체격+0",
		"#LIGHT_BLUE# * 마법+2, 의지+3, 교활함+1",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 9",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 35%",
	},
	inc_stats = { str=-2, mag=2, wil=3, cun=1, dex=1, con=0 },
	experience = 1.3,
	talents_types = { ["race/shalore"]={true, 0} },
	talents = { [ActorTalents.T_SHALOREN_SPEED]=1 },
	copy = {
		moddable_tile = "elf_#sex#",
		moddable_tile_base = "base_shalore_01.png",
		moddable_tile_ornament = {female="braid_02"},
		random_name_def = "shalore_#sex#", random_name_max_syllables = 4,
		default_wilderness = {"playerpop", "shaloren"},
		starting_zone = "scintillating-caves",
		starting_quest = "start-shaloren",
		faction = "shalore",
		starting_intro = "shalore",
		life_rating = 9,
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10}),
	},
	experience = 1.35,
	random_escort_possibilities = { {"scintillating-caves", 2, 3}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

newBirthDescriptor
{
	type = "subrace",
	name = "Thalore",
	kr_display_name = "탈로레",
	desc = {
		"탈로레 엘프 족은 대부분의 시간을 숲 속에서 은둔하며 지내며, 거의 벗어나질 않습니다.",
		"아무리 세월이 흘러도 그들의 생태는 변하지 않습니다.",
		"자연친화적이고 은둔적인 성향은 그들이 자연의 수호자가 되도록 했고, 그로인해 종종 샬로레 엘프들과 대립하는 일도 생기게 되었습니다.",
		"잠시동안 적에게 입히는 피해와 자신이 받는 피해 저항력을 동시에 끌어올리는 #GOLD#나무의 분노#WHITE#를 사용할 수 있습니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+2, 민첩+3, 체격+1",
		"#LIGHT_BLUE# * 마법-2, 의지+1, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 11",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 35%",
	},
	inc_stats = { str=2, mag=-2, wil=1, cun=0, dex=3, con=1 },
	talents_types = { ["race/thalore"]={true, 0} },
	talents = { [ActorTalents.T_THALOREN_WRATH]=1 },
	copy = {
		moddable_tile = "elf_#sex#",
		moddable_tile_base = "base_thalore_01.png",
		moddable_tile_ornament = {female="braid_01"},
		random_name_def = "thalore_#sex#",
		default_wilderness = {"playerpop", "thaloren"},
		starting_zone = "norgos-lair",
		starting_quest = "start-thaloren",
		faction = "thalore",
		starting_intro = "thalore",
		life_rating = 11,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
	},
	experience = 1.30,
	random_escort_possibilities = { {"norgos-lair", 2, 3}, {"heart-gloom", 1, 2}, {"daikara", 1, 3}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}
