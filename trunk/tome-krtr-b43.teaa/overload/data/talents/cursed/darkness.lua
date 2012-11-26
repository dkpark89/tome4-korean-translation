-- ToME - Tales of Middle-Earth
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

local Object = require "engine.Object"
local Map = require "engine.Map"

local function createDarkTendrils(summoner, x, y, target, damage, duration, pinDuration)
	if not summoner:getTalentFromId(summoner.T_CREEPING_DARKNESS) then return end

	local e = Object.new{
		name = "dark tendril",
		block_sight=false,
		canAct = false,
		x = x, y = y,
		target = target,
		damage = damage,
		duration = duration,
		pinDuration = pinDuration,
		summoner = summoner,
		summoner_gain_exp = true,
		act = function(self)
			local Map = require "engine.Map"

			self:useEnergy()

			local done = false
			local hitTarget = false

			local tCreepingDarkness = self.summoner:getTalentFromId(self.summoner.T_CREEPING_DARKNESS)

			if self.finalizing then
				if self.duration <= 0 or self.target.dead or self.x ~= self.target.x or self.y ~= self.target.y then
					game.logSeen(self, "The dark tendrils dissipate.")
					done = true
				end
			elseif self.duration <= 0 or self.target.dead or core.fov.distance(self.x, self.y, self.target.x, self.target.y) > self.duration * 2 then
				game.logSeen(self, "The dark tendrils dissipate.")
				done = true
			elseif self.x == self.target.x and self.y == self.target.y then
				hitTarget = true
			else
				-- find new location
				local bestX, bestY
				local bestDistance = 9999
				local start = rng.range(0, 8)
				for i = start, start + 8 do
					local nextX = self.x + (i % 3) - 1
					local nextY = self.y + math.floor((i % 9) / 3) - 1
					if not (nextX == self.x and nextY == self.y) and tCreepingDarkness.canCreep(nextX, nextY, true) then
						local distance = core.fov.distance(nextX, nextY, self.target.x, self.target.y)
						if distance < bestDistance then
							bestDistance, bestX, bestY = distance, nextX, nextY
						end
					end
				end

				-- move to new location
				if bestX and bestY then
					self.x, self.y = bestX, bestY
					if not game.level.map:checkAllEntities(self.x, self.y, "creepingDark") and rng.percent(50) then
						tCreepingDarkness.createDark(self.summoner, self.x, self.y, self.damage, 3, 2, 33, 0)
					end

					if self.x == self.target.x and self.y == self.target.y then
						hitTarget = true
					end
				else
					-- no where to go
					game.logSeen(self, "The dark tendrils dissipate.")
					done = true
				end
			end

			if hitTarget and self.target:canBe("pin") then
				-- attack the target
				game.logSeen(self, "The dark tendrils lash at %s.", self.target.name)

				-- pin target
				self.target:setEffect(self.target.EFF_PINNED, self.pinDuration, {})

				-- explode
				local dark = game.level.map:checkAllEntities(self.x, self.y, "creepingDark")
				if dark then
					dark.duration = math.max(dark.duration, self.pinDuration + 1)
					for i = 1, 4 do
						if rng.percent(50) then tCreepingDarkness.doCreep(tCreepingDarkness, dark, false) end
					end
				end

				-- put in a final countdown for displaying
				self.finalizing = true
				duration = self.pinDuration
			end

			self.duration = self.duration - 1

			if done then
				-- remove dark tendrils
				game.level.map:removeParticleEmitter(self.particles)
				game.level.map:remove(self.x, self.y, Map.TERRAIN+4)
				game.level:removeEntity(self)
			elseif self.particles.x ~= self.x or self.particles.y ~= self.y then
				-- move dark tendrils
				game.level.map:removeParticleEmitter(self.particles)
				self.particles.x = self.x
				self.particles.y = self.y
				game.level.map:addParticleEmitter(self.particles)
			end
		end,
	}
	game.level:addEntity(e)
	game.level.map(x, y, Map.TERRAIN+4, e)

	-- add particles
	e.particles = Particles.new("dark_tendrils", 1, { })
	e.particles.x = e.x
	e.particles.y = e.y
	game.level.map:addParticleEmitter(e.particles)
end

local function getDamageIncrease(self)
	local total = 0
		
	local t = self:getTalentFromId(self.T_CREEPING_DARKNESS)
	if t then total = total + self:getTalentLevelRaw(t) end
	t = self:getTalentFromId(self.T_DARK_VISION)
	if t then total = total + self:getTalentLevelRaw(t) end
	t = self:getTalentFromId(self.T_DARK_TORRENT)
	if t then total = total + self:getTalentLevelRaw(t) end
	t = self:getTalentFromId(self.T_DARK_TENDRILS)
	if t then total = total + self:getTalentLevelRaw(t) end
	
	return total * 2
end

