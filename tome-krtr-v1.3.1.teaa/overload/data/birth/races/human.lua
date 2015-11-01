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
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Human",
	kr_name = "인간",
	desc = {
		"인간은 하플링과 더불어 마즈'에이알에서 가장 흔한 종족입니다. 수천 년 동안 인간과 하플링은 서로 싸워왔으며, 이는 어떤 사건이 일어나고 위대한 인물들이 인간과 하플링을 하나의 규율 아래 단결시키기 전까지 계속되었습니다",
		"연합 왕국이 만들어진 후, 인간과 하플링들은 한 세기가 넘는 평화를 지금껏 누려왔습니다.",
		"인간은 하이어 (Higher) 와 나머지 인종의 두 부류로 나뉩니다. 하이어의 피 속에는 뛰어난 능력과 감각, 그리고 장수를 부여하는 마법이 흐르고 있습니다.",
		"하이어가 아닌 인종들은 빠른 학습능력과 기술 숙달의 재능을 부여받았습니다. 그들이 원하는 어떠한 것이든 될 수 있고 할 수 있습니다.",
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
		resolvers.inventory({id=true, transmo=false, alter=function(o) o.inscription_data.cooldown=12 o.inscription_data.heal=50 end, {type="scroll", subtype="infusion", name="healing infusion", ego_chance=-1000, ego_chance=-1000}}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
	},
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	moddable_attachement_spots = "race_human",
	cosmetic_unlock = {
		cosmetic_race_human_redhead = {
			{name="Redhead [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" end end},
			{name="Red braids [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_ornament = {female="braid_redhead_01"} end end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
		},
		cosmetic_bikini =  {
			{name="비키니 [기부자 전용]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Bikini if not o then print("No bikini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_BIKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
			{name="맨키니 [기부자 전용]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Mankini if not o then print("No mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_MANKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Male" end},
		},
	},
}

---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Higher",
	kr_name = "하이어",
	desc = {
		"하이어는 미혹의 시대 때 마법의 잠재력을 받은 인종입니다.",
		"다른 인종과 피를 섞지 않고, 자신들의 '순수한' 혈통을 보존하려 합니다.",
		"잠시동안 상처를 치유해주는 #GOLD#순수 혈통의 재능#WHITE#을 비롯한, 하이어 종족 기술들을 사용할 수 있습니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+1, 민첩+1, 체격+0",
		"#LIGHT_BLUE# * 마법+1, 의지+1, 교활함+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# 11",
		"#GOLD#경험치 불이익 :#LIGHT_BLUE# 15%",
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
	kr_name = "코르낙",
	desc = {
		"코르낙은 연맹 왕국의 북부 지방 사람들입니다.",
		"종족 기술은 없지만, 적응력이 매우 뛰어나기 때문에 #GOLD#기술계열 점수#WHITE#를 시작할 때 1 점 추가로 받습니다. (다른 종족들은 10, 20, 36 레벨에서만 받을 수 있음)",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+0",
		"#LIGHT_BLUE# * 마법+0, 의지+0, 교활함+0",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# 10",
		"#GOLD#경험치 불이익 :#LIGHT_BLUE# 0%",
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
