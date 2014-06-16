-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Slash",
	kr_name = "베기",
	type = {"cursed/slaughter", 1},
	require = cursed_str_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	hate = 2,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	requires_target = true,
	-- note that EFF_CURSED_WOUND in mod.data.timed_effects.physical.lua has a cap of -75% healing per application
	getDamageMultiplier = function(self, t, hate)
		return 1 + self:combatTalentIntervalDamage(t, "str", 0.3, 1.5, 0.4) * getHateMultiplier(self, 0.3, 1, false, hate)
	end,
	getHealFactorChange = function(self, t)
		local level = math.max(3 * self:getTalentTypeMastery(t.type[1]), self:getTalentLevel(t))
		return -self:combatLimit(math.max(0,(level-2)^0.5), 1, 0, 0, 0.26, 1.73)  -- Limit < -100%
	end,
	getWoundDuration = function(self, t)
		return 15
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local damageMultiplier = t.getDamageMultiplier(self, t)
		local hit = self:attackTarget(target, nil, damageMultiplier, true)

		if hit and not target.dead then
			local level = self:getTalentLevel(t)
			if target:canBe("poison") and level >= 3 then
				local healFactorChange = t.getHealFactorChange(self, t)
				local woundDuration = t.getWoundDuration(self, t)
				target:setEffect(target.EFF_CURSED_WOUND, woundDuration, { healFactorChange=healFactorChange, totalDuration=woundDuration })
			end
		end

		return true
	end,
	info = function(self, t)
		local healFactorChange = t.getHealFactorChange(self, t)
		local woundDuration = t.getWoundDuration(self, t)
		return ([[대상을 공격하여, %d%% 에서 %d%% 피해를 줍니다. (증오심 0 일 때 최소 피해, 증오심 100 이상일 때 최대 피해)
		기술 레벨이 3 이상이면, 적을 공격하면서 자신의 저주를 적에게 옮깁니다. 이를 통해 대상의 생명력 회복 효율을 %d 턴 동안 %d%% 낮출 수 있게 되며, 이 효과는 중첩됩니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.]]):format(t.getDamageMultiplier(self, t, 0) * 100, t.getDamageMultiplier(self, t, 100) * 100, woundDuration, -healFactorChange * 100) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Frenzy",
	kr_name = "난도질",
	type = {"cursed/slaughter", 2},
	require = cursed_str_req2,
	points = 5,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	random_ego = "attack",
	cooldown = 12,
	hate = 2,
	getDamageMultiplier = function(self, t, hate)
		return self:combatTalentIntervalDamage(t, "str", 0.25, 0.8, 0.4) * getHateMultiplier(self, 0.5, 1, false, hate)
	end,
	getAttackChange = function(self, t)
		local level = math.max(3 * self:getTalentTypeMastery(t.type[1]) - 2, self:getTalentLevel(t) - 2)
		return -self:combatScale(math.max(0,level^0.5 - 0.5) * 15 * (100 + self:getStr()), 0, 0, 20.77, 3696, 0.67)
	end,
	range = 0,
	radius = 1,
        target = function(self, t)
                return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
        end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)

		local targets = {}
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then
				targets[#targets+1] = target
			end
		end)

		if #targets <= 0 then return nil end

		local damageMultiplier = t.getDamageMultiplier(self, t)
		local attackChange = t.getAttackChange(self, t)

		local effStalker = self:hasEffect(self.EFF_STALKER)
		if effStalker and core.fov.distance(self.x, self.y, effStalker.target.x, effStalker.target.y) > 1 then effStalker = nil end
		for i = 1, 4 do
			local target
			if effStalker and not effStalker.target.dead then
				target = effStalker.target
			else
				target = rng.table(targets)
			end

			if self:attackTarget(target, nil, damageMultiplier, true) and self:getTalentLevel(t) >= 3 and not target:hasEffect(target.EFF_OVERWHELMED) then
				target:setEffect(target.EFF_OVERWHELMED, 3, {src=self, attackChange=attackChange})
			end
		end

		return true
	end,
	info = function(self, t)
		local attackChange = t.getAttackChange(self, t)
		return ([[근접한 적들에게, 각각 %d%% 에서 %d%% 피해를 주는 공격을 4 번 연속으로 합니다. (증오심 0 일 때 최소 피해, 증오심 100 이상일 때 최대 피해)
		사냥감으로 지정된 대상이 근처에 있다면, 그 대상을 우선적으로 공격합니다.
		기술 레벨이 3 이상이면, 더욱 더 격렬하게 공격하여 대상의 정확도를 3 턴 동안 %d 감소시킵니다.
		정확도 감소량과 피해량은 힘 능력치의 영향을 받아 증가합니다.]]):format(t.getDamageMultiplier(self, t, 0) * 100, t.getDamageMultiplier(self, t, 100) * 100, -attackChange)
	end,
}

