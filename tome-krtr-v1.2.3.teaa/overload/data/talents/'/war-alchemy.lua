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
	name = "Heat",
	kr_name = "불꽃",
	type = {"spell/war-alchemy", 1},
	require = spells_req1,
	points = 5,
	mana = 10,
	cooldown = 5,
	random_ego = "attack",
	refectable = true,
	proj_speed = 20,
	range = 10,
	direct_hit = true,
	tactical = { ATTACK = { FIRE = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 620) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dur=8, initial=0, dam=t.getDamage(self, t)}, {type="flame"})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[대상의 신체 일부를 화염으로 바꿔, 8 턴에 걸쳐 %0.2f 화염 피해를 가합니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.FIRE, damage))
	end,
}
