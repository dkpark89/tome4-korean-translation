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

newTalent{
	name = "Mind Sear",
	kr_display_name = "정신 파괴",
	type = {"psionic/psychic-assault", 1},
	require = psi_wil_req1,
	points = 5,
	cooldown = 2,
	psi = 5,
	range = 7,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	tactical = { ATTACKAREA = { MIND = 3 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.MIND, self:mindCrit(t.getDamage(self, t)), {type="mind"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[적들을 관통하는 정신파를 날립니다. 정신파는 대상의 뇌를 약간 파괴하여, %0.2f 정신 피해를 줍니다.
		피해량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Psychic Lobotomy",
	kr_display_name = "사고 방해",
	type = {"psionic/psychic-assault", 2},
	require = psi_wil_req2,
	points = 5,
	cooldown = 8,
	range = 7,
	psi = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { MIND = 2 }, DISABLE = { confusion = 2 } },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 200) end,
	getPower = function(self, t) return math.min(50, self:combatTalentMindDamage(t, 10, 50)) end,
	getDuration = function(self, t) return 1 + math.floor(self:getTalentLevel(t)) end,
	no_npc = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end
		local ai = target.ai or nil		
		
		local dam = self:mindCrit(t.getDamage(self, t))
		if target:canBe("confused") then
			target:setEffect(target.EFF_LOBOTOMIZED, t.getDuration(self, t), {src=self, dam=dam, power=t.getPower(self, t), apply_power=self:combatMindpower()})
		else
			game.logSeen(target, "%s 사고 방해를 저항했습니다!", target.name:capitalize())
		end

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local cunning_damage = t.getPower(self, t)/2
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[대상의 전두엽을 염력으로 무력화시켜 %0.2f 정신 피해를 주고, 복잡한 사고를 하지 못하게 만듭니다. %d 턴 동안 대상의 교활함 수치가 %d 감소하며, 혼란 상태에 빠집니다. (%d%% 위력)
		피해량, 교활함 수치 감소량, 혼란의 위력은 정신력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.MIND, (damage)), duration, cunning_damage, power)
	end,
}

newTalent{
	name = "Synaptic Static",
	kr_display_name = "시냅스 정전기 발동",
	type = {"psionic/psychic-assault", 3},
	require = psi_wil_req3,
	points = 5,
	cooldown = 10,
	psi = 10,
	range = 0,
	direct_hit = true,
	requires_target = true,
	radius = function(self, t) return math.min(7, 2 + math.ceil(self:getTalentLevel(t)/2)) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t, selffire=false} end,
	tactical = { ATTACKAREA = { MIND = 3 }, DISABLE=1 },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 200) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.MIND, {dam=self:mindCrit(self:combatTalentMindDamage(t, 20, 200)), crossTierChance=100} )
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "generic_ball", {radius=self:getTalentRadius(t), rm=100, rM=125, gm=100, gM=125, bm=100, bM=125, am=200, aM=255})
		game:playSoundNear(self, "talents/echo")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[주변 %d 칸 반경에 시냅스를 자극하는 염력 정전파를 발생시킵니다. %0.2f 정신 피해를 주며, 대상에게 정신 잠금 상태를 일으킵니다.
		피해량은 정신력 능력치의 영향을 받아 증가합니다.]]):format(radius, damDesc(self, DamageType.MIND, damage))
	end,
}

newTalent{
	name = "Sunder Mind",
	kr_display_name = "정신 붕괴",
	type = {"psionic/psychic-assault", 4},
	require = psi_wil_req4,
	points = 5,
	cooldown = 4,
	psi = 5,
	tactical = { ATTACK = { MIND = 2}, DISABLE = 1},
	range = 7,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 150) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		local dam =self:mindCrit(t.getDamage(self, t))
		if target:hasEffect(target.EFF_BRAINLOCKED) then dam = dam * 2 end
		self:project(tg, x, y, DamageType.MIND, {dam=dam, alwaysHit=true}, {type="mind"})
		target:setEffect(target.EFF_SUNDER_MIND, 4, {power=dam/10})
		
		game:playSoundNear(self, "talents/warp")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local power = t.getDamage(self, t) / 10
		return ([[대상의 정신을 무력화시켜, %0.2f 정신 피해를 주고 4 턴 동안 정신 내성을 %d 감소시킵니다. 이 공격은 피할 수 없으며, 정신 내성 감소는 중첩됩니다.
		정신 잠금 상태의 대상에게는 피해량과 정신 내성 감소량이 2 배가 됩니다.
		피해량과 정신 내성 감소량은 정신력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.MIND, (damage)), power)
	end,
}
