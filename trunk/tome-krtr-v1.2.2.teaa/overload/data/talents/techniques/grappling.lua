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

-- Obsolete but undeleted incase something uses it 
newTalent{
	name = "Grappling Stance",
	kr_name = "잡기 자세",
	type = {"technique/unarmed-other", 1},
	mode = "sustained",
	hide = true,
	points = 1,
	cooldown = 12,
	tactical = { BUFF = 2 },
	type_no_req = true,
	no_npc_use = true, -- They dont need it since it auto switches anyway
	no_unlearn_last = true,
	getSave = function(self, t) return self:getStr(20, true) end,
	getDamage = function(self, t) return self:getStr(10, true) end,
	activate = function(self, t)
		cancelStances(self)
		local ret = {
			phys = self:addTemporaryValue("combat_physresist", t.getSave(self, t)),
			power = self:addTemporaryValue("combat_dam", t.getDamage(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physresist", p.phys)
		self:removeTemporaryValue("combat_dam", p.power)
		return true
	end,
	info = function(self, t)
		local save = t.getSave(self, t)
		local damage = t.getDamage(self, t)
		return ([[잡기 자세를 취해 물리 내성을 %d 증가시키고, 물리력을 %d 증가시킵니다.
		이 효과는 힘 능력치의 영향을 받아 증가합니다.]])
		:format(save, damage)
	end,
}

newTalent{
	name = "Clinch",
	kr_name = "붙잡기",
	type = {"technique/grappling", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 5,
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getPower = function(self, t) return self:combatTalentPhysicalDamage(t, 20, 60) end,
	getDrain = function(self, t) return 6 end,
	getSharePct = function(self, t) return math.min(0.35, self:combatTalentScale(t, 0.05, 0.25)) end,
	getDamage = function(self, t) return 1 end,
	action = function(self, t)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local grappled = false

		-- breaks active grapples if the target is not grappled
		if target:isGrappled(self) then
			grappled = true
		else
			self:breakGrapples()
		end

		-- end the talent without effect if the target is to big
		if self:grappleSizeCheck(target) then
			return true
		end

		-- start the grapple; this will automatically hit and reapply the grapple if we're already grappling the target
		local hit self:attackTarget(target, nil, t.getDamage(self, t), true)
		local hit2 = self:startGrapple(target)

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		local drain = t.getDrain(self, t)
		local share = t.getSharePct(self, t)*100
		local damage = t.getDamage(self, t)*100
		return ([[자신의 신체 크기보다 한 단계 큰 대상까지에게 %d%% 피해의 근접공격을 한 뒤 붙잡기 시도를 합니다. 붙잡기에 성공하면 대상을 %d 턴 동안 붙잡고 있게 됩니다.
		붙잡힌 대상은 이동할 수 없게 되고, 붙잡힌 동안 매 턴마다 %d의 피해를 받습니다. 또한 붙잡힌 상태에서 붙잡은 이가 받는 피해의 %d%% 는 붙잡힌 대상에게 전달됩니다. 
		붙잡은 상태에서 이동하게 되면 기술이 풀리며, 붙잡기를 유지하는 동안에는 매 턴마다 체력이 %d 씩 소모됩니다.
		한번에 하나의 대상만을 붙잡을 수 있으며, 다른 대상에게 맨손 전투 기술을 사용하면 붙잡은 대상이 풀려납니다.]])
		:format(damage, duration, power, share, drain)
	end,
}

-- I tried to keep this relatively consistent with the existing Grappling code structure, but it wound up pretty awkward as a result
newTalent{
	name = "Crushing Hold",
	kr_name = "눌러 조르기",
	type = {"technique/grappling", 2},
	require = techs_req2,
	mode = "passive",
	points = 5,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { silence = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 50) * getUnarmedTrainingBonus(self) end, -- this function shouldn't be used any more but I left it in to be safe, Clinch now handles the damage 
	getSlow = function(self, t)
		if self:getTalentLevel(self.T_CRUSHING_HOLD) >= 5 then
			return self:combatTalentPhysicalDamage(t, 0.05, 0.65)
		else
			return 0
		end
	end,
	getDamageReduction = function(self, t)
		return self:combatTalentPhysicalDamage(t, 1, 15)
	end,
	getSilence = function(self, t) -- this is a silence without an immunity check by design, if concerned about NPC use this is the talent to block
		if self:getTalentLevel(self.T_CRUSHING_HOLD) >= 3 then
			return 1
		else
			return 0
		end
	end,
	getBonusEffects = function(self, t) -- used by startGrapple in Combat.lua, essentially merges these properties and the Clinch bonuses
		return {silence = t.getSilence(self, t), slow = t.getSlow(self, t), reduce = t.getDamageReduction(self, t)}	
	end,
	info = function(self, t)
		local reduction = t.getDamageReduction(self, t)
		local slow = t.getSlow(self, t)
		
		return ([[적을 잡는 능력을 강화하여, 추가 효과를 발생시킵니다. 모든 추가 효과는 내성이나 저항을 무시하고 발동합니다.
		#RED#기술 레벨 1 이상 : 적의 기본 무기 피해량 %d 감소
		기술 레벨 3 이상 : 적 침묵
		기술 레벨 5 이상 : 적의 전체 행동 속도 %d%% 감소#LAST#]]) 
		:format(reduction, slow*100)
	end,
}


newTalent{
	name = "Take Down",
	kr_name = "넘어뜨리기",
	type = {"technique/grappling", 3},
	require = techs_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 10,
	stamina = 15,
	tactical = { ATTACK = { PHYSICAL = 1}, CLOSEIN = 2 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	getTakeDown = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 100) * getUnarmedTrainingBonus(self) end,
	getSlam = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 400) * getUnarmedTrainingBonus(self) end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, .1, 1)
	end,
	action = function(self, t)

		-- if the target is grappled then do an attack+AoE project
		if self:hasEffect(self.EFF_GRAPPLING) then
			local target = self:hasEffect(self.EFF_GRAPPLING)["trgt"]
			local tg = {type="ball", range=1, radius=5, selffire=false}

			local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
			local slam = self:physicalCrit(t.getSlam(self, t), nil, target, self:combatAttack(), target:combatDefense())
			self:project(tg, self.x, self.y, DamageType.PHYSICAL, slam, {type="bones"})
			
			self:breakGrapples()
					
			return true
		else
			local tg = {type="hit", range=self:getTalentRange(t)}
			local x, y, target = self:getTarget(tg)
			if not x or not y or not target then return nil end
			if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		

			local grappled = false

			-- do the rush
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			local tx, ty = self.x, self.y
			while lx and ly do
				if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			local ox, oy = self.x, self.y
			self:move(tx, ty, true)
			if config.settings.tome.smooth_move > 0 then
				self:resetMoveAnim()
				self:setMoveAnim(ox, oy, 8, 5)
			end

			-- breaks active grapples if the target is not grappled
			if target:isGrappled(self) then
				grappled = true
			else
				self:breakGrapples()
			end

			if core.fov.distance(self.x, self.y, x, y) == 1 then
				-- end the talent without effect if the target is to big
				if self:grappleSizeCheck(target) then
					return true
				end

				-- start the grapple; this will automatically hit and reapply the grapple if we're already grappling the target
				local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)	
				local hit2 = self:startGrapple (target)
				
			end

			return true
			end
	end,
	info = function(self, t)
		local takedown = t.getDamage(self, t)*100
		local slam = t.getSlam(self, t)
		return ([[대상에게 달려들어 넘어뜨리면서 %d%% 피해의 근접공격을 하고, 대상을 붙잡습니다. 대상이 이미 붙잡힌 상태라면, 대상을 땅바닥에 내동댕이 쳐서 5 칸 반경으로 %d 의 물리 피해를 발생시키는 충격파를 일으키지만 대상에게로의 붙잡기는 풀리게 됩니다.
		붙잡기 효과는 다른 붙잡기 기술들의 영향을 받으며, 물리 피해량은 물리력의 영향을 받아 증가합니다.]])
		:format(damDesc(self, DamageType.PHYSICAL, (takedown)), damDesc(self, DamageType.PHYSICAL, (slam)))
	end,
}

newTalent{
	name = "Hurricane Throw",
	kr_name = "폭풍 투척", 
	type = {"technique/grappling", 4},
	require = techs_req4,
	points = 5,
	random_ego = "attack",
	requires_target = true,
	cooldown = function(self, t)
		return 8
	end,
	stamina = 20,
	range = function(self, t)
		return 8
	end,
	radius = function(self, t)
		return 1
	end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 1, 3.5) -- no interaction with Striking Stance so we make the base damage higher to compensate
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
	
		if self:hasEffect(self.EFF_GRAPPLING) then
			local grappled = self:hasEffect(self.EFF_GRAPPLING)["trgt"]
			
			local tg = self:getTalentTarget(t)
			local x, y, target = self:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = self:canProject(tg, x, y)
			
			-- if the target square is an actor, find a free grid around it instead
			if game.level.map(x, y, Map.ACTOR) then
				x, y = util.findFreeGrid(x, y, 1, true, {[Map.ACTOR]=true})
				if not x then return end
			end

			if game.level.map:checkAllEntities(x, y, "block_move") then return end

			local ox, oy = grappled.x, grappled.y
			grappled:move(x, y, true)
			if config.settings.tome.smooth_move > 0 then
				grappled:resetMoveAnim()
				grappled:setMoveAnim(ox, oy, 8, 5)
			end
			
			-- pick all targets around the landing point and do a melee attack
			self:project(tg, grappled.x, grappled.y, function(px, py, tg, self)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target ~= self then
				
					local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
					self:breakGrapples()
				end
			end)
			return true

		else
			-- only usable if you have something Grappled
			return false
		end
	end,
	info = function(self, t)
		return ([[붙잡은 적을 강력한 힘으로 빙빙 돌린 뒤, 멀리 던져버립니다. 이를 통해 던져진 적과 낙하지점 주변의 모든 적들에게 %d%% 피해를 줍니다.]]):format(t.getDamage(self, t)*100) 
	end,
}
