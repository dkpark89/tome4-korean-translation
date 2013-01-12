-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

require "engine.krtrUtils" --@@

newTalent{
	name = "Juggernaut",
	kr_display_name = "저돌적인 전투",
	type = {"technique/superiority", 1},
	require = techs_req_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 40,
	stamina = 60,
	no_energy = true,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_EARTHEN_BARRIER, 20, {power=10 + self:getTalentLevel(t) * 5})
		return true
	end,
	info = function(self, t)
		return ([[자신의 몸을 신경쓰지 않고 전투에 집중하여, 전투 중에 받는 피해를 약간 무시합니다.
		물리 피해 감소량이 20 턴 동안 %d%% 증가합니다.]]):format(10 + self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Onslaught",
	kr_display_name = "맹습",
	type = {"technique/superiority", 2},
	require = techs_req_high2,
	points = 5,
	mode = "sustained",
	cooldown = 20,
	sustain_stamina = 50,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		return {
			onslaught = self:addTemporaryValue("onslaught", math.floor(self:getTalentLevel(t))),
			stamina = self:addTemporaryValue("stamina_regen", -4),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("onslaught", p.onslaught)
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	info = function(self, t)
		return ([[공격적인 자세를 취하여, 앞으로 나아갈 때 전방 %d 칸 반경에 있는 적들을 밀어낼 수 있습니다.
		이 기술은 체력을 급속도로 소모합니다. (1 턴 당 4 체력 소모 )]]):
		format(math.floor(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Battle Call",
	kr_display_name = "전장의 부름",
	type = {"technique/superiority", 3},
	require = techs_req_high3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { CLOSEIN = 2 },
	range = 0,
	radius = function(self, t)
		return 2 + self:getTalentLevel(t)
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
				game.logSeen(target, "%s 전장의 부름을 받았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[주위 %d 칸 반경에 있는 적들을 불러와, 근접공격을 할 수 있는 거리까지 즉시 끌어들입니다.]]):format(2+self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Shattering Impact",
	kr_display_name = "충격파",
	type = {"technique/superiority", 4},
	require = techs_req_high4,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		return {
			dam = self:addTemporaryValue("shattering_impact", self:combatTalentWeaponDamage(t, 0.2, 0.6)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("shattering_impact", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[무기에 온 힘을 실어, 적을 타격할 때마다 충격파를 만들어냅니다. 이 충격파는 근처의 모든 적들에게 %d%% 무기 피해를 줍니다. 
		대신, 매 타격마다 체력이 15 소모됩니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.2, 0.6))
	end,
}
