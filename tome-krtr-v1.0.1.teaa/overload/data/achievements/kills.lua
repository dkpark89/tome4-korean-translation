-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

newAchievement{
	name = "That was close",
	kr_name = "십년감수",
	show = "full",
	desc = [[생명력이 1 만 남은 상태로 적을 죽임.]],
}
newAchievement{
	name = "Size matters",
	kr_name = "크기의 문제",
	show = "full",
	desc = [[한 번의 공격으로 600 이상의 피해를 줌.]],
	on_gain = function(_, src, personal)
		if src.descriptor and (src.descriptor.subclass == "Rogue" or src.descriptor.subclass == "Shadowblade") then
			game:setAllowedBuild("rogue_marauder", true)
		end
	end,
}
newAchievement{
	name = "Size is everything", id = "DAMAGE_1500",
	kr_name = "크기가 전부야",
	show = "full",
	desc = [[한 번의 공격으로 1,500 이상의 피해를 줌.]],
}
newAchievement{
	name = "The bigger the better!", id = "DAMAGE_3000",
	kr_name = "크면 클수록 더 좋지!",
	show = "full",
	desc = [[한 번의 공격으로 3,000 이상의 피해를 줌.]],
}
newAchievement{
	name = "Overpowered!", id = "DAMAGE_6000",
	kr_name = "압도!",
	show = "full",
	desc = [[한 번의 공격으로 6,000 이상의 피해를 줌.]],
}
newAchievement{
	name = "Exterminator",
	kr_name = "절멸자",
	show = "full",
	desc = [[1,000 마리의 생명체를 살해.]],
	mode = "player",
	can_gain = function(self, who)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 1000 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
}
newAchievement{
	name = "Pest Control",
	kr_name = "해충 구제",
	image = "npc/vermin_worms_green_worm_mass.png",
	show = "full",
	desc = [[1,000 마리의 해충 살해.]],
	mode = "player",
	can_gain = function(self, who, target)
		if target:knowTalent(target.T_MULTIPLY) or target.clone_on_hit then
			self.nb = (self.nb or 0) + 1
			if self.nb >= 1000 then return true end
		end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
}
newAchievement{
	name = "Reaver",
	kr_name = "파괴자",
	show = "full",
	desc = [[1,000 명의 영장류 살해.]],
	mode = "world",
	can_gain = function(self, who, target)
		if target.type == "humanoid" then
			self.nb = (self.nb or 0) + 1
			if self.nb >= 1000 then return true end
		end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 1000"} end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("corrupter")
		game:setAllowedBuild("corrupter_reaver", true)
	end,
}

newAchievement{
	name = "Backstabbing Traitor", id = "ESCORT_KILL",
	kr_name = "중상모략적인 배반자",
	image = "object/knife_stralite.png",
	show = "full",
	desc = [[모험가 호위 중, 자기 손으로 모험가를 6 번 죽임.]],
	mode = "player",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 6 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 6"} end,
}

newAchievement{
	name = "Bad Driver", id = "ESCORT_LOST",
	kr_name = "나쁜 길잡이",
	show = "full",
	desc = [[모험가 호위를 모두 실패함.]],
	mode = "player",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 9 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 9"} end,
}

newAchievement{
	name = "Guiding Hand", id = "ESCORT_SAVED",
	kr_name = "인도의 손길",
	show = "full",
	desc = [[모험가 호위를 모두 성공함.]],
	mode = "player",
	can_gain = function(self, who, target)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 9 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 9"} end,
}

