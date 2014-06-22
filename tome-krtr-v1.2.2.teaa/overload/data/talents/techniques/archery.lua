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

-- Default archery attack
newTalent{
	name = "Shoot",
	kr_name = "사격",
	type = {"technique/archery-base", 1},
	no_energy = "fake",
	hide = true,
	innate = true,
	points = 1,
	cooldown = 0,
	stamina = function(self, t)
		if not self:hasArcheryWeapon("sling") or not self:isTalentActive("T_SKIRMISHER_BOMBARDMENT") then return nil end

		local b = self:getTalentFromId("T_SKIRMISHER_BOMBARDMENT")
		return b.shot_stamina(self, b)
	end,
	range = archery_range,
	message = "@Source1@ 사격을 했습니다!",
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	no_unlearn_last = true,
	use_psi_archery = function(self, t)
		local inven = self:getInven("PSIONIC_FOCUS")
		if not inven then return false end
		local pf_weapon = inven[1]
		if pf_weapon and pf_weapon.archery then
			return true
		else
			return false
		end
	end,
	action = function(self, t)
		-- Most of the time use the normal shoot.
		if not self:hasArcheryWeapon("sling") or not self:isTalentActive("T_SKIRMISHER_BOMBARDMENT") then
			local targets = self:archeryAcquireTargets(nil, {one_shot=true})
			if not targets then return end
			self:archeryShoot(targets, t, nil, {use_psi_archery = t.use_psi_archery(self, t)})
			return true
		end

		local weapon, ammo, offweapon = self:hasArcheryWeapon()
		if not weapon then return nil end
		local infinite = ammo.infinite or self:attr("infinite_ammo")
		if not ammo or (ammo.combat.shots_left <= 0 and not infinite) then
			game.logPlayer(self, "화살이나 탄환이 다 떨어졌습니다!") 
			return nil
		end

		-- Bombardment.
		local weapon = self:hasArcheryWeapon("sling")
		local bombardment = self:getTalentFromId("T_SKIRMISHER_BOMBARDMENT")
		local shots = bombardment.bullet_count(self, bombardment)

		-- Do targeting.
		local old_target_forced = game.target.forced
		local tg = {type = "bolt", range = archery_range(self),	talent = t}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		game.target.forced = {x, y, target}

		-- Fire all shots.
		local i
		for i = 1, shots do
			local targets = self:archeryAcquireTargets(nil, {no_energy=true, one_shot=true})
			if not targets then break end
			self:archeryShoot(targets, t, nil, {use_psi_archery = t.use_psi_archery(self, t)})
		end

		local speed = self:combatSpeed(weapon)
		self:useEnergy(game.energy_to_act * (speed or 1))

		game.target.forced = old_target_forced

		return i ~= 1
	end,
	info = function(self, t)
		return ([[장거리 무기(활, 투석구 혹은 기타 장치)를 발사합니다!]])
	end,
}
newTalent{
	name = "Reload",
	kr_name = "재장전",
	type = {"technique/archery-base", 1},
	cooldown = 2,
	innate = true,
	points = 1,
	tactical = { AMMO = 2 },
	no_energy = true,
	no_reload_break = true,
	no_break_stealth = true,
	on_pre_use = function(self, t, silent)
		local q = self:hasAmmo()
		if not q then if not silent then game.logPlayer(self, "화살통이나 탄환 주머니를 착용해야 합니다.") end return false end
		if q.combat.shots_left >= q.combat.capacity then return false end
		return true 
	end,
	no_unlearn_last = true,
	action = function(self, t)
		if self.resting then return end
		local ret = self:reload()
		if ret then
			self:setEffect(self.EFF_RELOAD_DISARMED, 1, {})
		end
		return true
	end,
	info = function(self, t)
		return ([[재빠르게 %d 발의 화살이나 탄환을 재장전합니다. (해당 무기 수련 기술과 장비 보너스에 의존)
		직접 재장전하는 것은 시간이 소모되지 않지만, 대신 2 턴 동안 무장해제 된 것으로 간주됩니다.
		재장전 기술은 사용해도 은신 상태가 해제되지 않습니다.]]) 
		:format(self:reloadRate())
	end,
}

newTalent{
	name = "Steady Shot",
	kr_name = "정밀 사격",
	type = {"technique/archery-training", 1},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 3,
	stamina = 8,
	require = techs_dex_req1,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1.1, 2.2)})
		return true
	end,
	info = function(self, t)
		return ([[안정된 자세로 정확하게 사격하여, %d%% 의 무기 피해를 줍니다.]]):format(self:combatTalentWeaponDamage(t, 1.1, 2.2) * 100)
	end,
}

