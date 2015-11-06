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

require "engine.krtrUtils"
local Map = require "engine.Map"

newTalent{
	name = "Dirty Fighting",
	kr_name = "비열한 전투",
	type = {"cunning/dirty", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 10,
	tactical = { DISABLE = {stun = 2}, ATTACK = {weapon = 0.5} },
	require = cuns_req1,
	requires_target = true,
	range = 1,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.7) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	speed = "weapon",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatAttack()})
			end
			if not target:hasEffect(target.EFF_STUNNED) then
				self:logCombat(target, "#Target1# 기절하지 않았고, #Source2# 재빨리 자세를 잡았습니다!")
				self.energy.value = self.energy.value + game.energy_to_act * self:getSpeed("weapon")
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[대상에게 %d%% 피해를 주고, 공격이 성공했을 경우 대상을 %d 턴 동안 기절시킵니다.
		기절 확률은 정확도 능력치의 영향을 받아 증가합니다.
		공격에 성공했지만 적을 기절시키지는 못했다면, 자세를 빠르게 복구하여 턴 소모를 하지 않게 됩니다.]]):
		format(100 * damage, duration)
	end,
}

newTalent{
	name = "Backstab",
	kr_name = "뒤치기",
	type = {"cunning/dirty", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	-- called by _M:physicalCrit in mod.class.interface.Combat.la
	getCriticalChance = function(self, t) return self:combatTalentScale(t, 15, 50, 0.75) end,
	-- called by _M:attackTargetWith in mod.class.interface.Combat.lua
	getStunChance = function(self, t) return self:combatTalentLimit(t, 100, 3, 15) end, -- Limit < 100%
	info = function(self, t)
		return ([[빠른 손재간을 이용하여, 기절한 대상에게 큰 피해를 줍니다. 기절한 대상에게 치명타를 발생시킬 확률이 %d%% 증가합니다.
		또한, 일반적인 근접 치명타 공격이 %d%% 확률로 대상을 3 턴 동안 기절시키게 됩니다.]]):
		format(t.getCriticalChance(self, t), t.getStunChance(self, t))
	end,
}
newTalent{
	name = "Switch Place",
	kr_name = "자리 바꾸기",
	type = {"cunning/dirty", 3},
	points = 5,
	random_ego = "defensive",
	cooldown = 10,
	stamina = 15,
	require = cuns_req3,
	requires_target = true,
	tactical = { DISABLE = 2 },
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	speed = "weapon",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local tx, ty, sx, sy = target.x, target.y, self.x, self.y
		local hitted = self:attackTarget(target, nil, 0, true)

		if hitted and not self.dead and tx == target.x and ty == target.y then
			if not self:canMove(tx,ty,true) or not target:canMove(sx,sy,true) then
				self:logCombat(target, "지형 때문에 #Source2# #Target6# 자리 바꾸기를 할 수 없습니다.") 
				return true
			end
			self:setEffect(self.EFF_EVASION, t.getDuration(self, t), {chance=50})
			-- Displace
			if not target.dead then
				self:move(tx, ty, true)
				target:move(sx, sy, true)
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[각종 기술과 움직임을 이용하여, 대상과 자리를 바꿉니다.
		자리를 바꾸면 적들이 당황하여, %d 턴 동안 50%% 확률로 모든 근접 공격을 회피할 수 있게 됩니다.
		대상과 자리를 바꾸기 위해서는, 자신의 무기를 대상에게 닿게 할 필요가 있습니다. 때문에 우선 공격이 명중해야 기술의 효과가 발동되며, 이를 통해 무기 피해를 줄 수는 없지만 무기의 공격시 효과는 발동시킬 수 있습니다.]]):
		format(duration)
	end,
}

newTalent{
	name = "Cripple",
	kr_name = "무력화",
	type = {"cunning/dirty", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	stamina = 20,
	require = cuns_req4,
	requires_target = true,
	tactical = { DISABLE = 2, ATTACK = {weapon = 2} },
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.9) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getSpeedPenalty = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "cun", 5, 50), 100, 20, 0, 55.7, 35.7) end, -- Limit < 100%
	speed = "weapon",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			local speed = t.getSpeedPenalty(self, t) / 100
			target:setEffect(target.EFF_CRIPPLE, t.getDuration(self, t), {speed=speed, apply_power=self:combatAttack()})
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local speedpen = t.getSpeedPenalty(self, t)
		return ([[대상을 공격하여, %d%% 피해를 줍니다. 공격이 명중하면 대상은 %d 턴 동안 무력화 상태가 되어 공격속도, 시전속도, 사고속도가 %d%% 줄어들게 됩니다.
		무력화 확률은 정확도 능력치의 영향을 받아 증가하며, 무력화의 위력은 교활함 능력치의 영향을 받아 증가합니다.]]):
		format(100 * damage, duration, speedpen)
	end,
}
