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
	name = "Healing Light",
	kr_name = "치유의 빛",
	type = {"celestial/light", 1},
	require = spells_req1,
	points = 5,
	random_ego = "defensive",
	cooldown = 10,
	positive = -10,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 20, 440) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true, size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.5, y=-0.3, img="healcelestial", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0xd8/255, 0xff/255, 0x21/255, 1}, beamColor2={0xf7/255, 0xff/255, 0x9e/255, 1}, circleDescendSpeed=3}))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[자신을 향해 내리비치는 햇빛을 통해, %d 생명력을 회복합니다.
		회복량은 주문력의 영향을 받아 증가합니다.]]):
		format(heal)
	end,
}

newTalent{
	name = "Bathe in Light",
	kr_name = "빛의 세례",
	type = {"celestial/light", 2},
	require = spells_req2,
	random_ego = "defensive",
	points = 5,
	cooldown = 15,
	positive = -20,
	tactical = { HEAL = 3 },
	range = 0,
	radius = 2,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 4, 80) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 7)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.HEALING_POWER, self:spellCrit(t.getHeal(self, t)),
			self:getTalentRadius(t),
			5, nil,
			{overlay_particle={zdepth=6, only_one=true, type="circle", args={img="sun_circle", a=10, speed=0.04, radius=self:getTalentRadius(t)}}, type="healing_vapour"},
			nil, true
		)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local heal = t.getHeal(self, t)
		local duration = t.getDuration(self, t)
		return ([[햇빛이 내리비치는 마력 지대를 만들어, 주변 %d 칸 반경에 있는 모든 아군에게 빛의 세례를 내립니다. 
		- 매 턴마다 %0.2f 만큼의 생명력이 회복됩니다.
		- 매 턴마다 %0.2f 만큼의 피해 보호막이 생성되며, 보호막의 피해량 감소 수치는 재충전됩니다. 이미 다른 피해 보호막이 발동 중일 경우에도 피해량 감소 수치가 재충전되며, 보호막의 남은 지속시간이 2 턴 미만일 경우 2 턴으로 고정됩니다. 하나의 피해 보호막을 20 회 이상 재충전시킬 경우, 보호막이 불안정해져 사라지게 됩니다.
		- 치유 효과를 %d%% 증가시킵니다.
		- 이 효과는 %d 턴 동안 지속되며, 해당 지역에 빛이 밝혀집니다.
		회복량은 주문력의 영향을 받아 증가합니다.]]):
		format(radius, heal, heal, heal / 2, duration)
	end,
}

newTalent{
	name = "Barrier",
	kr_name = "방벽",
	type = {"celestial/light", 3},
	require = spells_req3,
	points = 5,
	random_ego = "defensive",
	positive = -20,
	cooldown = 15,
	tactical = { DEFEND = 2 },
	getAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 30, 370) end,
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {color={0xe1/255, 0xcb/255, 0x3f/255}, power=self:spellCrit(t.getAbsorb(self, t))})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local absorb = t.getAbsorb(self, t)
		return ([[10턴 동안 방벽을 생성하여, %d 피해를 흡수합니다.
		피해 흡수량은 주문력의 영향을 받아 증가합니다.]]):
		format(absorb)
	end,
}

newTalent{
	name = "Providence",
	kr_name = "빛의 섭리",
	type = {"celestial/light", 4},
	require = spells_req4,
	points = 5,
	random_ego = "defensive",
	positive = -20,
	cooldown = 30,
	tactical = { HEAL = 1, CURE = 2 },
	getRegeneration = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		self:setEffect(self.EFF_PROVIDENCE, t.getDuration(self, t), {power=t.getRegeneration(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local regen = t.getRegeneration(self, t)
		local duration = t.getDuration(self, t)
		return ([[빛의 보호를 받아, 매 턴마다 %d 의 생명력을 회복하고 한 개의 나쁜 상태이상 효과를 해제합니다. 빛의 보호는 %d 턴 동안 유지됩니다.
		치유량은 주문력의 영향을 받아 증가합니다.]]):
		format(regen, duration) --@ 변수 순서 조정
	end,
}

