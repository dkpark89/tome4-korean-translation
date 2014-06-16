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
	name = "Bind",
	kr_name = "묶기",
	type = {"psionic/grip", 1},
	require = psi_cun_high1,
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	psi = 10,
	tactical = { DISABLE = 2 },
	range = function(self, t)
		local r = 5
		local mult = 1 + 0.01*self:callTalent(self.T_REACH, "rangebonus")
		return math.floor(r*mult)
	end,
	getDuration = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 3, 10))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dur = t.getDuration(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_PSIONIC_BIND, dur, {power=1, apply_power=self:combatMindpower()})
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		return ([[염력의 끈으로 대상을 묶어, %d 턴 동안 이동하지 못하게 만듭니다. 
		지속시간은 정신력의 영향을 받아 증가합니다.]]):
		format(dur)
	end,
}

newTalent{
	name = "Greater Telekinetic Grasp",
	kr_name = "향상된 염동적 악력",
	type = {"psionic/grip", 4},
	require = psi_cun_high4,
	hide = true,
	points = 5,
	mode = "passive",
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.50) end, -- Limit < 100%
	stat_sub = function(self, t) -- called by _M:combatDamage in mod\class\interface\Combat.lua
		return self:combatTalentScale(t, 0.64, 0.80)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "disarm_immune", t.getImmune(self, t))
	end,
	info = function(self, t)
		local boost = 100 * t.stat_sub(self, t)
		return ([[정신을 집중하여, 육체의 악력과 염동적 악력을 동시에 상승시킵니다. 이를 통해 다음과 같은 효과가 발생합니다.
		- 무장해제 면역력이 %d%% 증가합니다.
		- 염동력으로 쥐고 있는 무기의 피해량과 정확도를 결정하는, 의지력과 교활함 능력치의 적용 비율이 %d%% 가 됩니다. (원래는 각 능력치의 60%% 만큼 무기에 적용)
		- 기술 레벨이 5 이상이면, 염동력으로 쥔 보석이나 마석을 한 단계 높은 수준의 보석이나 마석인 것처럼 사용할 수 있게 됩니다.]]):
		format(t.getImmune(self, t)*100, boost)
	end,
}
