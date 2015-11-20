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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"

newTalent{
	name = "Stalk",
	kr_name = "추적 개시",
	type = {"cursed/endless-hunt", 1},
	mode = "sustained",
	require = cursed_wil_req1,
	points = 5,
	cooldown = 0,
	no_energy = true,
	tactical = { BUFF = 5 },
	activate = function(self, t)
		return {
			hit = false, -- was any target hit this turn
			hit_target = nil, -- which single target was hit this turn
			hit_turns = 0, -- how many turns has the target been hit
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	getDuration = function(self, t)
		return 40
	end,
	getHitHateChange = function(self, t, bonus)
		bonus = math.min(bonus, 3)
		return 0.5 * bonus
	end,
	getAttackChange = function(self, t, bonus)
		return math.floor(self:combatTalentStatDamage(t, "wil", 10, 30) * math.sqrt(bonus))
	end,
	getStalkedDamageMultiplier = function(self, t, bonus)
		return 1 + self:combatTalentIntervalDamage(t, "str", 0.1, 0.35, 0.4) * bonus / 3
	end,
	doStalk = function(self, t, target)
		if self:hasEffect(self.EFF_STALKER) or target:hasEffect(self.EFF_STALKED) then
			-- doesn't support multiple stalkers, stalkees
			game.logPlayer(self, "#F53CBE#추적 대상에게 집중할 수가 없습니다!")
			return false
		end

		local duration = t.getDuration(self, t)
		self:setEffect(self.EFF_STALKER, duration, { target=target, bonus = 1 })
		target:setEffect(self.EFF_STALKED, duration, {src=self })

		game.level.map:particleEmitter(target.x, target.y, 1, "stalked_start")

		return true
	end,
	on_targetDied = function(self, t, target)
		self:removeEffect(self.EFF_STALKER)
		target:removeEffect(self.EFF_STALKED)

		-- prevent stalk targeting this turn
		local stalk = self:isTalentActive(self.T_STALK)
		if stalk then
			stalk.hit = false
			stalk.hit_target = nil
			stalk.hit_turns = 0
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[하나의 적을 근접 공격으로 두 번 연이어 공격하면, 적에 대한 증오심이 불타올라 오직 그 적만을 추적하기 시작합니다. 이 효과는 추적 대상이 죽지 않는 한, %d 턴 동안 지속됩니다. 추적이 시작되면 적을 공격할 때마다 추가 능력의 단계가 올라가고, 공격하지 않을 때마다 추가 능력의 단계를 잃게 됩니다.
		1 단계 추가 능력 : 정확도 +%d / 근접 피해량 +%d%% / 사냥감을 공격할 때마다 증오심 회복 +%0.2f
		2 단계 추가 능력 : 정확도 +%d / 근접 피해량 +%d%% / 사냥감을 공격할 때마다 증오심 회복 +%0.2f
		3 단계 추가 능력 : 정확도 +%d / 근접 피해량 +%d%% / 사냥감을 공격할 때마다 증오심 회복 +%0.2f
		정확도 추가량은 의지 능력치, 근접 피해 증가량은 힘 능력치의 영향을 받아 증가합니다.]]):format(duration,
		t.getAttackChange(self, t, 1), t.getStalkedDamageMultiplier(self, t, 1) * 100 - 100, t.getHitHateChange(self, t, 1),
		t.getAttackChange(self, t, 2), t.getStalkedDamageMultiplier(self, t, 2) * 100 - 100, t.getHitHateChange(self, t, 2),
		t.getAttackChange(self, t, 3), t.getStalkedDamageMultiplier(self, t, 3) * 100 - 100, t.getHitHateChange(self, t, 3))
	end,
}

