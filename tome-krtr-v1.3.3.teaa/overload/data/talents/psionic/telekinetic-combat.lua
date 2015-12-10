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


newTalent{
	name = "Telekinetic Assault",
	kr_name = "염동력 맹공",
	type = {"psionic/telekinetic-combat", 4},
	require = psi_cun_high4,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	psi = 25,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 3 } },
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	action = function(self, t)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "손에 무기를 쥐고 있지 않으면 사용할 수 없습니다.")
			return nil
		end
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		self:attr("use_psi_combat", 1)
		if self:getInven(self.INVEN_PSIONIC_FOCUS) then
			for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
				if o.combat and not o.archery then
					self:attackTargetWith(target, o.combat, nil, self:combatTalentWeaponDamage(t, 1.2, 1.9))
					self:attackTargetWith(target, o.combat, nil, self:combatTalentWeaponDamage(t, 1.2, 1.9))
				end
			end
		end
		self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.5, 2.5))
		self:attr("use_psi_combat", -1)
		return true
	end,
	info = function(self, t)
		return ([[모든 무기로 적을 맹공하여, 염동력으로 쥔 무기로 %d%% 무기 피해를 두 번 가하고 이어서 주무기로 %d%% 무기 피해를 가합니다.
		이번 공격에 한해, 정확도와 피해량의 계산에 힘과 민첩 능력치 대신 의지와 교활함 능력치를 사용합니다.
		또한, 활성화 중인 오러로 인한 피해 증가가 이번 공격에 적용됩니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1.2, 1.9), 100 * self:combatTalentWeaponDamage(t, 1.5, 2.5))
	end,
}
