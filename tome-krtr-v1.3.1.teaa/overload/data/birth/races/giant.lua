--- ToME - Tales of Maj'Eyal
--- Copyright (C) 2009 - 2015 Nicolas Casalini
---
--- This program is free software: you can redistribute it and/or modify
--- it under the terms of the GNU General Public License as published by
--- the Free Software Foundation, either version 3 of the License, or
--- (at your option) any later version.
---
--- This program is distributed in the hope that it will be useful,
--- but WITHOUT ANY WARRANTY; without even the implied warranty of
--- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--- GNU General Public License for more details.
---
--- You should have received a copy of the GNU General Public License
--- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---
--- Nicolas Casalini "DarkGod"
--- darkgod@te4.org

----------------------------------------------------------
---                       Giants                         --
----------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Giant",
	locked = function() return profile.mod.allow_build.race_giant end,
	locked_desc = "누구 보다 높이 선 강력한 존재들, 하지만 그들이 거대하면 거대 할 수록, 더 심하게 쓰러질 것이다...",
	desc = {
		[[#{italic}#"거인"#{normal}#은 두루뭉실하게 표현 되곤 하지만 보통 신장이 2.5m를 넘는 인간종을 부르는 말입니다. 그들의 기원, 문화, 다른 종족과의 관계는 종족마다 심하게 다르지만,  보통 그들은 이방인 취급을 받거나 따돌림을 받는 경향이 있습니다, 그들보다 작은 종족들에게 공포의 대상이 되어 피해지면서 말이죠.]],
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

----------------------------------------------------------
---                       Ogres                         --
----------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Ogre",
	locked = function() return profile.mod.allow_build.race_ogre end,
	locked_desc = [[오래 지난 증오의 시대에 구축되어,
전쟁을 위해 만들어졌지만 결국 마지막까지 살아 남았다.
그들의 잊혀진 탄생지는 깊은 지하에 존재하고,
그것의 통로는 파괴되어 찾을 수 없었다.
이전의 도굴꾼들은 실패하였지만, 그들의 정보는 불멸이니;
시작하기 위해서는, 하플링들이 포탈에 손을 대었었던 장소를 살펴보는 게 좋을 것이다...]],
	desc = {
		"오거는 인간의 변형 된 모습으로, 콘클라베를 위해 일할 노동자나 전사로서 만들어졌습니다.",
		"각인은 그들의 한계를 아득히 넘어선 물리적, 마법적 힘을 부여해 주었지만, 그들의 룬 마법에 대한 의존성은 마법사냥의 손쉬운 표적이 되게 하였습니다, 그것은 결과적으로 그들이 샬로레들 사이에 피난 하게 만들었죠.",
		"간단하고 직접적인 해결 방안을 선호하는 그들의 성향 때문에 멍청한 야만인이라는 부당한 평가를 받게 하였습니다. 각인을 다루는 특별한 기술과 겸손하고 순종적인 성격을 가졌음에도 말입니다",
		"그들은 그들의 공격이 빗나가거나 막혔을 때 치명타 확률과 배율을 올려주고, 혼란과 기절에 대한 저항성을 부여하는 #GOLD#오거의 분노#WHITE# 기술을 보유하고 있습니다.",
		"#GOLD#능력치 변화 :",
		"#LIGHT_BLUE# * 힘+3, 민첩-1, 체격+0",
		"#LIGHT_BLUE# * 마법+2, 의지-2, 교활+2",
		"#GOLD#레벨 당 생명력 :#LIGHT_BLUE# 13",
		"#GOLD#경험치 불이익 :#LIGHT_BLUE# 30%",
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
			{name="빨간머리 [기부자 전용]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" end end},
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
