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
	name = "Curse of Defenselessness",
	kr_name = "무저항의 저주",
	type = {"corruption/curses", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_DEFENSELESSNESS, 10, {power=self:combatTalentSpellDamage(t, 30, 60), apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx", radius=0})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 저주하여, 회피도와 모든 내성을 10 턴 동안 %d 감소시킵니다.
		이 효과는 주문력의 영향을 받아 증가합니다.]]):format(self:combatTalentSpellDamage(t, 30, 60))
	end,
}

newTalent{
	name = "Curse of Impotence",
	kr_name = "무기력의 저주",
	type = {"corruption/curses", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	imppower = function(self,t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 30),100, 0, 0, 19.36, 19.36) end, -- Limit to <100%
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_IMPOTENCE, 10, {power=t.imppower(self,t), apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx_02", radius=0})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 저주하여, 대상이 주는 모든 피해량을 10 턴 동안 %d%% 감소시킵니다.
		이 효과는 주문력의 영향을 받아 증가합니다.]]):format(t.imppower(self,t))
	end,
}

newTalent{
	name = "Curse of Death",
	kr_name = "죽음의 저주",
	type = {"corruption/curses", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { ATTACK = {DARKNESS = 2}, DISABLE = 1 },
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_DEATH, 10, {src=self, dam=self:combatTalentSpellDamage(t, 10, 70), apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx_03", radius=0})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 저주하여, 10 턴 동안 자연적인 생명력 회복을 정지시키고 매 턴마다 %0.2f 어둠 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.DARKNESS, self:combatTalentSpellDamage(t, 10, 70)))
	end,
}

newTalent{
	name = "Curse of Vulnerability",
	kr_name = "약화의 저주",
	type = {"corruption/curses", 4},
	require = corrs_req4,
	points = 5,
	cooldown = 20,
	vim = 20,
	range = 10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CURSE_VULNERABILITY, 7, {power=self:combatTalentSpellDamage(t, 10, 40), apply_power=self:combatSpellpower()})
			game.level.map:particleEmitter(tx, ty, 1, "circle", {base_rot=0, oversize=0.7, a=130, limit_life=8, appear=8, speed=0, img="curse_gfx_04", radius=0})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상을 저주하여, 대상의 전체 저항력을 7 턴 동안 %d%% 감소시킵니다.
		이 효과는 주문력의 영향을 받아 증가합니다.]]):format(self:combatTalentSpellDamage(t, 10, 40))
	end,
}
