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


-- Note: This is consistent with raw damage but is applied after damage multipliers
local function getShieldStrength(self, t)
	--return math.max(0, self:combatMindpower())
	return self:combatTalentMindDamage(t, 20, 100)
end

local function getEfficiency(self, t)
	return self:combatTalentLimit(t, 100, 20, 55)/100 -- Limit to <100%
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
		for i = 2, 0, -1 do
			local ni = i + diff
			if ni <= 2 then
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
	for i = 0, 2 do val = val + (p.last_absorbs.values[i] or 0) end
	if val > 0 then self:setEffect(self.EFF_PSI_DAMAGE_SHIELD, 5, {power=val*2}) end
end

local function shieldOverlay(self, t, p)
	local val = 0
	for i = 0, 2 do val = val + (p.last_absorbs.values[i] or 0) end
	if val <= 0 then return "" end
	local fnt = "buff_font_small"
	if val >= 1000 then fnt = "buff_font_smaller" end
	return tostring(math.ceil(val)), fnt
end

local function shieldOnDamage(self, t, elementTest, transcendId, dam)
	if not elementTest then return dam end
	local shield = self:isTalentActive(t.id)
	if shield.game_turn + 10 <= game.turn then
		shield.psi_gain = 0
		shield.game_turn = game.turn
	end
	local mast = shieldMastery(self, t)
	local total_dam = dam
	local absorbable_dam = getEfficiency(self, t) * total_dam
	local strength = getShieldStrength(self, t)
	if self:hasEffect(transcendId) then
		absorbable_dam = total_dam
		strength = strength * 2
	end
	local guaranteed_dam = total_dam - absorbable_dam
	dam = absorbable_dam

	local psigain = 0
	if dam <= strength then
		psigain = 1 + dam/mast
		shieldAbsorb(self, t, shield, dam)
		dam = 0
	else
		psigain = 1 + strength/mast
		dam = dam - strength
		shieldAbsorb(self, t, shield, strength)
	end
	psigain = math.min(maxPsiAbsorb(self, t) - shield.psi_gain, psigain)
	shield.psi_gain = shield.psi_gain + psigain
	self:incPsi(psigain)

	return dam + guaranteed_dam
end

