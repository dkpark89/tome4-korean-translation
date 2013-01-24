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
	name = "Prismatic Slash",
	kr_display_name = "무지개 베기",
	type = {"wild-gift/higher-draconic", 1},
	require = gifts_req_high1,
	points = 5,
	random_ego = "attack",
	equilibrium = 20,
	cooldown = 16,
	range = 1,
	tactical = { ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1 } },
	requires_target = true,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.0) end,
	getBurstDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 230) end,
	radius = function(self, t)
		return 1 + self:getTalentLevel(t) / 2
	end,
	on_learn = function(self, t) 
		self.combat_physresist = self.combat_physresist + 1
		self.combat_spellresist = self.combat_spellresist + 1
		self.combat_mentalresist = self.combat_mentalresist + 1
	end,
	on_unlearn = function(self, t) 
		self.combat_physresist = self.combat_physresist - 1
		self.combat_spellresist = self.combat_spellresist - 1
		self.combat_mentalresist = self.combat_mentalresist - 1
	end,
	action = function(self, t)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local elem = rng.table{"phys", "cold", "fire", "lightning", "acid",}

			if elem == "phys" then
				self:attackTarget(target, DamageType.PHYSICAL, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.SAND, {dur=3, dam=self:mindCrit(t.getBurstDamage(self, t))})
				game.level.map:particleEmitter(x, y, tg.radius, "ball_matter", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "cold" then
				self:attackTarget(target, DamageType.ICE, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.ICE, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_ice", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "fire" then
				self:attackTarget(target, DamageType.FIREBURN, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.FIREBURN, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_fire", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "lightning" then
				self:attackTarget(target, DamageType.LIGHTNING_DAZE, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.LIGHTNING_DAZE, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_lightning", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "acid" then
				self:attackTarget(target, DamageType.ACID_DISARM, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.ACID_DISARM, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_acid", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			end
		return true
	end,
	info = function(self, t)
		local burstdamage = t.getBurstDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[적에게 순수한 원소의 힘을 발산합니다. 적에게 %d%% 무기 피해와 함께, 다양한 속성 효과를 줍니다.
		추가적으로 주변 %d 칸 반경에 해당 속성으로 %0.2f 피해를 주며, 이 효과는 공격이 빗나가더라도 발생합니다.
		기술 레벨을 올릴 때마다, 모든 내성이 1 증가합니다.
		적에게 줄 수 있는 속성 효과는 다음과 같습니다.
		- 모래바람 (물리+실명)
		- 강산 (산성+무장 해제)
		- 극한의 냉기 (냉기+빙결)
		- 굉음의 번개 (전기+기절)
		- 타오르는 화염 (화염+화상)]]):format(100 * self:combatTalentWeaponDamage(t, 1.2, 2.0), radius, burstdamage)
	end,
}

newTalent{
	name = "Venomous Breath",
	kr_display_name = "독성 브레스",
	type = {"wild-gift/higher-draconic", 2},
	require = gifts_req_high2,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ breathes venom!",
	tactical = { ATTACKAREA = { poison = 2 } },
	range = 0,
	radius = function(self, t) return 4 + self:getTalentLevelRaw(t) end,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 60, 650) end,
	getEffect = function(self, t) return 10 + self:getTalentLevel(t) * 8 end,
	on_learn = function(self, t) self.resists[DamageType.NATURE] = (self.resists[DamageType.NATURE] or 0) + 2 end,
	on_unlearn = function(self, t) self.resists[DamageType.NATURE] = (self.resists[DamageType.NATURE] or 0) - 2 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.INSIDIOUS_POISON, {dam=self:mindCrit(t.getDamage(self,t)), dur=6, heal_factor=t.getEffect(self,t)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_slime", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local effect = t.getEffect(self, t)
		return ([[전방 %d 칸에 독성 브레스를 뿜어내, 6 턴 동안 매 턴마다 %0.2f 자연 피해를 줍니다.
		독에 걸린 적들은 생명력 회복 효율이 %d%% 떨어지게 됩니다.
		피해량은 힘 능력치의 영향을 받아 증가하며, 치명타율은 정신 치명타율을 기반으로 합니다.
		기술 레벨을 올릴 때마다, 자연 저항력이 2%% 증가합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.NATURE, t.getDamage(self,t)/6), effect)
	end,
}

newTalent{
	name = "Wyrmic Guile",
	kr_display_name = "용의 교활함",
	type = {"wild-gift/higher-draconic", 3},
	require = gifts_req_high3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] + 2
		self:onStatChange(self.STAT_CUN, 2)
		self.stun_immune = (self.stun_immune or 0) + .05
		self.blind_immune = (self.blind_immune or 0) + .05
		self.knockback_immune = (self.knockback_immune or 0) + .1
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] - 2
		self:onStatChange(self.STAT_CUN, -2)
		self.stun_immune = (self.stun_immune or 0) - .05
		self.blind_immune = (self.blind_immune or 0) - .05
		self.knockback_immune = (self.knockback_immune or 0) - .1
	end,
	info = function(self, t)
		return ([[용의 교활함을 가져, 교활함 수치가 %d 증가합니다.
		기술 레벨을 올릴 때마다 밀어내기 저항력이 10%% 증가하며, 실명과 기절 저항력은 5%% 증가합니다.]]):format(2*self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Chromatic Fury",
	kr_display_name = "모든 용의 분노",
	type = {"wild-gift/higher-draconic", 4},
	require = gifts_req_high4,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 0.5
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 0.5
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 0.5
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 0.5

		self.resists_pen[DamageType.PHYSICAL] = (self.resists_pen[DamageType.PHYSICAL] or 0) + 4
		self.resists_pen[DamageType.COLD] = (self.resists_pen[DamageType.COLD] or 0) + 4
		self.resists_pen[DamageType.FIRE] = (self.resists_pen[DamageType.FIRE] or 0) + 4
		self.resists_pen[DamageType.LIGHTNING] = (self.resists_pen[DamageType.LIGHTNING] or 0) + 4
		self.resists_pen[DamageType.ACID] = (self.resists_pen[DamageType.ACID] or 0) + 4
		
		self.inc_damage[DamageType.PHYSICAL] = (self.inc_damage[DamageType.PHYSICAL] or 0) + 2
		self.inc_damage[DamageType.COLD] = (self.inc_damage[DamageType.COLD] or 0) + 2
		self.inc_damage[DamageType.FIRE] = (self.inc_damage[DamageType.FIRE] or 0) + 2
		self.inc_damage[DamageType.LIGHTNING] = (self.inc_damage[DamageType.LIGHTNING] or 0) + 2
		self.inc_damage[DamageType.ACID] = (self.inc_damage[DamageType.ACID] or 0) + 2
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) - 0.5
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 0.5
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 0.5
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 0.5
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) - 0.5

		self.resists_pen[DamageType.PHYSICAL] = (self.resists_pen[DamageType.PHYSICAL] or 0) - 4
		self.resists_pen[DamageType.COLD] = (self.resists_pen[DamageType.COLD] or 0) - 4
		self.resists_pen[DamageType.FIRE] = (self.resists_pen[DamageType.FIRE] or 0) - 4
		self.resists_pen[DamageType.LIGHTNING] = (self.resists_pen[DamageType.LIGHTNING] or 0) - 4
		self.resists_pen[DamageType.ACID] = (self.resists_pen[DamageType.ACID] or 0) - 4

		self.inc_damage[DamageType.PHYSICAL] = (self.inc_damage[DamageType.PHYSICAL] or 0) - 2
		self.inc_damage[DamageType.COLD] = (self.inc_damage[DamageType.COLD] or 0) - 2
		self.inc_damage[DamageType.FIRE] = (self.inc_damage[DamageType.FIRE] or 0) - 2
		self.inc_damage[DamageType.LIGHTNING] = (self.inc_damage[DamageType.LIGHTNING] or 0) - 2
		self.inc_damage[DamageType.ACID] = (self.inc_damage[DamageType.ACID] or 0) - 2
	end,
	info = function(self, t)
		return ([[모든 용의 힘을 얻었으며, 모든 속성의 수련을 끝마쳤습니다.
		물리, 화염, 냉기, 전기, 산성 피해량이 %d%% 증가하며, 각 속성의 저항 관통력이 %d%% 증가합니다.
		기술 레벨이 오를 때마다 물리, 화염, 냉기, 전기, 산성 저항력이 0.5%% 증가합니다.]])
		:format(2*self:getTalentLevelRaw(t), 4*self:getTalentLevelRaw(t))
	end,
}
