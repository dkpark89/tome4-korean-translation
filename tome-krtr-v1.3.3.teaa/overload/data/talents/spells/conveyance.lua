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
	name = "Phase Door",
	kr_name = "근거리 순간이동",
	type = {"spell/conveyance",1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = function(self, t) return game.zone and game.zone.force_controlled_teleport and 1 or 10 end,
	cooldown = function(self, t) return game.zone and game.zone.force_controlled_teleport and 3 or 8 end,
	tactical = { ESCAPE = 2 },
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getRange = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 15), 40, 4, 0, 13.4, 9.4) end, -- Limit to range 40
	getRadius = function(self, t) return math.floor(self:combatTalentLimit(t, 0, 6, 2)) end, -- Limit to radius 0	
	is_teleport = true,
	action = function(self, t)
		local target = self
		if self:getTalentLevel(t) >= 4 then
			game.logPlayer(self, "순간이동시킬 대상을 선택하세요.")
			local tg = {default_target=self, type="hit", nowarning=true, range=10, first_target="friend"}
			local tx, ty = self:getTarget(tg)
			if tx then
				local _ _, tx, ty = self:canProject(tg, tx, ty)
				if tx then
					target = game.level.map(tx, ty, Map.ACTOR) or self
				end
			end
		end
		if target ~= self and target:canBe("teleport") then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "마법이 헛나갔습니다!")
				return true
			end
		end

		-- Annoy them!
		if target ~= self and target:reactionToward(self) < 0 then target:setTarget(self) end

		local x, y = self.x, self.y
		local rad = t.getRange(self, t)
		local radius = t.getRadius(self, t)
		if self:getTalentLevel(t) >= 5 or game.zone.force_controlled_teleport then
			game.logPlayer(self, "순간이동할 지역을 선택하세요.")
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=rad, radius=radius, requires_knowledge=false}
			x, y = self:getTarget(tg)
			if not x then return nil end
			-- Target code does not restrict the target coordinates to the range, it lets the project function do it
			-- but we cant ...
			local _ _, x, y = self:canProject(tg, x, y)
			rad = radius

			-- Check LOS
			if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
				game.logPlayer(self, "순간이동 제어에 실패했습니다! 무작위한 곳에 순간이동됩니다!")
				x, y = self.x, self.y
				rad = t.getRange(self, t)
			end
		end

		game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		target:teleportRandom(x, y, rad)
		game.level.map:particleEmitter(target.x, target.y, 1, "teleport")

		if target ~= self then
			target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local range = t.getRange(self, t)
		return ([[주변 %d 칸 반경 내 무작위한 곳으로 단거리 순간이동합니다.
		기술 레벨이 4 이상이면, 대상을 지정하여 순간이동시킬 수 있습니다.
		기술 레벨이 5 이상이면, 순간이동할 지역을 선택할 수 있습니다. (오차 범위 : 주변 %d 칸 반경) 단, 선택한 지역이 시야 밖의 지역일 경우 마법이 실패할 수도 있습니다.
		순간이동 범위는 주문력의 영향을 받아 증가합니다.]]):format(range, radius)
	end,
}

