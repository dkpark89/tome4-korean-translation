-- ToME - Tales of Middle-Earth
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

newTalent{
	name = "Hardened",
	kr_name = "강인함",
	type = {"cursed/traveler", 1},
	require = cursed_wil_req1,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.combat_armor = (self.combat_armor or 0) + 2
	end,
	on_unlearn = function(self, t)
		self.combat_armor = self.combat_armor - 2
	end,
	info = function(self, t)
		return ([[여행의 결과, 더 튼튼한 육체를 가지게 되었습니다. 방어도가 %d 상승합니다.]]):format(self:getTalentLevelRaw(t) * 2)
	end
}

newTalent{
	name = "Wary",
	kr_name = "신중함",
	type = {"cursed/traveler", 2},
	require = cursed_wil_req2,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.trap_avoidance = (self.trap_avoidance or 0) + 14
	end,
	on_unlearn = function(self, t)
		self.trap_avoidance = self.trap_avoidance - 14
	end,
	info = function(self, t)
		return ([[여행의 결과, 위험을 더 잘 감지할 수 있게 되었습니다. %d%% 확률로 함정을 발동시키지 않게 됩니다.]]):format(self:getTalentLevelRaw(t) * 14)
	end
}

newTalent{
	name = "Weathered",
	kr_name = "비바람",
	type = {"cursed/traveler", 3},
	require = cursed_wil_req3,
	mode = "passive",
	points = 5,

	on_learn = function(self, t)
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 7
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 7
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.FIRE] = self.resists[DamageType.FIRE] - 7
		self.resists[DamageType.COLD] = self.resists[DamageType.COLD] - 7
	end,
	info = function(self, t)
		return ([[오랜 여행 동안, 몸이 원소에 의해 '풍화' 되었습니다. 냉기와 화염 저항력이 %d%% 상승합니다.]]):format(self:getTalentLevel(t) * 7)
	end
}

newTalent{
	name = "Savvy",
	kr_name = "실용적 지식",
	type = {"cursed/traveler", 4},
	require = cursed_wil_req4,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.exp_kill_multiplier = (self.exp_kill_multiplier or 1) + 0.03
	end,
	on_unlearn = function(self, t)
		self.exp_kill_multiplier = (self.exp_kill_multiplier or 1) - 0.03
	end,
	info = function(self, t)
		return ([[여행을 하면서, 많은 지식을 쌓았습니다. 추가 경험치를 %d%% 만큼 얻게 됩니다.]]):format(self:getTalentLevelRaw(t) * 3)
	end
}

