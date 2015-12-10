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

newTalent{
	name = "Arcane Reconstruction", short_name = "HEAL",
	kr_name = "마법적 재구축",
	type = {"spell/aegis", 1},
	require = spells_req1,
	points = 5,
	mana = 25,
	cooldown = 16,
	use_only_arcane = 2,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentSpellDamage(t, 10, 520) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[몸에 마력을 주입하여, 신체를 최상의 몸 상태로 재구축합니다. 재구축을 통해 시전자의 생명력이 %d 회복됩니다.
		생명력 회복량은 주문력의 영향을 받아 증가합니다.]]):
		format(heal)
	end,
}

newTalent{
	name = "Shielding",
	kr_name = "보호막 수련",
	type = {"spell/aegis", 2},
	require = spells_req2,
	points = 5,
	mode = "sustained",
	sustain_mana = 40,
	use_only_arcane = 2,
	cooldown = 14,
	tactical = { BUFF = 2 },
	getDur = function(self, t) return self:getTalentLevel(t) >= 5 and 1 or 0 end,
	getShield = function(self, t) return 20 + self:combatTalentSpellDamage(t, 5, 400) / 10 end,
	activate = function(self, t)
		local dur = t.getDur(self, t)
		local shield = t.getShield(self, t)
		game:playSoundNear(self, "talents/arcane")
		local ret = {
			shield = self:addTemporaryValue("shield_factor", shield),
			dur = self:addTemporaryValue("shield_dur", dur),
		}
		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("shield_factor", p.shield)
		self:removeTemporaryValue("shield_dur", p.dur)
		return true
	end,
	info = function(self, t)
		local shield = t.getShield(self, t)
		local dur = t.getDur(self, t)
		return ([[시전자를 감싸고 있는 보호막에 추가적인 마력을 흘려넣어, 모든 보호막 관련 마법들이 %d%% 강화됩니다.
		(적용되는 보호막 : 피해 보호막, 시간의 보호막, 왜곡의 보호막, 불안정한 보호막)
		피해량을 흡수하는 보호막일 경우에는 최대 흡수량이 증가하며, 불안정한 보호막일 경우 마나 회복량이 줄어드는 효과가 있습니다.
		기술 레벨이 5 이상이면, 모든 보호막의 지속시간이 1 턴 증가합니다.
		강화 효율은 주문력의 영향을 받아 증가합니다.]]):
		format(shield, dur)
	end,
}

newTalent{
	name = "Arcane Shield",
	kr_name = "마력의 보호막",
	type = {"spell/aegis", 3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	use_only_arcane = 2,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getShield = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 5, 500), 100, 20, 0, 55.4, 354) end,	 -- Limit < 100%
	activate = function(self, t)
		local shield = t.getShield(self, t)
		game:playSoundNear(self, "talents/arcane")
		local ret = {
			shield = self:addTemporaryValue("arcane_shield", shield),
		}
		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("arcane_shield", p.shield)
		return true
	end,
	info = function(self, t)
		local shield = t.getShield(self, t)
		return ([[시전자 주변에 보호의 성질을 지닌 마력을 만들어냅니다.
		직접적인 생명력 회복 효과를 받을 때마다 마력이 반응하여, 회복량의 %d%% 에 해당하는 피해를 막아주는 보호막이 3 턴 동안 생성됩니다.
		'직접적인 생명력 회복 효과' 만이 마력을 반응시킬 수 있으며, '생명력 재생을 강화하는 효과' 에는 마력이 반응하지 않습니다. 
		보호막의 성능은 주문력의 영향을 받아 증가합니다.]]):
		format(shield)
	end,
}

newTalent{
	name = "Aegis",
	kr_name = "수호",
	type = {"spell/aegis", 4},
	require = spells_req4,
	points = 5,
	mana = 50,
	cooldown = 25,
	use_only_arcane = 2,
	no_energy = true,
	tactical = { HEAL = 2 },
	getShield = function(self, t) return 40 + self:combatTalentSpellDamage(t, 5, 500) / 10 end,
	getNumEffects = function(self, t) return math.max(1,math.floor(self:combatTalentScale(t, 3, 7, "log"))) end,
	on_pre_use = function(self, t)
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.on_aegis then return true end
		end
		if self:isTalentActive(self.T_DISRUPTION_SHIELD) then return true end
	end,
	action = function(self, t)
		local target = self
		local shield = t.getShield(self, t)
		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.on_aegis then
				effs[#effs+1] = {id=eff_id, e=e, p=p}
			end
		end

		for i = 1, t.getNumEffects(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			eff.e.on_aegis(self, eff.p, shield)
		end

		if self:isTalentActive(self.T_DISRUPTION_SHIELD) then
			self:setEffect(self.EFF_MANA_OVERFLOW, math.ceil(self:combatTalentScale(t, 3, 7)), {power=shield})
		end

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local shield = t.getShield(self, t)
		return ([[현재 시전자를 보호 중인 모든 보호막에 마력을 불어넣어, 보호막을 %d%% 증폭시킵니다.
		피해량을 흡수하는 보호막일 경우에는 최대 흡수량이, 불안정한 보호막일 경우 최대 마나량이 증가합니다.
		이 효과는 최대 %d 개 이하의 보호막에만 적용됩니다.
		적용되는 보호막 : 피해 보호막, 시간의 보호막, 왜곡의 보호막, 불안정한 보호막
		성능 증가율은 주문력의 영향을 받아 증가합니다.]]):
		format(shield, t.getNumEffects(self, t))
	end,
}