local function adjustShieldGFX(self, t, v, p, r, g, b)
	if not p then p = self:isTalentActive(t.id) end
	if not p then return end
	self:removeParticles(p.particle)
	if v then
		if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"},
			{type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={r, g, b, 0.6}, auraColor={r, g, b, 1}}))
		else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=r, g=g, b=b, a=1}))
		end
	else
		if core.shader.active(4) then p.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1, img="shield5"},
			{type="shield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=3, color={r, g, b}}))
		else p.particle = self:addParticles(Particles.new("generic_shield", 1, {r=r, g=g, b=b, a=0.5}))
		end
	end
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
			if not silent then game.logSeen(self, "보호막은 한번에 2개 까지만 유지할 수 있습니다. 보호막 생성이 취소됩니다.") end
			return false
		end
		return true
	end,
	--called when damage gets absorbed by kinetic shield
	ks_on_damage = function(self, t, damtype, dam)
		return shieldOnDamage(self, t, kineticElement(self, t, damtype),
			self.EFF_TRANSCENDENT_TELEKINESIS, dam)
	end,
	adjust_shield_gfx = function(self, t, v, p)
		return adjustShieldGFX(self, t, v, p, 1, 0, 0.3)
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")

		local ret = {
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
		return true
	end,
	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 물리/산성/자연/시간 속성 공격의 %d%% 를 막아냅니다. 한번에 %d 피해까지 막아낼 수 있습니다
		보호막이 피해를 흡수할 때마다, 공격의 일부를 염력으로 변환하여, 염력을 1 회복하며, %0.1f 피해를 흡수할 때마다 추가로 염력을 1 회복합니다, 턴 당 염력을 최대 %0.1f까지 회복할 수 있습니다.
		기술 레벨이 3 이상일 경우, 보호막을 해제할 때 보호막을 해제할 때 마지막 3 턴 동안 흡수한 피해량의 두 배 만큼을 완전히 막아내는 염력 보호막을 만들어냅니다.
		보호막의 최대 피해 흡수량과 염력 회복 효율은 정신력의 영향을 받아 증가합니다.
		보호막은 한번에 2개 까지만 유지할 수 있습니다.]]):
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
		return shieldOnDamage(self, t, thermalElement(self, t, damtype),
			self.EFF_TRANSCENDENT_PYROKINESIS, dam)
	end,
	adjust_shield_gfx = function(self, t, v, p)
		return adjustShieldGFX(self, t, v, p, 0.3, 1, 1)
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
		return true
	end,
	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 화염/냉기/빛/마법 속성 공격의 %d%% 를 막아냅니다. 한번에 %d 피해까지 막아낼 수 있습니다
		보호막이 피해를 흡수할 때마다, 공격의 일부를 염력으로 변환하여, 염력을 1 회복하며, %0.1f 피해를 흡수할 때마다 추가로 염력을 1 회복합니다, 턴 당 염력을 최대 %0.1f까지 회복할 수 있습니다.
		기술 레벨이 3 이상일 경우, 보호막을 해제할 때 보호막을 해제할 때 마지막 3 턴 동안 흡수한 피해량의 두 배 만큼을 완전히 막아내는 염력 보호막을 만들어냅니다.
		보호막의 최대 피해 흡수량과 염력 회복 효율은 정신력의 영향을 받아 증가합니다.
		보호막은 한번에 2개 까지만 유지할 수 있습니다.]]):
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
	shieldAbsorb = shieldAbsorb,
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
		return shieldOnDamage(self, t, chargedElement(self, t, damtype),
			self.EFF_TRANSCENDENT_ELECTROKINESIS, dam)
	end,
	adjust_shield_gfx = function(self, t, v, p)
		return adjustShieldGFX(self, t, v, p, 0.8, 1, 0.2)
	end,
	iconOverlay = shieldOverlay,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local s_str = getShieldStrength(self, t)

		local ret = {
			game_turn = game.turn,
			psi_gain = 0,
			last_absorbs = {last_turn=math.floor(game.turn / 10), values={}},
		}
		t.adjust_shield_gfx(self, t, self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS), ret)
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		if self:attr("save_cleanup") then return true end

		if self:getTalentLevel(t) >= 3 then shieldSpike(self, t, p) end
		return true
	end,
	info = function(self, t)
		local s_str = getShieldStrength(self, t)
		local absorb = 100*getEfficiency(self,t)
		return ([[시전자 주변을 보호막으로 둘러싸, 전기/황폐/어둠/정신 속성 공격의 %d%% 를 막아냅니다. 한번에 %d 피해까지 막아낼 수 있습니다
		보호막이 피해를 흡수할 때마다, 공격의 일부를 염력으로 변환하여, 염력을 1 회복하며, %0.1f 피해를 흡수할 때마다 추가로 염력을 1 회복합니다, 턴 당 염력을 최대 %0.1f까지 회복할 수 있습니다.
		기술 레벨이 3 이상일 경우, 보호막을 해제할 때 보호막을 해제할 때 마지막 3 턴 동안 흡수한 피해량의 두 배 만큼을 완전히 막아내는 염력 보호막을 만들어냅니다.
		보호막의 최대 피해 흡수량과 염력 회복 효율은 정신력의 영향을 받아 증가합니다.
		보호막은 한번에 2개 까지만 유지할 수 있습니다.]]):
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Forcefield",
	kr_name = "역장",
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
	callbackOnTakeDamage = function(self, t, src, x, y, damtype, dam, tmp)
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
		return ([[시전자 주변을 정신역장으로 둘러싸, 모든 피해량을 %d%% 감소시킵니다.
		이 강력한 보호막은 매우 유지하기 힘들기 때문에, 매 턴마다 최대 염력의 5%% 만큼이 소모되고 염력 소모량이 5%%씩 증가합니다. 예를 들면, 2턴째에는 10%%가 소모됩니다.]]):
		format(t.getResist(self,t))
	end,
}
