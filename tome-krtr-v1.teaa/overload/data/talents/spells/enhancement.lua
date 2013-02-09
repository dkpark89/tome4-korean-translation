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
	name = "Fiery Hands",
	kr_display_name = "타오르는 손",
	type = {"spell/enhancement",1},
	require = spells_req1,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 40,
	tactical = { BUFF = 2 },
	getFireDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 40) end,
	getFireDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 5, 14) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		return {
			dam = self:addTemporaryValue("melee_project", {[DamageType.FIRE] = t.getFireDamage(self, t)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = t.getFireDamageIncrease(self, t)}),
			sta = self:addTemporaryValue("stamina_regen_on_hit", self:getTalentLevel(t) / 3),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		self:removeTemporaryValue("stamina_regen_on_hit", p.sta)
		return true
	end,
	info = function(self, t)
		local firedamage = t.getFireDamage(self, t)
		local firedamageinc = t.getFireDamageIncrease(self, t)
		return ([[손과 무기가 마법의 불꽃으로 불타올라, 근접 공격에 %0.2f 화염 피해가 추가되고 모든 화염 피해가 %d%% 증가합니다.
		매 타격마다 %0.2f 만큼 체력이 회복되는 효과도 있습니다.
		마법의 효과는 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.FIRE, firedamage), firedamageinc, self:getTalentLevel(t) / 3)
	end,
}

newTalent{
	name = "Earthen Barrier",
	kr_display_name = "대지의 보호",
	type = {"spell/enhancement", 2},
	points = 5,
	random_ego = "utility",
	cooldown = 25,
	mana = 45,
	require = spells_req2,
	range = 10,
	tactical = { DEFEND = 2 },
	getPhysicalReduction = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	action = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_EARTHEN_BARRIER, 10, {power=t.getPhysicalReduction(self, t)})
		return true
	end,
	info = function(self, t)
		local reduction = t.getPhysicalReduction(self, t)
		return ([[대지의 힘으로 피부를 단단하게 만들어, 10 턴 동안 받는 물리 피해를 %d%% 감소시킵니다.
		피해 감소량은 주문력의 영향을 받아 상승합니다.]]):
		format(reduction)
	end,
}

newTalent{
	name = "Shock Hands",
	kr_display_name = "전격의 손",
	type = {"spell/enhancement", 3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 40,
	tactical = { BUFF = 2 },
	getIceDamage = function(self, t) return self:combatTalentSpellDamage(t, 3, 20) end,
	getIceDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 5, 14) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/lightning")
		return {
			dam = self:addTemporaryValue("melee_project", {[DamageType.LIGHTNING_DAZE] = t.getIceDamage(self, t)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.LIGHTNING] = t.getIceDamageIncrease(self, t)}),
			man = self:addTemporaryValue("mana_regen_on_hit", self:getTalentLevel(t) / 3),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		self:removeTemporaryValue("mana_regen_on_hit", p.man)
		return true
	end,
	info = function(self, t)
		local icedamage = t.getIceDamage(self, t)
		local icedamageinc = t.getIceDamageIncrease(self, t)
		return ([[손과 무기가 마법의 전류가 흘러, 근접 공격에 %0.2f 전기 피해가 추가되고 모든 전기 피해가 %d%% 증가합니다.
		매 타격마다 %0.2f 만큼 마나가 회복되며, 25%% 확률로 적이 혼절 상태효과에 걸리는 효과도 있습니다.
		마법의 효과는 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.LIGHTNING, icedamage), icedamageinc, self:getTalentLevel(t) / 3)
	end,
}

newTalent{
	name = "Inner Power",
	kr_display_name = "내재된 힘",
	type = {"spell/enhancement", 4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 75,
	tactical = { BUFF = 2 },
	getStatIncrease = function(self, t) return math.min(math.floor(self:combatTalentSpellDamage(t, 2, 10)), 11) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = t.getStatIncrease(self, t)
		return {
			stats = self:addTemporaryValue("inc_stats", {
				[self.STAT_STR] = power,
				[self.STAT_DEX] = power,
				[self.STAT_MAG] = power,
				[self.STAT_WIL] = power,
				[self.STAT_CUN] = power,
				[self.STAT_CON] = power,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		local statinc = t.getStatIncrease(self, t)
		return ([[잠재된 힘에 집중하여, 모든 능력치를 %d 만큼 추가로 끌어올립니다. (최대 11 까지 가능)
		능력치 상승량은 주문력의 영향을 받아 상승합니다.]]):
		format(statinc)
	end,
}
