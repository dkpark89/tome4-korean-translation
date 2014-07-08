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
	name = "Corrupted Strength",
	kr_name = "오염된 힘",
	type = {"corruption/reaving-combat", 1},
	mode = "passive",
	points = 5,
	vim = 8,
	require = str_corrs_req1,
	-- called by _M:getOffHandMult function in mod\class\interface\Combat.lua
	getoffmult = function(self,t) return self:combatTalentLimit(t, 1, 0.53, 0.69) end, -- limit <100%
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self:attr("allow_any_dual_weapons", 1)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:attr("allow_any_dual_weapons", -1)
		end
	end,
	info = function(self, t)
		return ([[보조 무기로 모든 한손 무기를 사용할 수 있게 되며, 보조 무기의 피해 효율이 %d%% 가 됩니다.
		그리고 1 턴 이상의 시전시간을 갖는 주문을 사용할 때, 턴 소모 없이 시전자 근처의 무작위한 적에게 무기 피해의 %d%% 에 해당하는 황폐 속성 피해를 줍니다.]]):
		format(100*t.getoffmult(self,t), 100 * self:combatTalentWeaponDamage(t, 0.5, 1.1))
	end,
}

newTalent{
	name = "Bloodlust",
	kr_name = "피의 굻주림",
	type = {"corruption/reaving-combat", 2},
	mode = "passive",
	require = str_corrs_req2,
	points = 5,
	-- _M:combatSpellpower references effect in mod\class\interface\Combat.lua
	-- Effect is refreshed in function _M:onTakeHit(value, src) in mod\class\Actor.lua
	-- getParams called in definition of EFF_BLOODLUST in data\timed_effects\magical.lua
	getParams = function(self, t) -- returns maxSP per turn, max duration
		return self:combatTalentScale(t, 1, 5, 0.75), math.floor(self:combatTalentScale(t, 2, 6))
	end,
	info = function(self, t)
		local SPbonus, maxDur = t.getParams(self, t)
		return ([[하나의 적에게 피해를 입힐 때마다, 피의 분노 상태에 들어가 주문력이 1 상승합니다. (한 턴에 최대 %d 주문력, 전체 최대 %d 주문력)
		또한 현재 유지 중인 다른 분노의 지속시간이 늘어납니다.
		피의 분노는 %d 턴 동안 유지되며, 적에게 피해를 주지 않은 턴에는 증가한 주문력이 %0.1f%% 감소합니다.]]): 
		format(SPbonus, SPbonus*6, maxDur, 100/maxDur)
	end,
}

newTalent{
	name = "Carrier",
	kr_name = "보균자",
	type = {"corruption/reaving-combat", 3},
	mode = "passive",
	require = str_corrs_req3,
	points = 5,
	getDiseaseImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.20, 0.75) end, -- Limit < 100%
	-- called by _M:attackTargetWith in mod.class.interface.Combat.lua
	getDiseaseSpread = function(self, t) return self:combatTalentLimit(t, 100, 5, 20) end, --Limit < 100%
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "disease_immune", t.getDiseaseImmune(self, t))
	end,
	info = function(self, t)
		return ([[질병 면역력이 %d%% 상승하며, 근접 공격을 할 때마다 %d%% 확률로 대상에게 무작위한 질병을 감염시킵니다.
		(유행성 질병 기술에 걸린 적에게는 근접 공격이 황폐 피해처럼 적용됩니다.)]]): 
		format(t.getDiseaseImmune(self, t)*100, t.getDiseaseSpread(self, t))
	end,
}

newTalent{
	name = "Acid Blood",
	kr_name = "산성 피",
	type = {"corruption/reaving-combat", 4},
	mode = "passive",
	require = str_corrs_req4,
	points = 5,
	do_splash = function(self, t, target)
		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 5, 30))
		local atk = self:combatTalentSpellDamage(t, 15, 35)
		local armor = self:combatTalentSpellDamage(t, 15, 40)
		if self:getTalentLevel(t) >= 3 then
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=self, dam=dam, atk=atk, armor=armor})
		else
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=self, dam=dam, atk=atk})
		end
	end,
	info = function(self, t)
		return ([[피가 산성 혼합물이 되어, 자신을 공격한 적은 산성 피해를 받게 됩니다.
		자신을 공격한 적은 5 턴 동안 매 턴마다 %0.2f 산성 피해를 받게 되며, 정확도가 %d 떨어지게 됩니다.
		기술 레벨이 3 이상이면, 추가적으로 적의 방어도를 5 턴 동안 %d 감소시킵니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 5, 30)), self:combatTalentSpellDamage(t, 15, 35), self:combatTalentSpellDamage(t, 15, 40))
	end,
}
