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

local function activate_moss(self, btid)
	for tid, lev in pairs(self.talents) do
		if tid ~= btid and self.talents_def[tid].type[1] == "wild-gift/moss" and (not self.talents_cd[tid] or self.talents_cd[tid] < 3) then
			self.talents_cd[tid] = 3
		end
	end
end

newTalent{
	name = "Grasping Moss",
	kr_name = "붙잡는 이끼",
	type = {"wild-gift/moss", 1},
	require = gifts_req1,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getSlow = function(self, t) return 30 + math.ceil(self:getTalentLevel(t) * 6) end,
	getPin = function(self, t) return 20 + math.ceil(self:getTalentLevel(t) * 5) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.GRASPING_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), pin=t.getPin(self, t), slow=t.getSlow(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local slow = t.getSlow(self, t)
		local pin = t.getPin(self, t)
		local radius = self:getTalentRadius(t)
		return ([[자신의 주변 %d 칸 반경에 즉각적으로 이끼를 자라나게 만듭니다.
		해당 영역에 위치한 모든 적들은 매 턴마다 %0.2f 자연 속성 피해를 받게 됩니다.
		이 이끼는 아주 두껍고 끈적하기 때문에 모든 적들의 이동 속도를 %d%% 감소시키며, %d%% 확률로 4 턴간 그 자리에서 이동하지 못하게 됩니다.
		이끼는 %d 턴 동안 지속됩니다.
		모든 이끼 계열 기술은 사용 시간 없이 즉시 사용할 수 있지만, 하나의 기술을 사용하면 다른 모든 이끼 계열 기술들을 3 턴 동안 쓰지 못하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), slow, pin, duration)
	end,
}

newTalent{
	name = "Nourishing Moss",
	kr_name = "달라붙는 이끼",
	type = {"wild-gift/moss", 2},
	require = gifts_req2,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getHeal = function(self, t) return 50 + math.ceil(self:getTalentLevel(t) * 12) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.NOURISHING_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), factor=t.getHeal(self, t)/100},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local heal = t.getHeal(self, t)
		local radius = self:getTalentRadius(t)
		return ([[자신의 주변 %d 칸 반경에 즉각적으로 이끼를 자라나게 만듭니다.
		해당 영역에 위치한 모든 적들은 매 턴마다 %0.2f 자연 속성 피해를 받게 됩니다.
		이 이끼에는 흡혈 성향이 있어, 적들에게 준 피해량의 %d%% 만큼 당신의 생명력을 회복시켜 줍니다.
		이끼는 %d 턴 동안 지속됩니다.
		모든 이끼 계열 기술은 사용 시간 없이 즉시 사용할 수 있지만, 하나의 기술을 사용하면 다른 모든 이끼 계열 기술들을 3 턴 동안 쓰지 못하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), heal, duration)
	end,
}

newTalent{
	name = "Slippery Moss",
	kr_name = "미끄러운 이끼",
	type = {"wild-gift/moss", 3},
	require = gifts_req3,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getFail = function(self, t) return math.min(50, 15 + math.ceil(self:getTalentLevel(t) * 4)) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.SLIPPERY_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), fail=t.getFail(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local fail = t.getFail(self, t)
		local radius = self:getTalentRadius(t)
		return ([[자신의 주변 %d 칸 반경에 즉각적으로 이끼를 자라나게 만듭니다.
		해당 영역에 위치한 모든 적들은 매 턴마다 %0.2f 자연 속성 피해를 받게 됩니다.
		이 이끼는 매우 미끄러워, 이끼 위에서 적들이 복잡한 행동을 할 경우 %d%% 확률로 기술 사용이 실패하게 됩니다. 
		이끼는 %d 턴 동안 지속됩니다.
		모든 이끼 계열 기술은 사용 시간 없이 즉시 사용할 수 있지만, 하나의 기술을 사용하면 다른 모든 이끼 계열 기술들을 3 턴 동안 쓰지 못하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), fail, duration)
	end,
}

newTalent{
	name = "Hallucinogenic Moss",
	kr_name = "환각성 이끼",
	type = {"wild-gift/moss", 4},
	require = gifts_req4,
	points = 5,
	cooldown = 16,
	equilibrium = 5,
	no_energy = true,
	tactical = { ATTACKAREA = {NATURE=1}, DISABLE = {pin = 1} },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 6, 40) end,
	getDuration = function(self, t) return 3 + math.ceil(self:getTalentLevel(t)) end,
	getChance = function(self, t) return 20 + math.ceil(self:getTalentLevel(t) * 5.5) end,
	getPower = function(self, t) return 15 + math.ceil(self:getTalentLevel(t) * 5) end,
	range = 0,
	radius = function(self, t)
		return 2 + math.floor(self:getTalentLevelRaw(t)/2)
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.HALLUCINOGENIC_MOSS, {dam=self:mindCrit(t.getDamage(self, t)), chance=t.getChance(self, t), power=t.getPower(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="moss"},
			nil, false, false
		)
		activate_moss(self, t.id)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		local power = t.getPower(self, t)
		local radius = self:getTalentRadius(t)
		return ([[자신의 주변 %d 칸 반경에 즉각적으로 이끼를 자라나게 만듭니다.
		해당 영역에 위치한 모든 적들은 매 턴마다 %0.2f 자연 속성 피해를 받게 됩니다.
		이 이끼는 이상한 액체로 뒤덮혀 있어, 이끼의 영향을 받은 모든 적들은 %d%% 확률로 2 턴 동안 혼란에 빠지게 됩니다. (혼란 수치 : %d%%)  
		이끼는 %d 턴 동안 지속됩니다.
		모든 이끼 계열 기술은 사용 시간 없이 즉시 사용할 수 있지만, 하나의 기술을 사용하면 다른 모든 이끼 계열 기술들을 3 턴 동안 쓰지 못하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.NATURE, damage), chance, power, duration)
	end,
}
