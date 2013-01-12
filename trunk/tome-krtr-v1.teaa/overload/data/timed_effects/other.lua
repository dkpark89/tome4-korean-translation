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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "INFUSION_COOLDOWN", image = "effects/infusion_cooldown.png",
	desc = "Infusion Saturation",
	kr_display_name = "주입 포화",
	long_desc = function(self, eff) return ("The more you use infusions, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "other",
	subtype = { infusion=true },
	status = "detrimental",
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "RUNE_COOLDOWN", image = "effects/rune_cooldown.png",
	desc = "Runic Saturation",
	kr_display_name = "룬 포화",
	long_desc = function(self, eff) return ("The more you use runes, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "other",
	subtype = { rune=true },
	status = "detrimental",
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "TAINT_COOLDOWN", image = "effects/tainted_cooldown.png",
	desc = "Tainted",
	kr_display_name = "오염됨",
	long_desc = function(self, eff) return ("The more you use taints, the longer they will take to recharge (+%d cooldowns)."):format(eff.power) end,
	type = "other",
	subtype = { taint=true },
	status = "detrimental",
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { power=1 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
}

newEffect{
	name = "TIME_PRISON", image = "talents/time_prison.png",
	desc = "Time Prison",
	kr_display_name = "시간의 감옥",
	long_desc = function(self, eff) return "The target is removed from the normal time stream, unable to act but unable to take any damage. Time does not pass for this creature." end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	tick_on_timeless = true,
	parameters = {},
	on_gain = function(self, err) return "#Target# is removed from time!", "+Out of Time" end,
	on_lose = function(self, err) return "#Target# is returned to normal time.", "-Out of Time" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.sid = self:addTemporaryValue("time_prison", 1)
		eff.tid = self:addTemporaryValue("no_timeflow", 1)
		eff.imid = self:addTemporaryValue("status_effect_immune", 1)
		eff.particle = self:addParticles(Particles.new("time_prison", 1))
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("time_prison", eff.sid)
		self:removeTemporaryValue("no_timeflow", eff.tid)
		self:removeTemporaryValue("status_effect_immune", eff.imid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "TIME_SHIELD", image = "talents/time_shield.png",
	desc = "Time Shield",
	kr_display_name = "시간의 보호막",
	long_desc = function(self, eff) return ("The target is surrounded by a time distortion, absorbing %d/%d damage and sending it forward in time. While active all newly applied status effects durations are reduced by %d%%."):format(self.time_shield_absorb, eff.power, eff.time_reducer) end,
	type = "other",
	subtype = { time=true, shield=true },
	status = "beneficial",
	parameters = { power=10, dot_dur=5, time_reducer=20 },
	on_gain = function(self, err) return "The very fabric of time alters around #target#.", "+Time Shield" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes to normal.", "-Time Shield" end,
	on_aegis = function(self, eff, aegis)
		self.time_shield_absorb = self.time_shield_absorb + eff.power * aegis / 100
	end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		if self:attr("shield_factor") then eff.power = eff.power * (100 + self:attr("shield_factor")) / 100 end
		if self:attr("shield_dur") then eff.dur = eff.dur + self:attr("shield_dur") end
		eff.durid = self:addTemporaryValue("reduce_status_effects_time", eff.time_reducer)
		eff.tmpid = self:addTemporaryValue("time_shield", eff.power)
		--- Warning there can be only one time shield active at once for an actor
		self.time_shield_absorb = eff.power
		self.time_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield3"}, {type="shield", time_factor=2000, color={1, 1, 0.3}}))
		else
			eff.particle = self:addParticles(Particles.new("time_shield_bubble", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("reduce_status_effects_time", eff.durid)

		self:removeParticles(eff.particle)
		-- Time shield ends, setup a dot if needed
		if eff.power - self.time_shield_absorb > 0 then
			print("Time shield dot", eff.power - self.time_shield_absorb, (eff.power - self.time_shield_absorb) / eff.dot_dur)
			self:setEffect(self.EFF_TIME_DOT, eff.dot_dur, {power=(eff.power - self.time_shield_absorb) / eff.dot_dur})
		end

		self:removeTemporaryValue("time_shield", eff.tmpid)
		self.time_shield_absorb = nil
		self.time_shield_absorb_max = 0
	end,
}

newEffect{
	name = "TIME_DOT",
	desc = "Temporal Wake",
	kr_display_name = "시간의 각성",
	long_desc = function(self, eff) return ("The time distortion protecting the target has ended. All damage forwarded in time is now appearing as temporal vortexes each turn. Temporal Vortexes do %0.2f temporal damage per turn for 3 turn."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "The powerful time-altering energies come crashing down on #target#.", "+Temporal Wake" end,
	on_lose = function(self, err) return "The fabric of time around #target# returns to normal.", "-Temporal Wake" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, 3,
			DamageType.TEMPORAL, eff.power,
			0,
			5, nil,
			{type="temporal_vortex"},
			nil, true
		)
	end,
}

newEffect{
	name = "GOLEM_OFS",
	desc = "Golem out of sight",
	kr_display_name = "시야를 벗어난 골렘",
	long_desc = function(self, eff) return "The golem is out of sight of the alchemist; direct control will be lost!" end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#LIGHT_RED##Target# is out of sight of its master; direct control will break!.", "+Out of sight" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if game.player ~= self then return true end

		if eff.dur <= 1 then
			game:onTickEnd(function()
				game.logPlayer(self, "#LIGHT_RED#You lost sight of your golem for too long; direct control is broken!")
				game.player:runStop("golem out of sight")
				game.player:restStop("golem out of sight")
				game.party:setPlayer(self.summoner)
			end)
		end
	end,
}

newEffect{
	name = "CONTINUUM_DESTABILIZATION",
	desc = "Continuum Destabilization",
	kr_display_name = "불안정한 연속성",
	long_desc = function(self, eff) return ("The target has been affected by space or time manipulations and is becoming more resistant to them (+%d)."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# looks a little pale around the edges.", "+Destabilized" end,
	on_lose = function(self, err) return "#Target# is firmly planted in reality.", "-Destabilized" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the continuum_destabilization
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		-- Need to remove and re-add the continuum_destabilization
		self:removeTemporaryValue("continuum_destabilization", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("continuum_destabilization", old_eff.power)
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("continuum_destabilization", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("continuum_destabilization", eff.effid)
	end,
}

newEffect{
	name = "SUMMON_DESTABILIZATION",
	desc = "Summoning Destabilization",
	kr_display_name = "불안정한 소환",
	long_desc = function(self, eff) return ("The more the target summons creatures the longer it will take to summon more (+%d turns)."):format(eff.power) end,
	type = "other", -- Type "other" so that nothing can dispel it
	subtype = { miscellaneous=true },
	status = "detrimental",
	parameters = { power=10 },
	on_merge = function(self, old_eff, new_eff)
		-- Merge the destabilizations
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		-- Need to remove and re-add the talents CD
		self:removeTemporaryValue("talent_cd_reduction", old_eff.effid)
		old_eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -old_eff.power })
		return old_eff
	end,
	activate = function(self, eff)
		eff.effid = self:addTemporaryValue("talent_cd_reduction", { [self.T_SUMMON] = -eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_cd_reduction", eff.effid)
	end,
}

newEffect{
	name = "DAMAGE_SMEARING", image = "talents/damage_smearing.png",
	desc = "Damage Smearing",
	kr_display_name = "피해 문지르기",
	long_desc = function(self, eff) return ("Passes damage received in the present onto the future self."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "The fabric of time alters around #target#.", "+Damage Smearing" end,
	on_lose = function(self, err) return "The fabric of time around #target# stabilizes.", "-Damage Smearing" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("time_shield", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "SMEARED",
	desc = "Smeared",
	kr_display_name = "번짐",
	long_desc = function(self, eff) return ("Damage received in the past is returned as %0.2f temporal damage per turn."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is taking damage received in the past!", "+Smeared" end,
	on_lose = function(self, err) return "#Target# stops taking damage received in the past.", "-Smeared" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "PRECOGNITION", image = "talents/precognition.png",
	desc = "Precognition",
	kr_display_name = "사전 인지",
	long_desc = function(self, eff) return "You walk into the future; when the effect ends, if you are not dead, you are brought back to the past." end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		game:onTickEnd(function()
			game:chronoClone("precognition")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()
			-- Update the shader of the original player
			self:updateMainShader()
			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the spacetime continuum to a previous state!")
			game:chronoRestore("precognition", true)
			game.player.tmp[self.EFF_PRECOGNITION] = nil
			if game._chronoworlds then game._chronoworlds = nil end
			if game.player:knowTalent(game.player.T_FORESIGHT) then
				local t = game.player:getTalentFromId(game.player.T_FORESIGHT)
				t.do_precog_foresight(game.player, t)
			end
			game.player.energy.value = game.energy_to_act
			game.paused = true
		end)
	end,
}

newEffect{
	name = "SEE_THREADS", image = "talents/see_the_threads.png",
	desc = "See the Threads",
	kr_display_name = "시간흐름 보기",
	long_desc = function(self, eff) return ("You walk three different timelines, choosing the one you prefer at the end (current timeline: %d)."):format(eff.thread) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.thread = 1
		eff.max_dur = eff.dur
		game:onTickEnd(function()
			game:chronoClone("see_threads_base")
		end)
	end,
	deactivate = function(self, eff)
		game:onTickEnd(function()

			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#The see the threads spell fizzles and cancels, leaving you in this timeline.")
				return
			end

			if eff.thread < 3 then
				local worlds = game._chronoworlds

				-- Clone but not the subworlds
				game._chronoworlds = nil
				local clone = game:chronoClone()

				-- Restore the base world and resave it
				game._chronoworlds = worlds
				game:chronoRestore("see_threads_base", true)

				-- Setup next thread
				local eff = game.player:hasEffect(game.player.EFF_SEE_THREADS)
				eff.thread = eff.thread + 1
				game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the space time continuum to the start of the time threads!")

				game._chronoworlds = worlds
				game:chronoClone("see_threads_base")

				-- Add the previous thread
				game._chronoworlds["see_threads_"..(eff.thread-1)] = clone
				game.level.map:particleEmitter(game.player.x, game.player.y, 1, "rewrite_universe")
				return
			else
				game._chronoworlds.see_threads_base = nil
				local chat = Chat.new("chronomancy-see-threads", {name="See the Threads"}, self, {turns=eff.max_dur})
				chat:invoke()
			end
		end)
	end,
}

newEffect{
	name = "IMMINENT_PARADOX_CLONE",
	desc = "Imminent Paradox Clone",
	kr_display_name = "일촉즉발의 괴리적 복제",
	long_desc = function(self, eff) return "When the effect expires you'll be pulled into the past." end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
			game:onTickEnd(function()
			game:chronoClone("paradox_past")
		end)
	end,
	deactivate = function(self, eff)
		local t = self:getTalentFromId(self.T_PARADOX_CLONE)
		local base = t.getDuration(self, t) - 2
		game:onTickEnd(function()
			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#You've altered your destiny and will not be pulled into the past.")
				return
			end

			local worlds = game._chronoworlds
			-- save the players health so we can reload it
			local oldplayer = game.player

			-- Clone but not the subworlds
			game._chronoworlds = nil
			local clone = game:chronoClone()
			game._chronoworlds = worlds

			-- Move back in time, but keep the paradox_future world stored
			game:chronoRestore("paradox_past", true)
			game._chronoworlds = game._chronoworlds or {}
			game._chronoworlds["paradox_future"] = clone
			game.logPlayer(self, "#LIGHT_BLUE#You've been pulled into the past!")
			-- pass health and resources into the new timeline
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end

			-- Hack to remove the IMMINENT_PARADOX_CLONE effect in the past
			-- Note that we have to use game.player now since self refers to self from the future!
			game.player.tmp[self.EFF_IMMINENT_PARADOX_CLONE] = nil

			-- Setup the return effect
			game.player:setEffect(self.EFF_PARADOX_CLONE, base, {})
		end)
	end,
}

newEffect{
	name = "PARADOX_CLONE", image = "talents/paradox_clone.png",
	desc = "Paradox Clone",
	kr_display_name = "괴리적 복제",
	long_desc = function(self, eff) return "You've been pulled into the past." end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		-- save the players rescources so we can reload it
		local oldplayer = game.player
		game:onTickEnd(function()
			game:chronoRestore("paradox_future")
			-- Reload the player's health and resources
			game.logPlayer(game.player, "#LIGHT_BLUE#You've been returned to the present!")
			game.player.life = oldplayer.life
			for i, r in ipairs(game.player.resources_def) do
				game.player[r.short_name] = oldplayer[r.short_name]
			end
		end)
	end,
}

newEffect{
	name = "MILITANT_MIND", image = "talents/militant_mind.png",
	desc = "Militant Mind",
	kr_display_name = "투쟁적 정신",
	long_desc = function(self, eff) return ("Increases physical power, physical save, spellpower, spell save, mindpower, and mental save by %d."):format(eff.power) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", eff.power)
		eff.presid = self:addTemporaryValue("combat_physresist", eff.power)
		eff.sresid = self:addTemporaryValue("combat_spellresist", eff.power)
		eff.mresid = self:addTemporaryValue("combat_mentalresist", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
		self:removeTemporaryValue("combat_physresist", eff.presid)
		self:removeTemporaryValue("combat_spellresist", eff.sresid)
		self:removeTemporaryValue("combat_mentalresist", eff.mresid)
	end,
}

newEffect{
	name = "SEVER_LIFELINE", image = "talents/sever_lifeline.png",
	desc = "Sever Lifeline",
	kr_display_name = "생명선 절단",
	long_desc = function(self, eff) return ("The target's lifeline is being cut. When the effect ends %0.2f temporal damage will hit the target."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	parameters = {power=10000},
	on_gain = function(self, err) return "#Target#'s lifeline is being severed!", "+Sever Lifeline" end,
	deactivate = function(self, eff)
		if not eff.src or eff.src.dead then return end
		if not eff.src:hasLOS(self.x, self.y) then return end
		if eff.dur >= 1 then return end
		DamageType:get(DamageType.TEMPORAL).projector(eff.src, self.x, self.y, DamageType.TEMPORAL, eff.power)
	end,
}

newEffect{
	name = "SPACETIME_STABILITY",
	desc = "Spacetime Stability",
	kr_display_name = "시공간 안정화",
	long_desc = function(self, eff) return "Chronomancy spells cast by the target will not fail." end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "Spacetime has stabilized around #Target#.", "+Spactime Stability" end,
	on_lose = function(self, err) return "The fabric of spacetime around #Target# has returned to normal.", "-Spacetime Stability" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "FADE_FROM_TIME", image = "talents/fade_from_time.png",
	desc = "Fade From Time",
	kr_display_name = "시간에서 벗어나기",
	long_desc = function(self, eff) return ("The target is partially removed from the timeline, reducing all damage dealt by %d%%, all damage received by %d%%, and the duration of all detrimental effects by %d%%."):
	format(eff.dur * 2 + 2, eff.cur_power or eff.power, eff.cur_power or eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# has partially removed itself from the timeline.", "+Fade From Time" end,
	on_lose = function(self, err) return "#Target# has returned fully to the timeline.", "-Fade From Time" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_damage", old_eff.dmgid)
		self:removeTemporaryValue("resists", old_eff.rstid)
		self:removeTemporaryValue("reduce_status_effects_time", old_eff.durid)
		old_eff.cur_power = (new_eff.power)
		old_eff.dmgid = self:addTemporaryValue("inc_damage", {all = - old_eff.dur * 2})
		old_eff.rstid = self:addTemporaryValue("resists", {all = old_eff.cur_power})
		old_eff.durid = self:addTemporaryValue("reduce_status_effects_time", old_eff.cur_power)

		old_eff.dur = old_eff.dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		local current = eff.power * eff.dur/10
		self:setEffect(self.EFF_FADE_FROM_TIME, 1, {power = current})
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.rstid = self:addTemporaryValue("resists", { all = eff.power})
		eff.durid = self:addTemporaryValue("reduce_status_effects_time", eff.power)
		eff.dmgid = self:addTemporaryValue("inc_damage", {all = -20})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("reduce_status_effects_time", eff.durid)
		self:removeTemporaryValue("resists", eff.rstid)
		self:removeTemporaryValue("inc_damage", eff.dmgid)
	end,
}

newEffect{
	name = "SHADOW_VEIL", image = "talents/shadow_veil.png",
	desc = "Shadow Veil",
	kr_display_name = "그림자 드리우기",
	long_desc = function(self, eff) return ("You veil yourself in shadows and let them control you. While in the veil you become immune to status effects, and gain %d%% all damage reduction. Each turn you blink to a nearby foe, hitting it for %d%% darkness weapon damage. While this goes on you cannot be stopped unless you are killed, and you cannot control your character."):format(eff.res, eff.dam * 100) end,
	type = "other",
	subtype = { darkness=true },
	status = "beneficial",
	parameters = { res=10, dam=1.5 },
	on_gain = function(self, err) return "#Target# is covered in a veil of shadows!", "+Assail" end,
	on_lose = function(self, err) return "#Target# is no longer covered by shadows.", "-Assail" end,
	activate = function(self, eff)
		eff.sefid = self:addTemporaryValue("negative_status_effect_immune", 1)
		eff.resid = self:addTemporaryValue("resists", {all=eff.res})
	end,
	on_timeout = function(self, eff)
		-- Choose a target in FOV
		local acts = {}
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and self:reactionToward(act) < 0 and not act.dead then
				local sx, sy = util.findFreeGrid(act.x, act.y, 1, true, {[engine.Map.ACTOR]=true})
				if sx then acts[#acts+1] = {act, sx, sy} end
			end
		end
		if #acts == 0 then return end

		act = rng.table(acts)
		self:move(act[2], act[3], true)
		game.level.map:particleEmitter(act[2], act[3], 1, "dark")
		self:attackTarget(act[1], DamageType.DARKNESS, eff.dam) -- Attack *and* use energy
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("negative_status_effect_immune", eff.sefid)
		self:removeTemporaryValue("resists", eff.resid)
	end,
}

newEffect{
	name = "ZERO_GRAVITY", image = "effects/zero_gravity.png",
	desc = "Zero Gravity",
	kr_display_name = "무중력",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("There is no gravity here; you float in the air. Movement is three times as slow, and any melee or archery blows have a chance to knockback. Maximum encumbrance is greatly increased.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { spacetime=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	activate = function(self, eff)
		eff.encumb = self:addTemporaryValue("max_encumber", self:getMaxEncumbrance() * 20),
		self:checkEncumbrance()
		game.logPlayer(self, "#LIGHT_BLUE#You enter a zero gravity zone, beware!")
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_encumber", eff.encumb)
		self:checkEncumbrance()
	end,
}

newEffect{
	name = "CURSE_OF_CORPSES",
	desc = "Curse of Corpses",
	kr_display_name = "시체의 저주",
	short_desc = "Corpses",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {},
	getResistsUndead = function(level) return -2 * level end,
	getIncDamageUndead = function(level) return 2 + level * 2 end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getStrChange = function(level) return level end,
	getMagChange = function(level) return level end,
	getCorpselightRadius = function(level) return level + 1 end,
	getReprieveChance = function(level) return 35 + (level - 4) * 15 end,
	display_desc = function(self, eff)
		return ([[Curse of Corpses %d]]):format(eff.level)
	end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[An aura of death surrounds you. #LIGHT_BLUE#Level %d%s#WHITE#
#CRIMSON#Penalty: #WHITE#Fear of Death: %+d%% resistance against damage from the undead.
#CRIMSON#Level 1: %sPower over Death: %+d%% damage against the undead.
#CRIMSON#Level 2: %s%+d Luck, %+d Strength, %+d Magic
#CRIMSON#Level 3: %sCorpselight: Each death you cause leaves behind a trace of itself, an eerie light of radius %d.
#CRIMSON#Level 4: %sReprieve from Death: Humanoids you slay have a %d%% chance to rise to fight beside you as ghouls for 6 turns.]]):format(
		level, self.cursed_aura == self.EFF_CURSE_OF_CORPSES and ", Cursed Aura" or "",
		def.getResistsUndead(level),
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getIncDamageUndead(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getStrChange(math.max(level, 2)), def.getMagChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getCorpselightRadius(math.max(level, 3)),
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getReprieveChance(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Fear of Death
		eff.resistsUndeadId = self:addTemporaryValue("resists_actor_type", { ["undead"] = def.getResistsUndead(level) })

		-- level 1: Power over Death
		if bonusLevel < 1 then return end
		eff.incDamageUndeadId = self:addTemporaryValue("inc_damage_actor_type", { ["undead"] = def.getIncDamageUndead(level) })

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_STR] = def.getStrChange(level),
			[Stats.STAT_MAG] = def.getMagChange(level),
		})

		-- level 3: Corpselight
		-- level 4: Reprieve from Death
	end,
	deactivate = function(self, eff)
		if eff.resistsUndeadId then self:removeTemporaryValue("resists_actor_type", eff.resistsUndeadId) end
		if eff.incDamageUndeadId then self:removeTemporaryValue("inc_damage_actor_type", eff.incDamageUndeadId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	doCorpselight = function(self, eff, target)
		if math.min(eff.unlockLevel, eff.level) >= 3 then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES]
			local tg = {type="ball", 10, radius=def.getCorpselightRadius(eff.level), talent=t}
			self:project(tg, target.x, target.y, DamageType.LITE, 1)
			game.logSeen(target, "#F53CBE#%s's remains glow with a strange light.", target.name:capitalize())
		end
	end,
	npcWalkingCorpse = {
		name = "walking corpse",
		display = "z", color=colors.GREY, image="npc/undead_ghoul_ghoul.png",
		type = "undead", subtype = "ghoul",
		desc = [[This corpse was recently alive but moves as though it is just learning to use its body.]],
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
		no_drops = true,
		autolevel = "ghoul",
		level_range = {1, nil}, exp_worth = 0,
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=14, dex=12, mag=10, con=12 },
		rank = 2,
		size_category = 3,
		infravision = 10,
		resolvers.racial(),
		resolvers.tmasteries{ ["technique/other"]=1, },
		open_door = true,
		blind_immune = 1,
		see_invisible = 2,
		undead = 1,
		max_life = resolvers.rngavg(90,100),
		combat_armor = 2, combat_def = 7,
		resolvers.talents{
			T_STUN={base=1, every=10, max=5},
			T_BITE_POISON={base=1, every=10, max=5},
			T_ROTTING_DISEASE={base=1, every=10, max=5},
		},
		combat = { dam=resolvers.levelup(10, 1, 1), atk=resolvers.levelup(5, 1, 1), apr=3, dammod={str=0.6} },
	},
	doReprieveFromDeath = function(self, eff, target)
		local def = self.tempeffect_def[self.EFF_CURSE_OF_CORPSES]
		if math.min(eff.unlockLevel, eff.level) >= 4 and target.type == "humanoid" and rng.percent(def.getReprieveChance(eff.level)) then
			if not self:canBe("summon") then return end

			local x, y = target.x, target.y
			local m = require("mod.class.NPC").new(def.npcWalkingCorpse)
			m.faction = self.faction
			m.summoner = self
			m.summoner_gain_exp = true
			m.summon_time = 6
			m:resolve() m:resolve(nil, true)
			m:forceLevelup(math.max(1, self.level - 2))
			game.zone:addEntity(game.level, m, "actor", x, y)

			-- Add to the party
			if self.player then
				m.remove_from_party_on_death = true
				game.party:addMember(m, {control="no", type="summon", title="Summon"})
			end

			game.level.map:particleEmitter(x, y, 1, "slime")

			game.logSeen(target, "#F53CBE#The corpse of the %s pulls itself up to fight for you.", target.name)
			game:playSoundNear(who, "talents/slime")

			return true
		else
			return false
		end
	end,
}

newEffect{
	name = "CURSE_OF_MADNESS",
	desc = "Curse of Madness",
	kr_display_name = "광기의 저주",
	short_desc = "Madness",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {},
	getMindResistChange = function(level) return -level * 3 end,
	getConfusionImmuneChange = function(level) return -level * 0.04 end,
	getCombatCriticalPowerChange = function(level) return level * 3 end,
	getOffHandMultChange = function(level) return level * 4 end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getDexChange = function(level) return -1 + level * 2 end,
	getManiaDamagePercent = function(level) return 16 - (level - 4) * 3 end,
	display_desc = function(self, eff)
		return ([[Curse of Madness %d]]):format(eff.level)
	end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[You feel your grip on reality slipping. #LIGHT_BLUE#Level %d%s#WHITE#
#CRIMSON#Penalty: #WHITE#Fractured Sanity: %+d%% Mind Resistance, %+d%% Confusion Immunity
#CRIMSON#Level 1: %sUnleashed: %+d%% critical damage, %+d%% off-hand weapon damage
#CRIMSON#Level 2: %s%+d Luck, %+d Dexterity
#CRIMSON#Level 3: %sConspirator: When you are confused, any foe that hits you or that you hit in melee becomes confused.
#CRIMSON#Level 4: %sMania: Any time you take more than %d%% damage during a single turn, the remaining cooldown of one of your talents is reduced by 1.]]):format(
		level, self.cursed_aura == self.EFF_CURSE_OF_MADNESS and ", Cursed Aura" or "",
		def.getMindResistChange(level), def.getConfusionImmuneChange(level) * 100,
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getCombatCriticalPowerChange(math.max(level, 1)), def.getOffHandMultChange(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getDexChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#",
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getManiaDamagePercent(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS], eff.level, math.min(eff.unlockLevel, eff.level)

		-- reset stored values
		eff.last_life = self.life

		-- penalty: Fractured Sanity
		eff.mindResistId = self:addTemporaryValue("resists", { [DamageType.MIND] = def.getMindResistChange(level) })
		eff.confusionImmuneId = self:addTemporaryValue("confusion_immune", def.getConfusionImmuneChange(level) )

		-- level 1: Twisted Mind
		if bonusLevel < 1 then return end
		eff.getCombatCriticalPowerChangeId = self:addTemporaryValue("combat_critical_power", def.getCombatCriticalPowerChange(level) )

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_DEX] = def.getDexChange(level),
		})

		-- level 3: Conspirator
		-- level 4: Mania
	end,
	deactivate = function(self, eff)
		if eff.mindResistId then self:removeTemporaryValue("resists", eff.mindResistId) end
		if eff.confusionImmuneId then self:removeTemporaryValue("confusion_immune", eff.confusionImmuneId) end
		if eff.getCombatCriticalPowerChangeId then self:removeTemporaryValue("combat_critical_power", eff.getCombatCriticalPowerChangeId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_timeout = function(self, eff)
		-- mania
		if math.min(eff.unlockLevel, eff.level) >= 4 and eff.life ~= eff.last_life then
			-- occurs pretty close to actual cooldowns in Actor.Act
			local def = self.tempeffect_def[self.EFF_CURSE_OF_MADNESS]
			if not self:attr("stunned") and eff.last_life and 100 * (eff.last_life - self.life) / self.max_life >= def.getManiaDamagePercent(eff.level) then
				-- perform mania
				local list = {}
				for tid, cd in pairs(self.talents_cd) do
					if cd and cd > 0 then
						list[#list + 1] = tid
					end
				end
				if #list == 0 then return end

				local tid = rng.table(list)
				local t = self:getTalentFromId(tid)

				self.changed = true
				self.talents_cd[tid] = self.talents_cd[tid] - 1
				if self.talents_cd[tid] <= 0 then
					self.talents_cd[tid] = nil
					if self.onTalentCooledDown then self:onTalentCooledDown(tid) end
				end
				game.logSeen(self, "#F53CBE#%s's mania hastens %s.", self.name:capitalize(), t.name)
			end
			eff.last_life = self.life
		end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	doConspirator = function(self, eff, target)
		if math.min(eff.unlockLevel, eff.level) >= 3 and self:attr("confused") and target:canBe("confusion") then
			target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			game.logSeen(self, "#F53CBE#%s spreads confusion to %s.", self.name:capitalize(), target.name)
		end
	end,
}

newEffect{
	name = "CURSE_OF_SHROUDS",
	desc = "Curse of Shrouds",
	kr_display_name = "수의의 저주",
	short_desc = "Shrouds",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {},
	getShroudIncDamageChange = function(level) return -(4 + level * 2) end,
	getResistsDarknessChange = function(level) return level * 4 end,
	getResistsCapDarknessChange = function(level) return level * 4 end,
	getSeeInvisible = function(level) return 2 + level * 2 end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getConChange = function(level) return -1 + level * 2 end,
	getShroudResistsAllChange = function(level) return (level - 1) * 5 end,
	display_desc = function(self, eff)
		return ([[Curse of Shrouds %d]]):format(eff.level)
	end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[A shroud of darkness seems to fall across your path. #LIGHT_BLUE#Level %d%s#WHITE#
#CRIMSON#Penalty: #WHITE#Shroud of Weakness: Small chance of becoming enveloped in a Shroud of Weakness (reduces damage dealt by %d%%) for 4 turns.
#CRIMSON#Level 1: %sNightwalker: %+d Darkness Resistance, %+d%% Max Darkness Resistance, %+d See Invisible
#CRIMSON#Level 2: %s%+d Luck, %+d Constitution
#CRIMSON#Level 3: %sShroud of Passing: Your form seems to fade as you move, reducing all damage taken by %d%% for 1 turn after movement.
#CRIMSON#Level 4: %sShroud of Death: The power of every kill seems to envelop you like a shroud, reducing all damage taken by %d%% for 3 turns.]]):format(
		level, self.cursed_aura == self.EFF_CURSE_OF_SHROUDS and ", Cursed Aura" or "",
		-def.getShroudIncDamageChange(level),
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getResistsDarknessChange(math.max(level, 1)), def.getResistsCapDarknessChange(math.max(level, 1)), def.getSeeInvisible(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getConChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getShroudResistsAllChange(math.max(level, 3)),
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getShroudResistsAllChange(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Shroud of Weakness

		-- level 1: Nightwalker
		if bonusLevel < 1 then return end
		eff.resistsDarknessId = self:addTemporaryValue("resists", { [DamageType.DARKNESS] = def.getResistsDarknessChange(level) })
		eff.resistsCapDarknessId = self:addTemporaryValue("resists_cap", { [DamageType.DARKNESS]= def.getResistsCapDarknessChange(level) })
		eff.seeInvisibleId = self:addTemporaryValue("see_invisible", def.getSeeInvisible(level))

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_CON] = def.getConChange(level),
		})

		-- level 3: Shroud of Passing
		-- level 4: Shroud of Death
	end,
	deactivate = function(self, eff)
		if eff.resistsDarknessId then self:removeTemporaryValue("resists", eff.resistsDarknessId) end
		if eff.resistsCapDarknessId then self:removeTemporaryValue("resists_cap", eff.resistsCapDarknessId) end
		if eff.seeInvisibleId then self:removeTemporaryValue("see_invisible", eff.seeInvisibleId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end

		if self:hasEffect(self.EFF_SHROUD_OF_WEAKNESS) then self:removeEffect(self.EFF_SHROUD_OF_WEAKNESS) end
		if self:hasEffect(self.EFF_SHROUD_OF_PASSING) then self:removeEffect(self.EFF_SHROUD_OF_PASSING) end
		if self:hasEffect(self.EFF_SHROUD_OF_DEATH) then self:removeEffect(self.EFF_SHROUD_OF_DEATH) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	on_timeout = function(self, eff)
		-- Shroud of Weakness
		if rng.chance(100) then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS]
			self:setEffect(self.EFF_SHROUD_OF_WEAKNESS, 4, { power=def.getShroudIncDamageChange(eff.level) })
		end
	end,
	doShroudOfPassing = function(self, eff)
		-- called after energy is used; eff.moved may be set from movement
		local effShroud = self:hasEffect(self.EFF_SHROUD_OF_PASSING)
		if math.min(eff.unlockLevel, eff.level) >= 3 and eff.moved then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS]
			if not effShroud then self:setEffect(self.EFF_SHROUD_OF_PASSING, 1, { power=def.getShroudResistsAllChange(eff.level) }) end
		else
			if effShroud then self:removeEffect(self.EFF_SHROUD_OF_PASSING) end
		end
		eff.moved = false
	end,
	doShroudOfDeath = function(self, eff)
		if math.min(eff.unlockLevel, eff.level) >= 4 and not self:hasEffect(self.EFF_SHROUD_OF_DEATH) then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_SHROUDS]
			self:setEffect(self.EFF_SHROUD_OF_DEATH, 3, { power=def.getShroudResistsAllChange(eff.level) })
		end
	end,
}

newEffect{
	name = "SHROUD_OF_WEAKNESS",
	desc = "Shroud of Weakness",
	kr_display_name = "약화의 수의",
	long_desc = function(self, eff) return ("The target is enveloped in a shroud that seems to hang upon it like a heavy burden. (Reduces damage dealt by %d%%)."):format(-eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "detrimental",
	no_stop_resting = true,
	parameters = { power=10 },
	activate = function(self, eff)
		eff.incDamageId = self:addTemporaryValue("inc_damage", {all = eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.incDamageId)
	end,
}

newEffect{
	name = "SHROUD_OF_PASSING",
	desc = "Shroud of Passing",
	kr_display_name = "흐려짐의 수의",
	long_desc = function(self, eff) return ("The target is enveloped in a shroud that seems to not only obscure it but also to fade its form (+%d%% resist all)."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	decrease = 0,
	parameters = { power=10 },
	activate = function(self, eff)
		eff.resistsId = self:addTemporaryValue("resists", { all = eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistsId)
	end,
}

newEffect{
	name = "SHROUD_OF_DEATH",
	desc = "Shroud of Death",
	kr_display_name = "죽음의 수의",
	long_desc = function(self, eff) return ("The target is enveloped in a shroud that seems to not only obscure it but also to fade its form (+%d%% resist all)."):format(eff.power) end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.resistsId = self:addTemporaryValue("resists", { all = eff.power })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistsId)
	end,
}

newEffect{
	name = "CURSE_OF_NIGHTMARES",
	desc = "Curse of Nightmares",
	kr_display_name = "악몽의 저주",
	short_desc = "Nightmares",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {},
	getVisionsReduction = function(level) return 5 + level * 4 end,
	getResistsPhysicalChange = function(level) return 1 + level end,
	getResistsCapPhysicalChange = function(level) return 1 + level end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getWilChange = function(level) return -1 + level * 2 end,
	getBaseSuffocateAirChange = function(level) return 10 + (level - 3) * 3 end,
	getSuffocateAirChange = function(level) return 3 + (level - 3) * 2 end,
	getNightmareChance = function(level) return 0.1 + (level -4) * 0.05 end,
	getNightmareRadius = function(level) return 5 + (level - 4) * 2 end,
	display_desc = function(self, eff)
		if math.min(eff.unlockLevel, eff.level) >= 4 then
			return ([[Curse of Nightmares %d: %d%%]]):format(eff.level, eff.nightmareChance or 0)
		else
			return ([[Curse of Nightmares %d]]):format(eff.level)
		end
	end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[Horrible visions fill your mind. #LIGHT_BLUE#Level %d%s#WHITE#
#CRIMSON#Penalty: #WHITE#Plagued by Visions: Your mental save has a 20%% chance to be reduced by %d%% when tested.
#CRIMSON#Level 1: %sRemoved from Reality: %+d Physical Resistance, %+d Maximum Physical Resistance
#CRIMSON#Level 2: %s%+d Luck, %+d Willpower
#CRIMSON#Level 3: %sSuffocate: Your touch instills a horror that suffocates any weak, non-elite foe that hits you or that you hit in melee. At 3 levels below yours they lose %d air and an additional %d air for each level below that.
#CRIMSON#Level 4: %sNightmare: Each time you are damaged by a foe there is %d%% chance of triggering a radius %d nightmare (slow effects, hateful whispers, and summoned Terrors) for 8 turns. This chance grows each time you are struck.]]):format(
		level, self.cursed_aura == self.EFF_CURSE_OF_NIGHTMARES and ", Cursed Aura" or "",
		def.getVisionsReduction(level),
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getResistsPhysicalChange(math.max(level, 1)), def.getResistsCapPhysicalChange(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getWilChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getBaseSuffocateAirChange(math.max(level, 3)), def.getSuffocateAirChange(math.max(level, 3)),
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", eff.nightmareChance or 0, def.getNightmareRadius(math.max(level, 4)), def.getNightmareChance(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Plagued by Visions

		-- level 1: Removed from Reality
		if bonusLevel < 1 then return end
		eff.resistsPhysicalId = self:addTemporaryValue("resists", { [DamageType.PHYSICAL]= def.getResistsPhysicalChange(level) })
		eff.resistsCapPhysicalId = self:addTemporaryValue("resists_cap", { [DamageType.PHYSICAL]= def.getResistsCapPhysicalChange(level) })

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_WIL] = def.getWilChange(level),
		})

		-- level 3: Suffocate
		-- level 4: Nightmare
	end,
	deactivate = function(self, eff)
		if eff.resistsPhysicalId then self:removeTemporaryValue("resists", eff.resistsPhysicalId); end
		if eff.resistsCapPhysicalId then self:removeTemporaryValue("resists_cap", eff.resistsCapPhysicalId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	doSuffocate = function(self, eff, target)
		if math.min(eff.unlockLevel, eff.level) >= 3 then
			if target and target.rank <= 2 and target.level <= self.level - 3 and not target:attr("no_breath") and not target:attr("invulnerable") then
				local def = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES]
				local airLoss = def.getBaseSuffocateAirChange(eff.level) + (self.level - target.level - 3) * def.getSuffocateAirChange(eff.level)
				game.logSeen(self, "#F53CBE#%s begins to choke from a suffocating curse. (-%d air)", target.name, airLoss)
				target:suffocate(airLoss, self, "suffocated from a curse")
			end
		end
	end,
	npcTerror = {
		name = "terror",
		display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
		blood_color = colors.BLUE,
		desc = "A formless terror that seems to cut through the air, and its victims, like a knife.",
		type = "horror", subtype = "eldritch",
		rank = 2,
		size_category = 2,
		body = { INVEN = 10 },
		no_drops = true,
		autolevel = "warrior",
		level_range = {1, nil}, exp_worth = 0,
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=16, dex=20, wil=15, con=15 },
		infravision = 10,
		can_pass = {pass_wall=20},
		resists = {[DamageType.LIGHT] = -50, [DamageType.DARKNESS] = 100},
		silent_levelup = true,
		no_breath = 1,
		fear_immune = 1,
		blind_immune = 1,
		infravision = 10,
		see_invisible = 80,
		max_life = resolvers.rngavg(50, 80),
		combat_armor = 1, combat_def = 10,
		combat = { dam=resolvers.levelup(resolvers.rngavg(15,20), 1, 1.1), atk=resolvers.rngavg(5,15), apr=5, dammod={str=1} },
		resolvers.talents{
		},
	},
	doNightmare = function(self, eff)
		if math.min(eff.unlockLevel, eff.level) >= 4 then
			-- build chance for a nightmare
			local def = self.tempeffect_def[self.EFF_CURSE_OF_NIGHTMARES]
			eff.nightmareChance = (eff.nightmareChance or 0) + def.getNightmareChance(eff.level)

			-- invoke the nightmare
			if rng.percent(eff.nightmareChance) then
				local radius = def.getNightmareRadius(eff.level)

				-- make sure there is at least one creature to torment
				local seen = false
				core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, radius,
					function(_, x, y) return game.level.map:opaque(x, y) end,
					function(_, x, y)
						local actor = game.level.map(x, y, game.level.map.ACTOR)
						if actor and actor ~= self and self:reactionToward(actor) < 0 then seen = true end
					end, nil)
				if not seen then return false end

				-- start the nightmare: slow, hateful whisper, random Terrors (minor horrors)
				eff.nightmareChance = 0
				game.level.map:addEffect(self,
					self.x, self.y, 8,
					DamageType.NIGHTMARE, 1,
					radius,
					5, nil,
					engine.Entity.new{alpha=80, display='', color_br=134, color_bg=60, color_bb=134},
					function(e)
						-- attempt one summon per turn
						if not e.src:canBe("summon") then return end

						local def = e.src.tempeffect_def[e.src.EFF_CURSE_OF_NIGHTMARES]

						-- random location nearby..not too picky and these things can move through walls but won't start there
						local locations = {}
						local grids = core.fov.circle_grids(e.x, e.y, e.radius, true)
						for lx, yy in pairs(grids) do for ly, _ in pairs(grids[lx]) do
							if not game.level.map:checkAllEntities(lx, ly, "block_move") then
								locations[#locations+1] = {lx, ly}
							end
						end end
						if #locations == 0 then return true end
						local location = rng.table(locations)

						local m = require("mod.class.NPC").new(def.npcTerror)
						m.faction = e.src.faction
						m.summoner = e.src
						m.summoner_gain_exp = true
						m.summon_time = 3
						m:resolve() m:resolve(nil, true)
						m:forceLevelup(e.src.level)

						-- Add to the party
						if e.src.player then
							m.remove_from_party_on_death = true
							game.party:addMember(m, {control="no", type="nightmare", title="Nightmare"})
						end

						game.zone:addEntity(game.level, m, "actor", location[1], location[2])

						return true
					end,
					false, false)

				game.logSeen(self, "#F53CBE#The air around %s grows cold and terrifying shapes begin to coalesce. A nightmare has begun.", self.name:capitalize())
				game:playSoundNear(self, "talents/cloud")
			end
		end
	end,
}

newEffect{
	name = "CURSE_OF_MISFORTUNE",
	desc = "Curse of Misfortune",
	kr_display_name = "불운의 저주",
	short_desc = "Misfortune",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {},
	getCombatDefChange = function(level) return level * 2 end,
	getCombatDefRangedChange = function(level) return level end,
	getLckChange = function(eff, level)
		if eff.unlockLevel >= 5 or level <= 2 then return -1 end
		if level <= 3 then return -2 else return -3 end
	end,
	getCunChange = function(level) return -1 + level * 2 end,
	getDeviousMindChange = function(level) return 20 + 15 * (level - 3) end,
	getUnfortunateEndChance = function(level) return 30 + (level - 4) * 10 end,
	getUnfortunateEndIncrease = function(level) return 40 + (level - 4) * 20 end,
	display_desc = function(self, eff)
		return ([[Curse of Misfortune %d]]):format(eff.level)
	end,
	long_desc = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MISFORTUNE], eff.level, math.min(eff.unlockLevel, eff.level)

		return ([[Mayhem and destruction seem to follow you. #LIGHT_BLUE#Level %d%s#WHITE#
#CRIMSON#Penalty: #WHITE#Lost Fortune: You seem to find less gold in your journeys.
#CRIMSON#Level 1: %sMissed Opportunities: %+d Defense, +%d Ranged Defense
#CRIMSON#Level 2: %s%+d Luck, %+d Cunning
#CRIMSON#Level 3: %sDevious Mind: You have an affinity for seeing the devious plans of others (+%d%% chance to avoid traps).
#CRIMSON#Level 4: %sUnfortunate End: There is a %d%% chance that the damage you deal will increase by %d%% if it is enough to kill your opponent.]]):format(
		level, self.cursed_aura == self.EFF_CURSE_OF_MISFORTUNE and ", Cursed Aura" or "",
		bonusLevel >= 1 and "#WHITE#" or "#GREY#", def.getCombatDefChange(math.max(level, 1)), def.getCombatDefRangedChange(math.max(level, 1)),
		bonusLevel >= 2 and "#WHITE#" or "#GREY#", def.getLckChange(eff, math.max(level, 2)), def.getCunChange(math.max(level, 2)),
		bonusLevel >= 3 and "#WHITE#" or "#GREY#", def.getDeviousMindChange(math.max(level, 3)),
		bonusLevel >= 4 and "#WHITE#" or "#GREY#", def.getUnfortunateEndChance(math.max(level, 4)), def.getUnfortunateEndIncrease(math.max(level, 4)))
	end,
	activate = function(self, eff)
		local def, level, bonusLevel = self.tempeffect_def[self.EFF_CURSE_OF_MISFORTUNE], eff.level, math.min(eff.unlockLevel, eff.level)

		-- penalty: Lost Fortune
		eff.moneyValueMultiplierId = self:addTemporaryValue("money_value_multiplier", 0.5 - level * 0.05)

		-- level 1: Missed Shot
		if bonusLevel < 1 then return end
		eff.combatDefId = self:addTemporaryValue("combat_def", def.getCombatDefChange(level))
		eff.combatDefRangedId = self:addTemporaryValue("combat_def_ranged", def.getCombatDefRangedChange(level))

		-- level 2: stats
		if bonusLevel < 2 then return end
		eff.incStatsId = self:addTemporaryValue("inc_stats", {
			[Stats.STAT_LCK] = def.getLckChange(eff, level),
			[Stats.STAT_CUN] = def.getCunChange(level),
		})

		-- level 3: Devious Mind
		if bonusLevel < 3 then return end
		eff.trapAvoidanceId = self:addTemporaryValue("trap_avoidance", 50)

		-- level 4: Unfortunate End
	end,
	deactivate = function(self, eff)
		if eff.moneyValueMultiplierId then self:removeTemporaryValue("money_value_multiplier", eff.moneyValueMultiplierId) end
		if eff.combatDefId then self:removeTemporaryValue("combat_def", eff.combatDefId) end
		if eff.combatDefRangedId then self:removeTemporaryValue("combat_def_ranged", eff.combatDefRangedId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
		if eff.trapAvoidanceId then self:removeTemporaryValue("trap_avoidance", eff.trapAvoidanceId) end
	end,
	on_merge = function(self, old_eff, new_eff) return old_eff end,
	doUnfortunateEnd = function(self, eff, target, dam)
		if math.min(eff.unlockLevel, eff.level) >=4 then
			local def = self.tempeffect_def[self.EFF_CURSE_OF_MISFORTUNE]
			if target.life - dam > 0 and rng.percent(def.getUnfortunateEndChance(eff.level)) then
				local multiplier = 1 + def.getUnfortunateEndIncrease(eff.level) / 100
				if target.life - dam * multiplier <= 0 then
					-- unfortunate end! note that this does not kill if target.die_at < 0
					dam = dam * multiplier
					if target.life - dam <= target.die_at then
						game.logSeen(target, "#F53CBE#%s suffers an unfortunate end.", target.name:capitalize())
					else
						game.logSeen(target, "#F53CBE#%s suffers an unfortunate blow.", target.name:capitalize())
					end
				end
			end
		end

		return dam
	end,
}

newEffect{
	name = "RELOADING", image = "talents/reload.png",
	desc = "Reloading",
	kr_display_name = "재장전",
	long_desc = function(self, eff) return ("Reloading ammo.") end,
	decrease = 0,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff) game.logPlayer(self, "#LIGHT_BLUE#You begin reloading.") end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		for i = 1, eff.shots_per_turn do
			eff.ammo.combat.shots_left = eff.ammo.combat.shots_left + 1
			if eff.ammo.combat.shots_left >= eff.ammo.combat.capacity then
				game.logPlayer(self, "Your %s is full.", eff.ammo.name)
				self:breakReloading()
				break
			end
		end
	end,
}

newEffect{
	name = "PROB_TRAVEL_UNSTABLE", image = "talents/probability_travel.png",
	desc = "Time Prison",
	kr_display_name = "시간의 감옥",
	long_desc = function(self, eff) return "The target has recently blinked through a wall using probability travel." end,
	type = "other",
	subtype = { time=true, space=true },
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("prob_travel_deny", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("prob_travel_deny", eff.iid)
	end,
}

newEffect{
	name = "HEIGHTEN_FEAR", image = "talents/heighten_fear.png",
	desc = "Heighten Fear",
	kr_display_name = "향상된 공포",
	long_desc = function(self, eff) return ("The target is in a state of growing fear. If they spend %d more turns in a range or %d and in sight of the source of this fear (%s), they will be subjected to a new fear."):
	format(eff.turns_left, eff.range, eff.source.name) end,
	type = "other",
	subtype = { fear=true },
	status = "detrimental",
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = { },
	on_merge = function(self, old_eff, new_eff)
		old_eff.source = new_eff.source
		old_eff.range = new_eff.range

		return old_eff
	end,
	on_timeout = function(self, eff)
		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		if tInstillFear.hasEffect(eff.source, tInstillFear, self) then
			if core.fov.distance(self.x, self.y, eff.source.x, eff.source.y) <= eff.range and self:hasLOS(eff.source.x, eff.source.y) then
				eff.turns_left = eff.turns_left - 1
			end
			if eff.turns_left <= 0 then
				eff.turns_left = eff.turns
				if rng.percent(eff.chance or 100) then
					eff.chance = (eff.chance or 100) - 10
					game.logSeen(self, "%s succumbs to heightening fears!", self.name:capitalize())
					tInstillFear.applyEffect(eff.source, tInstillFear, self)
				else
					game.logSeen(self, "%s feels a little less afraid!", self.name:capitalize())
				end
			end
		else
			-- no more fears
			self:removeEffect(self.EFF_HEIGHTEN_FEAR, false, true)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "CURSED_FORM", image = "talents/seethe.png",
	desc = "Cursed Form",
	kr_display_name = "저주받은 신체",
	type = "other",
	subtype = { curse=true },
	status = "beneficial",
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = {},
	long_desc = function(self, eff)
		local desc = "The target's unnatural body has responded to damage taken."
		if (eff.incDamageChange or 0) > 0 then
			desc = desc..(" All damage that the target inflicts is increased by %d%%."):format(eff.incDamageChange)
		end
		if (eff.statChange or 0) > 0 then
			desc = desc..(" Strength and Willpower are increased by %d. Poisons and diseases have a %d%% chance of being neutralized each turn."):format(eff.statChange, eff.neutralizeChance)
		end
		return desc
	end,
	activate = function(self, eff)
		-- first on_timeout is ignored because it is applied immediately
		eff.firstHit = true
		eff.increase = 1
		self.tempeffect_def[self.EFF_CURSED_FORM].updateEffect(self, eff)

		game.level.map:particleEmitter(self.x, self.y, 1, "cursed_form", {power=eff.increase})
	end,
	deactivate = function(self, eff)
		if eff.incDamageId then
			self:removeTemporaryValue("inc_damage", eff.incDamageId)
			eff.incDamageId = nil
		end
		if eff.incStatsId then
			self:removeTemporaryValue("inc_stats", eff.incStatsId)
			eff.incStatsId = nil
		end
	end,
	do_onTakeHit = function(self, eff, dam)
		eff.hit = true
	end,
	updateEffect = function(self, eff)
		local tSeethe = self:getTalentFromId(self.T_SEETHE)
		local tGrimResolve = self:getTalentFromId(self.T_GRIM_RESOLVE)
		if tSeethe then
			eff.incDamageChange = tSeethe.getIncDamageChange(self, tSeethe, eff.increase)
		end
		if tGrimResolve then
			eff.statChange = tGrimResolve.getStatChange(self, tGrimResolve, eff.increase)
			eff.neutralizeChance = tGrimResolve.getNeutralizeChance(self, tGrimResolve)
		end

		if eff.incDamageId then
			self:removeTemporaryValue("inc_damage", eff.incDamageId)
			eff.incDamageId = nil
		end
		if eff.incDamageChange > 0 then
			eff.incDamageId = self:addTemporaryValue("inc_damage", {all = eff.incDamageChange})
		end
		if eff.incStatsId then
			self:removeTemporaryValue("inc_stats", eff.incStatsId)
			eff.incStatsId = nil
		end
		if eff.statChange > 0 then
			eff.incStatsId = self:addTemporaryValue("inc_stats", { [Stats.STAT_STR] = eff.statChange, [Stats.STAT_WIL] = eff.statChange })
		end
	end,
	on_timeout = function(self, eff)
		if eff.firstHit then
			eff.firstHit = nil
			eff.hit = false
		elseif eff.hit then
			if eff.increase < 5 then
				eff.increase = eff.increase + 1
				self.tempeffect_def[self.EFF_CURSED_FORM].updateEffect(self, eff)

				game.level.map:particleEmitter(self.x, self.y, 1, "cursed_form", {power=eff.increase})
			end
			eff.hit = false
		else
			eff.increase = eff.increase - 1
			if eff.increase == 0 then
				self:removeEffect(self.EFF_CURSED_FORM, false, true)
			else
				self.tempeffect_def[self.EFF_CURSED_FORM].updateEffect(self, eff)
			end
		end
	end,
}

newEffect{
	name = "FADED", image = "talents/shadow_fade.png",
	desc = "Faded",
	kr_display_name = "흐려짐",
	long_desc = function(self, eff) return "The target has faded and is no longer taking damage." end,
	type = "other",
	subtype = { },
	status = "beneficial",
	on_gain = function(self, err) return "#Target# fades!", "+Faded" end,
	parameters = {},
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.imid = self:addTemporaryValue("status_effect_immune", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("status_effect_immune", eff.imid)
	end,
	on_timeout = function(self, eff)
		-- always remove
		return true
	end,
}

newEffect{
	name = "POSSESSION", image = "talents/possess.png",
	desc = "Psionic Consume",
	kr_display_name = "염동적 소모",
	long_desc = function(self, eff) return "This creature's mind has been destroyed and a possessor is now controlling the husk. However, the intense psionic energies are burning the body away, and it will soon disappear." end,
	type = "other",
	subtype = { psionic=true, possess=true },
	status = "detrimental",
	no_stop_resting = true,
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		self.summoner = nil
		self:die(self)
	end,
}

-- Borrowed Time and the Borrowed Time stun effect
newEffect{
	name = "HIGHBORN_S_BLOOM", image = "talents/highborn_s_bloom.png",
	desc = "Highborn's Bloom",
	kr_display_name = "꽃피운 고귀함",
	long_desc = function(self, eff) return "The target is using talents without consuming resources." end,
	type = "other",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("zero_resource_cost", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("zero_resource_cost", eff.tmpid)
	end,
}

newEffect{
	name = "VICTORY_RUSH_ZIGUR", image = "talents/arcane_destruction.png",
	desc = "Victory Rush",
	kr_display_name = "승리의 돌진",
	long_desc = function(self, eff) return "The thrill of victory makes this creature invulnerable." end,
	type = "other",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("invulnerable", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.tmpid)
	end,
}

newEffect{
	name = "SOLIPSISM", image = "talents/solipsism.png",
	desc = "Solipsism",
	kr_display_name = "유아론",
	long_desc = function(self, eff) return ("This creature has fallen into a solipsistic state and is caught up in its own egoic thoughts (-%d%% global speed)."):format(eff.power * 100) end,
	type = "other",
	subtype = { psionic=true },
	status = "detrimental",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "CLARITY", image = "talents/clarity.png",
	desc = "Clarity",
	kr_display_name = "명석",
	long_desc = function(self, eff) return ("The creature has found a state of clarity and sees the world for what it is (+%d%% global speed)."):format(eff.power * 100) end,
	type = "other",
	subtype = { psionic=true },
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = { },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "DREAMSCAPE", image = "talents/dreamscape.png",
	desc = "Dreamscape",
	kr_display_name = "꿈의 영역",
	long_desc = function(self, eff) return ("This target has invaded %s's dreams and has gained a %d%% bonus to all damage."):format(eff.target.name, eff.power) end,
	type = "other",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power=1, projections_killed=0 },
	on_timeout = function(self, eff)
		-- Clone protection
		if not self.on_die then return end
		-- Dreamscape doesn't cooldown in the dreamscape
		self.talents_cd[self.T_DREAMSCAPE] = self.talents_cd[self.T_DREAMSCAPE] + 1
		-- Spawn every three turns, or every two for lucid dreamers
		local spawn_time = 2
		if eff.dur%spawn_time == 0 then
			local x, y = util.findFreeGrid(eff.target.x, eff.target.y, 1, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "Not enough space to summon!")
				return
			end
			-- Create a clone for later spawning
			local m = require("mod.class.NPC").new(eff.target:clone{
				shader = "shadow_simulacrum",
				shader_args = { color = {0.0, 1, 1}, base = 0.6 },
				no_drops = true,
				faction = eff.target.faction,
				summoner = eff.target, summoner_gain_exp=true,
				ai_target = {actor=nil},
				ai = "summoned", ai_real = "tactical",
				ai_state = eff.target.ai_state or { ai_move="move_complex", talent_in=1 },
				name = eff.target.name.."'s dream projection",
			})
			m.ai_state.ally_compassion = 10
			m:removeAllMOs()
			m.make_escort = nil
			m.on_added_to_level = nil
			m._rst_full = true

			m.energy.value = 0
			m.player = nil
			m.max_life = m.max_life
			m.life = util.bound(m.life, 0, m.max_life)
			if not eff.target:attr("lucid_dreamer") then
				m.inc_damage.all = (m.inc_damage.all or 0) - 50
			end
			m.forceLevelup = function() end
			m.die = nil
			m.on_die = nil
			m.on_acquire_target = nil
			m.seen_by = nil
			m.can_talk = nil
			m.puuid = nil
			m.on_takehit = nil
			m.exp_worth = 0
			m.no_inventory_access = true
			m.clone_on_hit = nil
			m.remove_from_party_on_death = true
			m.is_psychic_projection = true
			-- remove imprisonment
			m.invulnerable = m.invulnerable - 1
			m.time_prison = m.time_prison - 1
			m.no_timeflow = m.no_timeflow - 1
			m.status_effect_immune = m.status_effect_immune - 1
			m:removeParticles(eff.particle)
			m:removeTimedEffectsOnClone()

			-- track number killed
			m.on_die = function(self, who)
				local p = (who and who:hasEffect(who.EFF_DREAMSCAPE)) or (who and who.summoner and who.summoner:hasEffect(who.summoner.EFF_DREAMSCAPE))
				if p then -- For the rare instance we die after the effect ends but before the dreamscape instance closes
					p.projections_killed = p.projections_killed + 1
					game.logSeen(p.target, "#LIGHT_RED#%s writhes in agony as a fragment of its mind is destroyed!", p.target.name:capitalize())
				end
			end

			game.zone:addEntity(game.level, m, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
			game.logSeen(eff.target, "#LIGHT_BLUE#%s has spawned a dream projection to protect its mind!", eff.target.name:capitalize())

			if game.party:hasMember(eff.target) then
				game.party:addMember(m, {
					control="full",
					type="projection",
					title="Dream Self",
					orders = {target=true},
				})
				if eff.target == game.player then
					game.party:setPlayer(m)
					m:resetCanSeeCache()
				end
			end

			-- Try to insure the AI isn't attacking the invulnerable actor
			if self.ai_target and self.ai_target.actor and self.ai_target.actor:attr("invulnerable") then
				self:setTarget(nil)
			end
		end
		-- End the effect early if we've killed enough projections
		if eff.projections_killed/10 >= eff.target.life/eff.target.max_life then
			game:onTickEnd(function()
				eff.target:die(self)
				game.logSeen(eff.target, "#LIGHT_RED#%s's mind shatters into %d tiny fragments!", eff.target.name:capitalize(), eff.target.max_life)
				eff.projections_killed = 0 -- clear this out to prevent closing messages
			end)
		end
	end,
	activate = function(self, eff)
		-- Make the target invulnerable
		eff.iid = eff.target:addTemporaryValue("invulnerable", 1)
		eff.sid = eff.target:addTemporaryValue("time_prison", 1)
		eff.tid = eff.target:addTemporaryValue("no_timeflow", 1)
		eff.imid = eff.target:addTemporaryValue("status_effect_immune", 1)
		eff.target.energy.value = 0
		if core.shader.active(4) then
			eff.particle = eff.target:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", time_factor=6000, aadjust=5, color={0, 1, 1}}))
		else
			eff.particle = eff.target:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
		end

		-- Make the invader deadly
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
		eff.did = self:addTemporaryValue("lucid_dreamer", 1)
	end,
	deactivate = function(self, eff)
		-- Clone protection
		if not self.on_die then return end
		-- Remove the target's invulnerability
		eff.target:removeTemporaryValue("invulnerable", eff.iid)
		eff.target:removeTemporaryValue("time_prison", eff.sid)
		eff.target:removeTemporaryValue("no_timeflow", eff.tid)
		eff.target:removeTemporaryValue("status_effect_immune", eff.imid)
		eff.target:removeParticles(eff.particle)
		-- Remove the invaders damage bonus
		self:removeTemporaryValue("inc_damage", eff.pid)
		self:removeTemporaryValue("lucid_dreamer", eff.did)
		-- Return from the dreamscape
		game:onTickEnd(function()
			-- Collect objects
			local objs = {}
			for i = 0, game.level.map.w - 1 do for j = 0, game.level.map.h - 1 do
				for z = game.level.map:getObjectTotal(i, j), 1, -1 do
					objs[#objs+1] = game.level.map:getObject(i, j, z)
					game.level.map:removeObject(i, j, z)
				end
			end end

			local oldzone = game.zone
			local oldlevel = game.level
			local zone = game.level.source_zone
			local level = game.level.source_level

			if not self.dead then
				oldlevel:removeEntity(self)
				level:addEntity(self)
			end

			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(eff.x, eff.y, 20, true, {[Map.ACTOR]=true})
			if x1 then
				if not self.dead then
					self:move(x1, y1, true)
					self.on_die, self.dream_plane_on_die = self.dream_plane_on_die, nil
					game.level.map:particleEmitter(x1, y1, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
				else
					self.x, self.y = x1, y1
				end
			end
			local x2, y2 = util.findFreeGrid(eff.tx, eff.ty, 20, true, {[Map.ACTOR]=true})
			if not eff.target.dead then
				if x2 then
					eff.target:move(x2, y2, true)
					eff.target.on_die, eff.target.dream_plane_on_die = eff.target.dream_plane_on_die, nil
				end
				if oldlevel:hasEntity(eff.target) then oldlevel:removeEntity(eff.target) end
				level:addEntity(eff.target)
			else
				eff.target.x, eff.target.y = x2, y2
			end

			-- Add objects back
			for i, o in ipairs(objs) do
				if self.dead then
					game.level.map:addObject(eff.target.x, eff.target.y, o)
				else
					game.level.map:addObject(self.x, self.y, o)
				end
			end

			-- Remove all npcs in the dreamscape
			for uid, e in pairs(oldlevel.entities) do
				if e ~= self and e ~= eff.target and e.die then e:die() end
			end

			-- Reload MOs
			game.level.map:redisplay()
			game.level.map:recreate()
			game.uiset:setupMinimap(game.level)

			game.logPlayer(game.player, "#LIGHT_BLUE#You are brought back from the Dreamscape!")

			-- Apply Dreamscape hit
			if eff.projections_killed > 0 then
				local kills = eff.projections_killed
				eff.target:takeHit(eff.target.max_life/10 * kills, self)
				eff.target:setEffect(eff.target.EFF_BRAINLOCKED, kills, {})

				local loss = "loss"
				if kills >= 10 then loss = "potentially fatal loss" elseif kills >=8 then loss = "devastating loss" elseif kills >=6 then loss = "tremendous loss" elseif kills >=4 then loss = "terrible loss" end
				game.logSeen(eff.target, "#LIGHT_RED#%s suffered a %s of self in the Dreamscape!", eff.target.name:capitalize(), loss)
			end
		end)
	end,
}

newEffect{
	name = "DISTORTION", image = "talents/maelstrom.png",
	desc = "Distortion",
	kr_display_name = "왜곡",
	long_desc = function(self, eff) return "The target has recently taken distortion damage and is vulnerable to distortion effects." end,
	type = "other",
	subtype = { distortion=true },
	status = "detrimental",
	parameters = { },
	no_stop_enter_worlmap = true, no_stop_resting = true,
}

newEffect{
	name = "REVISIONIST_HISTORY", image = "talents/revisionist_history.png",
	desc = "Revisionist History",
	kr_display_name = "수정주의적 역사",
	long_desc = function(self, eff) return "While this effect holds you can decide recent history did not happen the way it did." end,
	type = "other",
	subtype = { time=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.back_in_time then game:onTickEnd(function()
			-- Update the shader of the original player
			self:updateMainShader()
			if game._chronoworlds == nil then
				game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
				self:startTalentCooldown(self.T_REVISIONIST_HISTORY)
				return
			end
			game.logPlayer(game.player, "#LIGHT_BLUE#You go back in time to rewrite history!")
			game:chronoRestore("revisionist_history", true)
			game._chronoworlds = nil
			game.player:startTalentCooldown(self.T_REVISIONIST_HISTORY)
		end) else
			game._chronoworlds = nil
			self:startTalentCooldown(self.T_REVISIONIST_HISTORY)
		end
	end,
}

newEffect{
	name = "ZONE_AURA_FIRE",
	desc = "Oil mist",
	kr_display_name = "기름 안개",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% fire damage, -10% fire resistance, -10% armour, -2 sight range.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.FIRE]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.FIRE]=10})
		self:effectTemporaryValue(eff, "sight", -2)
		self:effectTemporaryValue(eff, "combat_armor", -math.ceil(self:combatArmor() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_COLD",
	desc = "Grave chill",
	kr_display_name = "묘지의 냉기",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% cold damage, -10% cold resistance, -10% physical save, -20% confusion immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.COLD]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.COLD]=10})
		self:effectTemporaryValue(eff, "confusion_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_physresist", -math.ceil(self:combatPhysicalResist(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_LIGHTNING",
	desc = "Static discharge",
	kr_display_name = "정전기 방출",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% lightning damage, -10% lightning resistance, -10% physical power, -20% stun immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHTNING]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.LIGHTNING]=10})
		self:effectTemporaryValue(eff, "stun_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_dam", -math.ceil(self:combatPhysicalpower() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_ACID",
	desc = "Noxious fumes",
	kr_display_name = "유독가스",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% acid damage, -10% acid resistance, -10% defense, -20% disarm immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.ACID]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.ACID]=10})
		self:effectTemporaryValue(eff, "disarm_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_def", -math.ceil(self:combatDefense(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_DARKNESS",
	desc = "Echoes of the void",
	kr_display_name = "공허로부터의 메아리",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% darkness damage, -10% darkness resistance, -10% mental save, -20% fear immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.DARKNESS]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.DARKNESS]=10})
		self:effectTemporaryValue(eff, "fear_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_mentalresist", -math.ceil(self:combatMentalResist(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_MIND",
	desc = "Eerie silence",
	kr_display_name = "으스스한 침묵",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% mind damage, -10% mind resistance, -10% spellpower, -20% silence immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.MIND]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.MIND]=10})
		self:effectTemporaryValue(eff, "silence_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_spellpower", -math.ceil(self:combatSpellpower() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_LIGHT",
	desc = "Aura of light",
	kr_display_name = "빛의 오러",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% light damage, -10% light resistance, -10% accuracy, -20% blind immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.LIGHT]=10})
		self:effectTemporaryValue(eff, "blind_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_atk", -math.ceil(self:combatAttack() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_ARCANE",
	desc = "Aether residue",
	kr_display_name = "에테르 잔여물",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% arcane damage, -10% arcane resistance, -10% armour hardiness, -20% stoning immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.ARCANE]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.ARCANE]=10})
		self:effectTemporaryValue(eff, "stone_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_armor_hardiness", -math.ceil(self:combatArmorHardiness() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_TEMPORAL",
	desc = "Impossible geometries",
	kr_display_name = "불가능한 지형",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% temporal damage, -10% temporal resistance, -10% spell save, -20% pinning immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.TEMPORAL]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.TEMPORAL]=10})
		self:effectTemporaryValue(eff, "pin_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_spellresist", -math.ceil(self:combatSpellResist(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_PHYSICAL",
	desc = "Uncontrolled anger",
	kr_display_name = "억제되지 않는 분노",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% physical damage, -10% physical resistance, -10% mindpower, -20% knockback immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.PHYSICAL]=10})
		self:effectTemporaryValue(eff, "knockback_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_mindpower", -math.ceil(self:combatMindpower() * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_BLIGHT",
	desc = "Miasma",
	kr_display_name = "망령",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% blight damage, -10% blight resistance, -20% healing mod, -20% disease immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.BLIGHT]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.BLIGHT]=10})
		self:effectTemporaryValue(eff, "disease_immune", -0.2)
		self:effectTemporaryValue(eff, "healing_factor", -0.2)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "ZONE_AURA_NATURE",
	desc = "Slimy floor",
	kr_display_name = "질척한 바닥",
	no_stop_enter_worlmap = true,
	long_desc = function(self, eff) return ("Zone-wide effect: +10% nature damage, -10% nature resistance, -10% ranged defense, -20% poison immunity.") end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { aura=true },
	status = "detrimental",
	zone_wide_effect = true,
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.NATURE]=-10})
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.NATURE]=10})
		self:effectTemporaryValue(eff, "poison_immune", -0.2)
		self:effectTemporaryValue(eff, "combat_def_ranged", -math.ceil(self:combatDefenseRanged(true) * 0.1))
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "VAULTED", image = "talents/time_prison.png",
	desc = "In Vault",
	kr_display_name = "금고 내부",
	long_desc = function(self, eff) return "The target is part of a vault and cannot act until it has been openend." end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { vault=true },
	status = "neutral",
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "invulnerable", 1)
		self:effectTemporaryValue(eff, "dont_act", 1)
		self:effectTemporaryValue(eff, "no_timeflow", 1)
		self:effectTemporaryValue(eff, "status_effect_immune", 1)
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "CAUTERIZE", image = "talents/cauterize.png",
	desc = "Cauterize",
	kr_display_name = "지져짐",
	long_desc = function(self, eff) return ("Your body is cauterizing, burning for %0.2f damage each turn."):format(eff.dam) end,
	type = "other",
	subtype = { fire=true },
	status = "detrimental",
	parameters = { dam=10 },
	on_gain = function(self, err) return "#CRIMSON##Target# is wreathed in flames on the brink of death!", "+Cauterize" end,
	on_lose = function(self, err) return "#CRIMSON#The flames around #target# vanish.", "-Cauterize" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.dam = old_eff.dam + new_eff.dam
		return old_eff
	end,
	activate = function(self, eff)
		self.life = self.old_life or 10
		eff.invulnerable = true
		eff.particle1 = self:addParticles(Particles.new("inferno", 1))
		eff.particle2 = self:addParticles(Particles.new("inferno", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
	on_timeout = function(self, eff)
		if eff.invulnerable then
			eff.invulnerable = nil
		end
		local dead, val = self:takeHit(eff.dam, self, {special_death_msg="burnt to death by cauterize"})

		local srcname = self.x and self.y and game.level.map.seens(self.x, self.y) and self.name:capitalize() or "Something"
		--@@
		local dtn = DamageType:get(DamageType.FIRE).kr_display_name or DamageType:get(DamageType.FIRE).name
		game:delayedLogDamage(self, self, val, ("%s%d %s#LAST#"):format(DamageType:get(DamageType.FIRE).text_color or "#aaaaaa#", math.ceil(val), dtn), false)
	end,
}

newEffect{
	name = "EIDOLON_PROTECT", image = "shockbolt/npc/unknown_unknown_the_eidolon.png",
	desc = "Protected by the Eidolon",
	kr_display_name = "에이돌론으로부터의 보호",
	long_desc = function(self, eff) return "The target is protected by the Eidolon, no creature may harm it (except self-harm)." end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { eidolon=true },
	status = "neutral",
	parameters = {},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "invulnerable_others", 1)
	end,
	deactivate = function(self, eff)
	end,
}


newEffect{
	name = "CLOAK_OF_DECEPTION", image = "shockbolt/object/artifact/black_cloak.png",
	desc = "Cloak of Deception",
	kr_display_name = "기만의 망토",
	long_desc = function(self, eff) return "The target is under the effect of the cloak of deception, making it look alive." end,
	decrease = 0, no_remove = true,
	type = "other",
	subtype = { undead=true },
	status = "neutral",
	parameters = {},
	activate = function(self, eff)
		self.old_faction_cloak = self.faction
		self.faction = "allied-kingdoms"
		if self.player then engine.Map:setViewerFaction(self.faction) end
	end,
	deactivate = function(self, eff)
		self.faction = self.old_faction_cloak
		if self.player then engine.Map:setViewerFaction(self.faction) end
	end,
}
