-- ToME - Tales of Maj'Eyal
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
	name = "Bow Mastery",
	kr_display_name = "활 숙련",
	type = {"technique/archery-bow", 1},
	points = 5,
	require = { stat = { dex=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[활을 사용할 때 물리력을 %d , 활 피해량을 %d%% 증가시킵니다.
		또한, 재장전을 할 때:
		2 레벨에는 턴 당 장전량이 1 증가하며,
		4 레벨에는 턴 당 장전량이 2 증가하며,
		5 레벨에서는 턴 당 장전량이 3 증가합니다.
		]]):
		format(damage, inc * 100)
	end,
}

newTalent{
	name = "Piercing Arrow",
	kr_display_name = "관통 사격",
	type = {"technique/archery-bow", 2},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req2,
	range = archery_range,
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("bow") then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이 필요합니다.") end return false end return true end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "활을 장착해야 합니다!") return nil end

		local targets = self:archeryAcquireTargets({type="beam"}, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, {type="beam"}, {mult=self:combatTalentWeaponDamage(t, 1, 1.5), apr=1000})
		return true
	end,
	info = function(self, t)
		return ([[어떤 것이든 꿰뚫는 화살을 쏴서, 다수의 대상을 관통하여 방어도를 무시하고 %d%% 의 무기 피해를 줍니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1, 1.5))
	end,
}

newTalent{
	name = "Dual Arrows",
	kr_display_name = "이중 사격",
	type = {"technique/archery-bow", 3},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	require = techs_dex_req3,
	range = archery_range,
	radius = 1,
	tactical = { ATTACKAREA = { weapon = 1 } },
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("bow") then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이 필요합니다.") end return false end return true end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "활을 장착해야 합니다!") return nil end

		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {limit_shots=2})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.2, 1.9)})
		return true
	end,
	info = function(self, t)
		return ([[대상에게 화살을 동시에 두 발 쏴서 대상과, 인접한 다른 대상에게 %d%% 의 무기 피해를 줍니다.
		이 기술은 체력을 전혀 소모하지 않습니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1.2, 1.9))
	end,
}

newTalent{
	name = "Volley of Arrows",
	kr_display_name = "집중 사격",
	type = {"technique/archery-bow", 4},
	no_energy = "fake",
	points = 5,
	cooldown = 12,
	stamina = 35,
	require = techs_dex_req4,
	range = archery_range,
	radius = function(self, t)
		return 2 + self:getTalentLevel(t)/3
	end,
	direct_hit = true,
	tactical = { ATTACKAREA = { weapon = 2 } },
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), selffire=false}
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("bow") then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이 필요합니다.") end return false end return true end,
	action = function(self, t)
		if not self:hasArcheryWeapon("bow") then game.logPlayer(self, "활을 장착해야 합니다!") return nil end

		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg)
		if not targets then return end
		self:archeryShoot(targets, t, {type="bolt", selffire=false}, {mult=self:combatTalentWeaponDamage(t, 0.6, 1.3)})
		return true
	end,
	info = function(self, t)
		return ([[%d 칸 반경의 지역에 화살을 퍼부어 %d%% 의 무기 피해를 줍니다.]])
		:format(2 + self:getTalentLevel(t)/3,
		100 * self:combatTalentWeaponDamage(t, 0.6, 1.3))
	end,
}
