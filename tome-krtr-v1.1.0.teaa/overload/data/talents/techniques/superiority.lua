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

newTalent{
	name = "Juggernaut",
	kr_name = "저돌적인 전투",
	type = {"technique/superiority", 1},
	require = techs_req_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 40,
	stamina = 60,
	no_energy = true,
	tactical = { DEFEND = 2 },
	getResist = function(self, t) return self:combatTalentScale(t, 15, 35) end,
	action = function(self, t)
		self:setEffect(self.EFF_JUGGERNAUT, 20, {power=t.getResist(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[자신의 몸을 신경쓰지 않고 전투에 집중하여, 전투 중에 받는 피해를 약간 무시합니다.
		물리 피해 감소량이 20 턴 동안 %d%% 증가합니다.]]):format(t.getResist(self,t))
	end,
}

newTalent{
	name = "Onslaught",
	kr_name = "맹습",
	type = {"technique/superiority", 2},
	require = techs_req_high2,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	sustain_stamina = 50,
	tactical = { BUFF = 2 },
	range = function(self,t) return math.floor(self:combatTalentLimit(t, 10, 1, 5)) end, -- Limit KB range to <10
	activate = function(self, t)
		return {
			onslaught = self:addTemporaryValue("onslaught", t.range(self,t)), 
			stamina = self:addTemporaryValue("stamina_regen", -4),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("onslaught", p.onslaught)
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	info = function(self, t)
		return ([[공격적인 자세를 취하여, 적을 공격할 때마다 적을 %d 칸 밀어낼 수 있습니다.
		이 기술은 체력을 급속도로 소모합니다. (1 턴 당 4 체력 소모)]]):
		format(t.range(self, t))
	end,
}

newTalent{
	name = "Battle Call",
	kr_name = "전장의 부름",
	type = {"technique/superiority", 3},
	require = techs_req_high3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { CLOSEIN = 2 },
	range = 0,
	radius = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 7))
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if tx and ty and target:canBe("teleport") then
				target:move(tx, ty, true)
				game.logSeen(target, "%s 전장의 부름을 받았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[주위 %d 칸 반경에 있는 적들을 불러와, 근접공격을 할 수 있는 거리까지 즉시 끌어들입니다.]]):format(t.radius(self,t))
	end,
}

newTalent{
	name = "Shattering Impact",
	kr_name = "충격파",
	type = {"technique/superiority", 4},
	require = techs_req_high4,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	tactical = { BUFF = 2 },
	weaponDam = function(self, t) return (self:combatTalentLimit(t, 1, 0.38, 0.6)) end, -- Limit < 100% weapon damage
	--Note: Shattering impact effect handled in mod.class.interface.Combat.lua : _M:attackTargetWith
	activate = function(self, t)
		return {
			dam = self:addTemporaryValue("shattering_impact", t.weaponDam(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("shattering_impact", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[무기에 온 힘을 실어, 적을 타격할 때마다 충격파를 만들어냅니다. 이 충격파는 근처 1 칸 반경의 모든 존재들에게 %d%% 물리적 무기 피해를 추가로 줍니다. Only one shockwave will be created per action, and the primary target does not take extra damage. 
		대신, 충격파가 발생할 때마다 체력이 15 소모됩니다.]]): --@@ 한글화 필요 : 윗줄
		format(100*t.weaponDam(self, t))
	end,
}
