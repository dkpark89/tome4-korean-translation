﻿-- ToME - Tales of Maj'Eyal
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
	name = "Human",
	display_name = "인간",
	desc = {
		"인간은 하플링과 더불어 마즈'에이알에서 가장 흔한 종족입니다. 오래 전, 스펠블레이즈가 일어나고 위대한 인물들이 인간과 하플링을 하나의 규율 아래 단결시키기 전에는 수천년간 인간과 하플링은 서로 싸워왔었습니다.",
		"그 후 연합 왕국의 백성은 한 세기가 넘는 평화를 지금껏 누려왔습니다.",
		"인간은 하이어(Higher)와 나머지 인종의 두 부류로 나뉩니다. 뛰어난 능력과 감각, 그리고 장수를 부여하는 마법이 그들(Higher)의 피 속에 흐르고 있습니다.",
		"나머지 인종들은 빠른 학습능력과 기술 숙달의 재능을 부여받았습니다. 그들이 원하는 어떠한 것으로든 될 수 있고 할 수 있습니다.",
	},
	descriptor_choices =
	{
		subrace =
		{
			["Cornac"] = "allow",
			["Higher"] = "allow",
			__ALL__ = "disallow",
		},
		subclass =
		{
			-- Only human and elves make sense to play celestials
			['Sun Paladin'] = "allow",
			['Anorithil'] = "allow",
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	talents = {},
	copy = {
		faction = "allied-kingdoms",
		type = "humanoid", subtype="human",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},
	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Higher",
	display_name = "하이어",
	desc = {
		"하이어는 미혹의 시대 때 마법의 잠재력을 받은 인종입니다.",
		"다른 인종과 피를 섞지 않고, 자신들의 '순수한' 혈통을 보존하려합니다.",
		"잠시동안 상처를 치유해주는 #GOLD#순수 혈통의 재능#WHITE#을 사용할 수 있습니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+1, 민첩+1, 체격+0",
		"#LIGHT_BLUE# * 마법+1, 의지+1, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 11",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 15%",
	},
	inc_stats = { str=1, mag=1, dex=1, wil=1 },
	experience = 1.15,
	talents_types = { ["race/higher"]={true, 0} },
	talents = {
		[ActorTalents.T_HIGHER_HEAL]=1,
	},
	copy = {
		moddable_tile = "human_#sex#",
		moddable_tile_base = "base_higher_01.png",
		random_name_def = "higher_#sex#",
		life_rating = 11,
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "higher",
	},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Cornac",
	display_name = "코르낙",
	desc = {
		"코르낙은 연맹 왕국의 북부 지방 사람들입니다.",
		"적응력이 매우 뛰어나기 때문에 #GOLD#기술계열 점수#WHITE#를 시작할때 1점 받습니다(다른 종족은 10,20,30 레벨에서만 받을 수 있음).",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 10",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 0%",
	},
	experience = 1.0,
	copy = {
		moddable_tile = "human_#sex#",
		moddable_tile_base = "base_cornac_01.png",
		random_name_def = "cornac_#sex#",
		unused_talents_types = 1,
		life_rating = 10,
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "cornac",
	},
}
