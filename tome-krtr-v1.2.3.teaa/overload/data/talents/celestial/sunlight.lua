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

newTalent{
	name = "Searing Light",
	kr_name = "타오르는 빛",
	type = {"celestial/sunlight", 1},
	require = divi_req1,
	random_ego = "attack",
	points = 5,
	cooldown = 6,
	positive = -16,
	range = 7,
	tactical = { ATTACK = {LIGHT = 2} },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 6, 160) end,
	getDamageOnSpot = function(self, t) return self:combatTalentSpellDamage(t, 6, 80) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t)), {type="light"})

		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, 4,
			DamageType.LIGHT, t.getDamageOnSpot(self, t),
			0,
			5, nil,
			{type="light_zone"},
			nil, self:spellFriendlyFire()
		)

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damageonspot = t.getDamageOnSpot(self, t)
		return ([[태양의 힘을 타오르는 창의 형태로 구현하여, 대상에게 %0.2f 빛 피해를 줍니다. 던져진 창은 4 턴 동안 지면에 남아, 접근하는 모든 대상에게 %0.2f 빛 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.LIGHT, damage), damageonspot)
	end,
}

newTalent{
	name = "Sun Flare",
	kr_name = "햇빛 섬광",
	type = {"celestial/sunlight", 2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 22,
	positive = -15,
	tactical = { ATTACKAREA = {LIGHT = 1}, DISABLE = 2 },
	direct_hit = true,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 4, 80) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		-- Temporarily turn on "friendlyfire" to lite all tiles
		tg.selffire = true
		tg.radius = tg.radius * 2
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		tg.radius = tg.radius / 2
		tg.selffire = false
		local grids = self:project(tg, self.x, self.y, DamageType.BLIND, t.getDuration(self, t))
		if self:getTalentLevel(t) >= 3 then
			self:project(tg, self.x, self.y, DamageType.LIGHT, t.getDamage(self, t))
		end
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[시전자 주변 %d 칸 반경에 강렬한 햇빛이 내리쬐어, 적들을 %d 턴 동안 실명시킵니다. 또한 주변 %d 칸 반경이 밝아집니다.
		기술 레벨이 3 이상일 경우, 주변 %d 칸 반경에 %0.2f 빛 피해를 가할 수 있게 됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(radius, duration, radius * 2, damDesc(self, DamageType.LIGHT, damage), radius)
   end,
}

newTalent{
	name = "Firebeam",
	kr_name = "태양 화살",
	type = {"celestial/sunlight",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 7,
	positive = -20,
	tactical = { ATTACK = {FIRE = 2}  },
	range = 7,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 200) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "light_beam", {tx=x-self.x, ty=y-self.y})

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[불타는 태양의 힘을 관통하는 화살 형태로 분출해, 적들에게 %0.2f 화염 피해를 가합니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Sunburst",
	kr_name = "햇빛 폭발",
	type = {"celestial/sunlight", 4},
	require = divi_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	positive = -20,
	tactical = { ATTACKAREA = {LIGHT = 2} },
	range = 0,
	radius = 3,
	direct_hit = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 160) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t)))

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[햇빛을 폭발시켜, 시전자 주변 %d 칸 반경의 모든 대상들에게 %0.2f 빛 피해를 가합니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(radius, damDesc(self, DamageType.LIGHT, damage))
	end,
}
