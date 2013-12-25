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

local function combatTalentDamage(self, t, min, max)
	return self:combatTalentSpellDamage(t, min, max, self.level + self:getWil())
end

local function getWillFailureEffectiveness(self, minChance, maxChance, attackStrength)
	return attackStrength * self:getWil() * 0.05 * (minChance + (maxChance - minChance) / 2)
end

-- mindpower bonus for gloom talents
local function gloomTalentsMindpower(self)
	return self:combatScale(self:getTalentLevel(self.T_GLOOM) + self:getTalentLevel(self.T_WEAKNESS) + self:getTalentLevel(self.T_DISMAY) + self:getTalentLevel(self.T_SANCTUARY), 1, 1, 20, 20, 0.75)
end

newTalent{
	name = "Gloom",
	kr_name = "침울한 기운",
	type = {"cursed/gloom", 1},
	mode = "sustained",
	require = cursed_wil_req1,
	points = 5,
	cooldown = 0,
	range = 3,
	no_energy = true,
	tactical = { BUFF = 5 },
	getChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^.5, 100, 7, 1, 15.65, 2.23) end, -- Limit < 100%
	getDuration = function(self, t)
		return 3
	end,
	activate = function(self, t)
		self.torment_turns = nil -- restart torment
		game:playSoundNear(self, "talents/arcane")
		return {
			particle = self:addParticles(Particles.new("gloom", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	do_gloom = function(self, tGloom)
		if game.zone.wilderness then return end

		-- all gloom effects are handled here
		local tWeakness = self:getTalentFromId(self.T_WEAKNESS)
		local tDismay = self:getTalentFromId(self.T_DISMAY)
		--local tSanctuary = self:getTalentFromId(self.T_SANCTUARY)
		--local tLifeLeech = self:getTalentFromId(self.T_LIFE_LEECH)
		--local lifeLeeched = 0
		
		local mindpower = self:combatMindpower(1, gloomTalentsMindpower(self))
		
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(tGloom), true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local target = game.level.map(x, y, Map.ACTOR)
				if target and self:reactionToward(target) < 0 then
					-- check for hate bonus against tough foes
					if target.rank >= 3.5 and not target.gloom_hate_bonus then
						local hateGain = target.rank >= 4 and 20 or 10
						self:incHate(hateGain)
						game.logPlayer(self, "#F53CBE#강력한 적이 침울한 기운 속으로 들어왔습니다! 심장이 요동치기 시작합니다! (+%d 증오)", hateGain)
						target.gloom_hate_bonus = true
					end
				
					-- Gloom
					if self:getTalentLevel(tGloom) > 0 and rng.percent(tGloom.getChance(self, tGloom)) and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
						local effect = rng.range(1, 3)
						if effect == 1 then
							-- confusion
							if target:canBe("confusion") and not target:hasEffect(target.EFF_GLOOM_CONFUSED) then
								target:setEffect(target.EFF_GLOOM_CONFUSED, 2, {power=70})
								hit = true
							end
						elseif effect == 2 then
							-- stun
							if target:canBe("stun") and not target:hasEffect(target.EFF_GLOOM_STUNNED) then
								target:setEffect(target.EFF_GLOOM_STUNNED, 2, {})
								hit = true
							end
						elseif effect == 3 then
							-- slow
							if target:canBe("slow") and not target:hasEffect(target.EFF_GLOOM_SLOW) then
								target:setEffect(target.EFF_GLOOM_SLOW, 2, {power=0.3})
								hit = true
							end
						end
					end

					-- Weakness
					if self:getTalentLevel(tWeakness) > 0 and rng.percent(tWeakness.getChance(self, tWeakness)) and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
						if not target:hasEffect(target.EFF_GLOOM_WEAKNESS) then
							local duration = tWeakness.getDuration(self, tWeakness)
							local incDamageChange = tWeakness.getIncDamageChange(self, tWeakness)
							local hateBonus = tWeakness.getHateBonus(self, tWeakness)
							target:setEffect(target.EFF_GLOOM_WEAKNESS, duration, {incDamageChange=incDamageChange,hateBonus=hateBonus})
							hit = true
						end
					end

					-- Dismay
					if self:getTalentLevel(tDismay) > 0 and rng.percent(tDismay.getChance(self, tDismay)) and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
						target:setEffect(target.EFF_DISMAYED, tDismay.getDuration(self, tDismay), {})
					end

					-- Life Leech
					--if tLifeLeech and self:getTalentLevel(tLifeLeech) > 0 and target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
					--	local damage = tLifeLeech.getDamage(self, tLifeLeech)
					--	local actualDamage = DamageType:get(DamageType.LIFE_LEECH).projector(self, target.x, target.y, DamageType.LIFE_LEECH, damage)
					--	lifeLeeched = lifeLeeched + actualDamage
					--end
				end
			end
		end

		-- life leech
		--if lifeLeeched > 0 then
		--	lifeLeeched = math.min(lifeLeeched, tLifeLeech.getMaxHeal(self, tLifeLeech))
		--	local temp = self.healing_factor
		--	self.healing_factor = 1
		--	self:heal(lifeLeeched)
		--	self.healing_factor = temp
		--	game.logPlayer(self, "#F53CBE#You leech %0.1f life from your foes.", lifeLeeched)
		--end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local duration = t.getDuration(self, t)
		local mindpowerChange = gloomTalentsMindpower(self)
		return ([[끔찍할 정도로 침울한 기운이 주변을 감싸, 주변 3 칸 반경의 적들에게 영향을 줍니다. 매 턴마다, 정신 내성에 따른 저항에 실패한 적은 %d%% 확률로 %d 턴 동안 감속, 기절, 혼란 중 하나의 상태효과에 걸리게 됩니다.
		이 능력은 자연적인 것이며, 발동이나 취소에 어떤 원천력도 사용하지 않습니다. 
		기술 레벨이 오를 때마다 추가적인 정신력 능력치를 받아, 침울한 기운 계열의 상태효과를 더 잘 걸 수 있게 됩니다. (실제로 정신력이 오르는 것은 아닙니다. 현재 상승량 : %+d)]]):format(chance, duration, mindpowerChange)
	end,
}

newTalent{
	name = "Weakness",
	kr_name = "약화",
	type = {"cursed/gloom", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	getChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^.5, 100, 7, 1, 15.65, 2.23) end, -- Limit < 100%
	getDuration = function(self, t)
		return 3
	end,
	getIncDamageChange = function(self, t) return self:combatLimit(self:getTalentLevel(t)^.5, 65, 12, 1, 26.8, 2.23) end, -- Limit to <65%
	getHateBonus = function(self, t)
		return 2
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local duration = t.getDuration(self, t)
		local incDamageChange = t.getIncDamageChange(self, t)
		local hateBonus = t.getHateBonus(self, t)
		local mindpowerChange = gloomTalentsMindpower(self)
		return ([[매 턴마다, 침울한 기운 속에 들어온 적들이 정신 내성에 따른 저항에 실패할 경우 %d%% 확률로 %d 턴 동안 약화 상태가 됩니다. 약화 상태에서는 대상의 피해량이 %d%% 감소하게 되며, 약화된 적을 처음 공격했을 경우 시전자의 증오심이 %d 회복됩니다.
		기술 레벨이 오를 때마다 추가적인 정신력 능력치를 받아, 침울한 기운 계열의 상태효과를 더 잘 걸 수 있게 됩니다. (실제로 정신력이 오르는 것은 아닙니다. 현재 상승량 : %+d)]]):format(chance, duration, -incDamageChange, hateBonus, mindpowerChange)
	end,
}

newTalent{
	name = "Dismay",
	kr_name = "당황",
	type = {"cursed/gloom", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^.5, 100, 3.5, 1, 7.83, 2.23) end, -- Limit < 100%
	getDuration = function(self, t)
		return 3
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local duration = t.getDuration(self, t)
		local mindpowerChange = gloomTalentsMindpower(self)
		return ([[매 턴마다, 침울한 기운 속에 들어온 적들이 정신 내성에 따른 저항에 실패할 경우 %0.1f%% 확률로 %d 턴 동안 정신적 충격을 받아 당황하게 됩니다. 당황한 적을 처음 공격했을 경우 반드시 치명타 효과가 발생합니다.
		기술 레벨이 오를 때마다 추가적인 정신력 능력치를 받아, 침울한 기운 계열의 상태효과를 더 잘 걸 수 있게 됩니다. (실제로 정신력이 오르는 것은 아닙니다. 현재 상승량 : %+d)]]):format(chance, duration, mindpowerChange)
	end,
}

--newTalent{
--	name = "Life Leech",
--	type = {"cursed/gloom", 4},
--	mode = "passive",
--	require = cursed_wil_req4,
--	points = 5,
--	getDamage = function(self, t)
--		return combatTalentDamage(self, t, 2, 10)
--	end,
--	getMaxHeal = function(self, t)
--		return combatTalentDamage(self, t, 4, 25)
--	end,
--	info = function(self, t)
--		local damage = t.getDamage(self, t)
--		local maxHeal = t.getMaxHeal(self, t)
--		local mindpowerChange = self:getTalentLevelRaw(self.T_GLOOM) + self:getTalentLevelRaw(self.T_WEAKNESS) + self:getTalentLevelRaw(self.T_DISMAY) + self:getTalentLevelRaw(self.T_LIFE_LEECH)
--		return ([[Each turn, those caught in your gloom must save against your mindpower or have %0.1f life leeched from them. Life leeched in this way will restore up to a total of %0.1f of your own life per turn. This form of healing is unaffected by healing modifiers.
--		Each point in Life Leech increases the mindpower of all gloom effects (current: %+d).]]):format(damage, maxHeal, mindpowerChange)
--	end,
--}

newTalent{
	name = "Sanctuary",
	kr_name = "도피처",
	type = {"cursed/gloom", 4},
	mode = "passive",
	require = cursed_wil_req4,
	points = 5,
	getDamageChange = function(self, t)
		return math.max(-35, -math.sqrt(self:getTalentLevel(t)) * 11)
	end,
	info = function(self, t)
		local damageChange = t.getDamageChange(self, t)
		local mindpowerChange = gloomTalentsMindpower(self)
		return ([[자신을 감싸고 있는 침울한 기운이 바깥 세상으로부터의 도피처가 됩니다. 침울한 기운 밖에서 날아온 공격을 받을 때, 피해량이 %d%% 감소됩니다.
		기술 레벨이 오를 때마다 추가적인 정신력 능력치를 받아, 침울한 기운 계열의 상태효과를 더 잘 걸 수 있게 됩니다. (실제로 정신력이 오르는 것은 아닙니다. 현재 상승량 : %+d)]]):format(-damageChange, mindpowerChange)
	end,
}