newTalent{
	name = "Aim",
	kr_name = "조준",
	type = {"technique/archery-training", 2},
	mode = "sustained",
	points = 5,
	require = techs_dex_req2,
	cooldown = 8,
	sustain_stamina = 20,
	no_energy = true,
	tactical = { BUFF = 2 },
	no_npc_use = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	getCombatVals = function(self, t)
		local vals = {speed = -self:combatTalentLimit(t, 0.5, 0.05, 0.25), -- Limit < 50% speed loss
			crit =  self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 7, 0, 57, 50),
			atk = self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 4, 0, 54, 50),
			dam = self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 4, 0, 54, 50),
			apr = self:combatScale(self:getTalentLevel(t) * self:getDex(10, true), 3, 0, 53, 50)}
		return vals
	end,
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "활이나 투석구 없이는 조준 기술을 쓸 수 없습니다!")
			return nil
		end

		if self:isTalentActive(self.T_RAPID_SHOT) then self:forceUseTalent(self.T_RAPID_SHOT, {ignore_energy=true}) end
		local vals = t.getCombatVals(self, t)
		return {
			speed = self:addTemporaryValue("combat_physspeed", vals.speed),
			crit = self:addTemporaryValue("combat_physcrit", vals.crit),
			atk = self:addTemporaryValue("combat_dam", vals.atk),
			dam = self:addTemporaryValue("combat_atk", vals.dam),
			apr = self:addTemporaryValue("combat_apr", vals.apr),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_apr", p.apr)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self, t)
		local vals = t.getCombatVals(self, t)
		return ([[사격할 때, 보다 차분하게 집중하여 적을 조준합니다. 물리력이 %d / 정확도가 %d / 방어도 관통이 %d / 치명타율이 %d%% 증가하는 대신, 사격 속도가 %d%% 만큼 감소됩니다.
		조준으로 인해 얻는 긍정적 효과들은 민첩 능력치의 영향을 받아 증가합니다.]]):
		format(vals.dam, vals.atk, vals.apr, vals.crit, -vals.speed * 100)
	end,
}

newTalent{
	name = "Rapid Shot",
	kr_name = "속사",
	type = {"technique/archery-training", 3},
	mode = "sustained",
	points = 5,
	require = techs_dex_req3,
	cooldown = 8,
	sustain_stamina = 20,
	no_energy = true,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	getCombatVals = function(self, t)
		local vals = {speed = self:combatTalentScale(t, 0.1, 0.5, 0.75),
			crit = -self:combatTalentScale(t, 10.4, 20),
			atk = -self:combatTalentScale(t, 10.4, 20, 0.75),
			dam = -self:combatTalentScale(t, 10.4, 20, 0.75)
			}
		return vals
	end,
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "활이나 투석구 없이는 속사 기술을 사용할 수 없습니다!")
			return nil
		end

		if self:isTalentActive(self.T_AIM) then self:forceUseTalent(self.T_AIM, {ignore_energy=true}) end
		local vals = t.getCombatVals(self, t)
		return {
			speed = self:addTemporaryValue("combat_physspeed", vals.speed),
			atk = self:addTemporaryValue("combat_dam", vals.atk),
			dam = self:addTemporaryValue("combat_atk", vals.dam),
			crit = self:addTemporaryValue("combat_physcrit", vals.crit),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_dam", p.dam)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		local vals = t.getCombatVals(self, t)
		return ([[사격할 때, 낼 수 있는 최대한의 속도를 냅니다. 발사 속도가 %d%% 증가하는 대신, 정확도가 %d / 물리력이 %d / 치명타율이 %d 감소합니다.]]):
		format(vals.speed*100, vals.atk, vals.dam, vals.crit)
	end,
}

newTalent{
	name = "Relaxed Shot",
	kr_name = "느긋한 한 발",
	type = {"technique/archery-training", 4},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	require = techs_dex_req4,
	range = archery_range,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 }, STAMINA = 1 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 0.5, 1.1)})
		self:incStamina(12 + self:getTalentLevel(t) * 8)
		return true
	end,
	info = function(self, t)
		return ([[힘을 빼고 사격하여 %d%% 의 무기 피해를 주고, 그동안 몸의 긴장을 풀어 %d 만큼의 체력을 회복합니다.]]):format(self:combatTalentWeaponDamage(t, 0.5, 1.1) * 100, 12 + self:getTalentLevel(t) * 8)
	end,
}

-------------------------------- Utility -----------------------------------

