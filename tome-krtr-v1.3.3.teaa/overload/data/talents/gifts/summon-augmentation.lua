-- ToME - Tales of Maj'Eyal
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
	name = "Rage",
	kr_name = "분노",
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
	kr_name = "소환수 폭발",
	type = {"wild-gift/summon-augmentation", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8, 0.5, 0, 0, true)) end,
	requires_target = true,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, first_target="friend"}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon or not target.wild_gift_detonate then return nil end

		local dt = self:getTalentFromId(target.wild_gift_detonate)

		if not dt.on_detonate then
			game.logPlayer("당신은 이 소환수를 폭발시킬 수 없습니다.")
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
		- 불꽃뿜는 릿치: 화염구 폭발
		- 히드라: 번개나 산성 혹은 중독성 폭발
		- 서리나무: 얼음 구체 폭발
		- 화염 드레이크: 화염의 구름 생성
		- 전투견: 물리 피해를 주는 폭발
		- 젤리: 대상을 느리게 만드는 슬라임 덩어리 폭발
		- 미노타우르스: 모든 생명체에게 출혈효과를 주는 날카로운 폭발
		- 암석 골렘: 모든 생명체에게 밀어내기 효과
		- 거북이: 우호적인 모든 생명체에게 작은 등껍질 방패 부여
		- 거미: 주변의 모든 적들을 속박
		추가적으로, 임의의 소환기술의 재사용 대기시간이 사라집니다.
		적대적 효과는 시전자와 다른 소환수들에게는 영향을 주지 않습니다.
		기술의 효과는 의지 능력치의 영향을 받아 증가합니다.]]):format(radius)
	end,
}

newTalent{
	name = "Resilience",
	kr_name = "활력",
	type = {"wild-gift/summon-augmentation", 3},
	require = gifts_req3,
	mode = "passive",
	points = 5,
	incCon = function(self, t) return math.floor(self:combatTalentScale(t, 2, 10, 0.75)) end,
	info = function(self, t)
		return ([[모든 소환수의 체격 능력치를 %d 상승시키고, 소환 기술들의 실질 기술 레벨을 %0.1f 만큼 더해 소환수의 지속 시간을 증가시킵니다. (증가된 소환 기술들의 실질 기술 레벨은 소환수의 지속 시간에만 영향을 주며, 소환수의 능력치는 증가되지 않습니다]]):format(t.incCon(self, t), self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Phase Summon",
	kr_name = "위치전환",
	type = {"wild-gift/summon-augmentation", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 25,
	range = 10,
	requires_target = true,
	np_npc_use = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target or not target.summoner or not target.summoner == self or not target.wild_gift_summon then return nil end

		local dur = t.getDuration(self, t)
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
		return ([[소환수 하나와 위치를 서로 바꿉니다. 이 기술을 사용하면 적이 당황하여, 시전자와 소환수 모두 %d 턴 동안 모든 근접 공격을 50%% 확률로 회피할 수 있게 됩니다.]]):format(t.getDuration(self, t))
	end,
}
