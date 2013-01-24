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

--Mindlash: ranged physical rad-0 ball
--Pyrokinesis: LOS burn attack
--Reach: gem-based range improvements
--Channeling: gem-based shield and improvement

newTalent{
	name = "Mindlash",
	kr_display_name = "염력 채찍",
	type = {"psionic/focus", 1},
	require = psi_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		local c = 5
		local gem_level = getGemLevel(self)
		return math.max(c - gem_level, 0)
	end,
	psi = 10,
	tactical = { ATTACK = function(self, t, target)
		local val = { PHYSICAL = 2}
		local gem_level = getGemLevel(self)
		if gem_level > 0 and not target.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) then
			local c =  self:getTalentFromId(self.T_CONDUIT)
			local auras = self:isTalentActive(c.id)
			if auras.k_aura_on then
				val.PHYSICAL = val.PHYSICAL + 1
			end
			if auras.t_aura_on then
				val.FIRE = 1
			end
			if auras.c_aura_on then
				val.LIGHTNING = 1
			end
			return val
		end
		return 0
	end },
	range = function(self, t)
		local r = 5
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	getDamage = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 6, 170)*(1 + 0.3*gem_level)
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local gem_level = getGemLevel(self)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, self:mindCrit(rng.avg(0.8*dam, dam)), {type="flame"})
		if gem_level > 0 and not tg.dead and self:knowTalent(self.T_CONDUIT) and self:isTalentActive(self.T_CONDUIT) then
			local c =  self:getTalentFromId(self.T_CONDUIT)
			--c.do_combat(self, c, tg)
			local mult = 1 + 0.2*(self:getTalentLevel(c))
			local auras = self:isTalentActive(c.id)
			if auras.k_aura_on then
				local k_aura = self:getTalentFromId(self.T_KINETIC_AURA)
				local k_dam = mult * k_aura.getAuraStrength(self, k_aura)
				DamageType:get(DamageType.PHYSICAL).projector(self, x, y, DamageType.PHYSICAL, k_dam)
			end
			if auras.t_aura_on then
				local t_aura = self:getTalentFromId(self.T_THERMAL_AURA)
				local t_dam = mult * t_aura.getAuraStrength(self, t_aura)
				DamageType:get(DamageType.FIRE).projector(self, x, y, DamageType.FIRE, t_dam)
			end
			if auras.c_aura_on then
				local c_aura = self:getTalentFromId(self.T_CHARGED_AURA)
				local c_dam = mult * c_aura.getAuraStrength(self, c_aura)
				DamageType:get(DamageType.LIGHTNING).projector(self, x, y, DamageType.LIGHTNING, c_dam)
			end

		end
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[근처의 대상에게 염력 채찍을 휘둘러, %d 피해를 줍니다. 염력의 통로가 활성화 되었을 경우 채찍에 오러를 실어 추가 피해를 줍니다.
		정신 파괴자가 이 기술을 쓰기 위해서는 집중이 필요하며, 염동력으로 보석이나 마석을 들고 있을 경우 특수한 효과들이 추가됩니다.]]):
		format(dam)
	end,
}

newTalent{
	name = "Pyrokinesis",
	kr_display_name = "염화",
	type = {"psionic/focus", 2},
	require = psi_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		local c = 20
		local gem_level = getGemLevel(self)
		return c - gem_level
	end,
	psi = 20,
	tactical = { ATTACK = { FIRE = 2 } },
	range = 0,
	radius = function(self, t)
		local r = 5
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	getDamage = function (self, t)
		local gem_level = getGemLevel(self)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 21, 200)*(1 + 0.3*gem_level)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
	end,
	action = function(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.FIREBURN, {dur=10, initial=0, dam=dam}, {type="ball_fire", args={radius=1}})
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[염력으로 불을 붙여, 주변 %d 칸 반경의 적들에게 10 턴에 걸쳐 총 %d 화염 피해를 줍니다.
		정신 파괴자가 이 기술을 쓰기 위해서는 집중이 필요하며, 염동력으로 보석이나 마석을 들고 있을 경우 특수한 효과들이 추가됩니다.]]):
		format(radius, dam)
	end,
}

newTalent{
	name = "Reach",
	kr_display_name = "도달",
	type = {"psionic/focus", 3},
	require = psi_wil_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		local inc = 2*self:getTalentLevel(t)
		return ([[보석이나 마석을 통해, 정신력이 미치는 범위를 넓힙니다. 정신력을 사용하는 기술들의 사정거리가 %d%% - %d%% 증가합니다. 
		염동력으로 들고 있는 보석이나 마석의 수준에 따라 기술의 효과가 달라집니다.]]):
		format(inc, 5*inc)
	end,
}

newTalent{
	name = "Focused Channeling",
	kr_display_name = "염력 집중",
	type = {"psionic/focus", 4},
	require = psi_wil_req4,
	mode = "passive",
	points = 5,
	info = function(self, t)
		local inc = 1 + 0.15*self:getTalentLevel(t)
		return ([[염력으로 들고 있는 보석이나 마석을 통해, 오러나 보호막의 피해량을 %0.2f - %0.2f 만큼 증가시킵니다.
		염동력으로 들고 있는 보석이나 마석의 수준에 따라 기술의 효과가 달라집니다.]]):
		format(inc, 5*inc)
	end,
}
