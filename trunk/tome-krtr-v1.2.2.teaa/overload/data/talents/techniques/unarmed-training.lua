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

-- Empty Hand adds extra scaling to gauntlet and glove attacks based on character level.

newTalent{
	name = "Empty Hand",
	kr_name = "맨주먹의 힘",
	type = {"technique/unarmed-other", 1},
	innate = true,
	hide = true,
	mode = "passive",
	points = 1,
	no_unlearn_last = true,
	on_learn = function(self, t)
		local fct = function()
			self.before_empty_hands_combat = self.combat
			self.combat = table.clone(self.combat, true)
			self.combat.physspeed = math.min(0.6, self.combat.physspeed or 1000)
			if not self.combat.sound then self.combat.sound = {"actions/punch%d", 1, 4} end
			if not self.combat.sound_miss then self.combat.sound_miss = "actions/melee_miss" end
		end
		if type(self.combat.dam) == "table" then
			game:onTickEnd(fct)
		else
			fct()
		end
	end,
	on_unlearn = function(self, t)
		self.combat = self.before_empty_hands_combat
	end,
	getDamage = function(self, t) return self.level * 0.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[무기를 사용하지 않을 때, 물리력을 %d 증가시킵니다.
		물리력 상승량은 캐릭터의 레벨에 따라 증가합니다.]]):
		format(damage)
	end,
}

-- This is by far the most powerful weapon tree in the game, loosely because you lose 2 weapon slots to make use of it and weapon stats are huge
-- Regardless, it gives much less damage than most weapon trees and is slightly more frontloaded
newTalent{
	name = "Unarmed Mastery",
	kr_name = "맨손 격투 수련",
	type = {"technique/unarmed-training", 1},
	points = 5,
	require = { stat = { cun=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 4 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[무기를 사용하지 않으면 물리력이 %d 증가하고, 모든 맨손 격투의 피해량이 %d%% 증가합니다. (발차기와 잡기류 포함)
		격투가는 캐릭터 레벨 당 0.5 의 물리력을 추가로 얻고 (현재 격투가의 추가 물리력 : %0.1f), 다른 직업보다 맨손 공격 속도가 40%% 더 빠릅니다.]]):
		format(damage, 100*inc, self.level * 0.5)
	end,
}

newTalent{
	name = "Unified Body",
	kr_name = "합일의 경지", 
	type = {"technique/unarmed-training", 2},
	require = techs_cun_req2,
	mode = "passive",
	points = 5,
	tactical = { BUFF = 2 },
	getStr = function(self, t) return math.ceil(self:combatTalentScale(t, 1.5, 7.5, 0.75) + self:combatTalentStatDamage(t, "cun", 2, 10)) end,
	getCon = function(self, t) return math.ceil(self:combatTalentScale(t, 1.5, 7.5, 0.75) + self:combatTalentStatDamage(t, "dex", 5, 25)) end,

	passives = function(self, t, tmptable)
		self:talentTemporaryValue(tmptable, "inc_stats", {[self.STAT_CON] = t.getCon(self, t)})
		self:talentTemporaryValue(tmptable, "inc_stats", {[self.STAT_STR] = t.getStr(self, t)})	
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_DEX or stat == self.STAT_CUN then
			self:updateTalentPassives(t)
		end
	end,
	info = function(self, t)
		return ([[맨손 격투 수련을 통해 합일의 경지에 이릅니다. 교활함 능력치에 비례해 힘 능력치가 %d 상승하며, 민첩 능력치에 비례해 건강 능력치가 %d 상승합니다.]]):format(t.getStr(self, t), t.getCon(self, t)) 
	end
}

newTalent{
	name = "Heightened Reflexes",
	kr_name = "반사신경 향상",
	type = {"technique/unarmed-training", 3},
	require = techs_cun_req3,
	mode = "passive",
	points = 5,
	getPower = function(self, t) return self:combatTalentScale(t, 0.1, 2, 0.75) end,
	do_reflexes = function(self, t)
		self:setEffect(self.EFF_REFLEXIVE_DODGING, 1, {power=t.getPower(self, t)})
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[발사체가 자신을 향해 날아올 때, 전체 속도가 1 턴 동안 %d%% 증가합니다. 이동 이외의 행동을 하면 이 효과는 사라집니다.]]):
		format(power * 100)
	end,
}

-- It's a bit wierd that this works against mind attacks
newTalent{
	name = "Reflex Defense",
	kr_name = "반사적 회피", 
	type = {"technique/unarmed-training", 4},
	require = techs_cun_req4, -- bit icky since this is clearly dex, but whatever, cun turns defense special *handwave*
	points = 5,
	mode = "passive",
	getDamageReduction = function(self, t) 
		return self:combatTalentLimit(t, 1, 0.15, 0.50) * self:combatLimit(self:combatDefense(), 1, 0.15, 10, 0.5, 50) -- Limit < 100%, 25% for TL 5.0 and 50 defense
	end,
	getDamagePct = function(self, t)
		return self:combatTalentLimit(t, 0.1, 0.3, 0.15) -- Limit trigger > 10% life
	end,
	callbackOnHit = function(self, t, cb)
		if ( cb.value > (t.getDamagePct(self, t) * self.max_life) ) then
			local damageReduction = cb.value * t.getDamageReduction(self, t)
			cb.value = cb.value - damageReduction
			game.logPlayer(self, "#GREEN#몸을 복잡한 방식으로 뒤틀어, 피해량을 #ORCHID#" .. math.ceil(damageReduction) .. "#LAST# 감소시켰습니다.") 
		end
		return cb.value
	end, 
	info = function(self, t)
		return ([[인체 생리학에 대한 높은 이해를 통해, 반사신경을 새로운 방식으로 사용합니다. 어떠한 방식으로든 최대 생명력의 %d%% 이상 피해를 입을 경우, 그 피해량을 %0.1f%% 감소시킵니다. 
		피해 감소량은 회피도의 영향을 받아 증가합니다.]]): 
		format(t.getDamagePct(self, t)*100, t.getDamageReduction(self, t)*100 )
	end,
}
