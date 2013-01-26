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

require "engine.krtrUtils"

newTalent{
	name = "Death Dance",
	kr_display_name = "죽음의 춤",
	type = {"technique/2hweapon-offense", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 30,
	tactical = { ATTACKAREA = { weapon = 3 } },
	range = 0,
	radius = 1,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 죽음의 춤을 출 수 없습니다!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1.4, 2.1))
			end
		end)

		return true
	end,
	info = function(self, t)
		return ([[한바퀴 돌면서, 근접한 주변의 적들에게 %d%% 의 무기 피해를 입힙니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1.4, 2.1))
	end,
}

newTalent{
	name = "Berserker",
	kr_display_name = "광전사",
	type = {"technique/2hweapon-offense", 2},
	require = techs_req2,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	activate = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 광전사 상태가 될 수 없습니다!")
			return nil
		end

		return {
			stun = self:addTemporaryValue("stun_immune", 0.1 * self:getTalentLevel(t)),
			pin = self:addTemporaryValue("pin_immune", 0.1 * self:getTalentLevel(t)),
			dam = self:addTemporaryValue("combat_dam", 5 + self:getStr(7, true) * self:getTalentLevel(t)),
			atk = self:addTemporaryValue("combat_atk", 5 + self:getDex(7, true) * self:getTalentLevel(t)),
			def = self:addTemporaryValue("combat_def", -10),
			armor = self:addTemporaryValue("combat_armor", -10),
		}
	end,

	deactivate = function(self, t, p)
		self:removeTemporaryValue("stun_immune", p.stun)
		self:removeTemporaryValue("pin_immune", p.pin)
		self:removeTemporaryValue("combat_def", p.def)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("combat_atk", p.atk)
		self:removeTemporaryValue("combat_dam", p.dam)
		return true
	end,
	info = function(self, t)
		return ([[공격적인 전투 자세를 취합니다. 회피도와 방어력이 10 씩 감소하는 대신, 정확도가 %d, 물리력이 %d 증가합니다.
		광전사 상태인 사람을 멈춰세우기란 거의 불가능하기 때문에, %d%% 의 기절과 속박 저항을 얻습니다.
		정확도는 민첩, 물리력은 힘 능력치의 영향을 받아 증가합니다.]]):
		format(
			5 + self:getDex(7, true) * self:getTalentLevel(t),
			5 + self:getStr(7, true) * self:getTalentLevel(t),
			10 * self:getTalentLevel(t)
		)
	end,
}

newTalent{
	name = "Warshout",
	kr_display_name = "전투의 외침",
	type = {"technique/2hweapon-offense",3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	message = function(self) if self.subtype == "rodent" then return "@Source1@ 전투의 외침을 내지릅니다. 찍찍!" else return "@Source1@ 전투의 외침을 내지릅니다." end end ,
	stamina = 30,
	cooldown = 18,
	tactical = { ATTACKAREA = { confusion = 1 }, DISABLE = { confusion = 3 } },
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevelRaw(t)
	end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 전투의 외침을 내지를 수 없습니다!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CONFUSION, {
			dur=3+self:getTalentLevelRaw(t),
			dam=50+self:getTalentLevelRaw(t)*10,
			power_check=function() return self:combatPhysicalpower() end,
			resist_check=self.combatPhysicalResist,
		}, {type="flame"})
		return true
	end,
	info = function(self, t)
		return ([[전방 %d 칸 반경에 전투의 외침을 내지릅니다. 범위 내의 대상들은 %d 턴 동안 혼란 상태에 빠집니다.]]):
		format(self:getTalentRadius(t), 3 + self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Death Blow",
	kr_display_name = "죽음의 일격",
	type = {"technique/2hweapon-offense", 4},
	require = techs_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 죽음의 일격을 쓸 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local inc = self.stamina / 2
		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam + inc
		end
		self.combat_physcrit = self.combat_physcrit + 100

		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3))

		if self:getTalentLevel(t) >= 4 then
			self.combat_dam = self.combat_dam - inc
			self:incStamina(-self.stamina / 2)
		end
		self.combat_physcrit = self.combat_physcrit - 100

		-- Try to insta-kill
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("instakill") and target.life > 0 and target.life < target.max_life * 0.2 then
				-- KILL IT !
				game.logSeen(target, "%s에게 죽음의 고통을 안겨줬습니다!", (target.kr_display_name or target.name):capitalize())
				target:die(self)
			elseif target.life > 0 and target.life < target.max_life * 0.2 then
				game.logSeen(target, "%s 죽음의 고통을 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[적중시 무조건 치명타 효과가 발생하며, %d%% 의 무기 피해를 주는 즉사 공격을 시도합니다. 
		공격을 받은 대상이 빈사상태 (생명력 20%% 미만) 이며 대상이 저항하지 못했을 경우, 대상은 즉사합니다.
		기술 레벨이 4 이상이면, 남은 체력의 절반을 쏟아부어 그만큼 더 강력한 공격을 할 수 있습니다.
		즉사 확률은 물리력의 영향을 받아 증가합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.3))
	end,
}

