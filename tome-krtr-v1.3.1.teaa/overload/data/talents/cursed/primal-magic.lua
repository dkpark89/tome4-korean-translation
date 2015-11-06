-- ToME - Tales of Middle-Earth
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

local function combatTalentDamage(self, t, min, max)
	return self:combatTalentSpellDamage(t, min, max, (self.level + self:getMag()) * 1.2)
end

local function combatPower(self, t, multiplier)
	return (self.level + self:getMag()) * (multiplier or 1)
end

newTalent{
	name = "Arcane Bolts",
	kr_name = "마법 화살",
	type = {"cursed/primal-magic", 1},
	require = cursed_mag_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	hate =  8,
	range = 6,
	proj_speed = 4,
	tactical = { ATTACK = { ARCANE = 2 } },
	getDamage = function(self, t)
		return combatTalentDamage(self, t, 0, 125)
	end,
	fireArcaneBolt = function(self, t)
		-- find nearest target
		local target
		local minDistance = 9999
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local actor = game.level.map(x, y, Map.ACTOR)
				if actor and self:reactionToward(actor) < 0 then
					local distance = core.fov.distance(self.x, self.y, actor.x, actor.y)
					if (not target or distance < minDistance) and self:hasLOS(actor.x, actor.y) then
						target = actor
						minDistance = distance
					end
				end
			end
		end

		if not target then return end
		if self.dead then
			self.arcaneBolts = nil
			return
		end

		local x, y = target.x, target.y
		local tg = {type="bolt", range=range, talent=t, display={particle="bolt_fire", trail="firetrail"}}
		self:projectile(tg, target.x, target.y, DamageType.ARCANE, self.arcaneBolts.damage, nil)

		game:playSoundNear(self, "talents/fire")
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local damage = t.getDamage(self, t)

		--local tg = {type="bolt", range=range, talent=t, display={particle="bolt_fire", trail="firetrail"}}
		--local x, y, target = self:getTarget(tg)
		--if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end

		self.arcaneBolts = { damage = damage, range = range, duration = 4 }

		return true
	end,
	do_arcaneBolts = function(self, t)
		t.fireArcaneBolt(self, t)

		if self.arcaneBolts then
			self.arcaneBolts.duration = self.arcaneBolts.duration - 1
			if self.arcaneBolts.duration <= 0 then self.arcaneBolts = nil end
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[4 턴 동안, 매 턴마다 마법의 힘으로 이루어진 화살을 가장 근접한 적에게 날려 %d 피해를 줍니다.
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.ARCANE, damage))
	end,
}

newTalent{
	name = "Displace",
	kr_name = "위치 이동",
	type = {"cursed/primal-magic", 2},
	require = cursed_mag_req2,
	points = 5,
	random_ego = "utility",
	no_energy = true,
	cooldown = function(self, t) return 20 - math.floor(self:getTalentLevel(t) * 1.5) end,
	hate = 5,
	range = 3,
	tactical = { ESCAPE = function(self, t, target)
		return 2 * self:canBe("teleport")
	end },
	action = function(self, t)
		local x, y = self.x, self.y
		local range = self:getTalentRange(t)
		game.logPlayer(self, "이동할 위치를 선택하세요...")
		local tg = {type="ball", nolock=true, pass_terrain=false, nowarning=true, range=range, radius=0}
		x, y = self:getTarget(tg)
		if not x or not self:hasLOS(x, y) then return nil end

		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		if not self:canMove(x, y) or (self.x == x and self.y == y) then return nil end
		if not self:canBe("teleport") or game.level.map.attrs(x, y, "no_teleport") then
			game.logSeen(self, "위치 이동에 실패했습니다!")
			return true
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
		self:move(x, y, true)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport_in")

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[시야 내에 있는 3 칸 이내의 장소로 즉시 이동합니다.]])
	end,
}

newTalent{
	name = "Primal Skin",
	kr_name = "태고의 피부",
	type = {"cursed/primal-magic", 3},
	require = cursed_mag_req3,
	points = 5,
	mode = "passive",
	points = 5,
	getArmor = function(self, t) return combatTalentDamage(self, t, 4, 40) end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		return ([[오랜 세월 수련한 마법이 피부에 스며들어, 물리적 피해를 저항해낼 수 있게 됩니다. 이를 통해 방어도가 %d 상승합니다.
		방어도 상승량은 마법 능력치의 영향을 받아 증가합니다.]]):format(armor)
	end,
}

newTalent{
	name = "Vaporize",
	kr_name = "증발",
	type = {"cursed/primal-magic", 4},
	require = cursed_mag_req4,
	points = 5,
	random_ego = "attack",
	hate = 30,
	cooldown = 30,
	tactical = { ATTACK = { ARCANE = 2 } },
	range = 10,
	proj_speed = 20,
	requires_target = true,
	no_npc_use = true,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_arcane", trail="arcanetrail"}}
		return tg
	end,
	getDamage = function(self, t) return combatTalentDamage(self, t, 0, 800) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ARCANE, t.getDamage(self, t), {type="vaporize"})

		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, 8,
			DamageType.ARCANE, 5,
			0,
			5, nil,
			{type="light_zone"},
			nil, self:spellFriendlyFire()
		)

		tg = {type="hit", range=10}
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur = 4,
			dam = 75
		})

		game:playSoundNear(self, "talents/fireflash")

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[대상에게 순수한 마법의 힘으로 %d 피해를 줍니다. 너무나 격렬한 마법이라 통제가 어려우며, 통제에 실패할 경우 4 턴 동안 혼란 상태가 됩니다.
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.ARCANE, damage))
	end,
}
