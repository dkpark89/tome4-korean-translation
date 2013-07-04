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
	name = "Strength of Purpose",
	kr_name = "목표의 힘",
	type = {"chronomancy/temporal-combat", 1},
	require = temporal_req1,
	mode = "sustained",
	points = 5,
	sustain_stamina = 50,
	sustain_paradox = 100,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return math.ceil((self:getTalentLevel(t) * 1.5) + self:combatTalentStatDamage(t, "wil", 5, 20)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_STR] = t.getPower(self, t)}),
			phys = self:addTemporaryValue("combat_physresist", t.getPower(self, t)),
			particle = self:addParticles(Particles.new("temporal_focus", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_stats", p.stats)
		self:removeTemporaryValue("combat_physresist", p.phys)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[시공간 연속체를 다루면서, 힘을 증가시키는 법을 알게 되었습니다. 힘 능력치와 물리 내성이 %d 상승합니다.
		이 효과는 의지 능력치의 영향을 받아 증가합니다.]]):format(power)
	end
}

newTalent{
	name = "Invigorate",
	kr_name = "활성화",
	type = {"chronomancy/temporal-combat", 2},
	require = temporal_req2,
	points = 5,
	paradox = 10,
	cooldown = 24,
	tactical = { STAMINA = 2 },
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	getPower = function(self, t) return self:getTalentLevel(t) end,
	action = function(self, t)
		self:setEffect(self.EFF_INVIGORATE, t.getDuration(self,t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[%d 턴 동안 매 턴마다 %d 체력을 회복하고, 모든 기술의 재사용 대기시간이 2 배 빨리 감소됩니다.
		지속시간은 괴리 수치의 영향을 받아 증가합니다.]]):format(duration, power)
	end,
}

newTalent{
	name = "Quantum Feed",
	kr_name = "양자 공급",
	type = {"chronomancy/temporal-combat", 3},
	require = temporal_req3,
	mode = "sustained",
	points = 5,
	sustain_stamina = 50,
	sustain_paradox = 100,
	cooldown = 18,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return math.ceil((self:getTalentLevel(t) * 1.5) + self:combatTalentStatDamage(t, "wil", 5, 20)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			stats = self:addTemporaryValue("inc_stats", {[self.STAT_MAG] = t.getPower(self, t)}),
			spell = self:addTemporaryValue("combat_spellresist", t.getPower(self, t)),
			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[시공간 연속체를 다루면서, 마법을 다루는 법을 알게 되었습니다. 마법 능력치와 주문 내성이 %d 상승합니다.
		이 효과는 의지 능력치의 영향을 받아 증가합니다.]]):format(power)
	end
}

newTalent{
	name = "Damage Smearing",
	kr_name = "피해 분산",
	type = {"chronomancy/temporal-combat",4},
	require = temporal_req4,
	points = 5,
	paradox = 25,
	cooldown = 25,
	tactical = { DEFEND = 2 },
	no_energy = true,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SMEARING, t.getDuration(self,t), {})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[%d 턴 동안 자신이 받는 모든 공격의 속성을 시간 속성으로 바꾸고, 6 턴에 걸쳐 피해를 나눠입게 됩니다.
		지속시간은 괴리 수치의 영향을 받아 증가합니다.]]):format (duration)
	end,
}
