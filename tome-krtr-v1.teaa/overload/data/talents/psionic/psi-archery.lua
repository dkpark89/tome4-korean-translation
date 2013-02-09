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
	name = "Guided Shot",
	kr_display_name = "유도 사격",
	type = {"psionic/psi-archery", 1},
	require = psi_cun_high1,
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	psi = 10,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	range = archery_range,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("bow") then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이 필요합니다.") end return false end return true end,
	shot_boost = function(self, t)
		return 30 + 10*self:getTalentLevel(t)
	end,
	use_psi_archery = function(self, t)
		local pf_weapon = self:getInven("PSIONIC_FOCUS")[1]
		if pf_weapon and pf_weapon.archery then
			return true
		else
			return false
		end
	end,
	action = function(self, t)
		local inc = t.shot_boost(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {atk = inc, crit_chance = inc, use_psi_archery = t.use_psi_archery(self,t)})
		return true
	end,
	info = function(self, t)
		return ([[염력으로 화살을 조절하여, 더 정확하고 치명적인 공격을 합니다. 피해량은 변하지 않지만, 정확도와 치명타율이 %d 증가합니다.]]):format(t.shot_boost(self, t))
	end,
}

newTalent{
	name = "Augmented Shot",
	kr_display_name = "염력 사격",
	type = {"psionic/psi-archery", 2},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	psi = 15,
	require = psi_cun_high2,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("bow") then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이 필요합니다.") end return false end return true end,
	apr_boost = function(self, t)
		return 10 + 10*self:getTalentLevel(t)
	end,
	dam_mult = function(self, t)
		return self:combatTalentWeaponDamage(t, 1.5, 2.5)
	end,
	use_psi_archery = function(self, t)
		local pf_weapon = self:getInven("PSIONIC_FOCUS")[1]
		if pf_weapon and pf_weapon.archery then
			return true
		else
			return false
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.dam_mult(self, t), apr = t.apr_boost(self, t), use_psi_archery = t.use_psi_archery(self,t)})
		return true
	end,
	info = function(self, t)
		return ([[활에 염력을 불어넣어, 그 어떤 궁수보다도 강력한 사격을 합니다.
		관통율이 %d 증가하며, 피해량이 %d%% 증가합니다.]]):format(t.apr_boost(self, t), t.dam_mult(self, t) * 100)
	end,
}

newTalent{
	name = "Thought-quick Shot",
	kr_display_name = "순간 사격",
	type = {"psionic/psi-archery", 3},
	require = psi_cun_high3,
	no_energy = true,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t)
		return math.ceil(math.max(18 - 2 * self:getTalentLevel(t), 5))
	end,
	psi = 20,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	range = archery_range,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon("bow") then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이 필요합니다.") end return false end return true end,
	use_psi_archery = function(self, t)
		local pf_weapon = self:getInven("PSIONIC_FOCUS")[1]
		if pf_weapon and pf_weapon.archery then
			return true
		else
			return false
		end
	end,
	action = function(self, t)
		local old = self.energy.value
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {use_psi_archery = t.use_psi_archery(self,t)})
		self.energy.value = old
		return true
	end,
	info = function(self, t)
		return ([[스치는 생각처럼 빠르게 화살을 날립니다. 턴 소모 없이 화살을 날리며, 기술 레벨이 오르면 재사용 대기시간이 짧아집니다.]])
	end,
}

