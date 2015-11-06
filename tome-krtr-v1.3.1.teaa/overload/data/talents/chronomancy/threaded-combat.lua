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

-- EDGE TODO: Particles, Timed Effect Particles

newTalent{
	name = "Thread Walk",
	kr_name = "흐름 걷기",
	type = {"chronomancy/threaded-combat", 1},
	require = chrono_req_high1,
	points = 5,
	cooldown = 10,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { ATTACK = {weapon = 2}, CLOSEIN = 2, ESCAPE = 2 },
	requires_target = true,
	is_teleport = true,
	range = function(self, t)
		if self:hasArcheryWeapon("bow") then return util.getval(archery_range, self, t) end
		return 1
	end,
	is_melee = function(self, t) return not self:hasArcheryWeapon("bow") end,
	speed = function(self, t) return self:hasArcheryWeapon("bow") and "archery" or "weapon" end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDefense = function(self, t) return self:combatTalentStatDamage(t, "mag", 10, 25) end,
	getResist = function(self, t) return self:combatTalentStatDamage(t, "mag", 5, 15) end,
	on_pre_use = function(self, t, silent) if self:attr("disarmed") then if not silent then game.logPlayer(self, "이 기술을 사용하기 위해서는 무기가 필요합니다.") end return false end return true end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "defense_on_teleport", t.getDefense(self, t))
		self:talentTemporaryValue(p, "resist_all_on_teleport", t.getResist(self, t))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_MAG then
			self:updateTalentPassives(t)
		end
	end,
	archery_onreach = function(self, t, x, y)
		game:onTickEnd(function()
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			game:playSoundNear(self, "talents/teleport")
			
			if self:teleportRandom(x, y, 0) then
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			else
				game.logSeen(self, "마법이 실패하였습니다!")
			end
		end)
	end,
	action = function(self, t)
		local mainhand, offhand = self:hasDualWeapon()

		if self:hasArcheryWeapon("bow") then
			-- Ranged attack
			local targets = self:archeryAcquireTargets({type="bolt"}, {one_shot=true, no_energy = true})
			if not targets then return end
			self:archeryShoot(targets, t, {type="bolt"}, {mult=t.getDamage(self, t)})
		elseif mainhand then
			-- Melee attack
			local tg = {type="hit", range=self:getTalentRange(t), talent=t}
			local _, x, y = self:canProject(tg, self:getTarget(tg))
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if not target then return nil end
			
			self:attackTarget(target, nil, t.getDamage(self, t), true)
			
			-- Find a good spot to shoot from
			local range = 5
			local weapon = self:hasArcheryWeaponQS()
			if weapon then range = weapon.combat.range end
			local poss = {}
			game.logPlayer(self, "사정거리 %d", range)
			for i = x - range, x + range do
				for j = y - range, y + range do
					if game.level.map:isBound(i, j) and
						core.fov.distance(x, y, i, j) <= range and -- make sure they're within arrow range
						core.fov.distance(i, j, self.x, self.y) >= range/2 and
						self:canMove(i, j) and target:hasLOS(i, j) then
						poss[#poss+1] = {i,j}
					end
				end
			end
			if #poss == 0 then return game.logSeen(self, "주문이 실패하였습니다!") end
			local pos = poss[rng.range(1, #poss)]
			x, y = pos[1], pos[2]
			
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			game:playSoundNear(self, "talents/teleport")
			
			if self:teleportRandom(x, y, 0) then
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			else
				game.logSeen(self, "주문이 실패하였습니다!")
			end
			
			
			-- This teleports the target straight back.  Should probably copy this function someplace fun so we can use it for other stuff
			-- Find our teleport location
			--[[local dist = 10 / core.fov.distance(x, y, self.x, self.y)
			local destx, desty = math.floor((self.x - x) * dist + x), math.floor((self.y - y) * dist + y)
			local l = core.fov.line(x, y, destx, desty, false)
			local lx, ly, is_corner_blocked = l:step()
			local ox, oy
			
			while game.level.map:isBound(lx, ly) and not game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") and not is_corner_blocked do
				if not game.level.map(lx, ly, Map.ACTOR) then ox, oy = lx, ly end
				lx, ly, is_corner_blocked = l:step()
			end
			
			game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			game:playSoundNear(self, "talents/teleport")
			
			-- ox, oy now contain the last square in line not blocked by actors.
			if ox and oy then 
				self:teleportRandom(ox, oy, 0)
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			end]]

		else
			game.logPlayer(self, "당신은 합당한 무기 없이는 이 기술을 사용할 수 없습니다!")
			return nil
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local defense = t.getDefense(self, t)
		local resist = t.getResist(self, t)
		return ([[당신의 쌍수무기나 활로 %d%% 의 무기 피해를 입힙니다. 만약 당신이 화살을 쏘았다면 당신은 목표의 근처로 순간이동 할 것입니다. 만약 당신이 쌍수무기로 공격했다면, 당신은 활의 사정거리 내로 순간이동 할 것입니다.
		또한 당신은 이제 어떠한 순간이동 후에도 위상에서 벗어남 효과를 다섯 턴 동안 가지게 됩니다. 이 효과는 %d 의 회피율과 %d%% 만큼의 모든 속성 저항력을 추가합니다.
		위상에서 벗어남 효과는 당신의 마법 능력치에 비례하여 상승합니다.]])
		:format(damage, defense, resist)
	end
}

newTalent{
	name = "Blended Threads",
	kr_name = "뒤섞인 흐름",
	type = {"chronomancy/threaded-combat", 2},
	require = chrono_req_high2,
	mode = "passive",
	points = 5,
	getCount = function(self, t) return math.ceil(self:getTalentLevel(t))end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		if hitted then
			if self.turn_procs.blended_threads and self.turn_procs.blended_threads >= t.getCount(self, t) then return end
			
			-- Refresh talent
			local tids = {}
			for tid, _ in pairs(self.talents_cd) do
				local tt = self:getTalentFromId(tid)
				if tt.type[1]:find("^chronomancy/blade") and not tt.fixed_cooldown then
					tids[#tids+1] = tt
				end
			end

			if #tids > 0 then
				local tid = rng.tableRemove(tids)
				self:alterTalentCoolingdown(tid, - 1)
				self.turn_procs.blended_threads = (self.turn_procs.blended_threads or 0) + 1
			end
			
		end
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		if hitted then
			if self.turn_procs.blended_threads and self.turn_procs.blended_threads >= t.getCount(self, t) then return end
			
			-- Refresh talent
			local tids = {}
			for tid, _ in pairs(self.talents_cd) do
				local tt = self:getTalentFromId(tid)
				if tt.type[1]:find("^chronomancy/bow") and not tt.fixed_cooldown then
					tids[#tids+1] = tt
				end
			end

			if #tids > 0 then
				local tid = rng.tableRemove(tids)
				self:alterTalentCoolingdown(tid, - 1)
				self.turn_procs.blended_threads = (self.turn_procs.blended_threads or 0) + 1
			end
			
		end
	end,
	info = function(self, t)
		local count = t.getCount(self, t)
		return ([[당신이 화살을 맞출 때마다 검의 흐름 계열의 기술 중 하나의 재사용 대기 시간이 한 턴 줄어듭니다.
		당신이 근접무기를 맞출 때마다 활의 흐름 계열의 기술 중 하나의 재사용 대기 시간이 한 턴 줄어듭니다.
		이 효과는 한 턴에 %d 번만 일어날 수 있습니다.]])
		:format(count)
	end
}

newTalent{
	name = "Thread the Needle",
	kr_name = "바늘의 흐름",
	type = {"chronomancy/threaded-combat", 3},
	require = chrono_req_high3,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 18) end,
	tactical = { ATTACKAREA = { weapon = 3 } },
	requires_target = true,
	range = function(self, t)
		if self:hasArcheryWeapon("bow") then return util.getval(archery_range, self, t) end
		return 0
	end,
	is_melee = function(self, t) return not self:hasArcheryWeapon("bow") end,
	speed = function(self, t) return self:hasArcheryWeapon("bow") and "archery" or "weapon" end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 2.2) end,
	on_pre_use = function(self, t, silent) if self:attr("disarmed") then if not silent then game.logPlayer(self, "이 기술을 사용하기 위해서는 무기가 필요합니다.") end return false end return true end,
	target = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t)}
		if not self:hasArcheryWeapon("bow") then
			tg = {type="ball", radius=1, range=self:getTalentRange(t)}
		end
		return tg
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local damage = t.getDamage(self, t)
		local mainhand, offhand = self:hasDualWeapon()

		if self:hasArcheryWeapon("bow") then
			-- Ranged attack
			local targets = self:archeryAcquireTargets(tg, {one_shot=true, no_energy = true})
			if not targets then return end
			self:archeryShoot(targets, t, tg, {mult=dam})
		elseif mainhand then
			-- Melee attack
			self:project(tg, self.x, self.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= self then
					self:attackTarget(target, nil, dam, true)
				end
			end)
			self:addParticles(Particles.new("meleestorm2", 1, {}))
		else
			game.logPlayer(self, "당신은 합당한 무기 없이 이 기술을 사용 할 수 없습니다!")
			return nil
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[당신의 활이나 쌍수무기로 %d%% 의 무기 피해를 입힙니다. 만약 당신이 활을 쏘았다면 당신은 일직선의 모든 목표를 타격할 것입니다. 만약 당신이 쌍수무기를 휘둘렀다면 당신은 당신의 주변 한 칸에 있는 모든 적들을 공격 할 것입니다.]])
		:format(damage)
	end
}

