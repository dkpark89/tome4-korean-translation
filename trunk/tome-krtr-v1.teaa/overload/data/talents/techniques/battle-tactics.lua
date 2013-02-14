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
	name = "Greater Weapon Focus",
	kr_display_name = "고도의 집중 공격",
	type = {"technique/battle-tactics", 1},
	require = techs_req_high1,
	points = 5,
	cooldown = 20,
	stamina = 25,
	no_energy = true,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		self:setEffect(self.EFF_GREATER_WEAPON_FOCUS, math.floor(4 + self:getTalentLevel(t) * 1.3), {chance=self:combatTalentStatDamage(t, "dex", 10, 90)})
		return true
	end,
	info = function(self, t)
		return ([[적을 공격하는 동작 하나하나에 집중하여, %d%% 확률로 한 번의 추가공격을 할 수 있게 됩니다.
		다른 기술이나 방패를 사용한 공격 등 모든 형태의 근접공격에 적용되며, 이 경우 추가공격 역시 일반 공격이 아닌 해당 기술을 사용합니다.
		이 상태는 %d 턴 동안 유지되며, 추가공격 확률은 민첩의 영향을 받아 증가합니다.]]):format(self:combatTalentStatDamage(t, "dex", 10, 90), math.floor(4 + self:getTalentLevel(t) * 1.3))
	end,
}

newTalent{
	name = "Step Up",
	kr_display_name = "진격",
	type = {"technique/battle-tactics", 2},
	require = techs_req_high2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[적을 죽일 때마다, %d%% 확률로 이동 속도가 1000%% 증가합니다.
		이동 속도가 굉장히 빨라지기 때문에, 상대적으로 게임의 전체적인 턴은 느리게 진행됩니다.
		이 효과는 게임의 전체적인 턴으로 1 턴이 지나거나, 이동을 제외한 다른 행동을 하면 사라집니다.]]):format(self:getTalentLevelRaw(t) * 20)
	end,
}

newTalent{
	name = "Bleeding Edge",
	kr_display_name = "출혈상",
	type = {"technique/battle-tactics", 3},
	require = techs_req_high3,
	points = 5,
	cooldown = 12,
	stamina = 24,
	requires_target = true,
	tactical = { ATTACK = { weapon = 1, cut = 1 }, DISABLE = 2 },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.7), true)
		if hit then
			if target:canBe("cut") then
				local sw = self:getInven("MAINHAND")
				if sw then
					sw = sw[1] and sw[1].combat
				end
				sw = sw or self.combat
				local dam = self:combatDamage(sw)
				local damrange = self:combatDamageRange(sw)
				dam = rng.range(dam, dam * damrange)
				dam = dam * self:combatTalentWeaponDamage(t, 2, 3.2)

				target:setEffect(target.EFF_DEEP_WOUND, 7, {src=self, heal_factor=self:getTalentLevel(t) * 10, power=dam / 7, apply_power=self:combatAttack()})
			end
		end
		return true
	end,
	info = function(self, t)
		return ([[대상을 후려쳐서 %d%% 의 무기 피해를 줍니다.
		공격이 성공하면, 대상은 출혈 상태가 되어 7 턴 동안 총 %d%% 의 무기 피해를 입으며 치유 증가율이 %d%% 만큼 줄어듭니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.7), 100 * self:combatTalentWeaponDamage(t, 2, 3.2), self:getTalentLevel(t) * 10)
	end,
}

newTalent{
	name = "True Grit",
	kr_display_name = "진정한 투지",
	type = {"technique/battle-tactics", 4},
	require = techs_req_high4,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 70,
	tactical = { BUFF = 2 },
	do_turn = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.resid then self:removeTemporaryValue("resists", p.resid) end
		if p.cresid then self:removeTemporaryValue("resists_cap", p.cresid) end
		local perc = (1 - (self.life / self.max_life)) * 10 * 5
		p.resid = self:addTemporaryValue("resists", {all=perc})
		p.cresid = self:addTemporaryValue("resists_cap", {all=perc/2})
	end,
	getStaminaDrain = function(self, t)
		return -16 + 2 * self:getTalentLevelRaw(t)
	end,
	activate = function(self, t)
		return {
			stamina = self:addTemporaryValue("stamina_regen", t.getStaminaDrain(self, t))
		}
	end,
	deactivate = function(self, t, p)
		if p.resid then self:removeTemporaryValue("resists", p.resid) end
		if p.cresid then self:removeTemporaryValue("resists_cap", p.cresid) end
		self:removeTemporaryValue("stamina_regen", p.stamina)
		return true
	end,
	info = function(self, t)
		local drain = t.getStaminaDrain(self, t)
		return ([[방어 자세를 취하여 적의 맹공에 저항합니다.
		현재 생명력이 최대 생명력의 10%% 만큼 감소할 때마다, 모든 저항력이 5%% 증가하고 저항력 최대치도 5%% 증가합니다.
		투지를 불태우는 동안에는 체력이 급격히 감소됩니다. (턴 당 체력 %d 감소)]]):
		format(drain)
	end,
}

