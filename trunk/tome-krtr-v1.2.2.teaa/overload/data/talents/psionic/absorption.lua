﻿-- ToME - Tales of Maj'Eyal
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

-- Note: This is consistent with raw damage but is applied after damage multipliers
local function getShieldStrength(self, t)
	--return math.max(0, self:combatMindpower())
	return self:combatTalentMindDamage(t, 10, 100)
end

local function getSpikeStrength(self, t)
	local ss = getShieldStrength(self, t)
	return 75*self:getTalentLevel(t) + ss*6.85
end

local function getEfficiency(self, t)
	return self:combatTalentLimit(t, 100, 20, 70)/100 -- Limit to <100%
end

local function maxPsiAbsorb(self, t) -- Max psi/turn to prevent runaway psi gains (solipsist randbosses)
	return 2 + self:combatTalentScale(t, 0.3, 1)
end

local function shieldMastery(self, t)
	return 100-self:combatTalentMindDamage(t, 40, 50)
end

local function kineticElement(self, t, damtype)
	if damtype == DamageType.PHYSICAL or damtype == DamageType.ACID or damtype == DamageType.NATURE or damtype == DamageType.TEMPORAL then return true end
	return false
end

local function thermalElement(self, t, damtype)
	if damtype == DamageType.FIRE or damtype == DamageType.COLD or damtype == DamageType.LIGHT or damtype == DamageType.ARCANE then return true end
	return false
end

local function chargedElement(self, t, damtype)
	if damtype == DamageType.LIGHTNING or damtype == DamageType.BLIGHT or damtype == DamageType.DARKNESS or damtype == DamageType.MIND then return true end
	return false
end

local function shieldAbsorb(self, t, p, absorbed)
	local cturn = math.floor(game.turn / 10)
	if cturn ~= p.last_absorbs.last_turn then
		local diff = cturn - p.last_absorbs.last_turn
		for i = 5, 0, -1 do
			local ni = i + diff
			if ni <= 5 then
				p.last_absorbs.values[ni] = p.last_absorbs.values[i]
			end
			p.last_absorbs.values[i] = nil
		end
	end
	p.last_absorbs.values[0] = (p.last_absorbs.values[0] or 0) + absorbed
	p.last_absorbs.last_turn = cturn
end

local function shieldSpike(self, t, p)
	local val = 0
	for i = 0, 5 do val = val + (p.last_absorbs.values[i] or 0) end

	self:setEffect(self.EFF_PSI_DAMAGE_SHIELD, 5, {power=val})
end

local function shieldOverlay(self, t, p)
	local val = 0
	for i = 0, 5 do val = val + (p.last_absorbs.values[i] or 0) end
	if val <= 0 then return "" end
	local fnt = "buff_font_small"
	if val >= 1000 then fnt = "buff_font_smaller" end
	return tostring(math.ceil(val)), fnt
end

newTalent{
	name = "Kinetic Shield",
	kr_name = "동역학적 보호막",
	type = {"psionic/absorption", 1},
	require = psi_cun_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 14, 10, true)) end, --Limit > 5
	range = 0,
	no_energy = true,
	tactical = { DEFEND = 2 },
	callbackOnActBase = function(self, t)
		shieldAbsorb(self, t, self.sustain_talents[t.id], 0) -- make sure we compute the table correctly
	end,
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_THERMAL_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
			if not silent then game.logSeen(self, "보호막은 한번에 2 개 까지만 유지할 수 있습니다. 보호막 생성이 취소됩니다.") end
			return false
		end
		return true
	end,
	--called when damage gets absorbed by kinetic shield
	ks_on_damage = function(self, t, damtype, dam)
		local ks = self:isTalentActive(self.T_KINETIC_SHIELD)
		if not ks then return dam end
		if ks.game_turn + 10 <= game.turn then
			ks.psi_gain = 0
			ks.game_turn = game.turn
		end
		local kinetic_shield = self.kinetic_shield
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		if self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS) then absorbable_dam = total_dam kinetic_shield = kinetic_shield * 2 end
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not kineticElement(self, t, damtype) then return total_dam end		

		local psigain = 0
		if dam <= kinetic_shield then
			psigain = 1 + dam/mast
			shieldAbsorb(self, t, ks, dam)
			dam = 0
		else
			psigain = 1 + kinetic_shield/mast
			dam = dam - kinetic_shield
			shieldAbsorb(self, t, ks, kinetic_shield)
		end
		psigain = math.min(maxPsiAbsorb(self, t) - ks.psi_gain, psigain)
		ks.psi_gain = ks.psi_gain + psigain
		self:incPsi(psigain)

		return dam + guaranteed_dam
	end,
	adjust_shield_gfx = function(self, t, v, p)
		if not p then p = self:isTalentActive(t.id) end
		if not p then return end

		self:removeParticles(p.particle)
		if v then
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={1, 0, 0.3, 0.6}, auraColor={1, 0, 0.3, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=1}))
			end
		else
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={1, 0, 0.3}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=0.5}))
			end
		end
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			am = self:addTemporaryValue("kinetic_shield", s_str),
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("kinetic_shield", p.am)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
		return true
	end,
	--called when damage gets absorbed by kinetic shield spike
	kss_on_damage = function(self, t, damtype, dam)
		local kss = self:hasEffect(self.EFF_KINSPIKE_SHIELD)
		if not kss then return dam end
		if kss.game_turn + 10 <= game.turn then
			kss.psi_gain = 0
			kss.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = 1*total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

