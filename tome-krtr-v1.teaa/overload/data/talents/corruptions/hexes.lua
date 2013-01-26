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
	name = "Pacification Hex",
	kr_display_name = "진정의 매혹술",
	type = {"corruption/hexes", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_PACIFICATION_HEX, 20, {power=self:combatSpellpower(), chance=self:combatTalentSpellDamage(t, 30, 50), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜 3 턴 동안 혼절시키고, 20 턴 동안 매 턴마다 %d%% 확률로 다시 혼절하게 만듭니다.
		이 효과는 대상의 주변 2 칸 반경에 있는 모든 적들에게 적용됩니다.
		혼절 확률은 주문력의 영향을 받아 증가합니다.]]):format(self:combatTalentSpellDamage(t, 30, 50))
	end,
}

newTalent{
	name = "Burning Hex",
	kr_display_name = "화염의 매혹술",
	type = {"corruption/hexes", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_BURNING_HEX, 20, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 4, 90)), power=1+(self:getTalentLevel(t) / 10), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜, 원천력 (체력, 마나, 원기 등) 을 사용할 때마다 %0.2f 화염 피해를 입히고 기술의 재사용 대기시간을 %d%% 턴 증가시킵니다.
		이 효과는 대상의 주변 2 칸 반경에 있는 모든 적들에게 적용됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]])
		:format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 4, 90)), ((self:getTalentLevel(t) / 10))*100 +1 ) --@@ 마지막 변수에서 글로 +1이 적힌 것을 변수 값으로 집어넣음
	end,
}

newTalent{
	name = "Empathic Hex",
	kr_display_name = "공감의 매혹술",
	type = {"corruption/hexes", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	radius = 2,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_EMPATHIC_HEX, 20, {power=self:combatTalentSpellDamage(t, 4, 20), apply_power=self:combatSpellpower()})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜, 20 턴 동안 대상이 누군가를 공격할 때마다 자신도 피해를 입게 만듭니다.
		피해량의 %d%% 만큼 자신도 피해를 입게 되며, 이 효과는 대상의 주변 2 칸 반경에 있는 모든 적들에게 적용됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(self:combatTalentSpellDamage(t, 4, 20))
	end,
}

newTalent{
	name = "Domination Hex",
	kr_display_name = "지배의 매혹술",
	type = {"corruption/hexes", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 20,
	vim = 30,
	range = 10,
	no_npc_use = true,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			if target:canBe("instakill") then
				target:setEffect(target.EFF_DOMINATION_HEX, 2 + self:getTalentLevel(t), {src=self, apply_power=self:combatSpellpower()})
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜, %d 턴 동안 노예로 부립니다.
		시전자가 대상에게 피해를 주면, 매혹의 효과는 사라집니다.]]):format(2 + self:getTalentLevel(t))
	end,
}
