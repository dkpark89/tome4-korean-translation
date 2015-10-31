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
	name = "Warp Blade",
	type = {"chronomancy/blade-threading", 1},
	require = chrono_req1,
	points = 5,
	cooldown = 6,
	paradox = function (self, t) return getParadoxCost(self, t, 8) end,
	tactical = { ATTACK = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	speed = "weapon",
	range = 1,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.9) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 3, 7))) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "dual") then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local swap = doWardenWeaponSwap(self, t, "blade")

		local tg = self:getTalentTarget(t)
		local _, x, y = self:canProject(tg, self:getTarget(tg))
		local target = game.level.map(x, y, game.level.map.ACTOR)
		if not target then
			if swap then doWardenWeaponSwap(self, t, "bow") end
			return nil
		end

		-- Hit?
		local hitted = self:attackTarget(target, DamageType.WARP, t.getDamage(self, t), true)

		-- Project our warp
		if hitted then
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=64, rM=64, gm=134, gM=134, bm=170, bM=170, am=35, aM=90})
			DamageType:get(DamageType.RANDOM_WARP).projector(self, target.x, target.y, DamageType.RANDOM_WARP, {dur=t.getDuration(self, t), apply_power=getParadoxSpellpower(self, t)})
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[Attack with your melee weapons for %d%% weapon damage as physical and temporal (warp) damage. If either attack hits you may stun, blind, pin, or confuse the target for %d turns.
		
		Blade Threading talents will freely swap to your dual-weapons when activated if you have them in your secondary slots.  Additionally you may use the Attack talent in a similar manner.]])
		:format(damage, duration)
	end
}

newTalent{
	name = "Blink Blade",
	type = {"chronomancy/blade-threading", 2},
	require = chrono_req2,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 12) end,
	tactical = { ATTACKAREA = {weapon = 2}, ATTACK = {weapon = 2},  },
	requires_target = true,
	is_teleport = true,
	speed = "weapon",
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9, 0.5, 0, 1)) end,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "dual") then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local swap = doWardenWeaponSwap(self, t, "blade")

		local tg = self:getTalentTarget(t)
		local _, x, y = self:canProject(tg, self:getTarget(tg))
		local target = game.level.map(x, y, game.level.map.ACTOR)
		if not target then
			if swap then doWardenWeaponSwap(self, t, "bow") end
			return nil
		end
		
		-- Our teleport hit
		local function teleport_hit(self, t, target, x, y)
			local teleported = self:teleportRandom(x, y, 0)
			if teleported then
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
				if core.fov.distance(self.x, self.y, x, y) <= 1 then
					local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
				end
			end
			return teleported
		end
		
		local first_teleport = teleport_hit(self, t, target, x, y)
		if not first_teleport then game.logSeen(self, "The spell fizzles!") return true end
		
		local teleports = 1
		local attempts = 10
		
		-- Check for Warden's focus
		local wf = checkWardenFocus(self)
		if wf and not wf.dead then
			while teleports > 0 and attempts > 0 do
				local tx, ty = util.findFreeGrid(wf.x, wf.y, 1, true, {[Map.ACTOR]=true})
				if tx and ty and not wf.dead then
					if teleport_hit(self, t, wf, tx, ty) then
						teleports = teleports - 1
					else
						attempts = attempts - 1
					end
				else
					break
				end
			end				
		end
		
		-- Be sure we still have teleports left
		if teleports > 0 and attempts > 0 then
			-- Get available targets
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local target_type = Map.ACTOR
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					tgts[#tgts+1] = a
				end
			end end

			-- Randomly take targets
			while teleports > 0 and #tgts > 0 and attempts > 0 do
				local a, id = rng.table(tgts)
				local tx2, ty2 = util.findFreeGrid(a.x, a.y, 1, true, {[Map.ACTOR]=true})
				if tx2 and ty2 and not a.dead then
					if teleport_hit(self, t, a, tx2, ty2) then
						teleports = teleports - 1
					else
						attempts = attempts - 1
					end
				else
					-- find a different target?
					attempts = attempts - 1
				end
			end
		
		end

		game:playSoundNear(self, "talents/teleport")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[Teleport to the target and attack with your melee weapons for %d%% damage.  Then teleport next to a second random enemy, attacking for %d%% damage.
		Blink Blade can hit the same target multiple times.]])
		:format(damage, damage)
	end
}

