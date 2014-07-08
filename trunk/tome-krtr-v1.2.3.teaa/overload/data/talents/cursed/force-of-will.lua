-- ToME - Tales of Middle-Earth
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

-- damage: initial physical damage and used for fractional knockback damage
-- knockback: distance to knockback
-- knockbackDamage: when knockback strikes something, both parties take damage - percent of damage * remaining knockback
-- power: used to determine the initial radius of particles

local function forceHit(self, t, target, sourceX, sourceY, damage, knockback, knockbackDamage, power, max)
	-- apply initial damage
	if damage > 0 then
		damage = self:mindCrit(damage)
		self:project({type="hit", range=10, talent=t}, target.x, target.y, DamageType.PHYSICAL, damage)
		game.level.map:particleEmitter(target.x, target.y, 1, "force_hit", {power=power, dx=target.x - sourceX, dy=target.y - sourceY})
	end

	-- knockback?
	if not target.dead and knockback and knockback > 0 and target:canBe("knockback") and (target.never_move or 0) < 1 then
		-- give direct hit a direction?
		if sourceX == target.x and sourceY == target.y then
			local newDirection = rng.table(util.adjacentDirs())
			local dx, dy = util.dirToCoord(newDirection, sourceX, sourceY)
			sourceX = sourceX + dx
			sourceY = sourceY + dy
		end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", target) end
		local lineFunction = core.fov.line(sourceX, sourceY, target.x, target.y, block_actor, true)
		local finalX, finalY = target.x, target.y
		local knockbackCount = 0
		local blocked = false
		while knockback > 0 do
			local x, y, is_corner_blocked = lineFunction:step(true)

			if not game.level.map:isBound(x, y) or is_corner_blocked or game.level.map:checkAllEntities(x, y, "block_move", target) then
				-- blocked
				local nextTarget = game.level.map(x, y, Map.ACTOR)
				if nextTarget then
					if knockbackCount > 0 then
						target:logCombat(nextTarget, "#Source2# %d 칸 밀려나 #Target6# 부딪쳤습니다!", knockbackCount)
					else
						target:logCombat(nextTarget, "#Source2# #Target6# 부딪쳤습니다!")
					end
				elseif knockbackCount > 0 then
					game.logSeen(target, "%s %d 칸 밀려났습니다!", (target.kr_name or target.name):capitalize():addJosa("은"), knockbackCount)
				else
					game.logSeen(target, "%s 밀려났습니다!", (target.kr_name or target.name):capitalize():addJosa("은"))
				end

				-- take partial damage
				local blockDamage = damage * util.bound(knockback * (knockbackDamage / 100), 0, 1.5)
				self:project({type="hit", range=10, talent=t}, target.x, target.y, DamageType.PHYSICAL, blockDamage)

				if nextTarget then
					-- start a new force hit with the knockback damage and current knockback
					if max > 0 then
						forceHit(self, t, nextTarget, sourceX, sourceY, blockDamage, knockback, knockbackDamage, power / 2, max - 1)
					end
				end

				knockback = 0
				blocked = true
			else
				-- allow move
				finalX, finalY = x, y
				knockback = knockback - 1
				knockbackCount = knockbackCount + 1
			end
		end

		if not blocked and knockbackCount > 0 then
			game.logSeen(target, "%s %d 칸 밀려났습니다!", (target.kr_name or target.name):capitalize():addJosa("은"), knockbackCount)
		end

		if not target.dead and (finalX ~= target.x or finalY ~= target.y) then
			local ox, oy = target.x, target.y
			target:move(finalX, finalY, true)
			if config.settings.tome.smooth_move > 0 then
				target:resetMoveAnim()
				target:setMoveAnim(ox, oy, 9, 5)
			end
		end
	end
end

