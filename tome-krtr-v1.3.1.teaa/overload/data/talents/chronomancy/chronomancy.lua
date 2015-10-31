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
	name = "Precognition",
	type = {"chronomancy/chronomancy",1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 20,
	no_npc_use = true,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 2, 10))) end,
	range = function(self, t) return 10 + math.floor(self:combatTalentScale(t, 2, 14)) end,
	action = function(self, t)
		-- Foresight bonuses
		local defense = 0
		local crits = 0
		if self:knowTalent(self.T_FORESIGHT) then
			defense = self:callTalent(self.T_FORESIGHT, "getDefense")
			crits = self:callTalent(self.T_FORESIGHT, "getCritDefense")
		end
		
		self:setEffect(self.EFF_PRECOGNITION, t.getDuration(self, t), {range=self:getTalentRange(t), actor=1, traps=1, defense=defense, crits=crits})
		
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		return ([[You peer into the future, sensing creatures and traps in a radius of %d for %d turns.
		If you know Foresight you'll gain additional defense and chance to shrug off critical hits (equal to your Foresight bonuses) while Precognition is active.]]):format(range, duration)
	end,
}

newTalent{
	name = "Foresight",
	type = {"chronomancy/chronomancy",2},
	mode = "passive",
	require = chrono_req2,
	points = 5,
	getDefense = function(self, t) return self:combatTalentStatDamage(t, "mag", 10, 50) end,
	getCritDefense = function(self, t) return self:combatTalentStatDamage(t, "mag", 2, 10) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_def", t.getDefense(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.getCritDefense(self, t))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_MAG then
			self:updateTalentPassives(t)
		end
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local crits = t.getCritDefense(self, t)
		return ([[Gain %d defense and %d%% chance to shrug off critical hits.
		If you have Precognition or See the Threads active these bonuses will be added to those effects, granting additional defense and chance to shrug off critical hits.
		These bonuses scale with your Magic stat.]]):
		format(defense, crits)
	end,
}

newTalent{
	name = "Contingency",
	type = {"chronomancy/chronomancy", 3},
	require = chrono_req3,
	points = 5,
	sustain_paradox = 36,
	mode = "sustained",
	no_sustain_autoreset = true,
	cooldown = 50,
	getTrigger= function(self, t) return self:combatTalentScale(t, 0.25, 0.45, 0.6) end,
	tactical = { DEFEND = 2 },
	no_npc_use = true,  -- so rares don't learn useless talents
	allow_temporal_clones = true,  -- let clones copy it anyway so they can benefit from the effects
	on_pre_use = function(self, t, silent) if self ~= game.player and not self:isTalentActive(t) then return false end return true end,  -- but don't let them cast it
	callbackOnHit = function(self, t, cb, src)
		if src == self then return cb.value end
	
		local p = self:isTalentActive(t.id)
		local life_after = self.life - cb.value
		local cont_trigger = self.max_life * t.getTrigger(self, t)
		
		-- Cast our contingent spell
		if p and p.rest_count <= 0 and cont_trigger > life_after then
			local cont_t = p.talent
			local cont_id = self:getTalentFromId(cont_t)
			local t_level = math.min(self:getTalentLevel(t), self:getTalentLevel(cont_t))
			
			-- Make sure we still know the talent and that the pre-use conditions apply
			if t_level == 0 or not self:knowTalent(cont_id) or not self:preUseTalent(cont_id, true, true) then
				game.logPlayer(self, "#LIGHT_RED#Your Contingency has failed to cast %s!", self:getTalentFromId(cont_t).name)
			else
				game.logPlayer(self, "#STEEL_BLUE#Your Contingency triggered %s!", self:getTalentFromId(cont_t).name)
				p.rest_count = self:getTalentCooldown(t)
				game:onTickEnd(function()
					if not self.dead then
						self:forceUseTalent(cont_t, {ignore_ressources=true, ignore_cd=true, ignore_energy=true, force_target=self, force_level=t_level})
					end
				end)
			end
		end
		
		return cb.value
	end,
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.rest_count > 0 then p.rest_count = p.rest_count - 1 end
	end,
	iconOverlay = function(self, t, p)
		local val = p.rest_count or 0
		if val <= 0 then return "" end
		local fnt = "buff_font"
		return tostring(math.ceil(val)), fnt
	end,
	activate = function(self, t)
		local talent = self:talentDialog(require("mod.dialogs.talents.ChronomancyContingency").new(self))
		if not talent then return nil end

		local ret = {
			talent = talent, rest_count = 0
		}
		
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.2, img="runicshield_teal"}, {type="runicshield", shieldIntensity=0.10, ellipsoidalFactor=1, scrollingSpeed=1, time_factor=12000, bubbleColor={0.5, 1, 0.8, 0.2}, auraColor={0.5, 1, 0.8, 0.5}}))
		end

		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local trigger = t.getTrigger(self, t) * 100
		local cooldown = self:getTalentCooldown(t)
		local talent = self:isTalentActive(t.id) and self:getTalentFromId(self:isTalentActive(t.id).talent).name or "None"
		return ([[Choose an activatable spell that affects only you and does not require a target.  When you take damage that reduces your life below %d%% the spell will automatically cast.
		This spell will cast even if it is currently on cooldown, will not consume a turn or resources, and uses the talent level of Contingency or its own, whichever is lower.
		This effect can only occur once every %d turns and takes place after the damage is resolved.

		Current Contingency Spell: %s]]):
		format(trigger, cooldown, talent)
	end,
}

newTalent{
	name = "See the Threads",
	type = {"chronomancy/chronomancy", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 24) end,
	cooldown = 50,
	no_npc_use = true,  -- so rares don't learn useless talents
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 4, 16))) end,
	on_pre_use = function(self, t, silent)
		if checkTimeline(self) then
			if not silent then
				game.logPlayer(self, "The timeline is too fractured to do this now.")
			end
			return false
		end
		if game.level and game.level.data and game.level.data.see_the_threads_done then
			if not silent then
				game.logPlayer(self, "You've seen as much as you can here.")
			end
			return false
		end
		return true
	end,
	action = function(self, t)
		-- Foresight Bonuses
		local defense = 0
		local crits = 0
		if self:knowTalent(self.T_FORESIGHT) then
			defense = self:callTalent(self.T_FORESIGHT, "getDefense")
			crits = self:callTalent(self.T_FORESIGHT, "getCritDefense")
		end
		
		if game.level and game.level.data then
			game.level.data.see_the_threads_done = true
		end
		
		self:setEffect(self.EFF_SEE_THREADS, t.getDuration(self, t), {defense=defense, crits=crits})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You peer into three possible futures, allowing you to explore each for %d turns.  When the effect expires, you'll choose which of the three futures becomes your present.
		If you know Foresight you'll gain additional defense and chance to shrug off critical hits (equal to your Foresight values) while See the Threads is active.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.
		If you die in any thread you'll revert the timeline to the point when you first cast the spell and the effect will end.
		This spell may only be used once per zone level.]])
		:format(duration)
	end,
}