﻿-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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

local cooldown_bonus = function(self)
	local t = self:getTalentFromId("T_SKIRMISHER_SUPERB_AGILITY")
	return t.cooldown_bonus(self, t)
end

local stamina_bonus = function(self)
	local t = self:getTalentFromId("T_SKIRMISHER_SUPERB_AGILITY")
	return t.stamina_bonus(self, t)
end

newTalent {
	short_name = "SKIRMISHER_VAULT",
	name = "Vault",
	type = {"technique/acrobatics", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return 10 - cooldown_bonus(self) end,
	stamina = function(self, t) return math.max(0, 18 - stamina_bonus(self)) end,
	tactical = {ESCAPE = 2},
	on_pre_use = function(self, t)
		return not self:attr("never_move")
	end,
	range = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 8))
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t, nolock=true}
	end,
	speed_bonus = function(self, t)
		return self:combatTalentScale(t, 0.6, 1.0, 0.75)
	end,
	action = function(self, t)
		-- Get Landing Point.
		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return end
		if core.fov.distance(self.x, self.y, tx, ty) > self:getTalentRange(t) then return end
		if tx == self.x and ty == self.y then return end
		if target or
			game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self)
		then
			game.logPlayer(self, "You must have an empty space to land in.")
			return
		end

		-- Get Launch target.
		local block_actor = function(_, bx, by)
			return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self)
		end
		local line = self:lineFOV(tx, ty, block_actor)
		local lx, ly, is_corner_blocked = line:step()
		local launch_target = game.level.map(lx, ly, Map.ACTOR)
		if not launch_target then
			game.logPlayer(self, "You need someone adjacent to vault over.")
			return
		end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)

		local give_speed = function()
			self:setEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED, 3, {
				 direction = math.atan2(ty - oy, tx - ox),
				 leniency = math.pi * 0.25, -- 90 degree cone
				 move_speed_bonus = t.speed_bonus(self, t),
				 compass = game.level.map:compassDirection(tx-ox, ty-oy)
			})
		end
		game:onTickEnd(give_speed)

		return true
	end,
	info = function(self, t)
		return ([[Use an adjacent friend or foe as a springboard, vaulting over them to another tile within range.
		This maneuver grants you a burst of speed from your momentum, allowing you run %d%% faster (movement speed bonus) in the same direction you vaulted for 3 turns.
		The increased speed ends if you change directions or stop moving.
		]]):format(t.speed_bonus(self, t) * 100)
	end,
}

