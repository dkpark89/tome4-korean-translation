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

local function combatTalentDamage(self, t, min, max)
	return self:combatTalentSpellDamage(t, min, max, (self.level + self:getWil()) * 1.2)
end

newTalent{
	name = "Unnatural Body",
	kr_name = "잠식된 육체",
	type = {"cursed/cursed-form", 1},
	mode = "passive",
	require = cursed_wil_req1,
	points = 5,
	no_unlearn_last = true,
	getHealPerKill = function(self, t)
		return combatTalentDamage(self, t, 15, 50)
	end,
	getMaxUnnaturalBodyHeal = function(self, t) -- Add up to 50% max life to pool
		return t.getHealPerKill(self, t) * 2 + self:combatTalentLimit(t, .5, 0.01, 0.03) * self.max_life
	end,
	getRegenRate = function(self, t) return 3 + combatTalentDamage(self, t, 15, 25) end,
	updateHealingFactor = function(self, t)
		local change = -0.5 + math.min(100, self:getHate()) * .005
		self.healing_factor = (self.healing_factor or 1) - (self.unnatural_body_healing_factor or 0) + change
		self.unnatural_body_healing_factor = change
	end,
	do_regenLife  = function(self, t) -- called by _M:actBase in mod.class.Actor.lua
		-- update healing factor
		t.updateHealingFactor(self, t)

		-- heal
		local maxHeal = self.unnatural_body_heal or 0
		if maxHeal > 0 then
			local heal = math.min(t.getRegenRate(self, t), maxHeal)
			local temp = self.healing_factor
			self.healing_factor = 1
			self:heal(heal, t)
			self.healing_factor = temp

			self.unnatural_body_heal = math.max(0, (self.unnatural_body_heal or 0) - heal)
		end
	end,
	on_kill = function(self, t, target) -- called by _M:die in mod.class.Actor.lua
		if target and target.max_life then
			local heal = math.min(t.getHealPerKill(self, t), target.max_life)
			if heal > 0 then
				self.unnatural_body_heal = math.min(self.life, (self.unnatural_body_heal or 0) + heal)
				self.unnatural_body_heal = math.min(self.unnatural_body_heal, t.getMaxUnnaturalBodyHeal(self, t))
			end
		end
	end,
	info = function(self, t)
		local healPerKill = t.getHealPerKill(self, t)
		local maxUnnaturalBodyHeal = t.getMaxUnnaturalBodyHeal(self, t)
		local regenRate = t.getRegenRate(self, t)

		return ([[증오의 힘이 육체를 잠식합니다. 이로 인해, 치유 효율이 증오심에 따라 50%% 에서 100%% 까지 증감합니다. (증오가 0 일 때 50%% / 증오가 100 이상일 때 100%%)		
		그리고 적을 살해할 때마다, 적의 생명력을 저장해서 자신의 생명력을 %d 회복할 수 있게 됩니다. (적의 최대 생명력 이상은 회복할 수 없으며, %d 이상은 회복할 수 없습니다) 매 턴마다 %0.1f 이상의 생명력은 회복할 수 없으며, 이는 증오심에 따른 치유 효율이나 다른 효과의 영향을 받지 않습니다.
		살육을 통한 회복량은 의지 능력치의 영향을 받아 증가합니다.]]):format(healPerKill, maxUnnaturalBodyHeal, regenRate) 
	end,
}

newTalent{
	name = "Relentless",
	kr_name = "무자비함",
	type = {"cursed/cursed-form", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.5) end, -- Limit < 100%
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "fear_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "confusion_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "knockback_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "stun_immune", t.getImmune(self, t))
	end,
	info = function(self, t)
		return ([[피에 대한 갈망이 몸의 움직임을 지배합니다. 기절, 혼란, 공포, 밀어내기 면역력이 %d%% 상승합니다.]]):format(t.getImmune(self, t)*100)
	end,
}

newTalent{
	name = "Seethe",
	kr_name = "끓어오르는 분노의 힘",
	type = {"cursed/cursed-form", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getIncDamageChange = function(self, t, increase)
		return self:combatTalentLimit(t, 60, 2, 2*2.24) * increase --I5 Limit < 60%
	end,
	info = function(self, t)
		local incDamageChangeMax = t.getIncDamageChange(self, t, 5)
		return ([[자신의 증오심과 고통으로 육체의 분노를 이끌어내는 법을 알게 되었습니다. 적에게 피해를 받을 때마다, 자신이 적에게 주는 피해량이 증가하게 됩니다. 최대 5 턴 동안 피해를 받아서, 피해량을 %d%% 까지 증가시킬 수 있습니다. 중간에 한 턴이라도 피해를 받지 않으면, 그만큼 피해 증가량도 줄어들게 됩니다.]]):format(incDamageChangeMax)
	end
}

newTalent{
	name = "Grim Resolve",
	kr_name = "냉혹한 결심",
	type = {"cursed/cursed-form", 4},
	require = cursed_wil_req4,
	mode = "passive",
	points = 5,
	getStatChange = function(self, t, increase) return math.floor(self:combatTalentScale(t, 1, 2.24) * increase) end,
	getNeutralizeChance = function(self, t) return self:combatTalentLimit(t, 60, 10, 23.4) end, -- Limit < 60%
	info = function(self, t)
		local statChangeMax = t.getStatChange(self, t, 5)
		local neutralizeChance = t.getNeutralizeChance(self, t)
		return ([[자신이 받는 고통과 당당히 맞서 싸우게 됩니다. 적에게 피해를 받을 때마다, 힘과 의지 능력치가 증가하게 됩니다. 최대 5 턴 동안 피해를 받아서, 각 능력치를 %d 까지 증가시킬 수 있습니다. 중간에 한 턴이라도 피해를 받지 않으면, 그만큼 능력치 증가량도 줄어들게 됩니다. 
		그리고 이 효과가 지속되는 동안, 매 턴마다 %d%% 확률로 자신에게 걸린 독과 질병을 이겨낼 수 있게 됩니다.]]):format(statChangeMax, neutralizeChance)
	end,
}

