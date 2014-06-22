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

require "engine.krtrUtils"

newTalent{
	name = "Sling Mastery",
	kr_name = "투석구 수련",
	type = {"technique/archery-sling", 1},
	points = 5,
	require = { stat = { dex=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	ammo_mastery_reload = function(self, t)
		return math.floor(self:getTalentLevel(t) / 2)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, 'ammo_mastery_reload', t.ammo_mastery_reload(self, t))
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		local reloads = t.ammo_mastery_reload(self, t)
		return ([[투석구를 사용하면 물리력이 %d / 투석구의 피해량이 %d%% 증가합니다.
		또한, 한번에 %d 발의 탄환을 재장전할 수 있게 됩니다.]]):format(damage, inc * 100, reloads) 
	end,
}

newTalent{
	name = "Eye Shot",
	kr_name = "눈 맞추기",
	type = {"technique/archery-sling", 2},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req2,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { blind = 2 } },
	getBlindDur = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("sling") then if not silent then game.logPlayer(self, "이 기술을 쓰려면 투석구를 쥐고 있어야 합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("blind") then
			target:setEffect(target.EFF_BLINDED, t.getBlindDur(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		end
	end,
	action = function(self, t)
		if not self:hasArcheryWeapon("sling") then game.logPlayer(self, "투석구를 쥐고 있어야 합니다!") return nil end
		
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[대상의 눈을 조준하여 탄환을 발사합니다. 적중 시 대상을 %d 턴 동안 실명 상태로 만들며, %d%% 의 무기 피해를 줍니다.
		실명 확률은 정확도 능력치의 영향을 받아 증가합니다.]])
		:format(t.getBlindDur(self, t),	100 * self:combatTalentWeaponDamage(t, 1, 1.5))
	end,
}

newTalent{
	name = "Inertial Shot",
	kr_name = "관성의 힘",
	type = {"technique/archery-sling", 3},
	no_energy = "fake",
	points = 5,
	cooldown = 8,
	stamina = 15,
	require = techs_dex_req3,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("sling") then if not silent then game.logPlayer(self, "이 기술을 쓰려면 투석구를 쥐고 있어야 합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:checkHit(self:combatAttack(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
			target:knockback(self.x, self.y, 4)
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatAttack())
			game.logSeen(target, "%s 밀려나지 않습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		else
			game.logSeen(target, "%s 확고히 서있습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		end
	end,
	action = function(self, t)
		if not self:hasArcheryWeapon("sling") then game.logPlayer(self, "투석구를 쥐고 있어야 합니다!") return nil end

		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[대상에게 온 힘을 실은 탄환을 날려, %d%% 의 무기 피해를 주고 대상을 밀어냅니다.
		밀어낼 확률은 정확도 능력치의 영향을 받아 증가합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1, 1.5))
	end,
}

newTalent{
	name = "Multishot",
	kr_name = "다연장 탄환 발사술",
	type = {"technique/archery-sling", 4},
	no_energy = "fake",
	points = 5,
	cooldown = 12,
	stamina = 35,
	require = techs_dex_req4,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 3 } },
	getShots = function(self, t, fake)
		local count = self:combatTalentScale(t, 2.8, 4.3, "log")
		if fake then return count end
		return math.floor(count) + (rng.percent(100*(count - math.floor(count))) and 1 or 0)
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("sling") then if not silent then game.logPlayer(self, "이 기술을 쓰려면 투석구를 쥐고 있어야 합니다.") end return false end return true end,
	action = function(self, t)
		if not self:hasArcheryWeapon("sling") then game.logPlayer(self, "투석구를 쥐고 있어야 합니다!") return nil end
		local targets = self:archeryAcquireTargets(nil, {multishots=t.getShots(self, t)})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 0.3, 0.7)})
		return true
	end,
	info = function(self, t)
		return ([[한 번에 평균적으로 %0.1f 발의 탄환을 대상에게 날려, 각 탄환마다 %d%% 무기 피해를 줍니다.]]):format(t.getShots(self, t, true), 100 * self:combatTalentWeaponDamage(t, 0.3, 0.7))
	end,
}
