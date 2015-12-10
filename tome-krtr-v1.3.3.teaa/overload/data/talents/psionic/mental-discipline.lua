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




newTalent{
	name = "Aura Discipline",
	kr_name = "오러 수련",
	type = {"psionic/mental-discipline", 1},
	require = psi_wil_req1,
	points = 5,
	mode = "passive",
	cooldownred = function(self,t) return math.max(0,math.floor(self:combatTalentLimit(t, 8, 1, 5))) end, -- Limit to <8 turns reduction
	getMastery = function(self, t) return self:combatTalentScale(t, 2.5, 10, 0.75) end,
	info = function(self, t)
		local cooldown = t.cooldownred(self,t)
		local mast = t.getMastery(self, t)
		return ([[염력 발산법을 수련하여 오러의 재사용 대기시간이 %d 턴 줄어들고, 염력 소비량이 줄어듭니다.
		염력 1 당 %0.2f 피해를 더 줄 수 있게 됩니다.]]):format(cooldown, mast)
	end,
}

newTalent{
	name = "Shield Discipline",
	kr_name = "보호막 수련",
	type = {"psionic/mental-discipline", 2},
	require = psi_wil_req2,
	points = 5,
	mode = "passive",
	mastery = function(self,t) return self:combatTalentLimit(t, 20, 3, 10) end, -- Adjustment to damage absorption, Limit to 20
	cooldownred = function(self,t) return math.floor(self:combatTalentLimit(t, 16, 4, 10)) end,  -- Limit to <16 turns reduction
	absorbLimit = function(self,t) return self:combatTalentScale(t, 0.5, 2) end, -- Limit of bonus psi on shield hit per turn
	info = function(self, t)
		local cooldown = t.cooldownred(self,t)
		local mast = t.mastery(self,t)
		return ([[염력 보호법을 수련하여 보호막의 재사용 대기시간이 %d 턴 줄어들고, 염력 회복량이 증가합니다. (%0.1f 피해를 덜 받아도 염력이 1 회복됩니다)
		또한 각각의 보호막을 통해 매 턴마다 얻을 수 있는 최대 염력량이 %0.1f 증가합니다.]]):
		format(cooldown, mast, t.absorbLimit(self, t))
	end,
}

newTalent{
	name = "Iron Will",
	kr_name = "불굴의 의지",
	type = {"psionic/mental-discipline", 3},
	require = psi_wil_req3,
	points = 5,
	mode = "passive",
	stunImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.17, 0.50) end,
	on_learn = function(self, t)
		self.combat_mentalresist = self.combat_mentalresist + 6
	end,
	on_unlearn = function(self, t)
		self.combat_mentalresist = self.combat_mentalresist - 6
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "stun_immune", t.stunImmune(self, t))
	end,
	info = function(self, t)
		return ([[정신 내성이 %d / 기절 면역력이 %d%% 증가합니다.]]):
		format(self:getTalentLevelRaw(t)*6, t.stunImmune(self, t)*100)
	end,
}

newTalent{
	name = "Highly Trained Mind",
	kr_name = "고도로 훈련된 정신",
	type = {"psionic/mental-discipline", 4},
	mode = "passive",
	require = psi_wil_req4,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_WIL] = self.inc_stats[self.STAT_WIL] + 2
		self:onStatChange(self.STAT_WIL, 2)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] + 2
		self:onStatChange(self.STAT_CUN, 2)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_WIL] = self.inc_stats[self.STAT_WIL] - 2
		self:onStatChange(self.STAT_WIL, -2)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] - 2
		self:onStatChange(self.STAT_CUN, -2)
	end,
	info = function(self, t)
		return ([[고도로 정신을 훈련하여, 의지와 교활함을 증가시킵니다.
		의지와 교활함 능력치가 %d 증가합니다.]]):format(2*self:getTalentLevelRaw(t))
	end,
}
