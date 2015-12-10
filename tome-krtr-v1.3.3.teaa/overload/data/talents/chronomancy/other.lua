-- ToME - Tales of Maj'Eyal
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

-- Misc. Paradox Talents
newTalent{
	name = "Spacetime Tuning",
	type = {"chronomancy/other", 1},
	points = 1,
	tactical = { PARADOX = 2 },
	no_npc_use = true,
	no_unlearn_last = true,
	on_learn = function(self, t)
		if not self.preferred_paradox then self.preferred_paradox = 300 end
	end,
	getTuning = function(self, t)
		local value = 10
		-- factor spacetime stability in directly so our duration is set correctly
		if self:knowTalent(self.T_SPACETIME_STABILITY) then
			value = value + (self:callTalent(self.T_SPACETIME_STABILITY, "getTuning") * 2)
		end
		return value
	end,
	startTuning = function(self, t)
		if self.preferred_paradox and (self:getParadox() ~= self:getMinParadox() or self.preferred_paradox > self:getParadox())then
			local power = t.getTuning(self, t)
			if math.abs(self:getParadox() - self.preferred_paradox) > 1 then
				local duration = (self.preferred_paradox - self:getParadox())/power
				if duration < 0 then duration = math.abs(duration); power = power - (power*2) end
				duration = math.max(1, duration)
				self:setEffect(self.EFF_SPACETIME_TUNING, duration, {power=power})
			end
		end
	end,
	tuneParadox = function(self, t)
		tuneParadox(self, t, t.getTuning(self, t))
	end,
	action = function(self, t)
		local function getQuantity(title, prompt, default, min, max)
			local result
			local co = coroutine.running()

			local dialog = engine.dialogs.GetQuantity.new(
				title,
				prompt,
				default,
				max,
				function(qty)
					result = qty
					coroutine.resume(co)
				end,
				min)
			dialog.unload = function(dialog)
				if not dialog.qty then coroutine.resume(co) end
			end

			game:registerDialog(dialog)
			coroutine.yield()
			return result
		end

		local paradox = getQuantity(
			"Spacetime Tuning",
			"What's your preferred paradox level?",
			math.floor(self.paradox))
			if not paradox then return end
			if paradox > 1000 then paradox = 1000 end
			self.preferred_paradox = paradox
		return true
	end,
	info = function(self, t)
		local tune = t.getTuning(self, t)
		local preference = self.preferred_paradox
		local sp_modifier = getParadoxModifier(self, t) * 100
		local spellpower = getParadoxSpellpower(self, t)
		local after_will, will_modifier, sustain_modifier = self:getModifiedParadox()
		local anomaly = self:paradoxFailChance()
		return ([[Use to set your preferred Paradox.  While resting or waiting you'll adjust your Paradox towards this number at the rate of %d per turn.
		Your Paradox modifier is factored into the duration and spellpower of all chronomancy spells.

		Preferred Paradox :  %d
		Paradox Modifier :  %d%%
		Spellpower for Chronomancy :  %d
		Willpower Paradox Modifier : -%d
		Paradox Sustain Modifier : +%d
		Total Modifed Paradox :  %d
		Current Anomaly Chance :  %d%%]]):format(tune, preference, sp_modifier, spellpower, will_modifier, sustain_modifier, after_will, anomaly)
	end,
}

