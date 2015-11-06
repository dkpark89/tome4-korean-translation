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

-- Synergizes with melee classes (escort), Weapon of Wrath, healing mod (avoid overheal > healing efficiency), and low spellpower
newTalent{
	name = "Chant of Fortitude",
	kr_name = "인내의 찬가",
	type = {"celestial/chants", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 12,
	sustain_positive = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getResists = function(self, t) return self:combatTalentSpellDamage(t, 5, 70) end,
	getLifePct = function(self, t) return self:combatTalentLimit(t, 1, 0.05, 0.20) end, -- Limit < 100% bonus
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	sustain_slots = 'celestial_chant',
	activate = function(self, t)
		local power = t.getResists(self, t)
		game:playSoundNear(self, "talents/spell_generic2")

		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			phys = self:addTemporaryValue("combat_physresist", power),
			spell = self:addTemporaryValue("combat_spellresist", power),
			life = self:addTemporaryValue("max_life", t.getLifePct(self, t)*self.max_life),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeTemporaryValue("max_life", p.life)
		return true
	end,
	info = function(self, t)
		local saves = t.getResists(self, t)
		local life = t.getLifePct(self, t)
		local damageonmeleehit = t.getDamageOnMeleeHit(self, t)
		return ([[태양의 영광을 노래하여, 물리 내성과 주문 내성을 %d 상승시키고 최대 생명력을 %0.1f%% 증가시킵니다. (현재 상승량 : %d) 
 		그리고 주변을 빛으로 감싸, 근접공격을 받으면 적에게 %0.1f 빛 피해를 되돌려줍니다. 
 		한번에 하나의 찬가만을 유지할 수 있습니다. 
 		내성 상승량과 피해량은 주문력의 영향을 받아 증가하고, 생명력은 기술 레벨의 영향을 받아 증가합니다.]]): 
		format(saves, life*100, life*self.max_life, damDesc(self, DamageType.LIGHT, damageonmeleehit))
	end,
}

-- Mostly the same code as Sanctuary
-- Just like Fortress we limit the interaction with spellpower a bit because this is an escort reward
-- This can be swapped to reactively with a projectile already in the air
newTalent{
	name = "Chant of Fortress",
	kr_name = "보루의 찬가",
	type = {"celestial/chants", 2},
	mode = "sustained",
	require = divi_req2,
	points = 5,
	cooldown = 12,
	sustain_positive = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getDamageChange = function(self, t)
		return -self:combatTalentLimit(t, 50, 14, 30) -- Limit < 50% damage reduction
	end,
	sustain_slots = 'celestial_chant',
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		local range = -t.getDamageChange(self, t)
		local damageonmeleehit = t.getDamageOnMeleeHit(self, t)
		return ([[태양의 영광을 노래하여, 3 칸 이상 떨어진 적에게서 받는 공격의 피해량을 %d%% 만큼 감소시킵니다. 
 		그리고 주변을 빛으로 감싸, 근접공격을 받으면 적에게 %0.1f 빛 피해를 되돌려줍니다. 
 		한번에 하나의 찬가만을 유지할 수 있습니다. 
 		피해 감소량은 기술 레벨의 영향을 받아 증가하고, 피해량은 주문력의 영향을 받아 증가합니다.]]):  
		format(range, damDesc(self, DamageType.LIGHT, damageonmeleehit))
	end,
}

-- Escorts can't give this one so it should have the most significant spellpower scaling
-- Ideally at high spellpower this would almost always be the best chant to use, but we can't guarantee that while still differentiating the chants in interesting ways
-- People that don't want to micromanage/math out when the other chants are better will like this and it should still outperform Fortitude most of the time
newTalent{
	name = "Chant of Resistance",
	kr_name = "저항의 찬가",
	type = {"celestial/chants",3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 12,
	sustain_positive = 20,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	no_energy = true,
	range = 10,
	getResists = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	sustain_slots = 'celestial_chant',
	activate = function(self, t)
		local power = t.getResists(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			res = self:addTemporaryValue("resists", {all = power}),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("resists", p.res)
		return true
	end,
	info = function(self, t)
		local resists = t.getResists(self, t)
		local damage = t.getDamageOnMeleeHit(self, t)
		return ([[태양의 영광을 노래하여, 전체 저항력을 %d%% 상승시킵니다. 
 		그리고 주변을 빛으로 감싸, 근접공격을 받으면 적에게 %0.1f 빛 피해를 되돌려줍니다. 
 		한번에 하나의 찬가만을 유지할 수 있습니다. 
 		저항력과 피해량은 주문력의 영향을 받아 증가합니다.]]): 
		format(resists, damDesc(self, DamageType.LIGHT, damage))
	end,
}

-- Extremely niche in the name of theme
-- A defensive chant is realistically always a better choice than an offensive one but we can mitigate this by giving abnormally high value at low talent investment
newTalent{
	name = "Chant of Light",
	kr_name = "빛의 찬가",
	type = {"celestial/chants", 4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 12,
	sustain_positive = 5,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getLightDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 20, 50) end,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getLite = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	sustain_slots = 'celestial_chant',
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamageOnMeleeHit(self, t)}),
			phys = self:addTemporaryValue("inc_damage", {[DamageType.LIGHT] = t.getLightDamageIncrease(self, t), [DamageType.FIRE] = t.getLightDamageIncrease(self, t)}),
			lite = self:addTemporaryValue("lite", t.getLite(self, t)),
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("inc_damage", p.phys)
		self:removeTemporaryValue("lite", p.lite)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getLightDamageIncrease(self, t)
		local damage = t.getDamageOnMeleeHit(self, t)
		local lite = t.getLite(self, t)
		return ([[태양의 영광을 노래하여, 빛과 화염 속성으로 적을 공격할 때 %d%% 피해를 추가로 줍니다. 
 		그리고 주변을 빛으로 감싸, 근접공격을 받으면 적에게 %0.1f 의 빛 피해를 되돌려 줍니다. 
 		또한, 광원 반경이 %d 칸 증가됩니다. 이 찬가는 다른 찬가들에 비해 적은 원천력으로 유지할 수 있습니다. 
 		한번에 하나의 찬가만을 유지할 수 있습니다.  
 		기술의 효과는 주문력의 영향을 받아 증가합니다.]]):  
		format(damageinc, damDesc(self, DamageType.LIGHT, damage), lite)
	end,
}
