-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

require "engine.krtrUtils"

local Object = require "engine.Object"

newTalent{
	name = "Lightning Speed",
	kr_name = "번개의 속도",
	type = {"wild-gift/storm-drake", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 26,
	range = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	requires_target = true,
	no_energy = true,
	getSpeed = function(self, t) return self:combatTalentScale(t, 470, 750, 0.75) end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 1.1, 2.6)) end,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	on_pre_use = function(self, t) return not self:attr("never_move") end,
	action = function(self, t)
		self:setEffect(self.EFF_LIGHTNING_SPEED, self:mindCrit(t.getDuration(self, t)), {power=t.getSpeed(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[순수한 번개의 형태로 변신하여, 게임의 전체적인 턴으로 %d 턴 동안 %d%% 더 빠르게 움직입니다.
		또한 물리 저항력이 30%% 상승하며, 전기 저항력이 100%% 가 됩니다.
		이동 이외의 행동을 하면 효과가 해제됩니다.
		매우 빠르게 움직이기 때문에, 상대적으로 게임 상에서의 시간은 느려집니다.
		이 기술의 레벨이 오를 때마다, 전기 저항력이 1%% 상승합니다.]]):
		format(t.getDuration(self, t), t.getSpeed(self, t)) --@ 변수 순서 조정
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
	radius = 1,
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
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if not target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 10) then
				game.logSeen(target, "%s 전기장의 효과를 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				return
			end
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatMindpower())
			game.logSeen(target, "%s 전기장에 걸려들었습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))

			local perc = t.getPercent(self, t)
			if target.rank >= 5 then perc = perc / 3
			elseif target.rank >= 3.5 then perc = perc / 2
			elseif target.rank >= 3 then perc = perc / 1.5
			end

			local dam = target.life * perc / 100
			if target.life - dam < 0 then dam = target.life end
			target:takeHit(dam, self)

			game:delayedLogDamage(self, target, dam, ("#PURPLE#%d 전기장#LAST#"):format(math.ceil(dam))) 
		end, nil, {type="lightning_explosion"})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t)
		return ([[주변 1 칸 반경에 전기장을 만들어냅니다. 저항에 실패할 경우, 전기장의 영향을 받은 적은 현재 생명력의 %0.1f%% 를 잃게 됩니다. (높은 등급의 적에게는 효과가 감소됩니다)
		이 효과로는 무언가를 죽일 수 없습니다. 생명력 감소량은 정신력의 영향을 받아 증가합니다.
		이 기술의 레벨이 오를 때마다, 전기 저항력이 1%% 상승합니다.]]):format(percent)
	end,
}

newTalent{
	name = "Tornado",
	kr_name = "태풍",
	type = {"wild-gift/storm-drake", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 14,
	cooldown = 15,
	proj_speed = 2, -- This is purely indicative
	tactical = { ATTACK = { LIGHTNING = 2 }, DISABLE = { stun = 2 } },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) - 1 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		local movedam = self:mindCrit(self:combatTalentMindDamage(t, 10, 110))
		local dam = self:mindCrit(self:combatTalentMindDamage(t, 15, 190))

		local proj = require("mod.class.Projectile"):makeHoming(
			self,
			{particle="bolt_lightning", trail="lightningtrail"},
			{speed=2, name="Tornado", dam=dam, movedam=movedam},
			target,
			self:getTalentRange(t),
			function(self, src)
				local DT = require("engine.DamageType")
				DT:get(DT.LIGHTNING).projector(src, self.x, self.y, DT.LIGHTNING, self.def.movedam)
			end,
			function(self, src, target)
				local DT = require("engine.DamageType")
				src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.LIGHTNING, self.def.dam)
				src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.MINDKNOCKBACK, self.def.dam)
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, 4, {apply_power=src:combatMindpower()})
				else
					game.logSeen(target, "%s 태풍의 효과를 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
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
		return ([[대상을 향해 천천히 움직이는 태풍을 소환합니다.
		태풍의 이동경로에 있는 적들은 %0.2f 전기 피해를 입습니다.
		대상에게 접근하면 태풍이 폭발하여, 주변 1 칸 반경에 %0.2f 전기 피해와 %0.2f 물리 피해를 줍니다. 태풍은 폭발하면서 주변의 적들을 밀어내며, 대상은 4 턴 동안 기절하게 됩니다.
		태풍은 %d 턴 동안 지속됩니다.
		이 기술의 레벨이 오를 때마다, 전기 저항력이 1%% 상승합니다.]]):format(
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 10, 110)),
			damDesc(self, DamageType.LIGHTNING, self:combatTalentMindDamage(t, 15, 190)),
			damDesc(self, DamageType.PHYSICAL, self:combatTalentMindDamage(t, 15, 190)),
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
	message = "@Source1@ 번개를 뿜어냅니다!",
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
		return self:combatTalentStatDamage(t, "str", 30, 500)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.LIGHTNING_DAZE, {power_check=self:combatMindpower(), dam=rng.avg(dam / 3, dam, 3)})

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
		return ([[전방 %d 칸 반경에 번개 브레스를 뿜어내, 적들에게 %0.2f - %0.2f 전기 피해를 주고 3 턴 동안 혼절시킵니다.
		피해량은 힘 능력치의 영향을 받으며, 치명타율은 정신 치명타율을 따릅니다.
		이 기술의 레벨이 오를 때마다, 전기 저항력이 1%% 상승합니다.]]):format(
			self:getTalentRadius(t),
			damDesc(self, DamageType.LIGHTNING, damage / 3),
			damDesc(self, DamageType.LIGHTNING, damage)
		)
	end,
}
