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

require "engine.krtrUtils"

local Object = require "engine.Object"

--I5 Assumed reference Actor for scaling: (level 50, wil = 100, Paradox mastery at level 5, 0% fatigue) at 25% failure chance = 1150 paradox

-- A simple scaling damage formula
-- damage proportional to paradox, returns 127, 367 damage at 400, 1150 paradox
getAnomalyDamage = function(self)
	return self:getParadox()*367/1150 -- linear formula with no cap
end

-- Another scaling formula, used in place of apply_power for timed effects
-- power proportional to paradox, returns 72, 207 at 400, 1150 paradox
getAnomalyPower = function(self)
	return self:getParadox()*207/1150 -- linear formula
end

-- simple radius formula used for AoEs and targeting, caps at 10 mostly to prevent overloading the particle threads with a giant AoE
getAnomalyRadius = function(self)
	local base_radius = math.ceil(self:getParadox()/100)
	local radius = math.min(base_radius, 10)
	return radius
end

newTalent{
	name = "Anomaly Teleport",
	kr_name = "이상 현상 : 순간이동",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 10,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/200, 1150)) end,
	getRange = function(self, t) return math.floor(self:combatScale(self:getParadox(), 0, 0, 1150/20, 1150)) end,
	message = "진실이 변경되었습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
			a:teleportRandom(a.x, a.y, t.getRange(self, t), 15)
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
		end
		return true
	end,
	info = function(self, t)
		local targets = t.getTargetCount(self, t)
		local range = t.getRange(self, t)
		return ([[시전자 주변의 무작위한 적 %d 명이 순간이동되어, %d 칸 더 떨어진 곳에 나타납니다.]]):format(targets, range)
	end,
}

newTalent{
	name = "Anomaly Rearrange",
	kr_name = "이상 현상 : 재배열",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 10,
	direct_hit = true,
	type_no_req = true,
	cooldown = 1,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/50, 1150)) end,
	getRange = function(self, t) return math.floor(self:combatScale(self:getParadox(), 0, 0, 1150/100, 1150)) end,
	message = "@Source1@ 시공간의 구조에 약간의 문제를 일으켰습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
			a:teleportRandom(a.x, a.y, t.getRange(self, t), 1)
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
		end
		return true
	end,
	info = function(self, t)
		local targets = t.getTargetCount(self, t)
		local range = t.getRange(self, t)
		return ([[시전자 주변의 무작위한 적 %d 명이 순간이동되어, %d 칸 더 떨어진 곳에 나타납니다.]]):format(targets, range)
	end,
}

newTalent{
	name = "Anomaly Stop",
	kr_name = "이상 현상 : 중지",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 10,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return 1 end,
	getRadius = function(self, t) return getAnomalyRadius(self) end,
	getStop = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/100, 1150)) end,
	message = "@Source1@ 무의 시간으로 이루어진 거품을 만들어냅니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), selffire=self:spellFriendlyFire(), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.STOP, t.getStop(self, t))
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_temporal", {radius=t.getRadius(self, t), tx=a.x, ty=a.y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[반경 %d 칸의 거품에 들어간 모든 대상들을 %d 턴 동안 기절시킵니다.]]):format(t.getRadius(self, t), t.getStop(self, t)) --@@ 한글화 검수 필요
	end,
}

newTalent{
	name = "Anomaly Slow",
	kr_name = "이상 현상 : 감속",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return 1 end,
	getRadius = function(self, t) return getAnomalyRadius(self) end,
	getSlow = function(self, t) return 1 - 1 / (1 + (self:getParadox()/15) / 100) end,
	message = "@Source1@ 느린 시간으로 이루어진 거품을 만들어냅니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), selffire=self:spellFriendlyFire(), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.SLOW, t.getSlow(self, t))
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "ball_temporal", {radius=t.getRadius(self, t), tx=a.x, ty=a.y})
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[반경 %d 칸의 거품에 들어간 모든 대상들을 %d%% 감속시킵니다.]]):
		format(t.getRadius(self, t), t.getSlow(self, t)*100) --@@ 한글화 검수 필요
	end,
}

