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
	name = "Turn Back the Clock",
	kr_name = "시간 되돌리기",
	type = {"chronomancy/age-manipulation", 1},
	require = chrono_req1,
	points = 5,
	paradox = 5,
	cooldown = 4,
	tactical = { ATTACK = {TEMPORAL = 2}, DISABLE = 2 },
	range = 10,
	reflectable = true,
	requires_target = true,
	proj_speed = 5,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 150)*getParadoxModifier(self, pm) end,
	getDamageStat = function(self, t) return 2 + math.ceil(t.getDamage(self, t) / 15) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="temporal_bolt"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:projectile(tg, x, y, DamageType.CLOCK, self:spellCrit(t.getDamage(self, t)), nil)
		game:playSoundNear(self, "talents/spell_generic2")

		--bolt #2 (Talent Level 4 Bonus Bolt)
		if self:getTalentLevel(t) >= 4 then
			local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="temporal_bolt"}}
			local x, y = self:getTarget(tg2)
			if x and y then
				x, y = checkBackfire(self, x, y)
				if x and y then
					self:projectile(tg2, x, y, DamageType.CLOCK, self:spellCrit(t.getDamage(self, t)), nil)
					game:playSoundNear(self, "talents/spell_generic2")
				end
			end
		else end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damagestat = t.getDamageStat(self, t)
		return ([[시간의 힘이 담긴 화살을 발사하여 %0.2f 시간 피해를 주고, 대상의 모든 능력치를 3 턴 동안 %d 낮춥니다.
		기술 레벨이 4 이상이면, 두 번째 화살을 발사할 수 있습니다.
		피해량은 괴리 수치와 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage), damagestat)
	end,
}

newTalent{
	name = "Temporal Fugue",
	kr_name = "시간의 푸가",
	type = {"chronomancy/age-manipulation", 2},
	require = chrono_req2,
	points = 5,
	paradox = 15,
	cooldown = 14,
	tactical = { ATTACKAREA = 2, DISABLE= 2 },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	requires_target = true,
	direct_hit = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getConfuseDuration = function(self, t) return math.floor(self:combatScale((self:getTalentLevel(t) + 2) * getParadoxModifier(self, pm), 2, 2, 7, 7)) end,
	getConfuseEfficency = function(self, t) return math.min(50, self:getTalentLevelRaw(t) * 10) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, DamageType.CONFUSION, {
			dur = t.getConfuseDuration(self, t),
			dam = t.getConfuseEfficency(self, t)
		})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "temporal_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local duration = t.getConfuseDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[전방 %d 칸 반경에 있는 적들의 정신을 유아 수준으로 퇴행시켜, %d 턴 동안 혼란 상태(%d%% to act randomly)로 만듭니다.
		지속시간은 괴리 수치의 영향을 받아 증가합니다.]]):
		format(radius, t.getConfuseEfficency(self, t), duration) --@@ 한글화 필요 : 두줄 위
	end,
}

newTalent{
	name = "Ashes to Ashes",
	kr_name = "재는 재로",
	type = {"chronomancy/age-manipulation",3},
	require = chrono_req3,
	points = 5,
	paradox = 20,
	cooldown = 14,
	tactical = { ATTACKAREA = {TEMPORAL = 2} },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 3.25, 4.25)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 8, 135)*getParadoxModifier(self, pm) end,
	getDuration = function(self, t) return 5 + math.ceil(self:getTalentLevel(t)) end,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.WASTING, t.getDamage(self, t),
			tg.radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=176, color_bg=196, color_bb=222},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			tg.selffire
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[주변 %d 칸 반경에 시간의 왜곡장을 형성하여, 왜곡장 안의 적들에게 3 턴 동안 %0.2f 시간 피해를 나눠서 줍니다. 적이 계속 왜곡장 안에 있을 경우, 시간 피해도 지속적으로 받게 됩니다.
		왜곡장은 %d 턴 동안 유지되며, 피해량은 괴리 수치와 주문력의 영향을 받아 증가합니다.]]):format(radius, damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
}

newTalent{
	name = "Body Reversion",
	kr_name = "신체 역행",
	type = {"chronomancy/age-manipulation", 4},
	require = chrono_req4,
	points = 5,
	paradox = 10,
	cooldown = 10,
	tactical = { HEAL = 2, CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "physical" then
				nb = nb + 1
			end
		end
		return nb
	end },
	is_heal = true,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 40, 440)*getParadoxModifier(self, pm) end,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.5, y=-0.3, img="healparadox", life=25}, {type="healing", time_factor=3000, beamsCount=15, noup=2.0, beamColor1={0xb6/255, 0xde/255, 0xf3/255, 1}, beamColor2={0x5c/255, 0xb2/255, 0xc2/255, 1}}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healparadox", life=25}, {type="healing", time_factor=3000, beamsCount=15, noup=1.0, beamColor1={0xb6/255, 0xde/255, 0xf3/255, 1}, beamColor2={0x5c/255, 0xb2/255, 0xc2/255, 1}}))
		end
		self:attr("allow_on_heal", -1)

		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type == "physical" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[육체의 시간을 역행시켜, %0.2f 생명력을 회복하고 물리적 상태효과를 %d 개 제거합니다.
		좋은 효과도 같이 제거되며, 생명력 회복량은 괴리 수치와 주문력의 영향을 받아 증가합니다.]]):
		format(heal, count)
	end,
}
