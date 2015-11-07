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
	name = "Prismatic Slash",
	kr_name = "무지개 베기",
	type = {"wild-gift/higher-draconic", 1},
	require = gifts_req_high1,
	points = 5,
	random_ego = "attack",
	equilibrium = 10,
	cooldown = 12,
	range = 1,
	is_melee = true,
	tactical = { ATTACK = { PHYSICAL = 1, COLD = 1, FIRE = 1, LIGHTNING = 1, ACID = 1 } },
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.6, 2.3) end,
	getBurstDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 230) end,
	getPassiveSpeed = function(self, t) return (self:combatTalentScale(t, 2, 10, 0.5)/100) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.5, 3.5)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physspeed", t.getPassiveSpeed(self, t))
		self:talentTemporaryValue(p, "combat_mindspeed", t.getPassiveSpeed(self, t))
	end,
	action = function(self, t)

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

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
				local grids = self:project(tg, x, y, DamageType.ICE_SLOW, self:mindCrit(t.getBurstDamage(self, t)))
				game.level.map:particleEmitter(x, y, tg.radius, "ball_ice", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
				game:playSoundNear(self, "talents/flame")
			elseif elem == "fire" then
				self:attackTarget(target, DamageType.FIREBURN, t.getWeaponDamage(self, t), true)
				local tg = {type="ball", range=1, selffire=false, radius=self:getTalentRadius(t), talent=t}
				local grids = self:project(tg, x, y, DamageType.FIRE_STUN, self:mindCrit(t.getBurstDamage(self, t)))
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
		local speed = t.getPassiveSpeed(self, t)
		return ([[적에게 순수하고, 불안정한 원소의 힘을 발산합니다. 적에게 %d%% 무기 피해를 실명의 모래, 무장해제의 산, 빙결과 둔화의 얼음, 혼절의 번개 혹은 기절의 화염 속성으로 가합니다. (같은 확률)
		추가적으로 해당 속성으로 %0.2f 피해를 주변 %d 칸 범위에 주며, 이 효과는 공격이 빗나가더라도 발생합니다.
		무지개 베기에 투자된 기술레벨 하나당 당신의 공격, 사고 속도가 %d%% 만큼 오릅니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1.2, 2.0), burstdamage, radius, 100*speed)
	end,
}

newTalent{
	name = "Venomous Breath",
	kr_name = "독성 브레스",
	type = {"wild-gift/higher-draconic", 2},
	require = gifts_req_high2,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ 독의 숨결을 내뱉습니다!",
	tactical = { ATTACKAREA = { poison = 2 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "str", 60, 750) end,
	getEffect = function(self, t) return math.ceil(self:combatTalentLimit(t, 50, 10, 20)) end,
	on_learn = function(self, t)
		self.resists[DamageType.NATURE] = (self.resists[DamageType.NATURE] or 0) + 3
		self.inc_damage[DamageType.NATURE] = (self.inc_damage[DamageType.NATURE] or 0) + 4
		end,
	on_unlearn = function(self, t)
		self.resists[DamageType.NATURE] = (self.resists[DamageType.NATURE] or 0) - 3
		self.inc_damage[DamageType.NATURE] = (self.inc_damage[DamageType.NATURE] or 0) - 4
		end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target:canBe("poison") then
				target:setEffect(self.EFF_CRIPPLING_POISON, 6, {src=self, power=dam/6, fail=math.ceil(self:combatTalentLimit(t, 100, 10, 20))})
			end
		end)

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_slime", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="poisonwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		local effect = t.getEffect(self, t)
		return ([[당신은 무력화 독의 숨결을 %d 범위의 원뿔형으로 내뱉습니다. 숨결에 휩쓸린 목표는 무력화 독에 중독이 되어 매턴 %0.2f 자연 피해를 6 턴동안 입습니다. 
		무력화 독은 %d%% 의 확률로 일반 공격이나 이동보다 복잡한 행동을 취소시킵니다.
		피해량은 당신의 힘 능력치에 비례하여 상승하고, 치명타율은 정신 치명타율을 따릅니다.
		독성 브레스에 투자된 레벨 하나마다 당신의 자연 저항력을 3%%, 자연 피해량을 4%% 만큼 상승시킵니다.]] ):format(self:getTalentRadius(t), damDesc(self, DamageType.NATURE, t.getDamage(self,t)/6), effect)
	end,
}

newTalent{
	name = "Wyrmic Guile",
	kr_name = "용의 교활함",
	type = {"wild-gift/higher-draconic", 3},
	require = gifts_req_high3,
	points = 5,
	mode = "passive",
	resistKnockback = function(self, t) return self:combatTalentLimit(t, 1, .17, .5) end, -- Limit < 100%
	resistBlindStun = function(self, t) return self:combatTalentLimit(t, 1, .07, .25) end, -- Limit < 100%
	CDreduce = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 1, 6)) end, -- Limit < 8
	on_learn = function(self, t)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] + 2
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_CUN] = self.inc_stats[self.STAT_CUN] - 2
	end,
	passives = function(self, t, p)
		local cdr = t.CDreduce(self, t)
		self:talentTemporaryValue(p, "knockback_immune", t.resistKnockback(self, t))
		self:talentTemporaryValue(p, "stun_immune", t.resistBlindStun(self, t))
		self:talentTemporaryValue(p, "blind_immune", t.resistBlindStun(self, t))
		self:talentTemporaryValue(p, "talent_cd_reduction",
{[Talents.T_VENOMOUS_BREATH]=cdr, [Talents.T_ICE_BREATH]=cdr, [Talents.T_FIRE_BREATH]=cdr, [Talents.T_LIGHTNING_BREATH]=cdr, [Talents.T_CORROSIVE_BREATH]=cdr, [Talents.T_SAND_BREATH]=cdr})
	end,
	info = function(self, t)
		return ([[당신은 용의 교활함을 가집니다.
		교활 능력치를 %d 만큼 상승시키고, 당신의 브레스 공격의 재사용 대기 시간을 %d 만큼 줄입니다.
		당신은 %d%% 만큼의 밀려남 저항력을 가지고, 실명, 기절 저항도 %d%% 만큼 얻습니다]]):format(2*self:getTalentLevelRaw(t), t.CDreduce(self, t), 100*t.resistKnockback(self, t), 100*t.resistBlindStun(self, t))
	end,
}