newAchievement{
	name = "Earth Master", id = "GEOMANCER",
	kr_name = "대지의 명인",
	show = "name",
	desc = [[하코르'준을 죽이고, 암석 마법 계열의 봉인을 해제.]],
	mode = "player",
}

newAchievement{
	name = "Kill Bill!", id = "KILL_BILL",
	kr_name = "킬 빌!",
	image = "object/artifact/bill_treestump.png",
	show = "full",
	desc = [[레벨 1 캐릭터로 트롤 늪의 빌을 죽임.]],
	mode = "player",
}

newAchievement{
	name = "Atamathoned!", id = "ATAMATHON",
	kr_name = "아타마쏜!",
	image = "npc/atamathon.png",
	show = "name",
	desc = [[거대 골렘 아타마쏜을 어리석게도 재작동시킨 후, 다시 파괴함.]],
	mode = "player",
}

newAchievement{
	name = "Huge Appetite", id = "EAT_BOSSES",
	kr_name = "거대한 식욕",
	show = "full",
	desc = [[보스 20명 '삼키기'.]],
	mode = "player",
	can_gain = function(self, who, target)
		if target.rank < 3.5 then return false end
		self.nb = (self.nb or 0) + 1
		if self.nb >= 20 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 20"} end,
}

newAchievement{
	name = "Headbanger", id = "HEADBANG",
	kr_name = "박치기왕",
	show = "full",
	desc = [[20명의 보스를 '박치기'로 죽임.]],
	mode = "player",
	can_gain = function(self, who, target)
		if target.rank < 3.5 then return false end
		self.nb = (self.nb or 0) + 1
		if self.nb >= 20 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 20"} end,
}

newAchievement{
	name = "Are you out of your mind?!", id = "UBER_WYRMS_OPEN",
	kr_name = "너 지금 미쳤어?!",
	image = "npc/dragon_multihued_multi_hued_drake.png",
	show = "name",
	desc = [[보르 무기고에서 '너무나 엄청나게 강력한 무지개빛 고위 용' 의 관심을 받음. 목숨이 아깝다면 도망치는 것이 순리.]],
	mode = "player",
}

newAchievement{
	name = "I cleared the room of death and all I got was this lousy achievement!", id = "UBER_WYRMS", --주로 티셔츠에 ~~~~ and all I got was this lousy T-shirt! 드립으로 자주 나오는 말이죠.
	kr_name = "죽음의 방을 싹쓸이했지만, 내가 얻은 것이라고는 이 바보같은 도전과제 뿐이야!",
	image = "npc/dragon_multihued_multi_hued_drake.png",
	show = "name",
	desc = [[보르 무기고의 "죽음의 방"에 있는 일곱 마리의 압도적인 용을 죽임.]],
	mode = "player",
	can_gain = function(self, who)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 7 then return true end
	end,
}

newAchievement{
	name = "I'm a cool hero", id = "NO_DERTH_DEATH",
	kr_name = "나는 멋진 영웅이지",
	image = "npc/humanoid_human_human_farmer.png",
	show = "name",
	desc = [[마을 주민을 한 명도 죽게 놔두지 않고 데르스 마을 구출.]],
	mode = "player",
}

newAchievement{
	name = "Kickin' it old-school", id = "FIRST_BOSS_URKIS",
	kr_name = "옛 방식으로 작살내기",
	image = "npc/humanoid_human_urkis__the_high_tempest.png",
	show = "full",
	desc = [[대기술사 우르키스를 죽이고, 그에게서 되돌림의 장대를 획득.]],
	mode = "player",
}

newAchievement{
	name = "Leave the big boys alone", id = "FIRST_BOSS_MASTER",
	kr_name = "다 큰 놈은 내버려 둬",
	image = "npc/the_master.png",
	show = "full",
	desc = [['주인' 을 죽이고, 그에게서 되돌림의 장대를 획득.]],
	mode = "player",
}

newAchievement{
	name = "You know who's to blame", id = "FIRST_BOSS_GRAND_CORRUPTOR",
	kr_name = "누가 비난받을지 알지",
	image = "npc/humanoid_shalore_grand_corruptor.png",
	show = "full",
	desc = [[위대한 타락자를 죽이고, 그에게서 되돌림의 장대를 획득.]],
	mode = "player",
}

newAchievement{
	name = "You know who's to blame (reprise)", id = "FIRST_BOSS_MYSSIL",
	kr_name = "누가 비난받을지 알지 (반복)",
	image = "npc/humanoid_halfling_protector_myssil.png",
	show = "full",
	desc = [[미씰을 죽이고, 그에게서 되돌림의 장대를 획득.]],
	mode = "player",
}
