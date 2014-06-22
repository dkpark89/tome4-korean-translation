-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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

require "engine.krtrUtils"

local sling_equipped = function(self, silent)
	if not self:hasArcheryWeapon("sling") then
		if not silent then
			game.logPlayer(self, "투석구를 장착해야 합니다!")
		end
		return false
	end
	return true
end

-- calc_all is so the info can show all the effects.
local sniper_bonuses = function(self, calc_all)
	local bonuses = {}
	local t = self:getTalentFromId("T_SKIRMISHER_SLING_SNIPER")
	local level = self:getTalentLevel(t)

	if level > 0 or calc_all then
		bonuses.crit_chance = self:combatTalentScale(t, 3, 10)
		bonuses.crit_power = self:combatTalentScale(t, 0.1, 0.2, 0.75)
	end
	if level >= 5 or calc_all then
		bonuses.resists_pen = {[DamageType.PHYSICAL] = self:combatStatLimit("cun", 100, 15, 50)} -- Limit < 100%
	end
	return bonuses
end

-- Add the phys pen to self right before the shot hits.
local pen_on = function(self, talent, tx, ty, tg, target)
	if target and tg and tg.archery and tg.archery.resists_pen then
		self.temp_skirmisher_sling_sniper = self:addTemporaryValue("resists_pen", tg.archery.resists_pen)
	end
end

-- The action for each of the shots.
local fire_shot = function(self, t)
	local tg = {type = "hit"}

	local targets = self:archeryAcquireTargets(tg, table.clone(t.archery_target_parameters))
	if not targets then return end
	local bonuses = sniper_bonuses(self)
	local params = {mult = t.damage_multiplier(self, t)}
	if bonuses.crit_chance then params.crit_chance = bonuses.crit_chance end
	if bonuses.crit_power then params.crit_power = bonuses.crit_power end
	if bonuses.resists_pen then params.resists_pen = bonuses.resists_pen end
	self:archeryShoot(targets, t, {type = "hit", speed = 200}, params) -- Projectile speed because using "hit" with slow projectiles is infuriating
	return true
end

-- Remove the phys pen from self right after the shot is finished.
local pen_off = function(self, talent, target, x, y)
	if self.temp_skirmisher_sling_sniper then
		self:removeTemporaryValue("resists_pen", self.temp_skirmisher_sling_sniper)
	end
end

local shot_cooldown = function(self, t)
	if self:getTalentLevel(self.T_SKIRMISHER_SLING_SNIPER) >= 3 then
		return 6
	else
		return 8
	end
end

newTalent {
	short_name = "SKIRMISHER_KNEECAPPER",
	name = "Kneecapper",
	kr_name = "무릎 깨기",
	type = {"cunning/called-shots", 1},
	require = techs_cun_req1,
	points = 5,
	no_energy = "fake",
	random_ego = "attack",
	tactical = {ATTACK = {weapon = 1}, DISABLE = 1},
	stamina = 10,
	cooldown = shot_cooldown,
	requires_target = true,
	range = archery_range,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	pin_duration = function(self, t)
		return math.floor(self:combatTalentScale(t, 1, 2))
	end,
	slow_duration = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 4.7))
	end,
	slow_power = function(self, t)
		return self:combatLimit(self:getCun()*.5 + self:getTalentLevel(t)*10, 0.6, 0.2, 15, 0.5, 100) --Limit < 60%, 20% at TL 1 for 10 Cun, 50% at TL5, Cun 100
	end,
	archery_onreach = pen_on,
	archery_onmiss = pen_off,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_SLOW_MOVE, t.slow_duration(self, t), {power = t.slow_power(self, t), apply_power = self:combatAttack()})
		if target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, t.pin_duration(self, t), {apply_power = self:combatAttack()})
		else
			game.logSeen(target, "%s 속박되지 않았습니다.", (target.kr_name or target.name):capitalize():addJosa("가"))
		end
		pen_off(self, t, target, x, y)
	end,
	archery_target_parameters = {one_shot = true},
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 1.5, 1.9)
	end,
	action = fire_shot,
	info = function(self, t)
		return ([[대상의 무릎 (혹은 구조상 이동에 중요한 부분) 을 공격하여, %d%% 의 무기 피해를 주고 %d 턴 동안 이동하지 못하게 만듭니다. 또한 속박 상태가 끝난 이후에도 대상은 %d 턴 동안 이동속도가 %d%% 감소하게 됩니다.
		시전자와 대상 사이의 다른 적들은 이 공격의 영향을 받지 않습니다.
		감속 효과는 교활 능력치의 영향을 받아 증가합니다.]])
		:format(t.damage_multiplier(self, t) * 100,
				t.pin_duration(self, t),
				t.slow_duration(self, t),
				t.slow_power(self, t) * 100) --@ 변수 순서 조정
				
	end,
}