-- Talents from older versions to keep save files compatable
newTalent{
	name = "Slow",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 30) end,
	cooldown = 24,
	tactical = { ATTACKAREA = {TEMPORAL = 2}, DISABLE = 2 },
	range = 6,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.25, 3.25))	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSlow = function(self, t) return math.min(10 + self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self, t))/ 100 , 0.6) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 60, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.CHRONOSLOW, {dam=t.getDamage(self, t), slow=t.getSlow(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="temporal_cloud"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[Creates a time distortion in a radius of %d that lasts for %d turns, decreasing global speed by %d%% for 3 turns and inflicting %0.2f temporal damage each turn to all targets within the area.
		The slow effect and damage dealt will scale with your Spellpower.]]):
		format(radius, duration, 100 * slow, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Spacetime Mastery",
	type = {"chronomancy/other", 1},
	mode = "passive",
	require = chrono_req1,
	points = 5,
	getPower = function(self, t) return math.max(0, self:combatTalentLimit(t, 1, 0.15, 0.5)) end, -- Limit < 100%
	cdred = function(self, t, scale) return math.floor(scale*self:combatTalentLimit(t, 0.8, 0.1, 0.5)) end, -- Limit < 80% of cooldown
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_BANISH] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_DIMENSIONAL_STEP] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_SWAP] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_TEMPORAL_WAKE] = t.cdred(self, t, 10)})
		self:talentTemporaryValue(p, "talent_cd_reduction", {[self.T_WORMHOLE] = t.cdred(self, t, 20)})
	end,
	info = function(self, t)
		local cooldown = t.cdred(self, t, 10)
		local wormhole = t.cdred(self, t, 20)
		return ([[Your mastery of spacetime reduces the cooldown of Banish, Dimensional Step, Swap, and Temporal Wake by %d, and the cooldown of Wormhole by %d.  Also improves your Spellpower for purposes of hitting targets with chronomancy effects that may cause continuum destabilization (Banish, Time Skip, etc.), as well as your chance of overcoming continuum destabilization, by %d%%.]]):
		format(cooldown, wormhole, t.getPower(self, t)*100)

	end,
}

newTalent{
	name = "Quantum Feed",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	mode = "sustained",
	points = 5,
	sustain_paradox = 20,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return self:combatTalentScale(t, 1.5, 7.5, 0.75) + self:combatTalentStatDamage(t, "wil", 5, 20) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_MAG] = t.getPower(self, t)}),
			spell = self:addTemporaryValue("combat_spellresist", t.getPower(self, t)),
			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[You've learned to boost your magic through your control over the spacetime continuum.  Increases your Magic and your Spell Save by %d.
		The effect will scale with your Willpower.]]):format(power)
	end
}

newTalent{
	name = "Moment of Prescience",
	type = {"chronomancy/other", 1},
	require = chrono_req1,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 18,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 18, 3, 10.5)) end, -- Limit < 18
	getPower = function(self, t) return self:combatTalentScale(t, 4, 15) end, -- Might need a buff
	tactical = { BUFF = 4 },
	no_energy = true,
	no_npc_use = true,
	action = function(self, t)
		local power = t.getPower(self, t)
		-- check for Spin Fate
		local eff = self:hasEffect(self.EFF_SPIN_FATE)
		if eff then
			local bonus = math.max(0, (eff.cur_save_bonus or eff.save_bonus) / 2)
			power = power + bonus
		end

		self:setEffect(self.EFF_PRESCIENCE, t.getDuration(self, t), {power=power})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[You pull your awareness fully into the moment, increasing your stealth detection, see invisibility, defense, and accuracy by %d for %d turns.
		If you have Spin Fate active when you cast this spell, you'll gain a bonus to these values equal to 50%% of your spin.
		This spell takes no time to cast.]]):
		format(power, duration)
	end,
}

newTalent{
	name = "Gather the Threads",
	type = {"chronomancy/other", 1},
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 12,
	tactical = { BUFF = 2 },
	getThread = function(self, t) return self:combatTalentScale(t, 7, 30, 0.75) end,
	getReduction = function(self, t) return self:combatTalentScale(t, 3.6, 15, 0.75) end,
	action = function(self, t)
		self:setEffect(self.EFF_GATHER_THE_THREADS, 5, {power=t.getThread(self, t), reduction=t.getReduction(self, t)})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local primary = t.getThread(self, t)
		local reduction = t.getReduction(self, t)
		return ([[You begin to gather energy from other timelines. Your Spellpower will increase by %0.2f on the first turn and %0.2f more each additional turn.
		The effect ends either when you cast a spell, or after five turns.
		Eacn turn the effect is active, your Paradox will be reduced by %d.
		This spell will not break Spacetime Tuning, nor will it be broken by activating Spacetime Tuning.]]):format(primary + (primary/5), primary/5, reduction)
	end,
}

newTalent{
	name = "Entropic Field",
	type = {"chronomancy/other",1},
	mode = "sustained",
	points = 5,
	sustain_paradox = 20,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return math.min(90, 10 +  self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self, t))) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("time_shield", 1)),
			phys = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=t.getPower(self, t)/2}),
			proj = self:addTemporaryValue("slow_projectiles", t.getPower(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("resists", p.phys)
		self:removeTemporaryValue("slow_projectiles", p.proj)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[You encase yourself in a field that slows incoming projectiles by %d%%, and increases your physical resistance by %d%%.
		The effect will scale with your Spellpower.]]):format(power, power / 2)
	end,
}

