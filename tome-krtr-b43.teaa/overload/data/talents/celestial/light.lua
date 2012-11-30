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
	name = "Healing Light",
	display_name = "치유의 빛",
	type = {"celestial/light", 1},
	require = spells_req1,
	points = 5,
	random_ego = "defensive",
	cooldown = 10,
	positive = -10,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 20, 440) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[당신에게 내리비치는 태양의 독려를 받아, %d의 생명력을 회복합니다.
		회복량은 마법 능력치의 영향을 받아 증가됩니다.]]):
		format(heal)
	end,
}

newTalent{
	name = "Bathe in Light",
	display_name = "빛의 세례",
	type = {"celestial/light", 2},
	require = spells_req2,
	random_ego = "defensive",
	points = 5,
	cooldown = 10,
	positive = -20,
	tactical = { HEAL = 3 },
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 4, 40) end,
	getDuration = function(self, t) return self:getTalentLevel(t) + 2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.HEALING_POWER, t.getHeal(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="healing_vapour"},
			nil, true
		)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local heal = t.getHeal(self, t)
		local duration = t.getDuration(self, t)
		return ([[햇빛이 내리비치는 마력 지대를 만들어서, %d칸 반경 내의 모든 대상을 매 턴마다 %0.2f 만큼 치유하고, 치유 효과를 %d%% 증가시킵니다. 효과는 %d턴 동안 지속됩니다.
		또한 해당 지역에 빛이 밝혀집니다.
		치유량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(radius, heal, heal, duration)
	end,
}

newTalent{
	name = "Barrier",
	display_name = "방벽",
	type = {"celestial/light", 3},
	require = spells_req3,
	points = 5,
	random_ego = "defensive",
	positive = -20,
	cooldown = 15,
	tactical = { DEFEND = 2 },
	getAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 30, 470) end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {power=t.getAbsorb(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local absorb = t.getAbsorb(self, t)
		return ([[10턴 동안 당신을 보호하는 방벽을 생성하여 %d의 피해를 흡수합니다.
		방벽의 흡수량은 마법 능력치의 영향을 받아 증가됩니다.]]):
		format(absorb)
	end,
}

newTalent{
	name = "Providence",
	display_name = "빛의 뜻",
	type = {"celestial/light", 4},
	require = spells_req4,
	points = 5,
	random_ego = "defensive",
	positive = -20,
	cooldown = 30,
	tactical = { HEAL = 1, CURE = 2 },
	getRegeneration = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:setEffect(self.EFF_PROVIDENCE, t.getDuration(self, t), {power=t.getRegeneration(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local regen = t.getRegeneration(self, t)
		local duration = t.getDuration(self, t)
		return ([[빛의 보호를 받아, 매 턴마다 %d의 생명력을 회복하고 한 개의 상태이상 효과를 해제합니다. 빛의 보호는 %d턴 동안 유지됩니다.
		치유량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(regen, duration)
	end,
}

