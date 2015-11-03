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

setAuto("subclass", false)
setAuto("subrace", false)

setStepNames{
	world = "Campaign",
	race = "Race Category",
	subrace = "Race",
	class = "Class Category",
	subclass = "Class",
}

newBirthDescriptor{
	type = "base",
	name = "base",
	kr_name = "기본",
	desc = {
	},
	descriptor_choices =
	{
		difficulty =
		{
			Tutorial = "disallow",
		},
		world =
		{
			["Maj'Eyal"] = "allow",
			Infinite = "allow",
			Arena = "allow",
			Ents = "disallow",
			Spydre = "disallow",
			Orcs = "disallow",
			Trolls = "disallow",
			Nagas = "disallow",
			Undeads = "disallow",
			Faeros = "disallow",
		},
		class =
		{
			-- Specific to some races
			None = "disallow",
		},
	},
	talents = {},
	experience = 1.0,
	body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1, QS_QUIVER = 1 },

	copy = {
		-- Some basic stuff
		move_others = true,
		no_auto_resists = true, no_auto_saves = true,
		no_auto_high_stats = true,
		resists_cap = {all=70},
		keep_inven_on_death = true,
		can_change_level = true,
		can_change_zone = true,
		save_hotkeys = true,

		-- Mages are unheard of at first, nobody but them regenerates mana
		mana_rating = 6,
		mana_regen = 0,

		max_level = 50,
		money = 15,
		resolvers.equip{ id=true,
			{type="lite", subtype="lite", name="brass lantern", ignore_material_restriction=true, ego_chance=-1000},
		},
		make_tile = function(e)
			if not e.image then e.image = "player/"..e.descriptor.subrace:lower():gsub("[^a-z0-9_]", "_").."_"..e.descriptor.sex:lower():gsub("[^a-z0-9_]", "_")..".png" end
		end,
	},
	game_state = {
		force_town_respec = 1,
	}
}


