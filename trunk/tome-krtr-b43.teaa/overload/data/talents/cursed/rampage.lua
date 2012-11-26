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
	name = "Rampage",
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
	getMovementSpeedChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.5) * 1.4
	end,
	getCombatPhysSpeedChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.5) * 0.224
	end,
	on_pre_use = function(self, t, silent)
		if self:hasEffect(self.EFF_RAMPAGE) then 
			if not silent then game.logPlayer(self, "You are already rampaging!") end
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
		return ([[You enter a terrible rampage for %d turns (up to a maximum of %d turns), destroying everything in your path. Starting a rampage is instantaneous. There is also a small chance when you take damage that you will rampage. Any talent, rune or infusion you use while rampaging becomes a distraction and reduces the duration of the rampage by 1. Your first movement while rampaging increases the rampage duration by 1.
		Rampage Bonus: +%d%% movement speed.
		Rampage Bonus: +%d%% attack speed]]):format(duration, maxDuration, movementSpeedChange * 100, combatPhysSpeedChange * 100)
	end,
}

newTalent{
	name = "Brutality",
	type = {"cursed/rampage", 2},
	mode = "passive",
	require = cursed_str_req2,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getPhysicalDamageChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.7) * 12
	end,
	getCombatPhysResistChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.7) * 6
	end,
	getCombatMentalResistChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.7) * 6
	end,
	info = function(self, t)
		local physicalDamageChange = t.getPhysicalDamageChange(self, t)
		local combatPhysResistChange = t.getCombatPhysResistChange(self, t)
		local combatMentalResistChange = t.getCombatMentalResistChange(self, t)
		return ([[You attack with mindless brutality. The first critical hit inflicted while rampaging increases the rampage duration by 1.
		Rampage Bonus: Your physical damage increases by %d%%.
		Rampage Bonus: Your physical save increases by %d and mental save increases by %d.]]):format(physicalDamageChange, combatPhysResistChange, combatMentalResistChange)
	end,
}

newTalent{
	name = "Tenacity",
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
		return ([[Nothing will stop your rampage.
		Rampage Bonus: You shrug off up to %d damage each turn during your rampage. If you shrug off more than %d damage, the rampage duration increases by 1.
		Damage increases with the Strength Stat.]]):format(damageShield, damageShieldBonus)
	end,
}

newTalent{
	name = "Slam",
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
			if not silent then game.logPlayer(self, "You must be rampaging to use this talant.") end
			return false
		end
		return true
	end,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_RAMPAGE)
		if not eff then 
			if not silent then game.logPlayer(self, "You must be rampaging to use this talant.") end
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
				game.logSeen(self, "#F53CBE#%s slams %s!", self.name:capitalize(), target.name)
				DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, damage)
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, stunDuration, {apply_power=self:combatPhysicalpower()})
				else
					game.logSeen(target, "#F53CBE#%s resists the stunning blow!", target.name:capitalize())
				end
			
				hitCount = hitCount - 1
				hits = hits + 1
				if hitCount == 0 then break end
			end
		end
		
		-- bonus duration
		if hits >= 2 and eff.actualDuration < eff.maxDuration and not eff.slam then
			game.logPlayer(self, "#F53CBE#Your rampage is invigorated by the collosal slam! (+1 duration)")
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
		return ([[While rampaging, you slam up to %d adjacent opponents, stunning them for %d turns and damaging them for between %d and %d physical damage. Your first slam of at least two opponents increases the rampage duration by 1.
		Damage increases with your Physical Power.]]):format(hitCount, stunDuration, damage * 0.5, damage)
	end,
}
