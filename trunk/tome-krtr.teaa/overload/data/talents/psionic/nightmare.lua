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

newTalent{
	name = "Nightmare",
	type = {"psionic/nightmare", 1},
	points = 5, 
	require = psi_wil_high1,
	cooldown = 8,
	psi = 10,
	tactical = { DISABLE = {sleep = 1}, ATTACK = { DARKNESS = 2 }, },
	direct_hit = true,
	requires_target = true,
	range = function(self, t) return 2 + math.floor(self:getTalentLevel(t)/2) end,
	target = function(self, t) return {type="cone", radius=self:getTalentRange(t), range=0, talent=t, selffire=false} end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/2) end,
	getInsomniaPower= function(self, t)
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaPower(self, t)
		return 20 - reduction
	end,
	getSleepPower = function(self, t) 
		local power = self:combatTalentMindDamage(t, 5, 25)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power * t.getSleepPowerBonus(self, t)
		end
		return math.ceil(power)
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		--Restless?
		local is_waking =0
		if self:knowTalent(self.T_RESTLESS_NIGHT) then
			local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
			is_waking = t.getDamage(self, t)
		end
		
		local damage = self:mindCrit(t.getDamage(self, t))
		local power = self:mindCrit(t.getSleepPower(self, t))
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if target then
				if target:canBe("sleep") then
					target:setEffect(target.EFF_NIGHTMARE, t.getDuration(self, t), {src=self, power=power, waking=is_waking, dam=damage, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
				else
					game.logSeen(self, "%s resists the nightmare!", target.name:capitalize())
				end
			end
		end)
		
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "generic_wave", {radius=tg.radius, tx=x-self.x, ty=y-self.y, rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=35, aM=90})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRange(t)
		local duration = t.getDuration(self, t)
		local power = t.getSleepPower(self, t)
		local damage = t.getDamage(self, t)
		local insomnia = t.getInsomniaPower(self, t)
		return([[Puts targets in a radius %d cone into a nightmarish sleep for %d turns, rendering them unable to act.  Every %d points of damage the target suffers will reduce the effect duration by one turn.
		Each turn they'll suffer %0.2f darkness damage.  This damage will not reduce the duration of the effect.
		When Nightmare ends the target will suffer from Insomnia for a number of turns equal to the amount of time it was asleep (up to five turns max), granting it %d%% sleep immunity for each turn of the Insomnia effect.
		The damage threshold and mind damage will scale with your mindpower.]]):format(radius, duration, power, damDesc(self, DamageType.DARKNESS, (damage)), insomnia)
	end,
}

newTalent{
	name = "Inner Demons",
	type = {"psionic/nightmare", 2},
	points = 5,
	require = psi_wil_high2,
	cooldown = 18,
	psi = 20,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = function(self, t, target) if target and target:attr("sleep") then return 4 else return 2 end end },
	getChance = function(self, t) return self:combatTalentMindDamage(t, 15, 50) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * 2) end,
	summon_inner_demons = function(self, target, t)
		-- Find space
		local x, y = util.findFreeGrid(target.x, target.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			return
		end

		local m = target:clone{
			shader = "shadow_simulacrum",
			shader_args = { color = {0.6, 0.0, 0.3}, base = 0.6, time_factor = 1500 },
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
			ai_target = {actor=target},
			ai = "summoned", ai_real = "tactical",
			name = ""..target.name.."'s Inner Demon",
			desc = [[A hideous, demonic entity that resembles the creature it came from.]],
		}
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		mod.class.NPC.castAs(m)
		engine.interface.ActorAI.init(m, m)

		m.exp_worth = 0
		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life / 4
		m.life = util.bound(m.life, 0, m.max_life)
		m.inc_damage.all = (m.inc_damage.all or 0) - 50
		m.forceLevelup = function() end
		m.on_die = nil
		m.puuid = nil
		m.on_acquire_target = nil
		m.no_inventory_access = true
		m.on_takehit = nil
		m.seen_by = nil
		m.can_talk = nil
		m.clone_on_hit = nil

		-- Inner Demon's never flee
		m.ai_tactic = m.ai_tactic or {}
		m.ai_tactic.escape = 0
		
		-- Remove some talents
		local tids = {}
		for tid, _ in pairs(m.talents) do
			local t = m:getTalentFromId(tid)
			if t.no_npc_use then tids[#tids+1] = t end
		end
		for i, t in ipairs(tids) do
			if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true}) end
			m.talents[t.id] = nil
		end
		
		-- remove detrimental timed effects
		local effs = {}
		for eff_id, p in pairs(m.tmp) do
			local e = m.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		while #effs > 0 do
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" then
				m:removeEffect(eff[2])
			end
		end

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})

		game.logSeen(target, "#F53CBE#%s's Inner Demon manifests!", target.name:capitalize())

	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		if self:reactionToward(target) >= 0 then
			game.logPlayer(self, "You can't cast this on friendly targets.")
			return nil
		end
		
		local chance = self:mindCrit(t.getChance(self, t))
		if target:canBe("fear") then
			target:setEffect(target.EFF_INNER_DEMONS, t.getDuration(self, t), {src = self, chance=chance, apply_power=self:combatMindpower()})
		else
			game.logSeen(target, "%s resists the demons!", target.name:capitalize())
		end
		
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[Brings the target's inner demons to the surface.  Each turn for %d turns there's a %d%% chance that the a demon will surface, requiring the target to make a mental save to keep it from manifesting.
		If the target is sleeping the chance will be doubled and no saving throw will be allowed.  Otherwise if the summoning is resisted the effect will end early.
		The summon chance will scale with your mindpower.]]):format(duration, chance)
	end,
}

