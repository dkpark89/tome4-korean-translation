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

require "engine.krtrUtils"

newTalent{
	name = "Reclaim",
	kr_name = "환원",
	type = {"wild-gift/eyals-fury", 1},
	require = gifts_req_high1,
	points = 5,
	equilibrium = 5,
	range = 7,
	cooldown = 5,
	tactical = { ATTACK = { NATURE = 1, ACID = 1 } },
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display = {particle=particle, trail=trail}, friendlyfire=false, friendlyblock=false}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 320) end,
	undeadBonus = 25,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not (tx and ty) or core.fov.distance(self.x, self.y, tx, ty) > self:getTalentRange(t) then return nil end
		if not target then return true end
		local dam = self:mindCrit(t.getDamage(self, t))*(1 + ((target.undead or target.type == "construct") and t.undeadBonus/100 or 0))		
		self:project(tg, tx, ty, DamageType.ACID, dam*0.5)
		self:project(tg, tx, ty, DamageType.NATURE, dam*0.5)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[하나의 대상에게 가차없는 자연의 힘을 가해, 대상을 부패시키고 생명의 순환 과정 내부로 환원시킵니다.
		이를 통해 %0.1f 자연 피해와 %0.1f 산성 피해를 주며, 언데드나 건축물에게는 %d%% 더 강력한 피해를 줍니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.NATURE, dam/2), damDesc(self, DamageType.ACID, dam/2), t.undeadBonus)
	end,
}

newTalent{
	name = "Nature's Defiance",
	kr_name = "자연의 저항",
	type = {"wild-gift/eyals-fury", 2},
	require = gifts_req_high2,
	points = 5,
	mode = "passive",
	getSave = function(self, t) return self:combatTalentMindDamage(t, 5, 50) end,
	getResist = function(self, t) return self:combatTalentMindDamage(t, 5, 40) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getAffinity = function(self, t) return self:combatTalentLimit(t, 50, 5, 20) end, -- Limit <50%
	getPower = function(self, t) return self:combatTalentMindDamage(t, 2, 8) end,
	trigger = function(self, t, target, source_t) -- called in damage_types.lua default projector
		self:setEffect(self.EFF_NATURE_REPLENISHMENT, t.getDuration(self, t), {power = t.getPower(self, t)})
		return true
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "resists", {[DamageType.ARCANE]=t.getResist(self, t)})
		self:talentTemporaryValue(p, "damage_affinity", {[DamageType.NATURE]=t.getAffinity(self, t)})
	end,
	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[자연에 대한 헌신을 통해, 육체를 보다 자연의 세계에 동화시키고 비자연적인 힘으로부터 저항력을 얻습니다.
		주문 내성이 %d / 마법 저항력이 %0.1f%% / 자연 피해 친화도가 %0.1f%% 상승합니다.
		마법의 힘을 반항하기 때문에, 주문 공격을 받을 때마다 %0.1f 만큼의 평정을 %d 턴 동안 회복하게 됩니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(t.getSave(self, t), t.getResist(self, t), t.getAffinity(self, t), t.getPower(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Acidfire", 
	kr_name = "산화",
	type = {"wild-gift/eyals-fury", 3},
	require = gifts_req_high3,
	points = 5,
	equilibrium = 20,
	cooldown = 25,
	range = 8,
	radius = 4,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { ACID = 2 },  DISABLE = {blind = 1} },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 70) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 20, 40) end, --Limit < 100%
	removeEffect = function(target) -- remove one random beneficial magical effect or sustain
	-- Go through all beneficial magical effects
		local effs = {}
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type == "magical" and e.status == "beneficial" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Go through all sustained spells
		for tid, act in pairs(target.sustain_talents) do
			if act then
				local talent = target:getTalentFromId(tid)
				if talent.is_spell then effs[#effs+1] = {"talent", tid} end
			end
		end
		if #effs == 0 then return end
		local eff = rng.tableRemove(effs)

		if eff[1] == "effect" then
			target:removeEffect(eff[2])
		else
			target:forceUseTalent(eff[2], {ignore_energy=true})
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		local eff = game.level.map:addEffect(self,
			x, y, t.getDuration(self, t), -- duration
			engine.DamageType.ACID_BLIND, t.getDamage(self, t),
			self:getTalentRadius(t), -- radius
			5, nil,
			{type="vapour"},
			function(eff) --update_fct(effect)
				local act
				for i, g in pairs(eff.grids) do
					for j, _ in pairs(eff.grids[i]) do
						act = game.level.map(i, j, engine.Map.ACTOR)
						if act then
							if rng.percent(eff.chance) then
								eff.removeEffect(act)
							end
						end
					end
				end
			end,
			false, -- no friendly fire
			false -- no self fire
		)
		eff.chance = t.getChance(self, t)
		eff.removeEffect = t.removeEffect
		eff.name = "Acidfire cloud"
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[대지의 힘을 끌어내, 주변 %d 칸 반경에 %d 턴 동안 실명성, 부식성 산성 구름을 만들어냅니다.
		매 턴마다, 이 구름은 적들에게 %0.1f 산성 피해를 주고 %d%% 확률로 하나의 이로운 마법적 효과를 태워버립니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), t.getDuration(self, t), damDesc(self, DamageType.ACID, t.getDamage(self, t)), t.getChance(self, t))
	end,
}

