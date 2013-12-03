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
	name = "Shattering Shout",
	kr_name = "공격의 외침",
	type = {"technique/warcries", 1},
	require = techs_req_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 7,
	stamina = 20,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	requires_target = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	getdamage = function(self,t) return self:combatScale(self:getTalentLevel(t) * self:getStr(), 60, 10, 267, 500)  end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, t.getdamage(self,t))
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=8, size=2, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		return ([[강렬한 외침을 내질러, 전방의 적들에게 %0.2f 의 물리 피해를 줍니다. (전방 %d 칸 반경)
		피해량은 힘 능력치의 영향을 받아 증가합니다.]])
		:format(damDesc(self, DamageType.PHYSICAL, t.getdamage(self,t)), t.radius(self,t))
	end,
}

newTalent{
	name = "Second Wind",
	kr_name = "제 2 호흡",
	type = {"technique/warcries", 2},
	require = techs_req_high2,
	points = 5,
	random_ego = "utility",
	cooldown = 50,
	tactical = { STAMINA = 2 },
	getRestore = function(self, t) return self:combatTalentLimit(t, 100, 27, 55) end,
	action = function(self, t)
		self:incStamina(t.getRestore(self, t)*self.max_stamina/ 100)
		return true
	end,
	info = function(self, t)
		return ([[심호흡을 통해, 체력을 %d%% 회복합니다.]]):
		format(t.getRestore(self, t))
	end,
}

newTalent{
	name = "Battle Shout",
	kr_name = "전장의 외침",
	type = {"technique/warcries", 3},
	require = techs_req_high3,
	points = 5,
	random_ego = "defensive",
	cooldown = 30,
	stamina = 40,
	tactical = { DEFEND = 2, BUFF = 1 },
	getdur = function(self,t) return math.floor(self:combatTalentLimit(t, 30, 7, 15)) end, -- Limit to < 30
	getPower = function(self, t) return self:combatTalentLimit(t, 50, 11, 15) end, -- Limit to < 50%
	action = function(self, t)
		self:setEffect(self.EFF_BATTLE_SHOUT, t.getdur(self,t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[전장의 외침을 내질러, 생명력과 체력 최대치를 %0.1f%% 증가시킵니다. 증가량에 해당하는 만큼의 생명력과 체력은 회복됩니다 (지속시간 %d 턴). When the effect ends, the additional life and stamina will be lost.]]):format(t.getPower(self, t), t.getdur(self, t)) --@@ 한글화 필요
	end,
}

newTalent{
	name = "Battle Cry",
	kr_name = "전장의 포효",
	type = {"technique/warcries", 4},
	require = techs_req_high4,
	points = 5,
	random_ego = "attack",
	cooldown = 30,
	stamina = 40,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	requires_target = true,
	tactical = { DISABLE = 2 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_BATTLE_CRY, 7, {power=7 * self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
		end)
		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "directional_shout", {life=12, size=5, tx=x-self.x, ty=y-self.y, distorion_factor=0.1, radius=self:getTalentRadius(t), nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
		return true
	end,
	info = function(self, t)
		return ([[전장의 포효를 들은 적들은 두려움에 사로잡혀 몸이 굳어버립니다. 전방 %d 칸 범위에 있는 적의 회피도를 7턴 동안 %d 감소시킵니다.
		회피도 감소 효과는 물리력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), 7 * self:getTalentLevel(t))
	end,
}
