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

local function getShieldStrength(self, t)
	local add = 0
	if self:knowTalent(self.T_FOCUSED_CHANNELING) then
		add = getGemLevel(self)*(1 + 0.1*(self:getTalentLevel(self.T_FOCUSED_CHANNELING) or 0))
	end
	--return 2 + (1+ self:getWil(8))*self:getTalentLevel(t) + add
	return self:combatStatTalentIntervalDamage(t, "combatMindpower", 3, 40) + add
end

local function getSpikeStrength(self, t)
	local ss = getShieldStrength(self, t)
	return  75*self:getTalentLevel(t) + ss*math.sqrt(ss)
end

local function getEfficiency(self, t)
	return 0.01*(50 + math.min(self:getCun(30, true), 50))
end

local function kineticElement(self, t, damtype)
	if damtype == DamageType.PHYSICAL or damtype == DamageType.ACID then return true end
	if damtype == DamageType.NATURE and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 3 then return true end
	if damtype == DamageType.TEMPORAL and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 6 then return true end
	return false
end

local function thermalElement(self, t, damtype)
	if damtype == DamageType.FIRE or damtype == DamageType.COLD then return true end
	if damtype == DamageType.LIGHT and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 3 then return true end
	if damtype == DamageType.ARCANE and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 6 then return true end
	return false
end

local function chargedElement(self, t, damtype)
	if damtype == DamageType.LIGHTNING or damtype == DamageType.BLIGHT then return true end
	if damtype == DamageType.DARKNESS and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 3 then return true end
	if damtype == DamageType.MIND and self:getTalentLevel(self.T_ABSORPTION_MASTERY) >= 6 then return true end
	return false
end

newTalent{
	name = "Kinetic Shield",
	kr_display_name = "동역학적 보호막",
	type = {"psionic/absorption", 1},
	require = psi_wil_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 30,
	cooldown = function(self, t)
		return 20 - 2*(self:getTalentLevelRaw(self.T_SHIELD_DISCIPLINE) or 0)
	end,
	range = 10,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_THERMAL_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
			if not silent then game.logSeen(self, "보호막은 한번에 2 개 까지만 유지할 수 있습니다. 보호막 생성이 취소됩니다.") end
			return false
		end
		return true
	end,
	--called when damage gets absorbed by kinetic shield
	ks_on_damage = function(self, t, damtype, dam)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not kineticElement(self, t, damtype) then return total_dam end

		if dam <= self.kinetic_shield then
			self:incPsi(2 + dam/mast)
			dam = 0
		else
			self:incPsi(2 + self.kinetic_shield/mast)
			dam = dam - self.kinetic_shield
		end

		return dam + guaranteed_dam
	end,


	activate = function(self, t)
		--if self:isTalentActive(self.T_THERMAL_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
		--	game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.")
		--	return false
		--end
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-10000, llpow=1, aadjust=3, color={1, 0, 0.3}}))
		else
			particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=0.5}))
		end

		return {
			am = self:addTemporaryValue("kinetic_shield", s_str),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("kinetic_shield", p.am)
		if self:attr("save_cleanup") then return true end
		self:setEffect(self.EFF_KINSPIKE_SHIELD, 5, {power=spike_str})
		return true
	end,

	--called when damage gets absorbed by kinetic shield spike
	kss_on_damage = function(self, t, damtype, dam)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 1*total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

		if kineticElement(self, t, damtype) then
			-- Absorb damage into the shield
			if dam <= self.kinspike_shield_absorb then
				self.kinspike_shield_absorb = self.kinspike_shield_absorb - dam
				self:incPsi(2 + 2*dam/mast)
				dam = 0
			else
				self:incPsi(2 + 2*self.kinspike_shield_absorb/mast)
				dam = dam - self.kinspike_shield_absorb
				self.kinspike_shield_absorb = 0
			end

			if self.kinspike_shield_absorb <= 0 then
				game.logPlayer(self, "동역학적 보호막의 파편들이 깨져 사라졌습니다!")
				self:removeEffect(self.EFF_KINSPIKE_SHIELD)
			end
			return dam + guaranteed_dam
		else
			return total_dam
		end
	end,

	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local spike_str = getSpikeStrength(self, t)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 물리 공격이나 산성 공격의 %d%% 를 막아냅니다. (한번에 %d 피해까지 막아낼 수 있습니다)
		보호막을 해제하면 동역학적 보호막의 파편들이 생겨나, 5 턴 동안 물리 공격이나 산성 공격을 %d 만큼 완전히 막아냅니다.
		보호막이 피해를 흡수할 때마다 염력을 2 회복하며, %d 피해를 흡수했을 때마다 추가로 염력을 1 회복합니다. 보호막의 파편들은 피해 흡수에 따른 염력 회복을 더 효율적으로 합니다.
		피해 흡수량 등은 정신력의 영향을 받아 증가합니다.]]):
		format(absorb, s_str, spike_str, mast)
	end,
}



