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

-- Compute the total detection ability of enemies to see through stealth
-- Each foe loses 10% detection power per tile beyond range 1
-- returns detect, closest = total detection power, distance to closest enemy
local function stealthDetection(self, radius)
	if not self.x then return nil end
	local dist = 0
	local closest, detect = math.huge, 0
	for i, act in ipairs(self.fov.actors_dist) do
		dist = core.fov.distance(self.x, self.y, act.x, act.y)
		if dist > radius then break end
		if act ~= self and act:reactionToward(self) < 0 and not act:attr("blind") and (not act.fov or not act.fov.actors or act.fov.actors[self]) then
			detect = detect + act:combatSeeStealth() * (1.1 - dist/10) -- detection strength reduced 10% per tile
			if dist < closest then closest = dist end
		end
	end
	return detect, closest
end

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
	getStealthPower = function(self, t) return 10 + self:combatScale(math.max(1,self:getCun(10, true) * self:getTalentLevel(t)), 5, 1, 54, 50) end, --TL 5, cun 100 = 54
	getRadius = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 8.9, 4.6)) end, -- Limit to range >= 1
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(t.id) then return true end
		local armor = self:getInven("BODY") and self:getInven("BODY")[1]
		if armor and (armor.subtype == "heavy" or armor.subtype == "massive") then
			if not silent then game.logPlayer(self, "갑옷을 입으면 은신할 수 없습니다!") end
			return nil
		end

		-- Check nearby actors detection ability
		if not self.x or not self.y or not game.level then return end
		if not rng.percent(self.hide_chance or 0) then
			if stealthDetection(self, t.getRadius(self, t)) > 0 then 
				if not silent then game.logPlayer(self, "너무 가까이에 적이 있어서, 은신 상태가 될 수 없습니다!") end 
				return nil
			end
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
	getMultiplier = function(self, t) return self:combatTalentScale(t, 1/7, 5/7) end,
	info = function(self, t)
		local multiplier = t.getMultiplier(self, t)
		return ([[은신 중에 적을 공격했으며 적이 자신의 존재를 알아채지 못했을 경우, 공격은 자동적으로 치명타가 됩니다.
		그림자 베기는 적과 3 칸 이내로 떨어져서 공격할 경우 일반 치명타보다 +%.02f%% 더 높은 피해를 주지만, 그 이상 떨어진 상태에서 공격할 경우 피해량 증가 수치가 감소하게 됩니다. (10 칸 떨어진 곳에서 공격할 경우 피해량 증가 0%%)
		이 피해량 증가는 주문 및 정신 치명타에도 똑같이 적용되며, 이 공격을 통해 적이 자신의 존재를 알아챘더라도 기술의 효과는 적용됩니다.]]): 
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
	-- Assume level 50 w/100 cun --> stealth = 54, detection = 50
	-- 90% (~= 47% chance against 1 opponent (range 1) at talent level 1, 270% (~= 75% chance against 1 opponent (range 1) and 3 opponents (range 6) at talent level 5
	-- vs flat 47% at 1, 75% @ 5 previous
	stealthMult = function(self, t) return self:combatTalentScale(t, 0.9, 2.7) end,
	getChance = function(self, t, fake)
		local netstealth = t.stealthMult(self, t) * (self:callTalent(self.T_STEALTH, "getStealthPower") + (self:attr("inc_stealth") or 0))
		if fake then return netstealth end
		local detection = stealthDetection(self, 10) -- Default radius 10
		if detection <= 0 then return 100 end
		local _, chance = self:checkHit(netstealth, detection)
		print("Hide in Plain Sight: "..netstealth.." stealth vs "..detection.." detection -->chance "..chance)
		return chance
	end,
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
	-- Note it would be easy to include the %chance of success from the player's current location here
	info = function(self, t)
		return ([[적들이 보고 있는 중에서도 은신할 수 있는 방법을 배우게 됩니다. 적들이 얼마나 가까이 있는지와 상관없이 은신 시도를 할 수 있지만, 적이 많고 가까이 있을수록 성공률이 떨어지게 됩니다.
		은신 성공 확률은 자기 은신 수치의 %0.2f 배 (즉, 은신 수치 %d), 그리고 자신을 보고 있는 모든 적들의 은신 감지력을 비교하여 결정됩니다. (계산시, 자신과 1 칸 떨어져 있을수록 적의 은신 감지력은 10%% 씩 감소합니다) 
		자신을 직접 보고 있는 적이 없을 경우, 은신은 언제나 성공합니다.
		성공적으로 은신을 하면 적들이 자신의 정확한 위치를 알지 못하거나, 아예 자신의 존재를 모르게 됩니다.
		또한 이 기술을 사용하면 은신 기술의 재사용 대기시간이 초기화됩니다.]]): 
		format(t.stealthMult(self, t), t.getChance(self, t, true))
	end,
}

newTalent{
	name = "Unseen Actions",
	kr_name = "보이지 않는 행동",
	type = {"cunning/stealth", 4},
	require = cuns_req4,
	mode = "passive",
	points = 5,
	-- Assume level 50 w/100 cun --> stealth = 54, detection = 50
	-- 40% (~= 20% chance against 1 opponent (range 1) at talent level 1, 189% (~= 55% chance against 1 opponent (range 1) and 2 opponents (range 6) at talent level 5
	-- vs flat 19% at 1, 55% @ 5 previous
	stealthMult = function(self, t) return self:combatTalentScale(t, 0.4, 1.89) end,
	getChance = function(self, t, fake)
		local netstealth = t.stealthMult(self, t) * (self:callTalent(self.T_STEALTH, "getStealthPower") + (self:attr("inc_stealth") or 0))
		if fake then return netstealth end
		local detection = stealthDetection(self, 10)
		if detection <= 0 then return 100 end
		local _, chance = self:checkHit(netstealth, detection)
		print("Unseen Actions: "..netstealth.." stealth vs "..detection.." detection -->chance "..chance)
		return chance
	end,
	-- Note it would be easy to include the %chance of success from the player's current location here
	info = function(self, t)
		return ([[은신 상태를 해제시키는 행동 (공격, 도구 사용, ...) 을 해도 은신 상태를 유지할 수 있게 되지만, 적이 많고 가까이 있을수록 성공률이 떨어지게 됩니다. 성공 확률은 자기 은신 수치의 %0.2f 배 (즉, 은신 수치 %d), 그리고 자신을 보고 있는 모든 적들의 은신 감지력을 비교하여 결정됩니다. (계산시, 자신과 1 칸 떨어져 있을수록 적의 은신 감지력은 10%% 씩 감소합니다) 
		적에게 감지되지 않았을 경우의 기본 성공률은 100%% 이며, 캐릭터의 행운 역시 영향을 미칩니다.]]): 
		format(t.stealthMult(self, t), t.getChance(self, t, true))
	end,
}
