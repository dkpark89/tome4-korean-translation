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

require "engine.krtrUtils" --@@

newTalent{
	name = "Uppercut",
	kr_display_name = "올려치기",
	type = {"technique/finishing-moves", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 12,
	message = "@Source1@ 마무리로 올려쳤습니다!",
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.8) + getStrikingStyle(self, dam) end,
	getDuration = function(self, t) return math.ceil(self:getTalentLevel(t) * (0.25 + (self:getCombo(combo) /5))) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local stun = math.ceil(self:getTalentLevel(t) * 0.25)
		local stunmax = math.ceil (self:getTalentLevel(t) * 1.25)
		return ([[적을 올려쳐서 %d%% 의 피해를 주고, 연계 점수에 따라 %d 에서 %d 턴 동안 기절시킵니다.
		기절 확률은 물리력 능력치의 영향을 받아 증가합니다.
		이 기술은 마무리 기술이기 때문에, 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, stun, stunmax)
	end,
}

newTalent{
	name = "Concussive Punch",
	kr_display_name = "충격타",
	type = {"technique/finishing-moves", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 10,
	message = "@Source1@ 마무리로 충격타를 날렸습니다!",
	tactical = { ATTACK = { weapon = 2 }, },
	radius = function(self, t) return 1 + math.floor(self:getTalentLevel(t) / 4) end,
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.8) + getStrikingStyle(self, dam) end,
	getAreaDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 10, 300) * (1 + getStrikingStyle(self, dam)) end,
	radius = function(self, t)
		return 1 + math.floor(self:getTalentLevel(t) / 4)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			local tg = {type="ball", range=1, radius=self:getTalentRadius(t), selffire=false, talent=t}
			local damage = t.getAreaDamage(self, t) * (0.25 + (self:getCombo(combo) /5))
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
		광역 피해량은 힘 능력치의 영향을 받아 증가하며, 피해 반경은 기술 레벨이 4 증가할 때마다 1 씩 증가합니다.
		이 기술은 마무리 기술이기 때문에, 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, radius, damDesc(self, DamageType.PHYSICAL, area), damDesc(self, DamageType.PHYSICAL, areamax))
	end,
}

newTalent{
	name = "Body Shot",
	kr_display_name = "몸통 치기",
	type = {"technique/finishing-moves", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 10,
	message = "@Source1@ 마무리로 몸통을 가격했습니다!",
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.8) + getStrikingStyle(self, dam) end,
	getDuration = function(self, t) return math.ceil(self:getTalentLevel(t) * (0.25 + (self:getCombo(combo) /5))) end,
	getDrain = function(self, t) return (self:getTalentLevel(t) * 2) * self:getCombo(combo) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			-- try to daze
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 혼절하지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end

			target:incStamina(- t.getDrain(self, t))

		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local drain = self:getTalentLevel(t) * 2
		local daze = math.ceil(self:getTalentLevel(t) * 0.25)
		local dazemax = math.ceil (self:getTalentLevel(t) * 1.25)
		return ([[대상의 몸통을 가격하여 %d%% 의 피해를 주고, 연계 점수당 대상의 체력을 %d 씩 소진시키며, 연계 점수에 따라 대상을 %d 에서 %d 턴 동안 혼절시킵니다.
		혼절 확률은 물리력 능력치의 영향을 받아 증가합니다.
		이 기술은 마무리 기술이기 때문에, 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, drain, daze, dazemax)
	end,
}

newTalent{
	name = "Haymaker",
	kr_display_name = "죽음의 강타",
	type = {"technique/finishing-moves", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 16,
	stamina = 12,
	message = "@Source1@ 마무리로 죽음의 강타를 날렸습니다!",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.4, 2.1) + getStrikingStyle(self, dam) end,
	getBonusDamage = function(self, t) return self:getCombo(combo)/10 end,
	getStamina = function(self, t) return ((self:getTalentLevel(t) + self:getCombo(combo))/50) * self.max_stamina end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local damage = t.getDamage(self, t) + (t.getBonusDamage(self, t) or 0)

		local hit = self:attackTarget(target, nil, damage, true)

		-- Try to insta-kill
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("instakill") and target.life > target.die_at and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s 에게 죽음의 고통을 안겨줬습니다!", (target.kr_display_name or target.name):capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s 죽음의 고통을 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		-- restore stamina
		if target.dead then
			self:incStamina(t.getStamina(self, t))
		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local stamina = math.ceil((self:getTalentLevel(t) + 1)) * 2
		local staminamax = math.ceil((self:getTalentLevel(t) + 5)) * 2
		return ([[%d%% 의 피해에 추가로 연계 점수당 10%%의 피해를 주는 치명적인 타격을 가합니다.
		공격을 받은 대상이 빈사상태 (생명력 20%% 미만) 이며 대상이 저항하지 못했을 경우, 대상은 즉사합니다.
		죽음의 강타로 적을 쓰러뜨리면, 연계 점수에 따라 최대 체력의 %d%% 에서 %d%% 에 해당하는 체력이 회복됩니다.
		이 기술은 마무리 기술이기 때문에, 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, stamina, staminamax)
	end,
}