newTalent{
	name = "Thermal Shield",
	kr_display_name = "열역학적 보호막",
	type = {"psionic/absorption", 2},
	require = psi_wil_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 30,
	cooldown = function(self, t)
		return 20 - 2*(self:getTalentLevelRaw(self.T_SHIELD_DISCIPLINE) or 0)
	end,
	range = 10,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
			if not silent then game.logSeen(self, "보호막은 한번에 2 개 까지만 유지할 수 있습니다. 보호막 생성이 취소됩니다.") end
			return false
		end
		return true
	end,

	--called when damage gets absorbed by thermal shield
	ts_on_damage = function(self, t, damtype, dam)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not thermalElement(self, t, damtype) then return total_dam end

		if dam <= self.thermal_shield then
			self:incPsi(2 + dam/mast)
			dam = 0
		else
			self:incPsi(2 + self.thermal_shield/mast)
			dam = dam - self.thermal_shield
		end
		return dam + guaranteed_dam
	end,


	activate = function(self, t)
		--if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
		--	game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.")
		--	return false
		--end
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)
		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-10000, llpow=1, aadjust=3, color={0.3, 1, 1}}))
		else
			particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=0.5}))
		end
		return {
			am = self:addTemporaryValue("thermal_shield", s_str),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("thermal_shield", p.am)
		if self:attr("save_cleanup") then return true end
		self:setEffect(self.EFF_THERMSPIKE_SHIELD, 5, {power=spike_str})
		return true
	end,

	--called when damage gets absorbed by thermal shield spike
	tss_on_damage = function(self, t, damtype, dam)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 1* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

		if thermalElement(self, t, damtype) then
			-- Absorb damage into the shield
			if dam <= self.thermspike_shield_absorb then
				self.thermspike_shield_absorb = self.thermspike_shield_absorb - dam
				self:incPsi(2 + 2*dam/mast)
				dam = 0
			else
				self:incPsi(2 + 2*self.thermspike_shield_absorb/mast)
				dam = dam - self.thermspike_shield_absorb
				self.thermspike_shield_absorb = 0
			end

			if self.thermspike_shield_absorb <= 0 then
				game.logPlayer(self, "열역학적 보호막의 파편들이 깨져 사라졌습니다!")
				self:removeEffect(self.EFF_THERMSPIKE_SHIELD)
			end
			return dam + guaranteed_dam
		else
			return total_dam
		end
	end,

	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local spike_str = getSpikeStrength(self, t)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 화염 공격이나 냉기 공격의 %d%% 를 막아냅니다. (한번에 %d 피해까지 막아낼 수 있습니다)
		보호막을 해제하면 열역학적 보호막의 파편이 생겨나, 5 턴 동안 화염 공격이나 냉기 공격을 %d 만큼 완전히 막아냅니다.
		보호막이 피해를 흡수할 때마다 염력을 2 회복하며, %d 피해를 흡수했을 때마다 추가로 염력을 1 회복합니다. 보호막의 파편들은 피해 흡수에 따른 염력 회복을 더 효율적으로 합니다.
		피해 흡수량 등은 정신력의 영향을 받아 증가합니다.]]):
		format(absorb, s_str, spike_str, mast)
	end,
}