--		local psigain = 0
		if kineticElement(self, t, damtype) then
			-- Absorb damage into the shield
			if dam <= self.kinspike_shield_absorb then
			self.kinspike_shield_absorb = self.kinspike_shield_absorb - dam
--				psigain = 2 + 2*dam/mast
				dam = 0
			else
--				psigain = 2 + 2*self.kinspike_shield_absorb/mast 
				dam = dam - self.kinspike_shield_absorb
				self.kinspike_shield_absorb = 0
			end

--			psigain = math.min(2*maxPsiAbsorb(self, t) - kss.psi_gain, psigain)
--			kss.psi_gain = kss.psi_gain + psigain
--			self:incPsi(psigain)

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
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 물리/산성/자연/시간 속성의 공격의 %d%% 를 막아냅니다. (한번에 %d 피해까지 막아낼 수 있습니다)
		보호막이 피해를 흡수할 때마다 공격력의 일부를 변환하여 염력을 2 회복하며, %0.1f 피해를 흡수했을 때마다 추가로 염력을 1 회복합니다 (턴 당 최대 염력 회복 : %0.1f).
		At talent level 3, when you de-activate the shield all the absorbed damage in the last 6 turns is released as a full psionic shield (absorbing all damage).
		보호막의 최대 피해 흡수량과 the efficiency of the psi gain는 정신력의 영향을 받아 증가합니다.]]): --@@ 한글화 필요 #228~229
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}



newTalent{
	name = "Thermal Shield",
	kr_name = "열역학적 보호막",
	type = {"psionic/absorption", 1},
	require = psi_cun_req2,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 14, 10, true)) end, --Limit > 5
	range = 0,
	no_energy = true,
	tactical = { DEFEND = 2 },
	callbackOnActBase = function(self, t)
		shieldAbsorb(self, t, self.sustain_talents[t.id], 0) -- make sure we compute the table correctly
	end,
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_CHARGED_SHIELD) then
			if not silent then game.logSeen(self, "보호막은 한번에 2 개 까지만 유지할 수 있습니다. 보호막 생성이 취소됩니다.") end
			return false
		end
		return true
	end,

	--called when damage gets absorbed by thermal shield
	ts_on_damage = function(self, t, damtype, dam)
		local ts = self:isTalentActive(self.T_THERMAL_SHIELD)
		if not ts then return dam end
		if ts.game_turn + 10 <= game.turn then
			ts.psi_gain = 0
			ts.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local thermal_shield = self.thermal_shield
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		if self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS) then absorbable_dam = total_dam thermal_shield = thermal_shield * 2 end
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not thermalElement(self, t, damtype) then return total_dam end
		
		local psigain = 0
		if dam <= thermal_shield then
			psigain = 1 + dam/mast
			shieldAbsorb(self, t, ts, dam)
			dam = 0
		else
			psigain = 1 + thermal_shield/mast
			shieldAbsorb(self, t, ts, thermal_shield)
			dam = dam - thermal_shield
		end
		
		psigain = math.min(maxPsiAbsorb(self, t) - ts.psi_gain, psigain)
		ts.psi_gain = ts.psi_gain + psigain
		self:incPsi(psigain)
		
		return dam + guaranteed_dam
	end,
	adjust_shield_gfx = function(self, t, v, p)
		if not p then p = self:isTalentActive(t.id) end
		if not p then return end

		self:removeParticles(p.particle)
		if v then
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={0.3, 1, 1, 0.6}, auraColor={0.3, 1, 1, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=1}))
			end
		else
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={0.3, 1, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=0.5}))
			end
		end
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			am = self:addTemporaryValue("thermal_shield", s_str),
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("thermal_shield", p.am)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
		return true
	end,
	--called when damage gets absorbed by thermal shield spike
	tss_on_damage = function(self, t, damtype, dam)
		local tss = self:hasEffect(self.EFF_THERMSPIKE_SHIELD)
		if not tss then return dam end
		if tss.game_turn + 10 <= game.turn then
			tss.psi_gain = 0
			tss.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = 1* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam

