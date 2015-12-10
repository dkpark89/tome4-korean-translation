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

newTalent{
	name = "Feed",
	kr_name = "먹잇감",
	type = {"cursed/dark-sustenance", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	range = 7,
	hate = 0,
	tactical = { BUFF = 2, DEFEND = 1 },
	requires_target = true,
	direct_hit = true,
	getHateGain = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 2 + self:combatMindpower() * 0.02
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local tg = {type="hit", range=range}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end
		if target == self then return nil end -- avoid targeting while frozen

		if self:reactionToward(target) >= 0 or target.summoner == self then
			game.logPlayer(self, "증오 흡수는 적을 통해서만 할 수 있습니다!");
			return nil
		end

		-- remove old effect
		if self:hasEffect(self.EFF_FEED) then
			self:removeEffect(self.EFF_FEED)
		end

		local hateGain = t.getHateGain(self, t)
		local constitutionGain = 0
		local lifeRegenGain = 0
		local damageGain = 0
		local resistGain = 0

		--local tFeedHealth = self:getTalentFromId(self.T_FEED_HEALTH)
		--if tFeedHealth and self:getTalentLevelRaw(tFeedHealth) > 0 then
		--	constitutionGain = tFeedHealth.getConstitutionGain(self, tFeedHealth, target)
		--	lifeRegenGain = tFeedHealth.getLifeRegenGain(self, tFeedHealth)
		--end

		local tFeedPower = self:getTalentFromId(self.T_FEED_POWER)
		if tFeedPower and self:getTalentLevelRaw(tFeedPower) > 0 then
			damageGain = tFeedPower.getDamageGain(self, tFeedPower, target)
		end

		local tFeedStrengths = self:getTalentFromId(self.T_FEED_STRENGTHS)
		if tFeedStrengths and self:getTalentLevelRaw(tFeedStrengths) > 0 then
			resistGain = tFeedStrengths.getResistGain(self, tFeedStrengths, target)
		end

		self:setEffect(self.EFF_FEED, 40, { target=target, range=range, hateGain=hateGain, constitutionGain=constitutionGain, lifeRegenGain=lifeRegenGain, damageGain=damageGain, resistGain=resistGain })

		return true
	end,
	info = function(self, t)
		local hateGain = t.getHateGain(self, t)
		return ([[대상을 먹잇감으로 삼아, 매 턴마다 %0.1f 증오심을 흡수합니다. 이 효과는 대상이 시야 내에 있는 한 지속됩니다.
		증오심 획득량은 정신력 능력치의 효과를 받아 증가합니다.]]):format(hateGain)
	end,
}

newTalent{
	name = "Devour Life",
	kr_name = "생명력 갈취",
	type = {"cursed/dark-sustenance", 2},
	require = cursed_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	range = 7,
	tactical = { BUFF = 2, DEFEND = 1 },
	direct_hit = true,
	requires_target = true,
	getLifeSteal = function(self, t, target)
		return self:combatTalentMindDamage(t, 0, 140)
	end,
	action = function(self, t)
		local effect = self:hasEffect(self.EFF_FEED)
		if not effect then
			if self:getTalentLevel(t) >= 5 then
				local tFeed = self:getTalentFromId(self.T_FEED)
				if not tFeed.action(self, tFeed) then return nil end
				effect = self:hasEffect(self.EFF_FEED)
			else
				game.logPlayer(self, "생명력 갈취를 하기 전에, 먼저 적을 먹잇감으로 삼아야 합니다.");
				return nil
			end
		end
		if not effect then return nil end
		local target = effect.target

		if target and not target.dead then
			local lifeSteal = t.getLifeSteal(self, t)
			self:project({type="hit", talent=t, x=target.x,y=target.y}, target.x, target.y, DamageType.DEVOUR_LIFE, { dam=lifeSteal })

			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(target.x-self.x), math.abs(target.y-self.y)), "dark_torrent", {tx=target.x-self.x, ty=target.y-self.y})
			--local dx, dy = target.x - self.x, target.y - self.y
			--game.level.map:particleEmitter(self.x, self.y,math.max(math.abs(dx), math.abs(dy)), "feed_hate", { tx=dx, ty=dy })
			game:playSoundNear(self, "talents/fire")

			return true
		end

		return nil
	end,
	info = function(self, t)
		local lifeSteal = t.getLifeSteal(self, t)
		return ([[먹잇감이 된 적의 생명력을 갈취하여, %d 생명력을 흡수합니다. 이 회복 효과는 증오심이 부족해도 감소되지 않습니다. 기술 레벨이 5 이상이면, 먹잇감 기술을 사용하지 않고 바로 이 기술을 사용해도 적이 먹잇감 상태가 됩니다.
		이 효과는 정신력 능력치의 영향을 받아 증가합니다.]]):format(lifeSteal)
	end,
}

--[[
newTalent{
	name = "Feed Health",
	type = {"cursed/dark-sustenance", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	getConstitutionGain = function(self, t, target)
		local gain = math.floor((6 + self:getWil(6)) * math.sqrt(self:getTalentLevel(t)) * 0.392)
		if target then
			-- return capped gain
			return math.min(gain, math.floor(target:getCon() * 0.75))
		else
			-- return max gain
			return gain
		end
	end,
	getLifeRegenGain = function(self, t, target)
		return self.max_life * (math.sqrt(self:getTalentLevel(t)) * 0.012 + self:getWil(0.01))
	end,
	info = function(self, t)
		local constitutionGain = t.getConstitutionGain(self, t)
		local lifeRegenGain = t.getLifeRegenGain(self, t)
		return ([Enhances your feeding by transferring %d constitution and %0.1f life per turn from a targeted foe to you.
		Improves with the Willpower stat.]):format(constitutionGain, lifeRegenGain)
	end,
}
]]
newTalent{
	name = "Feed Power",
	kr_name = "공격력 갈취",
	type = {"cursed/dark-sustenance", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getDamageGain = function(self, t)
		return self:combatLimit(self:getTalentLevel(t)^0.5 * 5 + self:combatMindpower() * 0.05, 100, 0, 0, 14, 14) -- Limit < 100%
	end,
	info = function(self, t)
		local damageGain = t.getDamageGain(self, t)
		return ([[먹잇감으로 삼은 적의 피해량을 %d%% 흡수하여, 그만큼 자신의 피해량을 증가시킵니다.
		이 효과는 정신력 능력치의 영향을 받아 증가합니다.]]):format(damageGain)
	end,
}

newTalent{
	name = "Feed Strengths",
	kr_name = "저항력 갈취",
	type = {"cursed/dark-sustenance", 4},
	mode = "passive",
	require = cursed_wil_req4,
	points = 5,
	getResistGain = function(self, t)
		return self:combatLimit(self:getTalentLevel(t)^0.5 * 14 + self:combatMindpower() * 0.15, 100, 0, 0, 40, 40) -- Limit < 100%
	end,
	info = function(self, t)
		local resistGain = t.getResistGain(self, t)
		return ([[먹잇감으로 삼은 적의 저항력을 %d%% 흡수하여, 그만큼 자신의 저항력을 증가시킵니다. '전체' 저항력과 음수인 저항력은 흡수하지 않습니다.
		이 효과는 정신력 능력치의 영향을 받아 증가합니다.]]):format(resistGain)
	end,
}