newTalent{
	name = "Anomaly Haste",
	kr_name = "이상 현상 : 가속",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/300, 1150)) end,
	getPower = function(self, t) return self:combatScale(self:getParadox(), 0, 0, 1150/15/100, 1150) end,
	message = "@Source1@ 몇몇 시간의 구조를 가속시켰습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			a:setEffect(self.EFF_SPEED, 8, {power=t.getPower(self, t)})
			game.level.map:particleEmitter(a.x, a.y, 1, "teleport")
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[대상을 중심으로 반경 %d 칸 안에 있는 존재들(최대 %d)의 전체 속도를 %d%% 증가시킵니다.]]): --@@ 한글화 검수 필요
		format(10, t.getTargetCount(self, t), t.getPower(self, t)*100) --@@ 변수 순서 조정
	end,
}

newTalent{
	name = "Anomaly Temporal Storm",
	kr_name = "이상 현상 : 시간의 폭풍",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	cooldown = 1,
	no_unlearn_last = true,
	getDamage = function(self, t) return getAnomalyDamage(self)/4 end,
	getDuration = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/50, 1150)) end,
	message = "@Source@의 주변으로 시간의 폭풍이 몰아칩니다.",
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.TEMPORAL, t.getDamage(self, t),
			3,
			5, nil,
			engine.Entity.new{alpha=75, display='', color_br=200, color_bg=200, color_bb=0},
			nil, false
		)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[시간의 폭풍을 %d 턴 동안 만들어내, 매 턴마다 %d 시간 피해를 줍니다.]])
		:format(duration, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Anomaly Summon Time Elemental",
	kr_name = "이상 현상 : 시간의 정령 소환",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 10,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/200, 1150)) end,
	getSummonTime = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/50, 1150)) end,
	message = "@Source@의 간섭에 몇몇 시간의 정령들이 관심을 보였습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			-- Find space
			local x, y = util.findFreeGrid(a.x, a.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "소환할 공간이 없습니다!")
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "elemental", subtype = "temporal",
				display = "E", color=colors.YELLOW,
				name = "telugoroth", faction = a.faction,
				kr_name = "정령",
				desc = [[시간의 정령으로, 시간을 여행하는 자가 아닌 한 만나기 힘든 정령입니다. 그 형체가 끊임없이 변하고 있어, 눈에 흐릿하게 보입니다.]],
				combat = { dam=resolvers.mbonus(40, 15), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.TEMPORAL },
				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
				autolevel = "none",
				global_speed_base = 1.5,
				stats = { str=8, dex=12, mag=12, wil= 12, con=10 },
				ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
				level_range = {self.level, self.level},

				resists = { [DamageType.PHYSICAL] = 10, [DamageType.TEMPORAL] = 100, },

				no_breath = 1,
				poison_immune = 1,
				disease_immune = 1,

				max_life = resolvers.rngavg(70,80),
				life_rating = 8,
				infravision = 10,
				rank = 2,
				size_category = 3,

				autolevel = "dexmage",

				combat_armor = 0, combat_def = 20,

				on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

				resolvers.talents{
					[Talents.T_TURN_BACK_THE_CLOCK]=3,
				},

				summoner = self, summoner_gain_exp=false,
				summon_time = t.getSummonTime(self, t),
			--	ai_target = {actor=target}
			}

			m:resolve() m:resolve(nil, true)
			m:forceLevelup(self.level)
			game.zone:addEntity(game.level, m, "actor", x, y)
			game.level.map:particleEmitter(x, y, 1, "summon")

			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[시간의 정령 %d 마리를 %d 턴 동안 소환합니다. 누구의 편을 들어줄지는 알 수 없습니다.]]):
		format(t.getTargetCount(self, t), t.getSummonTime(self, t))
	end,
}

newTalent{
	name = "Anomaly Temporal Bubble",
	kr_name = "이상 현상 : 시간의 거품",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 10,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/200, 1150)) end,
	getDuration = function(self, t) return math.floor(self:combatScale(self:getParadox(), 0, 0, 1150/100, 1150)) end,
	message = "@Source1@ 시간의 구조를 정지시켰습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.TIME_PRISON, t.getDuration(self, t), {type="manathrust"})
		end
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local target = t.getTargetCount(self, t)
		return ([[무작위한 %d 명의 대상들이 %d 턴 동안 시간의 감옥에 갇힙니다.]])
		:format(target, duration)
	end,
}