--		local psigain = 0
		if thermalElement(self, t, damtype) then
			-- Absorb damage into the shield
			if dam <= self.thermspike_shield_absorb then
				self.thermspike_shield_absorb = self.thermspike_shield_absorb - dam
--				psigain = 2 + 2*dam/mast
				dam = 0
			else
--				psigain = 2 + 2*self.thermspike_shield_absorb/mast
				dam = dam - self.thermspike_shield_absorb
				self.thermspike_shield_absorb = 0
			end
--			psigain = math.min(2*maxPsiAbsorb(self, t) - tss.psi_gain, psigain)
--			tss.psi_gain = tss.psi_gain + psigain
--			self:incPsi(psigain)
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
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 화염/냉기/빛/마법 속성 공격의 %d%% 를 막아냅니다. (한번에 %d 피해까지 막아낼 수 있습니다)
		보호막이 피해를 흡수할 때마다 공격력의 일부를 변환하여 염력을 2 회복하며, %0.1f 피해를 흡수했을 때마다 추가로 염력을 1 회복합니다 (턴 당 최대 염력 회복 : %0.1f).
		At talent level 3, when you de-activate the shield all the absorbed damage in the last 6 turns is released as a full psionic shield (absorbing all damage).
		보호막의 최대 피해 흡수량과 the efficiency of the psi gain는 정신력의 영향을 받아 증가합니다.]]): --@@ 한글화 필요 #374~375
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Charged Shield",
	kr_name = "전하적 보호막",
	type = {"psionic/absorption", 1},
	require = psi_cun_req3,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	sustain_psi = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 14, 10, true)) end, --Limit > 5
	range = 0,
	no_energy = true,
	tactical = { DEFEND = 2 },
	callbackOnActBase = function(self, t)
		shieldAbsorb(self, t, self.sustain_talents[t.id], 0) -- make sure we compute the table correctly
	end,
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_SHIELD) and self:isTalentActive(self.T_THERMAL_SHIELD) then
			if not silent then game.logSeen(self, "보호막은 한번에 2 개 까지만 유지할 수 있습니다. 보호막 생성이 취소됩니다.") end
			return false
		end
		return true
	end,
	--called when damage gets absorbed by charged shield
	cs_on_damage = function(self, t, damtype, dam)
		local cs = self:isTalentActive(self.T_CHARGED_SHIELD)
		if not cs then return dam end
		if cs.game_turn + 10 <= game.turn then
			cs.psi_gain = 0
			cs.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local charged_shield = self.charged_shield
		local total_dam = dam
		local absorbable_dam = getEfficiency(self,t)* total_dam
		if self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS) then absorbable_dam = total_dam charged_shield = charged_shield * 2 end
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
		if not chargedElement(self, t, damtype) then return total_dam end

		local psigain = 0
		if dam <= charged_shield then
			psigain = 1 + dam/mast
			shieldAbsorb(self, t, cs, dam)
			dam = 0
		else
			psigain = 1 + charged_shield/mast
			dam = dam - charged_shield
			shieldAbsorb(self, t, cs, charged_shield)
		end
		psigain = math.min(maxPsiAbsorb(self, t) - cs.psi_gain, psigain)
		cs.psi_gain = cs.psi_gain + psigain
		self:incPsi(psigain)
		return dam + guaranteed_dam
	end,
	adjust_shield_gfx = function(self, t, v, p)
		if not p then p = self:isTalentActive(t.id) end
		if not p then return end

		self:removeParticles(p.particle)
		if v then
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={0.8, 1, 0.2, 0.6}, auraColor={0.8, 1, 0.2, 1}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=1}))
			end
		else
			if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"}, {type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={0.8, 1, 0.2}}))
			else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=0.5}))
			end
		end
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			am = self:addTemporaryValue("charged_shield", s_str),
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		local spike_str = getSpikeStrength(self, t)
		self:removeTemporaryValue("charged_shield", p.am)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
		return true
	end,
	--called when damage gets absorbed by charged shield spike
	css_on_damage = function(self, t, damtype, dam)
		local css = self:hasEffect(self.EFF_CHARGESPIKE_SHIELD)
		if not css then return dam end
		if css.game_turn + 10 <= game.turn then
			css.psi_gain = 0
			css.game_turn = game.turn
		end
		local mast = shieldMastery(self, t)
		local total_dam = dam
		local absorbable_dam = 1* total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		dam = absorbable_dam
	
