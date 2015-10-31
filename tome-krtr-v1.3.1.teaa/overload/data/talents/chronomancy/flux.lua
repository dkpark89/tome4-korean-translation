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
	name = "Induce Anomaly",
	type = {"chronomancy/flux", 1},
	require = chrono_req1,
	points = 5,
	cooldown = 12,
	tactical = { PARADOX = 2 },
	getReduction = function(self, t) return self:combatTalentSpellDamage(t, 20, 80, getParadoxSpellpower(self, t)) end,
	anomaly_type = "no-major",
	no_energy = true,
	action = function(self, t)

		self:paradoxDoAnomaly(100, t.getReduction(self, t), {anomaly_type=t.anomaly_type, ignore_energy=true, allow_target=self:knowTalent(self.T_TWIST_FATE)})
	
		return true
	end,
	info = function(self, t)
		local reduction = t.getReduction(self, t)
		return ([[Create an anomaly, reducing your Paradox by %d.  This spell will never produce a major anomaly.
		Induced Anomalies may not be held by Twist Fate, nor do they cause held anomalies to trigger.  However upon learning Twist Fate you may target Induced Anomalies.
		The Paradox reduction will increase with your Spellpower.]]):format(reduction)
	end,
}

newTalent{
	name = "Reality Smearing",
	type = {"chronomancy/flux", 2},
	require = chrono_req2,
	mode = "sustained", 
	sustain_paradox = 0,
	points = 5,
	cooldown = 10,
	tactical = { DEFEND = 2 },
	getPercent = function(self, t) return (100 - self:combatTalentLimit(t, 80, 10, 60))/100 end, -- Limit < 20%
	getDuration = function(self, t) return getExtensionModifier(self, t, 3) end,
	damage_feedback = function(self, t, p, src)
		if p.particle and p.particle._shader and p.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			p.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			p.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	iconOverlay = function(self, t, p)
		local val = p.rest_count or 0
		if val <= 0 then return "" end
		local fnt = "buff_font"
		return tostring(math.ceil(val)), fnt
	end,
	callbackOnHit = function(self, t, cb, src)
		local absorb = cb.value * 0.3
		local paradox = absorb * t.getPercent(self, t)
		
		self:setEffect(self.EFF_REALITY_SMEARING, t.getDuration(self, t), {paradox=paradox/t.getDuration(self, t)})
		game:delayedLogMessage(self, nil,  "reality smearing", "#LIGHT_BLUE##Source# converts damage to paradox!")
		game:delayedLogDamage(src, self, 0, ("#LIGHT_BLUE#(%d converted)#LAST#"):format(absorb), false)
		cb.value = cb.value - absorb
		
		return cb.value
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")

		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local ratio = t.getPercent(self, t)
		local duration = t.getDuration(self, t)
		return ([[While active 30%% of all damage you take is converted into %0.2f Paradox damage.
		The Paradox damage is taken over three turns.]]):
		format(ratio, duration)
	end,
}

newTalent{
	name = "Attenuate",
	type = {"chronomancy/flux", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 4,
	tactical = { ATTACKAREA = { TEMPORAL = 2 } },
	range = 10,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 290, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, 4) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), nowarning=true, talent=t}
	end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		
		local damage = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if target:isTalentActive(target.T_REALITY_SMEARING) then
				target:setEffect(target.EFF_ATTENUATE_BEN, t.getDuration(self, t), {power=(damage/4)*0.4, src=self})
			else
				target:setEffect(target.EFF_ATTENUATE_DET, t.getDuration(self, t), {power=damage/4, src=self, apply_power=getParadoxSpellpower(self, t)})
			end
		end)

		game.level.map:particleEmitter(x, y, tg.radius, "generic_sploom", {rm=100, rM=100, gm=200, gM=220, bm=200, bM=220, am=35, aM=90, radius=tg.radius, basenb=60})
		game:playSoundNear(self, "talents/tidalwave")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Deals %0.2f temporal damage over %d turns to all targets in a radius of %d.  Targets with Reality Smearing active will instead recover %d life over four turns.
		If a target is reduced below 20%% life while Attenuate is active it may be instantly slain.
		The damage will scale with your Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration, radius, damage *0.4)
	end,
}

newTalent{
	name = "Twist Fate",
	type = {"chronomancy/flux", 4},
	require = chrono_req4,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 20, 8)) end, -- Limit >4
	tactical = { ATTACKAREA = 2 },
	on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_TWIST_FATE) then if not silent then game.logPlayer(self, "You must have a twisted anomaly to cast this spell.") end return false end return true end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 1, 6))) end,
	doTwistFate = function(self, t, twist)
		local eff = self:hasEffect(self.EFF_TWIST_FATE)
		
		if twist then
			eff.twisted = twist
			local anom = self:getTalentFromId(eff.talent)
			
			-- Call the anomoly action function directly
			anom.action(self, anom)
			self:incParadox(-eff.paradox)
		end
		
		self:removeEffect(self.EFF_TWIST_FATE)
	end,
	setEffect = function(self, t, talent, paradox)
		game.logPlayer(self, "#STEEL_BLUE#You take control of %s.", self:getTalentFromId(talent).name or nil)
		self:setEffect(self.EFF_TWIST_FATE, t.getDuration(self, t), {talent=talent, paradox=paradox})
		
	end,
	action = function(self, t)
		t.doTwistFate(self, t, true)
		game:playSoundNear(self, "talents/echo")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local talent
		local t_name = "None"
		local t_info = ""
		local eff = self:hasEffect(self.EFF_TWIST_FATE)
		if eff then
			talent = self:getTalentFromId(eff.talent)
			t_name = talent.name
			t_info = talent.info(self, talent)
		end
		return ([[If Twist Fate is not on cooldown minor anomalies will be held for %d turns, allowing your spell to cast as normal.  While held you may cast Twist Fate in order to trigger the anomaly and may choose the target area.
		If a second anomaly occurs while a prior one is held or the timed effect expires the first anomaly will trigger immediately, interrupting your current turn or action.
		Paradox reductions from held anomalies occur when triggered.
				
		Current Anomaly: %s
		
		%s]]):
		format(duration, t_name, t_info)
	end,
}