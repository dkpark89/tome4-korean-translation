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

------------------------------------------------------------------
-- Melee
------------------------------------------------------------------

newTalent{
	name = "Knockback", short_name = "GOLEM_KNOCKBACK",
	kr_name = "밀어내기",
	type = {"golem/fighting", 1},
	require = techs_req1,
	points = 5,
	cooldown = 10,
	range = 5,
	stamina = 5,
	requires_target = true,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), min_range=2}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	tactical = { DEFEND = { knockback = 2 }, DISABLE = { knockback = 1 } },
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "골렘이 활성화되지 않았습니다.") return end

		local tg = self:getTalentTarget(t)
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		if self.ai_target then self.ai_target.target = target end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
				game.logPlayer(self, "너무 가까이 있어서 돌진할 힘이 붙지 않습니다!")
				return
			end
			local tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
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
		end

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) > 1 then return true end
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 3)
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatPhysicalpower())
			else
				game.logSeen(target, "%s 밀려나지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[골렘이 대상에게 돌진하여, %d%% 피해를 주고 대상을 밀어냅니다.
		밀어내기 확률은 기술 레벨의 영향을 받아 증가합니다.]]):format(100 * damage)
	end,
}

newTalent{
	name = "Taunt", short_name = "GOLEM_TAUNT",
	kr_name = "도발",
	type = {"golem/fighting", 2},
	require = techs_req2,
	points = 5,
	cooldown = function(self, t)
		return 20 - self:getTalentLevelRaw(t) * 2
	end,
	range = 10,
	radius = function(self, t)
		return self:getTalentLevelRaw(t) / 2
	end,
	stamina = 5,
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), friendlyfire=false}
	end,
	tactical = { PROTECT = 3 },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			if self:reactionToward(target) < 0 then
				if self.ai_target then self.ai_target.target = target end
				target:setTarget(self)
				game.logSeen(self, "%s %s 도발하여, 자신만을 공격하도록 만들었습니다.", (self.kr_name or self.name):capitalize():addJosa("는"), (target.kr_name or target.name):addJosa("를"))
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[주변 %d 칸 반경의 적들을 도발하여, 골렘을 공격하도록 만듭니다.]]):format(self:getTalentLevelRaw(t) / 2 + 1)
	end,
}

newTalent{
	name = "Crush", short_name = "GOLEM_CRUSH",
	kr_name = "짓밟기",
	type = {"golem/fighting", 3},
	require = techs_req3,
	points = 5,
	cooldown = 10,
	range = 5,
	stamina = 5,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	getPinDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	tactical = { ATTACK = { PHYSICAL = 0.5 }, DISABLE = { pin = 2 } },
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "골렘이 활성화되지 않았습니다.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		if self.ai_target then self.ai_target.target = target end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
				game.logPlayer(self, "너무 가까이 있어서 돌진할 힘이 붙지 않습니다!")
				return
			end
			local tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
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
		end

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) > 1 then return true end
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Try to pin
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, t.getPinDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 속박되지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getPinDuration(self, t)
		return ([[골렘이 대상에게 돌진하여, %d%% 피해를 주고 대상을 짓밟아 땅에 %d 턴 동안 고정시킵니다.
		속박 확률은 기술 레벨의 영향을 받아 증가합니다.]]):
		format(100 * damage, duration)
	end,
}

newTalent{
	name = "Pound", short_name = "GOLEM_POUND",
	kr_name = "들이받기",
	type = {"golem/fighting", 4},
	require = techs_req4,
	points = 5,
	cooldown = 15,
	range = 5,
	radius = 2,
	stamina = 5,
	requires_target = true,
	target = function(self, t)
		return {type="ballbolt", radius=self:getTalentRadius(t), friendlyfire=false, range=self:getTalentRange(t)}
	end,
	getGolemDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.4, 1.1)
	end,
	getDazeDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	tactical = { ATTACKAREA = { PHYSICAL = 0.5 }, DISABLE = { daze = 3 } },
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "골렘이 활성화되지 않았습니다.") return end

		local tg = self:getTalentTarget(t)
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		if core.fov.distance(self.x, self.y, x, y) > 1 then
			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			if is_corner_blocked or game.level.map:checkAllEntities(lx, ly, "block_move", self) then
				game.logPlayer(self, "너무 가까이 있어서 돌진할 힘이 붙지 않습니다!")
				return
			end
			local tx, ty = lx, ly
			lx, ly, is_corner_blocked = l:step()
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
		end

		if self.ai_target then self.ai_target.target = target end

		-- Attack & daze
		tg.type = "ball"
		self:project(tg, self.x, self.y, function(xx, yy)
			if xx == self.x and yy == self.y then return end
			local target = game.level.map(xx, yy, Map.ACTOR)
			if target and self:attackTarget(target, nil, t.getGolemDamage(self, t), true) then
				if target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, t.getDazeDuration(self, t), {apply_power=self:combatPhysicalpower()})
				else
					game.logSeen(target, "%s 혼절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		local duration = t.getDazeDuration(self, t)
		local damage = t.getGolemDamage(self, t)
		return ([[골렘이 대상에게 돌진하여 주변 2 칸 반경에 충격파를 만들어냅니다. 주변의 적들은 %d 턴 동안 혼절 상태가 되며, %d%% 피해를 입습니다.
		혼절 확률은 기술 레벨의 영향을 받아 증가합니다.]]):
		format(duration, 100 * damage)
	end,
}


