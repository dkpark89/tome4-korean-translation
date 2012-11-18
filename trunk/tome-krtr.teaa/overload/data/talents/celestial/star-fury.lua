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
	name = "Moonlight Ray",
	display_name = "한 줄기 달빛",
	type = {"celestial/star-fury", 1},
	require = divi_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	negative = 10,
	tactical = { ATTACK = {DARKNESS = 2} },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 14, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "shadow_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[달의 힘을 끌어내어 적에게 날려서 %0.2f 의 피해를 줍니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Shadow Blast",
	display_name = "그림자 확산",
	type = {"celestial/star-fury", 2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	negative = 15,
	tactical = { ATTACKAREA = {DARKNESS = 2} },
	range = 5,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire()}
	end,
	getDamageOnSpot = function(self, t) return self:combatTalentSpellDamage(t, 4, 40) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 110) end,
	getDuration = function(self, t) return math.floor(self:getTalentLevel(t) * 0.8) + 2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		local grids = self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)), {type="shadow"})
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.DARKNESS, t.getDamageOnSpot(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="shadow_zone"},
			nil, self:spellFriendlyFire()
		)

		game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damageonspot = t.getDamageOnSpot(self, t)
		local duration = t.getDuration(self, t)
		return ([[그림자를 퍼뜨려서 %0.2f 의 어둠 피해를 주고, 3 타일 반경의 지역에 매 턴마다 %0.2f 의 어둠 피해를 %d 턴 동안 줍니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(damDesc(self, DamageType.DARKNESS, damage),damDesc(self, DamageType.DARKNESS, damageonspot),duration)
	end,
}

newTalent{
	name = "Twilight Surge",
	display_name = "밀려드는 황혼",
	type = {"celestial/star-fury",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 7,
	negative = -20,
	positive = -10,
	tactical = { ATTACKAREA = {LIGHT = 1, DARKNESS = 1} },
	range = 0,
	radius = 2,
	direct_hit = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, selffire=false}
	end,
	getLightDamage = function(self, t) return 10 + self:combatSpellpower(0.2) * self:getTalentLevel(t) end,
	getDarknessDamage = function(self, t) return 10 + self:combatSpellpower(0.2) * self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(t.getLightDamage(self, t)))
		self:project(tg, self.x, self.y, DamageType.DARKNESS, self:spellCrit(t.getDarknessDamage(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local lightdam = t.getLightDamage(self, t)
		local darknessdam = t.getDarknessDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[당신에게서 황혼의 물결이 퍼져나가, %0.2f 의 빛 피해와 %0.2f 의 어둠 피해를 %d 반경 내의 대상에게 줍니다.
		또한 음기와 양기를 동시에 얻습니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(damDesc(self, DamageType.LIGHT, lightdam),damDesc(self, DamageType.DARKNESS, darknessdam), radius)
	end,
}

newTalent{
	name = "Starfall",
	display_name = "별똥별",
	type = {"celestial/star-fury", 4},
	require = divi_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	negative = 20,
	tactical = { ATTACKAREA = {DARKNESS = 2}, DISABLE = 2 },
	range = 6,
	radius = function(self, t)
		return 1 + math.floor(self:getTalentLevelRaw(t) / 3)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 170) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = self:project(tg, x, y, DamageType.DARKSTUN, self:spellCrit(t.getDamage(self, t)))

		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "shadow_flash", {radius=tg.radius, grids=grids, tx=x, ty=y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[%d 반경의 지역에 별을 떨어뜨려, 4 턴 동안 기절시키고 %0.2f 의 어둠 피해를 줍니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(radius, damDesc(self, DamageType.DARKNESS, damage))
	end,
}
