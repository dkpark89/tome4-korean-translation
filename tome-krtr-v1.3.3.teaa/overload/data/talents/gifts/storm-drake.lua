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

local Object = require "engine.Object"

newTalent{
	name = "Lightning Speed",
	kr_name = "번개의 속도",
	type = {"wild-gift/storm-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 25,
	range = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	requires_target = true,
	no_energy = true,
	getPassiveSpeed = function(self, t) return self:combatTalentScale(t, 0.08, 0.4, 0.7) end,
	getSpeed = function(self, t) return self:combatTalentScale(t, 470, 750, 0.75) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 1.1, 3.1)) end,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "movement_speed", t.getPassiveSpeed(self, t))
	end,
	on_pre_use = function(self, t) return not self:attr("never_move") end,
	action = function(self, t)
		self:setEffect(self.EFF_LIGHTNING_SPEED, self:mindCrit(t.getDuration(self, t)), {power=t.getSpeed(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[순수한 번개의 형태로 변신하여, %d%% 더 빠르게 %d 게임 턴 동안 움직입니다.
		또한 물리 저항력이 30%% 상승하며, 전기 저항력이 100%% 가 됩니다.
		이동 이외의 행동을 하면 효과가 해제됩니다.
		매우 빠르게 움직이기 때문에, 상대적으로 게임 상에서의 시간은 느려질 것입니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 전기 저항력이 1%% 상승합니다.]]):format(t.getSpeed(self, t), t.getDuration(self, t), t.getPassiveSpeed(self, t)*100)
	end,
}

newTalent{
	name = "Static Field",
	kr_name = "정전기장",
	type = {"wild-gift/storm-drake", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 20,
	cooldown = 20,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 6)) end,
	tactical = { ATTACKAREA = { instakill = 5 } },
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getPercent = function(self, t)
		return self:combatLimit(self:combatTalentMindDamage(t, 10, 45), 90, 0, 0, 31, 31) -- Limit to <90%
	end,
	getDamage = function(self, t)
		return self:combatTalentMindDamage(t, 20, 160)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local litdam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if not target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 10) then
				game.logSeen(target, "%s 정전기장에 저항했습니다!", target.name:capitalize())
				return
			end
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatMindpower())
			game.logSeen(target, "%s 정전기장에 걸려들었습니다!", target.name:capitalize())

			local perc = t.getPercent(self, t)
			if target.rank >= 5 then perc = perc / 2.5
			elseif target.rank >= 3.5 then perc = perc / 2
			elseif target.rank >= 3 then perc = perc / 1.5
			end

			local dam = target.life * perc / 100
			if target.life - dam < 0 then dam = target.life end
			target:takeHit(dam, self)
			self:project({type="hit", talent=t},target.x,target.y,DamageType.LIGHTNING,litdam)

			game:delayedLogDamage(self, target, dam, ("#PURPLE#%d STATIC#LAST#"):format(math.ceil(dam)))
		end, nil, {type="lightning_explosion"})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t)
		local litdam = t.getDamage(self, t)
		return ([[당신 주변 %d 칸에 정전기장을 생성합니다. 정전기장의 내부로 들어온 존재는 현재 생명력의 %0.1f%% 만큼을 잃습니다. (목표가 엘리트, 레어일 경우 %0.1f%% , 목표가 유니크, 보스일 경우 %0.1f%% , 목표가 엘리트 보스일 경우 %0.1f%% ). 생명력 흡수는 저항 할 수 없지만, 그들의 물리 내성으로 막아 낼 수 있습니다.
		또한, 정전기장은 %0.2f 의 전기 피해를 목표의 랭크와 상관 없이 입힙니다.
		현재 생명력 감소량, 전기 피해량은 당신의 정신력에 비례하여 상승하며, 전기 피해는 정신 치명타율에 따라 치명타가 일어날 수 있습니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 전기 저항력이 1%% 상승합니다.]]):format(self:getTalentRadius(t), percent, percent/1.5, percent/2, percent/2.5, damDesc(self, DamageType.LIGHTNING, litdam))
	end,
}