newTalent{
	name = "Beckon",
	kr_name = "목표 지정",
	type = {"cursed/endless-hunt", 2},
	require = cursed_wil_req2,
	points = 5,
	cooldown = 10,
	hate = 2,
	tactical = { DISABLE = 2 },
	range = 10,
	getDuration = function(self, t)
		return math.min(20, math.floor(5 + self:getTalentLevel(t) * 2))
	end,
	getChance = function(self, t)
		return math.min(75, math.floor(25 + (math.sqrt(self:getTalentLevel(t)) - 1) * 20))
	end,
	getSpellpowerChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 8, 33)
	end,
	getMindpowerChange = function(self, t)
		return -self:combatTalentStatDamage(t, "wil", 8, 33)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)

		local tg = {type="hit", pass_terrain=true, range=range}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > range then return nil end

		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local spellpowerChange = t.getSpellpowerChange(self, t)
		local mindpowerChange = t.getMindpowerChange(self, t)
		target:setEffect(target.EFF_BECKONED, duration, {src=self, range=range, chance=chance, spellpowerChange=spellpowerChange, mindpowerChange=mindpowerChange })

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local spellpowerChange = t.getSpellpowerChange(self, t)
		local mindpowerChange = t.getMindpowerChange(self, t)
		return ([[사냥꾼은 사냥감이 자신에게 다가오도록 유도할 수 있습니다. %d 턴 동안, 적이 %d%% 확률로 다른 행동을 하지 않고 시전자에게 다가오려고 하게 됩니다. 적의 정신 내성에 따라 이 확률은 다르게 적용되며, 일정 수준 이상의 피해를 받은 적은 이 효과에서 벗어나게 됩니다. 또한 이 효과는 적이 시전자에게 제대로 집중하지 못하게 해, 시전자와 충분히 가까워지기 전까지 적의 주문력과 정신력을 %d 감소시킵니다. 
		주문력과 정신력 감소량은 의지 능력치의 영향을 받아 증가합니다.]]):format(duration, chance, -spellpowerChange)
	end,
}