-- This serves two primary roles
-- 1.  Core high damage shot
-- 2.  Sniping off-targets like casters in any situation in potentially one shot
newTalent {
	short_name = "SKIRMISHER_THROAT_SMASHER",
	name = "Kill Shot",
	kr_name = "결정타",
	type = {"cunning/called-shots", 2},
	require = techs_cun_req2,
	points = 5,
	no_energy = "fake",
	random_ego = "attack",
	tactical = {ATTACK = {weapon = 2}},
	stamina = 35,
	cooldown = shot_cooldown,
	no_npc_use = true, -- Numbers overtuned to make sure the class has a satisfying high damage shot
	requires_target = true,
	range = archery_range,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	getDistanceBonus = function(self, t, range)
		return self:combatScale(range, -.5, 1, 2.5, 10, 0.25) --Slow scaling to allow for greater range variability
	end,
	getDamage = function(self, t)
		return 1
	end,
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.3, 1.5)
	end,
	archery_onreach = pen_on,
	archery_onmiss = pen_off,
	archery_onhit = function(self, t, target, x, y)
		pen_off(self, t, target, x, y)
	end,
	archery_target_parameters = {one_shot = true},
	action = function(self, t)
		local tg = {type = "hit"}

		local targets = self:archeryAcquireTargets(tg, table.clone(t.archery_target_parameters))
		if not targets then return end

		-- THIS IS WHY I HATE YOUR CODE STRUCTURE GRAYSWANDIR
		local bonuses = sniper_bonuses(self)
		local dist = core.fov.distance(self.x, self.y, targets[1].x, targets[1].y)
		local damage, distbonus = t.damage_multiplier(self, t), t.getDistanceBonus(self, t, dist)

		local target = game.level.map(targets[1].x, targets[1].y, engine.Map.ACTOR)
		if not target then return end
		game:delayedLogMessage(self, target, "kill_shot", "#DARK_ORCHID##Source1# #Target3# 저격했습니다! (사거리에 의해 %+d%%%%%%%% 피해량 추가)#LAST#", distbonus*100)
		
		local params = {mult = damage + distbonus}
		if bonuses.crit_chance then params.crit_chance = bonuses.crit_chance end
		if bonuses.crit_power then params.crit_power = bonuses.crit_power end
		if bonuses.resists_pen then params.resists_pen = bonuses.resists_pen end
		self:archeryShoot(targets, t, {type = "hit", speed = 200}, params)

		return true
	end, 
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[대상을 저격용 탄환으로 공격합니다.
		이 탄환은 장거리 사격에 특화되어, 기본적으로 %d%% 의 무기 피해를 가하며 거리에 따라 추가 피해를 입힙니다.
		거리에 따른 추가 피해는 지근거리에서 %d%% 만큼, 최대 사거리 %d 칸에 있는 대상에게는 %d%% 만큼 가해집니다.
		시전자와 대상 사이의 다른 적들은 이 공격의 영향을 받지 않습니다.]])
		:format(t.damage_multiplier(self, t) * 100, t.getDistanceBonus(self, t, 1)*100, range, t.getDistanceBonus(self, t, range)*100)

		end,
}

newTalent {
	short_name = "SKIRMISHER_NOGGIN_KNOCKER",
	name = "Noggin Knocker",
	kr_name = "머리 깨기",
	type = {"cunning/called-shots", 3},
	require = techs_cun_req3,
	points = 5,
	no_energy = "fake",
	tactical = {ATTACK = {weapon = 2}, DISABLE = {stun = 2}},
	stamina = 15,
	cooldown = shot_cooldown,
	requires_target = true,
	range = archery_range,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.3, 0.75)
	end,
	archery_onreach = pen_on,
	archery_onmiss = pen_off,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_SKIRMISHER_STUN_INCREASE, 1, {apply_power = self:combatAttack()})
		else
			game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		end
		pen_off(self, t, target, x, y)
	end,
	archery_target_parameters = {limit_shots = 1, multishots = 3},
	action = fire_shot,
	info = function(self, t)
		return ([[대상의 약점 (주로 머리) 에 세 발의 탄환을 연속으로 날립니다.
		각 탄환은 %d%% 원거리 피해를 주며, 대상을 기절시키거나 기절의 지속 기간을 1 턴 늘리려고 시도합니다.
		시전자와 대상 사이의 다른 적들은 이 공격의 영향을 받지 않습니다.
		기절 확률은 정확도의 영향을 받아 증가합니다.]])
		:format(t.damage_multiplier(self, t) * 100)
	end,
}

newTalent {
	short_name = "SKIRMISHER_SLING_SNIPER",
	name = "Sling Sniper",
	kr_name = "투석구 저격수",
	type = {"cunning/called-shots", 4},
	require = techs_cun_req4,
	points = 5,
	no_energy = "fake",
	mode = "passive",
	info = function(self, t)
		local bonuses = sniper_bonuses(self, true)
		return ([[당신의 조준사격 실력은 유래가 없을 정도로 뛰어납니다. 치명타 확률이 %d%% 상승하며, 조준사격 기술 계열의 치명타 피해량이 %d%% 상승합니다. 
		기술 레벨이 3 이상일 경우, 모든 조준사격 기술 계열의 재사용 대기 시간이 2 줄어들게 됩니다. 
		기술 레벨이 5 이상일 경우, 모든 조준사격 기술 계열의 물리 저항력 관통이 %d%% 상승합니다.]])
		:format(bonuses.crit_chance,
			bonuses.crit_power * 100,
			bonuses.resists_pen[DamageType.PHYSICAL])
	end
}
