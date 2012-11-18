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
	name = "Circle of Shifting Shadows",
	display_name = "뒤바뀌는 그림자의 권역",
	type = {"celestial/circles", 1},
	require = divi_req_high1,
	points = 5,
	cooldown = 20,
	negative = 20,
	tactical = { DEFEND = 2, ATTACKAREA = {DARKNESS = 1} },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 4, 30) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.SHIFTINGSHADOWS, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=60, color_bg=10, color_bb=60},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[발 아래에 %d 타일 반경의 권역을 생성하여, 회피도를 %d 증가시키고, 권역에 발을 들이는 자들에게 매 턴마다 %0.2f 의 어둠 피해를 줍니다. 권역은 %d 턴 간 유지됩니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(radius, damage, (damDesc (self, DamageType.DARKNESS, damage)), duration)
	end,
}

newTalent{
	name = "Circle of Blazing Light",
	display_name = "타오르는 빛의 권역",
	type = {"celestial/circles", 2},
	require = divi_req_high2,
	points = 5,
	cooldown = 20,
	positive = 20,
	tactical = { DEFEND = 2, ATTACKAREA = {FIRE = 0.5, LIGHT = 0.5} },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 2, 15) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local radius = self:getTalentRadius(t)
		local tg = {type="ball", range=0, selffire=true, radius=radius, talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.BLAZINGLIGHT, t.getDamage(self, t),
			radius,
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=250, color_bg=200, color_bb=10},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[발 아래에 %d 타일 반경의 권역을 생성하여, 빛을 밝히고 매 턴마다 %d 의 양기를 획득하며, 권역에 발을 들이는 자들에게 매 턴마다 %0.2f 의 빛 피해와 %0.2f 의 화염 피해를 줍니다. 권역은 %d 턴 간 유지됩니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(radius, 1 + (damage / 4), (damDesc (self, DamageType.LIGHT, damage)), (damDesc (self, DamageType.FIRE, damage)), duration)
	end,
}

newTalent{
	name = "Circle of Sanctity",
	display_name = "고결함의 권역",
	type = {"celestial/circles", 3},
	require = divi_req_high3,
	points = 5,
	cooldown = 20,
	positive = 20,
	negative = 20,
	tactical = { DEFEND = 2, ATTACKAREA = 1 },
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.SANCTITY, 1,
			self:getTalentRadius(t),
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=150, color_bg=10, color_bb=200},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[발 아래에 %d 타일 반경의 권역을 생성하여, 권역에 발을 들이는 자들을 침묵시키고 자신은 침묵 효과에 걸리지 않게 됩니다. 권역은 %d 턴 간 유지됩니다.]]):
		format(radius, duration)
	end,
}

newTalent{
	name = "Circle of Warding",
	display_name = "배척의 권역",
	type = {"celestial/circles", 4},
	require = divi_req_high4,
	points = 5,
	cooldown = 20,
	positive = 20,
	negative = 20,
	tactical = { DEFEND = 2, ATTACKAREA = {LIGHT = 0.5, DARKNESS = 0.5} },
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 2, 20)  end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.WARDING, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=200, color_bg=200, color_bb=200},
			nil, self:spellFriendlyFire(true)
		)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[발 아래에 %d 타일 반경의 권역을 생성하여, 날아오는 발사체의 속도를 %d%% 감속시키고, 권역에 발을 들이는 자들을 밀어내며 매 턴마다 %0.2f 의 빛 피해와 %0.2f 의 어둠 피해를 줍니다. 권역은 %d 턴 간 유지됩니다.
		감속 효과와 피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(radius, damage, (damDesc (self, DamageType.LIGHT, damage)), (damDesc (self, DamageType.DARKNESS, damage)), duration)
	end,
}

