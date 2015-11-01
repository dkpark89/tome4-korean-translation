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

-- EDGE TODO:Particles, Timed Effect Particles

newTalent{
	name = "Temporal Bolt",
	type = {"chronomancy/timetravel",1},
	require = chrono_req1,
	points = 5,
	cooldown = 3,
	fixed_cooldown = true,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {TEMPORAL = 2} },
	range = 10,
	reflectable = true,
	proj_speed = 3,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 150, getParadoxSpellpower(self, t)) end,
	getCooldown = function(self, t) return self:getTalentLevel(t) >= 5 and 2 or 1 end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local dam = self:spellCrit(t.getDamage(self, t))
		local cdr = t.getCooldown(self, t)
		
		-- Hit our initial target; quality of life hack
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			
			-- Refresh talent
			local tids = {}
			for tid, _ in pairs(self.talents_cd) do
				local tt = self:getTalentFromId(tid)
				if tt.type[1]:find("^chronomancy/") and not tt.fixed_cooldown then
					tids[#tids+1] = tt
				end
			end
			if #tids > 0 then
				local tid = rng.tableRemove(tids)
				self:alterTalentCoolingdown(tid, - cdr)
			end
			
			DamageType:get(DamageType.TEMPORAL).projector(self, x, y, DamageType.TEMPORAL, dam)
		end)
		
		-- Make our homing missile
		self:project(tg, x, y, function(x, y)
			local proj = require("mod.class.Projectile"):makeHoming(
				self,
				{particle="arrow", particle_args={tile="particles_images/temporal_bolt", proj_x=self.x, proj_y=self.y, src_x=x, src_y=y}, trail="trail_paradox"},
				{speed=3, name="Temporal Bolt", dam=dam, cdr=cdr, start_x=x, start_y=y},
				self, self:getTalentRange(t),
				function(self, src)
					local talent = src:getTalentFromId 'T_TEMPORAL_BOLT'
					local target = game.level.map(self.x, self.y, engine.Map.ACTOR)
					if target and not target.dead and src ~= target then
						local DT = require("engine.DamageType")
						local multi = (10 - self.homing.count)/20
						local dam = self.def.dam * (1 + multi)
						src:project({type="hit", selffire=false, talent=talent}, self.x, self.y, DT.TEMPORAL, dam)

						-- Refresh talent
						local tids = {}
						for tid, _ in pairs(src.talents_cd) do
							local tt = src:getTalentFromId(tid)
							if tt.type[1]:find("^chronomancy/") and not tt.fixed_cooldown then
								tids[#tids+1] = tt
							end
						end
						if #tids > 0 then
							local tid = rng.tableRemove(tids)
							src:alterTalentCoolingdown(tid, - self.def.cdr)
						end
					end
				end,
				function(self, src)
				end
			)
			game.zone:addEntity(game.level, proj, "projectile", x, y)
		end)
			
		game:playSoundNear({x=x, y=y}, "talents/spell_generic2")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Pull a bolt of temporal energy back through time.  The bolt will home in on your location, dealing %0.2f temporal damage to targets, and reducing the cooldown of one chronomancy talent on cooldown by one turn per enemy hit.
		The bolt gains 5%% damage each time it moves and the damage will scale with your Spellpower.
		At talent level five cooldowns are reduced by two.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Time Skip",
	type = {"chronomancy/timetravel",2},
	require = chrono_req2,
	points = 5,
	cooldown = 6,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	tactical = { ATTACK = {TEMPORAL = 1}, DISABLE = 1 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 250, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, 2 + math.ceil(self:combatTalentScale(t, 0.3, 2.3))) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		if target:attr("timetravel_immune") then
			game.logSeen(target, "%s is immune!", target.name:capitalize())
			return true
		end

		-- Project our damage
		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		
		-- If they're dead don't remove them from time
		if target.dead or target.player then return true end
		
		-- Check hit
		local power = getParadoxSpellpower(self, t)
		local hit = self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s resists!", target.name:capitalize()) return true end
		
		-- Apply spellshock and destabilization
		target:crossTierEffect(target.EFF_SPELLSHOCKED, getParadoxSpellpower(self, t))
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=getParadoxSpellpower(self, t, 0.3)})
		
		-- Placeholder for the actor
		local oe = game.level.map(x, y, Map.TERRAIN+1)
		if (oe and oe:attr("temporary")) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logPlayer(self, "Something has prevented the timetravel.") return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = "temporal", subtype = "instability",
			name = "temporal instability",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					-- remove ourselves
					if self.old_feat then game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN+1, self.old_feat)
					else game.level.map:remove(self.target.x, self.target.y, engine.Map.TERRAIN+1) end
					game.nicer_tiles:updateAround(game.level, self.target.x, self.target.y)
					game.level:removeEntity(self)
					game.level.map:removeParticleEmitter(self.particles)
					
					-- return the actor and reset their values
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					local old_check = self.target.check
					self.target.forceLevelup = function() end
					self.target.check = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
					self.target.check = old_check
				end
			end,
			summoner_gain_exp = true, summoner = self,
		}
		
		-- Remove the target
		game.logSeen(target, "%s has moved forward in time!", target.name:capitalize())
		game.level:removeEntity(target, true)
		
		-- add the time skip object to the map
		local particle = Particles.new("wormhole", 1, {image="shockbolt/terrain/temporal_instability_yellow", speed=1})
		particle.zdepth = 6
		e.particles = game.level.map:addParticleEmitter(particle, x, y)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+1, e)
		game.level.map:updateMap(x, y)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage.  If your target survives, it may be removed from time for %d turns.
		The damage will scale with your Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
}