--		local psigain = 0
		if chargedElement(self, t, damtype) then	
			-- Absorb damage into the shield
			if dam <= self.chargespike_shield_absorb then
				self.chargespike_shield_absorb = self.chargespike_shield_absorb - dam
--				psigain = 2 + 2*dam/mast
				dam = 0
			else
--				psigain = 2 + 2*self.chargespike_shield_absorb/mast
				dam = dam - self.chargespike_shield_absorb
				self.chargespike_shield_absorb = 0
			end
			
--			psigain = math.min(2*maxPsiAbsorb(self, t) - css.psi_gain, psigain)
--			css.psi_gain = css.psi_gain + psigain
--			self:incPsi(psigain)

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
		local xs = (chargedElement(self, t, DamageType.DARKNESS) and "어둠 속성, " or "")..(chargedElement(self, t, DamageType.MIND) and "정신 속성, " or "")
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 전기/황폐/어둠/정신 속성 공격의 %d%% 를 막아냅니다. (한번에 %d 피해까지 막아낼 수 있습니다)
		보호막이 피해를 흡수할 때마다 공격력의 일부를 변환하여 염력을 2 회복하며, %0.1f 피해를 흡수했을 때마다 추가로 염력을 1 회복합니다 (턴 당 최대 염력 회복 : %0.1f).
		At talent level 3, when you de-activate the shield all the absorbed damage in the last 6 turns is released as a full psionic shield (absorbing all damage).
		보호막의 최대 피해 흡수량과 the efficiency of the psi gain는 정신력의 영향을 받아 증가합니다.]]): --@@ 한글화 필요 #519~520
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Forcefield",
	--kr_name = "", --@@ 한글화 필요
	type = {"psionic/absorption", 4},
	require = psi_cun_req4,
	points = 5,
	mode = "sustained",
	sustain_psi = 30,
	cooldown = 40,
	no_energy = true,
	tactical = { BUFF = 2, HEAL = 4 },
	range = 0,
	radius = 1,
	getResist = function(self, t) return self:combatTalentLimit(t, 80, 30, 65) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	activate = function(self, t)
		self.forcefield_timer = 1
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, blend=true, img="forcefield"}, {type="shield", shieldIntensity=0.15, color={1,1,1}}))
		else
			ret.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self.forcefield_timer = nil
		return true
	end,
	callbackOnTakeDamage = function(self, t, src, x, y, damtype, dam, tmp, no_martyr)
		local ff = self:isTalentActive(t.id)
		if not ff then return dam end
		local total_dam = dam
		local absorbable_dam = t.getResist(self,t) / 100 * total_dam
		local guaranteed_dam = total_dam - absorbable_dam
		return {dam=guaranteed_dam}
	end,
	callbackOnActBase = function(self, t)
		if self.psi < self.max_psi * self.forcefield_timer / 20 then self:forceUseTalent(self.T_FORCEFIELD, {ignore_energy=true}) return end
		self:incPsi(self.max_psi * self.forcefield_timer / -20)
		self.forcefield_timer = self.forcefield_timer + 1
	end,
	info = function(self, t)
		return ([[Surround yourself with a forcefield, reducing all incoming damage by %d%%. 
		Such a shield is very expensive to maintain, and will drain 5%% of your maximum psi each turn, for each turn you have it maintained. eg. turn 2 it will drain 10%%.]]): --@@ 한글화 필요 #571~572
		format(t.getResist(self,t))
	end,
}
