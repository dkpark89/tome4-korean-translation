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
	name = "Telekinetic Smash",
	kr_name = "염동력 강타",
	type = {"psionic/psi-fighting", 1},
	require = psi_cun_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	psi = 10,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	duration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "무기를 들지 않으면 이 기술을 사용할 수 없습니다.")
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attr("use_psi_combat", 1)
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.9, 1.5), true)
		if self:getInven(self.INVEN_PSIONIC_FOCUS) then
			for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
				if o.combat and not o.archery then
					self:attackTargetWith(target, o.combat, nil, self:combatTalentWeaponDamage(t, 0.9, 1.5))
				end
			end
		end
		if hit and target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, t.duration(self,t), {apply_power=self:combatMindpower()})
		end
		self:attr("use_psi_combat", -1)
		return true
	end,
	info = function(self, t)
		return ([[염력을 실어담아, 들고 있는 주무기와 염동무기로 강타를 날려 %d%% 무기 피해를 줍니다.
		If your mainhand weapon hits, you will also stun the target for %d turns.
		이번 공격에 한해, 정확도와 피해량의 계산에 힘과 민첩 능력치 대신 의지와 교활함 능력치를 사용합니다.
		Any active Aura damage bonusses will extend to the weapons used for this attack.]]): --@@ 한글화 필요 #60~63
		format(100 * self:combatTalentWeaponDamage(t, 0.9, 1.5), t.duration(self,t))
	end,
}

newTalent{
	name = "Augmentation",
	kr_name = "증대",
	type = {"psionic/psi-fighting", 2},
	require = psi_cun_req2,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getMult = function(self, t) return self:combatTalentScale(t, 0.07, 0.25) end,
	activate = function(self, t)
		local str_power = t.getMult(self, t)*self:getWil()
		local dex_power = t.getMult(self, t)*self:getCun()
		return {
			stats = self:addTemporaryValue("inc_stats", {
				[self.STAT_STR] = str_power,
				[self.STAT_DEX] = dex_power,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		local inc = t.getMult(self, t)
		local str_power = inc*self:getWil()
		local dex_power = inc*self:getCun()
		return ([[정신을 집중하여, 조금 더 강력하고 민첩해집니다. 의지와 교활함 능력치의 %d%% 만큼 힘과 민첩 능력치가 증가하게 됩니다.
		그 결과, 힘 능력치가 %d / 민첩 능력치가 %d 증가합니다.]]):
		format(inc*100, str_power, dex_power)
	end,
}

newTalent{
	name = "Warding Weapon",
	kr_name = "방어적 무기술",
	type = {"psionic/psi-fighting", 3},
	require = psi_cun_req3,
	points = 5,
	cooldown = 10,
	psi = 15,
	no_energy = true,
	tactical = { BUFF = 2 },
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.75, 1.1) end,
	action = function(self, t)
		self:setEffect(self.EFF_WEAPON_WARDING, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[Assume a defensive mental state.
		For one turn, you will fully block the next melee attack used against you with your telekinetically-wielded weapon and then strike the attacker with it for %d%% weapon damage. 
		At talent level 3 you will also disarm the attacker for 3 turns.
		This requires both a mainhand and a telekinetically-wielded weapon.]]): --@@ 한글화 필요 #120~123
		format(100 * t.getWeaponDamage(self, t))
	end,
}

newTalent{
	name = "Impale",
	--kr_name = "", --@@ 한글화 필요
	type = {"psionic/psi-fighting", 4},
	require = psi_cun_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	psi = 20,
	range = 3,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	getDamage = function (self, t) return math.floor(self:combatTalentMindDamage(t, 12, 340)) end,
	getWeaponDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.6) end,
	getShatter = function(self, t) return self:combatTalentLimit(t, 100, 10, 85) end,
	action = function(self, t)
		local weapon = self:getInven(self.INVEN_PSIONIC_FOCUS) and self:getInven(self.INVEN_PSIONIC_FOCUS)[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed")then
			game.logPlayer(self, "You cannot do that without a weapon in your telekinetic slot.") --@@ 한글화 필요
			return nil
		end
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 3 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, t.getWeaponDamage(self, t))
		if hit and target:canBe("cut") then
			target:setEffect(target.EFF_CUT, 4, {power=t.getDamage(self,t)/4, apply_power=self:combatMindpower()})
		end

		if hit and rng.percent(t.getShatter(self, t)) and self:getTalentLevel(t) >= 3 then
			local effs = {}

			-- Go through all shield effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.status == "beneficial" and e.subtype and e.subtype.shield then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, 1 do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					game.logSeen(self, "#CRIMSON#%s shatters %s shield!", (self.kr_name or self.name):capitalize(), (target.kr_name or target.name)) --@@ 한글화 필요
					target:removeEffect(eff[2])
				end
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[Focus your will into a powerful thrust of your telekinetically-wielded weapon to impale your target and then viciously rip it free.
		This deals %d%% weapon damage and then causes the victim to bleed for %0.1f Physical damage over four turns. 
		At level 3 the thrust is so powerful that it has %d%% chance to shatter a temporary damage shield if one exists.
		Your Willpower and Cunning are used instead of Strength and Dexterity to determine Accuracy and damage.
		The bleeding damage increases with your Mindpower.]]): --@@ 한글화 필요 #183~187
		format(100 * t.getWeaponDamage(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self,t)), t.getShatter(self, t))
	end,
}