newTalent{
	name = "Chromatic Fury",
	kr_name = "무지개빛 분노",
	type = {"wild-gift/higher-draconic", 4},
	require = gifts_req_high4,
	points = 5,
	mode = "passive",
	resistPen = function(tl)
		if tl <=0 then return 0 end
		return math.floor(mod.class.interface.Combat.combatTalentLimit({}, tl, 100, 4, 20))
	end, -- Limit < 100%
	on_learn = function(self, t)
		self.resists[DamageType.PHYSICAL] = (self.resists[DamageType.PHYSICAL] or 0) + 0.5
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 0.5
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 0.5
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 0.5
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 0.5

		local rpchange = t.resistPen(self:getTalentLevelRaw(t)) - t.resistPen(self:getTalentLevelRaw(t)-1)
		self.resists_pen[DamageType.PHYSICAL] = (self.resists_pen[DamageType.PHYSICAL] or 0) + rpchange
		self.resists_pen[DamageType.COLD] = (self.resists_pen[DamageType.COLD] or 0) + rpchange
		self.resists_pen[DamageType.FIRE] = (self.resists_pen[DamageType.FIRE] or 0) + rpchange
		self.resists_pen[DamageType.LIGHTNING] = (self.resists_pen[DamageType.LIGHTNING] or 0) + rpchange
		self.resists_pen[DamageType.ACID] = (self.resists_pen[DamageType.ACID] or 0) + rpchange

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

		local rpchange = t.resistPen(self:getTalentLevelRaw(t)) - t.resistPen(self:getTalentLevelRaw(t)+1)
		self.resists_pen[DamageType.PHYSICAL] = (self.resists_pen[DamageType.PHYSICAL] or 0) + rpchange
		self.resists_pen[DamageType.COLD] = (self.resists_pen[DamageType.COLD] or 0) + rpchange
		self.resists_pen[DamageType.FIRE] = (self.resists_pen[DamageType.FIRE] or 0) + rpchange
		self.resists_pen[DamageType.LIGHTNING] = (self.resists_pen[DamageType.LIGHTNING] or 0) + rpchange
		self.resists_pen[DamageType.ACID] = (self.resists_pen[DamageType.ACID] or 0) + rpchange

		self.inc_damage[DamageType.PHYSICAL] = (self.inc_damage[DamageType.PHYSICAL] or 0) - 2
		self.inc_damage[DamageType.COLD] = (self.inc_damage[DamageType.COLD] or 0) - 2
		self.inc_damage[DamageType.FIRE] = (self.inc_damage[DamageType.FIRE] or 0) - 2
		self.inc_damage[DamageType.LIGHTNING] = (self.inc_damage[DamageType.LIGHTNING] or 0) - 2
		self.inc_damage[DamageType.ACID] = (self.inc_damage[DamageType.ACID] or 0) - 2
	end,
	info = function(self, t)
		return ([[당신은 무지개빛 용의 힘을 전부 얻어내고, 모든 원소의 수련이 끝났습니다.
		물리, 화염, 냉기, 전기, 산성 피해량을 %d%% 만큼 상승시키고, 그 원소들의 저항 관통을 %d%% 만큼 얻습니다.
		무지개빛 분노에 투자된 레벨 하나마다, 당신의 물리, 화염, 냉기, 전기, 산성 저항력이 0.5%% 만큼 오릅니다.]])
		:format(2*self:getTalentLevelRaw(t), t.resistPen(self:getTalentLevelRaw(t)))
	end,
}
