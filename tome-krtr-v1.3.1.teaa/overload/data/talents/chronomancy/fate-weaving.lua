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
		return ([[Each time you would take damage from someone else you gain one Spin, increasing your defense and saves by %d for three turns.
		This effect may occur once per turn and stacks up to three Spin (for a maximum bonus of %d).]]):
		format(save, save * 3)
	end,
}

newTalent{
	name = "Seal Fate",
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
		return ([[Activate to Seal Fate for %d turns.  When you damage a target while Seal Fate is active you gain Spin and have a %d%% chance to increase the duration of one detrimental status effect on it by one turn.
		If you have Spin Fate active the chance will be increased by 33%% per Spin (for %d%% at three Spin.)
		The duration increase can occur up to %d times per turn and the bonus Spin once per turn.]]):format(duration, chance, chance * 2, procs)
	end,
}

newTalent{
	name = "Fateweaver",
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
		return ([[You now gain %d combat accuracy, physical power, spellpower, and mindpower per Spin.]]):
		format(power)
	end,
}

newTalent{
	name = "Webs of Fate",
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
		return ([[For the next %d turns you displace %d%% of any damage you receive onto a random enemy.
		While Webs of Fate is active you may gain one additional Spin per turn and your maximum Spin is doubled.]])
		:format(duration, power)
	end,
}