newTalent{
	name = "Anomaly Dig",
	kr_name = "이상 현상 : 굴착",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	getRadius = function(self, t) return getAnomalyRadius(self) end,
	message = "@Source@ 주변의 물질들이 먼지로 변해 사라졌습니다.",
	action = function(self, t)
		local tg = {type="ball", range=0, radius=t.getRadius(self,t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, DamageType.DIG, 1)
		game.level.map:particleEmitter(self.x, self.y, t.getRadius(self, t), "ball_earth", {radius=tg.radius})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[시전자 주변의 지형들이 사라집니다.]])
	end,
}

newTalent{
	name = "Anomaly Swap",
	kr_name = "이상 현상 : 위치 교체",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getRange = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/20, 1150)) end,
	getConfuseDuration = function(self, t) return math.floor(self:combatScale(self:getParadox(), 0, 0, 1150/200, 1150)) end,
	getConfuseEfficency = function(self, t) return self:combatLimit(self:getParadox(), 50, 0, 0, 35, 1150) end, -- Limit < 50%
	message = "진실이 변경되었습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, t.getRange(self, t))
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") and a ~= self then
				tgts[#tgts+1] = a
			end
		end end

		if #tgts > 0 then
			-- Randomly take a target
			local tg = {type="hit", range=t.getRange(self,t), talent=t} -- bug fix
			local a, id = rng.table(tgts)
			local target = a
		
			if target:canBe("teleport") and self:canBe("teleport") then
				-- first remove the target so the destination tile is empty
				game.level.map:remove(target.x, target.y, Map.ACTOR)
				local px, py 
				px, py = self.x, self.y
				if self:teleportRandom(a.x, a.y, 0) then
					-- return the target at the casters old location
					game.level.map(px, py, Map.ACTOR, target)
					self.x, self.y, target.x, target.y = target.x, target.y, px, py
					game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
					game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
					-- confuse them both
					self:project(tg, target.x, target.y, DamageType.CONFUSION, { dur = t.getConfuseDuration(self, t), dam = t.getConfuseEfficency(self, t), })
					self:project(tg, self.x, self.y, DamageType.CONFUSION, { dur = t.getConfuseDuration(self, t), dam = t.getConfuseEfficency(self, t),	})
				else
					-- return the target without effect
					game.level.map(target.x, target.y, Map.ACTOR, target)
					game.logSeen(self, "주문이 헛나갔습니다!")
				end
			else
				game.logSeen(target, "%s 위치 교체를 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
			game:playSoundNear(self, "talents/teleport")
		end

		return true
	end,
	info = function(self, t)
		return ([[시전자와 반경 %d 칸 안에 있는 무작위한 대상의 위치가 서로 바뀝니다, confusing (%d%% chance to act randomly) both of them for %d turns.]]):
		format(t.getRange(self, t), t.getConfuseEfficency(self, t), t.getConfuseDuration(self, t)) --@@ 한글화 필요
	end,
}

newTalent{
	name = "Anomaly Gravity Spike",
	kr_name = "이상 현상 : 중력 가시",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 10,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return 1 end,
	getRadius = function(self, t) return getAnomalyRadius(self) end,
	getDamage = function(self, t) return getAnomalyDamage(self) end,
	message = "@Source1@ 중력 가시를 발생시켰습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), friendlyfire=self:spellFriendlyFire(), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if not target then return end
				local tx, ty = util.findFreeGrid(a.x, a.y, 5, true, {[Map.ACTOR]=true})
				if tx and ty and target:canBe("knockback") then
					target:move(tx, ty, true)
					game.logSeen(target, "%s 중력 가시에 걸렸습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				end
			end)

			self:project (tg, a.x, a.y, DamageType.PHYSICAL, t.getDamage(self, t))
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "gravity_spike", {radius=t.getRadius(self, t), grids=grids, tx=a.x, ty=a.y, allow=core.shader.allow("distort")})
			game:playSoundNear(self, "talents/earth")

		end
		return true
	end,
	info = function(self, t)
		return ([[중력 가시를 만들어냅니다.]])
	end,
}

