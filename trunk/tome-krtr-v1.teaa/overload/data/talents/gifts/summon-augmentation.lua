﻿-- ToME - Tales of Maj'Eyal
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

newTalent{
	name = "Rage",
	kr_display_name = "분노",
	type = {"wild-gift/summon-augmentation", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 5,
	cooldown = 15,
	range = 10,
	np_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend"}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon then return nil end
		target:setEffect(target.EFF_ALL_STAT, 10, {power=self:mindCrit(self:combatTalentMindDamage(t, 10, 100))/4})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[하나의 소환수에게 살육의 본능을 심어, 10 턴 동안 모든 능력치가 %d 상승하게 됩니다.]]):format(self:combatTalentMindDamage(t, 10, 100)/4)
	end,
}

newTalent{
	name = "Detonate",
	kr_display_name = "소환수 폭발",
	type = {"wild-gift/summon-augmentation", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 10,
	radius = function(self, t)
		return 3 + self:getTalentLevelRaw(t)
	end,
	requires_target = true,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend"}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon or not target.wild_gift_detonate then return nil end

		local dt = self:getTalentFromId(target.wild_gift_detonate)

		if not dt.on_detonate then
			game.logPlayer("You may not detonate this summon.")
			return nil
		end

		dt.on_detonate(self, t, target)
		target:die(self)

		local l = {}
		for tid, cd in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if t.is_summon then l[#l+1] = tid end
		end
		if #l > 0 then 
			self.talents_cd[rng.table(l)] = nil
		end

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[소환수를 자폭시킵니다. 자폭은 주변 %d 칸 반경에 영향을 줍니다.
		- Ritch Flamespitter: Explodes into a fireball
		- Hydra: Explodes into a ball of lightning, acid or poison
		- Rimebark: Explodes into an iceball
		- Fire Drake: Generates a cloud of fire
		- War Hound: Explodes into a ball of physical damage
		- Jelly: Explodes into a ball of slowing slime
		- Minotaur: Explodes into a sharp ball, cutting all creatures
		- Stone Golem: Knocks back all creatures
		- Turtle: Grants a small shell shield to all friendly creatures
		- Spider: Pins all foes around
		In addition, a random summon will come off cooldown.
		Hostile effects will not hit you or your other summons.
		The effects improve with your Willpower.]]):format(radius)
	end,
}

newTalent{
	name = "Resilience",
	kr_display_name = "활력",
	type = {"wild-gift/summon-augmentation", 3},
	require = gifts_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[모든 소환수의 지속시간과 체격 능력치를 증가시킵니다.]])
	end,
}

newTalent{
	name = "Phase Summon",
	kr_display_name = "위치전환",
	type = {"wild-gift/summon-augmentation", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 10,
	requires_target = true,
	np_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon then return nil end

		local dur = 1 + self:getTalentLevel(t)
		self:setEffect(self.EFF_EVASION, dur, {chance=50})
		target:setEffect(target.EFF_EVASION, dur, {chance=50})

		-- Displace
		game.level.map:remove(self.x, self.y, Map.ACTOR)
		game.level.map:remove(target.x, target.y, Map.ACTOR)
		game.level.map(self.x, self.y, Map.ACTOR, target)
		game.level.map(target.x, target.y, Map.ACTOR, self)
		self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[소환수 하나와 위치를 서로 바꿉니다. 이 기술을 사용하면 적이 당황하여, 시전자와 소환수 모두 %d 턴 동안 모든 공격을 50%% 확률로 회피할 수 있게 됩니다.]]):format(1 + self:getTalentLevel(t))
	end,
}
