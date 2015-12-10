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
	name = "Wing Buffet",
	kr_name = "날개치기",
	type = {"wild-gift/fire-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	equilibrium = 5,
	cooldown = 8,
	range = 0,
	on_learn = function(self, t) 
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 1 
		self.combat_atk = self.combat_atk + 4
		self.combat_dam = self.combat_dam + 4
	end,
	on_unlearn = function(self, t) 
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 1 
		self.combat_atk = self.combat_atk - 4
		self.combat_dam = self.combat_dam - 4
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.6) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	direct_hit = true,
	tactical = { DEFEND = { knockback = 2 }, ESCAPE = { knockback = 2 } },
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, DamageType.PHYSKNOCKBACK, self:combatTalentWeaponDamage(t, 1.1, 1.6), true)
			end
		end)
		game:playSoundNear(self, "talents/breath")

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[강력한 바람의 돌풍을 불러내어, %d 범위 내의 적들을 세 칸만큼 밀어내고 %d%% 만큼의 무기 피해를 입힙니다.
		날개치기에 투자된 기술레벨 하나당 추가로 당신의 물리력과 정확도를 4씩 부여합니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 화염 저항력이 1%% 상승합니다.]]):format(self:getTalentRadius(t),damage*100)
	end,
}

newTalent{
	name = "Bellowing Roar",
	kr_name = "우렁찬 포효",
	type = {"wild-gift/fire-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source@ roars!",
	equilibrium = 8,
	cooldown = 20,
	range = 0,
	on_learn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 1 end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	tactical = { DEFEND = 1, DISABLE = { confusion = 3 } },
	requires_target = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.PHYSICAL, self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 380)))
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur=3,
			dam=20 + 6 * self:getTalentLevel(t),
			power_check=function() return self:combatPhysicalpower() end,
			resist_check=self.combatPhysicalResist,
		})
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.2, am=0.4, aM=0.6})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[당신은 강력한 포효를 터트려 당신 주변 %d 칸 내에 있는 적들을 3 턴간 심각한 혼란 상태로 빠트립니다.
		이 음파는 너무나도 강력하여, 당신의 적은 %0.2f 만큼의 물리 피해를 받습니다.
		피해량은 당신의 힘 능력치에 비례하여 상승합니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 화염 저항력이 1%% 상승합니다.]]):format(radius, self:combatTalentStatDamage(t, "str", 30, 380))
	end,
}

newTalent{
	name = "Devouring Flame",
	kr_name = "집어삼키는 화염",
	type = {"wild-gift/fire-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	equilibrium = 6,
	cooldown = 20,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 1 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 15, 60)
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		local damage = self:mindCrit(t.getDamage(self, t))
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.FIRE_DRAIN, {dam=damage, healfactor=0.1},
			radius,
			5, nil,
			{type="inferno"},
			nil, false
		)
		game:playSoundNear(self, "talents/devouringflame")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[불의 구름을 내뱉어, %0.2f 의 화염 피해를 범위 %d 에 %d 턴 동안 입힙니다.
		화염은 시전자를 무시하며, 가한 피해의 10%%만큼 적들의 생명력을 빨아들여 시전자에게 옮겨 줍니다.
		피해량은 정신력에 비례하여 상승하며, 치명타 효과가 발생할 수 있습니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 화염 저항력이 1%% 상승합니다.]]):format(damDesc(self, DamageType.FIRE, dam), radius, duration)
	end,
}

newTalent{
	name = "Fire Breath",
	kr_name = "화염 브레스",
	type = {"wild-gift/fire-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ 화염의 숨결을 내뱉습니다!",
	tactical = { ATTACKAREA = { FIRE = 2 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 1 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE_STUN, {dam=self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 650)), dur=3, initial=70})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
		end
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[당신은 화염의 숨결을 내뱉어 %d 범위의 원뿔 모양으로 발사합니다. 화염의 숨결에 휩싸인 목표는 %0.2f 의 화염 피해를 받고, 25%% 확률로 화염 충격 상태에 3 턴간 빠집니다.
		피해량은 당신의 힘 능력치에 비례하고, 치명타율은 정신 치명타율을 따릅니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 화염 저항력이 1%% 상승합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 650)))
	end,
}