-----------------------------------------------------------------------------
-- Cripple
-----------------------------------------------------------------------------
newTalent{
	name = "Stunning Blow",
	kr_display_name = "기절시키기",
	type = {"technique/2hweapon-cripple", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 8,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 기절시키기를 쓸 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상의 머리를 무기로 내리쳐서 %d%% 의 무기 피해를 주고, 공격에 성공하면 %d 턴 동안 기절시킵니다.
		기절 확률은 물리력의 영향을 받아 증가합니다.]])
		:format(100 * self:combatTalentWeaponDamage(t, 1, 1.5),
		2 + math.floor(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Sunder Armour",
	kr_display_name = "방어구 부수기",
	type = {"technique/2hweapon-cripple", 2},
	require = techs_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 12,
	requires_target = true,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 방어구 부수기를 쓸 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to stun !
		if hit then
			target:setEffect(target.EFF_SUNDER_ARMOUR, 4 + self:getTalentLevel(t), {power=5*self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
		end

		return true
	end,
	info = function(self, t)
		return ([[대상의 방어구를 무기로 내리쳐서 %d%% 의 무기 피해를 주고, 공격에 성공하면 대상의 방어도를 %d 만큼, %d 턴 동안 감소시킵니다.
		방어도 감소 확률은 물리력의 영향을 받아 증가합니다.]])
		:format(
			100 * self:combatTalentWeaponDamage(t, 1, 1.5),
			5 * self:getTalentLevel(t),
			4 + self:getTalentLevel(t)
		)
	end,
}

newTalent{
	name = "Sunder Arms",
	kr_display_name = "팔 부러뜨리기",
	type = {"technique/2hweapon-cripple", 3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 12,
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 팔 부러뜨리기를 쓸 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.5))

		-- Try to stun !
		if hit then
			target:setEffect(target.EFF_SUNDER_ARMS, 4 + self:getTalentLevel(t), {power=3*self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
		end

		return true
	end,
	info = function(self, t)
		return ([[대상의 팔을 무기로 내리쳐서 %d%% 의 무기 피해를 주고, 공격에 성공하면 대상의 정확도를 %d 만큼, %d 턴 동안 감소시킵니다.
		정확도 감소 확률은 물리력의 영향을 받아 증가합니다.]])
		:format(
			100 * self:combatTalentWeaponDamage(t, 1, 1.5),
			3 * self:getTalentLevel(t),
			4 + self:getTalentLevel(t)
		)
	end,
}

newTalent{
	name = "Blood Frenzy",
	kr_display_name = "피의 광란",
	type = {"technique/2hweapon-cripple", 4},
	require = techs_req4,
	points = 5,
	mode = "sustained",
	cooldown = 15,
	sustain_stamina = 70,
	no_energy = true,
	tactical = { BUFF = 1 },
	do_turn = function(self, t)
		if self.blood_frenzy > 0 then
			self.blood_frenzy = self.blood_frenzy - 2
		end
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 양손 무기가 필요합니다.") end return false end return true end,
	activate = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 피의 광란을 쓸 수 없습니다!")
			return nil
		end
		self.blood_frenzy = 0
		return {
			regen = self:addTemporaryValue("stamina_regen", -2),
		}
	end,
	deactivate = function(self, t, p)
		self.blood_frenzy = nil
		self:removeTemporaryValue("stamina_regen", p.regen)
		return true
	end,
	info = function(self, t)
		return ([[매 턴마다 체력이 2씩 감소하는 피의 광란 상태에 빠지며, 이 상태에서 적을 죽일 때마다 물리력이 %d 씩 상승합니다.
		물리력 상승 효과는 중첩되며 한계도 없지만, 추가로 얻은 물리력은 턴이 지날 때마다 2씩 감소합니다.]]):format(2 * self:getTalentLevel(t))
	end,
}

