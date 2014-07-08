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
	name = "Rampage",
	kr_name = "광란",
	type = {"cursed/rampage", 1},
	require = cursed_str_req1,
	points = 5,
	tactical = { ATTACK = 3 },
	cooldown = 24,
	hate = 15,
	no_energy = true,
	getDuration = function(self, t)
		return 5
	end,
	getMaxDuration = function(self, t)
		return 8
	end,
	getMovementSpeedChange = function(self, t) return self:combatTalentScale(t, 1.4, 3.13, 0.75) end, --Nerf this?
	getCombatPhysSpeedChange = function(self, t) return self:combatTalentScale(t, 0.224, 0.5, 0.75) end,
	on_pre_use = function(self, t, silent)
		if self:hasEffect(self.EFF_RAMPAGE) then 
			if not silent then game.logPlayer(self, "이미 광란 상태입니다!") end
			return false
		end
		return true
	end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local eff = {
			actualDuration = duration,
			maxDuration = t.getMaxDuration(self, t),
			movementSpeedChange = t.getMovementSpeedChange(self, t),
			combatPhysSpeedChange = t.getCombatPhysSpeedChange(self, t),
			physicalDamageChange = 0,
			combatPhysResistChange = 0,
			combatMentalResistChange = 0,
			damageShield = 0,
			damageShieldMax = 0,
		}
		if self:knowTalent(self.T_BRUTALITY) then
			local tBrutality = self:getTalentFromId(self.T_BRUTALITY)
			eff.physicalDamageChange = tBrutality.getPhysicalDamageChange(self, tBrutality)
			eff.combatPhysResistChange = tBrutality.getCombatPhysResistChange(self, tBrutality)
			eff.combatMentalResistChange = tBrutality.getCombatMentalResistChange(self, tBrutality)
		end
		
		if self:knowTalent(self.T_TENACITY) then
			local tTenacity = self:getTalentFromId(self.T_TENACITY)
			eff.damageShield = tTenacity.getDamageShield(self, tTenacity)
			eff.damageShieldMax = eff.damageShield
			eff.damageShieldBonus = tTenacity.getDamageShieldBonus(self, tTenacity)
		end
		
		self:setEffect(self.EFF_RAMPAGE, duration, eff)

		return true
	end,
	onTakeHit = function(t, self, fractionDamage)
		if fractionDamage < 0.08 then return false end
		if self:hasEffect(self.EFF_RAMPAGE) then return false end
		if rng.percent(50) then
			t.action(self, t, 0)
			return true
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local maxDuration = t.getMaxDuration(self, t)
		local movementSpeedChange = t.getMovementSpeedChange(self, t)
		local combatPhysSpeedChange = t.getCombatPhysSpeedChange(self, t)
		return ([[%d 턴 동안 광란 상태가 되어, 모든 것을 파괴합니다. (최대 %d 턴 까지 유지할 수 있습니다) 광란 상태는 턴 소모 없이 들어갈 수 있으며, 최대 생명력의 8%% 이상에 해당하는 피해를 한번에 받아도 50%% 확률로 광란 상태가 됩니다.
		모든 기술, 룬, 주입 능력을 사용할 때마다 조금씩 안정을 찾아, 광란 상태의 지속시간이 1 턴 줄어듭니다. 광란 상태에 들어간 뒤 첫 걸음을 내딛으면, 광란 상태의 지속시간이 1 턴 증가합니다.
		- 광란 상태일 때, 이동 속도가 %d%% / 공격 속도가 %d%% 상승합니다.]]):format(duration, maxDuration, movementSpeedChange * 100, combatPhysSpeedChange * 100)
	end,
}

newTalent{
	name = "Brutality",
	kr_name = "무자비",
	type = {"cursed/rampage", 2},
	mode = "passive",
	require = cursed_str_req2,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getPhysicalDamageChange = function(self, t) return self:combatTalentScale(t, 12, 37) end,
	getCombatPhysResistChange = function(self, t) return self:combatTalentScale(t, 6, 18.5, 0.75) end,
	getCombatMentalResistChange = function(self, t) return self:combatTalentScale(t, 6, 18.5, 0.75) end,
	info = function(self, t)
		local physicalDamageChange = t.getPhysicalDamageChange(self, t)
		local combatPhysResistChange = t.getCombatPhysResistChange(self, t)
		local combatMentalResistChange = t.getCombatMentalResistChange(self, t)
		return ([[무자비하고 난폭하게 공격합니다. 광란 상태에서 첫 번째 치명타 효과를 내면, 광란 상태의 지속시간이 1 턴 증가합니다.
		- 광란 상태일 때, 추가적으로 물리 피해량이 %d%% / 물리 내성이 %d / 정신 내성이 %d 상승합니다.]]):format(physicalDamageChange, combatPhysResistChange, combatMentalResistChange)
	end,
}

