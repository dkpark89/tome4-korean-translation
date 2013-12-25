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

getRelentless = function(self, cd)
	local cd = 1
	if self:knowTalent(self.T_RELENTLESS_STRIKES) then
		local t = self:getTalentFromId(self.T_RELENTLESS_STRIKES)
		cd = 1 - t.getCooldownReduction(self, t)
	end
		return cd
	end,

newTalent{
	name = "Striking Stance",
	kr_name = "타격 자세",
	type = {"technique/unarmed-other", 1},
	mode = "sustained",
	hide = true,
	points = 1,
	cooldown = 12,
	tactical = { BUFF = 2 },
	type_no_req = true,
	no_npc_use = true, -- They dont need it since it auto switches anyway
	no_unlearn_last = true,
	getAttack = function(self, t) return self:getDex(25, true) end,
	getDamage = function(self, t) return self:combatStatScale("dex", 5, 50) end,
	activate = function(self, t)
		cancelStances(self)
		local ret = {
			atk = self:addTemporaryValue("combat_atk", t.getAttack(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		local attack = t.getAttack(self, t)
		local damage = t.getDamage(self, t)
		return ([[타격 자세를 취해 정확도를 %d 올리고, 모든 타격계 기술과 마무리 기술의 최종 피해량을 %d%% 증가시킵니다.
		정확도와 피해량 상승은 민첩성 능력치의 영향을 받아 증가합니다.]]):
		format(attack, damage)
	end,
}

newTalent{
	name = "Double Strike",  -- no stamina cost attack that will replace the bump attack under certain conditions
	kr_name = "2연격",
	type = {"technique/pugilism", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.ceil(3 * getRelentless(self, cd)) end,
	message = "@Source1@ 빠르게 두 번의 주먹을 날립니다.",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.1, 0.8) + getStrikingStyle(self, dam) end,
	-- Learn the appropriate stance
	on_learn = function(self, t)
		if not self:knowTalent(self.T_STRIKING_STANCE) then
			self:learnTalent(self.T_STRIKING_STANCE, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_STRIKING_STANCE)
		end
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- force stance change
		if target and not self:isTalentActive(self.T_STRIKING_STANCE) then
			self:forceUseTalent(self.T_STRIKING_STANCE, {ignore_energy=true, ignore_cd = true})
		end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit1 = false
		local hit2 = false

		hit1 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		hit2 = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- build combo points
		local combo = false

		if self:getTalentLevel(t) >= 4 then
			combo = true
		end

		if combo then
			if hit1 then
				self:buildCombo()
			end
			if hit2 then
				self:buildCombo()
			end
		elseif hit1 or hit2 then
			self:buildCombo()
		end

		return true

	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[빠르게 두 번의 주먹을 날려 각각 %d%% 의 피해를 주고, 즉시 타격 자세로 전환합니다.
		이미 타격 자세를 취하고 있으며 2연격 기술이 사용 가능하다면, 일반 공격 대신 자동적으로 2연격 기술을 사용합니다. 이 때 2연격 기술의 지연 시간은 일반적으로 기술을 사용했을 때와 같습니다.
		한 번 이상 공격에 성공하면, 연계 점수를 1 획득합니다. 만약 기술 레벨이 4 이상이고 두 번의 공격이 모두 성공한다면, 연계 점수를 2 획득할 수 있습니다.]])
		:format(damage)
	end,
}

newTalent{
	name = "Relentless Strikes",
	kr_name = "가차없는 공격",
	type = {"technique/pugilism", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "utility",
	mode = "passive",
	getStamina = function(self, t) return self:combatTalentScale(t, 1/4, 5/4, 0.75) end,
	getCooldownReduction = function(self, t) return self:combatTalentLimit(t, 0.67, 0.09, 1/3) end,  -- Limit < 67%
	info = function(self, t)
		local stamina = t.getStamina(self, t)
		local cooldown = t.getCooldownReduction(self, t)
		return ([[모든 타격계 기술의 지연 시간을 %d%% 줄입니다. 그리고, 연계 점수를 1 획득할 때마다 체력을 %0.2f 회복할 수 있게 됩니다.
		만약 현재 체력이 부족해 어떤 기술을 사용할 수 없더라도, 이 기술을 통해 어떤 기술을 사용할 수 있을만큼 체력을 확보할 수 있다면 그 기술을 사용할 수 있습니다.]])
		:format(cooldown * 100, stamina)
	end,
}

newTalent{
	name = "Spinning Backhand",
	kr_name = "회전 손등치기",
	type = {"technique/pugilism", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.ceil(12 * getRelentless(self, cd)) end,
	stamina = 12,
	range = function(self, t) return math.ceil(self:combatTalentScale(t, 2.2, 4.3)) end,
	chargeBonus = function(self, t, dist) return self:combatScale(dist, 0.15, 1, 0.50, 5) end,
	message = "@Source1@ 회전하며 적을 손등으로 쳤습니다.",
	tactical = { ATTACKAREA = { weapon = 2 }, CLOSEIN = 1 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.7) + getStrikingStyle(self, dam) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		-- bonus damage for charging
		local charge = t.chargeBonus(self, t, (core.fov.distance(self.x, self.y, x, y) - 1))
		local damage = t.getDamage(self, t) + charge

		-- do the rush
		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local l = self:lineFOV(x, y, block_actor)
		local lx, ly, is_corner_blocked = l:step()
		local tx, ty = self.x, self.y
		while lx and ly do
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
		end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end

		local hit1 = false
		local hit2 = false
		local hit3 = false

		-- do the backhand
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			-- get left and right side
			local dir = util.getDir(x, y, self.x, self.y)
			local lx, ly = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
			local rx, ry = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
			local lt, rt = game.level.map(lx, ly, Map.ACTOR), game.level.map(rx, ry, Map.ACTOR)

			hit1 = self:attackTarget(target, nil, damage, true)

			--left hit
			if lt then
				hit2 = self:attackTarget(lt, nil, damage, true)
			end
			--right hit
			if rt then
				hit3 = self:attackTarget(rt, nil, damage, true)
			end

		end

		-- remove grappls
		self:breakGrapples()

		-- build combo points
		local combo = false

		if self:getTalentLevel(t) >= 4 then
			combo = true
		end

		if combo then
			if hit1 then
				self:buildCombo()
			end
			if hit2 then
				self:buildCombo()
			end
			if hit3 then
				self:buildCombo()
			end
		elseif hit1 or hit2 or hit3 then
			self:buildCombo()
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local charge =t.chargeBonus(self, t, t.range(self, t)-1)*100
		return ([[회전하면서 대상과 근처에 있는 적들을 손등으로 공격해, %d%% 의 피해를 줍니다. 무언가를 붙잡고 있을 때 이 기술을 사용하면, 붙잡기가 풀립니다.
		만약 대상과 떨어져 있다면 회전하면서 대상에게 접근하며, 이 때 이동한 거리 1 칸마다 %d%% 의 추가 피해를 입힙니다.
		이 기술을 통해 연계 점수를 1 획득할 수 있습니다. 만약 기술 레벨이 4 이상이라면, 타격에 성공한 횟수만큼 연계 점수를 획득할 수 있습니다.]])
		:format(damage, charge)
	end,
}

newTalent{
	name = "Flurry of Fists",
	kr_name = "질풍격",
	type = {"technique/pugilism", 4},
	require = techs_dex_req4,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return math.ceil(24 * getRelentless(self, cd)) end,
	stamina = 15,
	message = "@Source1@ 질풍격을 쏟아붓습니다.",
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.1) + getStrikingStyle(self, dam) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		local hit1 = false
		local hit2 = false
		local hit3 = false

		hit1 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		hit2 = self:attackTarget(target, nil, t.getDamage(self, t), true)
		hit3 = self:attackTarget(target, nil, t.getDamage(self, t), true)

		--build combo points
		local combo = false

		if self:getTalentLevel(t) >= 4 then
			combo = true
		end

		if combo then
			if hit1 then
				self:buildCombo()
			end
			if hit2 then
				self:buildCombo()
			end
			if hit3 then
				self:buildCombo()
			end
		elseif hit1 or hit2 or hit3 then
			self:buildCombo()
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[아주 빠르게 세 번의 주먹을 날려, 각각 %d%% 의 피해를 줍니다.
		이 기술을 통해 1의 연계 점수를 획득할 수 있습니다. 만약 기술 레벨이 4 이상이라면, 타격에 성공한 횟수만큼 연계 점수를 획득할 수 있습니다.]])
		:format(damage)
	end,
}

