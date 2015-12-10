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
	name = "Blood Splash",
	kr_name = "핏방울",
	type = {"corruption/vile-life", 1},
	require = corrs_req1,
	points = 5,
	mode = "passive",
	heal = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	callbackOnCrit = function(self, t)
		if self.turn_procs.blood_splash_on_crit then return end
		self.turn_procs.blood_splash_on_crit = true

		self:heal(t.heal(self, t), self)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end
	end,
	callbackOnKill = function(self, t)
		if self.turn_procs.blood_splash_on_kill then return end
		self.turn_procs.blood_splash_on_kill = true

		self:heal(t.heal(self, t), self)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, circleDescendSpeed=3.5}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, circleDescendSpeed=3.5}))
		end
	end,
	info = function(self, t)
		return ([[다른 자들의 고통과 죽음을 통해 활력을 얻게 됩니다.
		치명타 피해를 입힐 때마다, %d 생명력을 회복하게 됩니다. (이 효과는 1 턴에 2 번 이상 발생하지 않습니다)
		무언가를 죽일 때마다, %d 생명력을 회복하게 됩니다. (이 효과는 1 턴에 2 번 이상 발생하지 않습니다)]]):
		format(t.heal(self, t), t.heal(self, t))
	end,
}

newTalent{
	name = "Elemental Discord",
	kr_name = "원소의 불화",
	type = {"corruption/vile-life", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 20,
	sustain_vim = 30,
	mode = "sustained",
	tactical = { BUFF = 2 },
	getFire = function(self, t) return self:combatTalentSpellDamage(t, 10, 400) end,
	getCold = function(self, t) return self:combatTalentSpellDamage(t, 10, 500) end,
	getLightning = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 3, 5)) end,
	getAcid = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 2, 5)) end,
	getNature = function(self, t) return self:combatTalentLimit(t, 60, 15, 45) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		local p = self:isTalentActive(t.id)
		if not p then return end
		if not src.setEffect then return end
		if not p.last_turn[type] or game.turn - p.last_turn[type] < 100 then return end

		if type == DamageType.FIRE then
			src:setEffect(src.EFF_BURNING, 5, {src=self, apply_power=self:combatSpellpower(), power=t.getFire(self, t) / 5})
		elseif type == DamageType.COLD then
			src:setEffect(src.EFF_FROZEN, 3, {apply_power=self:combatSpellpower(), hp=t.getCold(self, t)})
		elseif type == DamageType.ACID then
			src:setEffect(src.EFF_BLINDED, t.getAcid(self, t), {apply_power=self:combatSpellpower()})
		elseif type == DamageType.LIGHTNING then
			src:setEffect(src.EFF_DAZED, t.getLightning(self, t), {apply_power=self:combatSpellpower()})
		elseif type == DamageType.NATURE then
			src:setEffect(src.EFF_SLOW, 4, {apply_power=self:combatSpellpower(), power=t.getNature(self, t) / 100})
		end
		p.last_turn[type] = game.turn
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		return {
			last_turn = {
				[DamageType.FIRE] = game.turn - 100,
				[DamageType.COLD] = game.turn - 100,
				[DamageType.ACID] = game.turn - 100,
				[DamageType.LIGHTNING] = game.turn - 100,
				[DamageType.NATURE] = game.turn - 100,
			},
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[원소 속성의 피해를 받을 경우, 그 제공자에게 끔찍한 효과를 일으킵니다.
		- 화염 : 5 턴에 걸쳐 %0.2f 화염 피해
		- 냉기 : 3 턴 동안 빙결 (얼음의 생명력 : %d)
		- 산성 : %d 턴 동안 실명
		- 전기 : %d 턴 동안 혼절
		- 자연 : 4 턴 동안 %d%% 감속
		이 효과는 한 번 발생하면 10 턴의 재사용 대기 시간을 갖습니다. (각 속성마다 재사용 대기 시간은 다르게 적용됩니다)
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(
			damDesc(self, DamageType.FIRE, t.getFire(self, t)),
			t.getCold(self, t),
			t.getAcid(self, t),
			t.getLightning(self, t),
			t.getNature(self, t)
		)
	end,
}

newTalent{
	name = "Healing Inversion",
	kr_name = "회복 반전",
	type = {"corruption/vile-life", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 15,
	vim = 16,
	range = 5,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getPower = function(self,t) return self:combatLimit(self:combatTalentSpellDamage(t, 4, 100), 100, 0, 0, 18.1, 18.1) end, -- Limit to <100%
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_HEALING_INVERSION, 5, {apply_power=self:combatSpellpower(), power=t.getPower(self, t)})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상의 원기를 조작하여, 일시적으로 모든 회복 효과를 반전시킵니다. (단, '재생' 효과는 반전되지 않습니다)
		5 턴 동안 대상의 모든 회복 효과가 적용되지 않으며, 대신 회복량의 %d%% 만큼이 황폐 피해로 적용됩니다.
		기술의 효과는 주문력의 영향을 받아 증가합니다.]]):format(t.getPower(self,t))
	end,
}

newTalent{
	name = "Vile Transplant",
	kr_name = "비열한 이식",
	type = {"corruption/vile-life", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 10,
	vim = 18,
	direct_hit = true,
	requires_target = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4, "log")) end,
	getDam = function(self, t) return self:combatTalentLimit(t, 2, 10, 5) end, --Limit < 10% life/effect
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end

			local list = {}
			local nb = t.getNb(self, t)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if (e.type == "physical" or e.type == "magical") and e.status == "detrimental" then
					list[#list+1] = eff_id
				end
			end

			local dam = t.getDam(self, t) * self.life / 100
			while #list > 0 and nb > 0 do
				if self:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 5) then
					local eff_id = rng.tableRemove(list)
					local p = self.tmp[eff_id]
					local e = self.tempeffect_def[eff_id]
					local effectParam = self:copyEffect(eff_id)
					effectParam.src = self

					target:setEffect(eff_id, p.dur, effectParam)
					self:removeEffect(eff_id)
					local dead, val = self:takeHit(dam, self, {source_talent=t})
					target:heal(val, self)
					game:delayedLogMessage(self, target, "vile_transplant"..e.desc, ("#CRIMSON##Source1# '%s' 효과를 #Target#에게로 이식시켰습니다!"):format(e.kr_desc or e.desc))
				end
				nb = nb - 1
			end
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, g=100, r=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[최대 %d 개의 해로운 물리적 / 마법적 효과들을 손이 닿을 거리에 있는 대상에게 이식시킵니다.
		그 대가로, 이식 대상은 이식된 해로운 효과 1 개당 시전자의 현재 생명력을 %0.1f%% 만큼 흡수해갑니다.
		해로운 효과를 이식시킬 확률은 주문력의 영향을 받아 증가합니다.]]):
		format(t.getNb(self, t), t.getDam(self, t))
	end,
}