newTalent{
	name = "Fade From Time",
	type = {"chronomancy/other", 1},
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 24,
	tactical = { DEFEND = 2, CURE = 2 },
	getResist = function(self, t) return self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self, t)) end,
	getdurred = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self, t)), 100, 0, 0, 32.9, 32.9) end, -- Limit < 100%
	action = function(self, t)
		-- fading managed by FADE_FROM_TIME effect in mod.data.timed_effects.other.lua
		self:setEffect(self.EFF_FADE_FROM_TIME, 10, {power=t.getResist(self, t), durred=t.getdurred(self,t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		local dur = t.getdurred(self,t)
		return ([[You partially remove yourself from the timeline for 10 turns.
		This increases your resistance to all damage by %d%%, reduces the duration of all detrimental effects on you by %d%%, and reduces all damage you deal by 20%%.
		The resistance bonus, effect reduction, and damage penalty will gradually lose power over the duration of the spell.
		The effects scale with your Spellpower.]]):
		format(resist, dur)
	end,
}

newTalent{
	name = "Paradox Clone",
	type = {"chronomancy/other", 1},
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 50) end,
	cooldown = 50,
	tactical = { ATTACK = 1, DISABLE = 2 },
	range = 2,
	requires_target = true,
	no_npc_use = true,
	getDuration = function(self, t)	return math.floor(self:combatTalentLimit(t, 50, 4, 8)) end, -- Limit <50
	getModifier = function(self, t) return rng.range(t.getDuration(self,t)*2, t.getDuration(self, t)*4) end,
	action = function (self, t)
		if checkTimeline(self) == true then
			return
		end

		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty then return nil end

		local x, y = util.findFreeGrid(tx, ty, 2, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local sex = game.player.female and "she" or "he"
		local m = require("mod.class.NPC").new(self:cloneFull{
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			exp_worth = 0,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			ai_tactic = resolvers.tactic("ranged"), ai_state = { talent_in=1, ally_compassion=10},
			desc = [[The real you... or so ]]..sex..[[ says.]]
		})
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		m.energy.value = 0
		m.player = nil
		m.puuid = nil
		m.max_life = m.max_life
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.on_takehit = nil
		m.no_inventory_access = true
		m.clone_on_hit = nil
		m.remove_from_party_on_death = true

		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(m.talents) do
			local t = m:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			m.talents[t.id] = nil
		end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/teleport")

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="no",
				type="minion",
				title="Paradox Clone",
				orders = {target=true},
			})
		end

		self:setEffect(self.EFF_IMMINENT_PARADOX_CLONE, t.getDuration(self, t) + t.getModifier(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[You summon your future self to fight alongside you for %d turns.  At some point in the future, you'll be pulled into the past to fight alongside your past self after the initial effect ends.
		This spell splits the timeline.  Attempting to use another spell that also splits the timeline while this effect is active will be unsuccessful.]]):format(duration)
	end,
}

newTalent{
	name = "Displace Damage",
	type = {"chronomancy/other", 1},
	mode = "sustained",
	require = chrono_req1,
	sustain_paradox = 48,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	-- called by _M:onTakeHit function in mod\class\Actor.lua to perform the damage displacment
	getDisplaceDamage = function(self, t) return self:combatTalentLimit(t, 25, 5, 15)/100 end, -- Limit < 25%
	range = 10,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		if dam > 0 and src ~= self then
			-- find available targets
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
			for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					tgts[#tgts+1] = a
				end
			end end

			-- Displace the damage
			local a = rng.table(tgts)
			if a then
				local displace = dam * t.getDisplaceDamage(self, t)
				game:delayedLogMessage(self, a, "displace_damage"..(a.uid or ""), "#PINK##Source# displaces some damage onto #Target#!")
				DamageType.defaultProjector(self, a.x, a.y, type, displace, tmp, true)
				dam = dam - displace
			end
		end

		return {dam=dam}
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local displace = t.getDisplaceDamage(self, t) * 100
		return ([[You bend space around you, displacing %d%% of any damage you receive onto a random enemy within range.
		]]):format(displace)
	end,
}

newTalent{
	name = "Repulsion Field",
	type = {"chronomancy/other",1},
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 30) end,
	cooldown = 14,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, ESCAPE = 2 },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 8, 80, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.REPULSION, t.getDamage(self, t),
			tg.radius,
			5, nil,
			engine.MapEffect.new{color_br=200, color_bg=120, color_bb=0, effect_shader="shader_images/paradox_effect.png"},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			tg.selffire
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[You surround yourself with a radius %d distortion of gravity, knocking back and dealing %0.2f physical damage to all creatures inside it.  The effect lasts %d turns.  Deals 50%% extra damage to pinned targets, in addition to the knockback.
		The blast wave may hit targets more then once, depending on the radius and the knockback effect.
		The damage will scale with your Spellpower.]]):format(radius, damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}

