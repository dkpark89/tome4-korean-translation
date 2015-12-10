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

-- Edge TODO: Sounds, Particles, Talent Icons; Trance of Focus; Deep Trance

local function cancelTrances(self)
	local trances = {self.T_TRANCE_OF_CLARITY, self.T_TRANCE_OF_PURITY, self.T_TRANCE_OF_FOCUS}
	for i, t in ipairs(trances) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Trance of Purity",
	kr_name = "순수의 최면",
	type = {"psionic/trance", 1},
	points = 5,
	require = psi_wil_req1,
	cooldown = 12,
	tactical = { BUFF = 2 },
	mode = "sustained",
	sustain_psi = 20,
	getSavingThrows = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getPurgeChance = function(self, t) return 50 - math.min(30, self:combatTalentMindDamage(t, 0, 30)) end,
	activate = function(self, t)
		local effs = {}
		local chance = 100
		
		-- go through all timed effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type ~= "other" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		
		-- Check chance to remove effects and purge them if possible
		while chance > 0 and #effs > 0 do
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" and rng.percent(chance) then
				self:removeEffect(eff[2])
				chance = chance - t.getPurgeChance(self, t)
			end
		end
	
		-- activate sustain
		cancelTrances(self)
		local power = t.getSavingThrows(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			phys = self:addTemporaryValue("combat_physresist", power),
			spell = self:addTemporaryValue("combat_spellresist", power),
			mental = self:addTemporaryValue("combat_mentalresist", power),
		--	particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
	--	self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_spellresist", p.spell)
		self:removeTemporaryValue("combat_mentalresist", p.mental)
		return true
	end,
	info = function(self, t)
		local purge = t.getPurgeChance(self, t)
		local saves = t.getSavingThrows(self, t)
		return ([[사용하면 나쁜 상태효과들이 제거됩니다. (100%% 확률로 첫번째 상태효과가 제거되며, 두번째 상태효과부터는 확률이 %d%% 씩 낮아집니다)
		최면이 유지되는 동안, 모든 내성이 %d 증가합니다.
		상태효과 제거 확률과 내성 증가량은 정신력의 영향을 받아 증가합니다.
		한번에 하나의 최면 효과만을 유지할 수 있습니다.]]):format(purge, saves)
	end,
}

newTalent{
	short_name = "TRANCE_OF_WELL_BEING",
	name = "Trance of Well-Being",
	kr_name = "치유의 최면",
	type = {"psionic/trance", 2},
	points = 5,
	require = psi_wil_req2,
	cooldown = 12,
	tactical = { BUFF = 2 },
	mode = "sustained",
	sustain_psi = 20,
	getHeal = function(self, t) return self:combatTalentMindDamage(t, 20, 340) end,
	getHealingModifier = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getLifeRegen = function(self, t) return self:combatTalentMindDamage(t, 10, 50) / 10 end,
	activate = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:mindCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
	
		cancelTrances(self)	
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			heal_mod = self:addTemporaryValue("healing_factor", t.getHealingModifier(self, t)/100),
			regen = self:addTemporaryValue("life_regen", t.getLifeRegen(self, t)),
		}

		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
			ret.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healcelestial"}, {type="healing", time_factor=4000, noup=2.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
			ret.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healcelestial"}, {type="healing", time_factor=4000, noup=1.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleColor={0,0,0,0}, beamsCount=5}))
		end
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle1)
		self:removeParticles(p.particle2)
		self:removeTemporaryValue("healing_factor", p.heal_mod)
		self:removeTemporaryValue("life_regen", p.regen)
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local healing_modifier = t.getHealingModifier(self, t)
		local regen = t.getLifeRegen(self, t)
		return ([[사용하면 생명력이 %0.2f 회복됩니다. 최면이 유지되는 동안, 치유 효율이 %d%% 증가하고 생명력 재생이 %0.2f 증가합니다.
		최면의 효과는 정신력의 영향을 받아 증가합니다.
		한번에 하나의 최면 효과만을 유지할 수 있습니다.]]):format(heal, healing_modifier, regen)
	end,
}

newTalent{
	name = "Trance of Focus",
	kr_name = "집중의 최면",
	type = {"psionic/trance", 3},
	points = 5,
	require = psi_wil_req3,
	cooldown = 12,
	tactical = { BUFF = 2 },
	mode = "sustained",
	sustain_psi = 20,
	getCriticalPower = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getCriticalChance = function(self, t) return self:combatTalentMindDamage(t, 4, 12) end,
	activate = function(self, t)
		self:setEffect(self.EFF_TRANCE_OF_FOCUS, 10, {t.getCriticalPower(self, t)})
		
		cancelTrances(self)	
		local power = t.getCriticalChance(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			phys = self:addTemporaryValue("combat_physcrit", power),
			spell = self:addTemporaryValue("combat_spellcrit", power),
			mental = self:addTemporaryValue("combat_mindcrit", power),
		}
		
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physcrit", p.phys)
		self:removeTemporaryValue("combat_spellcrit", p.spell)
		self:removeTemporaryValue("combat_mindcrit", p.mental)
		return true
	end,
	info = function(self, t)
		local power = t.getCriticalPower(self, t)
		local chance = t.getCriticalChance(self, t)
		return ([[사용하면 치명타 피해량이 10 턴 동안 %d%% 증가합니다. 그리고 최면이 유지되는 동안, 치명타율이 %d%% 증가합니다.
		최면의 효과는 정신력의 영향을 받아 증가합니다.]])::format(power, chance)
	end,
}

newTalent{
	name = "Deep Trance",
	kr_name = "깊은 최면",
	type = {"psionic/trance", 4},
	points = 5,
	require = psi_wil_req4,
	mode = "passive",
	info = function(self, t)
		return ([[염력, 자연, 반마법의 힘이 깃든 장비를 착용하면, 해당 장비의 '착용시 적용' 항목에 있는 모든 능력치가 %d%% 향상됩니다.
		장비 자체의 능력을 바꾸지는 않으며, 사용자에게만 적용됩니다. (장비 설명에는 향상된 수치가 표시되지 않습니다)]]):format(1)
	end,
}
