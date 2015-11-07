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

-- Class Trees
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/blade-threading", name = "Blade Threading", description = "시공마법과 쌍수 무기술의 조화." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/bow-threading", name = "Bow Threading", description = "시공마법과 장거리 무기술의 조화."}
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/temporal-combat", name = "Temporal Combat", description = "시공마법과 물리 전투 기술의 조화." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/guardian", name = "Temporal Guardian", description = "감시자의 전투 수련과 기술들." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/threaded-combat", name = "Threaded Combat", min_lev = 10, description = "장거리 무기술과 쌍수 무기술의 조화." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/temporal-hounds", name = "Temporal Hounds", min_lev = 10, description = "시간의 사냥개를 불러 당신의 전투를 돕습니다." }

newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/flux", name = "flux", description = "시공간을 조정합니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/gravity", name = "gravity", description = "중력의 힘을 불러내어 당신의 적을 부수고, 밀고, 당깁니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/matter", name = "matter", description = "물질 자체를 바꾸고 빚어냅니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-folding", name = "Spacetime Folding", description = "공간을 자유자재로 접습니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/speed-control", name = "Speed Control", description = "시공간에서 물질들과 존재들의 속도를 조절합니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/stasis", name = "stasis", description = "시공간을 안정화합니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timeline-threading", name = "Timeline Threading", min_lev = 10, description = "시간선을 관찰하고 개변시켜 시공간 연속체를 다스립니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/timetravel", name = "timetravel", description = "시간의 흐름을 직접적으로 다룹니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spellbinding", name = "Spellbinding", min_lev = 10, description = "시공간 주문을 다룹니다." }

-- Generic Chronomancy
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/chronomancy", name = "Chronomancy", generic = true, description = "미래를 어렴풋이 볼 수 있게 합니다, 혹은 현재에 대해 더 잘 알게됩니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/energy", name = "energy", generic = true, description = "순수한 에너지를 다루어 줄이거나, 늘립니다.Manipulate raw energy by addition or subtraction." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/fate-weaving", name = "Fate Weaving", generic = true, description = "운명의 실을 엮습니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/spacetime-weaving", name = "Spacetime Weaving", generic = true, description = "시공간의 선을 엮습니다." }

-- Misc and Outdated Trees
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/manifold", name = "Manifold", generic = true, description = "무기 폴딩이 발동 할 수 있게하는 효과들입니다." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/other", name = "Other", generic = true, description = "여러 종류의 시공간 효과들입니다." }