newTalent{
	name = "Creeping Darkness",
	type = {"cursed/darkness", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 20,
	hate = 8,
	range = 5,
	radius = 3,
	tactical = { ATTACK = { DARKNESS = 1 }, DISABLE = 2 },
	requires_target = true,

	-- implementation of creeping darkness..used in various locations, but stored here
	canCreep = function(x, y, ignoreCreepingDark)
		-- not on map
		if not game.level.map:isBound(x, y) then return false end
		 -- already dark
		 if not ignoreCreepingDark then
			if game.level.map:checkAllEntities(x, y, "creepingDark") then return false end
		end
		 -- allow objects and terrain to block, but not actors
		if game.level.map:checkAllEntities(x, y, "block_move") and not game.level.map(x, y, Map.ACTOR) then return false end

		return true
	end,
	doCreep = function(tCreepingDarkness, self, useCreep)
		local start = rng.range(0, 8)
		for i = start, start + 8 do
			local x = self.x + (i % 3) - 1
			local y = self.y + math.floor((i % 9) / 3) - 1
			if not (x == self.x and y == self.y) and tCreepingDarkness.canCreep(x, y) then
				-- add new dark
				local newCreep
				if useCreep then
					 -- transfer some of our creep to the new dark
					newCreep = math.ceil(self.creep / 2)
					self.creep = self.creep - newCreep
				else
					-- just clone our creep
					newCreep = self.creep
				end
				tCreepingDarkness.createDark(self.summoner, x, y, self.damage, self.originalDuration, newCreep, self.creepChance, 0)
				return true
			end

			-- nowhere to creep
			return false
		end
	end,
	createDark = function(summoner, x, y, damage, duration, creep, creepChance, initialCreep)
		local e = Object.new{
			name = "creeping dark",
			block_sight=true,
			canAct = false,
			canCreep = true,
			x = x, y = y,
			damage = damage,
			originalDuration = duration,
			duration = duration,
			creep = creep,
			creepChance = creepChance,
			summoner = summoner,
			summoner_gain_exp = true,
			damageIncrease = getDamageIncrease(summoner),
			act = function(self)
				local Map = require "engine.Map"

				self:useEnergy()

				-- apply damage to anything inside the darkness
				local actor = game.level.map(self.x, self.y, Map.ACTOR)
				if actor and actor ~= self.summoner and (not actor.summoner or actor.summoner ~= self.summoner) then
					self.projecting = true -- simplest way to indicate that this damage should not be amplified by the in creeping dark bonus
					self.summoner:project(actor, actor.x, actor.y, engine.DamageType.DARKNESS, self.damage)
					self.projecting = false
				end

				if self.duration <= 0 then
					-- remove
					if self.particles then game.level.map:removeParticleEmitter(self.particles) end
					game.level.map:remove(self.x, self.y, Map.TERRAIN+3)
					game.level:removeEntity(self)
					self.creepingDark = nil
					--game.level.map:redisplay()
				else
					self.duration = self.duration - 1

					local tCreepingDarkness = self.summoner:getTalentFromId(self.summoner.T_CREEPING_DARKNESS)

					if self.canCreep and self.creep > 0 and rng.percent(self.creepChance) then
						if not tCreepingDarkness.doCreep(tCreepingDarkness, self, true) then
							-- doCreep failed..pass creep on to a neighbor and stop creeping
							self.canCreep = false
							local start = rng.range(0, 8)
							for i = start, start + 8 do
								local x = self.x + (i % 3) - 1
								local y = self.y + math.floor((i % 9) / 3) - 1
								if not (x == self.x and y == self.y) and tCreepingDarkness.canCreep(x, y) then
									local dark = game.level.map:checkAllEntities(x, y, "creepingDark")
									if dark and dark.canCreep then
										-- transfer creep
										dark.creep = dark.creep + self.creep
										self.creep = 0
										return
									end
								end
							end
						end
					end
				end
			end,
		}
		e.creepingDark = e -- used for checkAllEntities to return the dark Object itself
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+3, e)

		-- add particles
		e.particles = Particles.new("creeping_dark", 1, { })
		e.particles.x = x
		e.particles.y = y
		game.level.map:addParticleEmitter(e.particles)

		-- do some initial creeping
		if initialCreep > 0 then
			local tCreepingDarkness = self.summoner:getTalentFromId(summoner.T_CREEPING_DARKNESS)
			while initialCreep > 0 do
				if not tCreepingDarkness.doCreep(tCreepingDarkness, e, false) then
					e.canCreep = false
					e.initialCreep = 0
					break
				end
				initialCreep = initialCreep - 1
			end
		end
	end,

	getDarkCount = function(self, t)
		return 1 + math.floor(self:getTalentLevel(t))
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 60)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local damage = self:mindCrit(t.getDamage(self, t))
		local darkCount = t.getDarkCount(self, t)

		local tg = {type="ball", nolock=true, pass_terrain=false, nowarning=true, friendly_fire=true, default_target=self, range=range, radius=radius, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)

		-- get locations in line of movement from center
		local locations = {}
		local grids = core.fov.circle_grids(x, y, radius, true)
		for darkX, yy in pairs(grids) do for darkY, _ in pairs(grids[darkX]) do
			local l = line.new(x, y, darkX, darkY)
			local lx, ly = l()
			while lx and ly do
				if game.level.map:checkAllEntities(lx, ly, "block_move") then break end

				lx, ly = l()
			end
			if not lx and not ly then lx, ly = darkX, darkY end

			if lx == darkX and ly == darkY and t.canCreep(darkX, darkY) then
				locations[#locations+1] = {darkX, darkY}
			end
		end end

		darkCount = math.min(darkCount, #locations)
		if darkCount == 0 then return false end

		for i = 1, darkCount do
			local location, id = rng.table(locations)
			table.remove(locations, id)
			t.createDark(self, location[1], location[2], damage, rng.range(5, 8), 4, 40, 0)
		end

		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local darkCount = t.getDarkCount(self, t)
		local damageIncrease = getDamageIncrease(self)
		return ([[Creeping dark slowly spreads from %d spots in a radius of %d around the targeted location. The dark deals %d damage and blocks the sight of any who do not possess Dark Vision or some other magical means of seeing.
		The damage will increase with your Mindpower. You do +%d%% damage to anything that has entered your creeping dark.]]):format(darkCount, radius, damage, damageIncrease)
	end,
}

newTalent{
	name = "Dark Vision",
	type = {"cursed/darkness", 2},
	require = cursed_wil_req2,
	points = 5,
	mode = "passive",
	random_ego = "attack",
	range = function(self, t)
		return 1 + self:getTalentLevelRaw(t)
	end,
	getMovementSpeedChange = function(self, t)
		return self:getTalentLevel(t) * 0.5
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local movementSpeedChange = t.getMovementSpeedChange(self, t)
		local damageIncrease = getDamageIncrease(self)
		return ([[Your eyes penetrate the darkness to find anyone that may be hiding there. This allows you to see through creeping darkness out to a radius of %d. You can also find your way through the darkness with greater speed (+%d%% movement into creeping darkness).
		You do +%d%% damage to anything that has entered your creeping dark.]]):format(range, movementSpeedChange * 100, damageIncrease)
	end,
}

newTalent{
	name = "Dark Torrent",
	type = {"cursed/darkness", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	hate = 8,
	cooldown = 6,
	tactical = { ATTACK = { DARKNESS = 2 }, DISABLE = { blind = 1 } },
	range = 5,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 280)
	end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		local damage = self:mindCrit(t.getDamage(self, t))

		local grids = self:project(tg, x, y,
			function(x, y, target, self)
				-- your will ignores friendly targets (except for knockback hits)
				local target = game.level.map(x, y, Map.ACTOR)
				if target then
					self:project(target, target.x, target.y, DamageType.DARKNESS, damage)
					if rng.percent(25) then
						if not target.dead and target:canBe("blind") then
							target:setEffect(target.EFF_BLINDED, 3, {apply_power=self:combatMindpower(), min_dur=1})
							target:setTarget(nil)
							--game.logSeen(target, "%s stumbles in the darkness!", target.name:capitalize())
						end
					end
				end
				if rng.percent(25) and self:knowTalent(self.T_CREEPING_DARKNESS) then
					local tCreepingDarkness = self:getTalentFromId(self.T_CREEPING_DARKNESS)
					local damage = tCreepingDarkness.getDamage(self, tCreepingDarkness)
					tCreepingDarkness.createDark(self, x, y, damage, 3, 2, 33, 0)
				end
			end,
			nil, nil)

		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "dark_torrent", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damageIncrease = getDamageIncrease(self)
		return ([[Sends a torrent of searing darkness through your foes doing %d damage. There is a 25%% chance the rushing darkness will blind them for 3 turns and cause them to forget their target.
		The damage will increase with your Mindpower. You do +%d%% damage to anything that has entered your creeping dark.]]):format(damDesc(self, DamageType.DARKNESS, damage), damageIncrease)
	end,
}

newTalent{
	name = "Dark Tendrils",
	type = {"cursed/darkness", 4},
	require = cursed_wil_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	hate = 10,
	range = 6,
	tactical = { ATTACK = { DARKNESS = 2 }, DISABLE = { pin = 2 } },
	direct_hit = true,
	requires_target = true,
	getPinDuration = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t) / 2)
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 80)
	end,
	action = function(self, t)
		if self.dark_tendrils then return false end

		local range = self:getTalentRange(t)
		local tg = {type="hit", range=range, talent=t}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end

		local pinDuration = t.getPinDuration(self, t)
		local damage = self:mindCrit(t.getDamage(self, t))

		createDarkTendrils(self, self.x, self.y, target, damage, 12, pinDuration)

		return true
	end,
	info = function(self, t)
		local pinDuration = t.getPinDuration(self, t)
		local damage = t.getDamage(self, t)
		local damageIncrease = getDamageIncrease(self)
		return ([[Send tendrils of creeping dark out to attack your target and pin them in the darkness for %d turns. Creeping dark will trail behind the tendrils as they move. The darkness does %d damage per turn.
		The damage will increase with your Mindpower. You do +%d%% damage to anything that has entered your creeping dark.]]):format(pinDuration, damage, damageIncrease)
	end,
}

