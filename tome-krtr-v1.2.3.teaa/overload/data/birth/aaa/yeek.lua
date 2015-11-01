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
--                       Yeeks                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Yeek",
	kr_name = "이크",
	locked = function() return profile.mod.allow_build.yeek end,
	locked_desc = "하나의 종족, 하나의 정신, 하나의 길. 억압은 끝나고, 이제 에이알을 물려받으리라. 우리가 약하리라 넘겨짚지 말지어다 - 우리의 길은 진실되며, 우리를 돕는 자만이 우리의 힘을 보게 될 것이다.",
	desc = {
		"이크는 '렐' 이라는 열대의 섬에 사는 작고 신비로운 종족입니다.",
		"흰 모피로 덮힌 몸통과 커다란 머리통 때문에, 우스꽝스러운 모습을 하고 있습니다.",
		"이제는 마즈'에이알에서 그들을 볼 수 없게 되었지만, 그들은 수천 년 동안 하플링의 나르골 왕국에서 노예로 부려졌었습니다.",
		"장작더미의 시대에 자유를 얻은 이후로, 그들은 지금까지 초능력을 이용한 정신 통합체 '한길' 을 따라왔습니다.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Yeek = "allow",
		},
	},
	copy = {
		faction = "the-way",
		type = "humanoid", subtype="yeek",
		size_category = 2,
		default_wilderness = {"playerpop", "yeek"},
		starting_zone = "town-irkkk",
		starting_quest = "start-yeek",
		starting_intro = "yeek",
		blood_color = colors.BLUE,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory({id=true, transmo=false, alter=function(o) o.inscription_data.cooldown=12 o.inscription_data.heal=50 end, {type="scroll", subtype="infusion", name="healing infusion", ego_chance=-1000, ego_chance=-1000}}),
	},
	game_state = {
		start_tier1_skip = 4,
	},
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
	moddable_attachement_spots = "race_yeek", moddable_attachement_spots_sexless=true,

	cosmetic_unlock = {
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
--                       Yeeks                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Yeek",
	kr_name = "이크",
	locked = function() return profile.mod.allow_build.yeek end,
	locked_desc = "하나의 종족, 하나의 정신, 하나의 길. 억압은 끝나고, 이제 에이알을 물려받으리라. 우리가 약하리라 넘겨짚지 말지어다 - 우리의 길은 진실되며, 우리를 돕는 자만이 우리의 힘을 보게 될 것이다.",
	desc = {
		"이크는 '렐' 이라는 열대의 섬에 사는 작고 신비로운 종족입니다.",
		"흰 모피로 덮힌 몸통과 커다란 머리통 때문에, 우스꽝스러운 모습을 하고 있습니다.",
		"이제는 마즈'에이알에서 그들을 볼 수 없게 되었지만, 그들은 수천 년 동안 하플링의 나르골 왕국에서 노예로 부려졌었습니다.",
		"일시적으로 다른 약한 대상의 정신을 붕괴시켜 지배하며, 효과가 끝나면 대상이 마음이 없는 빈껍데기가 되어 죽는 기술인 #GOLD#지배의 의지#WHITE#를 비롯한, 이크 종족 기술들을 사용할 수 있습니다.",
		"이크가 양서류는 아니지만, 물에 익숙하기 때문에 숨을 쉬지 않고 더 오래 버틸 수 있습니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘-3, 민첩-2, 체격-5",
		"#LIGHT_BLUE# * 마법+0, 의지+6, 교활함+4",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# 7",
		"#GOLD#경험치 불이익 :#LIGHT_BLUE# -15% (15% 이익)",
		"#GOLD#혼란 면역력 :#LIGHT_BLUE# 35%",
	},
	inc_stats = { str=-3, con=-5, cun=4, wil=6, mag=0, dex=-2 },
	talents_types = { ["race/yeek"]={true, 0} },
	talents = {
		[ActorTalents.T_YEEK_WILL]=1,
		[ActorTalents.T_YEEK_ID]=1,
	},
	copy = {
		life_rating=7,
		confusion_immune = 0.35,
		max_air = 200,
		moddable_tile = "yeek",
		random_name_def = "yeek_#sex#",
	},
	experience = 0.85,
}
