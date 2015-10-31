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
	name = "Swallow",
	type = {"wild-gift/sand-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 4,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 10, 7)) end,
	range = 1,
	no_message = true,
	tactical = { ATTACK = { weapon = 1 }, EQUILIBRIUM = 0.5},
	requires_target = true,
	no_npc_use = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	maxSwallow = function(self, t, target) return -- Limit < 50%
		self:combatLimit(self:getTalentLevel(t)*(self.size_category or 3)/(target.size_category or 3), 50, 13, 1, 25, 5)
	end,
	getPassiveCrit = function(self, t) return self:combatTalentScale(t, 2, 10, 0.5) end,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physcrit", t.getPassiveCrit(self, t))
		self:talentTemporaryValue(p, "combat_mindcrit", t.getPassiveCrit(self, t))
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		self:logCombat(target, "#Source# tries to swallow #Target#!")
		local hit = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 1.6, 2.5), true)
		if not hit then return true end

		if (target.life * 100 / target.max_life > t.maxSwallow(self, t, target)) and not target.dead then
			return true
		end

		if (target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) or target.dead) and (target:canBe("instakill") or target.life * 100 / target.max_life <= 5) then
			if not target.dead then target:die(self) end
			world:gainAchievement("EAT_BOSSES", self, target)
			self:incEquilibrium(-target.level - 5)
			self:attr("allow_on_heal", 1)
			self:heal(target.level * 2 + 5, target)
			if core.shader.active(4) then
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
			end
			self:attr("allow_on_heal", -1)
		else
			game.logSeen(target, "%s resists!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[Attack the target for %d%% Nature weapon damage.
		If the attack brings your target below %d%% life or kills it, you can try to swallow it, killing it automatically and regaining life and equilibrium depending on its level.
		The chance to swallow depends on your talent level and the relative size of the target.
		Levels in Swallow additionally raises your Physical and Mental critical rate by %d%%, passively.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.6, 2.5), t.maxSwallow(self, t, self), t.getPassiveCrit(self, t))
	end,
}

newTalent{
	name = "Quake",
	type = {"wild-gift/sand-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source@ shakes the ground!",
	equilibrium = 4,
	cooldown = 20,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	range = 1,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	no_npc_use = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.3, 2.1) end,
	action = function(self, t)
		local tg = {type="ball", range=0, selffire=false, radius=self:getTalentRadius(t), talent=t, no_restrict=true}
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, DamageType.PHYSKNOCKBACK, self:combatTalentWeaponDamage(t, 1.3, 2.1), true)
			end
		end)
		self:doQuake(tg, self.x, self.y)
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[You slam the ground, shaking the area around you in a radius of %d.
		Creatures caught by the quake will be damaged for %d%% weapon damage, and knocked back up to 3 tiles away.
		The terrain will also be moved around within the radius, and the user will be shifted to a random square within the radius.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):format(radius, dam * 100)
	end,
}

newTalent{
	name = "Burrow",
	type = {"wild-gift/sand-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 15,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
	range = 10,
	no_energy = function(self, t) if self:getTalentLevel(t) >= 5 then return true else return false end end,
	tactical = { CLOSEIN = 0.5, ESCAPE = 0.5 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7, 0.5, 0, 2)) end,
	getPenetration = function(self, t) return 10 + self:combatTalentMindDamage(t, 15, 30) end,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	action = function(self, t)
		self:setEffect(self.EFF_BURROW, t.getDuration(self, t), {power=t.getPenetration(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[Allows you to burrow into earthen walls for %d turns.
		Your powerful digging abilities also allow you to exploit and smash through enemy defensive weaknesses; You ignore %d of target armor and %d%% of enemy physical damage resistance while this is in effect.
		At Talent Level 5, this talent can be used instantly, and the cooldown will reduce with levels.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):format(t.getDuration(self, t), t.getPenetration(self, t), t.getPenetration(self, t) / 2)
	end,
}

newTalent{
	name = "Sand Breath",
	type = {"wild-gift/sand-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes sand!",
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = { blind = 2 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "str", 30, 480)
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 4)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SAND, {dur=t.getDuration(self, t), dam=self:mindCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="sandwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You breathe sand in a frontal cone of radius %d. Any target caught in the area will take %0.2f physical damage, and will be blinded for %d turns.
		The damage will increase with your Strength, and the critical chance is based on your Mental crit rate.
		Each point in sand drake talents also increases your physical resistance by 0.5%%.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}
