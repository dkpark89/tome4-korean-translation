﻿-- ToME - Tales of Maj'Eyal
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
	name = "Oozebeam",
	kr_name = "슬라임 광선",
	type = {"wild-gift/oozing-blades", 1},
	require = gifts_req_high1,
	points = 5,
	equilibrium = 4,
	cooldown = 3,
	tactical = { ATTACKAREA = {NATURE=2} },
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 290) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.SLIME, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "ooze_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[염검을 통하여 슬라임을 내뿜어, 순간적으로 기다란 광선을 만들어 %0.2f 슬라임 피해량의 공격을 합니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.NATURE, dam))
	end,
}

newTalent{
	name = "Natural Acid",
	kr_name = "자연적인 산성 물질",
	type = {"wild-gift/oozing-blades", 2},
	require = gifts_req_high2,
	points = 5,
	mode = "passive",
	getResist = function(self, t) return 10 + self:combatTalentMindDamage(t, 10, 70) end,
	info = function(self, t)
		local res = t.getResist(self, t)
		return ([[당신이 다른 존재에게 산성 속성 피해를 줄 때마다, 상대의 자연 저항력을 2 턴 동안 %d%% 감소시킵니다.
		저항력 감소치는 정신력의 영향을 받아 증가합니다.]]):
		format(res)
	end,
}

newTalent{
	name = "Mind Parasite",
	kr_name = "정신의 기생충",
	type = {"wild-gift/oozing-blades", 3},
	require = gifts_req_high3,
	points = 5,
	equilibrium = 12,
	cooldown = 15,
	range = 6,
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime", trail="slimetrail"}} end,
	tactical = { DISABLE = 2 },
	requires_target = true,
	getChance = function(self, t) return math.min(100, 20 + self:combatTalentMindDamage(t, 10, 70)) end,
	getNb = function(self, t) if self:getTalentLevel(t) <= 4 then return 1 else return 2 end end,
	getTurns = function(self, t) if self:getTalentLevel(t) <= 3 then return 2 else return 3 end end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				target:setEffect(target.EFF_MIND_PARASITE, 6, {chance=t.getChance(self, t), nb=t.getNb(self, t), turns=t.getTurns(self, t)})
			end
		end, {type="slime"})

		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[염검을 사용하여 적에게 작은 벌레를 발사합니다.
		목표에 명중하면 이 벌레는 대상의 뇌 속으로 파고 들어가 6 턴 동안 머무르면서, 숙주가 기술을 사용하는 것을 방해합니다.
		숙주는 기술을 사용할 때마다 %d%% 확률로 %d 가지 기술이 %d 턴의 재사용 대기시간을 가지게 됩니다.
		방해 확률은 정신력의 영향을 받아 증가합니다.]]):
		format(t.getChance(self, t), t.getNb(self, t), t.getTurns(self, t))
	end,
}

newTalent{
	name = "Unstoppable Nature",
	kr_name = "멈출수 없는 자연",
	type = {"wild-gift/oozing-blades", 4},
	require = gifts_req_high4,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 20,
	cooldown = 30,
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	tactical = { BUFF = 2 },
	getFireDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	getChance = function(self, t) return self:getTalentLevel(t) * 14 end,
	freespit = function(self, t, target)
		if game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
					break
				end
			end
		else
			for _, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
					break
				end
			end
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {additive=true, radius=1.1}, {type="flames", zoom=0.5, npow=4, time_factor=2000, color1={0.5,0.7,0,1}, color2={0.3,1,0.3,1}, hide_center=0, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("master_summoner", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.NATURE] = t.getFireDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.NATURE] = t.getResistPenalty(self, t)}),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getFireDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		local chance = t.getChance(self, t)
		return ([[스스로를 자연의 힘으로 둘러쌈으로써, 당신의 모든 자연 공격 피해량을 %d%% 증가시키고 자연 저항 관통력을 %d%% 올려줍니다.
		또 당신이 자연의 권능을 사용하여 피해를 줄 때마다, 당신의 '진흙 점액'이 %d%% 확률로 대상에게 추가적으로 '슬라임 뱉기'를 사용합니다.]])
		:format(damageinc, ressistpen, chance)
	end,
}