newTalent{
	name = "Blade Shear",
	type = {"chronomancy/blade-threading", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 12,
	paradox = function (self, t) return getParadoxCost(self, t, 18) end,
	tactical = { ATTACK = {weapon = 2}, ATTACKAREA = { TEMPORAL = 2 }},
	requires_target = true,
	speed = "weapon",
	range = 1,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	is_melee = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getShear = function(self, t) return self:combatTalentSpellDamage(t, 20, 200, getParadoxSpellpower(self, t)) end,
	target = function(self, t)
		return {type="cone", range=0, radius=self:getTalentRadius(t), talent=t, selffire=false }
	end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "dual") then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local swap = doWardenWeaponSwap(self, t, "blade")
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
	
		if not x or not y then
			if swap then doWardenWeaponSwap(self, t, "bow") end
			return nil
		end
	
		-- Change our radius for the melee attacks
		local old_radius = tg.radius
		tg.radius = 1
		
		-- Project our melee hits
		local total_hits = 0
		local target_found = false
		self:project(tg, x, y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				target_found = true
				local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
				if hit then
					total_hits = total_hits + 1
				end
			end
		end)
		
		-- Assume the player canceled
		if not target_found then 
			if swap then doWardenWeaponSwap(self, t, "bow") end
			return nil
		end

		if total_hits > 0 then
			-- Project our shear
			local multi = (total_hits - 1)/4
			local damage = self:spellCrit(t.getShear(self, t)) * (1 + multi)
			tg.radius = self:getTalentRadius(t)
		
			self:project(tg, x, y, function(px, py, tg, self)
				DamageType:get(DamageType.TEMPORAL).projector(self, px, py, DamageType.TEMPORAL, damage)
				local target = game.level.map(px, py, Map.ACTOR)
				-- Try to insta-kill...  but not our puppies
				if target and self:reactionToward(target) < 0 then
					if target:checkHit(getParadoxSpellpower(self, t), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") and target.life > 0 and target.life < target.max_life * 0.2 then
						-- KILL IT !
						game.logSeen(target, "%s has been cut from the timeline!", target.name:capitalize())
						target:die(self)
					elseif target.life > 0 and target.life < target.max_life * 0.2 then
						game.logSeen(target, "%s resists the temporal shear!", target.name:capitalize())
					end
				end
			end)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "temporal_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/tidalwave")
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local shear = t.getShear(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Attack up to three adjacent targets for %d%% weapon damage.  If any attack hits you'll create a temporal shear dealing %0.2f temporal damage in a radius %d cone.
		Each target you hit with your weapons beyond the first increases the damage of the shear by 25%%.  Targets reduced below 20%% of maximum life by the shear may be instantly slain.
		The cone damage improves with your Spellpower.]])
		:format(damage, damDesc(self, DamageType.TEMPORAL, shear), radius)
	end
}

newTalent{
	name = "Blade Ward",
	type = {"chronomancy/blade-threading", 4},
	require = chrono_req4,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:combatTalentLimit(t, 40, 10, 30) end, -- Limit < 40%
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[While dual-wielding you have a %d%% chance of parrying melee attacks made against you.]])
		:format(chance)
	end
}

--[=[newTalent{
	name = "Braided Blade",
	type = {"chronomancy/blade-threading", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 18) end,
	tactical = { ATTACKAREA = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	speed = "weapon",
	range = function(self, t) return 3 + math.floor(self:combatTalentLimit(t, 7, 0, 3)) end,
	is_melee = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t, selffire=false }
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.3) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 3, 7))) end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 25, 40, getParadoxSpellpower(self, t)) end,
	on_pre_use = function(self, t, silent) if not doWardenPreUse(self, "dual") then if not silent then game.logPlayer(self, "You require two weapons to use this talent.") end return false end return true end,
	action = function(self, t)
		local swap = doWardenWeaponSwap(self, t, "blade")
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
	
		if not x or not y then
			if swap then doWardenWeaponSwap(self, t, "bow") end
			return nil
		end
		
		local braid_targets = {}
		
		self:project(tg, x, y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				local hit = self:attackTarget(target, DamageType.TEMPORAL, t.getDamage(self, t), true)
				if hit then
					if not target.dead and self:reactionToward(target) < 0 then
						braid_targets[#braid_targets+1] = target
					end
				end
			end
		end)

		-- if we hit more than one, braid them
		if #braid_targets > 1 then
			for i = 1, #braid_targets do
				local target = braid_targets[i]
				target:setEffect(target.EFF_BRAIDED, t.getDuration(self, t), {power=t.getPower(self, t), src=self, targets=braid_targets})
			end
		end
		
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporalbeam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/heal")
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[Attack all targets in a beam with your melee weapons for %d%% temporal weapon damage.
		If two or more targets are hit by the beam you'll braid their lifelines for %d turns.
		Braided targets take %d%% of all damage dealt to other braided targets.
		The damage transferred by the braid effect and beam damage scales with your Spellpower.]])
		:format(damage, duration, power)
	end
}]=]
