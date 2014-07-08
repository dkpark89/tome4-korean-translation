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
		주무기 공격이 명중하면, 대상을 %d 턴 동안 기절시킵니다.
		이번 공격에 한해, 정확도와 피해량의 계산에 힘과 민첩 능력치 대신 의지와 교활함 능력치를 사용합니다.
		또한, 활성화 중인 오러로 인한 피해 증가가 이번 공격에 적용됩니다.]]): 
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
	getChance = function(self, t) return math.floor(self:combatStatLimit("cun", 100, 5, 30)) end,
	action = function(self, t)
		self:setEffect(self.EFF_WEAPON_WARDING, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[정신 상태를 수비적으로 돌립니다.
		1 턴 동안, 다음 물리 공격을 염동력으로 쥐고 있는 무기로 완전히 방어한 뒤 %d%% 주무기 피해로 반격합니다.
		순수 기술 레벨이 3 이상일 경우, 공격과 함께 적의 무장을 3 턴 동안 해제시킵니다.
		순수 기술 레벨이 5 이상일 경우, 이 기술을 사용하지 않아도 매 턴 마다 한번씩 %d%% 확률의 반사적인 막기를 사용 할 수 있습니다. 이 확률은 교활함 능력치에 따라 결정됩니다. 반사적으로 막을 때마다 염력이 15 씩 사용되고, 염력이 부족한 경우 반사적인 막기를 사용하지 않습니다.
		기술을 사용하기 위해서는 염동력으로 쥐고 있는 무기가 필요합니다.]]):
		format(100 * t.getWeaponDamage(self, t), t.getChance(self, t))
	end,
}

newTalent{
	name = "Impale",
	kr_name = "꿰뚫기", 
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
			game.logPlayer(self, "염동력으로 무기를 쥐고 있지 않으면 사용할 수 없습니다!") 
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
					game.logSeen(self, "#CRIMSON#%s %s의 보호막을 부숴버립니다!", (self.kr_name or self.name):capitalize():addJosa("가"), (target.kr_name or target.name)) 
					target:removeEffect(eff[2])
				end
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[의지를 집중하여, 염동력으로 쥐고 있는 무기로 대상을 꿰뚫고 베어버립니다.
		이를 통해 %d%% 무기 피해를 주고, 4 턴에 걸쳐 출혈로 %0.1f 물리 피해를 가합니다.
		기술 레벨이 3 이상일 경우, 공격이 더 강력해져 %d%% 확률로 대상의 일시적인 피해 보호막 하나를 부숴버립니다.
		이번 공격에 한해, 정확도와 피해량의 계산에 힘과 민첩 능력치 대신 의지와 교활함 능력치를 사용합니다.
		출혈 확률은 정신력 능력치의 영향을 받아 증가합니다.]]): 
		format(100 * t.getWeaponDamage(self, t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self,t)), t.getShatter(self, t))
	end,
}
