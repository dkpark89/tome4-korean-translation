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

function radianceRadius(self)
	if self:hasEffect(self.EFF_RADIANCE_DIM) then
		return 1
	else
		return self:getTalentRadius(self:getTalentFromId(self.T_RADIANCE))
	end
end

newTalent{
	name = "Radiance",
	kr_name = "광휘",
	type = {"celestial/radiance", 1},
	mode = "passive",
	require = divi_req1,
	points = 5,
	radius = function(self, t) return self:combatTalentScale(t, 3, 7) end,
	getResist = function(self, t) return self:combatTalentLimit(t, 100, 25, 75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "radiance_aura", radianceRadius(self))
		self:talentTemporaryValue(p, "blind_immune", t.getResist(self, t) / 100)
	end,
	info = function(self, t)
		return ([[몸에 주입된 빛의 힘으로 인해서, 어두운 곳에서도 적용되는 영구적인 광원 반경을 %d 칸 얻게 됩니다. 
43 		또한 눈이 빛에 적응하여, 실명 면역력이 %d%% 증가하게 됩니다. 
44 		이 기술을 통해 얻는 광원 반경이 장비의 광원 반경보다 클 경우, 보다 큰 쪽을 따릅니다. (즉, 서로 더해지지 않습니다) 
45 		]]): 
		format(radianceRadius(self), t.getResist(self, t))
	end,
}

newTalent{
	name = "Illumination",
	kr_name = "조명",
	type = {"celestial/radiance", 2},
	require = divi_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 15 + self:combatTalentSpellDamage(t, 1, 100) end,
	getDef = function(self, t) return 5 + self:combatTalentSpellDamage(t, 1, 35) end,
	callbackOnActBase = function(self, t)
		local radius = radianceRadius(self)
		local grids = core.fov.circle_grids(self.x, self.y, radius, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do local target = game.level.map(x, y, Map.ACTOR) if target and self ~= target then
			if (self:reactionToward(target) < 0) then
				target:setEffect(target.EFF_ILLUMINATION, 1, {power=t.getPower(self, t), def=t.getDef(self, t)})
				local ss = self:isTalentActive(self.T_SEARING_SIGHT)
				if ss then
					local dist = core.fov.distance(self.x, self.y, target.x, target.y) - 1
					local coeff = math.max(0.1, 1 - (0.1*dist)) -- 10% less damage per distance
					DamageType:get(DamageType.LIGHT).projector(self, target.x, target.y, DamageType.LIGHT, ss.dam * coeff)
					if ss.daze and rng.percent(ss.daze) and target:canBe("stun") then
						target:setEffect(target.EFF_DAZED, 3, {apply_power=self:combatSpellpower()})
					end
				end
		end
		end end end		
	end,
	info = function(self, t)
		return ([[몸에서 나오는 광휘를 통해, 보통은 볼 수 없는 것들까지 볼 수 있게 됩니다. 
79 		광휘의 광원 반경 내에 있는 적들은 은신 능력과 투명화 능력이 %d 감소하게 됩니다. 
80 		그리고 조명의 영향을 받은 모든 대상들은 더 공격하기 쉬워지게 되어, 회피도가 %d 감소하고 보이지 않는 것으로부터 얻는 회피 상승 효과가 무효화됩니다. 
81 		기술의 효과는 주문력의 영향을 받아 증가합니다.]]): 
		format(t.getPower(self, t), t.getDef(self, t))
	end,
}

-- This doesn't work well in practice.. Its powerful but it leads to cheesy gameplay, spams combat logs, maybe even lags
-- It can stay like this for now but may be worth making better
newTalent{
	name = "Searing Sight",
	kr_name = "타오르는 시선",
	type = {"celestial/radiance",3},
	require = divi_req3,
	mode = "sustained",
	points = 5,
	cooldown = 15,
	range = function(self) return radianceRadius(self) end,
	tactical = { ATTACKAREA = {LIGHT=1} },
	sustain_positive = 10,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 35) end,
	getDaze = function(self, t) return self:combatTalentLimit(t, 35, 5, 20) end,
	updateParticle = function(self, t)
		local p = self:isTalentActive(self.T_SEARING_SIGHT)
		if not p then return end
		self:removeParticles(p.particle)
		p.particle = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1, a=20, appear=4, speed=-0.2, img="radiance_circle", radius=self:getTalentRange(t)}))
	end,
	activate = function(self, t)
		local daze = nil
		if self:getTalentLevel(t) >= 4 then daze = t.getDaze(self, t) end
		return {
			particle = self:addParticles(Particles.new("circle", 1, {toback=true, oversize=1, a=20, appear=4, speed=-0.2, img="radiance_circle", radius=self:getTalentRange(t)})),
			dam=t.getDamage(self, t),
			daze=daze,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[몸에서 나오는 광휘가 너무나 강렬하여, 광휘의 영향범위에 있는 모든 적들에게 최대 %0.1f 의 빛 피해를 입힙니다. (거리에 따라 피해량 감소) 
122 		기술 레벨이 4 이상일 경우, 적들은 너무나 밝은 빛에 의해 %d%% 확률로 3 턴 동안 혼절 상태에 빠지게 됩니다. 
123 		피해량은 주문력의 영향을 받아 증가합니다.]]): 
		format(damDesc(self, DamageType.LIGHT, t.getDamage(self, t)), t.getDaze(self, t))
	end,
}