newTalent{
	name = "Temporal Clone",
	type = {"chronomancy/other", 1},
	points = 5,
	cooldown = 12,
	paradox = function (self, t) return getParadoxCost(self, t, 15) end,
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	range = 10,
	remove_on_clone = true,
	target = function (self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t, nowarning=true}
	end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 6, 12))) end,
	getDamagePenalty = function(self, t) return 60 - math.min(self:combatTalentSpellDamage(t, 0, 20, getParadoxSpellpower(self, t)), 30) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		-- Find space
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if not tx then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		-- Rank Penalty
		local duration = t.getDuration(self, t)
		if target.rank > 1 then duration = math.ceil(t.getDuration(self, t)/(target.rank/2)) end

		 -- Clone the target
		local m = makeParadoxClone(self, target, duration)
		-- Add and change some values
		m.faction = self.faction
		m.summoner = self
		m.generic_damage_penalty = t.getDamagePenalty(self, t)
		m.max_life = m.max_life * (100 - t.getDamagePenalty(self, t))/100
		m.life = m.max_life
		m.remove_from_party_on_death = true

		-- Handle some AI stuff
		m.ai_state = { talent_in=2, ally_compassion=10 }

		game.zone:addEntity(game.level, m, "actor", tx, ty)

		-- Set our target
		if self:reactionToward(target) < 0 then
			m:setTarget(target)
		end

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="no",
				type="temporal-clone",
				title="Temporal Clone",
				orders = {target=true},
			})
		end

		game.level.map:particleEmitter(tx, ty, 1, "temporal_teleport")
		game:playSoundNear(self, "talents/spell_generic")

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage_penalty = t.getDamagePenalty(self, t)
		return ([[Clones the target creature for up to %d turns.  The duration of the effect will be divided by half the target's rank, and the target will have have %d%% of its normal life and deal %d%% less damage.
		If you clone a hostile creature the clone will target the creature it was cloned from.
		The life and damage penalties will be lessened by your Spellpower.]]):
		format(duration, 100 - damage_penalty, damage_penalty)
	end,
}

newTalent{
	name = "Damage Smearing",
	type = {"chronomancy/other", 1},
	mode = "sustained",
	sustain_paradox = 48,
	cooldown = 24,
	tactical = { DEFEND = 2 },
	points = 5,
	getPercent = function(self, t) return self:combatTalentLimit(t, 50, 10, 30)/100 end, -- Limit < 50%
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 3, 6))) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		if dam > 0 and type ~= DamageType.TEMPORAL then
			local smear = dam * t.getPercent(self, t)
			self:setEffect(self.EFF_DAMAGE_SMEARING, t.getDuration(self, t), {dam=smear/t.getDuration(self, t), no_ct_effect=true})
			game:delayedLogDamage(src, self, 0, ("%s(%d smeared)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", smear), false)
			dam = dam - smear
		end

		return {dam=dam}
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[You convert %d%% of all non-temporal damage you receive into temporal damage spread out over %d turns.
		This damage will bypass resistance and affinity.]]):format(percent, duration)
	end,
}

newTalent{
	name = "Phase Shift",
	type = {"chronomancy/other", 1},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 24,
	tactical = { DEFEND = 2 },
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentLimit(t, 25, 3, 7, true))) end,
	action = function(self, t)
		self:setEffect(self.EFF_PHASE_SHIFT, t.getDuration(self, t), {})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Phase shift yourself for %d turns; any damage greater than 10%% of your maximum life will teleport you to an adjacent tile and be reduced by 50%% (can only happen once per turn).]]):
		format(duration)
	end,
}