------------------------------------------------------------------
-- Arcane
------------------------------------------------------------------

newTalent{
	name = "Eye Beam", short_name = "GOLEM_BEAM",
	kr_name = "안광",
	type = {"golem/arcane", 1},
	require = spells_req1,
	points = 5,
	cooldown = 3,
	range = 7,
	mana = 10,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 320) end,
	tactical = { ATTACK = { FIRE = 1, COLD = 1, LIGHTNING = 1 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if self.x == x and self.y == y then return nil end

		-- We will always project the beam as far as possible
		local l = self:lineFOV(x, y)
		l:set_corner_block()
		local lx, ly, is_corner_blocked = l:step(true)
		local target_x, target_y = lx, ly
		-- Check for terrain and friendly actors
		while lx and ly and not is_corner_blocked and core.fov.distance(self.x, self.y, lx, ly) <= tg.range do
			local actor = game.level.map(lx, ly, engine.Map.ACTOR)
			if actor and (self:reactionToward(actor) >= 0) then
				break
			elseif game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then
				target_x, target_y = lx, ly
				break
			end
			target_x, target_y = lx, ly
			lx, ly = l:step(true)
		end
		x, y = target_x, target_y

		local typ = rng.range(1, 3)

		if typ == 1 then
			self:project(tg, x, y, DamageType.FIRE, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		elseif typ == 2 then
			self:project(tg, x, y, DamageType.LIGHTNING, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		else
			self:project(tg, x, y, DamageType.COLD, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "icebeam", {tx=x-self.x, ty=y-self.y})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[골렘이 눈에서 광선을 발사하여 %0.2f 의 화염 피해, %0.2f 의 냉기 피해, %0.2f 의 전기 피해 중 하나를 줍니다.
		피해량은 골렘의 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.FIRE, damage), damDesc(self, DamageType.COLD, damage), damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

newTalent{
	name = "Reflective Skin", short_name = "GOLEM_REFLECTIVE_SKIN",
	kr_name = "반발성 피부",
	type = {"golem/arcane", 2},
	require = spells_req2,
	points = 5,
	mode = "sustained",
	cooldown = 70,
	range = 10,
	sustain_mana = 30,
	requires_target = true,
	tactical = { DEFEND = 1, SURROUNDED = 3, BUFF = 1 },
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			tmpid = self:addTemporaryValue("reflect_damage", 20 + self:combatTalentSpellDamage(t, 12, 40))
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("reflect_damage", p.tmpid)
		return true
	end,
	info = function(self, t)
		return ([[골렘의 피부에 신비한 힘을 불어넣어, 골렘이 받는 모든 피해를 %d%% 반사합니다.
		단, 골렘이 받는 피해가 줄어들지는 않습니다.
		피해 반사율은 골렘의 주문력의 영향을 받아 증가합니다]]):
		format(20 + self:combatTalentSpellDamage(t, 12, 40))
	end,
}

newTalent{
	name = "Arcane Pull", short_name = "GOLEM_ARCANE_PULL",
	kr_name = "끌어오기 마법",
	type = {"golem/arcane", 3},
	require = spells_req3,
	points = 5,
	cooldown = 15,
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevel(t) / 2
	end,
	mana = 20,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	tactical = { ATTACKAREA = { ARCANE = 2 }, CLOSEIN = 1 },
	getDamage = function(self, t)
		return self:combatTalentSpellDamage(t, 12, 120)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = {}
		self:project(tg, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				tgts[#tgts+1] = {actor=target, sqdist=core.fov.distance(self.x, self.y, px, py)}
			end
		end)
		table.sort(tgts, "sqdist")
		for i, target in ipairs(tgts) do
			target.actor:pull(self.x, self.y, tg.radius)
			game.logSeen(target.actor, "%s %s에 의해 끌려옵니다!", (target.actor.kr_name or target.actor.name):capitalize():addJosa("가"), (self.kr_name or self.name))
			DamageType:get(DamageType.ARCANE).projector(self, target.actor.x, target.actor.y, DamageType.ARCANE, t.getDamage(self, t))
		end
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		local dam = t.getDamage(self, t)
		return ([[골렘이 주변 %d 칸 반경의 적들에게 %0.2f 마법 피해를 주고, 적들을 끌어당깁니다.]]):
		format(rad, dam)
	end,
}

newTalent{
	name = "Molten Skin", short_name = "GOLEM_MOLTEN_SKIN",
	kr_name = "용해된 피부",
	type = {"golem/arcane", 4},
	require = spells_req4,
	points = 5,
	mana = 60,
	cooldown = 15,
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	action = function(self, t)
		local duration = 5 + self:getTalentLevel(t)
		local dam = self:combatTalentSpellDamage(t, 12, 120)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.GOLEM_FIREBURN, dam,
			self:getTalentRadius(t),
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=200, color_bg=60, color_bb=30},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		self:setEffect(self.EFF_MOLTEN_SKIN, duration, {power=30 + self:combatTalentSpellDamage(t, 12, 60)})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[골렘의 피부를 용암으로 변화시킵니다. 그 열기 때문에, 주변 3 칸 반경의 적들은 3 턴 동안 %0.2f 화염 피해를 입습니다. (기술 지속시간 : %d 턴)
		화염 피해는 중첩됩니다. 즉, 범위 안에 오랫동안 있을수록 더 많은 화염 피해를 입습니다.
		추가적으로, 골렘의 화염 저항이 %d%% 상승합니다.
		골렘의 제작자는 이 기술로 인한 화염 피해를 입지 않습니다.
		화염 피해량과 저항 상승량은 골렘 제작자의 주문력의 영향을 받아 상승합니다.]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 12, 120)), 5 + self:getTalentLevel(t), 30 + self:combatTalentSpellDamage(t, 12, 60))
	end,
}

newTalent{
	name = "Self-destruction", short_name = "GOLEM_DESTRUCT",
	kr_name = "자폭",
	type = {"golem/golem", 1},
	points = 1,
	range = 0,
	radius = 4,
	no_unlearn_last = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { FIRE = 3 } },
	no_npc_use = true,
	on_pre_use = function(self, t)
		return self.summoner and self.summoner.dead
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.FIRE, 50 + 10 * self.level)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		game:playSoundNear(self, "talents/fireflash")
		self:die(self)
		return true
	end,
	info = function(self, t)
		local rad = self:getTalentRadius(t)
		return ([[골렘이 자폭합니다. 주변 %d 칸 반경에 화염 폭발이 일어나, 범위 내에 있는 모든 적들에게 %0.2f 화염 피해를 줍니다.
		골렘의 제작자가 죽었을 경우에만 이 기술을 사용할 수 있습니다.]]):format(rad, damDesc(self, DamageType.FIRE, 50 + 10 * self.level))
	end,
}