newTalent{
	name = "Waking Nightmare",
	type = {"psionic/nightmare", 3},
	points = 5,
	require = psi_wil_high3,
	cooldown = 10,
	psi = 20,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { DARKNESS = 2 }, DISABLE = function(self, t, target) if target and target:attr("sleep") then return 4 else return 2 end end },
	getChance = function(self, t) return self:combatTalentMindDamage(t, 15, 50) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local chance = self:mindCrit(t.getChance(self, t))
		if target:canBe("fear") then
			target:setEffect(target.EFF_WAKING_NIGHTMARE, t.getDuration(self, t), {src = self, chance=t.getChance(self, t), dam=self:mindCrit(t.getDamage(self, t)), apply_power=self:combatMindpower()})
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})
		else
			game.logSeen(target, "%s resists the nightmare!", target.name:capitalize())
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[Inflicts %0.2f darkness damage each turn for %d turns and has a %d%% chance to randomly cause blindness, stun, or confusion (lasting 3 turns).
		If the target is sleeping the chance of suffering a negative effect will be doubled.
		The damage will scale with your mindpower.]]):
		format(damDesc(self, DamageType.DARKNESS, (damage)), duration, chance)
	end,
}

newTalent{
	name = "Night Terror",
	type = {"psionic/nightmare", 4},
	points = 5,
	require = psi_wil_high4,
	mode = "sustained",
	sustain_psi = 50,
	cooldown = 24,
	tactical = { BUFF=2 },
	getDamageBonus = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getSummonTime = function(self, t) return math.floor(self:getTalentLevel(t)*2) end,
	summonNightTerror = function(self, target, t)
		-- Find space
		local x, y = util.findFreeGrid(target.x, target.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			return
		end
		
		local stats = 10 + t.getDamageBonus(self, t)
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			name = "terror",
			display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
			blood_color = colors.BLUE,
			desc = "A formless terror that seems to cut through the air, and its victims, like a knife.",
			type = "horror", subtype = "eldritch",
			rank = 2,
			size_category = 2,
			body = { INVEN = 10 },
			no_drops = true,
			autolevel = "warriorwill",
			level_range = {1, nil}, exp_worth = 0,
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2 },
			stats = { str=15, dex=15, wil=15, con=15, cun=15},
			infravision = 10,
			can_pass = {pass_wall=20},
			resists = {[DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},
			silent_levelup = true,
			no_breath = 1,
			negative_status_effect_immune = 1,
			infravision = 10,
			see_invisible = 80,
			sleep = 1,
			lucid_dreamer = 1,
			max_life = resolvers.rngavg(50, 80),
			combat_armor = 1, combat_def = 10,
			combat = { dam=resolvers.levelup(resolvers.rngavg(15,20), 1, 1.1), atk=resolvers.rngavg(5,15), apr=5, dammod={str=1}, damtype=DamageType.DARKNESS },
			resolvers.talents{
			--	[Talents.T_SLEEP]=self:getTalentLevelRaw(t),
			},
		}

		m.faction = self.faction
		m.summoner = self
		m.summoner_gain_exp = true
		m.summon_time = t.getSummonTime(self, t)
		m.remove_from_party_on_death = true
		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180})
		
		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="no",
				type="terror",
				title="Night Terror",
				orders = {target=true},
			})
		end

	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local ret = {
			damage = self:addTemporaryValue("night_terror", t.getDamageBonus(self, t)),
			particle = self:addParticles(Particles.new("ultrashield", 1, {rm=60, rM=130, gm=20, gM=110, bm=90, bM=130, am=70, aM=180, radius=0.4, density=60, life=14, instop=20})),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("night_terror", p.damage)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamageBonus(self, t)
		local summon = t.getSummonTime(self, t)
		return ([[Increases your damage and resistance penetration on sleeping targets by %d%%.  Additionally every time you slay a sleeping target a Night Terror will be summoned for %d turns.
		The Night Terror's stats will scale with your mindpower as will the damage bonus to sleeping targets.]]):format(damage, summon)
	end,
}