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

newTalent{
	name = "Mind Storm",
	kr_display_name = "정신 폭풍",
	type = {"psionic/discharge", 1},
	points = 5, 
	require = psi_wil_high1,
	sustain_feedback = 0,
	mode = "sustained",
	cooldown = 12,
	tactical = { ATTACKAREA = {MIND = 2}},
	requires_target = true,
	proj_speed = 10,
	range = 7,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false, display={particle="discharge_bolt", trail="lighttrail"}}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	getTargetCount = function(self, t) return math.ceil(self:getTalentLevel(t)) end,
	getOverchargeRatio = function(self, t) return 20 - math.ceil(self:getTalentLevel(t)) end,
	doMindStorm = function(self, t, p)
		local tgts = {}
		local tgts_oc = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
				tgts_oc[#tgts_oc+1] = a
			end
		end end	
		
		local wrath = self:hasEffect(self.EFF_FOCUSED_WRATH)
		
		-- Randomly take targets
		local tg = self:getTalentTarget(t)
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 or self:getFeedback() < 5 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			-- Divert the Bolt?
			if wrath then
				self:projectile(tg, wrath.target.x, wrath.target.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t), nil, wrath.power))
			else
				self:projectile(tg, a.x, a.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t)))
			end
			self:incFeedback(-5)
		end
		
		-- Randomly take overcharge targets
		local tg = self:getTalentTarget(t)
		if p.overcharge >= 1 then
			for i = 1, math.min(p.overcharge, t.getTargetCount(self, t)) do
				if #tgts_oc <= 0 then break end
				local a, id = rng.table(tgts_oc)
				table.remove(tgts_oc, id)
				-- Divert the Bolt?
				if wrath then
					self:projectile(tg, wrath.target.x, wrath.target.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t), nil, wrath.power))
				else
					self:projectile(tg, a.x, a.y, DamageType.MIND, self:mindCrit(t.getDamage(self, t)))
				end
			end
		end
			
		p.overcharge = 0
		
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
		local ret = {
			overcharge = 0,
			particles = self:addParticles(Particles.new("ultrashield", 1, {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90, radius=0.2, density=15, life=28, instop=10}))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particles)
		return true
	end,
	info = function(self, t)
		local targets = t.getTargetCount(self, t)
		local damage = t.getDamage(self, t)
		local charge_ratio = t.getOverchargeRatio(self, t)
		return ([[잠재의식을 불러내, 매 턴마다 최대 %d 개의 정신력으로 이루어진 화살을 발사하여 %0.2f 정신 피해를 줍니다. (적 1 마리 당 화살 1 개) 화살 1 개 당 반발력이 1 소진됩니다.
		최대 반발력 이상의 반발력을 얻으면, 화살이 추가로 발사됩니다. (%d 반발력 당 화살 1 개, 최대 %d 개 까지)
		이 기술을 사용하는 동안, 염력 집중이 필요합니다. (이동하거나, 1 턴 이상 걸리는 기술을 사용하거나, 도구를 사용하면 집중이 깨집니다)
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(targets, damDesc(self, DamageType.MIND, damage), charge_ratio, targets)
	end,
}

newTalent{
	name = "Feedback Loop",
	kr_display_name = "힘의 순환",
	type = {"psionic/discharge", 2},
	points = 5, 
	require = psi_wil_high2,
	cooldown = 24,
	tactical = { FEEDBACK = 2 },
	no_break_channel = true,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * 1.5) end,
	on_pre_use = function(self, t, silent) if self:getFeedback() <= 0 then if not silent then game.logPlayer(self, "힘의 순환을 위해서는 약간이라도 반작용 수치가 필요합니다!") end return false end return true end,
	action = function(self, t)
		local wrath = self:hasEffect(self.EFF_FOCUSED_WRATH)
		self:setEffect(self.EFF_FEEDBACK_LOOP, self:mindCrit(t.getDuration(self, t), nil, wrath and wrath.power or 0), {})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[매 턴마다 감소하던 반작용이 %d 턴 동안 증가량으로 전환됩니다. 마법이 치명타로 적용되어, 지속시간이 더 길어질 수도 있습니다.
		이 기술은 염력 집중을 방해하지 않으며, 힘의 순환을 위해서는 반작용 수치를 조금이라도 가지고 있어야 합니다.
		최대 반작용 획득량은 정신력의 영향을 받아 증가합니다.]]):format(duration)
	end,
}

newTalent{
	name = "Backlash",
	kr_display_name = "반동",
	type = {"psionic/discharge", 3},
	points = 5, 
	require = psi_wil_high3,
	mode = "passive",
	range = 7,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 75) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	doBacklash = function(self, target, value, t)
		if self.turn_procs.psi_backlash and self.turn_procs.psi_backlash[target.uid] then return nil end
		self.turn_procs.psi_backlash = self.turn_procs.psi_backlash or {}
		self.turn_procs.psi_backlash[target.uid] = true
		self.no_backlash_loops = true
		if core.fov.distance(self.x, self.y,target.x, target.y) > self:getTalentRange(t) then return nil end
		local tg = self:getTalentTarget(t)
		local a = game.level.map(target.x, target.y, Map.ACTOR)
		if not a or self:reactionToward(a) >= 0 then return nil end
		local damage = math.min(value, t.getDamage(self, t))
		-- Divert the Backlash?
		local wrath = self:hasEffect(self.EFF_FOCUSED_WRATH)
		if damage > 0 then
			if wrath then
				self:project(tg, wrath.target.x, wrath.target.y, DamageType.MIND, self:mindCrit(damage, nil, wrath.power), nil, true) -- No Martyr loops
				game.level.map:particleEmitter(wrath.target.x, wrath.target.y, 1, "generic_discharge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
			else
				self:project(tg, a.x, a.y, DamageType.MIND, self:mindCrit(damage), nil, true) -- No Martyr loops
				game.level.map:particleEmitter(a.x, a.y, 1, "generic_discharge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
			end
		end
		self.no_backlash_loops = nil
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local damage = t.getDamage(self, t)
		return ([[피해를 받으면, 잠재의식이 발현하여 적에게 복수합니다. 공격자가 주변 %d 칸 반경에 있으면, 자동적으로 반작용 획득량이나 %0.2f 중 낮은 수치의 정신 피해를 줍니다.
		한 턴에 단 한 번의 복수만 가능합니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(range, damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Focused Wrath",   
	kr_display_name = "집중된 분노",   
	type = {"psionic/discharge", 4},
	points = 5, 
	require = psi_wil_high4,
	feedback = 25,
	cooldown = 12,
	tactical = { ATTACK = {MIND = 2}},
	range = 7,
	getCritBonus = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	direct_hit = true,
	requires_target = true,
	no_break_channel = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		_, x, y = self:canProject(tg, x, y)
		local target = x and game.level.map(x, y, engine.Map.ACTOR) or nil
		if not target or target == self then return nil end
		
		self:setEffect(self.EFF_FOCUSED_WRATH, t.getDuration(self, t), {target=target, power=t.getCritBonus(self, t)/100})

		game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local crit_bonus = t.getCritBonus(self, t)
		return ([[하나의 대상에게 정신을 집중하여, 모든 방출 계열 기술이 %d 턴 동안 그 대상만을 공격하게 만듭니다.
		이 효과가 적용되는 동안, 모든 방출 계열 기술의 치명타 위력이 %d%% 증가합니다.
		이 기술은 염력 집중을 방해하지 않으며, 피해 증가량은 정신력의 영향을 받아 증가합니다.]]):format(duration, damDesc(self, DamageType.MIND, crit_bonus))
	end,
}
