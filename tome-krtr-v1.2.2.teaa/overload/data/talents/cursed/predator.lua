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

newTalent{
	name = "Mark Prey",
	kr_name = "사냥감 지정",
	type = {"cursed/predator", 1},
	require = cursed_lev_req1,
	points = 5,
	tactical = { ATTACK = 3 },
	cooldown = 5,
	range = 10,
	no_energy = true,
	getMaxKillExperience = function(self, t)
		local total = 0
		
		if t then total = total + self:getTalentLevelRaw(t) end
		local t = self:getTalentFromId(self.T_ANATOMY)
		if t then total = total + self:getTalentLevelRaw(t) end
		local t = self:getTalentFromId(self.T_OUTMANEUVER)
		if t then total = total + self:getTalentLevelRaw(t) end
		local t = self:getTalentFromId(self.T_MIMIC)
		if t then total = total + self:getTalentLevelRaw(t) end
		
		return self:combatLimit(total, 0, 19.5, 1, 10, 20) --  Limit > 0
	end,
	getSubtypeDamageChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.5) * 0.15
	end,
	getTypeDamageChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.5) * 0.065
	end,
	getHateBonus = function(self, t) return self:combatTalentScale(t, 3, 10, "log")	end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff and eff.type == target.type and eff.subtype == target.subtype then
			return false
		end
		if eff then self:removeEffect(self.EFF_PREDATOR, true, true) end
		self:setEffect(self.EFF_PREDATOR, 1, { type=target.type, subtype=target.subtype, killExperience = 0, subtypeKills = 0, typeKills = 0 })
		
		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			local ef = self.tempeffect_def.EFF_PREDATOR
			ef.no_remove = false
			self:removeEffect(self.EFF_PREDATOR)
			ef.no_remove = true
		end
	end,
	info = function(self, t)
		local maxKillExperience = t.getMaxKillExperience(self, t)
		local subtypeDamageChange = t.getSubtypeDamageChange(self, t)
		local typeDamageChange = t.getTypeDamageChange(self, t)
		local hateDesc = ""
		if self:knowTalent(self.T_HATE_POOL) then
			local hateBonus = t.getHateBonus(self, t)
			hateDesc = (" 또한, 사냥 대상인 종족을 죽일 때마다 추가적으로 %d 증오를 획득할 수 있게 됩니다. 이 증오 획득량은 다른 요소에 의해 증감되지 않습니다."):format(hateBonus)
		end
		return ([[사냥할 대상을 지정하여, 대상과 같은 종류와 종족을 사냥할 때 더 효과적으로 사냥할 수 있게 됩니다. 
		사냥 대상으로 선택한 종류와 종족을 많이 죽일수록, 추가 효과도 더 강력해집니다. (같은 종류 살해시 경험치 +0.25, 같은 종족 살해시 경험치 +1) 
		살해 경험치를 %0.1f 만큼 쌓으면, 추가 효과를 최대로 볼 수 있게 됩니다. 
		사냥 대상인 종류를 공격하면 최대 %d%% 추가 피해를, 사냥 대상인 종족을 공격하면 최대 %d%% 추가 피해를 주게 됩니다.%s
		기술 레벨이 상승할 때마다, 최대 효율을 보기 위한 살해 경험치 수치가 줄어들게 됩니다.
		
		(예를 들어 '갈색 뱀' 을 사냥 대상으로 지정했다면 모든 '동물' 은 같은 종류이며, 모든 '뱀' 은 같은 종족입니다)]]):format(maxKillExperience, typeDamageChange * 100, subtypeDamageChange * 100, hateDesc)
	end,
}

