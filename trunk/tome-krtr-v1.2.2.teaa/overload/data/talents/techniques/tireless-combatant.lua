-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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



newTalent {
	short_name = "SKIRMISHER_BREATHING_ROOM",
	name = "Breathing Room",
	kr_name = "휴게실",
	type = {"technique/tireless-combatant", 1},
	require = techs_wil_req1,
	mode = "passive",
	points = 5,
	getRestoreRate = function(self, t)
		return t.applyMult(self, t, self:combatTalentScale(t, 1.5, 6, 0.75))
	end,
	applyMult = function(self, t, gain)
		if self:knowTalent(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR) then
			local t2 = self:getTalentFromId(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR)
			return gain * t2.getMult(self, t2)
		else
			return gain
		end
	end,
	callbackOnAct = function(self, t)

		-- Remove the existing regen rate
		if self.temp_skirmisherBreathingStamina then
			self:removeTemporaryValue("stamina_regen", self.temp_skirmisherBreathingStamina)
		end
		if self.temp_skirmisherBreathingLife then
			self:removeTemporaryValue("life_regen", self.temp_skirmisherBreathingLife)
		end
		self.temp_skirmisherBreathingStamina = nil
		self.temp_skirmisherBreathingLife = nil

		-- Calculate surrounding enemies
		local nb_foes = 0
		local add_if_visible_enemy = function(x, y)
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if target and self:reactionToward(target) < 0 and self:canSee(target) then
				nb_foes = nb_foes + 1
			end
		end
		local adjacent_tg = {type = "ball", range = 0, radius = 1, selffire = false}
		self:project(adjacent_tg, self.x, self.y, add_if_visible_enemy)

		-- Add new regens if needed
		if nb_foes == 0 then
			self.temp_skirmisherBreathingStamina = self:addTemporaryValue("stamina_regen", t.getRestoreRate(self, t))
			if self:getTalentLevelRaw(t) >= 3 then
				self.temp_skirmisherBreathingLife = self:addTemporaryValue("life_regen", t.getRestoreRate(self, t))
			end
		end

	end,
	info = function(self, t)
		local stamina = t.getRestoreRate(self, t)
		return ([[인접한 곳에 적이 없을 경우, 체력 재생량이 %0.1f 만큼 늘어납니다.
		이 기술에 직업기술 점수를 3 점 이상 투자할 경우, 체력 재생량 증가분만큼 생명력 재생량도 증가하게 됩니다.]])
			:format(stamina)
	end,
}

newTalent {
	short_name = "SKIRMISHER_PACE_YOURSELF",
	name = "Pace Yourself",
	kr_name = "완급 조절",
	type = {"technique/tireless-combatant", 2},
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_stamina = 0,
	no_energy = true,
	require = techs_wil_req2,
	tactical = { STAMINA = 2 },
	random_ego = "utility",
	activate = function(self, t)
		-- Superloads Combat:combatFatigue.
		local eff = {}
		self:talentTemporaryValue(eff, "global_speed_add", -t.getSlow(self, t))
		self:talentTemporaryValue(eff, "fatigue", -t.getReduction(self, t))
		return eff
	end,
	deactivate = function(self, t, p) return true end,
	getSlow = function(self, t)
		return  self:combatTalentLimit(t, 0, 0.15, .05)
	end,
	getReduction = function(self, t)
		return self:combatTalentScale(t, 10, 30)
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t) * 100
		local reduction = t.getReduction(self, t)
		return ([[움직임을 통제하여 힘을 비축합니다. 이 기술이 활성화 중인 동안 전체 속도가 %0.1f%% 감소하게 되지만, 대신 피로도가 %d%% 감소하게 됩니다. (최소 0%% 까지 감소)]])
		:format(slow, reduction)
	end,
}

