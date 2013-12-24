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

require "engine.krtrUtils"

----------------------------------------------------------------------
-- Offense
----------------------------------------------------------------------

newTalent{
	name = "Shield Pummel",
	kr_name = "방패 치기",
	type = {"technique/shield-offense", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 8,
	requires_target = true,
	tactical = { ATTACK = 1, DISABLE = { stun = 3 } },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 방패가 필요합니다.") end return false end return true end,
	getStunDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패 없이는 방패 치기를 할 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1, 1.7, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1.2, 2.1, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getStunDuration(self, t), {apply_power=self:combatAttackStr()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 방패로 두 번 내리쳐, 각각 %d%% / %d%% 의 방패 피해를 줍니다. 두 번째 타격이 명중하면, 대상은 %d 턴 동안 기절합니다.
		기절 확률은 정확도와 힘 능력치의 영향을 받아 증가합니다.]])
		:format(100 * self:combatTalentWeaponDamage(t, 1, 1.7, self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
		100 * self:combatTalentWeaponDamage(t, 1.2, 2.1, self:getTalentLevel(self.T_SHIELD_EXPERTISE)),
		t.getStunDuration(self, t))
	end,
}

newTalent{
	name = "Riposte",
	kr_name = "응수",
	type = {"technique/shield-offense", 2},
	require = techs_req2,
	mode = "passive",
	points = 5,
	getDurInc = function(self, t)  -- called in effect "BLOCKING" in mod.data\timed_effects\physical.lua
		return math.ceil(self:combatTalentScale(t, 0.15, 1.15))
	end,
	getCritInc = function(self, t)
		return self:combatTalentIntervalDamage(t, "dex", 10, 50)
	end,
	info = function(self, t)
		local inc = t.getDurInc(self, t)
		return ([[방패로 공격을 막은 뒤, 반격하는 능력을 다음과 같이 향상시킵니다 :
		공격을 제대로 막지 못했어도 반격합니다.
		반격 시 상대가 받는 상태효과 시간이 %d 턴 증가합니다.
		대상이 무방비 상태일 때 반격할 수 있는 횟수가 %d 회 늘어납니다.
		반격의 치명타율이 %d%% 증가합니다. 치명타율 증가 효과는 민첩성 능력치의 영향을 받아 증가합니다.]]):format(inc, inc, t.getCritInc(self, t))
	end,
}


newTalent{
	name = "Overpower",
	kr_name = "압도",
	type = {"technique/shield-offense", 3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 22,
	requires_target = true,
	tactical = { ATTACK = 2, ESCAPE = { knockback = 1 }, DISABLE = { knockback = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 무기와 방패가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패 없이는 적을 압도할 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3), true)
		-- Second attack with shield
		self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
		-- Third attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 4)
			else
				game.logSeen(target, "%s 밀려나지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 무기로 공격하여 %d%% 의 무기 피해를 주고, 방패로 두 번 밀어쳐 %d%% 의 방패 피해를 줍니다.
		마지막 공격이 적중하면, 대상은 압도되어 밀려납니다. 밀어내기 확률은 정확도 능력치의 영향을 받아 증가합니다.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.3), 100 * self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
	end,
}

newTalent{
	name = "Assault",
	kr_name = "급습",
	type = {"technique/shield-offense", 4},
	require = techs_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 16,
	requires_target = true,
	tactical = { ATTACK = 4 },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 무기와 방패가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패 없이는 적을 급습할 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Second & third attack with weapon
		if hit then
			self.combat_physcrit = self.combat_physcrit + 1000
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.5), true)
			self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.5), true)
			self.combat_physcrit = self.combat_physcrit - 1000
		end

		return true
	end,
	info = function(self, t)
		return ([[적을 방패로 급습하여 %d%% 의 방패 피해를 줍니다. 이 공격이 성공하면, 각각 %d%% 의 무기 피해를 주며 항상 치명타 효과가 발생하는 두 번의 무기 공격을 연속으로 가합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.5, self:getTalentLevel(self.T_SHIELD_EXPERTISE)), 100 * self:combatTalentWeaponDamage(t, 1, 1.5))
	end,
}


