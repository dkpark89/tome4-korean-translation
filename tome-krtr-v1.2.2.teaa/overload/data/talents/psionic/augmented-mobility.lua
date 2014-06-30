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

newTalent{
	name = "Skate",
	kr_name = "스케이트",
	type = {"psionic/augmented-mobility", 1},
	require = psi_wil_req1,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.2, 0.5, 0.75) end,
	getKBVulnerable = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.8) end,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("movement_speed", t.getSpeed(self, t)),
			knockback = self:addTemporaryValue("knockback_immune", -t.getKBVulnerable(self, t))
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("movement_speed", p.speed)
		self:removeTemporaryValue("knockback_immune", p.knockback)
		return true
	end,
	info = function(self, t)
		return ([[염력을 사용해서 지면 위로 살짝 날아오릅니다.
		이를 통해 지면을 미끄러지듯 신속하게 움직일 수 있게 되어, 이동 속도가 %d%% 증가하게 됩니다.
		하지만 날아다니기 때문에, 보다 쉽게 밀려나게 됩니다. (밀어내기 면역력 -%d%%)]]): 
		format(t.getSpeed(self, t)*100, t.getKBVulnerable(self, t)*100) 
	end,
}

newTalent{
	name = "Quick as Thought",
	kr_name = "생각의 속도",
	type = {"psionic/augmented-mobility", 2},
	require = psi_wil_req2,
	points = 5,
	random_ego = "utility",
	cooldown = 20,
	psi = 30,
	no_energy = true,
	getDuration = function(self, t) return math.floor(self:combatLimit(self:combatMindpower(0.1), 10, 4, 0, 6, 6)) end, -- Limit < 10
	speed = function(self, t) return self:combatTalentScale(t, 0.1, 0.6, 0.75) end,
	getBoost = function(self, t)
		return self:combatScale(self:getTalentLevel(t)*self:combatStatTalentIntervalDamage(t, "combatMindpower", 1, 9), 15, 0, 49, 34)
	end,
	action = function(self, t)
		self:setEffect(self.EFF_QUICKNESS, t.getDuration(self, t), {power=t.speed(self, t)})
		self:setEffect(self.EFF_CONTROL, t.getDuration(self, t), {power=t.getBoost(self, t)})
		return true
	end,
	info = function(self, t)
		local inc = t.speed(self, t)
		local percentinc = 100 * inc
		local boost = t.getBoost(self, t)
		return ([[육체를 정신력으로 감싸, 신경과 근육을 통한 비효율적인 운동 방식을 제거하고 몸의 움직임을 극도로 효율적이게 만듭니다. 
		%d 턴 동안 정확도가 %d / 치명타율이 %0.1f%% / 공격 속도가 %d%% 증가합니다.
		기술의 지속 시간은 정신력의 영향을 받아 증가합니다.]]): 
		format(t.getDuration(self, t), boost, 0.5*boost, percentinc) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Telekinetic Leap",
	kr_name = "염동 도약",
	type = {"psionic/augmented-mobility", 3},
	require = psi_wil_req3,
	cooldown = 15,
	psi = 10,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		return self:combatTalentLimit(t, 10, 5, 9) -- Limit < 10
	end,
	action = function(self, t)
		local tg = {default_target=self, type="ball", nolock=true, pass_terrain=false, nowarning=true, range=self:getTalentRange(t), radius=0, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end


		local fx, fy = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)


		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[염동력을 이용해, 최대 %d 칸 까지 도약합니다.]]): 
		format(range)
	end,
}

newTalent{
	name = "Shattering Charge",
	kr_name = "동역학적 돌진",
	type = {"psionic/augmented-mobility", 4},
	require = psi_wil_req4,
	points = 5,
	psi = 40,
	cooldown = 12,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 2 } },
	range = function(self, t) return self:combatTalentLimit(t, 10, 6, 9) end,
	direct_hit = true,
	requires_target = true,
	getDam = function(self, t) return self:combatTalentMindDamage(t, 20, 180) end,
	action = function(self, t)
		if self:getTalentLevelRaw(t) < 5 then
			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if core.fov.distance(self.x, self.y, x, y) > tg.range then return nil end
			if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
				local dam = self:mindCrit(t.getDam(self, t))
				self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(rng.avg(2*dam/3, dam, 3)))
				--local _ _, x, y = self:canProject(tg, x, y)
				game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
				game:playSoundNear(self, "talents/lightning")
				--self:move(x, y, true)
				local fx, fy = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
				if not fx then
					return
				end
				self:move(fx, fy, true)
			else
				game.logSeen(self, "그곳으로 이동할 수 없습니다.")
				return nil
			end
			return true
		else
			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if core.fov.distance(self.x, self.y, x, y) > tg.range then return nil end
			local dam = self:mindCrit(t.getDam(self, t))

			for i = 1, self:getTalentRange(t) do
				self:project(tg, x, y, DamageType.DIG, 1)
			end
			self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(rng.avg(2*dam/3, dam, 3)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")

			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, engine.Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			local tx, ty = self.x, self.y
			while lx and ly do
				if is_corner_blocked or block_actor(_, lx, ly) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			--self:move(tx, ty, true)
			local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not fx then
				return
			end
			self:move(fx, fy, true)
			return true
		end
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local dam = damDesc(self, DamageType.PHYSICAL, t.getDam(self, t))
		return ([[엄청난 양의 염력을 사용하여, %d 칸 만큼 돌진합니다. 이동 경로에 있는 모든 적들은 밀려나면서 %d - %d 물리 속성 피해를 받습니다.
		기술 레벨이 5 이상이면, 단단한 벽을 뚫어버릴 수 있습니다.]]): 
		format(range, 2*dam/3, dam)
	end,
}

