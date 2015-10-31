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
	name = "Repulsion Blast",
	type = {"chronomancy/gravity",1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 4,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, ESCAPE = 2 },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	requires_target = true,
	direct_hit = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 210, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- Project our base damage		
		local dam = self:spellCrit(t.getDamage(self, t))
		local bonus_dam = dam/4
		self:project(tg, x, y, DamageType.GRAVITY, dam)
		
		-- Do our knockback
		local tgts = {}
		local grids = self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and not target:isTalentActive(target.T_GRAVITY_LOCUS) then
				-- If we've already moved this target don't move it again
				for _, v in pairs(tgts) do
					if v == target then
						return
					end
				end
				
				-- Apply anti-gravity?
				if self:isTalentActive(self.T_GRAVITY_LOCUS) then
					local chance = self:callTalent(self.T_GRAVITY_LOCUS, "getAnti")
					if rng.percent(chance) then
						target:setEffect(target.EFF_ANTI_GRAVITY, 2, {})
					end
				end
				
				local hit = target:checkHit(getParadoxSpellpower(self, t), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback")
					
				if hit then
					local slam = false
					local dist = self:getTalentRadius(t) + 1 - core.fov.distance(self.x, self.y, px, py)
					target:knockback(self.x, self.y, dist, false, function(g, x, y)
						-- Deal our bonus damage
						if game.level.map:checkAllEntities(x, y, "block_move", target) then
							slam = true
							self:project({type="hit"}, target.x, target.y, DamageType.GRAVITY, bonus_dam)
							self:project({type="hit"}, x, y, DamageType.GRAVITY, bonus_dam)
							game.logSeen(target, "%s slams into something solid!", target.name:capitalize())
						end
					end)
					
					tgts[#tgts+1] = target
					if not slam then game.logSeen(target, "%s is knocked back!", target.name:capitalize()) end
					target:crossTierEffect(target.EFF_OFFBALANCE, getParadoxSpellpower(self, t))
				else
					game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
				end
				
			end
		end)
		
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "gravity_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y, allow=core.shader.allow("distort")})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Sends out a blast wave of gravity in a radius %d cone, dealing %0.2f base physical (gravity) damage and knocking back targets caught in the area.
		Targets knocked into walls or other targets take 25%% additional damage and deal 25%% damage to targets they're knocked into.
		Closer targets will be knocked back further and the damage will scale with your Spellpower.]]):
		format(radius, damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Gravity Spike",
	type = {"chronomancy/gravity", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	cooldown = 6,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = 2 },
	range = 6,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 230, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		
		local tgts = {}
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and not target:isTalentActive(target.T_GRAVITY_LOCUS) then
				-- If we've already moved this target don't move it again
				for _, v in pairs(tgts) do
					if v == target then
						return
					end
				end

				-- Do our Knockback
				local can = function(target)
					if target:checkHit(getParadoxSpellpower(self, t), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback") then -- Deprecated Checkhit call
						return true
					else
						game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
					end
				end
				if can(target) then
					target:pull(x, y, tg.radius, can)
					tgts[#tgts+1] = target
					game.logSeen(target, "%s is drawn in by the singularity!", target.name:capitalize())
					target:crossTierEffect(target.EFF_OFFBALANCE, getParadoxSpellpower(self, t))
				end
			end
		end)
		
		-- 25% bonus damage per target beyond the first
		local dam = self:spellCrit(t.getDamage(self, t))
		if #tgts > 0 then
			dam = dam + math.min(dam/2, dam*(#tgts-1)/8)
		end
		
		-- Project our damage last based on number of targets hit
		self:project(tg, x, y, function(px, py)
			local dist_factor = 1 + (core.fov.distance(x, y, px, py)/5)
			local damage = dam/dist_factor
			DamageType:get(DamageType.GRAVITY).projector(self, px, py, DamageType.GRAVITY, damage)
		end)
		
		game.level.map:particleEmitter(x, y, tg.radius, "gravity_spike", {radius=tg.radius, allow=core.shader.allow("distort")})

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Creates a gravity spike in a radius of %d that moves all targets towards the spell's center and inflicts %0.2f physical (gravity) damage.
		Each target moved beyond the first increases the damage by %0.2f (up to a maximum of %0.2f bonus damage).
		Targets take reduced damage the further they are from the epicenter (20%% less per tile).
		The damage dealt will scale with your Spellpower.]])
		:format(radius, damDesc(self, DamageType.PHYSICAL, damage), damDesc(self, DamageType.PHYSICAL, damage/8), damDesc(self, DamageType.PHYSICAL, damage/2))
	end,
}

newTalent{
	name = "Gravity Locus",
	type = {"chronomancy/gravity",3},
	require = chrono_req3,
	mode = "sustained",
	sustain_paradox = 24,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	getSlow = function(self, t) return self:combatTalentLimit(t, 80, 10, 50) end,
	getAnti = function(self, t) return self:combatTalentLimit(t, 100, 10, 75) end,
	getConversion= function(self, t) return self:combatTalentLimit(t, 80, 10, 40) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local particle = Particles.new("ultrashield", 1, {rm=204, rM=220, gm=102, gM=120, bm=0, bM=0, am=35, aM=90, radius=0.5, density=10, life=28, instop=100})
		return {
			converttype = self:addTemporaryValue("all_damage_convert", DamageType.PHYSICAL),
			convertamount = self:addTemporaryValue("all_damage_convert_percent", t.getConversion(self, t)),
			proj = self:addTemporaryValue("slow_projectiles", t.getSlow(self, t)),
			particle = self:addParticles(particle)
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("all_damage_convert", p.converttype)
		self:removeTemporaryValue("all_damage_convert_percent", p.convertamount)
		self:removeTemporaryValue("slow_projectiles", p.proj)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local conv = t.getConversion(self, t)
		local proj = t.getSlow(self, t)
		local anti = t.getAnti(self, t)
		return ([[Create a gravity field around you that converts %d%% all damage you deal into physical damage, slows incoming projectiles by %d%%, and protects you from all gravity damage and effects.
		Additionally, damage dealt by Repulsion Blast has a %d%% chance to reduce the target's knockback resistance by half for two turns.]]):format(conv, proj, anti)
	end,
}

newTalent{
	name = "Gravity Well",
	type = {"chronomancy/gravity", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 12,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = 2 },
	range = 6,
	radius = function(self, t) return 4 end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire=self:spellFriendlyFire()}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60, getParadoxSpellpower(self, t)) end,
	getSlow = function(self, t) return self:combatTalentLimit(t, 50, 10, 30)/100 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 4, 8))) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		-- Add a lasting map effect
		local dam = self:spellCrit(t.getDamage(self, t))
		game.level.map:addEffect(self,
			x, y, t.getDuration(self,t),
			DamageType.GRAVITY, {dam=dam, dur=1, slow=t.getSlow(self, t), apply=getParadoxSpellpower(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="gravity_well"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		local slow = t.getSlow(self, t)
		return ([[Increases local gravity in a radius of %d for %d turns, dealing %0.2f physical (gravity) damage as well as decreasing the global speed of all affected targets by %d%%.
		The damage done will scale with your Spellpower.]]):format(radius, duration, damDesc(self, DamageType.PHYSICAL, damage), slow*100)
	end,
}