----------------------------------------------------------------------
-- Defense
----------------------------------------------------------------------
newTalent{
	name = "Shield Wall",
	kr_name = "방패의 벽",
	type = {"technique/shield-defense", 1},
	require = techs_req1,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 30,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 무기와 방패가 필요합니다.") end return false end return true end,
	getarmor = function(self,t) return self:combatScale((1+self:getDex(4))*self:getTalentLevel(t), 5, 0, 30, 25, 0.375) + self:combatTalentScale(self:getTalentLevel(self.T_SHIELD_EXPERTISE), 1, 5, 0.75) end, -- Scale separately with talent level and talent level of Shield Expertise
	getDefense = function(self, t)
		return self:combatScale((1 + self:getDex(4, true)) * self:getTalentLevel(t), 6.4, 1.4, 30, 25) + self:combatTalentScale(self:getTalentLevel(self.T_SHIELD_EXPERTISE), 2, 10, 0.75)
	end,
	stunKBresist = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.50) end, -- Limit <100%
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패 없이는 방패의 벽을 세울 수 없습니다!")
			return nil
		end
		return {
			stun = self:addTemporaryValue("stun_immune", t.stunKBresist(self, t)),
			knock = self:addTemporaryValue("knockback_immune", t.stunKBresist(self, t)),
			dam = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL]=-20}),
			def = self:addTemporaryValue("combat_def", t.getDefense(self, t)),
			armor = self:addTemporaryValue("combat_armor", t.getarmor(self,t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("knockback_immune", p.knock)
		return true
	end,
	info = function(self, t)
		return ([[수비적인 전투 자세에 들어가 물리 공격력이 20%% 떨어지는 대신, 회피도가 %d / 방어도가 %d / 기절과 밀어내기 면역력이 %d%% 증가합니다.
		회피도와 방어도 증가량은 민첩 능력치의 영향을 받아 증가합니다.]]):
		format(t.getDefense(self, t), t.getarmor(self, t), 100*t.stunKBresist(self, t))
	end,
}

newTalent{
	name = "Repulsion",
	kr_name = "반발",
	type = {"technique/shield-defense", 2},
	require = techs_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { ESCAPE = { knockback = 2 }, DEFEND = { knockback = 0.5 } },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 무기와 방패가 필요합니다.") end return false end return true end,
	range = 0,
	radius = 1,
	getDist = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getDuration = function(self, t) return math.floor(self:combatStatScale("str", 3.8, 11)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패 없이는 반발을 사용할 수 없습니다!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95) and target:canBe("knockback") then --Deprecated checkHit call
					target:knockback(self.x, self.y, t.getDist(self, t))
					if target:canBe("stun") then target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {}) end
				else
					game.logSeen(target, "%s 밀려나지 않습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				end
			end
		end)

		self:addParticles(Particles.new("meleestorm2", 1, {radius=2}))

		return true
	end,
	info = function(self, t)
		return ([[적들이 방패를 공격하도록 허용한 뒤, 힘을 모아 후려갈겨 적들을 %d 칸 밀어냅니다.
		추가적으로, 밀려난 적들은 %d 턴 동안 혼절하게 됩니다.
		밀어내는 거리는 기술 레벨, 혼절 시간은 힘 능력치의 영향을 받아 증가합니다.]]):format(t.getDist(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Shield Expertise",
	kr_name = "방패 전문가",
	type = {"technique/shield-defense", 3},
	require = techs_req3,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 4
		self.combat_spellresist = self.combat_spellresist + 2
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist - 4
		self.combat_spellresist = self.combat_spellresist - 2
	end,
	info = function(self, t)
		return ([[방패를 사용하는 다른 기술들을 더 능숙하게 사용할 수 있게 되며, 주문 내성이 %d / 물리 내성이 %d 상승합니다.]]):format(2 * self:getTalentLevelRaw(t), 4 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Last Stand",
	kr_name = "최후의 저항",
	type = {"technique/shield-defense", 4},
	require = techs_req4,
	mode = "sustained",
	points = 5,
	cooldown = 30,
	sustain_stamina = 50,
	tactical = { DEFEND = 3 },
	no_npc_use = true,
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 무기와 방패가 필요합니다.") end return false end return true end,
	lifebonus = function(self,t, base_life) -- Scale bonus with max life
		return self:combatTalentStatDamage(t, "con", 30, 500) + (base_life or self.max_life) * self:combatTalentLimit(t, 1, 0.02, 0.10) -- Limit <100% of base life
	end,
	getDefense = function(self, t) return self:combatScale(self:getDex(4, true) * self:getTalentLevel(t), 5, 0, 25, 20) end,
	activate = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패 없이는 최후의 저항을 할 수 없습니다!")
			return nil
		end
		local hp = t.lifebonus(self,t)
		local ret = {
			base_life = self.max_life,
			max_life = self:addTemporaryValue("max_life", hp),
			def = self:addTemporaryValue("combat_def", t.getDefense(self, t)),
			nomove = self:addTemporaryValue("never_move", 1),
			dieat = self:addTemporaryValue("die_at", -hp),
			extra_life = self:addTemporaryValue("life", hp), -- Avoid healing effects
		}
--		if not self:attr("talent_reuse") then
--			self:heal(hp)
--		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("max_life", p.max_life)
		self:removeTemporaryValue("never_move", p.nomove)
		self:removeTemporaryValue("die_at", p.dieat)
		self:removeTemporaryValue("life", p.extra_life)
		return true
	end,
	info = function(self, t)
		local hp = self:isTalentActive(self.T_LAST_STAND)
		if hp then
			hp = t.lifebonus(self, t, hp.base_life)
		else
			hp = t.lifebonus(self,t)
		end
		return ([[단단히 버틸 준비를 합니다. 회피도가 %d / 최대 생명력과 현재 생명력이 %d 증가하는 대신, 움직이지 못하게 됩니다.
		버티기 상태로 당신에게 가해지는 모든 공격에 집중하여, 치명적인 피해를 받지 않으면 죽지 않게 됩니다. 생명력이 -%d 이하가 되어야 죽게 되지만, 생명력이 0 이하인 경우 현재 생명력을 알 수 없게 됩니다.
		회피도 증가는 민첩 능력치, 생명력 증가는 체격 능력치와 기본 최대 생명력의 영향을 받아 증가합니다.]]):
		format(t.getDefense(self, t), hp, hp)
	end,
}

