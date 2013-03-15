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
	name = "Stealth",
	kr_name = "은신",
	type = {"cunning/stealth", 1},
	require = cuns_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = 10,
	allow_autocast = true,
	no_energy = true,
	tactical = { BUFF = 3 },
	getStealthPower = function(self, t) return 4 + self:getCun(10, true) * self:getTalentLevel(t) end,
	getRadius = function(self, t) return math.max(0, math.floor(10 - self:getTalentLevel(t) * 1.1)) end,
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(t.id) then return true end
		local armor = self:getInven("BODY") and self:getInven("BODY")[1]
		if armor and (armor.subtype == "heavy" or armor.subtype == "massive") then
			if not silent then game.logPlayer(self, "갑옷을 입으면 은신할 수 없습니다!") end
			return nil
		end

		-- Check nearby actors
		if not self.x or not self.y or not game.level then return end

		if not rng.percent(self.hide_chance or 0) then
			local grids = core.fov.circle_grids(self.x, self.y, t.getRadius(self, t), true)
			for x, yy in pairs(grids) do for y in pairs(yy) do
				local actor = game.level.map(x, y, game.level.map.ACTOR)
				if actor and actor ~= self and actor:reactionToward(self) < 0 then
					if not actor:hasEffect(actor.EFF_DIM_VISION) then
						if not silent then game.logPlayer(self, "적들이 보고 있는 동안에는 은신할 수 없습니다!") end
						return nil
					end
				end
			end end
		end
		return true
	end,
	activate = function(self, t)
		local res = {
			stealth = self:addTemporaryValue("stealth", t.getStealthPower(self, t)),
			lite = self:addTemporaryValue("lite", -1000),
			infra = self:addTemporaryValue("infravision", 1),
		}
		self:resetCanSeeCacheOf()
		if self.updateMainShader then self:updateMainShader() end
		return res
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("stealth", p.stealth)
		self:removeTemporaryValue("infravision", p.infra)
		self:removeTemporaryValue("lite", p.lite)
		self:resetCanSeeCacheOf()
		if self.updateMainShader then self:updateMainShader() end
		return true
	end,
	info = function(self, t)
		local stealthpower = t.getStealthPower(self, t) + (self:attr("inc_stealth") or 0)
		local radius = t.getRadius(self, t)
		return ([[은신 상태가 되어, 적들이 자신을 발견하지 못하게 합니다. (은신 수치 +%d , 교활함 능력치 기반)
		성공적으로 은신을 하면 적들이 자신의 정확한 위치를 알지 못하거나, 아예 자신의 존재를 모르게 됩니다. (매 턴마다 은신의 성공 여부를 다시 계산합니다)
		은신 상태에서는 광원 반경이 0 으로 줄어들며, 중갑이나 판갑을 입으면 은신을 사용할 수 없습니다.
		주변 %d 칸 반경에 적이 보이면, 은신 상태가 될 수 없습니다.]]):
		format(stealthpower, radius)
	end,
}

newTalent{
	name = "Shadowstrike",
	kr_name = "그림자 베기",
	type = {"cunning/stealth", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getMultiplier = function(self, t) return self:getTalentLevel(t) / 7 end,
	info = function(self, t)
		local multiplier = t.getMultiplier(self, t)
		return ([[은신 중에 적을 공격했으며 적이 자신의 존재를 알아채지 못했을 경우, 자동적으로 치명타가 발생합니다.
		그림자 베기는 일반적인 치명타 공격보다 %.02f%% 더 큰 치명타 피해를 줍니다.]]):
		format(multiplier * 100)
	end,
}

newTalent{
	name = "Hide in Plain Sight",
	kr_name = "존재감 없는 자",
	type = {"cunning/stealth",3},
	require = cuns_req3,
	no_energy = true,
	points = 5,
	stamina = 20,
	cooldown = 40,
	tactical = { DEFEND = 2 },
	getChance = function(self, t) return 40 + self:getTalentLevel(t) * 7 end,
	action = function(self, t)
		if self:isTalentActive(self.T_STEALTH) then return end

		self.talents_cd[self.T_STEALTH] = nil
		self.changed = true
		self.hide_chance = t.getChance(self, t)
		self:useTalent(self.T_STEALTH)
		self.hide_chance = nil

		for uid, e in pairs(game.level.entities) do
			if e.ai_target and e.ai_target.actor == self then e:setTarget(nil) end
		end

		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[적들이 보고 있는 동안에도, %d%% 확률로 은신에 들어갈 수 있게 됩니다. 이 기술은 은신 기술의 재사용 대기시간도 초기화시켜주며, 자신을 추적하는 적들도 떨쳐낼 수 있습니다.]]):
		format(chance)
	end,
}

newTalent{
	name = "Unseen Actions",
	kr_name = "보이지 않는 행동",
	type = {"cunning/stealth", 4},
	require = cuns_req4,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return 10 + self:getTalentLevel(t) * 9 end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[은신 중에 행동 (공격, 도구 사용 등) 을 해도, %d%% 확률로 은신 상태가 해제되지 않게 됩니다.]]):
		format(chance)
	end,
}
