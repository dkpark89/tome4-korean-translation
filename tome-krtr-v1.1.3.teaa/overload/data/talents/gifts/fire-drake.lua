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
	name = "Bellowing Roar",
	kr_name = "포효",
	type = {"wild-gift/fire-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 포효합니다!",
	equilibrium = 3,
	cooldown = 20,
	range = 0,
	on_learn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 1 end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	tactical = { DEFEND = 1, DISABLE = { confusion = 3 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.PHYSICAL, self:mindCrit(self:combatTalentStatDamage(t, "str", 40, 400)))
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur=3,
			dam=40 + 6 * self:getTalentLevel(t),
			power_check=function() return self:combatPhysicalpower() end,
			resist_check=self.combatPhysicalResist,
		})
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0, gM=0, bm=0.1, bM=0.2, am=0.4, aM=0.6})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[주변 %d 칸 반경의 적들에게 포효를 내질러, 3 턴 동안 혼란 상태로 만듭니다.
		포효하는 소리는 엄청나게 크기 때문에, 적들은 %0.2f 물리 피해를 추가로 입게 됩니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.
		이 기술의 레벨이 오를 때마다, 화염 저항력이 1%% 상승합니다.]]):format(radius, self:combatTalentStatDamage(t, "str", 40, 400))
	end,
}

newTalent{
	name = "Wing Buffet",
	kr_name = "바람의 뷔페",
	type = {"wild-gift/fire-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	equilibrium = 7,
	cooldown = 10,
	range = 0,
	on_learn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 1 end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
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
		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dam=self:mindCrit(self:combatTalentStatDamage(t, "str", 15, 90)), dist=4})
		game:playSoundNear(self, "talents/breath")

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		return ([[강력한 바람을 불러내, 전방 %d 칸 반경의 적들을 4 칸 밀어내고 %d 피해를 줍니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.
		이 기술의 레벨이 오를 때마다, 화염 저항력이 1%% 상승합니다.]]):format(self:getTalentRadius(t), self:combatTalentStatDamage(t, "str", 15, 90))
	end,
}

newTalent{
	name = "Devouring Flame",
	kr_name = "집어삼키는 화염",
	type = {"wild-gift/fire-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	equilibrium = 10,
	cooldown = 35,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	range = 10,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 1 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "wil", 15, 120)
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		local dam = self:mindCrit(t.getDamage(self, t))
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.FIRE, dam,
			radius,
			5, nil,
			{type="inferno"},
			nil, true
		)
		game:playSoundNear(self, "talents/devouringflame")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[불의 구름을 뿜어내, 대상 지역의 주변 %d 칸 반경에 있는 적들에게 %d 턴 동안 매 턴마다 %0.2f 화염 피해를 줍니다.
		피해량은 의지 능력치의 영향을 받아 증가하며, 치명타 효과가 발생할 수 있습니다.
		이 기술의 레벨이 오를 때마다, 화염 저항력이 1%% 상승합니다.]]):format(radius, duration, damDesc(self, DamageType.FIRE, dam)) --@ 변수 순서 조정
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
	message = "@Source1@ 화염을 뿜어냅니다!",
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
		self:project(tg, x, y, DamageType.FIREBURN, {dam=self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 550)), dur=3, initial=70})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
		end
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[전방 %d 칸 반경에 화염 브레스를 뿜어내, 3 턴 동안 %0.2f 화염 피해를 나눠서 줍니다.
		피해량은 힘 능력치의 영향을 받아 증가하며, 치명타율은 정신 치명타율을 따릅니다.
		이 기술의 레벨이 오를 때마다, 화염 저항력이 1%% 상승합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 550)))
	end,
}
