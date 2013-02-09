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

-- Empty Hand adds extra scaling to gauntlet and glove attacks based on character level.

newTalent{
	name = "Empty Hand",
	kr_display_name = "맨주먹의 힘",
	type = {"technique/unarmed-other", 1},
	innate = true,
	hide = true,
	mode = "passive",
	points = 1,
	no_unlearn_last = true,
	getDamage = function(self, t) return self.level * 0.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[무기를 사용하지 않을 때, 물리력을 %d 증가시킵니다.
		물리력 상승량은 캐릭터의 레벨에 따라 증가합니다.]]):
		format(damage)
	end,
}

-- generic unarmed training
newTalent{
	name = "Unarmed Mastery",
	kr_display_name = "맨손 격투 수련",
	type = {"technique/unarmed-training", 1},
	points = 5,
	require = { stat = { cun=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[무기를 사용하지 않으면 물리력이 %d 증가하고, 모든 맨손 격투의 피해량이 %d%% 증가합니다. (발차기와 잡기류 포함)
		격투가는 캐릭터 레벨 당 0.5 의 물리력을 추가로 얻고 (현재 격투가의 추가 물리력 : %0.1f), 다른 직업보다 맨손 공격 속도가 40%% 더 빠릅니다.]]):
		format(damage, 100*inc, self.level * 0.5)
	end,
}

newTalent{
	name = "Steady Mind",
	kr_display_name = "평정심",
	type = {"technique/unarmed-training", 2},
	mode = "passive",
	points = 5,
	require = techs_cun_req2,
	getDefense = function(self, t) return self:combatTalentStatDamage(t, "dex", 5, 35) end,
	getMental = function(self, t) return self:combatTalentStatDamage(t, "cun", 5, 35) end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local saves = t.getMental(self, t)
		return ([[정신적 수양을 통해 평정심을 갖게 되었습니다. 적들의 공격에 차분하게 대응하여 회피도가 %d / 정신 내성이 %d 상승합니다.
		회피도는 민첩 능력치, 정신 내성은 교활함 능력치의 영향을 받아 상승합니다.]]):
		format(defense, saves)
	end,
}

newTalent{
	name = "Heightened Reflexes",
	kr_display_name = "반사신경 향상",
	type = {"technique/unarmed-training", 3},
	require = techs_cun_req3,
	mode = "passive",
	points = 5,
	getPower = function(self, t) return self:getTalentLevel(t)/2 end,
	do_reflexes = function(self, t)
		self:setEffect(self.EFF_REFLEXIVE_DODGING, 1, {power=t.getPower(self, t)})
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[발사체가 자신을 향해 날아올 때, 전체 속도가 1 턴 동안 %d%% 증가합니다. 이동 이외의 행동을 하면 이 효과는 사라집니다.]]):
		format(power * 100)
	end,
}

newTalent{
	name = "Combo String",
	kr_display_name = "연계 강화",
	type = {"technique/unarmed-training", 4},
	require = techs_cun_req4,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.ceil(self:getTalentLevel(t)/2) end,
	getChance = function(self, t) return self:getTalentLevel(t) * (5 + self:getCun(5, true)) end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[연계 점수를 획득할 때마다, %d%% 확률로 1 의 연계 점수를 추가로 획득합니다. 그리고, 연계 점수의 지속 시간이 %d 턴 늘어납니다.
		연계 점수를 추가로 획득할 확률은 교활함 능력치의 영향을 받아 증가합니다.]]):
		format(chance, duration)
	end,
}
