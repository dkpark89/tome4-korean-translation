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
	name = "Shield of Light",
	kr_name = "빛의 방패",
	type = {"celestial/guardian", 1},
	mode = "sustained",
	require = divi_req_high1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패를 장착하지 않은 상태에서는 빛의 방패를 사용할 수 없습니다!")
			return nil
		end

		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[방패에 빛의 힘을 불어넣어, 피해를 받을 때마다 양기를 2 소모하여 생명력을 %0.2f 회복합니다.
		양기가 부족하면, 이 효과는 발동되지 않습니다.
		치유량은 주문력의 영향을 받아 증가합니다.]]):
		format(heal)
	end,
}

newTalent{
	name = "Brandish",
	kr_name = "광휘",
	type = {"celestial/guardian", 2},
	require = divi_req_high2,
	points = 5,
	cooldown = 8,
	positive = 15,
	tactical = { ATTACK = {LIGHT = 2} },
	requires_target = true,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getShieldDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5, self:getTalentLevel(self.T_SHIELD_EXPERTISE)) end,
	getLightDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	radius = function(self, t)
		return 2 + self:getTalentLevel(t) / 2
	end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패를 장착하지 않은 상태에서는 광휘를 사용할 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, t.getWeaponDamage(self, t), true)
		-- Second attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, t.getShieldDamage(self, t))

		-- Light Burst
		if hit then
			local tg = {type="ball", range=1, selffire=true, radius=self:getTalentRadius(t), talent=t}
			self:project(tg, x, y, DamageType.LITE, 1)
			tg.selffire = false
			local grids = self:project(tg, x, y, DamageType.LIGHT, t.getLightDamage(self, t))
			game.level.map:particleEmitter(x, y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
			game:playSoundNear(self, "talents/flame")
		end

		return true
	end,
	info = function(self, t)
		local weapondamage = t.getWeaponDamage(self, t)
		local shielddamage = t.getShieldDamage(self, t)
		local lightdamage = t.getLightDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[대상을 무기로 공격하여 %d%% 무기 피해를 준 뒤, 방패로 쳐서 %d%% 방패 피해를 줍니다. 방패 공격이 적중하면, 찬란한 빛이 뿜어져나와 %0.2f 빛 피해를 주변 %d 칸 반경에 있는 적들에게 주고, 어두운 곳을 밝힙니다.
		빛 피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(100 * weapondamage, 100 * shielddamage, damDesc(self, DamageType.LIGHT, lightdamage), radius)
	end,
}

newTalent{
	name = "Retribution",
	kr_name = "심판",
	type = {"celestial/guardian", 3},
	require = divi_req_high3, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 20,
	cooldown = 10,
	range = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	tactical = { DEFEND = 2 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 40, 400) end,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패를 장착하지 않은 상태에서는 심판을 사용할 수 없습니다!")
			return nil
		end
		local power = t.getDamage(self, t)
		self.retribution_absorb = power
		self.retribution_strike = power
		game:playSoundNear(self, "talents/generic")
		return {
			shield = self:addTemporaryValue("retribution", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("retribution", p.shield)
		self.retribution_absorb = nil
		self.retribution_strike = nil
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[적에게 받는 피해량의 절반을 흡수합니다. %0.2f 피해를 흡수하면, 방패에서 찬란한 빛이 뿜어져나와 주변 %d 칸 반경에 흡수했던 피해량과 동일한 피해를 주고 기술이 해제됩니다.
		흡수량은 주문력의 영향을 받아 증가합니다.]]):
		format(damage, self:getTalentRange(t))
	end,
}

newTalent{
	name = "Second Life",
	kr_name = "두번째 생명",
	type = {"celestial/guardian", 4},
	require = divi_req_high4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 60,
	cooldown = 50,
	tactical = { DEFEND = 2 },
	getLife = function(self, t) return self.max_life * (0.05 + self:getTalentLevel(t)/25) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			particle = self:addParticles(Particles.new("golden_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[공격을 받아 생명력이 1 밑으로 떨어지게 되면, 두번째 생명이 발동되어 기술 유지가 해제되고 생명력이 %d 인 상태가 됩니다.]]):
		format(t.getLife(self, t))
	end,
}

