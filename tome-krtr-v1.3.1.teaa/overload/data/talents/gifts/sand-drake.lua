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
	name = "Swallow",
	kr_name = "삼키기",
	type = {"wild-gift/sand-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 4,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 10, 7)) end,
	range = 1,
	no_message = true,
	tactical = { ATTACK = { weapon = 1 }, EQUILIBRIUM = 0.5},
	requires_target = true,
	no_npc_use = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	maxSwallow = function(self, t, target) return -- Limit < 50%
		self:combatLimit(self:getTalentLevel(t)*(self.size_category or 3)/(target.size_category or 3), 50, 13, 1, 25, 5)
	end,
	getPassiveCrit = function(self, t) return self:combatTalentScale(t, 2, 10, 0.5) end,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physcrit", t.getPassiveCrit(self, t))
		self:talentTemporaryValue(p, "combat_mindcrit", t.getPassiveCrit(self, t))
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		self:logCombat(target, "#Source# 가 #Target# 삼키려고 시도합니다!")
		local hit = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 1.6, 2.5), true)
		if not hit then return true end

		if (target.life * 100 / target.max_life > t.maxSwallow(self, t, target)) and not target.dead then
			return true
		end

		if (target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) or target.dead) and (target:canBe("instakill") or target.life * 100 / target.max_life <= 5) then
			if not target.dead then target:die(self) end
			world:gainAchievement("EAT_BOSSES", self, target)
			self:incEquilibrium(-target.level - 5)
			self:attr("allow_on_heal", 1)
			self:heal(target.level * 2 + 5, target)
			if core.shader.active(4) then
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
			end
			self:attr("allow_on_heal", -1)
		else
			game.logSeen(target, "%s 저항하였습니다!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[목표를 자연 속성의 %d%% 의 무기 피해로 공격합니다.
		만약 당신의 공격이 목표를 %d%% 이하의 생명력으로 떨어트렸거나 죽였다면, 목표를 삼키려고 시도하여, 즉시 살해하고 생명력과 평정을 목표의 레벨에 따라 얻습니다.
		적을 삼킬 확률은 기술 레벨과 당신과 대상의 신체 크기에 따라 달라집니다.
		삼키기에 투자된 레벨 하나마다 당신의 물리, 정신 치명타율을 %d%% 만큼 올립니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 물리 저항력이 0.5%% 상승합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.6, 2.5), t.maxSwallow(self, t, self), t.getPassiveCrit(self, t))
	end,
}

newTalent{
	name = "Quake",
	kr_name = "지진",
	type = {"wild-gift/sand-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source@ 땅을 흔들었습니다!",
	equilibrium = 4,
	cooldown = 20,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	range = 1,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	no_npc_use = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.3, 2.1) end,
	action = function(self, t)
		local tg = {type="ball", range=0, selffire=false, radius=self:getTalentRadius(t), talent=t, no_restrict=true}
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, DamageType.PHYSKNOCKBACK, self:combatTalentWeaponDamage(t, 1.3, 2.1), true)
			end
		end)
		self:doQuake(tg, self.x, self.y)
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[당신은 땅을 내리치어, 당신 주변 %d 칸 내의 지역을 흔듭니다.
		지진에 휩쓸린 존재들은 %d%% 의 무기 피해를 입으며, 3 칸 밖으로 밀려납니다.
		범위 내의 지형 또한 뒤섞이고, 사용자는 범위 내의 공간 안에서 무작위로 옮겨집니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 물리 저항력이 0.5%% 상승합니다.]]):format(radius, dam * 100)
	end,
}

newTalent{
	name = "Burrow",
	kr_name = "굴 파기",
	type = {"wild-gift/sand-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 15,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
	range = 10,
	no_energy = function(self, t) if self:getTalentLevel(t) >= 5 then return true else return false end end,
	tactical = { CLOSEIN = 0.5, ESCAPE = 0.5 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7, 0.5, 0, 2)) end,
	getPenetration = function(self, t) return 10 + self:combatTalentMindDamage(t, 15, 30) end,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	action = function(self, t)
		self:setEffect(self.EFF_BURROW, t.getDuration(self, t), {power=t.getPenetration(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[당신은 %d 턴 동안 흙으로 된 벽을 파헤칠 수 있게 됩니다.
		당신의 강력한 땅 파기 능력은 적의 방어의 틈새를 찾아내고 깨부수는데에도 사용 될 수 있습니다. 이 효과를 가지고 있는 동안 당신은 적의 방어도를 %d 만큼과 %d%% 의 물리 저항력을 무시합니다.
		기술 레벨 5가 되었을 때, 이 기술은 턴을 소모하지 않으며, 재사용 대기 시간도 레벨에 따라 낮아집니다. 
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 물리 저항력이 0.5%% 상승합니다.]]):format(t.getDuration(self, t), t.getPenetration(self, t), t.getPenetration(self, t) / 2)
	end,
}

newTalent{
	name = "Sand Breath",
	kr_name = "모래 브레스",
	type = {"wild-gift/sand-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ 모래의 숨결을 내뱉습니다!",
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = { blind = 2 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "str", 30, 480)
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 4)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SAND, {dur=t.getDuration(self, t), dam=self:mindCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="sandwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[%d 칸 범위에 원뿔 모양으로 모래의 숨결을 내뱉습니다. 모래의 숨결에 휩쓸린 목표들은 %0.2f 의 물리 피해를 입으며, %d 턴 동안 실명 상태에 빠집니다.
		피해량은 힘 능력치에 따라 상승하며, 치명타율은 정신 치명타율을 따릅니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 물리 저항력이 0.5%% 상승합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}