newTalent{
	name = "Willful Strike",
	kr_name = "의지의 타격",
	type = {"cursed/force-of-will", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 5,
	hate = 5,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	direct_hit = true,
	requires_target = true,
	range = 3,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 280)
	end,
	getKnockback = function(self, t)
		return 2
	end,
	critpower = function(self, t) return self:combatTalentScale(t, 4, 15) end,
	action = function(self, t)
		local range = self:getTalentRange(t)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end

		--local distance = math.max(1, core.fov.distance(self.x, self.y, x, y))
		local power = 1 --(1 - ((distance - 1) / range))
		local damage = t.getDamage(self, t) * power
		local knockback = t.getKnockback(self, t)
		forceHit(self, t, target, self.x, self.y, damage, knockback, 7, power, 10)
		return true
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_critical_power", t.critpower(self, t))
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		return ([[증오심을 집중하여, 보이지 않는 힘으로 적을 공격합니다. 이를 통해 적에게 %d 피해를 주고, %d 칸 뒤로 밀어냅니다.
		추가적으로, 기술 레벨이 오를 때마다 힘의 통로가 개방되어 기술 유지 중 모든 치명타 배수를 %d%% 증가시킵니다. (현재 : %d%%)
		피해량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.PHYSICAL, damage), knockback, t.critpower(self, t), self.combat_critical_power or 0)
	end,
}

newTalent{
	name = "Deflection",
	kr_name = "굴절",
	type = {"cursed/force-of-will", 2},
	mode = "sustained",
	no_energy = true,
	require = cursed_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	tactical = { DEFEND = 2 },
	no_sustain_autoreset = true,
	getMaxDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 240)
	end,
	getDisplayName = function(self, t, p)
		return ("굴절 (%d)"):format(p.value)
	end,
	critpower = function(self, t) return self:combatTalentScale(t, 4, 15) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		return {
			value = 0,
			__update_display = true,
		}
	end,
	deactivate = function(self, t, p)
		if p.particles then self:removeParticles(p.particles) end
		p.particles = nil
		return true
	end,
	do_act = function(self, t, p)
		local maxDamage = t.getMaxDamage(self, t)
		if p.value < maxDamage and self.hate >= 0.2 then
			self:incHate(-0.2)

			p.value = math.min(p.value + maxDamage / 35, maxDamage)
			p.__update_display = true

			t.updateParticles(self, t, p)
		end
	end,
	do_onTakeHit = function(self, t, p, damage)
		if p.value > 0 then
			-- absorb 50% damage
			local deflectDamage = math.floor(math.min(damage * 0.5, p.value))
			if deflectDamage > 0 then
				damage = damage - deflectDamage
				p.value = math.max(0, p.value - deflectDamage)
				p.__update_display = true
				t.updateParticles(self, t, p)

				game.logPlayer(self, "받은 피해량을 %d 만큼 튕겨냈습니다!", deflectDamage)
			end
		end
		return damage
	end,
	updateParticles = function(self, t, p)
		local power = 1 + math.floor(p.value / t.getMaxDamage(self, t) * 9)
		if not p.particles or p.power ~= power then
			if p.particles then self:removeParticles(p.particles) end
			p.particles = self:addParticles(Particles.new("force_deflection", 1, { power = power }))
			p.power = power
		end
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_critical_power", t.critpower(self, t))
	end,
	info = function(self, t)
		local maxDamage = t.getMaxDamage(self, t)
		return ([[매 턴마다 0.2 만큼 증오를 소모하는 방벽을 만들어냅니다. 이 방벽은 의지의 힘으로 시전자가 받는 피해량을 최대 50%% 까지 튕겨내며, 최대 %d 피해량까지 튕겨낼 수 있습니다. 방벽은 매 턴마다 최대로 튕겨낼 수 있는 수치의 1/35 만큼을 충전합니다.
		예를 들어 최대 70 피해량을 튕겨낼 수 있다면, 방벽은 매 턴마다 2 씩 충전됩니다. 이는 35 턴 후, 최대 충전량인 70 에 도달하면 멈추게 됩니다. 이 상태에서 30 의 피해를 받으면, 50%% 에 해당하는 15 의 피해를 튕겨내고 방벽의 충전량은 55 가 됩니다.
		추가적으로, 기술 레벨이 오를 때마다 힘의 통로가 개방되어 기술 유지 중 모든 치명타 배수를 %d%% 증가시킵니다. (현재 : %d%%)
		방벽이 튕겨낼 수 있는 최대 피해량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(maxDamage, t.critpower(self, t), self.combat_critical_power or 0)
	end,
}

newTalent{ 
	name = "Blast",
	kr_name = "돌풍",
	type = {"cursed/force-of-will", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { stun = 1 } },
	requires_target = true,
	hate = 12,
	range = 4,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 300)
	end,
	getKnockback = function(self, t)
		return 2
	end,
	target = function(self, t)
		return {type="ball", nolock=true, pass_terrain=false, friendly_fire=false, nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDazeDuration = function(self, t)
		return 3
	end,
	critpower = function(self, t) return self:combatTalentScale(t, 4, 15) end,
	action = function(self, t) --NOTE TO DG, SINCE I CAN'T UNDERSTAND A WORD OF BENLI'S CODE: EDIT SO THAT KNOCKBACK OCCURS AFTER DAMAGE, AND SEPARATELY, TO PREVENT ENEMIES BEING SHOVED INTO A NEW SPACE AND HIT AGAIN.
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)

		local tg = self:getTalentTarget(t)
		local blastX, blastY = self:getTarget(tg)
		if not blastX or not blastY or core.fov.distance(self.x, self.y, blastX, blastY) > range then return nil end

		local grids = self:project(tg, blastX, blastY,
			function(x, y, target, self)
				-- your will ignores friendly targets (except for knockback hits)
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					local distance = core.fov.distance(blastX, blastY, x, y)
					local power = (1 - (distance / radius))
					local localDamage = damage * power
					local dazeDuration = t.getDazeDuration(self, t)

					forceHit(self, t, target, blastX, blastY, damage, math.max(0, knockback - distance), 7, power, 10)
					if target:canBe("stun") then
						target:setEffect(target.EFF_DAZED, dazeDuration, {src=self})
					end
				end
			end,
			nil, nil)

		local _ _, _, _, x, y = self:canProject(tg, blastX, blastY)
		game.level.map:particleEmitter(x, y, tg.radius, "force_blast", {radius=tg.radius})
		game:playSoundNear(self, "talents/fireflash")

		return true
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_critical_power", t.critpower(self, t))
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		local dazeDuration = t.getDazeDuration(self, t)
		return ([[분노의 감정을 한 곳에 뭉쳐, 폭발시킵니다. 주변 %d 칸 반경의 적들에게 %d 피해를 주며, 폭발의 중심부에 있던 적은 %d 칸 밀려납니다. (멀리 있는 적일수록 밀려나는 거리가 줄어듭니다) 폭발에 휩쓸린 모든 적들은 3 턴 동안 혼절합니다.
		추가적으로, 기술 레벨이 오를 때마다 힘의 통로가 개방되어 기술 유지 중 모든 치명타 배수를 %d%% 증가시킵니다. (현재 : %d%%)
		피해량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(radius, damDesc(self, DamageType.PHYSICAL, damage), knockback, t.critpower(self, t), self.combat_critical_power or 0)
	end,
}

newTalent{
	name = "Unseen Force",
	kr_name = "보이지 않는 힘",
	type = {"cursed/force-of-will", 4},
	require = cursed_wil_req4,
	points = 5,
	hate = 18,
	cooldown = 30,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	range = 4,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10))	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 140)
	end,
	getKnockback = function(self, t)
		return 2
	end,
	-- Minimum effects until tLvl > 4
	getAdjustedTalentLevel = function(self, t)
		local tLevel = self:getTalentLevel(self, t) - 4
		-- Do not feed a negative talent level to the scaling functions
		if tLevel < 0 then
			tLevel = 0
		end
		return tLevel
	end,
	getSecondHitChance = function(self, t)
		return self:combatTalentScale(t.getAdjustedTalentLevel(self, t), 15, 35)
	end,
	action = function(self, t)
		game.logSeen(self, "보이지 않는 힘이 %s 주변을 휘몰아치기 시작합니다!", (self.kr_name or self.name))
		local duration = t.getDuration(self, t)
		local particles = self:addParticles(Particles.new("force_area", 1, { radius = self:getTalentRange(t) }))

		self.unseenForce = { duration = duration, particles = particles }
		return true
	end,
	do_unseenForce = function(self, t)
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					targets[#targets+1] = a
				end
			end
		end

		if #targets > 0 then
			local damage = t.getDamage(self, t)
			local knockback = t.getKnockback(self, t)

			local xtrahits = t.getSecondHitChance(self,t)/100
			local hitCount = 1 + math.floor(xtrahits)
			if rng.percent(xtrahits - math.floor(xtrahits)*100) then hitCount = hitCount + 1 end

			-- Randomly take targets
			for i = 1, hitCount do
				local target, index = rng.table(targets)
				forceHit(self, t, target, target.x, target.y, damage, knockback, 7, 0.6, 10)
			end
		end

		self.unseenForce.duration = self.unseenForce.duration - 1
		if self.unseenForce.duration <= 0 then
			self:removeParticles(self.unseenForce.particles)
			self.unseenForce = nil
			game.logSeen(self, "%s 주변을 휘몰아치던 보이지 않는 힘이 사라집니다.", (self.kr_name or self.name))
		end
	end,
	critpower = function(self, t) return self:combatTalentScale(t, 4, 15) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_critical_power", t.critpower(self, t))
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		local knockback = t.getKnockback(self, t)
		local secondHitChance = t.getSecondHitChance(self, t)
		local hits = 1 + math.floor(secondHitChance/100)
		local chance = secondHitChance - math.floor(secondHitChance/100)*100
		return ([[극한의 분노심이 보이지 않는 힘이 되어, 주변에 휘몰아치게 됩니다. %d 턴 동안, 주변의 %d 명(%d%% 확률로 %d 명)에게 %d 피해를 주고 %d 칸 밀어낼 수 있게 됩니다. 기술 레벨이 높아지면, %d%% 확률로 한 턴에 두 번의 공격을 하게 됩니다.
		추가적으로, 기술 레벨이 오를 때마다 힘의 통로가 개방되어 모든 치명타 배수를 %d%% 증가시킵니다. (현재 : %d%%)
		피해량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(duration, hits, chance, hits+1, damDesc(self, DamageType.PHYSICAL, damage), knockback, secondHitChance, t.critpower(self, t), self.combat_critical_power or 0) --@ 변수 조정 : 원래 코드가 잘못된 것을 제대로 수정
	end,
}

