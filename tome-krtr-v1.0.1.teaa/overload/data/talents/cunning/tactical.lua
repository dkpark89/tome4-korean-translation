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

local function getStrikingStyle(self, dam)
	local dam = 0
	if self:isTalentActive(self.T_STRIKING_STANCE) then
		local t = self:getTalentFromId(self.T_STRIKING_STANCE)
		dam = t.getDamage(self, t)
	end
	return dam / 100
end

newTalent{
	name = "Tactical Expert",
	kr_name = "전술의 달인",
	type = {"cunning/tactical", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	getDefense = function(self, t) return (4 + self:getCun(10)) end,
	getMaximum = function(self, t) return t.getDefense(self, t) * math.ceil(self:getTalentLevel(t)) end,
	do_tact_update = function (self, t)
		local nb_foes = 0
		local act
		for i = 1, #self.fov.actors_dist do
			act = self.fov.actors_dist[i]
			if act and game.level:hasEntity(act) and self:reactionToward(act) < 0 and self:canSee(act) and act["__sqdist"] <= 2 then nb_foes = nb_foes + 1 end
		end

		local defense = nb_foes * t.getDefense(self, t)

		if defense <= t.getMaximum(self, t) then
			defense = defense
		else
			defense = t.getMaximum(self, t)
		end

		return defense
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local maximum = t.getMaximum(self, t)
		return ([[인접한 적의 숫자에 따라 회피도가 상승합니다. 적 1 명 당 회피도가 %d 상승합니다. (최대 상승 가능한 회피도 : +%d)
		기술의 효과는 교활함 능력치의 영향을 받아 증가합니다.]]):format(defense, maximum)
	end,
}

newTalent{
	name = "Counter Attack",
	kr_name = "반격",
	type = {"cunning/tactical", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 0.9) + getStrikingStyle(self, dam) end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[근접 공격을 피할 때마다, %d%% 확률로 자신을 공격한 적에게 %d%% 피해를 줍니다.
		이 공격은 자동적으로 발생하며, 턴을 소모하지 않습니다.
		맨손 격투가일 경우, 취하고 있는 자세에 따라 적에게 추가 피해를 줄 수 있습니다.
		반격 확률은 교활함 능력치의 영향을 받아 증가합니다.]]):format(self:getTalentLevel(t) * (5 + self:getCun(5, true)), damage)
	end,
}

newTalent{
	name = "Set Up",
	kr_name = "흐트러진 자세",
	type = {"cunning/tactical", 3},
	require = cuns_req3,
	points = 5,
	random_ego = "utility",
	cooldown = 12,
	stamina = 12,
	tactical = { DISABLE = 1, DEFEND = 2 },
	getPower = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 1, 25) end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)) end,
	getDefense = function(self, t) return 5 + self:combatTalentStatDamage(t, "cun", 1, 50) end,
	action = function(self, t)
		self:setEffect(self.EFF_DEFENSIVE_MANEUVER, t.getDuration(self, t), {power=t.getDefense(self, t)})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		local defense = t.getDefense(self, t)
		return ([[%d 턴 동안 회피도를 %d 상승시킵니다. 지속 시간 중에 근접 공격을 피할 때마다, 자신을 공격한 적은 치명타를 맞을 확률이 %d%% 상승하며 모든 내성이 %d 감소합니다. (중첩은 되지 않습니다)
		이 효과는 교활함 능력치의 영향을 받아 증가합니다.]])
		:format(duration, defense, power, power)
	end,
}

newTalent{
	name = "Exploit Weakness",
	kr_name = "약점 노출",
	type = {"cunning/tactical", 4},
	require = cuns_req4,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 30,
	tactical = { BUFF = 2 },
	getReductionMax = function(self, t) return 7 * self:getTalentLevel(t) end,
	do_weakness = function(self, t, target)
		target:setEffect(target.EFF_WEAKENED_DEFENSES, 3, {inc = - 5, max = - t.getReductionMax(self, t)})
	end,
	activate = function(self, t)
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL]=-10}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_damage", p.dam)
		return true
	end,
	info = function(self, t)
		local reduction = t.getReductionMax(self, t)
		return ([[공격을 통해 대상의 물리적 약점을 노출시킵니다. 적에게 주는 피해량이 10%% 감소하는 대신, 공격을 적중시킬 때마다 적의 물리 저항력이 5%% 감소합니다. (최대 %d%% 까지 감소 가능)]]):format(reduction)
	end,
}
