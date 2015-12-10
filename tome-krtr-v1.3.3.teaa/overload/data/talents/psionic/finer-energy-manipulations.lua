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
	name = "Realign",
	kr_name = "재조정", 
	type = {"psionic/finer-energy-manipulations", 1},
	require = psi_cun_req1,
	points = 5,
	psi = 15,
	cooldown = 15,
	tactical = { HEAL = 2, CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type == "physical" then
				nb = nb + 1
			end
		end
		return nb
	end },
	getHeal = function(self, t) return 40 + self:combatTalentMindDamage(t, 20, 290) end,
	is_heal = true,
	numCure = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log"))
	end,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:mindCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		
		local effs = {}
		-- Go through all temporary effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.type == "physical" and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.numCure(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s 치료되었습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		end
		
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local cure = t.numCure(self, t)
		return ([[정신력을 통해 육체를 재조정 및 재변경하여, %d 개의 해로운 물리적 상태 이상을 치료하고 생명력을 %d 회복합니다.
		생명력 회복량은 정신력의 영향을 받아 증가합니다.]]):
		format(cure, heal)
	end,
}

newTalent{
	name = "Reshape Weapon/Armour", image = "talents/reshape_weapon.png",
	kr_name = "무기/갑옷 재구성",
	type = {"psionic/finer-energy-manipulations", 2},
	require = psi_cun_req2,
	mode = "passive",
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	damBoost = function(self, t) return math.floor(self:combatTalentMindDamage(t, 5, 20)) end,
	armorBoost = function(self, t) return math.floor(self:combatTalentMindDamage(t, 5, 20)) end,
	fatigueBoost = function(self, t) return math.floor(self:combatTalentMindDamage(t, 2, 10)) end,
	getDamBoost = function(self, t, weapon)
		if weapon and weapon.talented ~= "mindstar" and weapon.talented ~= "unarmed" then
			return t.damBoost(self, t)
		end
		return 0
	end,
	getArmorBoost = function(self, t)
		local nb = 0
		if self:getInven("BODY") and self:getInven("BODY")[1] then nb = nb + 1 end
		if self:getInven("OFFHAND") and self:getInven("OFFHAND")[1] and self:getInven("OFFHAND")[1].subtype == "shield" then nb = nb + 1 end
		return nb * t.armorBoost(self, t)
	end,
	getFatigueBoost = function(self, t)
		local nb = 0
		if self:getInven("BODY") and self:getInven("BODY")[1] then nb = nb + 1 end
		if self:getInven("OFFHAND") and self:getInven("OFFHAND")[1] and self:getInven("OFFHAND")[1].subtype == "shield" then nb = nb + 1 end
		return nb * t.fatigueBoost(self, t)
	end,
	info = function(self, t)
		local weapon_boost = t.damBoost(self, t)
		local arm = t.armorBoost(self, t)
		local fat = t.fatigueBoost(self, t)
		return ([[무기나 갑옷, 또는 방패를 원자 레벨에서부터 재구성합니다. (마석은 이미 이상적인 상태로 존재하기 때문에, 재구성을 저항합니다)
		무기의 정확도와 피해량이 영구적으로 %d 상승합니다.
		갑옷이나 방패 착용시 각각 방어도가 영구적으로 %d 상승하고, 피로도가 영구적으로 %d 감소합니다.
		변화량은 정신력의 영향을 받아 증가합니다.]]):
		format(weapon_boost, arm, fat)
	end,
}

newTalent{
	name = "Matter is Energy",
	kr_name = "에너지 추출",
	type = {"psionic/finer-energy-manipulations", 3},
	require = psi_cun_req3,
	cooldown = 50,
	psi = 0,
	points = 5,
	no_npc_use = true,
	energy_per_turn = function(self, t)
		return self:combatTalentMindDamage(t, 10, 40)
	end,
	action = function(self, t)
		local ret = self:talentDialog(self:showInventory("어느 보석을 사용합니까?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.material_level and not gem.unique end, function(gem, gem_item)
			self:removeObject(self:getInven("INVEN"), gem_item)
			local amt = t.energy_per_turn(self, t)
			local dur = 3 + 2*(gem.material_level or 0)
			self:setEffect(self.EFF_PSI_REGEN, dur, {power=amt})
			self:setEffect(self.EFF_CRYSTAL_BUFF, dur, {name=gem.name, gem=gem.define_as, effects=gem.wielder})
			self:talentDialogReturn(true)
		end))
		if not ret then return nil end
		return true
	end,
	info = function(self, t)
		local amt = t.energy_per_turn(self, t)
		return ([[위대한 정신 파괴자의 말에 의하면, '모든 물체는 에너지의 근원이다' 고 합니다. 
		하지만 불행하게도, 대부분의 물체들은 너무나 복잡한 구성 방식을 가지고 있어서 에너지로 활용할 수 없습니다. 
		그나마 관리가 된 보석의 결정 구조는 단순한 편이기 때문에, 에너지를 추출해낼 수 있습니다.
		이 기술은 보석을 하나 소모하여, 5 - 13 턴 동안 매 턴마다 %d 염력을 추가로 회복합니다.
		수준 높은 보석일수록, 더 오랫동안 염력을 회복시켜줍니다.
		이 과정은 공명 역장을 형성해, 염력을 회복하는 동안 보석의 합성 효과를 제공합니다.]]):
		format(amt)
	end,
}

newTalent{
	name = "Resonant Focus",
	kr_name = "공명 집중", 
	type = {"psionic/finer-energy-manipulations", 4},
	require = psi_cun_req4,
	mode = "passive",
	points = 5,
	bonus = function(self,t) return self:combatTalentScale(t, 10, 40) end,
	on_learn = function(self, t)
		if self:isTalentActive(self.T_BEYOND_THE_FLESH) then
			if self.__to_recompute_beyond_the_flesh then return end
			self.__to_recompute_beyond_the_flesh = true
			game:onTickEnd(function()
				self.__to_recompute_beyond_the_flesh = nil
				local t = self:getTalentFromId(self.T_BEYOND_THE_FLESH)
				self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true})
				if t.on_pre_use(self, t) then self:forceUseTalent(t.id, {ignore_energy=true, ignore_cd=true, no_talent_fail=true, talent_reuse=true}) end
			end)
		end
	end,
	info = function(self, t)
		local inc = t.bonus(self,t)
		return ([[염동력의 공명 파장과 시전자의 정신력을 조심스럽게 동기 조정해, 그 효과를 강화시킵니다.
		염동력으로 쥐고 있는 무기의 경우, 힘과 민첩 능력치 대신 사용하는 의지와 교활함의 비율을 강화시킵니다. (기존 60%% 에서 %d%%)
		마석의 경우, 적을 끌어 당길 확률이 +%d%%만큼 상승합니다.
		보석의 경우, 모든 능력치가 %d 만큼 더 상승합니다.]]):
		format(60+inc, inc, math.ceil(inc/5))
	end,
}