newTalent{
	name = "Temporal Reprieve",
	type = {"chronomancy/timetravel", 3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 40) end,
	cooldown = 40,
	no_npc_use = true,
	fixed_cooldown = true,
	on_pre_use = function(self, t) return self:canBe("planechange") end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 2, 6))) end,
	action = function(self, t)
		if game.zone.is_temporal_reprieve then
			game.logPlayer(self, "This talent cannot be used from within the reprieve.")
			return
		end
		if game.zone.no_planechange then
			game.logPlayer(self, "This talent cannot be used here.")
			return
		end
		if not (self.player and self.game_ender) then return nil end

		if not self:canBe("planechange") or self.summon_time or self.summon then
			game.logPlayer(self, "The spell fizzles...")
			return
		end

		game:onTickEnd(function()
			if self:attr("dead") then return end
			local oldzone = game.zone
			local oldlevel = game.level

			-- Remove them before making the new elvel, this way party memebrs are not removed from the old
			if oldlevel:hasEntity(self) then oldlevel:removeEntity(self) end

			oldlevel.no_remove_entities = true
			local zone = mod.class.Zone.new("temporal-reprieve-talent")
			local level = zone:getLevel(game, 1, 0)
			oldlevel.no_remove_entities = nil

			level:addEntity(self)

			level.source_zone = oldzone
			level.source_level = oldlevel
			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(4, 4, 20, true, {[Map.ACTOR]=true})
			if x1 then
				self:move(x1, y1, true)
				game.level.map:particleEmitter(x1, y1, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
			end

			self.temporal_reprieve_on_die = self.on_die
			self.on_die = function(self, ...)
				self:removeEffect(self.EFF_TEMPORAL_REPRIEVE)
				local args = {...}
				game:onTickEnd(function()
					if self.temporal_reprieve_on_die then self:temporal_reprieve_on_die(unpack(args)) end
					self.on_die, self.temporal_reprieve_on_die = self.temporal_reprieve_on_die, nil
				end)
			end

			game.logPlayer(game.player, "#STEEL_BLUE#You time travel to a quiet place.")
			game.nicer_tiles:postProcessLevelTiles(game.level)

		end)

		self:setEffect(self.EFF_TEMPORAL_REPRIEVE, t.getDuration(self, t), {x=self.x, y=self.y})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Transport yourself to a safe place for %d turns.]]):
		format(duration)
	end,
}

newTalent{
	name = "Echoes From The Past",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 24) end,
	cooldown = 12,
	tactical = { ATTACKAREA = {TEMPORAL = 2} },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220, getParadoxSpellpower(self, t)) end,
	getPercent = function(self, t) return self:combatTalentLimit(t, 60, 20, 40)/100 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		
		local damage = self:spellCrit(t.getDamage(self, t))
		self:project(tg, self.x, self.y, function(px, py)
			DamageType:get(DamageType.TEMPORAL).projector(self, px, py, DamageType.TEMPORAL, damage)
			
			-- Echo
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local percent = t.getPercent(self, t)/target.rank
			local dam = (target.max_life - target.life) * percent
			DamageType:get(DamageType.TEMPORAL).projector(self, px, py, DamageType.TEMPORAL, dam)
		end)
		
		game.level.map:particleEmitter(self.x, self.y, 1, "shout", {size=4, distorion_factor=0.6, radius=self:getTalentRadius(t), life=30, nb_circles=8, rm=0.6, rM=0.6, gm=0.6, gM=0.6, bm=1, bM=1, am=0.6, aM=0.8})
		game:playSoundNear(self, "talents/warp")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[Creates a temporal echo in a radius of %d around you.  Affected target take %0.2f temporal damage, as well as up to %d%% of the difference between their current life and max life as additional temporal damage.
		The additional damage will be divided by the target's rank and the damage scales with your Spellpower.]]):
		format(radius, damDesc(self, DamageType.TEMPORAL, damage), percent)
	end,
}