newTalent{
	name = "Tornado",
	kr_name = "회오리바람",
	type = {"wild-gift/storm-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 14,
	cooldown = 15,
	proj_speed = 4, -- This is purely indicative
	tactical = { ATTACK = { LIGHTNING = 2 }, DISABLE = { stun = 2 } },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 6)) end,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	getRadius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, 0.5, 0, 0, true)) end,
	getStunDuration = function(self, t) return self:combatTalentScale(t, 3, 6, 0.5, 0, 0, true) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), selffire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local movedam = self:mindCrit(self:combatTalentMindDamage(t, 10, 110))
		local dam = self:mindCrit(self:combatTalentMindDamage(t, 15, 190))
		local rad = t.getRadius(self, t)
		local dur = t.getStunDuration(self, t)

		local proj = require("mod.class.Projectile"):makeHoming(
			self,
			{particle="bolt_lightning", trail="lightningtrail"},
			{speed=4, name="Tornado", dam=dam, movedam=movedam, rad=rad, dur=dur},
			target,
			self:getTalentRange(t),
			function(self, src)
				local DT = require("engine.DamageType")
				DT:get(DT.LIGHTNING).projector(src, self.x, self.y, DT.LIGHTNING, self.def.movedam)
			end,
			function(self, src, target)
				local DT = require("engine.DamageType")
				src:project({type="ball", radius=self.def.rad, selffire=false, x=self.x, y=self.y}, self.x, self.y, DT.LIGHTNING, self.def.dam)
				src:project({type="ball", radius=self.def.rad, selffire=false, x=self.x, y=self.y}, self.x, self.y, DT.MINDKNOCKBACK, self.def.dam)
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, self.def.dur, {apply_power=src:combatMindpower()})
				else
					game.logSeen(target, "%s 회오리바람에 저항했습니다!", target.name:capitalize())
				end

				-- Lightning ball gets a special treatment to make it look neat
				local sradius = (1 + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
				local nb_forks = 16
				local angle_diff = 360 / nb_forks
				for i = 0, nb_forks - 1 do
					local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
					local tx = self.x + math.floor(math.cos(a) * 1)
					local ty = self.y + math.floor(math.sin(a) * 1)
					game.level.map:particleEmitter(self.x, self.y, 1, "lightning", {radius=1, tx=tx-self.x, ty=ty-self.y, nb_particles=25, life=8})
				end
				game:playSoundNear(self, "talents/lightning")
			end
		)
		game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local rad = t.getRadius(self, t)
		local duration = t.getStunDuration(self, t)
		return ([[목표를 추적하며 느리게 이동하는 회오리바람을 소환 합니다.
		회오리가 이동하는 중 휩쓸린 적은 %0.2f 의 전기 피해를 입습니다.
		목표에게 도착하였을 때, 회오리는 폭발하여 %d 범위의 적에게 %0.2f 의 전기 피해와 %0.2f 의 물리 피해를 입힙니다. 영향을 받은 모든 존재는 밀려나며, 목표였던 존재는 %d 턴 동안 기절 상태에 빠집니다. 폭발은 기술 사용자를 무시합니다.
		회오리는 %d 턴 동안 유지되며, 폭발하면 사라집니다.
		피해량은 정신력에 비례하여 상승하고, 기절 확율은 당신의 정신력과 목표의 물리내성에 달려 있습니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 전기 저항력이 1%% 상승합니다.]]):format(
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 10, 110)),
			rad,
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 15, 190)),
			damDesc(self, DamageType.PHYSICAL, self:combatTalentMindDamage(t, 15, 190)),
			duration,
			self:getTalentRange(t)
		)
	end,
}

newTalent{
	name = "Lightning Breath",
	kr_name = "번개 브레스",
	type = {"wild-gift/storm-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ 번개의 숨결을 내뱉습니다!",
	tactical = { ATTACKAREA = {LIGHTNING = 2}, DISABLE = { stun = 1 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t)
		return self:combatTalentStatDamage(t, "str", 30, 670)
	end,
	getDaze = function(self, t) 
		return 20+self:combatTalentMindDamage(t, 10, 30) 
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.LIGHTNING_DAZE, {daze=t.getDaze(self, t), power_check=self:combatMindpower(), dam=rng.avg(dam / 3, dam, 3)})

		if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y}, {type="lightning"})
		else game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		end

		
		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="lightningwings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
		end
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local daze = t.getDaze(self, t)
		return ([[당신은 번개의 숨결을 내뱉어 %d 범위의 원뿔 모양으로 발사합니다. 번개의 숨결에 휩싸인 목표는 %0.2f에서 %0.2f 의 전기 피해를 받고, %d%% 의 확율로 3 턴간 혼절 상태에 빠집니다.
		피해량은 당신의 힘 능력치에 비례하고, 치명타율은 정신 치명타율을 따릅니다. 혼절 확율은 정신력에 비례합니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 전기 저항력이 1%% 상승합니다.]]):format(
			self:getTalentRadius(t),
			damDesc(self, DamageType.LIGHTNING, damage / 3),
			damDesc(self, DamageType.LIGHTNING, damage),
			daze
		)
	end,
}
