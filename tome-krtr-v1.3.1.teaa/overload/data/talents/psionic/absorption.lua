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
		absorbable = total_dam
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
			if not silent then game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.") end
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
		return ([[Surround yourself with a shield that will absorb %d%% of any physical/acid/nature/temporal attack, up to a maximum of %d damage per attack.
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining one point of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn.
		At talent level 3, when you de-activate the shield twice the absorbed damage (if any) in the last 3 turns is released as a full psionic shield (absorbing all damage).
		The maximum amount of damage your shield can absorb and the efficiency of the psi gain scale with your mindpower.
		You can only have two of these shields active at once.]]):
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Thermal Shield",
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
			if not silent then game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.") end
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
		return ([[Surround yourself with a shield that will absorb %d%% of any fire/cold/light/arcane attack, up to a maximum of %d damage per attack.
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining one point of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn.
		At talent level 3, when you de-activate the shield twice the absorbed damage (if any) in the last 3 turns is released as a full psionic shield (absorbing all damage).
		The maximum amount of damage your shield can absorb and the efficiency of the psi gain scale with your mindpower.
		You can only have two of these shields active at once.]]):
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Charged Shield",
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
			if not silent then game.logSeen(self, "You may only sustain two shields at once. Shield activation cancelled.") end
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
		return ([[Surround yourself with a shield that will absorb %d%% of any lightning/blight/darkness/mind attack, up to a maximum of %d damage per attack.
		Every time your shield absorbs damage, you convert some of the attack into energy, gaining one point of Psi, plus an additional point for every %0.1f points of damage absorbed, up to a maximum %0.1f points each turn.
		At talent level 3, when you de-activate the shield twice the absorbed damage (if any) in the last 3 turns is released as a full psionic shield (absorbing all damage).
		The maximum amount of damage your shield can absorb and the efficiency of the psi gain scale with your mindpower.
		You can only have two of these shields active at once.]]):
		format(absorb, s_str, shieldMastery(self, t), maxPsiAbsorb(self,t))
	end,
}

newTalent{
	name = "Forcefield",
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
		return ([[Surround yourself with a forcefield, reducing all incoming damage by %d%%.
		Such a shield is very expensive to maintain, and will drain 5%% of your maximum psi each turn and 5%% more for each turn you have it maintained. For example, on turn 2 it will drain 10%%.]]):
		format(t.getResist(self,t))
	end,
}
