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

require "engine.krtrUtils" --@@

newTalent{
	name = "Swallow",
	kr_display_name = "삼키기",
	type = {"wild-gift/sand-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 4,
	cooldown = 10,
	range = 1,
	no_message = true,
	tactical = { ATTACK = { NATURE = 0.5 }, EQUILIBRIUM = 0.5},
	requires_target = true,
	no_npc_use = true,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		game.logSeen(self, "%s %s 삼키려 합니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"), (target.kr_display_name or target.name):addJosa("를"))

		local hit = self:attackTarget(target, DamageType.NATURE, self:combatTalentWeaponDamage(t, 1, 1.5), true)
		if not hit then return true end

		if (target.life * 100 / target.max_life > 10 + 3 * self:getTalentLevel(t)) and not target.dead then
			return true
		end

		if (target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 15) or target.dead) and (target:canBe("instakill") or target.life * 100 / target.max_life <= 5) then
			if not target.dead then target:die(self) end
			world:gainAchievement("EAT_BOSSES", self, target)
			self:incEquilibrium(-target.level - 5)
			self:attr("allow_on_heal", 1)
			self:heal(target.level * 2 + 5)
			self:attr("allow_on_heal", -1)
		else
			game.logSeen(target, "%s 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
		end
		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여, %d%% 무기 피해를 자연 속성으로 줍니다.
		공격에 맞은 대상의 생명력이 %d%% 이하로 떨어졌거나 죽었을 경우, 적을 삼켜 즉사시키고 레벨에 따라 생명력과 평정을 회복합니다.
		이 기술의 레벨이 오를 때마다, 물리 저항력이 0.5%% 상승합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.5), 10 + 3 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Quake",
	kr_display_name = "지진",
	type = {"wild-gift/sand-drake", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 지면에 발을 구릅니다!",
	equilibrium = 4,
	cooldown = 30,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	range = 10,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	radius = function(self, t)
		return 2 + self:getTalentLevel(t) / 2
	end,
	no_npc_use = true,
	getDamage = function(self, t)
		return self:combatDamage() * 0.8
	end,
	action = function(self, t)
		local tg = {type="ball", range=0, selffire=false, radius=self:getTalentRadius(t), talent=t, no_restrict=true}
		self:project(tg, self.x, self.y, DamageType.PHYSKNOCKBACK, {dam=self:mindCrit(t.getDamage(self, t)), dist=4})
		self:doQuake(tg, self.x, self.y)
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[지면에 발을 굴러, 주변 %d 칸 반경에 지진을 일으킵니다.
		지진의 영향을 받은 적은 %d 피해를 입고, 4 칸 밀려나게 됩니다.
		지진 반경 내의 지형들도 지진의 영향을 받아 위치가 바뀌게 됩니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.
		이 기술의 레벨이 오를 때마다, 물리 저항력이 0.5%% 상승합니다.]]):format(radius, dam)
	end,
}

newTalent{
	name = "Burrow",
	kr_display_name = "굴 파기",
	type = {"wild-gift/sand-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 50,
	cooldown = 30,
	range = 10,
	tactical = { CLOSEIN = 0.5, ESCAPE = 0.5 },
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	action = function(self, t)
		self:setEffect(self.EFF_BURROW, 5 + self:getTalentLevel(t) * 3, {})
		return true
	end,
	info = function(self, t)
		return ([[%d 턴 동안 벽 속을 파고들어갈 수 있게 됩니다.
		이 기술의 레벨이 오를 때마다, 물리 저항력이 0.5%% 상승합니다.]]):format(5 + self:getTalentLevel(t) * 3)
	end,
}

newTalent{
	name = "Sand Breath",
	kr_display_name = "모래 브레스",
	type = {"wild-gift/sand-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source1@ 모래를 뿜어냅니다!",
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = { blind = 2 } },
	range = 0,
	radius = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5 end,
	on_unlearn = function(self, t) self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "str", 30, 400)
	end,
	getDuration = function(self, t)
		return 2+self:getTalentLevelRaw(t)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SAND, {dur=t.getDuration(self, t), dam=self:mindCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_earth", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[전방 %d 칸 반경에 모래 브레스를 뿜어내, %0.2f 물리 피해를 주고 %d 턴 동안 실명시킵니다.
		피해량은 힘 능력치의 영향을 받아 증가하며, 치명타율은 정신 치명타율을 따릅니다.
		이 기술의 레벨이 오를 때마다, 물리 저항력이 0.5%% 상승합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, damage), duration)
	end,
}