newTalent {
	name = "Tumble",
	short_name = "SKIRMISHER_CUNNING_ROLL",
	type = {"technique/acrobatics", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return 20 - cooldown_bonus(self) end,
	no_energy = true,
	stamina = function(self, t)
		return math.max(0, 20 - stamina_bonus(self))
	end,
	tactical = {ESCAPE = 2, BUFF = 1},
	range = function(self, t)
		return math.floor(self:combatTalentScale(t, 2, 4))
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	combat_physcrit = function(self, t)
		return self:combatTalentScale(t, 2.3, 7.5, 0.75)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		if self.x == x and self.y == y then return end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return end

		if target or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			game.logPlayer(self, "You must have an empty space to roll to.")
			return false
		end

		self:move(x, y, true)
		local combat_physcrit = t.combat_physcrit(self, t)
		if combat_physcrit then
			-- Can't set to 0 duration directly, so set to 1 and then decrease by 1.
			self:setEffect("EFF_SKIRMISHER_TACTICAL_POSITION", 1, {combat_physcrit = combat_physcrit})
			local eff = self:hasEffect("EFF_SKIRMISHER_TACTICAL_POSITION")
			eff.dur = eff.dur - 1
		end

		return true
	end,
	info = function(self, t)
		return ([[Move to a spot within range, bounding around, over, or through any enemies in the way.
		This maneuver can surprise your foes and improves your tactical position, improving your physical critical chance by %d%% for 1 turn.]]):format(t.combat_physcrit(self, t))
	end
}

newTalent {
	short_name = "SKIRMISHER_TRAINED_REACTIONS",
	name = "Trained Reactions",
	type = {"technique/acrobatics", 3},
	mode = "sustained",
	points = 5,
	cooldown = function(self, t) return 10 - cooldown_bonus(self) end,
	stamina_per_use = function(self, t) return 30 - stamina_bonus(self) end,
	sustain_stamina = 10,
	require = techs_dex_req3,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	getLifeTrigger = function(self, t)
		return self:combatTalentLimit(t, 10, 40, 24)
	end,
	getReduction = function(self, t)
		return self:combatTalentLimit(t, 60, 10, 30)
	end,
	-- called by mod/Actor.lua, although it could be a callback one day
	onHit = function(self, t, damage)
		-- Don't have trigger cooldown.
		-- if self:hasEffect("EFF_SKIRMISHER_TRAINED_REACTIONS_COOLDOWN") then return damage end

		local cost = t.stamina_per_use(self, t)
		if damage >= self.max_life * t.getLifeTrigger(self, t) * 0.01 then
			
			local nx, ny = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
			if nx and ny and use_stamina(self, cost) then

				-- Apply effect with duration 0.
				self:setEffect("EFF_SKIRMISHER_DEFENSIVE_ROLL", 1, {reduce = t.getReduction(self, t)})
				local eff = self:hasEffect("EFF_SKIRMISHER_DEFENSIVE_ROLL")
				eff.dur = eff.dur - 1

				-- Try to apply bonus effect from Superb Agility.
				local agility = self:getTalentFromId("T_SKIRMISHER_SUPERB_AGILITY")
				local speed = agility.speed_buff(self, agility)
				if speed then
					self:setEffect("EFF_SKIRMISHER_SUPERB_AGILITY", speed.duration, speed)
				end

				return damage * (100-t.getReduction(self, t)) / 100
			end
		end
		return damage
	end,

	info = function(self, t)
		local trigger = t.getLifeTrigger(self, t)
		local reduce = t.getReduction(self, t)
		local cost = t.stamina_per_use(self, t) * (1 + self:combatFatigue() * 0.01)
		return ([[While this talent is sustained, you anticipate deadly attacks against you.
		Any time you would lose more than %d%% of your life in a single hit, you instead duck out of the way and assume a defensive posture.
		This reduces the triggering damage and all further damage in the same turn by %d%%.
		You need %0.1f Stamina and an adjacent open tile to perform this feat (though it does not cause you to move).]])
		:format(trigger, reduce, cost)
	end,
}

newTalent {
	short_name = "SKIRMISHER_SUPERB_AGILITY",
	name = "Superb Agility",
	type = {"technique/acrobatics", 4},
	require = techs_dex_req4,
	mode = "passive",
	points = 5,
	stamina_bonus = function(self, t) return self:combatTalentLimit(t, 18, 3, 10) end, --Limit < 18
	cooldown_bonus = function(self, t) return math.floor(math.max(0, self:combatTalentLimit(t, 10, 1, 5))) end, --Limit < 10
	speed_buff = function(self, t)
		local level = self:getTalentLevel(t)
		if level >= 5 then return {global_speed_add = 0.2, duration = 2} end
		if level >= 3 then return {global_speed_add = 0.1, duration = 1} end
	end,
	info = function(self, t)
		return ([[You gain greater facility with your acrobatic moves, lowering the cooldowns of Vault, Tumble, and Trained Reactions by %d, and their stamina costs by %0.1f.
		At Rank 3 you also gain 10%% global speed for 1 turn after Trained Reactions activates. At rank 5 this speed bonus improves to 20%% and lasts for 2 turns.]])
		:format(t.cooldown_bonus(self, t), t.stamina_bonus(self, t))
	end,
}
