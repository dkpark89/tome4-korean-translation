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

newTalent{
	name = "Transcendent Pyrokinesis",
	kr_name = "초월 - 염화",
	type = {"psionic/thermal-mastery", 1},
	require = psi_wil_high1,
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getDamagePenalty = function(self, t) return self:combatTalentLimit(t, 100, 15, 50) end, --Limit < 100%
	getPenetration = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 10, 20), 100, 4.2, 4.2, 13.4, 13.4) end, -- Limit < 100%
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 30, 5, 10)) end, --Limit < 30
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_PYROKINESIS, t.getDuration(self, t), {power=t.getPower(self, t), penetration=t.getPenetration(self, t), weaken=t.getDamagePenalty(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_TELEKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self:alterTalentCoolingdown(self.T_THERMAL_SHIELD, -1000)
		self:alterTalentCoolingdown(self.T_THERMAL_STRIKE, -1000)
		self:alterTalentCoolingdown(self.T_THERMAL_AURA, -1000)
		self:alterTalentCoolingdown(self.T_THERMAL_LEECH, -1000)
		self:alterTalentCoolingdown(self.T_PYROKINESIS, -1000)
		return true
	end,
	info = function(self, t)
		return ([[%d 턴 동안, 한계를 뛰어넘은 초월적인 염화를 다룰 수 있게 됩니다.
		- 화염과 냉기 피해량이 %d%% / 화염과 냉기 저항 관통력이 %d%% 상승합니다.
		- 열역학적 보호막, 열역학적 오러 발산, 염화, 열역학적 흡수 기술의 재사용 대기 시간이 초기화됩니다.
		- 열역학적 보호막의 흡수 효율이 100%% 가 되며, 최대 흡수 가능량이 2 배 증가합니다.
		- 열역학적 오러 발산이 주변 2 칸 범위에 영향을 미치며, 피해량 추가가 적용 가능한 모든 무기에 적용됩니다.
		- 염화가 화염 충격 효과를 추가로 부여합니다.
		- 열역학적 흡수가 적의 피해량을 %d%% 감소시킵니다.
		- 열역학적 타격이 빙결성 냉기 폭발을 추가로 일으킵니다. (주변 1 칸 범위 폭발)
		피해량 증가와 저항 관통력은 정신력의 영향을 받아 증가합니다.
		한번에 하나의 '초월' 기술만을 사용할 수 있습니다.]]):format(t.getDuration(self, t), t.getPower(self, t), t.getPenetration(self, t), t.getDamagePenalty(self, t))
	end,
}

newTalent{
	name = "Brainfreeze",
	kr_name = "뇌 얼리기",
	type = {"psionic/thermal-mastery", 2},
	require = psi_wil_high2, 
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	psi = 20,
	tactical = { ATTACK = { COLD = 3} },
	range = function(self,t) return self:combatTalentScale(t, 4, 6) end,
	getDamage = function (self, t)
		return self:combatTalentMindDamage(t, 12, 340)
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		self:project(tg, x, y, DamageType.COLD, self:mindCrit(rng.avg(0.8*dam, dam)), {type="mindsear"})
		target:setEffect(target.EFF_BRAINLOCKED, 4, {apply_power=self:combatMindpower()})
		
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[대상의 뇌에서 급격하게 열을 뺏어, %0.1f 냉기 피해를 줍니다.
		대상은 4 턴 동안 정신 잠금 상태가 되어, 무작위한 기술 하나가 재사용 대기 상태가 됩니다.
		또한 정신 잠금 상태에서는 시간이 지나도 재사용 대기 시간이 감소하지 않게 됩니다.
		피해량과 정신 잠금이 걸릴 확률은 정신력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD, dam))
	end,
}

newTalent{
	name = "Heat Shift",
	kr_name = "열 교환",
	type = {"psionic/thermal-mastery", 3},
	require = psi_wil_high3,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	psi = 35,
	tactical = { DISABLE = 4 },
	range = 6,
	radius = function(self,t) return self:combatTalentScale(t, 2, 4) end,
	getDuration = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 4, 8))
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 60) end,
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 10, 20) end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t, friendlyfire=false} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		local armor = t.getArmor(self, t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				local cold = DamageType:get("COLD").projector(self, tx, ty, DamageType.COLD, dam)
				if act:canBe("pin") and act:canBe("stun") and not act:attr("fly") and not act:attr("levitation") then
					act:setEffect(act.EFF_FROZEN_FEET, dur, {apply_power=self:combatMindpower()})
				end
				local fire = DamageType:get("FIRE").projector(self, tx, ty, DamageType.FIRE, dam)
				if act:canBe("disarm") then
					act:setEffect(act.EFF_DISARMED, dur, {apply_power=self:combatMindpower()})
				end
				if cold>0 and fire>0 then
					act:setEffect(act.EFF_SUNDER_ARMOUR, dur, {power = armor})
				end
			end
		end)
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local rad = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[주변 %d 칸 반경에 걸쳐, 적들의 육체와 장비의 열을 교환합니다. 이를 통해 적들은 발이 얼어붙고, 장비는 너무나 뜨거워 사용할 수 없게 됩니다.
		이를 통해 %0.1f 냉기 피해와 %0.1f 화염 피해를 주며, 적은 %d 턴 동안 속박 (얼어붙은 발) 및 장비해제 상태가 됩니다.
		또한 두 속성의 피해를 모두 받은 대상은 방어도와 내성이 %d 감소하게 됩니다.
		효과가 적용될 확률과 지속 시간은 정신력의 영향을 받아 증가합니다.]]):
		format(rad, damDesc(self, DamageType.COLD, dam), damDesc(self, DamageType.FIRE, dam), dur, t.getArmor(self, t))
	end,
}

newTalent{
	name = "Thermal Balance",
	kr_name = "열에너지 균형",
	type = {"psionic/thermal-mastery", 4},
	require = psi_wil_high4,
	points = 5,
	psi = 0,
	cooldown = 10,
	range = function(self,t) return self:combatTalentScale(t, 4, 6) end,
	radius = function(self,t) return self:combatTalentScale(t, 2, 4) end,
	tactical = { ATTACKAREA = { FIRE = 2, COLD = 2 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 30, 300) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local dam=self:mindCrit(t.getDamage(self, t))
		local dam1 = dam * (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()
		local dam2 = dam * self:getPsi() / self:getMaxPsi()
		
		self:project(tg, x, y, DamageType.COLD, dam1)
		self:project(tg, x, y, DamageType.FIRE, dam2)

		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=1.1, a=255, limit_life=16, grow=true, speed=0, img="fireice_nova", radius=tg.radius})
		
		self:incPsi(self:getMaxPsi()/2 - self:getPsi())
		
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local dam1 = dam * (self:getMaxPsi() - self:getPsi()) / self:getMaxPsi()
		local dam2 = dam * self:getPsi() / self:getMaxPsi()
		return ([[현재 염력 상태에 따라, 화염과 냉기의 균형을 유지합니다.
		%d 칸 반경의 적들에게 현재 남은 염력에 따라 적들에게 %0.1f 화염 피해를 주고, (최대 염력 - 남은 염력) 에 따라 %0.1f 냉기 피해를 줍니다.
		이를 통해 현재 염력을 최대 염력의 절반으로 조정합니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, dam2), damDesc(self, DamageType.COLD, dam1)) --@ 변수 순서 조정
	end,
}

