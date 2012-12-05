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

require "engine.krtrUtils"

newTalent{
	name = "Bloodbath",
	kr_display_name = "피바다",
	type = {"technique/bloodthirst", 1},
	require = techs_req_high1,
	points = 5,
	mode = "passive",
	getRegen = function (self, t) return self:getTalentLevel(t) end,
	getMax = function(self, t) return self:getTalentLevel(t)*5 end,
	do_bloodbath = function(self, t)
		self:setEffect(self.EFF_BLOODBATH, 5 + self:getTalentLevelRaw(t), {regen=t.getRegen(self, t), max=t.getMax(self, t), hp=math.floor(self:getTalentLevel(t) * 2)})
	end,
	info = function(self, t)
		local regen = t.getRegen(self, t)
		local max_regen = t.getMax(self, t)
		return ([[적들의 피를 흩뿌리며 기뻐합니다. 적에게 치명타를 가하면, 최대 생명력이 %d%%, 턴 당 생명력 재생이 %0.2f, 체력 재생이 %0.2f 증가됩니다.
		생명력과 체력 재생 증가는 5회까지 중첩되며, 최대치는 턴당 %0.2f과 %0.2f 입니다.]]):
		format(math.floor(self:getTalentLevel(t) * 2), regen, regen/5, max_regen, max_regen/5)
	end,
}

newTalent{
	name = "Mortal Terror",
	kr_display_name = "죽음의 공포",
	type = {"technique/bloodthirst", 2},
	require = techs_req_high2,
	points = 5,
	mode = "passive",
	do_terror = function(self, t, target, dam)
		if dam < target.max_life * (20 + (30 - self:getTalentLevelRaw(t) * 5)) / 100 then return end

		local weapon = target:getInven("MAINHAND")
		if type(weapon) == "boolean" then weapon = nil end
		if weapon then weapon = weapon[1] and weapon[1].combat end
		if not weapon or type(weapon) ~= "table" then weapon = nil end
		weapon = weapon or target.combat

		if target:canBe("stun") then
			target:setEffect(target.EFF_DAZED, 5, {apply_power=self:combatPhysicalpower()})
		else
			game.logSeen(target, "%s 죽음의 공포에 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
		end
	end,
	on_learn = function(self, t)
		self.combat_physcrit = self.combat_physcrit + 2.8
	end,
	on_unlearn = function(self, t)
		self.combat_physcrit = self.combat_physcrit - 2.8
	end,
	info = function(self, t)
		return ([[강렬한 타격으로 적을 극심한 공포에 떨게 만듭니다. 적의 최대 생명력을 %d%% 이상 감소시키는 타격을 가하면, 대상은 극심한 공포에 빠져 5턴 동안 혼절합니다.
		또한 당신의 치명타율이 %d%% 증가됩니다.
		혼절 확률은 힘 능력치의 영향을 받아 증가됩니다.]]):
		format(20 + (30 - self:getTalentLevelRaw(t) * 5), self:getTalentLevelRaw(t) * 2.8)
	end,
}

newTalent{
	name = "Bloodrage",
	kr_display_name = "피의 분노",
	type = {"technique/bloodthirst", 3},
	require = techs_req_high3,
	points = 5,
	mode = "passive",
	on_kill = function(self, t)
		self:setEffect(self.EFF_BLOODRAGE, math.floor(5 + self:getTalentLevel(t)), {max=math.floor(self:getTalentLevel(t) * 6), inc=2})
	end,
	info = function(self, t)
		return ([[적의 눈에 흙이 들어갈 때마다 당신에게 강력한 힘이 솟구쳐, %d턴 동안 최대 %d까지 힘이 2씩 증가합니다.]]):
		format(math.floor(5 + self:getTalentLevel(t)), math.floor(self:getTalentLevel(t) * 6))
	end,
}

newTalent{
	name = "Unstoppable",
	kr_display_name = "무쌍",
	type = {"technique/bloodthirst", 4},
	require = techs_req_high4,
	points = 5,
	cooldown = 45,
	stamina = 120,
	tactical = { DEFEND = 5, CLOSEIN = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_UNSTOPPABLE, 2 + self:getTalentLevelRaw(t), {hp_per_kill=math.floor(self:getTalentLevel(t) * 3.5)})
		return true
	end,
	info = function(self, t)
		return ([[%d턴 동안 전투 광란 상태가 됩니다. 효과가 지속되는 동안에는 물품을 사용할 수도 없고 치유를 받을 수도 없으며, 생명력이 1밑으로 떨어지지 않습니다.
		광란 상태가 끝나면, 그동안 살해한 적 하나당 전체 생명력의 %d%%를 회복하게 됩니다.]]):
		format(2 + self:getTalentLevelRaw(t), math.floor(self:getTalentLevel(t) * 3.5))
	end,
}
