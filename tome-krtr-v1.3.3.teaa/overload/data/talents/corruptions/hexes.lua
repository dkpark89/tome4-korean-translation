-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
	kr_name = "진정의 매혹술",
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
	getchance = function(self,t)
		return self:combatLimit(self:combatTalentSpellDamage(t, 30, 50), 100, 0, 0, 36.8, 36.8) -- Limit <100%
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_PACIFICATION_HEX, 20, {power=self:combatSpellpower(), chance=t.getchance(self,t), apply_power=self:combatSpellpower()})
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜 3 턴 동안 혼절시키고, 20 턴 동안 매 턴마다 %d%% 확률로 다시 혼절하게 만듭니다.
		이 효과는 대상의 주변 2 칸 반경에 있는 모든 적들에게 적용됩니다.
		혼절 확률은 주문력의 영향을 받아 증가합니다.]]):format(t.getchance(self,t))
	end,
}

newTalent{
	name = "Burning Hex",
	kr_name = "화염의 매혹술",
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
	getCDincrease = function(self, t) return self:combatTalentScale(t, 0.15, 0.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_BURNING_HEX, 20, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 4, 90)), power=1 + t.getCDincrease(self, t), apply_power=self:combatSpellpower()})
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, g=100, b=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜, 원천력 (체력, 마나, 원기 등) 을 사용할 때마다 %0.2f 화염 피해를 입히며, 기술의 재사용 대기시간을 %d%% + 1 턴 증가시킵니다.
		이 효과는 목표의 주변 2 칸 반경에 있는 모든 적들에게 20 턴 동안 적용됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 4, 90)), t.getCDincrease(self, t)*100)
	end,
}

newTalent{
	name = "Empathic Hex",
	kr_name = "공감의 매혹술",
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
	recoil = function(self,t) return self:combatLimit(self:combatTalentSpellDamage(t, 4, 20), 100, 0, 0, 12.1, 12.1) end, -- Limit to <100%
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			target:setEffect(target.EFF_EMPATHIC_HEX, 20, {power=t.recoil(self,t), apply_power=self:combatSpellpower()})
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, r=100, b=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜, 20 턴 동안 대상이 누군가를 공격할 때마다 대상도 피해를 입게 만듭니다.
		피해량의 %d%% 만큼 대상도 피해를 입게 되며, 이 효과는 목표의 주변 2 칸 반경에 있는 모든 적들에게 적용됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(t.recoil(self,t))
	end,
}

newTalent{
	name = "Domination Hex",
	kr_name = "지배의 매혹술",
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
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			if target:canBe("instakill") then
				target:setEffect(target.EFF_DOMINATION_HEX, t.getDuration(self, t), {src=self, apply_power=self:combatSpellpower(), faction = self.faction})
			end
		end)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, "circle", {oversize=0.7, g=100, r=100, a=90, limit_life=8, appear=8, speed=2, img="blight_circle", radius=self:getTalentRadius(t)})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 매혹시켜, %d 턴 동안 노예로 부립니다.
		시전자가 대상에게 피해를 주면, 매혹의 효과는 사라집니다.]]):format(t.getDuration(self, t))
	end,
}
