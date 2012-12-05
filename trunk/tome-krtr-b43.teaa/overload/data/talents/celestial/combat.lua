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
	name = "Weapon of Light",
	kr_display_name = "빛의 무기",
	type = {"celestial/combat", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getDamage = function(self, t) return 7 + self:combatSpellpower(0.092) * self:getTalentLevel(t) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[무기에 태양의 힘을 불어넣어, 매 타격마다 3의 양기를 소모하여 %0.2f의 빛 피해를 추가로 줍니다.
		양기가 부족하면 이 효과는 발동되지 않습니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(damDesc(self, DamageType.LIGHT, damage))
	end,
}

newTalent{
	name = "Martyrdom",
	kr_display_name = "고난",
	type = {"celestial/combat", 2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 22,
	positive = 25,
	tactical = { DISABLE = 2 },
	range = 6,
	reflectable = true,
	requires_target = true,
	getReturnDamage = function(self, t) return 8 * self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_MARTYRDOM, 10, {power=t.getReturnDamage(self, t), apply_power=self:combatSpellpower()})
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local returndamage = t.getReturnDamage(self, t)
		return ([[대상을 10턴 동안 고난을 받을 자로 지정합니다. 고난을 받을 자는 남에게 피해를 줄 때마다 %d%%의 피해를 자신도 받게 됩니다.]]):
		format(returndamage)
	end,
}

newTalent{
	name = "Wave of Power",
	kr_display_name = "힘의 파동",
	type = {"celestial/combat",3},
	require = divi_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	positive = 10,
	tactical = { ATTACK = 2 },
	requires_target = true,
	range = function(self, t) return 2 + self:getStr(8) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.9) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[순수한 힘을 방출하여, 원거리에 있는 적에게 %d%%의 무기 피해를 줍니다.
		사정거리는 힘 능력치에 영향을 받아 증가됩니다.]]):
		format(100 * damage)
	end,
}

newTalent{
	name = "Crusade",
	kr_display_name = "박멸",
	type = {"celestial/combat", 4},
	require = divi_req4,
	random_ego = "attack",
	points = 5,
	cooldown = 10,
	positive = 10,
	tactical = { ATTACK = {LIGHT = 2} },
	range = 1,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTarget(target, DamageType.LIGHT, t.getDamage(self, t), true)
		self:attackTarget(target, DamageType.LIGHT, t.getDamage(self, t), true)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[태양의 힘을 모아 두 번 공격하여, 각각 무기 공격력의 %d%%에 해당하는 빛 피해를 줍니다.]]):
		format(100 * damage)
	end,
}