newTalent{
	name = "Reckless Charge",
	kr_name = "무모한 돌진",
	type = {"cursed/slaughter", 3},
	require = cursed_str_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	hate = 5,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	tactical = { CLOSEIN = 2 },
	requires_target = true,
	getDamageMultiplier = function(self, t, hate)
		return 0.7 * getHateMultiplier(self, 0.5, 1, false, hate)
		--return self:combatTalentIntervalDamage(t, "str", 0.8, 1.7, 0.4) * getHateMultiplier(self, 0.5, 1, false, hate)
	end,
	getMaxAttackCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	action = function(self, t)
		local targeting = {type="bolt", range=self:getTalentRange(t), nolock=true}
		local targetX, targetY, actualTarget = self:getTarget(targeting)
		if not targetX or not targetY then return nil end
		if core.fov.distance(self.x, self.y, targetX, targetY) > self:getTalentRange(t) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", target) end
		local lineFunction = core.fov.line(self.x, self.y, targetX, targetY, block_actor)
		local nextX, nextY, is_corner_blocked = lineFunction:step()
		local currentX, currentY = self.x, self.y

		local attackCount = 0
		local maxAttackCount = t.getMaxAttackCount(self, t)

		while nextX and nextY and not is_corner_blocked do
			local blockingTarget = game.level.map(nextX, nextY, Map.ACTOR)
			if blockingTarget and self:reactionToward(blockingTarget) < 0 then
				-- attempt a knockback
				local level = self:getTalentLevelRaw(t)
				local maxSize = 2
				if level >= 5 then
					maxSize = 4
				elseif level >= 3 then
					maxSize = 3
				end

				local blocked = true
				if blockingTarget.size_category <= maxSize then
					if blockingTarget:checkHit(self:combatPhysicalpower(), blockingTarget:combatPhysicalResist(), 0, 95, 15) and blockingTarget:canBe("knockback") then
						blockingTarget:crossTierEffect(blockingTarget.EFF_OFFBALANCE, self:combatPhysicalpower())
						-- determine where to move the target (any adjacent square that isn't next to the attacker)
						local start = rng.range(0, 8)
						for i = start, start + 8 do
							local x = nextX + (i % 3) - 1
							local y = nextY + math.floor((i % 9) / 3) - 1
							if core.fov.distance(currentY, currentX, x, y) > 1
									and game.level.map:isBound(x, y)
									and not game.level.map:checkAllEntities(x, y, "block_move", self) then
								blockingTarget:move(x, y, true)
								self:logCombat(blockingTarget, "#Source1# #Target3# 밀어냅니다!")
								blocked = false
								break
							end
						end
					end
				end

				if blocked then
					self:logCombat(blockingTarget, "#Target1# #Source#의 공격을 막아냈습니다!") 
				end
			end

			-- check that we can move
			if not game.level.map:isBound(nextX, nextY) or game.level.map:checkAllEntities(nextX, nextY, "block_move", self) then break end

			-- allow the move
			currentX, currentY = nextX, nextY
			nextX, nextY, is_corner_blocked = lineFunction:step()

			-- attack adjacent targets
			for i = 0, 8 do
				local x = currentX + (i % 3) - 1
				local y = currentY + math.floor((i % 9) / 3) - 1
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 and attackCount < maxAttackCount then
					local damageMultiplier = t.getDamageMultiplier(self, t)
					self:attackTarget(target, nil, damageMultiplier, true)
					attackCount = attackCount + 1

					game.level.map:particleEmitter(x, y, 1, "blood", {})
					game:playSoundNear(self, "actions/melee")
				end
			end
		end

		self:move(currentX, currentY, true)

		return true
	end,
	info = function(self, t)
		local level = self:getTalentLevelRaw(t)
		local maxAttackCount = t.getMaxAttackCount(self, t)
		local size
		if level >= 5 then
			size = "큼"
		elseif level >= 3 then
			size = "중간"
		else
			size = "작음"
		end
		return ([[대상에게 돌진하면서, 대상은 물론 돌진하는 길의 근처에 있는 적들에게까지 %d%% 에서 %d%% 피해를 줍니다. (증오심 0 일 때 최소 피해, 증오심 100 이상일 때 최대 피해) 
		최대 '%s' 크기인 적까지 밀어낼 수 있으며, 최대 %d 번 까지 공격할 수 있습니다. 한 대상을 여러 번 공격할 수도 있습니다.]]):format(t.getDamageMultiplier(self, t, 0) * 100, t.getDamageMultiplier(self, t, 100) * 100, size, maxAttackCount)
	end,
}

--newTalent{
--	name = "Cleave",
--	type = {"cursed/slaughter", 4},
--	mode = "passive",
--	require = cursed_str_req4,
--	points = 5,
--	on_attackTarget = function(self, t, target, multiplier)
--		if inCleave then return end
--		inCleave = true
--
--		local chance = 28 + self:getTalentLevel(t) * 7
--		if rng.percent(chance) then
--			local start = rng.range(0, 8)
--			for i = start, start + 8 do
--				local x = self.x + (i % 3) - 1
--				local y = self.y + math.floor((i % 9) / 3) - 1
--				local secondTarget = game.level.map(x, y, Map.ACTOR)
--				if secondTarget and secondTarget ~= target and self:reactionToward(secondTarget) < 0 then
--					local multiplier = multiplier or 1 * self:combatTalentWeaponDamage(t, 0.2, 0.7) * getHateMultiplier(self, 0.5, 1.0, false)
--					game.logSeen(self, "%s cleaves through another foe!", self.name:capitalize())
--					self:attackTarget(secondTarget, nil, multiplier, true)
--					inCleave = false
--					return
--				end
--			end
--		end
--		inCleave = false
--
--	end,
--	info = function(self, t)
--		local chance = 28 + self:getTalentLevel(t) * 7
--		local multiplier = self:combatTalentWeaponDamage(t, 0.2, 0.7)
--		return ([[Every swing of your weapon has a %d%% chance of striking a second target for %d%% (at 0 Hate) to %d%% (at 100+ Hate) damage.]]):format(chance, multiplier * 50, multiplier * 100)
--	end,
--}

newTalent{
	name = "Cleave",
	kr_name = "두개골 쪼개기",
	type = {"cursed/slaughter", 4},
	mode = "sustained",
	require = cursed_str_req4,
	points = 5,
	cooldown = 10,
	no_energy = true,
	getChance = function(self, t, has2h)
		local chance = self:combatTalentIntervalDamage(t, "str", 10, 38, 0.4)
		if (not has2h and self:hasTwoHandedWeapon()) or (has2h and has2h > 0) then chance = chance + 15 end
		chance = self:combatLimit(chance, 100, 0, 0, 25.18, 25.18) -- Limit < 100%
		return chance
	end,
	getDamageMultiplier = function(self, t, hate)
		local damageMultiplier = self:combatLimit(self:getTalentLevel(t) * self:getStr()*getHateMultiplier(self, 0.5, 1.0, false, hate), 1, 0, 0, 0.79, 500) -- Limit < 100%
		if self:hasTwoHandedWeapon() then
			damageMultiplier = damageMultiplier + 0.25
		end
		return damageMultiplier
	end,
	preUseTalent = function(self, t)
		-- prevent AI's from activating more than 1 talent
		if self ~= game.player and (self:isTalentActive(self.T_SURGE) or self:isTalentActive(self.T_REPEL)) then return false end
		return true
	end,
	activate = function(self, t)
		-- deactivate other talents and place on cooldown
		if self:isTalentActive(self.T_SURGE) then
			self:useTalent(self.T_SURGE)
		elseif self:knowTalent(self.T_SURGE) then
			local tSurge = self:getTalentFromId(self.T_SURGE)
			self.talents_cd[self.T_SURGE] = tSurge.cooldown
		end

		if self:isTalentActive(self.T_REPEL) then
			self:useTalent(self.T_REPEL)
		elseif self:knowTalent(self.T_REPEL) then
			local tRepel = self:getTalentFromId(self.T_REPEL)
			self.talents_cd[self.T_REPEL] = tRepel.cooldown
		end

		return {
			luckId = self:addTemporaryValue("inc_stats", { [Stats.STAT_LCK] = -3 })
		}
	end,
	deactivate = function(self, t, p)
		if p.luckId then self:removeTemporaryValue("inc_stats", p.luckId) end

		return true
	end,
	on_attackTarget = function(self, t, target)
		if self.inCleave then return end
		self.inCleave = true

		local chance = t.getChance(self, t)
		if rng.percent(chance) then
			local start = rng.range(0, 8)
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				local secondTarget = game.level.map(x, y, Map.ACTOR)
				if secondTarget and secondTarget ~= target and self:reactionToward(secondTarget) < 0 then
					local damageMultiplier = t.getDamageMultiplier(self, t)
					self:logCombat(secondTarget, "#Source1# #Target3# 내려칩니다!")
					self:attackTarget(secondTarget, nil, damageMultiplier, true)
					self.inCleave = false
					return
				end
			end
		end
		self.inCleave = false
	end,
	info = function(self, t)
		local chance = t.getChance(self, t, 0)
		local chance2h = t.getChance(self, t, 1)
		return ([[무기로 적을 공격할 때마다, 한손 무기 시 %d%% 양손 무기 시 %d%% 확률로 근접한 적에게 %d%% 에서 %d%% 피해를 추가로 줍니다 (증오심 0 일 때 최소 피해, 증오심 100 이상일 때 최대 피해. 양손 무기 시 추가 피해량 +25%%). 이 무자비한 공격 방식은 불행을 불러옵니다. (행운 -3)
		쇄도, 격퇴 기술과는 함께 사용할 수 없으며, 셋 중 하나를 사용하면 다른 두 기술들은 재사용 대기시간을 가지게 됩니다.
		추가 공격 확률과 피해량은 힘 능력치의 영향을 받아 증가합니다.]]):
		format(chance, chance2h, t.getDamageMultiplier(self, t, 0) * 100, t.getDamageMultiplier(self, t, 100) * 100)
	end,
}

