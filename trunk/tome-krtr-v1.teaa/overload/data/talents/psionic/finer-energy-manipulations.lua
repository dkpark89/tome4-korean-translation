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
	name = "Perfect Control",
	kr_display_name = "완벽한 제어",
	type = {"psionic/finer-energy-manipulations", 1},
	require = psi_cun_high1,
	cooldown = 50,
	psi = 15,
	points = 5,
	tactical = { BUFF = 2 },
	getBoost = function(self, t)
		return 15 + math.ceil(self:getTalentLevel(t)*self:combatStatTalentIntervalDamage(t, "combatMindpower", 1, 9))
	end,
	action = function(self, t)
		self:setEffect(self.EFF_CONTROL, 5 + self:getTalentLevelRaw(t), {power= t.getBoost(self, t)})
		return true
	end,
	info = function(self, t)
		local boost = t.getBoost(self, t)
		local dur = 5 + self:getTalentLevelRaw(t)
		return ([[염력으로 몸을 제어해, 몸의 불필요한 동작을 없애고 가장 효율적인 움직임만을 취할 수 있게 됩니다.
		%d 턴 동안 정확도가 %d / 치명타율이 %0.2f%% 상승합니다.]]):
		format(dur, boost, 0.5*boost)
	end,
}

newTalent{
	name = "Reshape Weapon",
	kr_display_name = "무기 재구성",
	type = {"psionic/finer-energy-manipulations", 2},
	require = psi_cun_high2,
	cooldown = 1,
	psi = 0,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	boost = function(self, t)
		return math.floor(self:combatStatTalentIntervalDamage(t, "combatMindpower", 3, 20))
	end,
	action = function(self, t)
		local d d = self:showInventory("어느 무기를 재구성합니까?", self:getInven("INVEN"), function(o) return not o.quest and o.type == "weapon" and not o.fully_reshaped end, function(o, item)
			--o.wielder = o.wielder or {}
			if (o.old_atk or 0) < t.boost(self, t) then
				o.combat.atk = (o.combat.atk or 0) - (o.old_atk or 0)
				o.combat.dam = (o.combat.dam or 0) - (o.old_dam or 0)
				o.combat.atk = (o.combat.atk or 0) + t.boost(self, t)
				o.combat.dam = (o.combat.dam or 0) + t.boost(self, t)
				o.old_atk = t.boost(self, t)
				o.old_dam = t.boost(self, t)
				game.logPlayer(self, "%s의 재구성이 성공하였습니다.", o:getName{do_colour=true, no_count=true}:capitalize())
				o.special = true
				if not o.been_reshaped then
					o.kr_display_name = "재구성된 "..(o.kr_display_name or o.name)
					o.name = "reshaped" .. " "..o.name..""
					o.been_reshaped = true
				end
				d.used_talent = true
			else
				game.logPlayer(self, "%s 더 이상 재구성할 수 없습니다.", o:getName{do_colour=true, no_count=true}:capitalize():addJosa("는"))
			end
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local weapon_boost = t.boost(self, t)
		return ([[무기를 원자 레벨에서부터 재구성해, 정확도와 피해량을 증가시킵니다. 무기의 정확도와 피해량이 영구적으로 %d 상승합니다.
		상승량은 정신력의 영향을 받아 증가합니다.]]):
		format(weapon_boost)
	end,
}

newTalent{
	name = "Reshape Armour", short_name = "RESHAPE_ARMOR",
	kr_display_name = "갑옷 재구성",
	type = {"psionic/finer-energy-manipulations", 3},
	require = psi_cun_high3,
	cooldown = 1,
	psi = 0,
	points = 5,
	no_npc_use = true,
	no_unlearn_last = true,
	arm_boost = function(self, t)
		local arm_values = {
		0 + self:getWil(2),
		1 + self:getWil(2),
		1 + self:getWil(2),
		2 + self:getWil(2),
		2 + self:getWil(2)
		}
		local index = util.bound(self:getTalentLevelRaw(t), 1, 5)
		return arm_values[index] * (self:getTalentLevel(t) / self:getTalentLevelRaw(t))
	end,
	fat_red = function(self, t)
		local fat_values = {
		1 + self:getWil(3),
		1 + self:getWil(3),
		2 + self:getWil(3),
		2 + self:getWil(3),
		3 + self:getWil(3)
		}
		local index = util.bound(self:getTalentLevelRaw(t), 1, 5)
		return fat_values[index] * (self:getTalentLevel(t) / self:getTalentLevelRaw(t))
	end,
	action = function(self, t)
		local d d = self:showInventory("어느 갑옷을 재구성합니까?", self:getInven("INVEN"), function(o) return not o.quest and o.type == "armor" and not o.fully_reshaped end, function(o, item)
			if (o.old_fat or 0) < t.fat_red(self, t) then
				o.wielder = o.wielder or {}
				if not o.been_reshaped then
					o.orig_arm = (o.wielder.combat_armor or 0)
					o.orig_fat = (o.wielder.fatigue or 0)
				end
				o.wielder.combat_armor = o.orig_arm
				o.wielder.fatigue = o.orig_fat
				o.wielder.combat_armor = (o.wielder.combat_armor or 0) + t.arm_boost(self, t)
				o.wielder.fatigue = (o.wielder.fatigue or 0) - t.fat_red(self, t)
				if o.wielder.fatigue < 0 and not (o.orig_fat < 0) then
					o.wielder.fatigue = 0
				elseif o.wielder.fatigue < 0 and o.orig_fat < 0 then
					o.wielder.fatigue = o.orig_fat
				end
				o.old_fat = t.fat_red(self, t)
				o.special = true
				game.logPlayer(self, "%s의 재구성이 성공하였습니다.", o:getName{do_colour=true, no_count=true}:capitalize())
				if not o.been_reshaped then
					o.kr_display_name = "재구성된 "..(o.kr_display_name or o.name)
					o.name = "reshaped" .. " "..o.name..""
					o.been_reshaped = true
				end
				d.used_talent = true
			else
				game.logPlayer(self, "%s 더 이상 재구성할 수 없습니다.", o:getName{do_colour=true, no_count=true}:capitalize():addJosa("는"))
			end
		end)
		local co = coroutine.running()
		d.unload = function(self) coroutine.resume(co, self.used_talent) end
		if not coroutine.yield() then return nil end
		return true
	end,
	info = function(self, t)
		local arm = t.arm_boost(self, t)
		local fat = t.fat_red(self, t)
		return ([[갑옷을 원자 레벨에서부터 재구성해, 방어도는 증가시키고 피로도는 감소시킵니다. 갑옷의 방어도가 영구적으로 %d 상승하고, 피로도가 영구적으로 %d 감소합니다.
		방어도 상승량과 피로도 감소량은 정신력의 영향을 받아 증가합니다.]]):
		format(arm, fat)
	end,
}

newTalent{
	name = "Matter is Energy",
	kr_display_name = "에너지 추출",
	type = {"psionic/finer-energy-manipulations", 4},
	require = psi_cun_high4,
	cooldown = 50,
	psi = 0,
	points = 5,
	no_npc_use = true,
	energy_per_turn = function(self, t)
		return self:combatStatTalentIntervalDamage(t, "combatMindpower", 10, 40, 0.25)
	end,
	action = function(self, t)
		local d d = self:showInventory("어느 보석을 사용합니까?", self:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.material_level and not gem.unique end, function(gem, gem_item)
			self:removeObject(self:getInven("INVEN"), gem_item)
			local amt = t.energy_per_turn(self, t)
			local dur = 3 + 2*(gem.material_level or 0)
			self:setEffect(self.EFF_PSI_REGEN, dur, {power=amt})
			self.changed = true
			d.used_talent = true
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
		하지만 다행하게도, 보석이나 수정으로 이루어진 물체는 그 구조가 단순한 편이라서 약간이나마 에너지를 추출해낼 수 있습니다.
		보석을 분해하여, 5 - 13 턴 동안 매 턴마다 %d 염력을 추가로 회복합니다. 수준 높은 보석일수록, 더 오랫동안 염력을 회복시켜줍니다.]]):
		format(amt)
	end,
}

