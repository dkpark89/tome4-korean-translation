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

require "engine.krtrUtils" --@@

newTalent{
	name = "Grappling Stance",
	kr_display_name = "잡기 자세",
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
		return ([[물리 내성을 %d 증가시키고 물리력을 %d 증가시킵니다.
		이 효과는 힘 능력치에 영향을 받아 증가됩니다.]])
		:format(save, damage)
	end,
}

newTalent{
	name = "Clinch",
	kr_display_name = "붙잡기",
	type = {"technique/grappling", 1},
	require = techs_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 5,
	tactical = { ATTACK = 2, DISABLE = 2 },
	requires_target = true,
	getDuration = function(self, t) return 4 + math.floor(self:getTalentLevel(t)) end,
	getPower = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 25) end,
	getDrain = function(self, t) return 6 - math.max(1, self:getTalentLevelRaw(t) or 0) end,
	-- Learn the appropriate stance
	on_learn = function(self, t)
		if not self:knowTalent(self.T_GRAPPLING_STANCE) then
			self:learnTalent(self.T_GRAPPLING_STANCE, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:unlearnTalent(self.T_GRAPPLING_STANCE)
		end
	end,
	action = function(self, t)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local grappled = false

		-- force stance change
		if target and not self:isTalentActive(self.T_GRAPPLING_STANCE) then
			self:forceUseTalent(self.T_GRAPPLING_STANCE, {ignore_energy=true, ignore_cd = true})
		end

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
		local hit = self:startGrapple(target)

		local duration = t.getDuration(self, t)

		-- do crushing hold or strangle if we're already grappling the target
		if hit and self:knowTalent(self.T_CRUSHING_HOLD) then
			local t = self:getTalentFromId(self.T_CRUSHING_HOLD)
			if grappled and not target.no_breath and not target:attr("undead") and target:canBe("silence") then
				target:setEffect(target.EFF_STRANGLE_HOLD, duration, {src=self, power=t.getDamage(self, t) * 1.5})
			else
				target:setEffect(target.EFF_CRUSHING_HOLD, duration, {src=self, power=t.getDamage(self, t)})
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		local drain = t.getDrain(self, t)
		return ([[당신의 신체 크기보다 한 단계 큰 대상까지, %d 턴 동안 붙잡습니다. 붙잡힌 대상은 이동할 수 없게 되고 정확도와 회피도가 %d 감소됩니다. 붙잡은 상태에서 이동하게 되면 기술이 풀립니다. 붙잡기를 유지하는 동안에는 매 턴마다 체력이 %d 씩 소모됩니다.
		한번에 하나의 대상만 붙잡을 수 있으며, 다른 대상에게 맨손 전투 기술을 사용하면 붙잡은 대상이 풀려납니다.
		붙잡을 확률과 잡힌 대상의 정확도, 회피도 감소는 물리력에 영향을 받아 증가됩니다.
		이 기술을 사용하면 잡기 자세로 전환됩니다.]])
		:format(duration, power, drain)
	end,
}

newTalent{
	name = "Maim",
	kr_display_name = "꺽기",
	type = {"technique/grappling", 2},
	require = techs_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 10,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = 2 },
	requires_target = true,
	getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t)) end,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 100) * getUnarmedTrainingBonus(self) end,
	getMaim = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 30) end,
	-- Learn the appropriate stance
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
		local hit = self:startGrapple (target)
		-- deal damage and maim if appropriate
		if hit then
			if grappled then
				self:project(target, x, y, DamageType.PHYSICAL, self:physicalCrit(t.getDamage(self, t), nil, target, self:combatAttack(), target:combatDefense()))
				target:setEffect(target.EFF_MAIMED, t.getDuration(self, t), {power=t.getMaim(self, t)})
			else
				self:project(target, x, y, DamageType.PHYSICAL, self:physicalCrit(t.getDamage(self, t), nil, target, self:combatAttack(), target:combatDefense()))
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		local maim = t.getMaim(self, t)
		return ([[대상을 잡고 %0.2f 의 물리 피해를 줍니다. 대상이 이미 잡혀있는 상태라면, 붙잡은 상태로 꺽어서 대상의 공격력을 %d 감소시키고 전체 속도를 30%% 감소시키는 효과를 %d 턴 동안 유지합니다.
		이 효과는 물리력에 영향을 받아 증가됩니다.]])
		:format(damDesc(self, DamageType.PHYSICAL, (damage)), maim, duration)
	end,
}

newTalent{
	name = "Crushing Hold",
	kr_display_name = "눌러 조르기",
	type = {"technique/grappling", 3},
	require = techs_req3,
	mode = "passive",
	points = 5,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { silence = 2 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 50) * getUnarmedTrainingBonus(self) end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[붙잡기 기술에 매 턴마다 %0.2f 의 물리 피해를 입히는, 눌러 조르기 효과가 추가됩니다. 대상이 이미 잡혀있는 상태라면, 붙잡은 상태로 숨통을 졸라서 침묵시키고 매 턴마다 %0.2f 의 물리 피해를 줍니다.
		대상이 침묵 효과에 면역이거나, 숨을 쉬지 않거나, 언데드라면 숨통 조르기 대신 눌러 조르기 효과만 받게 됩니다.
		이 효과는 물리력에 영향을 받아 증가됩니다.]])
		:format(damDesc(self, DamageType.PHYSICAL, (damage)), damDesc(self, DamageType.PHYSICAL, (damage * 1.5)))
	end,
}

newTalent{
	name = "Take Down",
	kr_display_name = "넘어뜨리기",
	type = {"technique/grappling", 4},
	require = techs_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 24,
	stamina = 12,
	tactical = { ATTACK = { PHYSICAL = 1, stun = 1}, DISABLE = { stun = 2 }, CLOSEIN = 2 },
	requires_target = true,
	range = function(self, t) return 2 + math.floor(self:getTalentLevel(t)/3) end,
	getDuration = function(self, t) return 2 + math.floor(self:getTalentLevel(t)) end,
	getTakeDown = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 100) * getUnarmedTrainingBonus(self) end,
	getSlam = function(self, t) return self:combatTalentPhysicalDamage(t, 15, 150) * getUnarmedTrainingBonus(self) end,
	-- Learn the appropriate stance
	action = function(self, t)
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
			local hit = self:startGrapple (target)
			-- takedown or slam as appropriate
			if hit then
				if grappled then
					self:project(target, x, y, DamageType.PHYSICAL, self:physicalCrit(t.getSlam(self, t), nil, target, self:combatAttack(), target:combatDefense()))
					if target:canBe("stun") then
						target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
					else
						game.logSeen(target, "%s 기절 효과에 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
					end
				else
					self:project(target, x, y, DamageType.PHYSICAL, self:physicalCrit(t.getTakeDown(self, t), nil, target, self:combatAttack(), target:combatDefense()))
					if target:canBe("stun") then
						target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
					else
						game.logSeen(target, "%s 혼절 효과에 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
					end
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local takedown = t.getTakeDown(self, t)
		local slam = t.getSlam(self, t)
		return ([[대상에게 달려들어서 땅바닥에 넘어뜨린 뒤, 잡아서 %0.2f 의 물리 피해를 주고 %d 턴 동안 혼절시킵니다. 대상이 이미 잡혀있는 상태라면 땅바닥에 내동댕이 쳐서, %0.2f 의 물리 피해를 입히고 %d 턴 동안 기절시킵니다.
		이 효과는 물리력에 영향을 받아 증가됩니다.]])
		:format(damDesc(self, DamageType.PHYSICAL, (takedown)), duration, damDesc(self, DamageType.PHYSICAL, (slam)), duration)
	end,
}

