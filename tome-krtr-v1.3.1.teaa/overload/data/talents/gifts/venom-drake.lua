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

newTalent{
	name = "Acidic Spray",
	kr_name = "산성 분사",
	type = {"wild-gift/venom-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ 산을 뱉습니다!",
	equilibrium = 3,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 3, 6.9, 5.5)) end, -- Limit >=3
	tactical = { ATTACK = { ACID = 2 } },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5.5, 7.5)) end,
	on_learn = function(self, t)
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1
		self.combat_mindpower = self.combat_mindpower + 4
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1
		self.combat_mindpower = self.combat_mindpower - 4
	end,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 5 then return true else return false end end,
	requires_target = true,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 5 then tg.type = "beam" end
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 25, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID_DISARM, self:mindCrit(t.getDamage(self, t)), nil)
		local _ _, x, y = self:canProject(tg, x, y)
		if tg.type == "beam" then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "acidbeam", {tx=x-self.x, ty=y-self.y})
		else
			game.level.map:particleEmitter(x, y, 1, "acid")
		end
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[적을 향해 산성의 액체 방울을 앞으로 뿌립니다.
		목표는 정신력 기반의 %0.2f 의 산성 피해를 입습니다.
		공격 받은 적은 무기가 산에 녹아 쓸모가 없어져, 25%% 확율로 3 턴간 무장해제 상태에 빠집니다.
		기술 레벨 5에 도달했을 때, 산성 액체는 적을 한 줄로 관통 할 수 있게 됩니다.
		산성분사에 투자된 레벨 하나마다 당신의 정신력이 4씩 오릅니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 산성 저항력이 1%% 상승합니다.]]):format(damDesc(self, DamageType.ACID, damage))
	end,
}

newTalent{
	name = "Corrosive Mist",
	kr_name = "부식성 안개",
	type = {"wild-gift/venom-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	equilibrium = 10,
	cooldown = 15,
	tactical = { ATTACKAREA = { ACID = 2 } },
	range = 0,
	on_learn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1 end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 15, 70) end,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatMindpower(0.04) + self:getTalentLevel(t)/2, 6, 0, 7.67, 5.67)) end,
	getCorrodeDur = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.8)) end,
	getAtk = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	getDefense = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	action = function(self, t)
		local damage = self:mindCrit(t.getDamage(self, t))
		local duration = t.getDuration(self, t)
		local cordur = t.getCorrodeDur(self, t)
		local atk = t.getAtk(self, t)
		local armor = t.getArmor(self, t)
		local defense = t.getDefense(self, t)
		local actor = self
		local radius = self:getTalentRadius(t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.ACID_CORRODE, {dam=damage, dur=cordur, atk=atk, armor=armor, defense=defense},
			radius,
			5, nil,
			{type="acidstorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local cordur = t.getCorrodeDur(self, t)
		local atk = t.getAtk(self, t)
		local radius = self:getTalentRadius(t)
		return ([[지속성 산으로 이루어진 안개를 내쉬어, %0.2f 의 산성 피해를 %d 범위 내에 %d 턴간 가합니다. 이 공격은 치명타가 일어날 수 있습니다.
		안개의 영향을 받은 적은 %d 턴 동안 부식되어 정확도, 방어도, 회피도가 %d 감소하게 됩니다.
		피해량과 지속시간은 정신력, 안개의 범위는 기술 레벨에 따라 증가합니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 산성 저항력이 1%% 상승합니다.]]):format(damDesc(self, DamageType.ACID, damage), radius, duration, cordur, atk)
	end,
}

newTalent{
	name = "Dissolve",
	kr_name = "용해",
	type = {"wild-gift/venom-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	equilibrium = 10,
	cooldown = 12,
	range = 1,
	is_melee = true,
	tactical = { ATTACK = { ACID = 2 } },
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	on_learn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		self:attackTarget(target, (self:getTalentLevel(t) >= 2) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		self:attackTarget(target, (self:getTalentLevel(t) >= 4) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		self:attackTarget(target, (self:getTalentLevel(t) >= 6) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		self:attackTarget(target, (self:getTalentLevel(t) >= 8) and DamageType.ACID_BLIND or DamageType.ACID, self:combatTalentWeaponDamage(t, 0.1, 0.60), true)
		return true
	end,
	info = function(self, t)
		return ([[당신은 적에게 빠르고, 무수히 많은 산성 타격을 가합니다. 총 4번 가격해 순수한 산성 피해를 입힙니다. 매 타격은 %d%% 의 무기 피해를 가집니다.
		기술 레벨이 2 오를 때마다, 공격 중 하나가 25%% 확률로 적을 실명시키는 특수 산성 공격으로 변화합니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 산성 저항력이 1%% 상승합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.1, 0.6))
	end,
}

newTalent{
	name = "Corrosive Breath",
	kr_name = "부식성 브레스",
	type = {"wild-gift/venom-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ 산의 숨결을 내뱉습니다!",
	tactical = { ATTACKAREA = { ACID = 2 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 1 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDisarm = function(self, t)
		return 20+self:combatTalentMindDamage(t, 10, 30)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID_DISARM, {dam=self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 520)), chance=t.getDisarm(self, t),})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="acidwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		local disarm = t.getDisarm(self, t)
		return ([[당신은 산의 숨결을 내뱉어 %d 범위의 원뿔 모양으로 발사합니다. 산의 숨결에 휩싸인 목표는 %0.2f 의 산성 피해를 받고, 무기가 녹아 %d%% 의 확율로 3 턴간 무장해제 상태에 빠집니다.
		피해량은 당신의 힘 능력치에 비례하고, 치명타율은 정신 치명타율을 따릅니다. 혼절 확율은 정신력에 비례합니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 산성 저항력이 1%% 상승합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, self:combatTalentStatDamage(t, "str", 30, 520)), disarm)
	end,
}