newTalent{
	name = "Swap",
	type = {"chronomancy/other", 1},
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { DISABLE = 1 },
	requires_target = true,
	direct_hit = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9, 0.5, 0, 1)) end,
	getConfuseDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getConfuseEfficency = function(self, t) return math.min(50, self:getTalentLevelRaw(t) * 10) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		if tx then
			local _ _, tx, ty = self:canProject(tg, tx, ty)
			if tx then
				target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return nil end
			end
		end

		-- Check hit
		if target:canBe("teleport") and self:checkHit(getParadoxSpellpower(self, t), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0)) then
			-- Grab the caster's location
			local px, py = self.x, self.y

			-- Remove the target so the destination tile is empty
			game.level.map:remove(target.x, target.y, Map.ACTOR)

			-- Try to teleport to the target's old location
			if self:teleportRandom(tx, ty, 0) then
				-- Put the target back in the caster's old location
				game.level.map(px, py, Map.ACTOR, target)
				target.x, target.y = px, py

				-- confuse them
				self:project(tg, target.x, target.y, DamageType.CONFUSION, { dur = t.getConfuseDuration(self, t), dam = t.getConfuseEfficency(self, t), apply_power=getParadoxSpellpower(self, t)})
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=getParadoxSpellpower(self, t, 0.3)})

				game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			else
				-- If we can't teleport, return the target
				game.level.map(target.x, target.y, Map.ACTOR, target)
				game.logSeen(self, "The spell fizzles!")
			end
		else
			game.logSeen(target, "%s resists the swap!", target.name:capitalize())
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getConfuseDuration(self, t)
		local power = t.getConfuseEfficency(self, t)
		return ([[You manipulate the spacetime continuum in such a way that you switch places with another creature with in a range of %d.  The targeted creature will be confused (power %d%%) for %d turns.
		The spell's hit chance will increase with your Spellpower.]]):format (range, power, duration)
	end,
}

newTalent{
	name = "Temporal Wake",
	type = {"chronomancy/other", 1},
	points = 5,
	random_ego = "attack",
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 10,
	tactical = { ATTACK = {TEMPORAL = 1, PHYSICAL = 1}, CLOSEIN = 2, DISABLE = { stun = 2 } },
	direct_hit = true,
	requires_target = true,
	is_teleport = true,
	target = function(self, t)
		return {type="beam", start_x=x, start_y=y, range=self:getTalentRange(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 3, 7))) end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9, 0.5, 0, 1)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logSeen(self, "You do not have line of sight.")
			return nil
		end
		local _ _, x, y = self:canProject(tg, x, y)
		local ox, oy = self.x, self.y

		-- If we target an actor directly project onto the other side of it (quality of life)
		if target then
			local dir = util.getDir(x, y, self.x, self.y)
			x, y = util.coordAddDir(x, y, dir)
		end

		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "The spell fizzles!")
		else
			local dam = self:spellCrit(t.getDamage(self, t))
			local x, y = ox, oy
			self:project(tg, x, y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target then
					-- Deal warp damage first so we don't overwrite a big stun with a little one
					DamageType:get(DamageType.WARP).projector(self, px, py, DamageType.WARP, dam)

					-- Try to stun
					if target:canBe("stun") then
						target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self, t)})
					else
						game.logSeen(target, "%s resists the stun!", target.name:capitalize())
					end
				end
			end)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporal_lightning", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
		end

		return true
	end,
	info = function(self, t)
		local stun = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[Violently fold the space between yourself and another point within range.
		You teleport to the target location, and leave a temporal wake behind that stuns for %d turns and deals %0.2f temporal and %0.2f physical warp damage to targets in the path.
		The damage will scale with your Spellpower.]]):
		format(stun, damDesc(self, DamageType.TEMPORAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/2))
	end,
}