newTalent{
	name = "Tenacity",
	kr_name = "끈기",
	type = {"cursed/rampage", 3},
	mode = "passive",
	require = cursed_str_req3,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getDamageShield = function(self, t)
		return self:combatTalentStatDamage(t, "str", 20, 100)
	end,
	getDamageShieldBonus = function(self, t)
		return t.getDamageShield(self, t) * 4
	end,
	info = function(self, t)
		local damageShield = t.getDamageShield(self, t)
		local damageShieldBonus = t.getDamageShieldBonus(self, t)
		return ([[그 무엇도 광란 상태를 멈출 수 없게 됩니다. 
		- 광란 상태일 때 추가적으로 매 턴마다 최대 %d 피해를 흡수할 수 있게 되며, 총 피해 흡수량이 %d 를 넘을 경우 광란 상태의 지속시간이 1 턴 증가합니다.
		피해 흡수량은 힘 능력치의 영향을 받아 증가합니다.]]):format(damageShield, damageShieldBonus)
	end,
}

newTalent{
	name = "Slam",
	kr_name = "광란의 후려치기",
	type = {"cursed/rampage", 4},
	require = cursed_str_req4,
	points = 5,
	cooldown = 6,
	hate = 3,
	random_ego = "attack",
	tactical = { ATTACKAREA = { weapon = 3 } },
	getHitCount = function(self, t)
		return 2 + math.min(math.floor(self:getTalentLevel(t) * 0.5), 3)
	end,
	getStunDuration = function(self, t)
		return 2
	end,
	getDamage = function(self, t)
		return self:combatTalentPhysicalDamage(t, 10, 140)
	end,
	on_pre_use = function(self, t, silent)
		if not self:hasEffect(self.EFF_RAMPAGE) then 
			if not silent then game.logPlayer(self, "이 기술을 사용하려면 광란 상태여야 합니다.") end
			return false
		end
		return true
	end,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_RAMPAGE)
		if not eff then 
			if not silent then game.logPlayer(self, "이 기술을 사용하려면 광란 상태여야 합니다.") end
			return false
		end
		
		local hitCount = t.getHitCount(self, t)
		local hits = 0
		local damage = t.getDamage(self, t) * rng.float(0.5, 1)
		local stunDuration = t.getStunDuration(self, t)
		local start = rng.range(0, 8)
		for i = start, start + 8 do
			local x = self.x + (i % 3) - 1
			local y = self.y + math.floor((i % 9) / 3) - 1
			local target = game.level.map(x, y, Map.ACTOR)
			if target and not target.dead and self:reactionToward(target) < 0 then
				game.logSeen(self, "#F53CBE#%s %s 후려칩니다!", (self.kr_name or self.name):capitalize():addJosa("가"), (target.kr_name or target.name):addJosa("를"))
				DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, damage)
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, stunDuration, {apply_power=self:combatPhysicalpower()})
				else
					game.logSeen(target, "#F53CBE#%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				end
			
				hitCount = hitCount - 1
				hits = hits + 1
				if hitCount == 0 then break end
			end
		end
		
		-- bonus duration
		if hits >= 2 and eff.actualDuration < eff.maxDuration and not eff.slam then
			game.logPlayer(self, "#F53CBE#적을 연속으로 후려쳐, 더욱 광란 상태에 빠져듭니다! (지속시간 1 턴 추가)")
			eff.actualDuration = eff.actualDuration + 1
			eff.dur = eff.dur + 1
			eff.slam = true
		end

		return true
	end,
	info = function(self, t)
		local hitCount = t.getHitCount(self, t)
		local stunDuration = t.getStunDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[광란 상태일 때 사용할 수 있으며, 근처의 적 %d 명을 동시에 후려쳐 %d 턴 동안 기절시키고 %d - %d 물리 피해를 줍니다. 처음으로 두 명 이상의 적에게 후려치기를 날릴 경우, 광란 상태의 지속시간이 1 턴 늘어납니다.
		피해량은 물리력 능력치의 영향을 받아 증가합니다.]]):format(hitCount, stunDuration, damage * 0.5, damage)
	end,
}