newTalent{
	name = "Warden's Call", short_name = WARDEN_S_CALL,
	kr_name = "감시자의 부름",
	type = {"chronomancy/threaded-combat", 4},
	require = chrono_req_high4,
	mode = "passive",
	points = 5,
	remove_on_clone = true,
	getDamagePenalty = function(self, t) return 100 - self:combatTalentLimit(t, 80, 10, 60) end,
	findTarget = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local target_type = Map.ACTOR
			local a = game.level.map(x, y, Map.ACTOR)
			if a and not a.dead and self:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
				tgts[#tgts+1] = a
			end
		end end
		
		return tgts
	end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		if hitted then
			if self.turn_procs.wardens_call then
				return
			else
				self.turn_procs.wardens_call = true
			end
			
			-- Make our clone
			local m = makeParadoxClone(self, self, 0)
			m.generic_damage_penalty = (m.generic_damage_penalty or 0) + t.getDamagePenalty(self, t)
			doWardenWeaponSwap(m, t, "blade")
			m.on_added_to_level = function(self)
				if not self.blended_target.dead then
					self:forceUseTalent(self.T_ATTACK, {ignore_cd=true, ignore_energy=true, force_target=self.blended_target, ignore_ressources=true, silent=true})
				end
				self:die()
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			end
			
			-- Check Focus first
			local wf = checkWardenFocus(self)
			if wf and not wf.dead then
				local tx, ty = util.findFreeGrid(wf.x, wf.y, 1, true, {[Map.ACTOR]=true})
				if tx and ty then
					m.blended_target = wf
					game.zone:addEntity(game.level, m, "actor", tx, ty)
				end
			end
			if not m.blended_target then
				local tgts= t.findTarget(self, t)
				local attempts = 5
				while #tgts > 0 and attempts > 0 do
					local a, id = rng.tableRemove(tgts)
					-- look for space
					local tx, ty = util.findFreeGrid(a.x, a.y, 1, true, {[Map.ACTOR]=true})
					if tx and ty then	
						m.blended_target = a				
						game.zone:addEntity(game.level, m, "actor", tx, ty)
						break
					else
						attempts = attempts - 1
					end
				end
			end
		end
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted)
		if hitted then
			if self.turn_procs.wardens_call then
				return
			else
				self.turn_procs.wardens_call = true
			end

			-- Make our clone
			local m = makeParadoxClone(self, self, 0)
			m.generic_damage_penalty = (m.generic_damage_penalty or 0) + t.getDamagePenalty(self, t)
			m:attr("archery_pass_friendly", 1)
			doWardenWeaponSwap(m, t, "bow")
			m.on_added_to_level = function(self)
				if not self.blended_target.dead then
					local targets = self:archeryAcquireTargets(nil, {one_shot=true, x=self.blended_target.x, y=self.blended_target.y, no_energy = true})
					if targets then
						self:forceUseTalent(self.T_SHOOT, {ignore_cd=true, ignore_energy=true, force_target=self.blended_target, ignore_ressources=true, silent=true})
					end
				end
				self:die()
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
			end
			
			-- Find a good location for our shot
			local function find_space(self, target, clone)
				local poss = {}
				local range = util.getval(archery_range, clone, t)
				local x, y = target.x, target.y
				for i = x - range, x + range do
					for j = y - range, y + range do
						if game.level.map:isBound(i, j) and
							core.fov.distance(x, y, i, j) <= range and -- make sure they're within arrow range
							core.fov.distance(i, j, self.x, self.y) <= range/2 and -- try to place them close to the caster so enemies dodge less
							self:canMove(i, j) and target:hasLOS(i, j) then
							poss[#poss+1] = {i,j}
						end
					end
				end
				if #poss == 0 then return end
				local pos = poss[rng.range(1, #poss)]
				x, y = pos[1], pos[2]
				return x, y
			end
			
			-- Check Focus first
			local wf = checkWardenFocus(self)
			if wf and not wf.dead then
				local tx, ty = find_space(self, target, m)
				if tx and ty then
					m.blended_target = wf
					game.zone:addEntity(game.level, m, "actor", tx, ty)
				end
			else
				local tgts = t.findTarget(self, t)
				if #tgts > 0 then
					local a, id = rng.tableRemove(tgts)
					local tx, ty = find_space(self, target, m)
					if tx and ty then
						m.blended_target = a
						game.zone:addEntity(game.level, m, "actor", tx, ty)
					end
				end
			end
		end
	end,
	info = function(self, t)
		local damage_penalty = t.getDamagePenalty(self, t)
		return ([[당신이 근접이나 화살로 공격을 맞추었을 때에, 적당한 공간이 있다면, 감시자가 다른 시간선으로 부터 나타날 수 있습니다. 나타난 감시자는 무작위의 적을 쏘거나 공격합니다.
		감시자들은 이 현실의 위상에서 벗어나 있기 때문에 %d%% 만큼 낮은 피해를 입히지만, 감시자의 화살은 아군을 통과해서 지나갈 것입니다.
		이 효과는 오직 한 턴에 한 번만 일어나며, 감시자들은 공격한 후에 그들의 시간선으로 되돌아갑니다.]])
		:format(damage_penalty)
	end
}
