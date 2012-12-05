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
	name = "Blood Red Moon",
	kr_display_name = "핏빛 달",
	type = {"celestial/eclipse", 1},
	mode = "passive",
	require = divi_req1,
	points = 5,
	on_learn = function(self, t)
		self.combat_spellcrit = self.combat_spellcrit + 3
	end,
	on_unlearn = function(self, t)
		self.combat_spellcrit = self.combat_spellcrit - 3
	end,
	info = function(self, t)
		return ([[주문 치명타율을 %d%% 증가시킵니다.]]):
		format(3 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Totality",
	kr_display_name = "개기 일월식",
	type = {"celestial/eclipse", 2},
	require = divi_req2,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	positive = 10,
	negative = 10,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t)) end,
	getResistancePenetration = function(self, t) return 5 + (self:getCun() / 10) * self:getTalentLevel(t) end,
	getCooldownReduction = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:setEffect(self.EFF_TOTALITY, t.getDuration(self, t), {power=t.getResistancePenetration(self, t)})
		for tid, cd in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[1]:find("^celestial/") then
				self.talents_cd[tid] = cd - t.getCooldownReduction(self, t)
			end
		end
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local penetration = t.getResistancePenetration(self, t)
		local cooldownreduction = t.getCooldownReduction(self, t)
		return ([[빛과 어둠 저항 관통을 %d턴 동안 %d%% 증가시키고, 재사용 대기중인 천공 계열 기술의 대기 시간을 %d턴 감소시킵니다.
		저항 관통은 교활함 능력치에 영향을 받아 증가됩니다.]]):
		format(penetration, duration, cooldownreduction)
	end,
}

newTalent{
	name = "Corona",
	kr_display_name = "코로나",
	type = {"celestial/eclipse", 3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	proj_speed = 3,
	range = 6,
	cooldown = 30,
	tactical = { BUFF = 2 },
	sustain_negative = 10,
	sustain_positive = 10,
	getTargetCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	getLightDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	getDarknessDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	on_crit = function(self, t)
		if self:getPositive() < 2 or self:getNegative() < 2 then
		--	self:forceUseTalent(t.id, {ignore_energy=true})
			return nil
		end
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

		local corona = rng.range(1, 100)
			if corona > 50 then
				local tg = {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, display={particle="bolt_light"}}
				self:projectile(tg, a.x, a.y, DamageType.LIGHT, t.getLightDamage(self, t), {type="light"})
				self:incPositive(-2)
			else
				local tg = {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, display={particle="bolt_dark"}}
				self:projectile(tg, a.x, a.y, DamageType.DARKNESS, t.getDarknessDamage(self, t), {type="shadow"})
				self:incNegative(-2)
			end
		end
	end,
	activate = function(self, t)
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local lightdamage = t.getLightDamage(self, t)
		local darknessdamage = t.getDarknessDamage(self, t)
		return ([[당신의 주문이 치명타로 적중할 때마다, 10칸 반경 내에 있는 %d명의 대상에게 빛이나 어둠의 볼트를 발사하여 %0.2f의 빛 피해나 %0.2f의 어둠 피해를 줍니다.
		이 효과가 발동될 때마다 2의 양기나 음기가 소모되며, 부족하다면 효과가 발동되지 않습니다.
		피해량은 마법 능력치의 영향을 받아 증가됩니다.]]):
		format(targetcount, damDesc(self, DamageType.LIGHT, lightdamage), damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Darkest Light",
	kr_display_name = "가장 어두운 빛",
	type = {"celestial/eclipse", 4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 30,
	sustain_negative = 10,
	tactical = { DEFEND = 2, ESCAPE = 2 },
	getInvisibilityPower = function(self, t) return 5 + (self:getCun() / 15) * self:getTalentLevel(t) end,
	getEnergyConvert = function(self, t) return math.max(0, 6 - self:getTalentLevelRaw(t)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	getRadius = function(self, t) return 2 + self:getTalentLevel(t) / 2 end,
	activate = function(self, t)
		local timer = t.getEnergyConvert(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			invisible = self:addTemporaryValue("invisible", t.getInvisibilityPower(self, t)),
			invisible_damage_penalty = self:addTemporaryValue("invisible_damage_penalty", 0.5),
			fill = self:addTemporaryValue("positive_regen", timer),
			drain = self:addTemporaryValue("negative_regen", - timer),
		}
		self:resetCanSeeCacheOf()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("invisible", p.invisible)
		self:removeTemporaryValue("invisible_damage_penalty", p.invisible_damage_penalty)
		self:removeTemporaryValue("positive_regen", p.fill)
		self:removeTemporaryValue("negative_regen", p.drain)
		local tg = {type="ball", range=0, selffire=true, radius= t.getRadius(self, t), talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		tg.selffire = false
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t) + self.positive))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		game:playSoundNear(self, "talents/flame")
		self.positive = 0
		self:resetCanSeeCacheOf()
		return true
	end,
	info = function(self, t)
		local invisibilitypower = t.getInvisibilityPower(self, t)
		local convert = t.getEnergyConvert(self, t)
		local damage = t.getDamage(self, t)
		local radius = t.getRadius(self, t)
		return ([[이 강력한 주문을 유지하는 동안 %d의 투명화 능력을 얻으며, 매 턴마다 %d의 음기를 양기로 전환합니다. 양기가 음기를 초과하게 되거나 유지를 해제하면, 효과가 끝나면서 찬란한 빛이 폭발하면서 양기의 총량에 %0.2f의 피해를 추가하여 %d칸 반경 내의 모든 대상에게 줍니다.
		투명화를 유지하는 동안에는 현실에서 유리되기에, 당신이 적에게 주는 피해가 50%% 감소됩니다.
		이 주문이 유지되는 동안에는 황혼 주문을 사용할 수 없으며, 광원을 장착하면 투명화가 소용없어지기에 착용을 해제해야 합니다.
		투명화는 교활함 능력치의 영향을 받으며, 폭발 피해량은 마법 능력치의 영향을 받아 증가됩니다.]]):
		format(invisibilitypower, convert, damDesc(self, DamageType.LIGHT, damage), radius)
	end,
}