-- Compensate for changes to Armour Training by introducing a new golem skill
newTalent{
	name = "Armour Configuration", short_name = "GOLEM_ARMOUR",
	kr_name = "갑옷 재배열",
	type = {"golem/golem", 1},
	mode = "passive",
	points = 6,
	no_unlearn_last = true,
	getArmorHardiness = function(self, t) return self:getTalentTypeMastery("technique/combat-training") * (self:getTalentLevelRaw(t) * 5 - 15) end,
	getArmor = function(self, t) return self:getTalentTypeMastery("technique/combat-training") * (self:getTalentLevelRaw(t) * 1.4 - 4.2) end,
	getCriticalChanceReduction = function(self, t) return self:getTalentTypeMastery("technique/combat-training") * (self:getTalentLevelRaw(t) * 1.9 - 5.7) end,
	info = function(self, t)
		local hardiness = t.getArmorHardiness(self, t)
		local armor = t.getArmor(self, t)
		local critreduce = t.getCriticalChanceReduction(self, t)
		local dir = self:getTalentLevelRaw(t) >= 3 and "상승" or "하락"
		return ([[골렘이 중갑과 판갑을 자동적으로 변형시켜, 자신이 착용할 수 있게 만듭니다.
		갑옷의 방어도가 %d / 방어 효율이 %d%% 만큼 %s하며, 적에게 치명타를 맞을 확률이 %d%% 만큼 낮아집니다.]]):
		format(armor, hardiness, dir, critreduce) --@@ 변수 순서 조정
	end,
}
