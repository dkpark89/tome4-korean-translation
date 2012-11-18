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

-- Default archery attack
newTalent{
	name = "Shoot",
	display_name = "사격",
	type = {"technique/archery-base", 1},
	no_energy = "fake",
	hide = true,
	innate = true,
	points = 1,
	range = archery_range,
	message = "@Source@ shoots!",
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
		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {use_psi_archery = t.use_psi_archery(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[활이나 투석구를 발사합니다!]])
	end,
}
newTalent{
	name = "Reload",
	display_name = "재장전",
	type = {"technique/archery-base", 1},
	cooldown = 0,
	points = 1,
	tactical = { AMMO = 2 },
	on_pre_use = function(self, t, silent) if not self:hasAmmo() then if not silent then game.logPlayer(self, "화살통이나 탄환 주머니를 착용해야 합니다.") end return false end return true end,
	shots_per_turn = function(self, t)
		local v = math.max(self:getTalentLevelRaw(self.T_BOW_MASTERY), self:getTalentLevelRaw(self.T_SLING_MASTERY))
		local add = 0
		if v >= 5 then add = add + 3
		elseif v >= 4 then add = add + 2
		elseif v >= 2 then add = add + 1
		end
		return self:getTalentLevelRaw(t) + (self:attr("ammo_reload_speed") or 0) + add
	end,
	action = function(self, t)
		local q, err = self:hasAmmo()
		if not q then
			game.logPlayer(self, "%s", err)
			return
		end
		if q.combat.shots_left >= q.combat.capacity then
			game.logPlayer(self, "발사체 재장전을 끝냈습니다(%s).", q.name)
			return
		end
		self:setEffect(self.EFF_RELOADING, q.combat.capacity, {ammo = q, shots_per_turn = t.shots_per_turn(self, t)})
		return true
	end,
	info = function(self, t)
		local spt = t.shots_per_turn(self, t)
		return ([[화살통이나 탄환 주머니에 매 턴마다 %d 발씩 발사체를 장전합니다.]]):format(spt)
	end,
}

newTalent{
	name = "Steady Shot",
	display_name = "정밀 사격",
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
		return ([[안정된 자세로 정확하게 사격을 하여 %d%% 의 무기 피해를 줍니다.]]):format(self:combatTalentWeaponDamage(t, 1.1, 2.2) * 100)
	end,
}

