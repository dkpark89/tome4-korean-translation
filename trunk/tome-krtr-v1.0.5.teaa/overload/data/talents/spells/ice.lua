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

require "engine.krtrUtils"

newTalent{
	name = "Ice Shards",
	kr_name = "얼음 파편",
	type = {"spell/ice",1},
	require = spells_req_high1,
	points = 5,
	mana = 12,
	cooldown = 3,
	tactical = { ATTACKAREA = { COLD = 1, stun = 1 } },
	range = 10,
	radius = 1,
	proj_speed = 4,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 18, 200) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = self:project(tg, x, y, function(px, py)
			local actor = game.level.map(px, py, Map.ACTOR)
			if actor and actor ~= self then
				local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="ice_shards"}}
				self:projectile(tg2, px, py, DamageType.ICE, self:spellCrit(t.getDamage(self, t)), {type="freeze"})
			end
		end)

		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[선택한 지역의 주변 1 칸 범위에 %0.2f 냉기 피해를 주는 얼음 파편들을 발사합니다. 파편의 속도는 느린 편이며, 범위 내에 있는 적의 숫자만큼 파편이 발사됩니다.
		얼음 파편은 시전자에게 피해를 주지 않습니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD, damage))
	end,
}

newTalent{
	name = "Frozen Ground",
	kr_name = "얼어붙은 대지",
	type = {"spell/ice",2},
	require = spells_req_high2,
	points = 5,
	mana = 25,
	cooldown = 10,
	requires_target = true,
	tactical = { ATTACKAREA = { COLD = 2 }, DISABLE = { stun = 1 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 280) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.COLDNEVERMOVE, {dur=4, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_ice", {radius=tg.radius})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[주변 %d 칸 반경의 기온을 급격하게 떨어트려 %0.2f 냉기 피해를 주고, 주변의 적들에게 4 턴 동안 '얼어붙은 발' 상태효과를 일으킵니다.
		얼어붙은 발 상태효과에 걸리면 이동은 할 수 없게 되지만, 다른 행동에는 영향을 주지 않습니다.
		피해량은 주문력의 영향을 받아 상승합니다.]]):format(radius, damDesc(self, DamageType.COLD, damage))
	end,
}

newTalent{
	name = "Shatter",
	kr_name = "파쇄",
	type = {"spell/ice",3},
	require = spells_req_high3,
	points = 5,
	mana = 25,
	cooldown = 15,
	tactical = { ATTACKAREA = { COLD = function(self, t, target) if target:attr("frozen") then return 2 end return 0 end } },
	range = 10,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 320) end,
	getTargetCount = function(self, t) return math.ceil(self:getTalentLevel(t) + 2) end,
	action = function(self, t)
		local max = t.getTargetCount(self, t)
		for i, act in ipairs(self.fov.actors_dist) do
			if self:reactionToward(act) < 0 then
				if act:attr("frozen") then
					-- Instakill critters
					if act.rank <= 1 then
						if act:canBe("instakill") then
							game.logSeen(act, "%s 박살났습니다!", (act.kr_name or act.name):capitalize():addJosa("가"))
							act:die(self)
						end
					end

					if not act.dead then
						local add_crit = 0
						if act.rank == 2 then add_crit = 50
						elseif act.rank >= 3 then add_crit = 25 end
						local tg = {type="hit", friendlyfire=false, talent=t}
						local grids = self:project(tg, act.x, act.y, DamageType.COLD, self:spellCrit(t.getDamage(self, t), add_crit))
						game.level.map:particleEmitter(act.x, act.y, tg.radius, "ball_ice", {radius=1})
					end

					max = max - 1
					if max <= 0 then break end
				end
			end
		end
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local targetcount = t.getTargetCount(self, t)
		return ([[빙결 상태효과에 의해 얼음에 갇힌 적들을 부숴버립니다. 시야 내의 모든 적들에게 적용되며, %0.2f 냉기 피해를 줍니다.
		대상의 등급에 따라, 추가 효과가 일어납니다 :
		* '일반' 미만 등급의 적들은 즉사합니다.
		* '일반' 등급의 적들에게는 치명타율이 50%% 증가합니다.
		* '정예' 와 '보스' 등급의 적들에게는 치명타율이 25%% 증가합니다.
		한번에 %d 개의 얼음까지 파괴할 수 있습니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD, damage), targetcount)
	end,
}

newTalent{
	name = "Uttercold",
	kr_name = "절대영도",
	type = {"spell/ice",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getColdDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:combatTalentLimit(t, 100, 17, 50) end, -- Limit < 100
	getPierce = function(self, t) return math.max(100, self:getTalentLevelRaw(t) * 20) end, 
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")

		local ret = {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.COLD] = t.getColdDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.COLD] = t.getResistPenalty(self, t)}),
			pierce = self:addTemporaryValue("iceblock_pierce", t.getPierce(self, t)),
		}
		local particle
		if core.shader.active(4) then
			ret.particle1 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="coldgeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=22000, noup=2.0, verticalIntensityAdjust=-3.0}))
			ret.particle1.toback = true
			ret.particle2 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=1.1, img="coldgeneric"}, {type="circular_flames", ellipsoidalFactor={1,2}, time_factor=22000, noup=1.0, verticalIntensityAdjust=-3.0}))
		else
			ret.particle1 = self:addParticles(Particles.new("uttercold", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle1 then self:removeParticles(p.particle1) end
		if p.particle2 then self:removeParticles(p.particle2) end
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		self:removeTemporaryValue("iceblock_pierce", p.pierce)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getColdDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		local pierce = t.getPierce(self, t)
		return ([[주변의 온도를 극도로 낮춰, 모든 냉기 속성 피해량을 %d%% 올리고 적들의 냉기 저항력을 %d%% 무시합니다.
		또한 빙결 상태효과에 의해 생긴 얼음을 더 쉽게 뚫을 수 있게 되어, 얼음에 의해 감소되는 피해량을 %d%% 무시합니다.]])
		:format(damageinc, ressistpen, pierce)
	end,
}
