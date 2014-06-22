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

require "engine.krtrUtils"

newTalent{
	name = "Stunning Blow", short_name = "STUNNING_BLOW_ASSAULT", image = "talents/stunning_blow.png",
	kr_name = "기절시키기",
	type = {"technique/2hweapon-assault", 1},
	require = techs_req1,
	points = 5,
	cooldown = 6,
	stamina = 8,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상의 머리를 무기로 내리쳐서 %d%% 의 무기 피해를 주고, 공격에 성공하면 %d 턴 동안 기절시킵니다.
		기절 확률은 물리력의 영향을 받아 증가합니다.]])
		:format(100 * self:combatTalentWeaponDamage(t, 1, 1.5), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Fearless Cleave",
	kr_name = "대담한 가로베기",
	type = {"technique/2hweapon-assault", 2},
	require = techs_req2,
	points = 5,
	cooldown = 0,
	stamina = 16,
	no_energy = "fake",
	tactical = { ATTACK = { weapon = 2 }, CLOSEIN = 0.5 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 1.8) end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = {type="hit", range=self:getTalentRange(t), simple_dir_request=true}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dir = util.getDir(x, y, self.x, self.y) or 6
		local moved = 0.5
		if self:canMove(x, y) then
			self:move(x, y)
			moved = 1
		else
			self:useEnergy(game.energy_to_act)
		end

		local fx, fy = util.coordAddDir(self.x, self.y, dir)
		local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
		local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
		local target, lt, rt = game.level.map(fx, fy, Map.ACTOR), game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

		local damage = t.getDamage(self, t) * moved
		if target then self:attackTargetWith(target, weapon.combat, nil, damage) end
		if lt then     self:attackTargetWith(lt, weapon.combat, nil, damage) end
		if rt then     self:attackTargetWith(rt, weapon.combat, nil, damage) end

		return true
	end,
	info = function(self, t)
	local damage = t.getDamage(self, t) * 100
	local movedamage = t.getDamage(self, t) * 0.5 * 100
		return ([[한 칸 앞으로 전진하며, 그 탄력을 통해 전방의 적 3 명을 %d%% 무기 피해로 가로벱니다.
		전진하지 못했을 경우, %d%% 무기 피해만을 입힙니다.]])
		:format(damage, movedamage)
	end,
}

newTalent{
	name = "Death Dance", short_name = "DEATH_DANCE_ASSAULT", image = "talents/death_dance.png",
	kr_name = "죽음의 춤",
	type = {"technique/2hweapon-assault", 3},
	require = techs_req3,
	points = 5,
	cooldown = 10,
	stamina = 30,
	tactical = { ATTACKAREA = { weapon = 3 } },
	range = 0,
	radius = 1,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	getBleed = function(self, t) return self:combatTalentScale(t, 0.3, 1) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다!")
			return nil
		end

		local scale = nil
		if self:getTalentLevel(t) >= 3 then
			scale = t.getBleed(self, t)
		end

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local oldlife = target.life
				self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.4, 2.1))
				local life_diff = oldlife - target.life
				if life_diff > 0 and target:canBe('cut') and scale then
					target:setEffect(target.EFF_CUT, 5, {power=life_diff * scale / 5, src=self, apply_power=self:combatPhysicalpower()})
				end
			end
		end)

		self:addParticles(Particles.new("meleestorm", 1, {}))

		return true
	end,
	info = function(self, t)
		return ([[한바퀴 돌면서, 주변 1 칸 반경의 모두에게 %d%% 의 무기 피해를 입힙니다.
		기술 레벨이 3 이상일 경우, 공격이 출혈을 일으켜 5 턴에 걸쳐 %d%% 피해를 추가로 가합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1.4, 2.1), t.getBleed(self, t) * 100)
	end,
}

newTalent{
	name = "Execution",
	kr_name = "처형",
	type = {"technique/2hweapon-assault", 4},
	require = techs_req4,
	points = 5,
	cooldown = 8,
	stamina = 25,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 } },
	getPower = function(self, t) return self:combatTalentScale(t, 1.0, 2.5, "log") end, -- +125% bonus against 50% damaged foe at talent level 5.0
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then return nil end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local perc = 1 - (target.life / target.max_life)
		local power = t.getPower(self, t)
--		game.logPlayer(self, "perc " .. perc .. " power " .. power) -- debugging code
		self.turn_procs.auto_phys_crit = true
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, 1 + power * perc)
		self.turn_procs.auto_phys_crit = nil
		return true
	end,
	info = function(self, t)
		return ([[이미 부상당한 적에게 최적의 효과를 발휘하는 기술입니다. 반드시 치명타로 적중하며, 대상의 현재 생명력이 최대 생명력보다 1%% 낮을 때마다 %0.1f%% 만큼 추가 무기 피해를 입힙니다.
		(예를 들어 적의 생명력이 30%% 남았을 경우 (70%% 감소했을 경우), %0.1f%% 무기 피해를 가할 수 있게 됩니다)]]):
		format(t.getPower(self, t), 100 + t.getPower(self, t) * 70)
	end,
}
