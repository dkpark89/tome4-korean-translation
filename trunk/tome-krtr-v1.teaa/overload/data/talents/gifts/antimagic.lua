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

require "engine.krtrUtils"

newTalent{
	name = "Resolve",
	kr_display_name = "결의",
	type = {"wild-gift/antimagic", 1},
	require = gifts_req1,
	mode = "passive",
	points = 5,
	getRegen = function(self, t) return 1 + (self:combatTalentMindDamage(t, 1, 10) /10) end,
	getResist = function(self, t) return self:combatTalentMindDamage(t, 10, 40) end,
	on_absorb = function(self, t, damtype)
		if not DamageType:get(damtype).antimagic_resolve then return end

		if not self:isTalentActive(self.T_ANTIMAGIC_SHIELD) then
			self:incEquilibrium(-t.getRegen(self, t))
			self:incStamina(t.getRegen(self, t))
		end
		self:setEffect(self.EFF_RESOLVE, 7, {damtype=damtype, res=self:mindCrit(t.getResist(self, t))})
		game.logSeen(self, "%s 마법 공격을 받고 고무됩니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"))
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		local regen = t.getRegen(self, t)
		return ([[마법 피해를 버텨내고, 자신을 더 강하게 만듭니다.
		마법 피해를 받을 때마다, 해당 속성에 대한 저항력이 7 턴 동안 %d%% 증가하게 됩니다.
		반마법 보호막이 비활성화 상태라면, 충격의 일부를 흡수하여 %0.2f 만큼 체력을 회복하고 평정을 되찾게 됩니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(	resist, regen )
	end,
}

newTalent{
	name = "Aura of Silence",
	kr_display_name = "침묵의 기운",
	type = {"wild-gift/antimagic", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 20,
	cooldown = 10,
	tactical = { DISABLE = { silence = 4 } },
	radius = function(self, t) return 4 + self:getTalentLevel(t) * 1.5 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.SILENCE, {dur=3 + math.floor(self:getTalentLevel(t) / 2), power_check=self:combatMindpower()})
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[주변의 소리를 없애, %d 턴 동안 주변 %d 칸 반경의 적들을 침묵시킵니다. (시전자 포함)
		침묵 확률은 정신력의 영향을 받아 증가합니다.]]):
		format(3 + math.floor(self:getTalentLevel(t) / 2), rad)
	end,
}

newTalent{
	name = "Antimagic Shield",
	kr_display_name = "반마법 보호막",
	type = {"wild-gift/antimagic", 3},
	require = gifts_req3,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 30,
	cooldown = 20,
	range = 10,
	tactical = { DEFEND = 2 },
	getMax = function(self, t)
		local v = self:combatTalentMindDamage(t, 20, 80)
		if self:knowTalent(self.T_TRICKY_DEFENSES) then
			v = v * (100 + self:getCun() / 2) / 100
		end
		return v
	end,
	on_damage = function(self, t, damtype, dam)
		if not DamageType:get(damtype).antimagic_resolve then return dam end

		if dam <= self.antimagic_shield then
			self:incEquilibrium(dam / 30)
			dam = 0
		else
			self:incEquilibrium(self.antimagic_shield / 30)
			dam = dam - self.antimagic_shield
		end

		if not self:equilibriumChance() then
			self:forceUseTalent(self.T_ANTIMAGIC_SHIELD, {ignore_energy=true})
			game.logSeen(self, "#GREEN#%s의 반마법 보호막이 부서집니다.", (self.kr_display_name or self.name))
		end
		return dam
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			am = self:addTemporaryValue("antimagic_shield", t.getMax(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("antimagic_shield", p.am)
		return true
	end,
	info = function(self, t)
		return ([[마법 공격을 맞을 때마다 %d 만큼 피해량을 경감시켜주는 반마법 보호막을 만들어냅니다.
		피해량을 30 흡수할 때마다 평정 수치가 1 올라가며, 평정에 따른 실패율을 계산합니다. 계산 결과 평정이 깨지면, 반마법 보호막도 깨지고 재사용 대기시간이 활성화됩니다.
		피해 흡수량은 정신력의 영향을 받아 증가합니다.]]):
		format(t.getMax(self, t))
	end,
}

newTalent{
	name = "Mana Clash",
	kr_display_name = "마나 충돌",
	type = {"wild-gift/antimagic", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	range = 10,
	tactical = { ATTACK = { ARCANE = 3 } },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local base = self:mindCrit(self:combatTalentMindDamage(t, 20, 460))
			DamageType:get(DamageType.MANABURN).projector(self, px, py, DamageType.MANABURN, base)
		end, nil, {type="slime"})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local base = self:combatTalentMindDamage(t, 20, 460)
		local mana = base
		local vim = base / 2
		local positive = base / 4
		local negative = base / 4

		return ([[대상의 마나를 %d / 원기를 %d / 양기와 음기를 %d 만큼 빼앗아 폭발시킵니다.
		폭발의 피해는 흡수된 마나 수치의 100%% / 흡수된 원기 수치의 200%% / 흡수된 양기나 음기 수치의 400%% 와 같습니다. (세 수치 중 높은 쪽을 따릅니다)
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(mana, vim, positive, negative)
	end,
}