newTalent{
	name = "Teleport",
	kr_name = "원거리 순간이동",
	type = {"spell/conveyance",2},
	require = spells_req2,
	points = 5,
	random_ego = "utility",
	mana = 20,
	cooldown = 30,
	tactical = { ESCAPE = 3 },
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getRange = function(self, t) return 100 + self:combatSpellpower(1) end,
	getRadius = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 19, 15)) end, -- Limit > 0
	is_teleport = true,
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 4 then
			game.logPlayer(self, "순간이동시킬 대상을 선택하세요.")
			local tg = {default_target=self, type="hit", nowarning=true, range=10, first_target="friend"}
			local tx, ty = self:getTarget(tg)
			if tx then
				local _ _, tx, ty = self:canProject(tg, tx, ty)
				if tx then
					target = game.level.map(tx, ty, Map.ACTOR) or self
				end
			end
		end

		if target ~= self and target:canBe("teleport") then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "마법이 헛나갔습니다!")
				return true
			end
		end

		-- Annoy them!
		if target ~= self and target:reactionToward(self) < 0 then target:setTarget(self) end

		local x, y = self.x, self.y
		local newpos
		if self:getTalentLevel(t) >= 5 then
			game.logPlayer(self, "순간이동할 지역을 선택하세요.")
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=t.getRange(self, t), radius=t.getRadius(self, t), requires_knowledge=false}
			x, y = self:getTarget(tg)
			if not x then return nil end
			-- Target code does not restrict the target coordinates to the range, it lets the project function do it
			-- but we cant ...
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
			newpos = target:teleportRandom(x, y, t.getRadius(self, t))
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		else
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
			newpos = target:teleportRandom(x, y, t.getRange(self, t), 15)
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		end

		if target ~= self then
			target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		end

		if not newpos then
			game.logSeen(game.player,"순간이동이 실패했습니다. 너무 좁은 지역이거나, 기타 다른 이유로 순간이동을 할 수 없는 지역입니다.")
		end
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		local radius = t.getRadius(self, t)
		return ([[주변 %d 칸 반경 내 무작위한 곳으로 원거리 순간이동합니다. 15 칸 미만의 거리는 순간이동할 수 없습니다.
		기술 레벨이 4 이상이면, 대상을 지정하여 순간이동시킬 수 있습니다.
		기술 레벨이 5 이상이면, 순간이동할 지역을 선택할 수 있습니다. (오차 범위 : 주변 %d 칸 반경)
		순간이동 범위는 주문력의 영향을 받아 증가합니다.]]):format(range, radius)
	end,
}

newTalent{
	name = "Displacement Shield",
	kr_name = "왜곡의 보호막",
	type = {"spell/conveyance", 3},
	require = spells_req3,
	points = 5,
	mana = 40,
	cooldown = 35,
	tactical = { DEFEND = 2 },
	range = 8,
	requires_target = true,
	getTransferChange = function(self, t) return 40 + self:getTalentLevel(t) * 5 end,
	getMaxAbsorb = function(self, t) return 50 + self:combatTalentSpellDamage(t, 20, 400) end,
	getDuration = function(self, t) return util.bound(10 + math.floor(self:getTalentLevel(t) * 3), 10, 25) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end
		if not target then return end

		self:setEffect(self.EFF_DISPLACEMENT_SHIELD, t.getDuration(self, t), {power=t.getMaxAbsorb(self, t), target=target, chance=t.getTransferChange(self, t)})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local chance = t.getTransferChange(self, t)
		local maxabsorb = t.getMaxAbsorb(self, t)
		local duration = t.getDuration(self, t)
		return ([[복잡한 술식으로 공간을 왜곡시키는 보호막을 만들어내고, 희생양을 하나 지정합니다. 
		보호막의 시전자가 피해를 받을 때마다 %d%% 확률로 피해를 전송하여, 시전자 대신 희생양이 피해를 받게 됩니다.
		총 %d 의 피해량을 전송했거나, %d 턴이 흘러 보호막의 지속시간이 끝나거나, 희생양이 사망하면 보호막은 사라집니다.
		보호막이 받아낼 수 있는 최대 피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(chance, maxabsorb, duration)
	end,
}

newTalent{
	name = "Probability Travel",
	kr_name = "마법 확률 이동",
	type = {"spell/conveyance",4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	cooldown = 40,
	sustain_mana = 200,
	tactical = { ESCAPE = 1, CLOSEIN = 1 },
	getRange = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.06) * self:getTalentLevel(t), 4, 0, 20, 16)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/teleport")
		return {
			prob_travel = self:addTemporaryValue("prob_travel", t.getRange(self, t)),
			prob_travel_penalty = self:addTemporaryValue("prob_travel_penalty", 2 + (5 - math.min(self:getTalentLevelRaw(t), 5)) / 2),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("prob_travel", p.prob_travel)
		self:removeTemporaryValue("prob_travel_penalty", p.prob_travel_penalty)
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[벽을 향해 이동하면 100%% 확률로 벽에 부딪힌다는 확률법칙을 뛰어넘어, 벽을 통과할 수 있게 됩니다.
		최대 %d 칸의 벽까지 통과할 수 있습니다.
		성공적인 벽 통과 후에도 몸이 안정화되려면 시간이 걸리기 때문에, 통과한 거리의 %d%% 에 해당하는 턴 동안에는 다시 벽을 통과할 수 없습니다.
		최대 이동 거리는 주문력의 영향을 받아 증가합니다.]]):
		format(range, (2 + (5 - math.min(self:getTalentLevelRaw(t), 5)) / 2) * 100)
	end,
}