newTalent{
	name = "Anomaly Entropy",
	kr_name = "이상 현상 : 엔트로피",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/100, 1150)) end,
	getPower = function(self, t) return math.floor(self:combatScale(self:getParadox(), 0, 0, 1150/100, 1150)) end,
	getTalentCount = function(self, t) return math.floor(self:combatScale(self:getParadox(), 0, 0, 1150/200, 1150)) end,
	message = "@Source@ 주변의 엔트로피가 증가하였습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end

				local tids = {}
				for tid, lev in pairs(target.talents) do
					local t = target:getTalentFromId(tid)
					if not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
				end
				for i = 1, t.getTalentCount(self, t) do
					local power = t.getPower(self, t)
					local t = rng.tableRemove(tids)
					if not t then break end
					target.talents_cd[t.id] = rng.range(2, power)
					game.logSeen(target, "%s의 %s 방해받았습니다!", (target.kr_name or target.name):capitalize(), (t.kr_name or t.name):addJosa("가"))
				end
				target.changed = true
			end, nil)
		end
		return true
	end,
	info = function(self, t)
		return ([[반경 10 칸의 거품 내부에 있는 존재들(최대 %d)의 기술 %d 개의 재사용 대기시간 %d 턴을 부여합니다.]]): --@@ 한글화 검수 필요
		format(t.getTalentCount(self, t), t.getTargetCount(self, t), t.getPower(self, t)) --@@ 변수 순서 조정
	end,
}

newTalent{
	name = "Anomaly Summon Townsfolk",
	kr_name = "이상 현상 : 시민 소환",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 10,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/200, 1150)) end,
	getSummonTime = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/20, 1150)) end,
	message = "몇몇 선량한 시민들이 자신들의 시공간에서 끌려나왔습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)
			-- Randomly pick a race
			local race = rng.range(1, 4)

			-- Find space
			for i = 1, 4 do
				local x, y = util.findFreeGrid(a.x, a.y, 5, true, {[Map.ACTOR]=true})
				if not x then
					game.logPlayer(self, "소환할 공간이 없습니다!")
					return
				end

				local NPC = require "mod.class.NPC"
				local m = NPC.new{
					type = "humanoid", display = "p",
					color=colors.WHITE,

					combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

					body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
					lite = 3,

					life_rating = 10,
					rank = 2,
					size_category = 3,

					open_door = true,

					autolevel = "warrior",
					stats = { str=12, dex=8, mag=6, con=10 },
					ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
					level_range = {1, 3},

					max_life = resolvers.rngavg(30,40),
					combat_armor = 2, combat_def = 0,

				--	summoner = self,
					summoner_gain_exp=false,
					summon_time = t.getSummonTime(self, t),
				}

				m.level = 1

				if race == 1 then
					m.name = "human farmer"
					m.kr_name = "인간 농부"
					m.subtype = "human"
					m.image = "npc/humanoid_human_human_farmer.png"
					m.desc = [[평범한 인간 농부로, 뭐가 어떻게 된 것인지 모르겠다는 표정을 하고 있습니다.]]
					m.faction = "allied-kingdoms"
					m.resolvers.inscriptions(1, "infusion")
				elseif race == 2 then
					m.name = "halfling gardner"
					m.kr_name = "하플링 정원사"
					m.subtype = "halfling"
					m.desc = [[무뚝뚝한 하플링 정원사로, 지금 여기서 무슨 일이 일어나는지 혼란스러운 것 같습니다.]]
					m.faction = "allied-kingdoms"
					m.image = "npc/humanoid_halfling_halfling_gardener.png"
					m.resolvers.inscriptions(1, "infusion")
				elseif race == 3 then
					m.name = "shalore scribe"
					m.kr_name = "샬로레 필경사"
					m.subtype = "shalore"
					m.desc = [[비쩍 마른 엘프 필경사로,주변 환경에 당황한 것 같습니다.]]
					m.faction = "shalore"
					m.image = "npc/humanoid_shalore_shalore_rune_master.png"
					m.resolvers.inscriptions(1, "rune")
				elseif race == 4 then
					m.name = "dwarven lumberjack"
					m.kr_name = "드워프 나무꾼"
					m.subtype = "dwarf"
					m.desc = [[건장한 드워프 나무꾼으로, 갑작스러운 환경 변화에 살짝 화가 난 것 같습니다.]]
					m.faction = "iron-throne"
					m.image = "npc/humanoid_dwarf_lumberjack.png"
					m.resolvers.inscriptions(1, "rune")
				end

				m:resolve() m:resolve(nil, true)
				m:forceLevelup(self.level)
				game.zone:addEntity(game.level, m, "actor", x, y)
				game.level.map:particleEmitter(x, y, 1, "summon")
			end

			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[선량한 시민들을 전장으로 불러냅니다.]])
	end,
}

