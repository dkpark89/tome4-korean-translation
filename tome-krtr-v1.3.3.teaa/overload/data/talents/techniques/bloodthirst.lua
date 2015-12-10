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

newTalent{
	name = "Mortal Terror",
	kr_name = "극심한 공포",
	type = {"technique/bloodthirst", 1},
	require = techs_req_high1,
	points = 5,
	mode = "passive",
	threshold = function(self,t) return self:combatTalentLimit(t, 10, 45, 25) end, -- Limit >10%
	getCrit = function(self, t) return self:combatTalentScale(t, 2.8, 14) end,
	do_terror = function(self, t, target, dam)
		if dam < target.max_life * t.threshold(self, t) / 100 then return end

		local weapon = target:getInven("MAINHAND")
		if type(weapon) == "boolean" then weapon = nil end
		if weapon then weapon = weapon[1] and weapon[1].combat end
		if not weapon or type(weapon) ~= "table" then weapon = nil end
		weapon = weapon or target.combat

		if target:canBe("stun") then
			target:setEffect(target.EFF_DAZED, 5, {apply_power=self:combatPhysicalpower()})
		else
			game.logSeen(target, "%s가 죽음의 공포에 저항했습니다!", target.name:capitalize())
		end
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physcrit", t.getCrit(self, t))
	end,
	info = function(self, t)
		return ([[강력한 공격으로 적에게 죽음에 대한 공포를 심어줍니다. 
		한 번의 근접공격으로 대상이 지닌 최대 생명력의 %d%% 가 넘는 피해를 입히면, 대상은 죽음의 공포에 빠져 5 턴 동안 혼절합니다.
		치명타율이 %d%% 증가하는 효과도 있으며, 혼절 확률은 물리력의 영향을 받아 증가합니다.]]):
		format(t.threshold(self, t), self:getTalentLevelRaw(t) * 2.8)
	end,
}

newTalent{
	name = "Bloodbath",
	kr_name = "피바다",
	type = {"technique/bloodthirst", 2},
	require = techs_req_high2,
	points = 5,
	mode = "passive",
	getHealth = function(self,t) return self:combatTalentLimit(t, 50, 2, 10)  end,  -- Limit max health increase to <+50%
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getRegen = function (self, t) return self:combatTalentScale(t, 1.7, 5) end,
	getMax = function(self, t) return 5*self:combatTalentScale(t, 1.7, 5) end,
	-- called by _M:attackTargetWith in mod.class.interface.Combat.lua
	do_bloodbath = function(self, t)
		self:setEffect(self.EFF_BLOODBATH, t.getDuration(self, t), {regen=t.getRegen(self, t), max=t.getMax(self, t), hp=t.getHealth(self,t)})
	end,
	info = function(self, t)
		local regen = t.getRegen(self, t)
		local max_regen = t.getMax(self, t)
		local max_health = t.getHealth(self,t)
		return ([[적들이 흘리는 피를 보고 희열을 느낍니다. 적에게 치명타를 가하면 %d 턴 동안 최대 생명력이 %d%% 상승하며, 턴 당 생명력 재생이 %0.2f / 턴 당 체력 재생이 %0.2f 증가합니다.
		생명력과 체력 재생 증가 효과는 5 회까지 중첩 가능합니다. 즉, 턴 당 생명력 재생은 최대 %0.2f / 턴 당 체력 재생은 최대 %0.2f 까지 가능합니다.]]):
		format(t.getDuration(self, t),t.getHealth(self, t), regen, regen/5, max_regen/5, max_regen)
	end,
}

newTalent{
	name = "Bloody Butcher",
	kr_name = "핏빛 도살자",
	type = {"technique/bloodthirst", 3},
	require = techs_req_high3,
	points = 5,
	mode = "passive",
	getDam = function(self, t) return self:combatScale(self:getStr(5, true) * self:getTalentLevel(t), 5, 0, 40, 35) end,
	getResist = function(self,t) return self:combatTalentScale(t, 10, 40) end,
	info = function(self, t)
		return ([[적에게 상처내는 것을 즐기게 되어, 물리력이 %d 상승합니다.
		또한 적이 출혈 상태에 빠질 경우, 적의 물리 저항력 역시 %d%% 감소하게 됩니다. (단, 저항력은 0%% 아래로 내려가지 않습니다)
		물리력 상승량은 힘 능력치의 영향을 받아 증가합니다.]]):
		format(t.getDam(self, t), t.getResist(self, t))
	end,
}

newTalent{
	name = "Unstoppable",
	kr_name = "무쌍",
	type = {"technique/bloodthirst", 4},
	require = techs_req_high4,
	points = 5,
	cooldown = 45,
	stamina = 120,
	fixed_cooldown = true,
	tactical = { DEFEND = 5, CLOSEIN = 2 },
	getHealPercent = function(self,t) return self:combatTalentLimit(t, 50, 3.5, 17.5) end, -- Limit <50%
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 3, 7, true)) end, -- Limit < 25
	action = function(self, t)
		self:setEffect(self.EFF_UNSTOPPABLE, t.getDuration(self, t), {hp_per_kill=t.getHealPercent(self,t)})
		return true
	end,
	info = function(self, t)
		return ([[%d 턴 동안 전투 광란 상태가 됩니다. 효과가 지속되는 동안에는 물품을 사용할 수 없고 치유 효과도 적용되지 않지만, 생명력이 1 밑으로 떨어지지 않습니다.
		전투 광란 상태가 끝나면, 전투 광란 상태에서 살해한 적 하나당 전체 생명력의 %d%% 에 해당하는 생명력을 회복합니다.
		무쌍 기술이 활성화 중인 동안, '광전사의 분노' 기술의 치명타 증가량은 적용되지 않습니다. 죽음에 대한 공포와 그로 인한 분노가 사라져버리기 때문입니다.]]):
		format(t.getDuration(self, t), t.getHealPercent(self,t))
	end,
}
