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

-- EDGE TODO: Particles, Timed Effect Particles

newTalent{
	name = "Spin Fate",
	kr_name = "운명 잣기",
	type = {"chronomancy/fate-weaving", 1},
	require = chrono_req1,
	mode = "passive",
	points = 5,
	getSaveBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 8, 0.75)) end,
	getMaxSpin = function(self, t) return self:hasEffect(self.EFF_WEBS_OF_FATE) and 6 or 3 end,
	doSpin = function(self, t)
		self:setEffect(self.EFF_SPIN_FATE, 3, {save_bonus=t.getSaveBonus(self, t), spin=1, max_spin=t.getMaxSpin(self, t)})
		
		-- Fateweaver
		if self:knowTalent(self.T_FATEWEAVER) then
			self:callTalent(self.T_FATEWEAVER, "doFateweaver")
		end
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		if dam > 0 and src ~= self then
			if self.turn_procs and not self.turn_procs.spin_fate then
				t.doSpin(self, t)
				self.turn_procs.spin_fate = true
			end
		end

		return {dam=dam}
	end,
	info = function(self, t)
		local save = t.getSaveBonus(self, t)
		return ([[다른 이에게 피해를 받을 때 마다, 당신은 실타래 효과 하나를 얻습니다. 실타래는 3 턴간 유지되며 하나당 당신의 회피율과 내성을 %d 만큼 추가로 부여합니다. (최대 추가량은 %d)
		이 효과는 한 턴에 한 번씩만 일어나며, 실타래 효과는 3개까지만 쌓입니다.]]):
		format(save, save * 3)
	end,
}

newTalent{
	name = "Seal Fate",
	kr_name = "운명 날인",
	type = {"chronomancy/fate-weaving", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 12,
	tactical = { BUFF = 2, DISABLE = 2 },
	getDuration = function(self, t) return getExtensionModifier(self, t, 5) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 50, 10, 40) end, -- Limit < 50%end,
	getProcs = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_SEAL_FATE, t.getDuration(self, t), {procs=t.getProcs(self, t), chance=t.getChance(self, t)})
		return true
	end,
	info = function(self, t)
		local procs = t.getProcs(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[운명 날인을 %d 턴간 발동합니다. 운명 날인이 유지되는 동안 당신이 목표에게 피해를 입혔다면 당신은 실타래를 하나 얻은 후, %d%%의 확률로 목표의 해로운 효과 하나의 지속 시간을 1 턴 늘립니다. 
		만약 당신이 실타래 효과를 가지고 있다면 이 확률은 실타래 하나당 33%% 만큼 상승합니다. (실타래 3개를 가지고 있다면 최종 확률은 %d%% .)
		지속 시간 연장 효과는 1 턴당 %d 번 일어 날 수 있으며, 추가 실타래는 1 턴당 하나만 얻을 수 있습니다.]]):format(duration, chance, chance * 2, procs)
	end,
}

newTalent{
	name = "Fateweaver",
	kr_name = "운명의 방직자",
	type = {"chronomancy/fate-weaving", 3},
	require = chrono_req3,
	mode = "passive",
	points = 5,
	getPowerBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 8, 0.75)) end,
	getMaxSpin = function(self, t) return self:hasEffect(self.EFF_WEBS_OF_FATE) and 6 or 3 end,
	doFateweaver = function(self, t)
		local eff = self:hasEffect(self.EFF_SPIN_FATE)
		if not eff then return end
		self:setEffect(self.EFF_FATEWEAVER, 3, {power_bonus=t.getPowerBonus(self, t), spin=1, max_spin=t.getMaxSpin(self, t)})
	end,
	info = function(self, t)
		local power = t.getPowerBonus(self, t)
		return ([[당신은 이제 실타래 하나당 정확도, 물리력, 주문력, 정신력을 %d 만큼 얻습니다.]]):
		format(power)
	end,
}

newTalent{
	name = "Webs of Fate",
	kr_name = "운명의 거미줄",
	type = {"chronomancy/fate-weaving", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 48) end,
	cooldown = 12,
	tactical = { BUFF = 2, DEFEND = 2 },
	getPower = function(self, t) return self:combatTalentLimit(t, 50, 10, 30)/100 end, -- Limit < 50%
	getDuration = function(self, t) return getExtensionModifier(self, t, 5) end,
	no_energy = true,
	action = function(self, t)
	
		self:setEffect(self.EFF_WEBS_OF_FATE, t.getDuration(self, t), {power=t.getPower(self, t), talent=t})
		
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[다음 %d 턴 동안 당신은 당신이 받을 피해의 %d%% 만큼을 무작위의 적에게 옮깁니다.
		운명의 거미줄이 유지 되는 동안에는 당신은 한 턴에 하나씩 실타래 효과를 얻으며, 최대 실타래 보유수가 두배로 늘어납니다.]])
		:format(duration, power)
	end,
}
