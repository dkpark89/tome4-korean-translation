﻿-- ToME - Tales of Maj'Eyal
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
	name = "Stealth",
	kr_display_name = "은신",
	type = {"cunning/stealth", 1},
	require = cuns_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = 10,
	allow_autocast = true,
	no_energy = true,
	tactical = { BUFF = 3 },
	getStealthPower = function(self, t) return 4 + self:getCun(10, true) * self:getTalentLevel(t) end,
	getRadius = function(self, t) return math.max(0, math.floor(10 - self:getTalentLevel(t) * 1.1)) end,
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(t.id) then return true end
		local armor = self:getInven("BODY") and self:getInven("BODY")[1]
		if armor and (armor.subtype == "heavy" or armor.subtype == "massive") then
			if not silent then game.logPlayer(self, "You cannot Stealth with such heavy armour on!") end
			return nil
		end

		-- Check nearby actors
		if not self.x or not self.y or not game.level then return end

		if not rng.percent(self.hide_chance or 0) then
			local grids = core.fov.circle_grids(self.x, self.y, t.getRadius(self, t), true)
			for x, yy in pairs(grids) do for y in pairs(yy) do
				local actor = game.level.map(x, y, game.level.map.ACTOR)
				if actor and actor ~= self and actor:reactionToward(self) < 0 then
					if not actor:hasEffect(actor.EFF_DIM_VISION) then
						if not silent then game.logPlayer(self, "You cannot Stealth with nearby foes watching!") end
						return nil
					end
				end
			end end
		end
		return true
	end,
	activate = function(self, t)
		local res = {
			stealth = self:addTemporaryValue("stealth", t.getStealthPower(self, t)),
			lite = self:addTemporaryValue("lite", -1000),
			infra = self:addTemporaryValue("infravision", 1),
		}
		self:resetCanSeeCacheOf()
		if self.updateMainShader then self:updateMainShader() end
		return res
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("stealth", p.stealth)
		self:removeTemporaryValue("infravision", p.infra)
		self:removeTemporaryValue("lite", p.lite)
		self:resetCanSeeCacheOf()
		if self.updateMainShader then self:updateMainShader() end
		return true
	end,
	info = function(self, t)
		local stealthpower = t.getStealthPower(self, t) + (self:attr("inc_stealth") or 0)
		local radius = t.getRadius(self, t)
		return ([[Enters stealth mode (power %d, based on Cunning), making you harder to detect.
		If successful (re-checked each turn), enemies will not know exactly where you are, or may not notice you at all.
		Stealth reduces your light radius to 0, and will not work with heavy or massive armours.
		You cannot enter stealth if there are foes in sight within range %d.]]):
		format(stealthpower, radius)
	end,
}

newTalent{
	name = "Shadowstrike",
	kr_display_name = "은신 타격",
	type = {"cunning/stealth", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getMultiplier = function(self, t) return self:getTalentLevel(t) / 7 end,
	info = function(self, t)
		local multiplier = t.getMultiplier(self, t)
		return ([[When striking from stealth, hits are automatically criticals if the target does not notice you just before you land the blow.
		Shadowstrikes do +%.02f%% damage versus a normal critical hit.]]):
		format(multiplier * 100)
	end,
}

newTalent{
	name = "Hide in Plain Sight",
	kr_display_name = "평지에서의 은닉",
	type = {"cunning/stealth",3},
	require = cuns_req3,
	no_energy = "fake",
	points = 5,
	stamina = 20,
	cooldown = 40,
	tactical = { DEFEND = 2 },
	getChance = function(self, t) return 40 + self:getTalentLevel(t) * 7 end,
	action = function(self, t)
		if self:isTalentActive(self.T_STEALTH) then return end

		self.talents_cd[self.T_STEALTH] = nil
		self.changed = true
		self.hide_chance = t.getChance(self, t)
		self:useTalent(self.T_STEALTH)
		self.hide_chance = nil

		for uid, e in pairs(game.level.entities) do
			if e.ai_target and e.ai_target.actor == self then e:setTarget(nil) end
		end

		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[You have learned how to be stealthy even when in plain sight of your foes, with a %d%% chance of success. This also resets the cooldown of your Stealth talent.
		All creatures currently following you will lose all track.]]):
		format(chance)
	end,
}

newTalent{
	name = "Unseen Actions",
	kr_display_name = "보이지않는 행동",
	type = {"cunning/stealth", 4},
	require = cuns_req4,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return 10 + self:getTalentLevel(t) * 9 end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[When you perform an action from stealth (attacking, using objects, ...) you have a %d%% chance to not break stealth.]]):
		format(chance)
	end,
}
