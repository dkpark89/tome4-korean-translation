-- ToME -  Tales of Maj'Eyal
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
	name = "Dust to Dust",
	kr_display_name = "먼지는 먼지로",
	type = {"chronomancy/matter",1},
	require = chrono_req1,
	points = 5,
	paradox = 5,
	cooldown = 3,
	tactical = { ATTACKAREA = {TEMPORAL = 1, PHYSICAL = 1} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.MATTER, self:spellCrit(t.getDamage(self, t)))
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "matter_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[물질을 먼지로 만들어 없애버리는 힘을 발사하여, 발사 궤도에 있는 모든 적들에게 %0.2f 시간 피해와 %0.2f 물리 피해를 줍니다.
		피해량은 괴리 수치와 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage / 2), damDesc(self, DamageType.PHYSICAL, damage / 2))
	end,
}

newTalent{
	name = "Carbon Spikes",
	kr_display_name = "탄소 가시",
	type = {"chronomancy/matter", 2},
	require = chrono_req2, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_paradox = 100,
	cooldown = 12,
	tactical = { BUFF =2, DEFEND = 2 },
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	getArmor = function(self, t) return math.ceil (self:combatTalentSpellDamage(t, 20, 50)) end,
	do_carbonRegrowth = function(self, t)
		local maxspikes = t.getArmor(self, t)
		if self.carbon_armor < maxspikes then
			self.carbon_armor = self.carbon_armor + 1
		end
	end,
	do_carbonLoss = function(self, t)
		if self.carbon_armor >= 1 then
			self.carbon_armor = self.carbon_armor - 1
		else
			-- Deactivate without loosing energy
			self:forceUseTalent(self.T_CARBON_SPIKES, {ignore_energy=true})
		end
	end,
	activate = function(self, t)
		local power = t.getArmor(self, t)
		self.carbon_armor = power
		game:playSoundNear(self, "talents/spell_generic")
		return {
			armor = self:addTemporaryValue("carbon_spikes", power),
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.BLEED]=t.getDamageOnMeleeHit(self, t)}),			
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("carbon_spikes", p.armor)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self.carbon_armor = nil
		return true
	end,
	info = function(self, t)
		local damage = t.getDamageOnMeleeHit(self, t)
		local armor = t.getArmor(self, t)
		return ([[부서지기 쉬운 탄소 가시를 맨몸, 옷, 갑옷 등에 돌출시켜, 방어도가 %d 상승하고 자신을 공격한 적에게 6 턴 동안 총 %0.2f 출혈 피해를 줍니다.
		공격을 받을 때마다 방어도 증가량이 1 씩 줄어들며, 매 턴마다 감소된 방어도가 1 씩 복구됩니다.
		방어도 상승량과 출혈 피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(armor, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Destabilize",
	kr_display_name = "불안정",
	type = {"chronomancy/matter", 3},
	require = chrono_req3,
	points = 5,
	cooldown = 10,
	paradox = 15,
	range = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 60)*getParadoxModifier(self, pm) end,
	getExplosion = function(self, t) return self:combatTalentSpellDamage(t, 20, 230)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_TEMPORAL_DESTABILIZATION, 10, {src=self, dam=t.getDamage(self, t), explosion=self:spellCrit(t.getExplosion(self, t))})
			game.level.map:particleEmitter(target.x, target.y, 1, "entropythrust")
		end)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local explosion = t.getExplosion(self, t)
		return ([[대상을 불안정하게 만들어, 10 턴 동안 매 턴마다 %0.2f 시간 피해를 줍니다. 대상이 불안정한 상태로 죽으면, 폭발하여 주변 4 칸 반경에 %0.2f 시간 피해와 %0.2f 물리 피해를 줍니다.
		피해량은 괴리 수치와 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.TEMPORAL, explosion/2), damDesc(self, DamageType.PHYSICAL, explosion/2))
	end,
}

newTalent{
	name = "Quantum Spike",
	kr_display_name = "양자 가시",
	type = {"chronomancy/matter", 4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 4,
	tactical = { ATTACK = {TEMPORAL = 1, PHYSICAL = 1} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		
		-- bonus damage on targets with temporal destabilization
		local damage = t.getDamage(self, t)
		if target then 
			if target:hasEffect(target.EFF_TEMPORAL_DESTABILIZATION) or target:hasEffect(target.EFF_CONTINUUM_DESTABILIZATION) then
				damage = damage * 1.5
			end
		end
		
		
		self:project(tg, x, y, DamageType.MATTER, self:spellCrit(damage))
		game:playSoundNear(self, "talents/arcane")
		
		-- Try to insta-kill
		if target then
			if target:checkHit(self:combatSpellpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("instakill") and target.life > 0 and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s 원자 단위로 분해되었습니다!", target.name:capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s 양자 가시를 저항했습니다!", target.name:capitalize())
			end
		end
		
		-- if we kill it use teleport particles for larger effect radius
		if target and target.dead then
			game.level.map:particleEmitter(x, y, 1, "teleport")
		else
			game.level.map:particleEmitter(x, y, 1, "entropythrust")
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[대상에게 %0.2f 시간 피해와 %0.2f 물리 피해를 줍니다.
		대상이 빈사 상태가 되면 (생명력 20%% 이하) 원자 단위로 분해를 시도하며, 성공할 경우 대상은 즉사합니다.
		양자 가시는 불안정한 대상에게 50%% 추가 피해를 줍니다.
		피해량은 괴리 수치와 주문력 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/2))
	end,
}

