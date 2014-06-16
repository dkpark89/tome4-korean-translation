﻿-- ToME - Tales of Maj'Eyal
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
	name = "Arcane Power",
	kr_name = "마법의 힘",
	type = {"spell/arcane", 1},
	mode = "sustained",
	require = spells_req1,
	sustain_mana = 25,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	use_only_arcane = 1,
	getSpellpowerIncrease = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	getArcaneResist = function(self, t) return 5 + self:combatTalentSpellDamage(t, 10, 500) / 18 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			power = self:addTemporaryValue("combat_spellpower", t.getSpellpowerIncrease(self, t)),
			res = self:addTemporaryValue("resists", {[DamageType.ARCANE] = t.getArcaneResist(self, t)}),
			particle = self:addParticles(Particles.new("arcane_power", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_spellpower", p.power)
		self:removeTemporaryValue("resists", p.res)
		return true
	end,
	info = function(self, t)
		return ([[마법에 대한 이해를 바탕으로, 주문을 시전할 때 더 집중할 수 있게 됩니다. 주문력이 %d 상승하고 마법 속성 저항력이 %d%% 상승합니다.]]):
		format(t.getSpellpowerIncrease(self, t), t.getArcaneResist(self, t))
	end,
}

newTalent{
	name = "Manathrust",
	kr_name = "마나 분출",
	type = {"spell/arcane", 2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 10,
	cooldown = 3,
	use_only_arcane = 1,
	tactical = { ATTACK = { ARCANE = 2 } },
	range = 10,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ARCANE, self:spellCrit(t.getDamage(self, t)), nil)
		local _ _, x, y = self:canProject(tg, x, y)
		if tg.type == "beam" then
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
		else
			game.level.map:particleEmitter(x, y, 1, "manathrust")
		end
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[마나를 화살 형태로 분출하여 %0.2f 마법 피해를 줍니다.
		기술 레벨이 3 이상이면, 분출된 마나가 적들을 관통합니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.ARCANE, damage))
	end,
}

newTalent{
	name = "Arcane Vortex",
	kr_name = "마법의 소용돌이",
	type = {"spell/arcane", 3},
	require = spells_req3,
	points = 5,
	mana = 35,
	cooldown = 12,
	use_only_arcane = 1,
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	tactical = { ATTACK = { ARCANE = 2 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 340) / 6 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return nil end

		target:setEffect(target.EFF_ARCANE_VORTEX, 6, {src=self, dam=t.getDamage(self, t)})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[마법의 소용돌이를 만들어 대상을 6 턴 동안 휘감습니다. 소용돌이는 매 턴마다 적들을 관통하는 마나를 분출하여, 대상의 시야 내에 있는 적들에게 %0.2f 마법 피해를 줍니다.
		주변에 적이 없다면, 이 주문의 마법 피해가 150%% 더 강력해집니다.
		대상이 죽으면 소용돌이가 폭발하여, 주변 2 칸 반경에 남은 피해량을 한번에 주는 마법 폭발을 일으킵니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.ARCANE, dam))
	end,
}

newTalent{
	name = "Disruption Shield",
	kr_name = "불안정한 보호막",
	type = {"spell/arcane",4},
	require = spells_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_mana = 10,
	use_only_arcane = 1,
	no_energy = true,
	tactical = { MANA = 3, DEFEND = 2, },
	getManaRatio = function(self, t) return math.max(3 - self:combatTalentSpellDamage(t, 10, 200) / 100, 0.5) * (100 - util.bound(self:attr("shield_factor") or 0, 0, 70)) / 100 end,
	getArcaneResist = function(self, t) return 50 + self:combatTalentSpellDamage(t, 10, 500) / 10 end,
	-- Note: effects handled in mod.class.Actor:onTakeHit function
	getMaxDamage = function(self, t) -- Compute damage limit
		local max_dam = self.max_mana
		for i, k in pairs(self.sustain_talents) do -- Add up sustain costs to get total mana pool size
			max_dam = max_dam + (tonumber(self.talents_def[i].sustain_mana) or 0)
		end
		return max_dam * 2 -- Maximum damage is 2x total mana pool
	end,
	on_pre_use = function(self, t) return (self:getMana() / self:getMaxMana() <= 0.25) or self:hasEffect(self.EFF_AETHER_AVATAR) or self:attr("disruption_shield") end,
	explode = function(self, t, dam)
		game.logSeen(self, "#VIOLET#%s의 보호막이 폭발하여, 강력한 마력 폭풍이 일어났습니다!", (self.kr_name or self.name):capitalize())
		dam = math.min(dam, t.getMaxDamage(self, t)) -- Damage cap
		-- Add a lasting map effect
		self:setEffect(self.EFF_ARCANE_STORM, 10, {power=t.getArcaneResist(self, t)})
		game.level.map:addEffect(self,
			self.x, self.y, 10,
			DamageType.ARCANE, dam / 10,
			3,
			5, nil,
			{type="arcanestorm", only_one=true},
			function(e) e.x = e.src.x e.y = e.src.y return true end,
			true
		)
	end,
	damage_feedback = function(self, t, p, src)
		if p.particle and p.particle._shader and p.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			p.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			p.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	iconOverlay = function(self, t, p)
		local val = self.disruption_shield_absorb or 0
		if val <= 0 then return "" end
		local fnt = "buff_font_small"
		if val >= 1000 then fnt = "buff_font_smaller" end
		return tostring(math.ceil(val)), fnt
	end,
	activate = function(self, t)
		local power = t.getManaRatio(self, t)
		self.disruption_shield_absorb = 0
		game:playSoundNear(self, "talents/arcane")

		local particle
		if core.shader.active(4) then
--			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3, img="shield6"}, {type="shield", ellipsoidalFactor=1.05, shieldIntensity=0.1, time_factor=-2500, color={0.8, 0.1, 1.0}, impact_color = {0, 1, 0}, impact_time=800}))
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="runicshield"}, {type="runicshield", shieldIntensity=0.14, ellipsoidalFactor=1, scrollingSpeed=-1, time_factor=12000, bubbleColor={0.8, 0.1, 1.0, 1.0}, auraColor={0.85, 0.3, 1.0, 1}}))
		else
			particle = self:addParticles(Particles.new("disruption_shield", 1))
		end

		return {
			shield = self:addTemporaryValue("disruption_shield", power),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("disruption_shield", p.shield)
		self.disruption_shield_absorb = nil
		return true
	end,
	info = function(self, t)
		return ([[시전자 주변을 불안정한 마법의 힘으로 둘러싸 모든 피해를 무효화시키고, 원래 받았어야 할 피해량 1 마다 마나를 %0.2f 회복합니다.
		최대 마나량 이상의 마나가 회복되어 시전자가 마나를 수용할 수 없게 되면, 보호막이 깨지고 강력한 마력 폭풍이 일어납니다. 
		마력 폭풍은 주변 3 칸 반경에 10 턴 동안 유지되며, 매 턴마다 지금까지 보호막이 흡수한 피해량의 10%% 에 해당하는 마법 피해(최대 %d 까지)를 줍니다.
		마력 폭풍은 시전자에게도 피해를 주지만, 대신 시전자의 마법 저항력을 %d%% 올려줍니다.
		현재 마나량이 최대 마나량의 25%% 이하가 되어야 이 마법을 사용할 수 있습니다.
		마나 회복량은 주문 / 보호 계열의 '보호막 수련' 기술과 주문력의 영향을 받아 감소합니다.]]):
		format(t.getManaRatio(self, t), t.getMaxDamage(self, t), t.getArcaneResist(self, t))
	end,
}
