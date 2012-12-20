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

local function cancelHymns(self)
	local hymns = {self.T_HYMN_OF_SHADOWS, self.T_HYMN_OF_DETECTION, self.T_HYMN_OF_PERSEVERANCE, self.T_HYMN_OF_MOONLIGHT}
	for i, t in ipairs(hymns) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Hymn of Shadows",
	kr_display_name = "그림자의 송가",
	type = {"celestial/hymns", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getDarknessDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	activate = function(self, t)
		cancelHymns(self)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]= t.getDamageOnMeleeHit(self, t)}),
			phys = self:addTemporaryValue("inc_damage", {[DamageType.DARKNESS] = t.getDarknessDamageIncrease(self, t)}),
			particle = self:addParticles(Particles.new("darkness_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("inc_damage", p.phys)
		return true
	end,
	info = function(self, t)
		local darknessinc = t.getDarknessDamageIncrease(self, t)
		local darknessdamage = t.getDamageOnMeleeHit(self, t)
		return ([[달의 영광을 노래하여, 적에게 주는 어둠 피해량을 %d%% 증가시킵니다.
		그리고 주변을 그림자로 감싸, 당신을 공격하는 적에게 %0.2f의 어둠 피해를 입힙니다.
		동시에 하나의 송가만을 유지할 수 있습니다.
		피해량과 피해 증가효과는 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(darknessinc, damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Hymn of Detection",
	kr_display_name = "간파의 송가",
	type = {"celestial/hymns", 2},
	mode = "sustained",
	require = divi_req2,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getSeeInvisible = function(self, t) return self:combatTalentSpellDamage(t, 2, 35) end,
	getSeeStealth = function(self, t) return self:combatTalentSpellDamage(t, 2, 15) end,
	getInfraVisionPower = function(self, t) return math.floor(5 + self:getTalentLevel(t)) end,
	activate = function(self, t)
		cancelHymns(self)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]= t.getDamageOnMeleeHit(self, t)}),
			invis = self:addTemporaryValue("see_invisible", t.getSeeInvisible(self, t)),
			stealth = self:addTemporaryValue("see_stealth", t.getSeeStealth(self, t)),
			infravision = self:addTemporaryValue("infravision", t.getInfraVisionPower(self, t)),
			particle = self:addParticles(Particles.new("darkness_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("infravision", p.infravision)
		self:removeTemporaryValue("see_invisible", p.invis)
		self:removeTemporaryValue("see_stealth", p.stealth)
		return true
	end,
	info = function(self, t)
		local infra = t.getInfraVisionPower(self, t)
		local invis = t.getSeeInvisible(self, t)
		local stealth = t.getSeeStealth(self, t)
		local darknessdamage = t.getDamageOnMeleeHit(self, t)
		return ([[달의 영광을 노래하여, 야간 투시력을 %d 만큼, 은신 감지를 %d 만큼, 투명화 감지를 %d 만큼 증가시킵니다.
		그리고 주변을 그림자로 감싸, 당신을 공격하는 적에게 %0.2f의 어둠 피해를 입힙니다.
		동시에 하나의 송가만을 유지할 수 있습니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(infra, stealth, invis, damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Hymn of Perseverance",
	kr_display_name = "불굴의 송가",
	type = {"celestial/hymns",3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 10,
	getDamageOnMeleeHit = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getImmunities = function(self, t) return 0.15 + self:getTalentLevel(t) / 14 end,
	activate = function(self, t)
		cancelHymns(self)
		local dam = self:combatTalentSpellDamage(t, 5, 25)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.DARKNESS]=t.getDamageOnMeleeHit(self, t)}),
			stun = self:addTemporaryValue("stun_immune", t.getImmunities(self, t)),
			confusion = self:addTemporaryValue("confusion_immune", t.getImmunities(self, t)),
			blind = self:addTemporaryValue("blind_immune", t.getImmunities(self, t)),
			particle = self:addParticles(Particles.new("darkness_shield", 1))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("confusion_immune", p.confusion)
		self:removeTemporaryValue("blind_immune", p.blind)
		return true
	end,
	info = function(self, t)
		local immunities = t.getImmunities(self, t)
		local darknessdamage = t.getDamageOnMeleeHit(self, t)
		return ([[달의 영광을 노래하여, %d%%의 기절, 실명, 혼란 저항을 얻습니다.
		그리고 주변을 그림자로 감싸, 당신을 공격하는 적에게 %0.2f의 어둠 피해를 입힙니다.
		동시에 하나의 송가만을 유지할 수 있습니다.
		피해량은 마법 능력치에 영향을 받아 증가됩니다.]]):
		format(100 * (immunities), damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Hymn of Moonlight",
	kr_display_name = "달빛의 송가",
	type = {"celestial/hymns",4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 12,
	sustain_negative = 20,
	no_energy = true,
	dont_provide_pool = true,
	tactical = { BUFF = 2 },
	range = 5,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 7, 80) end,
	getTargetCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	getNegativeDrain = function(self, t) return 9 - self:getTalentLevelRaw(t) end,
	do_beams = function(self, t)
		if self:getNegative() < t.getNegativeDrain(self, t) then return end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		local drain = t.getNegativeDrain(self, t)

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			if self:getNegative() - 1 < drain then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.DARKNESS, rng.avg(1, self:spellCrit(t.getDamage(self, t)), 3))
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "shadow_beam", {tx=a.x-self.x, ty=a.y-self.y})
			game:playSoundNear(self, "talents/spell_generic")
			self:incNegative(-drain)
		end
	end,
	activate = function(self, t)
		cancelHymns(self)
		game:playSoundNear(self, "talents/spell_generic")
		game.logSeen(self, "#DARK_GREY#그림자가 %s의 주변에서 춤을 추기 시작합니다!", (self.kr_display_name or self.name)) --@@
		return {
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#DARK_GREY#%s의 주변에서 춤 추던 그림자가 사라집니다.", (self.kr_display_name or self.name)) --@@
		return true
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local damage = t.getDamage(self, t)
		local drain = t.getNegativeDrain(self, t)
		return ([[주문이 지속되는 동안 당신을 따르는, 춤추는 그림자를 불러들입니다.
		매 턴마다 5칸 반경 내의 %d명의 적에게 그림자의 빔이 발사되어 1에서 %0.2f의 피해를 줍니다.
		이 강력한 주문은 빔이 발사될 때마다 %d의 음기가 소모되며, 부족하다면 효과가 발동되지 않습니다.
		피해량은 마법 능력치의 영향을 받아 증가됩니다.]]):
		format(targetcount, damDesc(self, DamageType.DARKNESS, damage), drain)
	end,
}
