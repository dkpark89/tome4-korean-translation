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

newAchievement{
	name = "Pyromancer",
	kr_name = "화염술사",
	desc = [[마도사 직업 봉인 해제 후, 누적 화염 피해를 백만 점 이상 입힘 (물체 속성/기술/직업 모두 사용 가능).]],
	show = "full",
	mode = "world",
	can_gain = function(self, who, dam)
		self.nb = (self.nb or 0) + dam
		return self.nb > 1000000 and profile.mod.allow_build.mage
	end,
	track = function(self) return tstring{tostring(math.floor(self.nb or 0))," / 1000000"} end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("mage_pyromancer", true)
		local p = game.party:findMember{main=true}
		if p.descriptor.subclass == "Archmage"  then
			if p:knowTalentType("spell/wildfire") == nil then
				p:learnTalentType("spell/wildfire", false)
				p:setTalentTypeMastery("spell/wildfire", 1.3)
			end
		end
	end,
}
newAchievement{
	name = "Cryomancer",
	kr_name = "냉기술사",
	desc = [[마도사 직업 봉인 해제 후, 누적 냉기 피해를 백만 점 이상 입힘 (물체 속성/기술/직업 모두 사용 가능).]],
	show = "full",
	mode = "world",
	can_gain = function(self, who, dam)
		self.nb = (self.nb or 0) + dam
		return self.nb > 1000000 and profile.mod.allow_build.mage
	end,
	track = function(self) return tstring{tostring(math.floor(self.nb or 0))," / 1000000"} end,
	on_gain = function(_, src, personal)
		game:setAllowedBuild("mage_cryomancer", true)
		local p = game.party:findMember{main=true}
		if p.descriptor.subclass == "Archmage"  then
			if p:knowTalentType("spell/ice") == nil then
				p:learnTalentType("spell/ice", false)
				p:setTalentTypeMastery("spell/ice", 1.3)
			end
		end
	end,
}
newAchievement{
	name = "Lichform",
	kr_name = "리치의 몸",
	desc = [[모든 사령술사들의 꿈이자 진정한 목표를 달성하여, 영원히 죽지 않는 리치가 되었습니다!]],
	show = "name",
}
newAchievement{
	name = "Best album ever!", id = "THE_CURE",
	kr_name = "최고의 앨범"
	desc = [[적의 이로운 효과를 89번 제거]],
	show = "full", 	mode = "player",
	can_gain = function(self, who)
		self.nb = (self.nb or 0) + 1
		if self.nb >= 89 then return true end
	end,
	track = function(self) return tstring{tostring(self.nb or 0)," / 89"} end,
}