--------------- Difficulties
newBirthDescriptor{
	type = "difficulty",
	name = "Tutorial",
	kr_name = "초보자 입문용 연습게임",
	never_show = true,
	desc =
	{
		"#GOLD##{bold}#입문용 연습게임",
		"#WHITE#연습용 캐릭터와 간단한 퀘스트를 통해, 게임에 대해 배우게됩니다.#{normal}#",
		"플레이어가 받는 모든 피해는 20% 감소됩니다.",
		"플레이어가 받는 모든 치유효과가 10% 증가됩니다.",
		"본 게임의 업적은 달성할 수 없습니다.",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "forbid",
			["Tutorial Human"] = "allow",
		},
		subrace =
		{
			__ALL__ = "forbid",
			["Tutorial Human"] = "allow",
		},
		class =
		{
			__ALL__ = "forbid",
			["Tutorial Adventurer"] = "allow",
		},
		subclass =
		{
			__ALL__ = "forbid",
			["Tutorial Adventurer"] = "allow",
		},
	},
	copy = {
		auto_id = 2,
		no_birth_levelup = true,
		infinite_lifes = 1,
		__game_difficulty = 1,
		__allow_rod_recall = false,
		__allow_transmo_chest = false,
		instakill_immune = 1,
	},
	game_state = {
		grab_online_event_forbid = true,
		always_learn_birth_talents = true,
		force_town_respec = false,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Easy",
	display_name = "Easier",
	kr_name = "쉬움",
	desc =
	{
		"#GOLD##{bold}#쉬운 난이도#WHITE##{normal}#",
		"조금 더 쉬운 게임을 할 수 있습니다.",
		"더 어려운 모드에서 플레이하기 힘들다면 선택하세요.",
		"플레이어가 받는 모든 피해가 30% 감소됩니다.",
		"플레이어가 받는 모든 치유효과가 30% 증가됩니다.",
		"모든 나쁜 상태 이상 효과의 지속시간이 50% 감소합니다.",
		"업적을 달성할 수 없습니다.",
	},
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	copy = {
		instakill_immune = 1,
		__game_difficulty = 1,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Normal",
	kr_name = "보통",
	selection_default = true,
	desc =
	{
		"#GOLD##{bold}#모험 난이도#WHITE##{normal}#",
		"도전하기에 적당한 난이도를 제공합니다.",
	},
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	copy = {
		instakill_immune = 1,
		__game_difficulty = 2,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Nightmare",
	kr_name = "악몽",
	desc =
	{
		"#GOLD##{bold}#악몽 난이도#WHITE##{normal}#",
		"불리한 게임 설정입니다.",
		"모든 지역의 레벨이 50% + 3 증가됩니다.",
		"모든 적들의 기술 레벨이 30% 증가됩니다.",
		"악몽 난이도에서 로그라이크 모드나 모험 모드로 플레이하면, 악몽 등급의 업적을 달성할 수 있습니다.",
	},
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	copy = {
		instakill_immune = 1,
		__game_difficulty = 3,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Insane",
	kr_name = "정신나간",
	locked = function() return profile.mod.allow_build.difficulty_insane end,
	locked_desc = "쉬움은 너무 약해! 보통도 너무 약해! 악몽은 아주 쉽지! 진짜 고통을 가져오라고!",
	desc =
	{
		"#GOLD##{bold}#정신나간 난이도#WHITE##{normal}#",
		"악몽 난이도와 비슷하지만, '보스' 등급의 적들이 더욱 많습니다!",
		"모든 지역의 레벨이 50% + 6 증가됩니다.",
		"모든 적들의 기술 레벨이 50% 증가됩니다.",
		"'희귀' 등급의 적들이 훨씬 자주 등장하고, 아무 곳에서나 '보스' 등급의 적들이 나타나기 시작합니다.",
		"고정된 '보스'등급의 적들은 임의의 기술들을 추가로 가집니다.",
		"모든 적들의 생명력이 20% 더 많아집니다.",
		"플레이어의 등급이 '정예' 가 아닌 '보통' 으로 설정됩니다.",
		"정신나간 난이도에서 로그라이크 모드나 모험 모드로 플레이하면, 정신나간 등급의 업적을 달성할 수 있습니다.",
            },
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	copy = {
		instakill_immune = 1,
		__game_difficulty = 4,
	},
	game_state = {
		default_random_rare_chance = 3,
		default_random_boss_chance = 20,
	},
}
newBirthDescriptor{
	type = "difficulty",
	name = "Madness",
	kr_name = "미치광이",
	locked = function() return profile.mod.allow_build.difficulty_madness end,
	locked_desc = "정신이 나갔어도 너무 쉬워! 진짜로 머리가 깨질 경험을 가져오라고!",
	desc =
	{
		"#GOLD##{bold}#미치광이 난이도#WHITE##{normal}#",
		"절대적으로 불리한 게이 설정입니다. 정말 정신병이 걸렸을 정도로 이 게임에 빠져있다면 이 난이도로 즐겨보세요!",
		"모든 지역의 레벨이 150% + 10 증가됩니다.",
		"모든 적들의 기술 레벨이 170% 증가됩니다.",
		"'희귀' 등급의 적들이 훨씬 자주 등장하고, 아무 곳에서나 '보스' 등급의 적들이 나타나기 시작합니다.",
		"보스급 적들은 임의의 기술들을 추가로 가집니다.",
		"플레이어가 사냥감이 됩니다! 가끔씩 일정 반경내의 모든 적들이 플레이어의 위치를 알아차리게 됩니다.",
		"플레이어의 등급이 '정예' 가 아닌 '보통' 으로 설정됩니다.",
		"미치광이 난이도에서 로그라이크 모드나 모험 모드로 플레이하면, 미치광이 등급의 업적을 달성할 수 있습니다.",
	},
	descriptor_choices =
	{
		race = { ["Tutorial Human"] = "forbid", },
		class = { ["Tutorial Adventurer"] = "forbid", },
	},
	talents = {
		[ActorTalents.T_HUNTED_PLAYER] = 1,
	},
	copy = {
		instakill_immune = 1,
		__game_difficulty = 5,
	},
	game_state = {
		default_random_rare_chance = 3,
		default_random_boss_chance = 20,
	},
}

--------------- Permadeath
newBirthDescriptor{
	type = "permadeath",
	name = "Exploration",
	kr_name = "탐사 모드",
	locked = function(birther) return birther:isDonator() end,
	locked_desc = "탐사 모드 : 무한한 생명 (기부자용 모드)",
	locked_select = function(birther) birther:selectExplorationNoDonations() end,
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.permadeath == "Exploration",
	desc =
	{
		"#GOLD##{bold}#탐사 모드#WHITE#",
		"부활 횟수에 제한이 없습니다.#{normal}#",
		"이 모드는 원래 의도했던 플레이 방식은 아니지만, 좀 더 편하게 게임을 플레이할 수 있게 해줍니다.",
		"하지만, 캐릭터의 사망은 게임에 있어서 중요한 요소이며 당신이 더 능숙한 플레이어가 되도록 해준다는 것을 기억하세요.",
		"탐사 모드용 업적을 얻을 수 있습니다.",
	},
	game_state = {
		force_town_respec = false,
	},
	copy = {
		infinite_respec = 1,
		infinite_lifes = 1,
	},
}
newBirthDescriptor{
	type = "permadeath",
	name = "Adventure",
	kr_name = "모험 모드",
	selection_default = (not config.settings.tome.default_birth) or (config.settings.tome.default_birth and config.settings.tome.default_birth.permadeath == "Adventure"),
	desc =
	{
		"#GOLD##{bold}#모험 모드#WHITE#",
		"제한된 횟수의 부활 기회를 제공합니다.",
		"적당한 조건에서 플레이하고 싶지만, 아직 로그라이크 모드를 할 준비가 되지 않았다고 생각한다면 선택하세요.#{normal}#",
		"1, 2, 5, 7, 14, 24, 35 레벨에서 총 7 개의 추가 생명을 부여받습니다.",
	},
	copy = {
		easy_mode_lifes = 1,
	},
}
newBirthDescriptor{
	type = "permadeath",
	name = "Roguelike",
	kr_name = "로그라이크 모드",
	selection_default = config.settings.tome.default_birth and config.settings.tome.default_birth.permadeath == "Roguelike",
	desc =
	{
		"#GOLD##{bold}#로그라이크 모드#WHITE#",
		"'정통' 로그라이크 게임에 가까운 게임 플레이를 제공합니다.",
		"추가 생명은 주어지지 않으며, 당신이 *바로* 당신의 캐릭터입니다.#{normal}#",
		"게임상에서 찾을 수 있는 부활 기회를 제외하면, 하나의 생명만을 제공받습니다.",
	},
}


-- Worlds
load("/data/birth/worlds.lua")

-- Races
load("/data/birth/races/tutorial.lua")
load("/data/birth/races/human.lua")
load("/data/birth/races/elf.lua")
load("/data/birth/races/halfling.lua")
load("/data/birth/races/dwarf.lua")
load("/data/birth/races/yeek.lua")
load("/data/birth/races/giant.lua")
load("/data/birth/races/undead.lua")
load("/data/birth/races/construct.lua")

-- Sexes
load("/data/birth/sexes.lua")

-- Classes
load("/data/birth/classes/tutorial.lua")
load("/data/birth/classes/warrior.lua")
load("/data/birth/classes/rogue.lua")
load("/data/birth/classes/mage.lua")
load("/data/birth/classes/wilder.lua")
load("/data/birth/classes/celestial.lua")
load("/data/birth/classes/corrupted.lua")
load("/data/birth/classes/afflicted.lua")
load("/data/birth/classes/chronomancer.lua")
load("/data/birth/classes/psionic.lua")
load("/data/birth/classes/adventurer.lua")
load("/data/birth/classes/none.lua")
