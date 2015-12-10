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

newTalent{
	name = "Uppercut",
	kr_name = "올려치기",
	type = {"technique/finishing-moves", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 12,
	message = "@Source@는 연계기의 마무리로 올려치기를 사용했습니다!",
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	range = 1,
	is_melee = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.8) + getStrikingStyle(self, dam) end,
	getDuration = function(self, t, comb) return 2 + math.ceil(self:combatTalentScale(t, 1, 5) * (0.25 + comb/5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		-- breaks active grapples if the target is not grappled
		if not target:isGrappled(self) then
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t, self:getCombo(combo)), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local stun = t.getDuration(self, t, 0)
		local stunmax = t.getDuration(self, t, 5)
		return ([[적을 올려쳐서 %d%% 의 피해를 주고, 연계 점수에 따라 %d 에서 %d 턴 동안 기절시킵니다.
		기절 확률은 물리력의 영향을 받아 증가합니다.
		이 기술을 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, stun, stunmax)
	end,
}

-- Low CD makes this more or less the "default" combo point dump for damage
-- Its pretty crap at low combo point
newTalent{
	name = "Concussive Punch",
	kr_name = "충격타",
	type = {"technique/finishing-moves", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 20,
	message = "@Source@는 연계기의 마무리로 충격타를 날렸습니다.",
	tactical = { ATTACK = { weapon = 2 }, },
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	range = 1,
	is_melee = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.6, 1.5) + getStrikingStyle(self, dam) end,
	getAreaDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 10, 450) * (1 + getStrikingStyle(self, dam)) end,
	radius = function(self, t) return (1 + self:getCombo(combo) ) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		-- breaks active grapples if the target is not grappled
		if not target:isGrappled(self) then
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			local tg = {type="ball", range=1, radius=self:getTalentRadius(t), selffire=false, talent=t}
			local damage = self:physicalCrit(t.getAreaDamage(self, t) * (0.25 + (self:getCombo(combo) /5)), nil, target, self:combatAttack(), target:combatDefense())
			--local damage = self:physicalCrit(t.getAreaDamage(self, t) * (0.25 + (self:getCombo(combo) /5)))
			self:project(tg, x, y, DamageType.PHYSICAL, damage)
			game.level.map:particleEmitter(x, y, tg.radius, "ball_earth", {radius=tg.radius})
			game:playSoundNear(self, "talents/breath")
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local area = t.getAreaDamage(self, t) * 0.25
		local areamax = t.getAreaDamage(self, t) * 1.25
		local radius = self:getTalentRadius(t)
		return ([[강력한 충격이 실린 주먹으로 대상을 가격하여 %d%% 의 피해를 주고, 공격이 성공하면 반경 %d 칸 내의 모든 적들에게 연계 점수에 따라 %0.2f - %0.2f 의 물리 피해를 줍니다.
		광역 피해량은 힘 능력치의 영향을 받아 증가하며, 피해 반경은 연계 점수만큼 증가합니다.
		이 기술을 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, radius, damDesc(self, DamageType.PHYSICAL, area), damDesc(self, DamageType.PHYSICAL, areamax))
	end,
}

newTalent{
	name = "Butterfly Kick",
	kr_name = "나비차기",
	type = {"technique/finishing-moves", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		return math.ceil(self:combatTalentLimit(t, 0, 30, 10)) -- Limit > 0
	end,
	stamina = 20,
	tactical = { ATTACKAREA = { weapon = 2 }, CLOSEIN = 1 },
	range = function(self, t)
		return 2 + self:getCombo(combo)
	end,
	radius = function(self, t)
		return 1
	end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 1, 1.5) + getStrikingStyle(self, dam)
	end,
	getBonusDamage = function(self, t) return (self:getCombo(combo)/10) or 0 end,
	requires_target = true,
--	no_npc_use = true, -- I mark this by default if I don't understand how the AI might use something, which is always
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), nolock = true}
	end,
	is_melee = true,
	action = function(self, t)
		if not (self:getCombo(combo) > 0) then return end -- abort if we have no CP, this is to make it base 2+requires CP because base 1 autotargets in melee range
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)

		if game.level.map(x, y, Map.ACTOR) then
			x, y = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
			if not x then return end
		end

		if game.level.map:checkAllEntities(x, y, "block_move") then return end

		local ox, oy = self.x, self.y
		self:move(x, y, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end

		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local totalDamage = t.getDamage(self, t) * (1 + t.getBonusDamage(self, t) )


				local hit = self:attackTarget(target, nil, totalDamage, true)
			end
		end)

		self:clearCombo()
		return true
	end,
	info = function(self, t)
		return ([[공중에서 날아차, 착지 지점 주변 1 칸에 있는 모든 적들에게 %d%% 무기 피해를 가합니다. 사거리는 연계 점수가 증가할 때마다 늘어나며, 총 피해량 역시 연계 점수 당 10%% 씩 상승합니다.
		이 기술을 사용하면 연계 점수가 초기화됩니다.]]):format(t.getDamage(self, t)*100)
	end,
}

newTalent{
	name = "Haymaker",
	kr_name = "죽음의 강타",
	type = {"technique/finishing-moves", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 12,
	message = "@Source@는 연계기의 마무리로 죽음의 강타를 날렸습니다!",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 3) + getStrikingStyle(self, dam) end,
	getBonusDamage = function(self, t) return self:getCombo(combo)/5 end, -- shift more of the damage to CP
	getStamina = function(self, t, comb)
		return self:combatLimit((self:getTalentLevel(t) + comb), 0.5, 0, 0, 0.2, 10) * self.max_stamina
	end, -- Limit 50% stamina gain
	is_melee = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		-- breaks active grapples if the target is not grappled
		if not target:isGrappled(self) then
			self:breakGrapples()
		end

		local damage = t.getDamage(self, t) * (1 + (t.getBonusDamage(self, t) or 0))

		local hit = self:attackTarget(target, nil, damage, true)

		-- Try to insta-kill
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("instakill") and target.life > target.die_at and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s 에게 죽음의 고통을 안겨줬습니다!", target.name:capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s 죽음의 고통을 저항했습니다!",  (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		-- restore stamina
		if target.dead then
			self:incStamina(t.getStamina(self, t, self:getCombo(combo)))
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local maxDamage = damage * 2
		local stamina = t.getStamina(self, t, 0)/self.max_stamina*100
		local staminamax = t.getStamina(self, t, 5)/self.max_stamina*100
		return ([[%d%% 의 피해에 연계 점수당 20%% 의 추가 피해(최대 추가 피해 최대 %d%%)를 주는, 치명적인 타격을 가합니다.
		공격을 받은 대상이 빈사상태 (생명력 20%% 미만) 이며 대상이 저항하지 못했을 경우, 대상은 즉사합니다.
		죽음의 강타로 적을 쓰러뜨리면, 연계 점수에 따라 최대 체력의 %d%% 에서 %d%% 에 해당하는 체력이 회복됩니다.
		이 기술을 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, maxDamage, stamina, staminamax)
	end,
}