newTalent{
	name = "Judgement",
	kr_name = "심판",
	type = {"celestial/radiance", 4},
	require = divi_req4,
	points = 5,
	cooldown = 25,
	positive = 20,
	tactical = { ATTACKAREA = {LIGHT = 2} },
	radius = function(self) return radianceRadius(self) end,
	range = function(self) return radianceRadius(self) end,
	getMoveDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 40) end,
	getExplosionDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 150) end,
	action = function(self, t)

		local tg = {type="ball", range=self:getTalentRange(t), radius = self:getTalentRadius(t), selffire = false, friendlyfire = false, talent=t}

		local movedam = self:spellCrit(t.getMoveDamage(self, t))
		local dam = self:spellCrit(t.getExplosionDamage(self, t))

		self:project(tg, self.x, self.y, function(tx, ty)
			local target = game.level.map(tx, ty, engine.Map.ACTOR)
			if not target then return end

			local proj = require("mod.class.Projectile"):makeHoming(
				self,
				{particle="bolt_light", trail="lighttrail"},
				{speed=1, name="Judgement", dam=dam, movedam=movedam},
				target,
				self:getTalentRange(t),
				function(self, src)
					local DT = require("engine.DamageType")
					DT:get(DT.JUDGEMENT).projector(src, self.x, self.y, DT.JUDGEMENT, self.def.movedam)
				end,
				function(self, src, target)
					local DT = require("engine.DamageType")
					local grids = src:project({type="ball", radius=1, x=self.x, y=self.y}, self.x, self.y, DT.JUDGEMENT, self.def.dam)
					game.level.map:particleEmitter(self.x, self.y, 1, "sunburst", {radius=1, grids=grids, tx=self.x, ty=self.y})
					game:playSoundNear(self, "talents/lightning")
				end
			)
			game.zone:addEntity(game.level, proj, "projectile", self.x, self.y)
		end)
		
		-- EFF_RADIANCE_DIM does nothing by itself its just used by radianceRadius
		self:setEffect(self.EFF_RADIANCE_DIM, 5, {})

		return true
	end,
	info = function(self, t)
		return ([[광휘 안에 있는 모든 적들에게 빛나는 오브를 발사합니다. 각각의 오브는 대상을 천천히 추적하며, 추적 중에 부딪히는 모든 대상에게 %d 빛 피해를 줍니다. 추적 대상에 도달할 경우 오브는 폭발하여 %d 빛 피해를 주고, 피해량의 50%% 만큼 시전자의 생명력을 회복시킵니다. 
179 		이 강력한 능력은 광휘를 일시적으로 흐리게 만들어, 5 턴 동안 광휘의 반경이 1 로 줄어들게 됩니다.]]): 
		format(t.getMoveDamage(self, t), t.getExplosionDamage(self, t))
	end,
}

