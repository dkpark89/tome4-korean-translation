-- ToME - Tales of Middle-Earth
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

local function canUseGestures(self)
	local nb = 0
	if self:getInven("MAINHAND") then
		local weapon = self:getInven("MAINHAND")[1]
		if not weapon or weapon.subtype == "mindstar" then nb = nb + 1 end
	end
		
	if self:getInven("OFFHAND") then
		local weapon = self:getInven("OFFHAND")[1]
		if not weapon or weapon.subtype == "mindstar" then nb = nb + 1 end
	end
	
	return nb == 2 and true or false
end

newTalent{
	name = "Gesture of Pain",
	kr_name = "고통의 손짓",
	type = {"cursed/gestures", 1},
	mode = "sustained",
	no_energy = true,
	require = cursed_cun_req1,
	points = 5,
	random_ego = "attack",
	tactical = { ATTACK = 2 },
	getBaseDamage = function(self, t)
		return self:combatTalentMindDamage(t, 0, 130)
	end,
	getBonusDamage = function(self, t)
		local bonus = 0
		if self:getInven("MAINHAND") then
			local weapon = self:getInven("MAINHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.dam or 1) end
		end
		if self:getInven("OFFHAND") then
			local weapon = self:getInven("OFFHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.dam or 1) end
		end
		return bonus
	end,
	getBonusCritical = function(self, t)
		local bonus = 0
		if self:getInven("MAINHAND") then
			local weapon = self:getInven("MAINHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.physcrit or 1) end
		end
		if self:getInven("OFFHAND") then
			local weapon = self:getInven("OFFHAND")[1]
			if weapon and weapon.subtype == "mindstar" then bonus = bonus + (weapon.combat.physcrit or 1) end
		end
	
		return bonus
	end,
	getStunChance = function(self, t)
		return math.max(10, self:getTalentLevelRaw(t) * 2)
	end,
	preAttack = function(self, t, target)
		if not canUseGestures(self) then
			game.logPlayer(self, "고통의 손짓을 취하기 위해서는, 적어도 한 손은 비어있거나 마석만을 들고 있어야 합니다.")
			return false
		end

		return true
	end,
	attack = function(self, t, target)
		local hit = false

		local mindpower = self:combatMindpower()
		local baseDamage = t.getBaseDamage(self, t)
		local bonusDamage = t.getBonusDamage(self, t)
		local bonusCritical = t.getBonusCritical(self, t)
		if self:checkHit(mindpower, target:combatMentalResist()) then
			local damage = self:mindCrit(baseDamage * rng.float(0.5, 1) + bonusDamage, bonusCritical)
			self:project({type="hit", x=target.x,y=target.y}, target.x, target.y, DamageType.MIND, { dam=damage,alwaysHit=true,crossTierChance=25 })
			game:playSoundNear(self, "actions/melee_hit_squish")
			hit = true
		else
			game.logSeen(self, "%s 고통의 손짓을 저항했습니다.", (target.kr_name or target.name):capitalize():addJosa("가"))
			game:playSoundNear(self, "actions/melee_miss")
		end

		if hit then
			local stunChance = t.getStunChance(self, t)
			if rng.percent(stunChance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 3, {apply_power=self:combatMindpower()})
			end
			
			if self:knowTalent(self.T_GESTURE_OF_MALICE) then
				local tGestureOfMalice = self:getTalentFromId(self.T_GESTURE_OF_MALICE)
				local resistAllChange = tGestureOfMalice.getResistAllChange(self, tGestureOfMalice)
				target:setEffect(target.EFF_MALIGNED, tGestureOfMalice.getDuration(self, tGestureOfMalice), { resistAllChange=resistAllChange })
			end
		
			game.level.map:particleEmitter(target.x, target.y, 1, "melee_attack", {color=colors.VIOLET})
		end

		return self:combatSpeed(), hit
	end,
	activate = function(self, t)
		return {  }
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local baseDamage = t.getBaseDamage(self, t)
		local stunChance = t.getStunChance(self, t)
		local bonusDamage = t.getBonusDamage(self, t)
		local bonusCritical = t.getBonusCritical(self, t)
		return ([[일반 공격을 하면서 고통의 손짓을 취해, 적의 정신을 직접 공격합니다. 이를 통해 적에게 %0.1f - %0.1f 정신 피해를 주며, %d%% 확률로 3 턴 동안 기절시킵니다.
		이 공격은 일반 공격을 대체하며, 적은 정신 내성을 통해 저항을 시도합니다. 이 공격은 정확도와 회피도에 따른 명중 계산 없이 무조건 명중합니다. 이 공격은 물리적인 타격 시 발생하는 효과가 발생하지 않지만, 마석의 기본 피해량과 치명타 확률은 이 공격에 더해집니다.
		이 기술은 25%% 확률로 적에게 능력치의 단계 차이 효과를 줄 수 있으며, 일반 공격과 동일하게 치명타를 통해서도 단계 차이 효과를 발생시킬 수 있습니다. 
		두 손 모두 비어있거나 마석만을 들고 있어야 손짓을 취할 수 있으며, 피해량은 정신력 능력치의 영향을 받아 증가합니다.
		현재, 마석으로 인해 피해량이 +%d, 치명타율이 +%d 상승한 상태입니다.]]):format(damDesc(self, DamageType.MIND, baseDamage * 0.5), damDesc(self, DamageType.MIND, baseDamage), stunChance, bonusDamage, bonusCritical)
	end,
}

newTalent{
	name = "Gesture of Malice",
	kr_name = "악의의 손짓",
	type = {"cursed/gestures", 2},
	require = cursed_cun_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t)
		return 5
	end,
	getResistAllChange = function(self, t)
		return -math.min(30, (math.sqrt(self:getTalentLevel(t)) - 0.5) * 12)
	end,
	info = function(self, t)
		local resistAllChange = t.getResistAllChange(self, t)
		local duration = t.getDuration(self, t)
		return ([[고통의 손짓을 강화하여, 적에게 사악한 저주를 추가로 내립니다. %d 턴 동안 적의 전체 저항력을 %d%% 낮춥니다.
		]]):format(duration, -resistAllChange)
	end,
}

newTalent{
	name = "Gesture of Power",
	kr_name = "힘의 손짓",
	type = {"cursed/gestures", 3},
	require = cursed_cun_req3,
	mode = "passive",
	points = 5,
	getMindpowerChange = function(self, t)
		if not canUseGestures(self) then return 0 end

		return math.floor(math.min(20, self:getTalentLevel(t) * 2))
	end,
	getMindCritChange = function(self, t)
		if not canUseGestures(self) then return 0 end

		return math.floor(math.min(14, self:getTalentLevel(t) * 1.2))
	end,
	info = function(self, t)
		local mindpowerChange = t.getMindpowerChange(self, t, 2)
		local mindCritChange = t.getMindCritChange(self, t)
		return ([[근접 공격을 강화시키는 손짓을 취합니다. 정신력이 %d 상승하며, 정신 공격을 할 때 치명타율이 %d%% 상승합니다. (현재 치명타율 : %d%%)
		두 손 모두 비어있거나 마석만을 들고 있어야 손짓을 취할 수 있으며, 이 기술은 고통의 손짓을 유지하지 않아도 적용됩니다.]]):format(mindpowerChange, mindCritChange, self:combatMindCrit())
	end,
}

newTalent{
	name = "Gesture of Guarding",
	kr_name = "수호의 손짓",
	type = {"cursed/gestures", 4},
	require = cursed_cun_req4,
	mode = "passive",
	cooldown = 10,
	points = 5,
	getDamageChange = function(self, t)
		if not canUseGestures(self) then return 0 end
		
		return -math.pow(self:getTalentLevel(t), 0.5) * 14
	end,
	getCounterAttackChance = function(self, t)
		if not canUseGestures(self) then return 0 end
		return math.sqrt(self:getTalentLevel(t)) * 4
	end,
	on_hit = function(self, t, who)
		if rng.percent(t.getCounterAttackChance(self, t)) and self:isTalentActive(self.T_GESTURE_OF_PAIN) and canUseGestures(self) then
			game.logSeen(self, "#F53CBE#%s %s의 공격을 반격합니다!", (self.kr_name or self.name):capitalize():addJosa("가"), (who.kr_name or who.name))
			local tGestureOfPain = self:getTalentFromId(self.T_GESTURE_OF_PAIN)
			tGestureOfPain.attack(self, tGestureOfPain, who)
		end
	end,
	info = function(self, t)
		local damageChange = t.getDamageChange(self, t)
		local counterAttackChance = t.getCounterAttackChance(self, t)
		return ([[근접 공격을 막아내는 손짓을 취하여, 모든 근접 공격의 피해량을 %d%% 만큼 덜 받게 됩니다. 고통의 손짓이 활성화 중일 경우, %d%% 확률로 반격을 할 수 있게 됩니다.
		두 손 모두 비어있거나 마석만을 들고 있어야 손짓을 취할 수 있으며, 이 기술은 고통의 손짓을 유지하지 않아도 적용됩니다.]]):format(-damageChange, counterAttackChance)
	end,
}