newTalent{
	name = "Harass Prey",
	kr_name = "사냥감 유린",
	type = {"cursed/endless-hunt", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 5,
	tactical = { ATTACK = { PHYSICAL = 3 } },
	getCooldownDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3.75, 6.75, "log", 0, 1)) end,
	getDamageMultiplier = function(self, t, hate)
		return getHateMultiplier(self, 0.35, 0.67, false, hate)
	end,
	getTargetDamageChange = function(self, t)
		return -self:combatLimit(self:combatTalentStatDamage(t, "wil", 0.7, 0.9), 1, 0, 0, 0.75, 0.87)*100 -- Limit < 100%
	end,
	getDuration = function(self, t)
		return 2
	end,
	on_pre_use = function(self, t)
		local eff = self:hasEffect(self.EFF_STALKER)
		return eff and not eff.target.dead and core.fov.distance(self.x, self.y, eff.target.x, eff.target.y) <= 1
	end,
	action = function(self, t)
		local damageMultipler = t.getDamageMultiplier(self, t)
		local cooldownDuration = t.getCooldownDuration(self, t)
		local targetDamageChange = t.getTargetDamageChange(self, t)
		local duration = t.getDuration(self, t)
		local effStalker = self:hasEffect(self.EFF_STALKER)
		local target = effStalker.target
		if not target or target.dead then return nil end

		target:setEffect(target.EFF_HARASSED, duration, {src=self, damageChange=targetDamageChange })

		for i = 1, 2 do
			if not target.dead and self:attackTarget(target, nil, damageMultipler, true) then
				-- remove effects
				local tids = {}
				for tid, lev in pairs(target.talents) do
					local t = target:getTalentFromId(tid)
					if not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
				end

				local t = rng.tableRemove(tids)
				if t then
					target.talents_cd[t.id] = rng.range(3, 5)
					game.logSeen(target, "#F53CBE#%s의 %s 기술이 방해받았습니다!", (target.kr_name or target.name):capitalize(), (t.kr_name or t.name))
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local damageMultipler = t.getDamageMultiplier(self, t)
		local cooldownDuration = t.getCooldownDuration(self, t)
		local targetDamageChange = t.getTargetDamageChange(self, t)
		local duration = t.getDuration(self, t)
		return ([[사냥감을 빠르게 두 번 공격하여, 각각 %d%% 에서 %d%% 피해를 줍니다. (증오심 0 일 때 최소 피해, 증오심 100 이상일 때 최대 피해) 
		각각의 공격은 사냥감의 기술이나 룬, 주입 능력 중 하나를 방해하여, 재사용 대기시간을 %d 턴 증가시킵니다. 사냥감은 공격을 받으면 불안감에 빠져, %d 턴 동안 피해량이 %d%% 만큼 감소하게 됩니다.
		피해 감소량은 의지 능력치의 영향을 받아 증가합니다.]]):format(t.getDamageMultiplier(self, t, 0) * 100, t.getDamageMultiplier(self, t, 100) * 100, cooldownDuration, duration, -targetDamageChange) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Surge",
	kr_name = "쇄도",
	type = {"cursed/endless-hunt", 4},
	mode = "sustained",
	require = cursed_wil_req4,
	points = 5,
	cooldown = 10,
	no_energy = true,
	getMovementSpeedChange = function(self, t)
		return self:combatTalentStatDamage(t, "wil", 0.1, 1.1)
	end,
	getDefenseChange = function(self, t, hasDualweapon)
		if hasDualweapon or self:hasDualWeapon() then return self:combatTalentStatDamage(t, "wil", 4, 40) end
		return 0
	end,
	preUseTalent = function(self, t)
		-- prevent AI's from activating more than 1 talent
		if self ~= game.player and (self:isTalentActive(self.T_CLEAVE) or self:isTalentActive(self.T_REPEL)) then return false end
		return true
	end,
	sustain_slots = 'cursed_combat_style',
	activate = function(self, t)
		-- Place other talents on cooldown.
		if self:knowTalent(self.T_REPEL) and not self:isTalentActive(self.T_REPEL) then
			local tRepel = self:getTalentFromId(self.T_REPEL)
			self.talents_cd[self.T_REPEL] = tRepel.cooldown
		end

		if self:knowTalent(self.T_CLEAVE) and not self:isTalentActive(self.T_CLEAVE) then
			local tCleave = self:getTalentFromId(self.T_CLEAVE)
			self.talents_cd[self.T_CLEAVE] = tCleave.cooldown
		end

		local movementSpeedChange = t.getMovementSpeedChange(self, t)
		return {
			moveId = self:addTemporaryValue("movement_speed", movementSpeedChange),
			luckId = self:addTemporaryValue("inc_stats", { [Stats.STAT_LCK] = -3 })
		}
	end,
	deactivate = function(self, t, p)
		if p.moveId then self:removeTemporaryValue("movement_speed", p.moveId) end
		if p.luckId then self:removeTemporaryValue("inc_stats", p.luckId) end

		return true
	end,
	info = function(self, t)
		local movementSpeedChange = t.getMovementSpeedChange(self, t)
		local defenseChange = t.getDefenseChange(self, t, true)
		return ([[끓어오르는 증오심을 이용하여, 이동 속도를 %d%% 증가시킵니다. 이 무모한 이동 방식은 불행을 불러옵니다. (행운 -3)
		두개골 쪼개기, 격퇴 기술과는 함께 사용할 수 없으며, 셋 중 하나를 사용하면 다른 두 기술들은 재사용 대기시간을 가지게 됩니다.
		이동 속도 증가와 더불어, 쌍수 무기를 사용할 경우 그 절묘한 균형이 맞아떨어져 회피도가 추가적으로 %d 상승하게 됩니다.
		이동 속도 증가량과 쌍수 무기 사용시 회피도 증가량은 의지 능력치의 영향을 받아 증가합니다.]]):format(movementSpeedChange * 100, defenseChange)
	end,
}