newTalent{
	name = "Eyal's Wrath",
	kr_name = "에이알의 분노",
	type = {"wild-gift/eyals-fury", 4},
	require = gifts_req_high5,
	points = 5,
	equilibrium = 20,
	cooldown = 20,
	radius = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 6)) end, --Limit < 10
	tactical = { ATTACKAREA = { Nature = 2 },  EQUILIBRIUM = 1 },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	getDrain = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	drainMagic = function(eff, act)
		if act:attr("invulnerable") or act:attr("no_timeflow") then return end
		local mana = math.min(eff.drain, act:getMana())
		local vim = math.min(eff.drain / 2, act:getVim())
		local positive = math.min(eff.drain / 4, act:getPositive())
		local negative = math.min(eff.drain / 4, act:getNegative())
		act:incMana(-mana); act:incVim(-vim); act:incPositive(-positive); act:incNegative(-negative)
		local drain = mana + vim + positive + negative
		if drain > 0 then
			game:delayedLogMessage(eff.src, act, "Eyal's Wrath", ("#CRIMSON#%s 마법적 원천력을 흡수했습니다!"):format(eff:getName():addJosa("가"))) 
			eff.src:incEquilibrium(-drain/10)
		end
	end,
	action = function(self, t)
		-- Add a lasting map effect
		local eff = game.level.map:addEffect(self,
			self.x, self.y, 7,
			DamageType.NATURE, t.getDamage(self, t),
			t.radius(self, t),
			5, nil,
			{type="generic_vortex", args = {radius = t.radius(self, t), rm = 5, rM=55, gm=250, gM=255, bm = 180, bM=255, am= 35, aM=90, density = 100}, only_one=true },
			function(eff)
				eff.x = eff.src.x
				eff.y = eff.src.y
				local act
				for i, g in pairs(eff.grids) do
					for j, _ in pairs(eff.grids[i]) do
						act = game.level.map(i, j, engine.Map.ACTOR)
						if act and act ~= eff.src and act:reactionToward(eff.src) < 0 then
							eff.drainMagic(eff, act)
						end
					end
				end
				return true
			end,
			false, false
		)
		eff.drain = t.getDrain(self, t)
		eff.drainMagic = t.drainMagic
		eff.name = "Eyal's Wrath"
		eff.kr_name = "에이알의 분노"
		game:playSoundNear(self, "talents/thunderstorm")
		return true
	end,
	info = function(self, t)
		local drain = t.getDrain(self, t)
		return ([[자연과의 깊은 연결을 통해, %d 칸 범위의 자연력 폭풍을 %d 턴 동안 만들어냅니다.
		이 폭풍은 시전자를 따라 움직이며, 매 턴마다 적에게 %0.1f 자연 피해를 줍니다.
		또한 이 폭풍에 피해를 입는 적은 추가적으로 %d 마나 / %d 원기 / %d 양기 / %d 음기를 흡수당하며, 시전자는 흡수된 양의 10%% 만큼 평정을 회복합니다.
		피해량과 원천력 흡수량은 정신력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), t.getDuration(self, t), damDesc(self, DamageType.NATURE, t.getDamage(self, t)), drain, drain/2, drain/4, drain/4)
	end,
}