newTalent{
	name = "Anatomy",
	kr_name = "해부학",
	type = {"cursed/predator", 2},
	mode = "passive",
	require = cursed_lev_req2,
	points = 5,
	getSubtypeAttackChange = function(self, t) return self:combatTalentScale(t, 5, 15.4, 0.75) end,
	getTypeAttackChange = function(self, t) return self:combatTalentScale(t, 2, 6.2, 0.75) end,
	getSubtypeStunChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^0.5, 100, 3.1, 1, 6.93, 2.23) end, -- Limit < 100%
	on_learn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	on_unlearn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	info = function(self, t)
		local subtypeAttackChange = t.getSubtypeAttackChange(self, t)
		local typeAttackChange = t.getTypeAttackChange(self, t)
		local subtypeStunChance = t.getSubtypeStunChance(self, t)
		return ([[사냥감에 대한 학습을 통해, 사냥감의 약점을 정확히 공격합니다. 사냥감으로 지정된 종류를 공격하면 정확도가 최대 %d 상승하며, 사냥감으로 지정된 종족을 공격하면 정확도가 최대 %d 상승합니다. 
		또한, 근접공격 시 최대 %0.1f%% 확률로 사냥감으로 지정된 종족을 3 턴 동안 기절시킬 수 있게 됩니다.
		기술 레벨이 상승할 때마다, 최대 효율을 보기 위한 살해 경험치 수치가 줄어들게 됩니다.]]):format(typeAttackChange, subtypeAttackChange, subtypeStunChance)
	end,
}

newTalent{
	name = "Outmaneuver",
	kr_name = "의표 찌르기",
	type = {"cursed/predator", 3},
	mode = "passive",
	require = cursed_lev_req3,
	points = 5,
	getDuration = function(self, t)
		return 10
	end,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getSubtypeChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^0.5, 100, 10, 1, 22.3, 2.23) end, -- Limit <100%
	getTypeChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^0.5, 100, 4, 1, 8.94, 2.23) end, -- Limit <100%
	getPhysicalResistChange = function(self, t) return -self:combatLimit(self:getTalentLevel(t)^0.5, 100, 8, 1, 17.9, 2.23) end, -- Limit <100%
	getStatReduction = function(self, t)
		return math.floor(math.sqrt(self:getTalentLevel(t)) * 4.3)
	end,
	on_learn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	on_unlearn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	info = function(self, t)
		local subtypeChance = t.getSubtypeChance(self, t)
		local typeChance = t.getTypeChance(self, t)
		local physicalResistChange = t.getPhysicalResistChange(self, t)
		local statReduction = t.getStatReduction(self, t)
		local duration = t.getDuration(self, t)
		return ([[근접 공격을 할 때마다 사냥감의 허를 찔러, 물리 저항력을 %d%% 낮추고 가장 높은 능력치를 %d 감소시킵니다. 사냥감으로 지정한 종류에게는 최대 %0.1f%% 확률, 사냥감으로 지정한 종족에게는 최대 %0.1f%% 확률로 허를 찌를 수 있습니다. 이 효과는 %d 턴 동안 지속되며, 연속으로 효과를 발생시킬 경우 그만큼 지속시간이 연장됩니다.
		기술 레벨이 상승할 때마다, 100%% 효율을 보기 위한 살해 경험치 수치가 줄어들게 됩니다.]]):format(-physicalResistChange, statReduction, typeChance, subtypeChance, duration)
	end,
}

newTalent{
	name = "Mimic",
	kr_name = "흉내 내기",
	type = {"cursed/predator", 4},
	mode = "passive",
	require = cursed_lev_req4,
	points = 5,
	getMaxIncrease = function(self, t) return self:combatTalentScale(t, 7, 21.6, 0.75) end,
	on_learn = function(self, t)
		self:removeEffect(self.EFF_MIMIC, true, true)
	end,
	on_unlearn = function(self, t)
		self:removeEffect(self.EFF_MIMIC, true, true)
	end,
	info = function(self, t)
		local maxIncrease = t.getMaxIncrease(self, t)
		return ([[사냥감의 강점을 흉내냅니다. 사냥감으로 지정한 종족을 죽이면, 사냥감에 맞는 능력치가 상승합니다. (모든 능력치를 합쳐 최대 %d 상승, 증오 수치에 따라 증감 적용) 기술의 지속시간은 무한하지만, 최근에 죽인 사냥감들의 능력치만 적용됩니다.
		기술 레벨이 상승할 때마다, 100%% 효율을 보기 위한 살해 경험치 수치가 줄어들게 됩니다.]]):format(maxIncrease)
	end,
}