newTalent{
	name = "Carbon Spikes",
	type = {"chronomancy/other", 1},
	no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_paradox = 20,
	cooldown = 12,
	tactical = { BUFF =2, DEFEND = 2 },
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 1, 150, getParadoxSpellpower(self, t)) end,
	getArmor = function(self, t) return math.ceil(self:combatTalentSpellDamage(t, 20, 50, getParadoxSpellpower(self, t))) end,
	callbackOnActBase = function(self, t)
		local maxspikes = t.getArmor(self, t)
		if self.carbon_armor < maxspikes then
			self.carbon_armor = self.carbon_armor + 1
		end
	end,
	do_carbonLoss = function(self, t)
		if self.carbon_armor >= 1 then
			self.carbon_armor = self.carbon_armor - 1
		else
			-- Deactivate without loosing energy
			self:forceUseTalent(self.T_CARBON_SPIKES, {ignore_energy=true})
		end
	end,
	activate = function(self, t)
		local power = t.getArmor(self, t)
		self.carbon_armor = power
		game:playSoundNear(self, "talents/spell_generic")
		return {
			armor = self:addTemporaryValue("carbon_spikes", power),
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.BLEED]=t.getDamageOnMeleeHit(self, t)}),			
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("carbon_spikes", p.armor)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self.carbon_armor = nil
		return true
	end,
	info = function(self, t)
		local damage = t.getDamageOnMeleeHit(self, t)
		local armor = t.getArmor(self, t)
		return ([[Fragile spikes of carbon protrude from your flesh, clothing, and armor, increasing your armor rating by %d and inflicting %0.2f bleed damage over six turns on attackers.   Each time you're struck, the armor increase will be reduced by 1.  Each turn the spell will regenerate 1 armor up to its starting value.
		If the armor increase from the spell ever falls below 1, the sustain will deactivate and the effect will end.
		The armor and bleed damage will increase with your Spellpower.]]):
		format(armor, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Destabilize",
	type = {"chronomancy/other", 1},
	points = 5,
	cooldown = 10,
	paradox = function (self, t) return getParadoxCost(self, t, 30) end,
	range = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60, getParadoxSpellpower(self, t)) end,
	getExplosion = function(self, t) return self:combatTalentSpellDamage(t, 20, 230, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_TEMPORAL_DESTABILIZATION, 10, {src=self, dam=t.getDamage(self, t), explosion=self:spellCrit(t.getExplosion(self, t))})
			game.level.map:particleEmitter(target.x, target.y, 1, "entropythrust")
		end)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local explosion = t.getExplosion(self, t)
		return ([[Destabilizes the target, inflicting %0.2f temporal damage per turn for 10 turns.  If the target dies while destabilized, it will explode, doing %0.2f temporal damage and %0.2f physical damage in a radius of 4.
		If the target dies while also under the effects of continuum destabilization, all explosion damage will be done as temporal damage.
		The damage will scale with your Spellpower.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.TEMPORAL, explosion/2), damDesc(self, DamageType.PHYSICAL, explosion/2))
	end,
}

newTalent{
	name = "Quantum Spike",
	type = {"chronomancy/other", 1},
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 40) end,
	cooldown = 4,
	tactical = { ATTACK = {TEMPORAL = 1, PHYSICAL = 1} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- bonus damage on targets with temporal destabilization
		local damage = t.getDamage(self, t)
		if target then 
			if target:hasEffect(target.EFF_TEMPORAL_DESTABILIZATION) or target:hasEffect(target.EFF_CONTINUUM_DESTABILIZATION) then
				damage = damage * 1.5
			end
		end
		
		
		self:project(tg, x, y, DamageType.WARP, self:spellCrit(damage))
		game:playSoundNear(self, "talents/arcane")
		
		-- Try to insta-kill
		if target then
			if target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") and target.life > 0 and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s has been pulled apart at a molecular level!", target.name:capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s resists the quantum spike!", target.name:capitalize())
			end
		end
		
		-- if we kill it use teleport particles for larger effect radius
		if target and target.dead then
			game.level.map:particleEmitter(x, y, 1, "teleport")
		else
			game.level.map:particleEmitter(x, y, 1, "entropythrust")
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Attempts to pull the target apart at a molecular level, inflicting %0.2f temporal damage and %0.2f physical damage.  If the target ends up with low enough life (<20%%), it might be instantly killed.
		Quantum Spike deals 50%% additional damage to targets affected by temporal destabilization and/or continuum destabilization.
		The damage will scale with your Spellpower.]]):format(damDesc(self, DamageType.TEMPORAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/2))
	end,
}
