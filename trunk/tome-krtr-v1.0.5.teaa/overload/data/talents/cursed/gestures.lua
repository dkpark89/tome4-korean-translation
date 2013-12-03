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
	local dam, nb = 0, 0
	local weapon

	if self:getInven("OFFHAND") then
		weapon = self:getInven("OFFHAND")[1]
		if not weapon or weapon.subtype == "mindstar" then
			nb = nb + 1
			dam = self:combatDamage(weapon and weapon.combat)
		end
	end
	
	if self:getInven("MAINHAND") then
		weapon = self:getInven("MAINHAND")[1]
		if not weapon or weapon.subtype == "mindstar" then
			nb = nb + 1
			dam = math.max(dam,self:combatDamage(weapon and weapon.combat))
		end
	end
	return nb >= 2 and true or false, dam -- return damage for use with Gesture of Guarding
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
	getStunChance = function(self, t) return self:combatTalentLimit(t, 50, 12, 20) end, -- Limit < 50%
	preAttack = function(self, t, target)
		if not canUseGestures(self) then
			game.logPlayer(self, "고통의 손짓을 취하기 위해서는, 두 손이 비어있거나 마석만을 들고 있어야 합니다.")
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

		if target:hasEffect(target.EFF_DISMAYED) then
		   bonusCritical = 100
		end

		if self:checkHit(mindpower, target:combatMentalResist()) then
			local damage = self:mindCrit(baseDamage * rng.float(0.5, 1) + bonusDamage, bonusCritical)
			self:project({type="hit", x=target.x,y=target.y}, target.x, target.y, DamageType.MIND, { dam=damage,alwaysHit=true,crossTierChance=25 })
			game:playSoundNear(self, "actions/melee_hit_squish")
			hit = true

			if target:hasEffect(target.EFF_DISMAYED) then
			   target:removeEffect(target.EFF_DISMAYED)
			end
		else
			game.logSeen(self, "%s 고통의 손짓을 저항했습니다.", (target.kr_name or target.name):capitalize():addJosa("가"))
			game:playSoundNear(self, "actions/melee_miss")
		end

		if hit then
			local effGloomWeakness = target:hasEffect(target.EFF_GLOOM_WEAKNESS)
			if effGloomWeakness and effGloomWeakness.hateBonus or 0 > 0 then
			   self:incHate(effGloomWeakness.hateBonus)
			   game.logPlayer(self, "#F53CBE#You revel in attacking a weakened foe! (+%d hate)", effGloomWeakness.hateBonus)
			   effGloomWeakness.hateBonus = nil
			end

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
		return ([[일반 공격을 하면서 고통의 손짓을 취해, 적의 정신을 직접 공격합니다. 이 공격이 성공하면 적에게 %0.1f - %0.1f 정신 피해를 주며, %d%% 확률로 3 턴 동안 기절시킵니다.
		이 공격은 일반 공격을 대체하며, 당신의 정확도와 적의 회피도 대신 당신의 정신력과 적의 정신 내성을 통해 저항을 판정합니다. 이 공격은 물리적인 타격 시 발생하는 효과가 발생하지 않지만, 마석의 기본 피해량과 치명타 확률은 이 공격에 더해집니다.
		이 기술은 두 손 모두 비어있거나 마석만을 들고 있어야 사용할 수 있으며, 25%% 확률로 적에게 능력치의 단계 차이 효과로 치명타 피해를 줄 수 있습니다. 피해량은 정신력 능력치의 영향을 받아 증가합니다.
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
	getGuardPercent = function(self, t) return self:combatTalentLimit(t, 100, 14, 31) end, --Limit < 100%
	-- Damage reduction handled in _M:attackTargetWith function in mod.class.interface.Combat.lua
	getDamageChange = function(self, t, fake)
		local test, dam = canUseGestures(self)
		if (not test or self:attr("encased_in_ice")) and not fake then return 0 end
		return t.getGuardPercent(self, t) * dam/100
	end,
	getCounterAttackChance = function(self, t, fake)
		if (not canUseGestures(self) or not self:isTalentActive(self.T_GESTURE_OF_PAIN)) and not fake then return 0 end 
		return self:combatTalentLimit(t, 50, 4, 8.9) -- Limit < 50%
	end,
	-- Mental effect "GESTURE_OF_GUARDING" handles the deflect count, refreshed in mod.class.Actor.lua _M:actBase
	getDeflects = function(self, t, fake)
		if not canUseGestures(self) and not fake then return 0 end
		return self:combatStatScale("cun", 0, 2.25)
	end,
	doGuard = function(self, t)
		local deflected, ef = 0, self:hasEffect(self.EFF_GESTURE_OF_GUARDING)
		if ef and ef.deflects > 0 then
			deflected = t.getDamageChange(self, t)
			if ef.deflects < 1 then deflected = deflected * ef.deflects end -- Partial deflection
			ef.deflects = ef.deflects -1
			if ef.deflects <=0 then self:removeEffect(self.EFF_GESTURE_OF_GUARDING) end
		end
		return deflected
	end,
	-- Counterattack handled in _M:attackTargetWith function in mod.class.interface.Combat.lua (requires EFF_GESTURE_OF_GUARDING)
	on_hit = function(self, t, who)
		if rng.percent(t.getCounterAttackChance(self, t)) and self:isTalentActive(self.T_GESTURE_OF_PAIN) and canUseGestures(self) then
			self:logCombat(who, "#F53CBE##Source1# #Target#의 공격을 반격합니다!")
			local tGestureOfPain = self:getTalentFromId(self.T_GESTURE_OF_PAIN)
			tGestureOfPain.attack(self, tGestureOfPain, who)
		end
	end,
	on_unlearn = function(self, t)
		self:removeEffect(self.EFF_GESTURE_OF_GUARDING)
	end,
	info = function(self, t)
		local damageChange = t.getDamageChange(self, t, true)
		local counterAttackChance = t.getCounterAttackChance(self, t, true)
		return ([[You guard against melee damage with a sweep of your hand. So long as you can use Gestures (Requires two free or mindstar-equipped hands), you deflect up to %d damage (%0.1f%% of your best free hand melee damage) from up to %0.1f melee attack(s) each turn (based on your cunning).
		If Gesture of Pain is active, you also have a %0.1f%% chance to counterattack.]]): --@@ 한글화 필요 #252~253
		format(damageChange, t.getGuardPercent(self, t), t.getDeflects(self, t, true), counterAttackChance)
	end,
}
