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

-- race & classes
require "engine.krtrUtils"
newTalentType{ type="tutorial", name = "tutorial", hide = true, description = "Tutorial-specific talents." }

newTalent{
	name = "Shove", short_name = "TUTORIAL_PHYS_KB",
	kr_display_name = "밀치기",
	type = {"tutorial", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		if self:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist()) then
			target:knockback(self.x, self.y, 1)
		else
			game.logSeen(target, "%s 밀려나지 않았습니다!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[어디서나 볼 수 있는, 케케묵은 밀쳐내기 기술입니다. 적을 한 칸 밀어냅니다.]])
	end,
}

newTalent{
	name = "Mana Gale", short_name = "TUTORIAL_SPELL_KB",
	kr_display_name = "마력 돌풍",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatSpellpower(), target:combatPhysicalResist()) then
			target:knockback(self.x, self.y, self:getTalentLevel(t))
			game.logSeen(target, "%s 돌풍에 밀려났습니다!", target.name:capitalize())
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatSpellpower())
		else
			game.logSeen(target, "%s 돌풍을 정면으로 맞고도, 꿈쩍도 하지 않았습니다!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		local dist = self:getTalentLevel(t)
		return ([[강력한 마법의 바람을 일으켜, 대상을 %d 칸 밀어냅니다.]]):format(dist)
	end,
}

newTalent{
	name = "Telekinetic Punt", short_name = "TUTORIAL_MIND_KB",
	kr_display_name = "염동력 주먹",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatMindpower(), target:combatPhysicalResist()) then
			target:knockback(self.x, self.y, 1)
			game.logSeen(target, "%s 주먹에 얻어맞아 밀려났습니다!", target.name:capitalize())
			target:crossTierEffect(target.EFF_OFFBALANCE, self:combatMindpower())
		else
			game.logSeen(target, "%s 주먹의 영향을 받지 않았습니다!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[대상을 염동력 주먹으로 날려버립니다.]])
	end,
}

newTalent{
	name = "Blink", short_name = "TUTORIAL_SPELL_BLINK",
	kr_display_name = "단거리 순간이동",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatSpellpower(), target:combatSpellResist()) then
			target:knockback(self.x, self.y, 1)
			game.logSeen(target, "%s 대상이 순간이동 되었습니다!", target.name:capitalize())
			target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
		else
			game.logSeen(target, "%s 순간이동을 저항했습니다!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[대상을 살짝 멀리 순간이동 시킵니다.]])
	end,
}

newTalent{
	name = "Fear", short_name = "TUTORIAL_MIND_FEAR",
	kr_display_name = "공포",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if self:checkHit(self:combatMindpower(), target:combatMentalResist()) then
			target:knockback(self.x, self.y, 1)
			game.logSeen(target, "%s 공포에 질려 도망갔습니다!", target.name:capitalize())
			target:crossTierEffect(target.EFF_BRAINLOCKED, self:combatMindpower())
		else
			game.logSeen(target, "%s 공포감이 들어 살짝 몸을 떨었습니다!", target.name:capitalize())
		end
		return true
	end,
	info = function(self, t)
		return ([[대상을 공포에 질려 도망치게 만듭니다.]])
	end,
}

newTalent{
	name = "Bleed", short_name = "TUTORIAL_SPELL_BLEED",
	kr_display_name = "출혈",
	type = {"tutorial", 1},
	points = 5,
	range = 5,
	random_ego = "attack",
	cooldown = 0,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if target then
			target:setEffect(self.EFF_CUT, 10, {power=1, apply_power=self:combatSpellpower()})
		end
		return true
	end,
	info = function(self, t)
		return ([[대상을 10 턴 동안 출혈 상태로 만듭니다.]])
	end,
}

newTalent{
	name = "Confusion", short_name = "TUTORIAL_MIND_CONFUSION",
	kr_display_name = "혼란",
	type = {"tutorial", 1},
	points = 5,
	range = 3,
	random_ego = "attack",
	cooldown = 6,
	requires_target = true,
	tactical = { ATTACK = 2},
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if target then
			target:setEffect(self.EFF_CONFUSED, 5, {power=100, apply_power=self:combatMindpower()})
		end
		return true
	end,
	info = function(self, t)
		return ([[정신력으로, 대상을 5 턴 동안 혼란 상태로 만듭니다.]])
	end,
}
