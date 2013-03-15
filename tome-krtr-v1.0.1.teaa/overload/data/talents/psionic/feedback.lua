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
	name = "Biofeedback",
	kr_name = "생체 반작용",
	type = {"psionic/feedback", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	getHealRatio = function(self, t) return 0.5 + self:combatTalentMindDamage(t, 0.1, 1)end,
	info = function(self, t)
		local heal = t.getHealRatio(self, t)
		return ([[받은 피해량의 %d%% 만큼 반작용 수치가 회복됩니다.
		회복량은 정신력의 영향을 받아 증가합니다.]]):format(heal*100)
	end,
}

newTalent{
	name = "Resonance Field",
	kr_name = "공진 장막",
	type = {"psionic/feedback", 2},
	points = 5,
	feedback = 25,
	require = psi_wil_req2,
	cooldown = 15,
	tactical = { DEFEND = 2},
	no_break_channel = true,
	getShieldPower = function(self, t) return self:combatTalentMindDamage(t, 30, 470) end,
	action = function(self, t)
		self:setEffect(self.EFF_RESONANCE_FIELD, 10, {power = self:mindCrit(t.getShieldPower(self, t))})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local shield_power = t.getShieldPower(self, t)
		return ([[공진 장막을 만들어, 받는 피해의 50%% 를 흡수합니다. (최대 %d 피해까지 흡수 가능)
		공진 장막은 반작용 획득을 감소시키지 않으며, 염력 집중 또한 방해하지 않습니다.
		최대 피해 흡수량은 정신력의 영향을 받아 증가하며, 공진 장막은 최대 10 턴 동안 유지할 수 있습니다.]]):format(shield_power)
	end,
}

newTalent{
	name = "Amplification",
	kr_name = "증폭",
	type = {"psionic/feedback", 3},
	points = 5,
	require = psi_wil_req3,
	mode = "passive",
	getFeedbackGain = function(self, t) return 0.5 + self:combatTalentMindDamage(t, 0.1, 0.5) end,
	getMaxFeedback = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	on_learn = function(self, t)
		self:incMaxFeedback(10)
	end,
	on_unlearn = function(self, t)
		self:incMaxFeedback(-10)
	end,
	info = function(self, t)
		local max_feedback = t.getMaxFeedback(self, t)
		local gain = t.getFeedbackGain(self, t)
		return ([[최대 반작용 수치를 %d 증가시키고, 반작용 획득 기본 비율이 %d%% 가 됩니다.
		반작용 획득 비율은 정신력의 영향을 받아 증가합니다.]]):format(max_feedback, gain * 100)
	end,
}

newTalent{
	name = "Conversion",
	kr_name = "변환",
	type = {"psionic/feedback", 4},
	points = 5,
	feedback = 25,
	require = psi_wil_req4,
	cooldown = 24,
	no_break_channel = true,
	is_heal = true,
	tactical = { MANA = 2, VIM = 2, EQUILIBRIUM = 2, STAMINA = 2, POSITIVE = 2, NEGATIVE = 2, PSI = 2, HATE = 2 },
	getConversion = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getData = function(self, t)
		local base = t.getConversion(self, t)
		return {
			heal = base * 10,
			stamina = base,
			mana = base * 1.8,
			equilibrium = -base * 1.5,
			vim = base,
			positive = base / 2,
			negative = base / 2,
			psi = base * 0.7,
			hate = base / 4,
		}
	end,
	action = function(self, t)
		local data = t.getData(self, t)
		for name, v in pairs(data) do
			local inc = "inc"..name:capitalize()
			if name == "heal" then
				self:attr("allow_on_heal", 1)
				self:heal(self:mindCrit(v), self)
				self:attr("allow_on_heal", -1)
			elseif
				self[inc] then self[inc](self, v) 
			end
		end
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local data = t.getData(self, t)
		return ([[반작용을 사용하여 다른 원천력을 회복합니다. 생명력이 %d / 체력이 %d / 마나가 %d / 평정이 %d / 원기가 %d / 양기와 음기가 %d / 염력이 %d / 증오가 %d 회복됩니다.
		이 기술은 염력 집중을 방해하지 않습니다.
		회복량은 정신력의 영향을 받아 증가합니다.]]):format(data.heal, data.stamina, data.mana, -data.equilibrium, data.vim, data.positive, data.psi, data.hate)
	end,
}