newTalentType{ no_silence=true, is_spell=true, type="chronomancy/age-manipulation", name = "Age Manipulation", description = "Manipulate the age of creatures you encounter." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/temporal-archery", name = "Temporal Archery", description = "A blend of chronomancy and ranged combat." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="chronomancy/paradox", name = "paradox", description = "Break the laws of spacetime." }

-- Anomalies are not learnable but can occur instead of an intended spell when paradox gets to high.
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/anomalies", name = "anomalies", description = "Spacetime anomalies that can randomly occur when paradox is to high." }

-- Generic requires for chronomancy spells based on talent level
chrono_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
chrono_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
chrono_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
chrono_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
chrono_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

chrono_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
chrono_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
chrono_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
chrono_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
chrono_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

-- Generic requires for non-spell temporal effects based on talent level
temporal_req1 = {
	stat = { wil=function(level) return 12 + (level-1)*2 end},
	level = function(level) return 0 + (level-1) end,
}
temporal_req2 = {
	stat = { wil=function(level) return 20 + (level-1)*2 end},
	level = function(level) return 4 + (level-1) end,
}
temporal_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
temporal_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
temporal_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/chronomancy/age-manipulation.lua")
load("/data/talents/chronomancy/blade-threading.lua")
load("/data/talents/chronomancy/bow-threading.lua")
load("/data/talents/chronomancy/chronomancy.lua")
load("/data/talents/chronomancy/energy.lua")
load("/data/talents/chronomancy/fate-weaving.lua")
load("/data/talents/chronomancy/flux.lua")
load("/data/talents/chronomancy/gravity.lua")
load("/data/talents/chronomancy/guardian.lua")
load("/data/talents/chronomancy/matter.lua")
load("/data/talents/chronomancy/paradox.lua")
load("/data/talents/chronomancy/spacetime-folding.lua")
load("/data/talents/chronomancy/spacetime-weaving.lua")
load("/data/talents/chronomancy/speed-control.lua")
load("/data/talents/chronomancy/spellbinding.lua")
load("/data/talents/chronomancy/stasis.lua")
load("/data/talents/chronomancy/temporal-archery.lua")
load("/data/talents/chronomancy/temporal-combat.lua")
load("/data/talents/chronomancy/temporal-hounds.lua")
load("/data/talents/chronomancy/threaded-combat.lua")
load("/data/talents/chronomancy/timeline-threading.lua")
load("/data/talents/chronomancy/timetravel.lua")

-- Loads many functions and misc. talents
load("/data/talents/chronomancy/other.lua")

-- Anomalies, not learnable talents that may be cast instead of the intended spell when paradox gets to high
load("/data/talents/chronomancy/anomalies.lua")

-- Paradox Functions

-- Paradox modifier.  This dictates paradox cost and spellpower scaling
-- Note that 300 is the optimal balance
-- Caps at -50% and +50%
getParadoxModifier = function (self)
	local paradox = self:getParadox()
	local pm = math.sqrt(paradox / 300)
	if paradox < 300 then pm = paradox/300 end
	pm = util.bound(pm, 0.5, 1.5)
	return pm
end

-- Paradox cost (regulates the cost of paradox talents)
getParadoxCost = function (self, t, value)
	local pm = getParadoxModifier(self)
	local multi = 1
	if self:attr("paradox_cost_multiplier") then
		multi = 1 - self:attr("paradox_cost_multiplier")
	end
	return (value * pm) * multi
end

-- Paradox Spellpower (regulates spellpower for chronomancy)
getParadoxSpellpower = function(self, t, mod, add)
	local pm = getParadoxModifier(self)
	local mod = mod or 1

	-- Empower?
	local p = self:isTalentActive(self.T_EMPOWER)
	if p and p.talent == t.id then
		pm = pm + self:callTalent(self.T_EMPOWER, "getPower")
	end

	local spellpower = self:combatSpellpower(mod * pm, add)
	return spellpower
end

-- Extension Spellbinding
getExtensionModifier = function(self, t, value)
	local pm = getParadoxModifier(self)
	local mod = 1
	
	local p = self:isTalentActive(self.T_EXTENSION)
	if p and p.talent == t.id then
		mod = mod + self:callTalent(self.T_EXTENSION, "getPower")
	end
	
	-- paradox modifier rounds down
	value = math.floor(value * pm)
	-- extension modifier rounds up
	value = math.ceil(value * mod)
	
	return value
end

-- Tunes paradox
tuneParadox = function(self, t, value)
	local dox = self:getParadox() - (self.preferred_paradox or 300)
	local fix = math.min( math.abs(dox), value )
	if dox > 0 then
		self:incParadox( -fix )
	elseif dox < 0 then
		self:incParadox( fix )
	end
end

--- Warden weapon functions
-- Checks for weapons in main and quickslot
doWardenPreUse = function(self, weapon, silent)
	if weapon == "bow" then
		if not self:hasArcheryWeapon("bow") and not self:hasArcheryWeaponQS("bow") then
			return false
		end
	end
	if weapon == "dual" then
		if not self:hasDualWeapon() and not self:hasDualWeaponQS() then
			return false
		end
	end
	return true
end

-- Swaps weapons if needed
doWardenWeaponSwap = function(self, t, type, silent)
	local swap = false
	local warden_weapon

	if type == "blade" then
		local mainhand, offhand = self:hasDualWeapon()
		if not mainhand or self:hasArcheryWeapon("bow") then  -- weird but this is lets ogers offhanding daggers still swap
			swap = true
			warden_weapon = "blade"
		end
	end
	if type == "bow" then
		if not self:hasArcheryWeapon("bow") then
			swap = true
			warden_weapon = "bow"
		end
	end
	
	if swap == true then
		local old_inv_access = self.no_inventory_access				-- Make sure clones can swap
		self.no_inventory_access = nil
		self:attr("no_sound", 1)
		self:quickSwitchWeapons(true, "warden", silent)
		self:attr("no_sound", -1)
		self.no_inventory_access = old_inv_access
	end
	
	return swap, dam
end

-- Target helper function for focus fire
checkWardenFocus = function(self)
	local target
	local eff = self:hasEffect(self.EFF_WARDEN_S_FOCUS)
	if eff then
		target = eff.target
	end
	return target
end

-- Spell functions
makeParadoxClone = function(self, target, duration)

	-- Don't clone particles or inventory on short lived clones
	local restore = false
	local old_particles, old_inven
	if duration == 0 then
		old_particles = target.__particles 
		old_inventory = target.inven[target.INVEN_INVEN]
		target.__particles = {}
		target.inven[target.INVEN_INVEN] = nil
		restore = true	
	end

	-- Clone them
	local m = target:cloneFull{
		no_drops = true,
		keep_inven_on_death = false,
		faction = target.faction,
		summoner = target, summoner_gain_exp=true,
		summon_time = duration,
		ai_target = {actor=nil},
		ai = "summoned", ai_real = "tactical",
		name = ""..target.name.."'s temporal clone",
		desc = [[A creature from another timeline.]],
	}
	
	-- restore values if needed
	if restore then
		target.__particles = old_particles
		target.inven[target.INVEN_INVEN] = old_inventory
	end
	
	-- remove some values
	m:removeAllMOs()
	m.make_escort = nil
	m.on_added_to_level = nil
	m.on_added = nil

	mod.class.NPC.castAs(m)
	engine.interface.ActorAI.init(m, m)

	-- change some values
	m.exp_worth = 0
	m.energy.value = 0
	m.player = nil
	m.max_life = m.max_life
	m.life = util.bound(m.life, 0, m.max_life)
	m.forceLevelup = function() end
	m.on_die = nil
	m.die = nil
	m.puuid = nil
	m.on_acquire_target = nil
	m.no_inventory_access = true
	m.no_levelup_access = true
	m.on_takehit = nil
	m.seen_by = nil
	m.can_talk = nil
	m.clone_on_hit = nil
	m.escort_quest = nil
	m.unused_talents = 0
	m.unused_generics = 0
	if m.talents.T_SUMMON then m.talents.T_SUMMON = nil end
	if m.talents.T_MULTIPLY then m.talents.T_MULTIPLY = nil end
	
	-- Clones never flee because they're awesome
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0

	-- Remove some talents
	local tids = {}
	for tid, _ in pairs(m.talents) do
		local t = m:getTalentFromId(tid)
		if (t.no_npc_use and not t.allow_temporal_clones) or t.remove_on_clone then tids[#tids+1] = t end
	end
	for i, t in ipairs(tids) do
		if t.mode == "sustained" and m:isTalentActive(t.id) then m:forceUseTalent(t.id, {ignore_energy=true, silent=true}) end
		m:unlearnTalentFull(t.id)
	end

	-- remove timed effects
	m:removeTimedEffectsOnClone()
	
	-- reset folds for our Warden clones
	for tid, cd in pairs(m.talents_cd) do
		local t = m:getTalentFromId(tid)
		if t.type[1]:find("^chronomancy/manifold") and m:knowTalent(tid) then
			m:alterTalentCoolingdown(t, -cd)
		end
	end
	
	-- And finally, a bit of sanity in case anyone decides they should blow up the world..
	if m.preferred_paradox and m.preferred_paradox > 600 then m.preferred_paradox = 600 end

	m.self_resurrect = nil
	
	return m
end

-- Make sure we don't run concurrent chronoworlds; to prevent lag and possible game breaking bugs or exploits
checkTimeline = function(self)
	if game._chronoworlds  == nil then
		return false
	else
		return true
	end
end
