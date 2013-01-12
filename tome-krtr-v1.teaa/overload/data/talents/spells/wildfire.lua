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
	name = "Blastwave",
	kr_display_name = "화염 파동",
	type = {"spell/wildfire",1},
	require = spells_req_high1,
	points = 5,
	mana = 12,
	cooldown = 5,
	tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 2 },
		CURE = function(self, t, target)
			if self:attr("burning_wake") and self:attr("cleansing_flame") then
				return 1
			end
	end },
	direct_hit = true,
	requires_target = true,
	range = 0,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.FIREKNOCKBACK, {dist=3, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		if self:attr("burning_wake") then
			game.level.map:addEffect(self,
				self.x, self.y, 4,
				DamageType.INFERNO, self:attr("burning_wake"),
				tg.radius,
				5, nil,
				{type="inferno"},
				nil, self:spellFriendlyFire()
			)
		end
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[화염의 파동을 발하여 %d 칸 반경의 적들에게 3 턴 동안 총 %0.2f 화염 피해를 주고, 뒤로 밀어냅니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):format(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Burning Wake",
	kr_display_name = "불타오른 흔적",
	type = {"spell/wildfire",2},
	require = spells_req_high2,
	mode = "sustained",
	points = 5,
	sustain_mana = 40,
	cooldown = 30,
	tactical = { BUFF=2, ATTACKAREA = { FIRE = 1 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 55) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		local cft = self:getTalentFromId(self.T_CLEANSING_FLAMES)
		return {
			bw = self:addTemporaryValue("burning_wake", t.getDamage(self, t)),
			cf = self:addTemporaryValue("cleansing_flames", cft.getChance(self, cft)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("burning_wake", p.bw)
		self:removeTemporaryValue("cleansing_flames", p.cf)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[불꽃, 화염 충격, 화염 폭발, 화염 파동 마법이 휩쓸고 지나간 자리에 불을 붙여, 4 턴 동안 총 %0.2f 화염 피해를 줍니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Cleansing Flames",
	kr_display_name = "정화의 불꽃",
	type = {"spell/wildfire",3},
	require = spells_req_high3,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	info = function(self, t)
		return ([['불타오른 흔적' 마법이 활성화 되었을 때, '지옥의 열화' 마법과 '불타오른 흔적' 마법의 피해를 입으면 %d%% 확률로 상태효과가 제거됩니다.
		적이 피해를 입으면 이로운 상태효과가, 아군이 피해를 입으면 해로운 상태효과가 제거됩니다. 단, 화염 피해는 똑같이 입습니다.]]):format(t.getChance(self, t))
	end,
}

newTalent{
	name = "Wildfire",
	kr_display_name = "염화",
	type = {"spell/wildfire",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getFireDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	getResistSelf = function(self, t) return self:getTalentLevel(t) * 14 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", hide_center=0, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("wildfire", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = t.getFireDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.FIRE] = t.getResistPenalty(self, t)}),
			selfres = self:addTemporaryValue("resists_self", {[DamageType.FIRE] = t.getResistSelf(self, t)}),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		self:removeTemporaryValue("resists_self", p.selfres)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getFireDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		local selfres = t.getResistSelf(self, t)
		return ([[시전자 주변에 염화를 둘러 모든 화염 피해량이 %d%% 상승하며, 적의 화염 저항력을 %d%% 무시합니다. 그리고 자신의 화염 마법에 자신이 피해를 입었을 때, 피해량이 %d%% 감소됩니다.]])
		:format(damageinc, ressistpen, selfres)
	end,
}