newTalent{
	name = "Flare",
	kr_name = "조명탄",
	type = {"technique/archery-utility", 1},
	no_energy = "fake",
	points = 5,
	cooldown = 15,
	stamina = 15,
	range = archery_range,
	radius = function(self, t)
		local rad = 1
		if self:getTalentLevel(t) >= 3 then rad = rad + 1 end
		if self:getTalentLevel(t) >= 5 then rad = rad + 1 end
		return rad
	end,
	require = techs_dex_req1,
	tactical = { ATTACKAREA = { FIRE = 2 }, DISABLE = { blind = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	requires_target = true,
	target = function(self, t)
		return {type="ball", x=x, y=y, radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	archery_onreach = function(self, t, x, y)
		local tg = self:getTalentTarget(t)
		self:project(tg, x, y, DamageType.LITE, 1)
		if self:getTalentLevel(t) >= 3 then
			tg.selffire = false
			self:project(tg, x, y, DamageType.BLINDPHYSICAL, 3)
		end
		game.level.map:particleEmitter(x, y, tg.radius, "ball_light", {radius=tg.radius})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 0.5, 1.2), damtype=DamageType.FIRE})
		return true
	end,
	info = function(self, t)
		local rad = 1
		if self:getTalentLevel(t) >= 3 then rad = rad + 1 end
		if self:getTalentLevel(t) >= 5 then rad = rad + 1 end
		return ([[화살이나 탄환을 발사할 때 불을 붙여, 대상에게 %d%% 의 화염 피해를 주고 주변 %d 칸 반경에 빛을 비춥니다.
		기술 레벨이 3 이상이면, 3턴 동안 대상을 실명 상태로 만들 수 있습니다.]]):
		format(self:combatTalentWeaponDamage(t, 0.5, 1.2) * 100, rad)
	end,
}

newTalent{
	name = "Crippling Shot",
	kr_name = "무력화 사격",
	type = {"technique/archery-utility", 2},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	require = techs_dex_req2,
	range = archery_range,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = 1 },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_SLOW, 7, {power=util.bound((self:combatAttack() * 0.15 * self:getTalentLevel(t)) / 100, 0.1, 0.4), apply_power=self:combatAttack()})
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[대상을 무력화시키는 사격을 가하여 %d%% 의 무기 피해를 주고, 7 턴 동안 전체 속도를 %d%% 감소시킵니다.
		감속 효과와 확률은 정확도 능력치의 영향을 받아 증가합니다.]]):format(self:combatTalentWeaponDamage(t, 1, 1.5) * 100, util.bound((self:combatAttack() * 0.15 * self:getTalentLevel(t)) / 100, 0.1, 0.4) * 100)
	end,
}

newTalent{
	name = "Pinning Shot",
	kr_name = "속박 사격",
	type = {"technique/archery-utility", 3},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	require = techs_dex_req3,
	range = archery_range,
	tactical = { ATTACK = { weapon = 1 }, DISABLE = { pin = 2 } },
	requires_target = true,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 5.5)) end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, t.getDur(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s 속박되지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		end
	end,
	action = function(self, t)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=self:combatTalentWeaponDamage(t, 1, 1.4)})
		return true
	end,
	info = function(self, t)
		return ([[대상의 발을 그 자리에 묶는 사격을 가하여 %d%% 의 무기 피해를 주고, %d 턴 동안 속박 상태로 만듭니다.
		속박 확률은 민첩 능력치의 영향을 받아 증가합니다.]])
		:format(self:combatTalentWeaponDamage(t, 1, 1.4) * 100,
		t.getDur(self, t))
	end,
}

newTalent{
	name = "Scatter Shot",
	kr_name = "산탄 사격",
	type = {"technique/archery-utility", 4},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	stamina = 15,
	require = techs_dex_req4,
	range = archery_range,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 2.7)) end,
	tactical = { ATTACKAREA = { weapon = 2 }, DISABLE = { stun = 3 } },
	requires_target = true,
	target = function(self, t)
		local weapon, ammo = self:hasArcheryWeapon()
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), display=self:archeryDefaultProjectileVisual(weapon, ammo)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	getStunDur = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, t.getStunDur(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local targets = self:archeryAcquireTargets(tg, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, tg, {mult=self:combatTalentWeaponDamage(t, 0.5, 1.5)})
		return true
	end,
	info = function(self, t)
		return ([[특수한 화살이나 탄환을 발사하여 대상과 주변 %d 칸 반경에 %d%% 의 무기 피해를 주고, %d 턴 동안 기절시킵니다.
		기절 확률은 정확도의 영향을 받아 증가합니다.]])
		:format(self:getTalentRadius(t), self:combatTalentWeaponDamage(t, 0.5, 1.5) * 100, t.getStunDur(self,t))
	end,
}