newTalent{
	name = "Masterful Telekinetic Archery",
	kr_display_name = "염동력 궁술의 달인",
	type = {"psionic/psi-archery", 4},
	require = psi_cun_high4,
	points = 5,
	psi = 30,
	cooldown = 50,
	range = archery_range,
	direct_hit = true,
	tactical = { BUFF = 3 },
	duration = function(self, t)
		return math.ceil(3 + self:getTalentLevel(t))
	end,
	do_tkautoshoot = function(self, t)
		if game.zone.wilderness then return end

		local targnum = 1
		if self:hasEffect(self.EFF_PSIFRENZY) then targnum = 1 + math.ceil(0.2*self:getTalentLevel(self.T_FRENZIED_PSIFIGHTING)) end
		local speed, hit = nil, false
		local sound, sound_miss = nil, nil
		--dam = self:getTalentLevel(t)
		local target
		local minDistance = 9999
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
				tgts[#tgts+1] = a
				local distance = core.fov.distance(self.x, self.y, a.x, a.y)
				if (not target or distance < minDistance) and self:hasLOS(a.x, a.y) then
					target = a
					minDistance = distance
				end
			end
		end end


		--local tg = {type="hit", range=10, talent=t}
		for i = 1, targnum do
			if #tgts <= 0 then break end

			local a, id = rng.table(tgts)
			--local a, id = tgts[i]
			--local targets = self:archeryAcquireTargets(target)
			table.remove(tgts, id)
			local weapon, ammo = self:hasArcheryWeapon()
			local targets = {}
			local am
			if not ammo.infinite then
				am = self:removeObject(self:getInven("QUIVER"), 1)
			else
				am = ammo
			end
			if am then
				targets = {{x=a.x, y=a.y, ammo=am.combat}}
			end

			if self:getInven(self.INVEN_PSIONIC_FOCUS) then
				for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
					if o.combat and o.archery then
						print("[PSI ATTACK] attacking with", o.name)
						self:archeryShoot(targets, t, nil, {use_psi_archery = true})
						--local s, h = self:attackTargetWith(a, o.combat, nil, 1)
						--speed = math.max(speed or 0, s)
						--hit = hit or h
						--if hit and not sound then sound = o.combat.sound
						--elseif not hit and not sound_miss then sound_miss = o.combat.sound_miss end
						if not o.combat.no_stealth_break then break_stealth = true end
						self:breakStepUp()
					end
				end
			else
				return nil
			end

		end
		--return hit
	end,
	action = function (self, t)
		if not self:getInven("PSIONIC_FOCUS") then return end
		local tkweapon = self:getInven("PSIONIC_FOCUS")[1]
		if type(tkweapon) == "boolean" then tkweapon = nil end
		if not tkweapon or not tkweapon.archery then
			game.logPlayer(self, "염력으로 활을 쥐고 있어야 할 수 있는 행동입니다.")
			return nil
		end
		self:setEffect(self.EFF_MASTERFUL_TELEKINETIC_ARCHERY, t.duration(self, t), {power=1})
		return true
	end,
	info = function(self, t)
		local duration = t.duration(self, t)
		local atk = 0
		local dam = 0
		local apr = 0
		local crit = 0
		local speed = 1
		local inven = self:getInven("PSIONIC_FOCUS")
		local o = inven and inven[1]
		if type(o) == "boolean" then o = nil end
		if not o then
			return ([[염동력으로 활을 쥐어 사용합니다. %d 턴 동안 가장 근접한 적에게 자동으로 화살을 발사합니다.
			힘과 민첩 능력치 대신, 의지와 교활함 능력치로 활의 피해량과 정확도가 계산됩니다.
			현재 염동력으로 활을 들지 않은 상태입니다.]]):format(duration)
		end
		if o.type == "weapon" then
			self.use_psi_combat = true
			atk = self:combatAttack(o.combat)
			dam = self:combatDamage(o.combat)
			apr = self:combatAPR(o.combat)
			crit = self:combatCrit(o.combat)
			speed = self:combatSpeed(o.combat)
			self.use_psi_combat = false
		end
		return ([[염동력으로 활을 쥐어 사용합니다. %d 턴 동안 가장 근접한 적에게 자동으로 화살을 발사합니다.
			힘과 민첩 능력치 대신, 의지와 교활함 능력치로 활의 피해량과 정확도가 계산됩니다.
			활의 성능은 다음과 같습니다.
			- 정확도 : %d
			- 피해량 : %d
			- 방어도 관통 : %d
			- 치명타율 : %0.2f
			- 공격 속도 : %0.2f]]):
		format(duration, atk, dam, apr, crit, speed)
	end,
}
