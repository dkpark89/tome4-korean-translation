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

-- Core offensive scaler for 1H/S as we have no Shield Mastery
-- Core defense roughly to be compared with Absorption Strike, but in truth 1H/S gets a lot of its defense from cooldown management+Suncloak/etc
-- Its important that this can crit but its also spamming the combat log, unsure of solution
-- Flag if its a crit once for each turn then calculate damage manually?
newTalent{
	name = "Shield of Light",
	kr_name = "빛의 방패",
	type = {"celestial/guardian", 1},
	mode = "sustained",
	require = divi_req_high1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 5, 22) end,
	getShieldDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.8, self:getTalentLevel(self.T_SHIELD_EXPERTISE)) end,
	on_pre_use = function(self, t) return self:hasShield() and true or false end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		local shield = self:hasShield()
		if hitted and not target.dead and shield and not self.turn_procs.shield_of_light then
			self.turn_procs.shield_of_light = true
			self:attackTargetWith(target, weapon.special_combat, DamageType.LIGHT, t.getShieldDamage(self, t))
		end
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[방패에 빛의 힘을 불어넣어, 피해를 받을 때마다 양기를 2 소모하여 생명력을 %0.2f 회복합니다. 
 		양기가 부족하면, 이 효과는 발동되지 않습니다. 
 		또한 1 턴에 한 번, 근접 공격을 성공시킬 경우 방패로 %d%% 빛 피해를 추가로 가합니다.  
 		치유량은 주문력의 영향을 받아 증가합니다.]]):  
		format(heal, t.getShieldDamage(self, t)*100)
	end,
}

-- Shield of Light means 1H/Shield builds actually care about positive energy, so we can give this a meaningful cost and power
-- Spamming Crusade+whatever is always more energy efficient than this
newTalent{
	name = "Brandish",
	kr_name = "휘두르기",
	type = {"celestial/guardian", 2},
	require = divi_req_high2,
	points = 5,
	cooldown = 8,
	positive = 25,
	tactical = { ATTACK = {LIGHT = 2} },
	requires_target = true,
	range = 1,
	is_melee = true,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 3) end,
	getShieldDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 2, self:getTalentLevel(self.T_SHIELD_EXPERTISE)) end,
	getLightDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패를 장착하지 않은 상태에서는 휘두르기를 사용할 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not target then return nil end
		if not self:canProject(tg, x, y) then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, t.getWeaponDamage(self, t), true)
		-- Second attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, t.getShieldDamage(self, t))

		-- Light Burst
		if hit then
			local tg = {type="ball", range=1, selffire=true, radius=self:getTalentRadius(t), talent=t}
			self:project(tg, x, y, DamageType.LITE, 1)
			tg.selffire = false
			local grids = self:project(tg, x, y, DamageType.LIGHT, self:spellCrit(t.getLightDamage(self, t)))
			game.level.map:particleEmitter(x, y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
			game:playSoundNear(self, "talents/flame")
		end

		return true
	end,
	info = function(self, t)
		local weapondamage = t.getWeaponDamage(self, t)
		local shielddamage = t.getShieldDamage(self, t)
		local lightdamage = t.getLightDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[대상을 무기로 공격하여 %d%% 무기 피해를 준 뒤, 방패로 쳐서 %d%% 방패 피해를 줍니다. 방패 공격이 적중하면, 찬란한 빛이 뿜어져나와 %0.2f 빛 피해를 주변 %d 칸 반경에 있는 적들에게 주고, 어두운 곳을 밝힙니다. 
 		빛 피해량은 주문력의 영향을 받아 증가합니다.]]): 
		format(100 * weapondamage, 100 * shielddamage, damDesc(self, DamageType.LIGHT, lightdamage), radius)
	end,
}

newTalent{
	name = "Retribution",
	kr_name = "응보",
	type = {"celestial/guardian", 3},
	require = divi_req_high3, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 20,
	cooldown = 10,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	tactical = { DEFEND = 2 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 400) end,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패를 장착하지 않은 상태에서는 응보를 사용할 수 없습니다!")
			return nil
		end
		local power = t.getDamage(self, t)
		self.retribution_absorb = power
		self.retribution_strike = power
		game:playSoundNear(self, "talents/generic")
		return {
			shield = self:addTemporaryValue("retribution", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("retribution", p.shield)
		self.retribution_absorb = nil
		self.retribution_strike = nil
		return true
	end,
	callbackOnRest = function(self, t)
		-- Resting requires no enemies in view so we can safely clear all stored damage
		-- Clear the stored damage by setting the remaining absorb to the max
		self.retribution_absorb = self.retribution
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local absorb_string = ""
		if self.retribution_absorb and self.retribution_strike then
			absorb_string = ([[#RED#남은 흡수 가능량 : %d]]):format(self.retribution_absorb)
		end

		return ([[적에게 받는 피해량의 절반을 흡수합니다. %0.2f 피해를 흡수하면, 방패에서 찬란한 빛이 뿜어져나와 주변 %d 칸 반경에 흡수했던 피해량과 동일한 피해를 주고 기술이 해제됩니다. 
 		흡수량은 주문력의 영향을 받아 증가합니다. 
 		%s]]): 
		format(damage, self:getTalentRange(t), absorb_string)
	end,
}

-- Moderate damage but very short CD
-- Spamming this on cooldown keeps positive energy up and gives a lot of cooldown management
newTalent{
	name = "Crusade",
	kr_name = "성전",
	type = {"celestial/guardian", 4},
	require = divi_req_high4,
	random_ego = "attack",
	points = 5,
	cooldown = 5,
	positive = -20,
	tactical = { ATTACK = {LIGHT = 2} },
	range = 1,
	requires_target = true,
	is_melee = true,
	target = function(self, t) return {type = 'hit', range = self:getTalentRange(t)} end,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 1.2) end,
	getShieldDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 1.2, self:getTalentLevel(self.T_SHIELD_EXPERTISE)) end,
	getCooldownReduction = function(self, t) return math.ceil(self:combatTalentScale(t, 1, 3)) end,
	getDebuff = function(self, t) return 1 end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패를 장착하지 않은 상태에서는 성전을 사용할 수 없습니다!") 
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target then return nil end
		if not self:canProject(tg, x, y) then return nil end

		local hit = self:attackTarget(target, DamageType.LIGHT, t.getWeaponDamage(self, t), true)
		if hit then self:talentCooldownFilter(nil, 1, t.getCooldownReduction(self, t), true) end

		local hit2 = self:attackTargetWith(target, shield.special_combat, DamageType.LIGHT, t.getShieldDamage(self, t))
		if hit2 then self:removeEffectsFilter({status = "detrimental"}, t.getDebuff(self, t)) end

		return true
	end,
	info = function(self, t)
		local weapon = t.getWeaponDamage(self, t)*100
		local shield = t.getShieldDamage(self, t)*100
		local cooldown = t.getCooldownReduction(self, t)
		local cleanse = t.getDebuff(self, t)
		return ([[신중한 공격을 통해 빛에 대한 헌신을 증명합니다.  
 		우선 무기로 적에게 %d%% 피해를 주고, 다음에는 방패로 적에게 %d%% 피해를 줍니다. 
 		첫 번째 공격이 성공할 경우, 무작위한 기술 %d 개의 재사용 대기 시간이 1 턴 줄어들게 됩니다. 
 		두 번째 공격이 성공할 경우, 해로운 상태효과가 %d 개 정화됩니다.]]):  
		format(weapon, shield, cooldown, cleanse)
	end,
}