newTalent{
	name = "Aim",
	display_name = "조준",
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
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "활이나 투석구 없이는 조준 기술을 쓸 수 없습니다!")
			return nil
		end

		if self:isTalentActive(self.T_RAPID_SHOT) then self:forceUseTalent(self.T_RAPID_SHOT, {ignore_energy=true}) end

		return {
			move = self:addTemporaryValue("never_move", 1),
			speed = self:addTemporaryValue("combat_physspeed", -self:getTalentLevelRaw(t) * 0.05),
			crit = self:addTemporaryValue("combat_physcrit", 7 + self:getTalentLevel(t) * self:getDex(10, true)),
			atk = self:addTemporaryValue("combat_dam", 4 + self:getTalentLevel(t) * self:getDex(10, true)),
			dam = self:addTemporaryValue("combat_atk", 4 + self:getTalentLevel(t) * self:getDex(10, true)),
			apr = self:addTemporaryValue("combat_apr", 3 + self:getTalentLevel(t) * self:getDex(10, true)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("never_move", p.move)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_apr", p.apr)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[냉정하고 집중된 자세를 취하여, 물리력(+%d), 정확도(+%d), 방어 관통(+%d), 치명타율(+%d%%)을 증가시키지만, 사격 속도가 %d%% 감소되고 그 자리에서 움직일 수 없게 됩니다.
		증가되는 효과들은 민첩 능력치에 영향을 받습니다.]]):
		format(4 + self:getTalentLevel(t) * self:getDex(10, true), 4 + self:getTalentLevel(t) * self:getDex(10, true),
		3 + self:getTalentLevel(t) * self:getDex(10, true), 7 + self:getTalentLevel(t) * self:getDex(10, true),
		self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Rapid Shot",
	display_name = "속사",
	type = {"technique/archery-training", 3},
	mode = "sustained",
	points = 5,
	require = techs_dex_req3,
	cooldown = 8,
	sustain_stamina = 20,
	no_energy = true,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	activate = function(self, t)
		local weapon = self:hasArcheryWeapon()
		if not weapon then
			game.logPlayer(self, "활이나 투석구 없이는 속사 기술을 사용할 수 없습니다!")
			return nil
		end

		if self:isTalentActive(self.T_AIM) then self:forceUseTalent(self.T_AIM, {ignore_energy=true}) end

		return {
			speed = self:addTemporaryValue("combat_physspeed", self:getTalentLevel(t) * 0.1),
			atk = self:addTemporaryValue("combat_dam", -8 - self:getTalentLevelRaw(t) * 2.4),
			dam = self:addTemporaryValue("combat_atk", -8 - self:getTalentLevelRaw(t) * 2.4),
			crit = self:addTemporaryValue("combat_physcrit", -8 - self:getTalentLevelRaw(t) * 2.4),
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
		return ([[유연하고 재빠른 전투 자세로 전환하여, 발사 속도를 %d%% 증가시키는 대신 정확도(%d), 물리력(%d), 치명타율(%d)이 감소됩니다.]]):
		format(self:getTalentLevel(t) * 10, -8 - self:getTalentLevelRaw(t) * 2.4, -8 - self:getTalentLevelRaw(t) * 2.4, -8 - self:getTalentLevelRaw(t) * 2.4)
	end,
}

newTalent{
	name = "Relaxed Shot",
	display_name = "숨 돌리기",
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
		return ([[힘을 넣지 않은 사격을 가하여 %d%% 의 무기 피해를 줍니다.
		그 사이에 한숨 돌릴 수 있게 되어 체력을 %d 얻습니다.]]):format(self:combatTalentWeaponDamage(t, 0.5, 1.1) * 100, 12 + self:getTalentLevel(t) * 8)
	end,
}

-------------------------------- Utility -----------------------------------

newTalent{
	name = "Flare",
	display_name = "조명 사격",
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
		return ([[발사체에 불을 붙여 쏴서 %d%% 의 화염 피해를 주고, %d 타일 반경에 빛을 밝힙니다.
		기술 레벨이 3 이상이면 3 턴 동안 실명 상태로 만들 확률도 생깁니다.]]):
		format(self:combatTalentWeaponDamage(t, 0.5, 1.2) * 100, rad)
	end,
}

newTalent{
	name = "Crippling Shot",
	display_name = "장애유발 사격",
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
		return ([[대상의 신체를 손상시키는 사격을 가하여 %d%% 의 무기 피해를 주고, 속도를 %d%% 감소시키는 효과를 7 턴 동안 지속되게 합니다.]]):format(self:combatTalentWeaponDamage(t, 1, 1.5) * 100, util.bound((self:combatAttack() * 0.15 * self:getTalentLevel(t)) / 100, 0.1, 0.4) * 100)
	end,
}

newTalent{
	name = "Pinning Shot",
	display_name = "속박 사격",
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
	getDur = function(self, t) return ({2, 3, 4, 4, 5})[util.bound(self:getTalentLevelRaw(t), 1, 5)] end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, t.getDur(self, t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s 에게 속박 사격을 사용했지만, 저항했습니다!", target.name:capitalize())
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
		속박 확률은 민첩 능력치에 영향을 받아 증가됩니다.]])
		:format(self:combatTalentWeaponDamage(t, 1, 1.4) * 100,
		t.getDur(self, t))
	end,
}

newTalent{
	name = "Scatter Shot",
	display_name = "산탄 사격",
	type = {"technique/archery-utility", 4},
	no_energy = "fake",
	points = 5,
	random_ego = "attack",
	cooldown = 14,
	stamina = 15,
	require = techs_dex_req4,
	range = archery_range,
	radius = function(self, t)
		return 1 + math.floor(self:getTalentLevel(t) / 3)
	end,
	tactical = { ATTACKAREA = { weapon = 2 }, DISABLE = { stun = 3 } },
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasArcheryWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 활이나 투석구가 필요합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		if target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevelRaw(t), {apply_power=self:combatAttack()})
		else
			game.logSeen(target, "%s 에게 산탄 사격을 사용했지만, 저항했습니다!", target.name:capitalize())
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
		return ([[착탄 지점에서 발사체가 산산조각나 파편이 %d 반경의 원형으로 방사되는 사격을 가하여 %d%% 의 무기 피해를 주고 %d 턴 동안 기절시킵니다.
		기절 확률은 민첩 능력치에 영향을 받아 증가됩니다.]])
		:format(self:getTalentRadius(t), self:combatTalentWeaponDamage(t, 0.5, 1.5) * 100, 2 + self:getTalentLevelRaw(t))
	end,
}