newTalent{
	name = "Anomaly Call",
	kr_name = "이상 현상 : 호출",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getRange = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/30, 1150)) end,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/200, 1150)) end,
	message = "펑!!",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, t.getRange(self, t))
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a:canBe("teleport") and a ~= self then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "소환할 공간이 없습니다!")
				return
			end

			a:move(x, y, true)
			game.level.map:particleEmitter(x, y, 1, "teleport")

		end
		return true
	end,
	info = function(self, t)
		return ([[Pulls up to %d enemies within range %d to the caster's location.]]): --@@ 한글화 필요
		format(t.getTargetCount(self, t), t.getRange(self, t))
	end,
}

newTalent{
	name = "Anomaly Flawed Design",
	kr_name = "이상 현상 : 잘못된 설계",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return math.ceil(self:combatScale(self:getParadox(), 0, 0, 1150/150, 1150)) end,
	getPower = function(self, t) return self:combatScale(self:getParadox(), 0, 0, 1150/30, 1150) end,
	message = "@Source1@ 몇몇 존재들을 우연히 약화시켰습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			a:setEffect(self.EFF_FLAWED_DESIGN, 10, {power=t.getPower(self, t)})
			a:setEffect(self.EFF_TURN_BACK_THE_CLOCK, 10, {power=t.getPower(self, t)/2})
			game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[반경 10칸 내의 몇몇 존재들을 약화시킵니다.]]) --@@ 한글화 검수 필요
	end,
}

newTalent{
	name = "Anomaly Dues Ex",
	kr_name = "이상 현상 : 신의 강림",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	range = 6,
	direct_hit = true,
	type_no_req = true,
	no_unlearn_last = true,
	getTargetCount = function(self, t) return 1 end,
	getHastePower = function(self, t) return self:combatScale(self:getParadox(), 0, 0, 1150/15/100, 1150) end,
	getRegenPower = function(self, t) return self:combatScale(self:getParadox(), 0, 0, 1150/15, 1150) end,
	message = "승산이 기울었습니다.",
	action = function(self, t)
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			a:setEffect(self.EFF_SPEED, 8, {power=t.getHastePower(self, t)})
			a:setEffect(self.EFF_REGENERATION, 8, {power=t.getRegenPower(self, t)})
			a:setEffect(self.EFF_PAIN_SUPPRESSION, 8, {power=t.getRegenPower(self, t)})
			game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
			game:playSoundNear(self, "talents/spell_generic")
		end
		return true
	end,
	info = function(self, t)
		return ([[Substantially toughens and hastes one target for 8 turns.]]) --@@ 한글화 필요
	end,
}

--[[newTalent{
	name = "Anomaly Terrain Change",
	kr_name = "이상 현상 : 지형 변화",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Random Terrain in a ball.)
	end,
}

newTalent{
	name = "Anomaly Stat Reorder",
	kr_name = "이상 현상 : 능력치 재분배",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Target loses stats.)
	end,
}

newTalent{
	name = "Anomaly Heal",
	kr_name = "이상 현상 : 치료",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Target is healed to full life.)
	end,
}

newTalent{
	name = "Anomaly Double",
	kr_name = "이상 현상 : 복제",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Clones a random non-elite creature.  Clone may or may not be hostile to the caster.)
	end,
}

newTalent{
	name = "Anomaly Sex Change",
	kr_name = "이상 현상 : 성전환",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Money Changer",
	kr_name = "이상 현상 : 금액 변화",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Spacetime Folding",
	kr_name = "이상 현상 : 시공간 접기",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Charge/Drain",
	kr_name = "이상 현상 : 충전/방전",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Vertigo",
	kr_name = "이상 현상 : 어지러움",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	no_npc_use = true,
	no_unlearn_last = true,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ()
	end,
}

newTalent{
	name = "Anomaly Evil Twin",
	kr_name = "이상 현상 : 사악한 쌍둥이",
	type = {"chronomancy/anomalies", 1},
	points = 1,
	type_no_req = true,
	requires_target = true,
	no_unlearn_last = true,
	getSummonTime = function(self, t) return math.floor(self:getParadox()/50) end,
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return (Clones the caster)
	end,
}]]
