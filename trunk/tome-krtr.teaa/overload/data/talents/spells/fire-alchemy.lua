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
local Object = require "engine.Object"

newTalent{
	name = "Heat",
	type = {"spell/fire-alchemy", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 5,
	random_ego = "attack",
	refectable = true,
	proj_speed = 20,
	range = 10,
	direct_hit = true,
	tactical = { ATTACK = { FIRE = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 620) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dur=8, initial=0, dam=t.getDamage(self, t)}, {type="flame"})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Turn part of your target into fire, burning the rest for %0.2f fire damage over 8 turns.
		The damage will increase with your Spellpower.]]):format(damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Smoke Bomb",
	type = {"spell/fire-alchemy", 2},
	require = spells_req2,
	points = 5,
	mana = 80,
	cooldown = 34,
	range = 6,
	direct_hit = true,
	tactical = { DISABLE = 2 },
	requires_target = true,
	getDuration = function(self, t) return 2 + self:combatSpellpower(0.03) * self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local e = Object.new{
				block_sight=true,
				temporary = t.getDuration(self, t),
				x = px, y = py,
				canAct = false,
				act = function(self)
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map:remove(self.x, self.y, engine.Map.TERRAIN+2)
						game.level:removeEntity(self)
						game.level.map:redisplay()
					end
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN+2, e)
		end, nil, {type="dark"})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Throw a smoke bomb, blocking line of sight. The smoke dissipates after %d turns.
		Duration will increase with your Spellpower.]]):
		format(duration)
	end,
}

newTalent{
	name = "Fire Storm",
	type = {"spell/fire-alchemy",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 70,
	cooldown = 30,
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false}
	end,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	getDuration = function(self, t) return 5 + self:combatSpellpower(0.05) + self:getTalentLevel(t) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 90) end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.FIRE_FRIENDS, t.getDamage(self, t),
			3,
			5, nil,
			{type="firestorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[A furious fire storm rages around the caster doing %0.2f fire damage in a radius of 3 each turn for %d turns.
		You closely control the firestorm, preventing it from harming your party members.
		The damage and duration will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.FIRE, damage), duration)
	end,
}


newTalent{
	name = "Body of Fire",
	type = {"spell/fire-alchemy",4},
	require = spells_req4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 250,
	points = 5,
	proj_speed = 2.4,
	range = 8,
	tactical = { ATTACKAREA = { FIRE = 3 } },
	getFireDamageOnHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getResistance = function(self, t) return self:combatTalentSpellDamage(t, 5, 45) end,
	getFireDamageInSight = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	getManaDrain = function(self, t) return -0.4 * self:getTalentLevelRaw(t) end,
	do_fire = function(self, t)
		if self:getMana() <= 0 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire"}}
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:projectile(tg, a.x, a.y, DamageType.FIRE, self:spellCrit(t.getFireDamageInSight(self, t)), {type="flame"})
			game:playSoundNear(self, "talents/fire")
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fireflash")
		game.logSeen(self, "#FF8000#%s turns into pure flame!", self.name:capitalize())
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.FIRE]=t.getFireDamageOnHit(self, t)}),
			res = self:addTemporaryValue("resists", {[DamageType.FIRE] = t.getResistance(self, t)}),
			drain = self:addTemporaryValue("mana_regen", t.getManaDrain(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#FF8000#The raging fire around %s calms down and disappears.", self.name)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("resists", p.res)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		local onhitdam = t.getFireDamageOnHit(self, t)
		local insightdam = t.getFireDamageInSight(self, t)
		local res = t.getResistance(self, t)
		local manadrain = t.getManaDrain(self, t)
		return ([[Turn your body into pure flame, increasing your fire resistance by %d%%, burning any creatures attacking you for %0.2f fire damage and projecting random slow-moving fire bolts at targets in sight doing %0.2f fire damage.
		This powerful spell drains %0.2f mana while active.
		The damage and resistance will increase with your Spellpower.]]):
		format(res,onhitdam,insightdam,-manadrain)
	end,
}
