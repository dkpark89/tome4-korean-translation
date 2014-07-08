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

local DamageType = require "engine.DamageType"

newTalent{
	name = "Rend",
	kr_name = "분쇄",
	type = {"corruption/scourge", 1},
	require = corrs_req1,
	points = 5,
	vim = 9,
	cooldown = 6,
	range = 1,
	tactical = { ATTACK = {PHYSICAL = 2} },
	requires_target = true,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "분쇄를 사용하려면 쌍수 무기가 필요합니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		DamageType:projectingFor(self, {project_type={talent=t}})
		local speed1, hit1 = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.6))
		local speed2, hit2 = self:attackTargetWith(target, offweapon.combat, nil, self:getOffHandMult(offweapon.combat, self:combatTalentWeaponDamage(t, 0.8, 1.6)))
		DamageType:projectingFor(self, nil)

		-- Try to bleed !
		if hit1 then
			if target:canBe("cut") then
				target:setEffect(target.EFF_CUT, 5, {power=self:combatTalentSpellDamage(t, 5, 40), src=self, apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 출혈을 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end
		if hit2 then
			if target:canBe("cut") then
				target:setEffect(target.EFF_CUT, 5, {power=self:combatTalentSpellDamage(t, 5, 40), src=self, apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 출혈을 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[쌍수 무기로 대상을 공격하여, 각각 %d%% 피해를 줍니다. 매 타격마다 대상을 출혈 상태로 만들어, 5 턴 동안 매 턴마다 %0.2f 피해를 줄 수 있습니다.
		출혈 효과는 주문력의 영향을 받아 증가합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.6), self:combatTalentSpellDamage(t, 5, 40))
	end,
}

newTalent{
	name = "Ruin",
	kr_name = "파멸",
	type = {"corruption/scourge", 2},
	mode = "sustained",
	require = corrs_req2,
	points = 5,
	sustain_vim = 40,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local ret = {}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local dam = damDesc(self, DamageType.BLIGHT, t.getDamage(self, t))
		return ([[오염과 타락의 힘에 집중하여, 근접 공격을 할 때마다 적에게 %0.2f 황폐 속성 피해를 주고 자신은 %0.2f 생명력을 회복합니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(dam, dam * 0.4)
	end,
}

newTalent{
	name = "Acid Strike",
	kr_name = "산성 타격",
	type = {"corruption/scourge", 3},
	require = corrs_req3,
	points = 5,
	vim = 18,
	cooldown = 12,
	range = 1,
	radius = 1,
	requires_target = true,
	tactical = { ATTACK = {ACID = 2}, DISABLE = 1 },
	target = function(self, t)
		-- Tries to simulate the acid splash
		return {type="ballbolt", range=1, radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "산성 타격을 사용하려면 쌍수 무기가 필요합니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		DamageType:projectingFor(self, {project_type={talent=t}})
		local speed1, hit1 = self:attackTargetWith(target, weapon.combat, DamageType.ACID, self:combatTalentWeaponDamage(t, 0.8, 1.6))
		local speed2, hit2 = self:attackTargetWith(target, offweapon.combat, DamageType.ACID, self:getOffHandMult(offweapon.combat, self:combatTalentWeaponDamage(t, 0.8, 1.6)))
		DamageType:projectingFor(self, nil)

		-- Acid splash !
		if hit1 or hit2 then
			local tg = self:getTalentTarget(t)
			tg.x = target.x
			tg.y = target.y
			self:project(tg, target.x, target.y, DamageType.ACID, self:spellCrit(self:combatTalentSpellDamage(t, 10, 130)))
		end

		return true
	end,
	info = function(self, t)
		return ([[쌍수 무기로 대상을 공격하여, 각각 %d%% 무기 피해를 산성 속성으로 줍니다.
		공격이 한 번이라도 적중하면, 산이 튀어 대상 주변의 적들에게 %0.2f 산성 피해를 줍니다.
		산성 피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.6), damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 10, 130)))
	end,
}

newTalent{
	name = "Dark Surprise",
	kr_name = "어둠의 기습",
	type = {"corruption/scourge", 4},
	require = corrs_req4,
	points = 5,
	vim = 14,
	cooldown = 8,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = {DARKNESS = 1, BLIGHT = 1}, DISABLE = 2 },
	action = function(self, t)
		local weapon, offweapon = self:hasDualWeapon()
		if not weapon then
			game.logPlayer(self, "어둠의 기습을 사용하려면 쌍수 무기가 필요합니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		DamageType:projectingFor(self, {project_type={talent=t}})
		local speed1, hit1 = self:attackTargetWith(target, weapon.combat, DamageType.DARKNESS, self:combatTalentWeaponDamage(t, 0.6, 1.4))

		if hit1 then
			self.turn_procs.auto_phys_crit = true
			local speed2, hit2 = self:attackTargetWith(target, offweapon.combat, DamageType.BLIGHT, self:getOffHandMult(offweapon.combat, self:combatTalentWeaponDamage(t, 0.6, 1.4)))
			self.turn_procs.auto_phys_crit = nil
			if hit2 and target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 4, {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(self, "%s 어둠을 이겨냈습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end
		DamageType:projectingFor(self, nil)

		return true
	end,
	info = function(self, t)
		return ([[대상을 주 무기로 공격하여 %d%% 무기 피해를 어둠 속성으로 줍니다. 첫 번째 공격이 성공하면, 대상을 보조 무기로 공격하여 %d%% 황폐 속성 피해를 주며 이 공격은 언제나 치명타 효과가 발생합니다.
		두 번째 공격까지 성공하면, 대상은 4 턴 동안 실명 상태가 됩니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.6, 1.4), 100 * self:combatTalentWeaponDamage(t, 0.6, 1.4))
	end,
}

