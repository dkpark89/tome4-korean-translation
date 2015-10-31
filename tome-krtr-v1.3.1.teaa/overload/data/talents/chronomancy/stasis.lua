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
	name = "Spacetime Stability",
	type = {"chronomancy/stasis", 1},
	require = chrono_req1,
	mode = "passive",
	points = 5,
	getTuning = function(self, t) return 1 + self:combatTalentLimit(t, 6, 0, 3) end,
	callbackOnActBase = function(self, t)
		if not self:hasEffect(self.EFF_SPACETIME_TUNING) then
			tuneParadox(self, t, t.getTuning(self, t))
		end
	end,
	info = function(self, t)
		local tune = t.getTuning(self, t)
		return ([[You automatically adjust your Paradox %0.2f points towards your preferred Paradox each turn.
		While using Spacetime Tuning twice this value will instead be added to the amount you would normally tune.]]):
		format(tune)
	end,
}

newTalent{
	name = "Time Shield", short_name = "CHRONO_TIME_SHIELD",
	type = {"chronomancy/stasis",2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 48) end,
	cooldown = 18,
	tactical = { DEFEND = 2 },
	no_energy = true,
	getMaxAbsorb = function(self, t) return 50 + self:combatTalentSpellDamage(t, 50, 450, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15)) end,
	getTimeReduction = function(self, t) return 25 + util.bound(15 + math.floor(self:getTalentLevel(t) * 2), 15, 35) end,
	action = function(self, t)
		self:setEffect(self.EFF_TIME_SHIELD, t.getDuration(self, t), {power=t.getMaxAbsorb(self, t), dot_dur=5, time_reducer=t.getTimeReduction(self, t)})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxabsorb = t.getMaxAbsorb(self, t)
		local duration = t.getDuration(self, t)
		local time_reduc = t.getTimeReduction(self,t)
		return ([[This intricate spell instantly erects a time shield around the caster, preventing any incoming damage and sending it forward in time.
		Once either the maximum damage (%d) is absorbed, or the time runs out (%d turns), the stored damage will return as a temporal restoration field over time (5 turns).
		Each turn the restoration field is active, you get healed for 10%% of the absorbed damage.
		While under the effect of Time Shield, all newly applied magical, physical and mental effects will have their durations reduced by %d%%.
		The shield's max absorption will increase with your Spellpower.]]):
		format(maxabsorb, duration, time_reduc)
	end,
}

newTalent{
	name = "Stop",
	type = {"chronomancy/stasis",3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 8,
	tactical = { ATTACKAREA = { TEMPORAL = 1 }, DISABLE = { stun = 3 } },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 2.7)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
	end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.ceil(self:combatTalentScale(t, 2.3, 4.3))) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		
		local dam = self:spellCrit(t.getDamage(self, t))
		local dur = t.getDuration(self, t)
		
		local grids = self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				self:project({type="hit"}, px, py, DamageType.TEMPORAL, dam)
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, dur, {apply_power=getParadoxSpellpower(self, t)})
				end
			end
		end)
		
		game.level.map:particleEmitter(x, y, tg.radius, "generic_sploom", {rm=230, rM=255, gm=230, gM=255, bm=30, bM=51, am=35, aM=90, radius=tg.radius, basenb=120})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage, and attempts to stun all targets in a radius %d ball for %d turns.
		The damage will scale with your Spellpower.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), radius, duration)
	end,
}

newTalent{
	name = "Static History",
	type = {"chronomancy/stasis",4},
	require = chrono_req4,
	points = 5,
	cooldown = 24,
	tactical = { PARADOX = 2 },
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(1 + self:combatTalentScale(t, 1, 7))) end,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_STATIC_HISTORY, t.getDuration(self, t), {})
		
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[For the next %d turns you may not create minor anomalies.  You do not regain Paradox or lose the spell you're casting if a random anomaly would normally occur.
		This spell has no effect on major anomalies.]]):
		format(duration)
	end,
}