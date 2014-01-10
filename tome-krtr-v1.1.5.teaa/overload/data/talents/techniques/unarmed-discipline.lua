-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	name = "Push Kick",
	kr_name = "밀어차기",
	type = {"technique/unarmed-discipline", 1},
	require = techs_dex_req1,
	points = 5,
	cooldown = 6,
	stamina = 12,
	tactical = { ATTACK = { PHYSICAL = 2 }, ESCAPE = { knockback = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 100) * getUnarmedTrainingBonus(self) end,
	getPush = function(self, t) return math.ceil(self:combatTalentScale(t, 1.1, 2.1)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = target:checkHit(self:combatAttack(), target:combatDefense(), 0, 95) and not self:checkEvasion(target)
		-- Try to knockback !
		if hit then
			local can = function(target)
				if target:checkHit(self:combatAttack(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
					self:project(target, target.x, target.y, DamageType.PHYSICAL, t.getDamage(self, t))
					return true
				else
					self:project(target, target.x, target.y, DamageType.PHYSICAL, t.getDamage(self, t))
					game.logSeen(target, "%s 밀려나지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				end

			end

			if can(target) then target:knockback(self.x, self.y, t.getPush(self, t), can) end

			-- move the attacker back
			self:knockback(target.x, target.y, 1)
			self:breakGrapples()
			self:buildCombo()

		else
			self:logCombat(target, "#Source1# #Target3# 빗맞췄습니다.")
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local push = t.getPush(self, t)
		return ([[밀어차기를 날려 대상을 %d 칸 밀어내고, %0.2f 물리 피해를 줍니다. 반동으로 인해 자신도 1 칸 밀려나며, 대상이 밀려날 때 다른 대상과 부딪히면 추가 피해를 주고 다른 대상도 같이 밀려납니다.
		이 기술을 통해 1 의 연계 점수를 획득할 수 있습니다. 무언가를 붙잡고 있을 때 이 기술을 사용하면, 붙잡기가 풀립니다.
		피해량은 물리력의 영향을 받아 증가합니다.]]):
		format(push, damDesc(self, DamageType.PHYSICAL, (damage)))
	end,
}

newTalent{
	name = "Defensive Throw",
	kr_name = "되치기",
	type = {"technique/unarmed-discipline", 2},
	require = techs_dex_req2,
	mode = "passive",
	points = 5,
	-- Limit defensive throws/turn for balance using a buff (warns attacking players of the talent)	
	-- EFF_DEFENSIVE_GRAPPLING effect is refreshed each turn in _M:actBase in mod.class.Actor.lua
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 50) * getUnarmedTrainingBonus(self) end,
	getDamageTwo = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 75) * getUnarmedTrainingBonus(self) end,
	getchance = function(self, t)
		return self:combatLimit(self:getTalentLevel(t) * (5 + self:getCun(5, true)), 100, 0, 0, 50, 50) -- Limit < 100%
	end,
	getThrows = function(self, t)
		return self:combatScale(self:getStr() + self:getDex()-20, 0, 0, 2.24, 180)
	end,
	-- called by _M:attackTargetWith function in mod\class\interface\Combat.lua (includes adjacency check)
	do_throw = function(self, target, t)
		local ef = self:hasEffect(self.EFF_DEFENSIVE_GRAPPLING)
		if not ef or not rng.percent(self.tempeffect_def.EFF_DEFENSIVE_GRAPPLING.throwchance(self, ef)) then return end
		local grappled = target:isGrappled(self)
		local hit = self:checkHit(self:combatAttack(), target:combatDefense(), 0, 95) and (grappled or not self:checkEvasion(target)) -- grappled target can't evade
		ef.throws = ef.throws - 1
		if ef.throws <= 0 then self:removeEffect(self.EFF_DEFENSIVE_GRAPPLING) end
		
		if hit then
			self:project(target, target.x, target.y, DamageType.PHYSICAL, self:physicalCrit(t.getDamageTwo(self, t), nil, target, self:combatAttack(), target:combatDefense()))
			-- if grappled stun
			if grappled and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2, {apply_power=self:combatAttack(), min_dur=1})
				self:logCombat(target, "#Source1# #Target3# 바닥에 내려꽂았습니다!")
			-- if not grappled daze
			else
				self:logCombat(target, "#Source1# #Target3# 바닥에 넘어뜨렸습니다!")
				-- see if the throw dazes the enemy
				if target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, 2, {apply_power=self:combatAttack(), min_dur=1})
				end
			end
		else
			self:logCombat(target, "#Source2# #Target#의 공격을 되치는데 실패했습니다!", (self.kr_name or self.name):capitalize(), (target.kr_name or target.name):capitalize()) 
		end
	end,
	on_unlearn = function(self, t)
		self:removeEffect(self.EFF_DEFENSIVE_GRAPPLING)
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damagetwo = t.getDamageTwo(self, t)
		return ([[맨손전투 상태에서 근접공격을 회피할 때마다, %d%% 확률로 공격자를 넘어뜨립니다. 공격자가 넘어지면 %0.2f 피해를 받고, 2 턴 동안 혼절합니다.
		공격자를 붙잡고 있었다면 %0.2f 피해를 주고, 2 턴 동안 기절시킵니다. 매 턴마다 최대 %0.1f 번의 되치기를 시도할 수 있습니다.
		되치기 확률은 정확도 능력치에 따라 증가하며, 피해량은 물리력에 따라 증가하고, 턴당 최대 되치기 시도 횟수는 힘 능력치와 민첩 능력치에 따라 증가합니다.]]):
		format(t.getchance(self,t), damDesc(self, DamageType.PHYSICAL, (damage)), damDesc(self, DamageType.PHYSICAL, (damagetwo)), t.getThrows(self, t))
	end,
}

newTalent{
	name = "Breath Control",
	kr_name = "호흡 조절",
	type = {"technique/unarmed-discipline", 3},
	require = techs_dex_req3,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 15,
	tactical = { BUFF = 1, STAMINA = 2 },
	getSpeed = function(self, t) return 0.1 end,
	getStamina = function(self, t) return self:combatTalentScale(t, 2, 7.5, 0.75) end,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("global_speed_add", -t.getSpeed(self, t)),
			stamina = self:addTemporaryValue("stamina_regen", t.getStamina(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("global_speed_add", p.speed)
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	info = function(self, t)
		local speed = t.getSpeed(self, t)
		local stamina = t.getStamina(self, t)
		return ([[호흡법에 집중하여 채력 재생량이 턴 당 %0.2f 증가하는 대신, 전체 속도가 %d%% 떨어집니다.]]):
		format(stamina, speed * 100)
	end,
}

newTalent{
	name = "Roundhouse Kick",
	kr_name = "돌려차기",
	type = {"technique/unarmed-discipline", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 18,
	range = 0,
	radius = function(self, t) return 1 end,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 15, 150) * getUnarmedTrainingBonus(self) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end

		self:breakGrapples()

		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dam=t.getDamage(self, t), dist=4})

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[돌려차기로 전방의 적들을 공격해, %0.2f 물리 피해를 주고 적들을 뒤로 밀어냅니다.
		무언가를 붙잡고 있을 때 이 기술을 사용하면, 붙잡기가 풀립니다.
		물리 피해량은 물리력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.PHYSICAL, (damage)))
	end,
}

