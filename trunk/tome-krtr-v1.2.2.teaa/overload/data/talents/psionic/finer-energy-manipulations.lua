-- ToME - Tales of Maj'Eyal
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

require "engine.krtrUtils"

newTalent{
	name = "Realign",
	--kr_name = "", --@@ 한글화 필요
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
			game.logSeen(self, "%s is cured!", self.name:capitalize())
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
		return ([[Realign and readjust your body with the power of your mind, curing up to %d detrimental physical effects and healing you for %d life.
		The life healed increases with your Mindpower.]]): --@@ 한글화 필요 #83~84
		format(cure, heal)
	end,
}

newTalent{
	name = "Reshape Weapon/Armour", image = "talents/reshape_weapon.png",
	kr_name = "무기/갑옷 재구성",
	type = {"psionic/finer-energy-manipulations", 2},
	require = psi_cun_req2,
	cooldown = 1,
	psi = 0,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	boost = function(self, t)
		return math.floor(self:combatTalentMindDamage(t, 5, 20))
	end,
	arm_boost = function(self, t)
		return math.floor(self:combatTalentMindDamage(t, 5, 20))
	end,
	fat_red = function(self, t)
		return math.floor(self:combatTalentMindDamage(t, 2, 10))
	end,
	action = function(self, t)
		local d d = self:showInventory("어느 무기나 갑옷을 재구성합니까?", self:getInven("INVEN"),
			function(o)
				return not o.quest and (o.type == "weapon" and o.subtype ~= "mindstar") or (o.type == "armor" and (o.slot == "BODY" or o.slot == "OFFHAND" )) and not o.fully_reshaped --Exclude fully reshaped?
			end
			, function(o, item)
			if o.combat then
				local atk_boost = t.boost(self, t)
				local dam_boost = atk_boost
				if (o.old_atk or 0) < atk_boost or (o.old_dam or 0) < dam_boost then
					if not o.been_reshaped then
						o.orig_atk = (o.combat.atk or 0)
						o.orig_dam = (o.combat.dam or 0)
					elseif o.been_reshaped == true then --Update items affected by older versions of this talent
						o.kr_name = "재구성된 "..(o.kr_name or o.name)
						o.name = o.name:gsub("reshaped ", "", 1)
						o.orig_atk = o.combat.atk - (o.old_atk or 0)
						o.orig_dam = o.combat.dam - (o.old_dam or 0)
					end
					o.combat.atk = o.orig_atk + atk_boost
					o.combat.dam = o.orig_dam + dam_boost
					o.old_atk = atk_boost
					o.old_dam = dam_boost
					game.logPlayer(self, "%s의 재구성이 성공하였습니다.", o:getName{do_colour=true, no_count=true}:capitalize())
					o.special = true
					o.been_reshaped = "reshaped("..tostring(atk_boost)..","..tostring(dam_boost)..") "
					d.used_talent = true
				else
					game.logPlayer(self, "%s 더 이상 재구성할 수 없습니다.", o:getName{do_colour=true, no_count=true}:capitalize():addJosa("는"))
				end
			else
				local armour = t.arm_boost(self, t)
				local fat = t.fat_red(self, t)
				if (o.old_fat or 0) < fat or o.wielder.combat_armor < (o.orig_arm or 0) + armour then
					o.wielder = o.wielder or {}
					if not o.been_reshaped then
						o.orig_arm = (o.wielder.combat_armor or 0)
						o.orig_fat = (o.wielder.fatigue or 0)
					end
					o.wielder.combat_armor = o.orig_arm
					o.wielder.fatigue = o.orig_fat
					o.wielder.combat_armor = (o.wielder.combat_armor or 0) + armour
					o.wielder.fatigue = (o.wielder.fatigue or 0) - fat
					if o.wielder.fatigue < 0 and not (o.orig_fat < 0) then
						o.wielder.fatigue = 0
					elseif o.wielder.fatigue < 0 and o.orig_fat < 0 then
						o.wielder.fatigue = o.orig_fat
					end
					o.old_fat = fat
					game.logPlayer(self, "%s의 재구성이 성공하였습니다.", o:getName{do_colour=true, no_count=true}:capitalize())
					o.special = true
					if o.orig_name then o.name = o.orig_name end --Fix name for items affected by older versions of this talent
					o.been_reshaped = "reshaped["..tostring(armour)..","..tostring(o.wielder.fatigue-o.orig_fat).."%] "
					d.used_talent = true
				else
					game.logPlayer(self, "%s 더 이상 재구성할 수 없습니다.", o:getName{do_colour=true, no_count=true}:capitalize():addJosa("는"))
				end
			end
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local weapon_boost = t.boost(self, t)
		local arm = t.arm_boost(self, t)
		local fat = t.fat_red(self, t)
		return ([[무기나 갑옷 또는 방패를 원자 레벨에서부터 재구성합니다. (Mindstars resist being adjusted because they are already in an ideal natural state.)
		무기를 선택하면 정확도와 피해량이 영구적으로 %d 상승합니다. 갑옷이나 방패를 선택하면 방어도가 영구적으로 %d 상승하고, 피로도가 영구적으로 %d 감소합니다.
		변화량은 정신력의 영향을 받아 증가합니다.]]): --@@ 한글화 필요 #176
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
		local d d = self:showInventory("어느 보석을 사용합니까?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.material_level and not gem.unique end, function(gem, gem_item)
			self:removeObject(self:getInven("INVEN"), gem_item)
			local amt = t.energy_per_turn(self, t)
			local dur = 3 + 2*(gem.material_level or 0)
			self:setEffect(self.EFF_PSI_REGEN, dur, {power=amt})
			self.changed = true
			d.used_talent = true
			local gem_names = {
				GEM_DIAMOND = "Diamond",
				GEM_PEARL = "Pearl",
				GEM_MOONSTONE = "Moonstone", 
				GEM_FIRE_OPAL = "Fire Opal",
				GEM_BLOODSTONE = "Bloodstone",
				GEM_RUBY = "Ruby",
				GEM_AMBER = "Amber",
				GEM_TURQUOISE = "Turquoise",
				GEM_JADE = "Jade",
				GEM_SAPPHIRE = "Sapphire",
				GEM_QUARTZ = "Quartz",
				GEM_EMERALD = "Emerald",
				GEM_LAPIS_LAZULI = "Lapis Lazuli",
				GEM_GARNET = "Garnet",
				GEM_ONYX = "Onyx",
				GEM_AMETHYST = "Amethyst", 
				GEM_OPAL = "Opal", 
				GEM_TOPAZ = "Topaz",
				GEM_AQUAMARINE = "Aquamarine",
				GEM_AMETRINE = "Ametrine",
				GEM_ZIRCON = "Zircon",
				GEM_SPINEL = "Spinel",
				GEM_CITRINE = "Citrine",
				GEM_AGATE = "Agate",
			}
			self:setEffect(self.EFF_CRYSTAL_BUFF, dur, {name=gem_names[gem.define_as], gem=gem.define_as})
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local amt = t.energy_per_turn(self, t)
		return ([[위대한 정신 파괴자의 말에 의하면, '모든 물체는 에너지의 근원이다' 고 합니다. 
		하지만 불행하게도, 대부분의 물체들은 너무나 복잡한 구성 방식을 가지고 있어서 에너지로 활용할 수 없습니다. 
		관리가 된 보석의 결정 구조는 단순한 편이라서 약간이나마 에너지를 추출해낼 수 있습니다.
		이 기술은 보석을 하나 소모하여, 5 - 13 턴 동안 매 턴마다 %d 염력을 추가로 회복합니다.
		수준 높은 보석일수록, 더 오랫동안 염력을 회복시켜줍니다. 
		This process also creates a resonance field that provides the (imbued) effects of the gem to you while this effect lasts.]]): --@@ 한글화 필요
		format(amt)
	end,
}

newTalent{
	name = "Resonant Focus",
	--kr_name = "", --@@ 한글화 필요
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
		return ([[By carefully synchronizing your mind to the resonant frequencies of your psionic focus, you strengthen its effects.
		For conventional weapons, this increases the percentage of your willpower and cunning that is used in place of strength and dexterity, from 80%% to %d%%.
		For mindstars, this increases the chance to pull enemies to you by +%d%%.
		For gems, this increases the bonus stats by %d.]]): --@@ 한글화 필요 #270~273
		format(80+inc, inc, math.ceil(inc/5))
	end,
}
