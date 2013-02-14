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
--                       Ghouls                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Undead",
	kr_display_name = "언데드",
	locked = function() return profile.mod.allow_build.undead end,
	locked_desc = "죽음의 힘, 무시무시한 의지, 이 육신은 멈추질 못하리. 왕은 죽고, 지배자는 쓰러지나, 우리는 그들보다 오래가리라.",
	desc = {
		"언데드는 타락한 어둠의 마법으로 이승에 되돌아온 부정한 영장류(인간, 엘프, 드워프, ...)입니다.",
		"구울에서부터 흡혈귀나 리치에 이르기까지 다양한 종류가 있습니다.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Ghoul = "allow",
			Skeleton = "allow",
			Vampire = "allow",
			Wight = "allow",
		},
		class =
		{
			Wilder = "disallow",
		},
		subclass =
		{
			Necromancer = "nolore",
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	talents = {
		[ActorTalents.T_UNDEAD_ID]=1,
	},
	copy = {
		-- Force undead faction to undead
		resolvers.genericlast(function(e) e.faction = "undead" end),
		starting_zone = "blighted-ruins",
		starting_level = 3, starting_level_force_down = true,
		starting_quest = "start-undead",
		undead = 1,
		forbid_nature = 1,
		inscription_restrictions = { ["inscriptions/runes"] = true, ["inscriptions/taints"] = true, },
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10}),
	},
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

newBirthDescriptor
{
	type = "subrace",
	name = "Ghoul",
	kr_display_name = "구울",
	locked = function() return profile.mod.allow_build.undead_ghoul end,
	locked_desc = "걸을 때는 느리게, 물어뜯을 때는 빠르게, 주인님께 배운 대로, 밤을 지배하리!",
	desc = {
		"구울은 썩어가는 언데드이며, 멍청하지만 강인하기에 훌륭한 전사가 될 수 있습니다.",
		"#GOLD#구울 종족 기술#WHITE#계열로 다양한 언데드 능력을 사용할 수 있습니다.",
		"- 굉장한 독 저항력",
		"- 출혈 완전 면역",
		"- 기절 저항력",
		"- 공포 완전 면역",
		"- 구울 종족 기술: 구울의 도약, 구역질, 물어뜯기",
		"썩어가는 육체 때문에 구울은 다른 생물들보다 느리게 행동합니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+3, 민첩+1, 체격+5",
		"#LIGHT_BLUE# * 마법+0, 의지-2, 교활함-2",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 14",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 25%",
		"#GOLD#전체속도 불이익:#LIGHT_BLUE# -20%",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	inc_stats = { str=3, con=5, wil=-2, mag=0, dex=1, cun=-2 },
	talents_types = {
		["undead/ghoul"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_GHOUL]=1,
	},
	copy = {
		type = "undead", subtype="ghoul",
		default_wilderness = {"playerpop", "low-undead"},
		starting_intro = "ghoul",
		life_rating=14,
		poison_immune = 0.8,
		cut_immune = 1,
		stun_immune = 0.5,
		fear_immune = 1,
		global_speed_base = 0.8,
		moddable_tile = "ghoul",
		moddable_tile_nude = true,
	},
	experience = 1.25,
}

newBirthDescriptor
{
	type = "subrace",
	name = "Skeleton",
	kr_display_name = "스켈레톤",
	locked = function() return profile.mod.allow_build.undead_skeleton end,
	locked_desc = "진군하는 뼈의 군단, 걸음마다 덜그럭 덜그럭. 그러나 더는 섬기지 않으리, 우리는 싸우기 위해 진군한다!",
	desc = {
		"스켈레톤은 강하고 재빠른, 움직이는 해골입니다.",
		"#GOLD#스켈레톤 종족 기술#WHITE#로 다양한 언데드 능력을 사용할 수 있습니다:",
		"- 중독 완전 면역",
		"- 출혈 완전 면역",
		"- 공포 완전 면역",
		"- 호흡하지 않음",
		"- 스켈레톤 종족 기술: 해골 갑옷, 재생하는 뼈, 재조합",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+3, 민첩+4, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 12",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 40%",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	inc_stats = { str=3, con=0, wil=0, mag=0, dex=4, cun=0 },
	talents_types = {
		["undead/skeleton"]={true, 0.1},
	},
	talents = {
		[ActorTalents.T_SKELETON]=1,
	},
	copy = {
		type = "undead", subtype="skeleton",
		default_wilderness = {"playerpop", "low-undead"},
		starting_intro = "skeleton",
		life_rating=12,
		poison_immune = 1,
		cut_immune = 1,
		fear_immune = 1,
		no_breath = 1,
		blood_color = colors.GREY,
		moddable_tile = "skeleton",
		moddable_tile_nude = true,
	},
	experience = 1.4,
}
