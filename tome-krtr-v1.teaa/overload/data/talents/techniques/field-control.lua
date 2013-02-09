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

require "engine.krtrUtils"

newTalent{
	name = "Disengage",
	kr_display_name = "작전상 후퇴",
	type = {"technique/field-control", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "utility",
	cooldown = 12,
	stamina = 20,
	range = 7,
	tactical = { ESCAPE = 2 },
	requires_target = true,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		self:knockback(target.x, target.y, math.floor(2 + self:getTalentLevel(t)))
		return true
	end,
	info = function(self, t)
		return ([[%d 칸 뒤로 도약하여, 대상에게서 멀어집니다.]]):format(math.floor(2 + self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Track",
	kr_display_name = "발자국 조사",
	type = {"technique/field-control", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "utility",
	stamina = 20,
	cooldown = 20,
	radius = function(self, t) return math.floor(5 + self:getCun(10, true) * self:getTalentLevel(t)) end,
	no_npc_use = true,
	action = function(self, t)
		local rad = self:getTalentRadius(t)
		self:setEffect(self.EFF_SENSE, 3 + self:getTalentLevel(t), {
			range = rad,
			actor = 1,
		})
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[%d 칸 반경 안에 있는 적들을, %d 턴 동안 탐지합니다.
		탐지 반경은 교활함 능력치의 영향을 받아 증가합니다.]]):format(rad, 3 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Heave",
	kr_display_name = "걷어차기",
	type = {"technique/field-control", 3},
	require = techs_dex_req3,
	points = 5,
	random_ego = "defensive",
	cooldown = 15,
	stamina = 5,
	tactical = { ESCAPE = { knockback = 1 }, DISABLE = { knockback = 3 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- Try to knockback !
		local can = function(target)
			if target:checkHit(math.max(self:combatAttack(), self:combatPhysicalpower()), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				return true
			else
				game.logSeen(target, "%s 밀려나지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		if can(target) then 
			target:knockback(self.x, self.y, math.floor(2 + self:getTalentLevel(t)), can) 
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatPhysicalpower())
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 강력하게 걷어차, %d 칸 떨어진 곳까지 밀어냅니다.
		날아가는 방향에 다른 대상이 있다면, 그 대상도 같이 밀려나게 됩니다.
		밀어내기 확률은 정확도나 물리력 중 더 높은 능력치의 영향을 받아 증가합니다.]]):format(math.floor(2 + self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Slow Motion",
	kr_display_name = "발사체 포착",
	type = {"technique/field-control", 4},
	require = techs_dex_req4,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	range = 10,
	sustain_stamina = 80,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		return {
			slow_projectiles = self:addTemporaryValue("slow_projectiles", math.min(90, 15 + self:getDex(10, true) * self:getTalentLevel(t))),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("slow_projectiles", p.slow_projectiles)
		return true
	end,
	info = function(self, t)
		return ([[주문, 화살 등 날아오는 발사체를 기민한 반사신경으로 포착하여, 마치 %d%% 느리게 날아오는 것 같은 효과를 일으킵니다.]]):
		format(math.min(90, 15 + self:getDex(10, true) * self:getTalentLevel(t)))
	end,
}

