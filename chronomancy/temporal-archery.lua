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
	name = "Phase Shot",
	kr_display_name = "시공의 사격",
	type = {"chronomancy/temporal-archery", 1},
	require = temporal_req1,
	points = 5,
	paradox = 3,
	cooldown = 3,
	no_energy = "fake",
	range = 10,
	tactical = { ATTACK = {TEMPORAL = 2} },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt"}
		local targets = self:archeryAcquireTargets(tg)
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm), damtype=DamageType.TEMPORAL, apr=1000})
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm))
		return ([[시공간을 관통하는 화살이나 탄환을 발사하여, 대상에게 시간 속성으로 %d%% 무기 피해를 줍니다.
		피해량은 괴리 수치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.TEMPORAL, weapon))
	end
}

newTalent{
	name = "Unerring Shot",
	kr_display_name = "무결점 사격",
	type = {"chronomancy/temporal-archery", 2},
	require = temporal_req2,
	points = 5,
	paradox = 5,
	cooldown = 8,
	no_energy = "fake",
	range = 10,
	tactical = { ATTACK = {PHYSICAL = 2} },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt"}
		local targets = self:archeryAcquireTargets(tg)
		if not targets then return end
		self:setEffect(self.EFF_ATTACK, 1, {power=100})
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.1, 2.1) * getParadoxModifier(self, pm)})
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm))
		return ([[사격할 때 조준에 집중하여, 높은 정확도로 %d%% 무기 피해를 줍니다. 사격한 후, 1 턴 동안 시공 계열의 효과를 남깁니다. (Afterwords your attack will remain improved for one turn as the chronomantic effects linger.)
		피해량은 괴리 수치의 영향을 받아 증가합니다.]])
		:format(weapon)
	end,
}

newTalent{
	name = "Perfect Aim",
	kr_display_name = "완벽한 조준",
	type = {"chronomancy/temporal-archery", 3},
	require = temporal_req3,
	mode = "sustained",
	points = 5,
	sustain_paradox = 225,
	cooldown = 10,
	tactical = { BUFF = 2 },
	no_energy = true,
	getPower = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 40)) end,
	activate = function(self, t)
		local power = t.getPower(self, t)
		return {
		ccp = self:addTemporaryValue("combat_critical_power", power),
		pid = self:addTemporaryValue("combat_physcrit", power / 2),
		sid = self:addTemporaryValue("combat_spellcrit", power / 2),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_critical_power", p.ccp)
		self:removeTemporaryValue("combat_physcrit", p.pid)
		self:removeTemporaryValue("combat_spellcrit", p.sid)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[사격할 때 조준에 집중하여, 치명타 배율을 %d%% 늘리고 물리 치명타율과 마법 치명타율을 %d%% 늘립니다.
		이 효과는 마법 능력치의 영향을 받아 증가합니다.]]):format(power, power / 2)
	end,
}

newTalent{
	name = "Quick Shot",
	kr_display_name = "빠른 사격",
	type = {"chronomancy/temporal-archery", 4},
	require = temporal_req4,
	points = 5,
	paradox = 10,
	cooldown = function(self, t) return 15 - 2 * self:getTalentLevelRaw(t) end,
	no_energy = true,
	range = 10,
	tactical = { ATTACK = {PHYSICAL = 2} },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	requires_target = true,
	action = function(self, t)
		local old = self.energy.value
		local targets = self:archeryAcquireTargets()
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm)})
		self.energy.value = old
		return true
	end,
	info = function(self, t)
		local weapon = 100 * (self:combatTalentWeaponDamage(t, 1, 1.5) * getParadoxModifier(self, pm))
		return ([[주변의 시간을 멈추고 한 발을 사격하여, %d%% 피해를 줍니다.
		피해량은 괴리 수치의 영향을 받아 증가하며, 기술 레벨이 올라가면 재사용 대기시간이 줄어듭니다.]]):format(weapon)
	end,
}