newTalent{
	name = "Charged Shield",
	kr_display_name = "전하적 보호막",
	type = {"psionic/absorption", 3},
	require = psi_wil_req3,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 30,
	cooldown = function(self, t)
		return 20 - 2*(self:getTalentLevelRaw(self.T_SHIELD_DISCIPLINE) or 0)
	end,
	range = 10,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_THERMAL_SHIELD) then
			if not silent then game.logSeen(self, "보호막은 한번에 2 개 까지만 유지할 수 있습니다. 보호막 생성이 취소됩니다.") end
			return false
		end
		return true
	end,
	--called when damage gets absorbed by charged shield
	cs_on_damage = function(self, t, damtype, dam)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not chargedElement(self, t, damtype) then return total_dam end

		if dam <= self.charged_shield then
			self:incPsi(2 + dam/mast)
			dam = 0
		else
			self:incPsi(2 + self.charged_shield/mast)
			dam = dam - self.charged_shield
		end
		return dam + guaranteed_dam
	end,


	activate = function(self, t)
		--if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_THERMAL_SHIELD) then
		--	game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.")
		--	return false
		--end
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)
		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-10000, llpow=1, aadjust=3, color={0.8, 1, 0.2}}))
		else
			particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=0.5}))
		end
		return {
			am = self:addTemporaryValue("charged_shield", s_str),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("charged_shield", p.am)
		if self:attr("save_cleanup") then return true end
		self:setEffect(self.EFF_CHARGESPIKE_SHIELD, 5, {power=spike_str})
		return true
	end,

	--called when damage gets absorbed by charged shield spike
	css_on_damage = function(self, t, damtype, dam)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local total_dam = dam
		local absorbable_dam = 1* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if chargedElement(self, t, damtype) then
			-- Absorb damage into the shield
			if dam <= self.chargespike_shield_absorb then
				self.chargespike_shield_absorb = self.chargespike_shield_absorb - dam
				self:incPsi(2 + 2*dam/mast)
				dam = 0
			else
				self:incPsi(2 + 2*self.chargespike_shield_absorb/mast)
				dam = dam - self.chargespike_shield_absorb
				self.chargespike_shield_absorb = 0
			end

			if self.chargespike_shield_absorb <= 0 then
				game.logPlayer(self, "전하적 보호막의 파편들이 깨져 사라졌습니다!")
				self:removeEffect(self.EFF_CHARGESPIKE_SHIELD)
			end
			return dam + guaranteed_dam
		else
			return total_dam
		end
	end,

	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local spike_str = getSpikeStrength(self, t)
		local mast = 30 - (2*self:getTalentLevel(self.T_SHIELD_DISCIPLINE) or 0) - 0.4*getGemLevel(self)
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 전기 공격이나 황폐화 공격의 %d%% 를 막아냅니다. (한번에 %d 피해까지 막아낼 수 있습니다)
		보호막을 해제하면 전하적 보호막의 파편이 생겨나, 5 턴 동안 전기 공격이나 황폐화 공격을 %d 만큼 완전히 막아냅니다.
		보호막이 피해를 흡수할 때마다 염력을 2 회복하며, %d 피해를 흡수했을 때마다 추가로 염력을 1 회복합니다. 보호막의 파편들은 피해 흡수에 따른 염력 회복을 더 효율적으로 합니다.
		피해 흡수량 등은 정신력의 영향을 받아 증가합니다.]]):
		format(absorb, s_str, spike_str, mast)
	end,
}

newTalent{
	name = "Absorption Mastery",
	kr_display_name = "피해 흡수 수련",
	type = {"psionic/absorption", 4},
	require = psi_wil_req4,
	cooldown = function(self, t)
		return math.floor(120 - self:getTalentLevel(t)*12)
	end,
	psi = 15,
	points = 5,
	no_energy = true,
	tactical = { BUFF = 3 },
	action = function(self, t)
		if self.talents_cd[self.T_KINETIC_SHIELD] == nil and self.talents_cd[self.T_THERMAL_SHIELD] == nil and self.talents_cd[self.T_CHARGED_SHIELD] == nil then
			return
		else
			self.talents_cd[self.T_KINETIC_SHIELD] = nil
			self.talents_cd[self.T_THERMAL_SHIELD] = nil
			self.talents_cd[self.T_CHARGED_SHIELD] = nil
			return true
		end
	end,

	info = function(self, t)
		return ([[사용하면 모든 보호막의 재사용 대기시간이 초기화됩니다. 기술 레벨이 올라가면 더 자주 기술을 사용할 수 있게 됩니다.
		기술 레벨이 3 과 6 이상이 되면, 보호막이 다른 속성까지 막을 수 있게 됩니다.
		- 동역학적 보호막 : 3 레벨에 자연 속성, 6 레벨에 시간 속성
		- 열역학적 보호막 : 3 레벨에 빛 속성, 6 레벨에 마법 속성
		- 전하적 보호막 : 3 레벨에 어둠 속성, 6 레벨에 정신 속성]])
	end,
}