newTalent {
	short_name = "SKIRMISHER_DAUNTLESS_CHALLENGER",
	name = "Dauntless Challenger",
	kr_name = "불굴의 도전가",
	type = {"technique/tireless-combatant", 3},
	require = techs_wil_req3,
	mode = "passive",
	points = 5,
	getStaminaRate = function(self, t)
		return t.applyMult(self, t, self:combatTalentScale(t, 0.3, 1.5, 0.75))
	end,
	getLifeRate = function(self, t)
		return t.applyMult(self, t, self:combatTalentScale(t, 1, 5, 0.75))
	end,
	applyMult = function(self, t, gain)
		if self:knowTalent(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR) then
			local t2 = self:getTalentFromId(self.T_SKIRMISHER_THE_ETERNAL_WARRIOR)
			return gain * t2.getMult(self, t2)
		else
			return gain
		end
	end,
	callbackOnAct = function(self, t)
		-- Remove the existing regen rate
		if self.temp_skirmisherDauntlessStamina then
			self:removeTemporaryValue("stamina_regen", self.temp_skirmisherDauntlessStamina)
		end
		if self.temp_skirmisherDauntlessLife then
			self:removeTemporaryValue("life_regen", self.temp_skirmisherDauntlessLife)
		end
		self.temp_skirmisherDauntlessStamina = nil
		self.temp_skirmisherDauntlessLife = nil

		-- Calculate visible enemies
		local nb_foes = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and self:canSee(act) then nb_foes = nb_foes + 1 end
		end

		-- Add new regens if needed
		if nb_foes >= 1 then
			if nb_foes > 4 then nb_foes = 4 end
			self.temp_skirmisherDauntlessStamina = self:addTemporaryValue("stamina_regen", t.getStaminaRate(self, t) * nb_foes)
			if self:getTalentLevelRaw(t) >= 3 then
				self.temp_skirmisherDauntlessLife = self:addTemporaryValue("life_regen", t.getLifeRate(self, t) * nb_foes)
			end
		end

	end,
	info = function(self, t)
		local stamina = t.getStaminaRate(self, t)
		local health = t.getLifeRate(self, t)
		return ([[좌절감이 사나이를 키우는 법입니다. 시야의 적 하나마다 체력 회복량이 %0.1f 상승하게 됩니다.
		이 기술에 직업기술 점수를 3 점 이상 투자할 경우, 시야의 적 하나마다 생명력 회복량도 %0.1f 상승하게 됩니다. 이 효과는 최대 4 명의 적이 있을 때까지 적용됩니다.]])
			:format(stamina, health)
	end,
}

newTalent {
	short_name = "SKIRMISHER_THE_ETERNAL_WARRIOR",
	name = "The Eternal Warrior",
	kr_name = "불멸의 전사",
	type = {"technique/tireless-combatant", 4},
	require = techs_wil_req4,
	mode = "passive",
	points = 5,
	getResist = function(self, t)
		return self:combatTalentScale(t, 0.7, 2.5)
	end,
	getResistCap = function(self, t)
		return self:combatTalentLimit(t, 30, 0.7, 2.5)/t.getMax(self, t) -- Limit < 30%
	end,
	getDuration = function(self, t)
		return 3
	end,
	getMax = function(self, t)
		return 5
	end,
	getMult = function(self, t, fake)
		if self:getTalentLevelRaw(t) >= 5 or fake then
			return 1.2
		else
			return 1
		end
	end,
	-- call from incStamina whenever stamina is incremented or decremented
	onIncStamina = function(self, t, delta)
		if delta < 0 and not self.temp_skirmisherSpentThisTurn then
			self:setEffect(self.EFF_SKIRMISHER_ETERNAL_WARRIOR, t.getDuration(self, t), {
				res = t.getResist(self, t),
				cap = t.getResistCap(self, t),
				max = t.getMax(self, t),
			})
			self.temp_skirmisherSpentThisTurn = true
		end
	end,
	callbackOnAct = function(self, t)
		self.temp_skirmisherSpentThisTurn = false
	end,
	info = function(self, t)
		local max = t.getMax(self, t)
		local duration = t.getDuration(self, t)
		local resist = t.getResist(self, t)
		local cap = t.getResistCap(self, t)
		local mult = (t.getMult(self, t, true) - 1) * 100
		return ([[체력을 소모한 매 턴마다, %d 턴 동안 %0.1f%% 전체 저항력과 %0.1f%% 전체 저항력 한계수치가 상승합니다. 이 효과는 최대 %d 번 까지 중첩되며, 새로 적용될 때마다 지속 시간이 초기화됩니다.
		또한 이 기술에 직업기술 점수를 5 점 이상 투자할 경우, 휴게실 기술과 불굴의 도전자 기술의 효율이 %d%% 증가합니다.]])
			:format(duration, resist, cap, max, mult)
	end,
}
