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

local Object = require "mod.class.Object"

-- race & classes
newTalentType{ type="technique/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ no_silence=true, is_spell=true, type="chronomancy/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ no_silence=true, is_spell=true, type="spell/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ no_silence=true, is_spell=true, type="corruption/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ is_nature=true, type="wild-gift/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ type="psionic/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ type="other/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ type="undead/other", name = "other", hide = true, description = "세상에 존재하는 다양한 기술들입니다." }
newTalentType{ type="undead/keepsake", name = "keepsake shadow", generic = true, description = "'고통의 자취'에서 그림자가 사용하는 특별한 기술들입니다." }

local oldTalent = newTalent
local newTalent = function(t) if type(t.hide) == "nil" then t.hide = true end return oldTalent(t) end

-- Multiply!!!
newTalent{
	name = "Multiply",
	kr_name = "자기복제",
	type = {"other/other", 1},
	cooldown = 3,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		if not self.can_multiply or self.can_multiply <= 0 then print("no more multiply") return nil end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then print("no free space") return nil end

		-- Find a place around to clone
		self.can_multiply = self.can_multiply - 1
		local a
		if self.clone_base then a = self.clone_base:clone() else a = self:clone() end
		a.can_multiply = a.can_multiply - 1
		a.energy.val = 0
		a.exp_worth = 0.1
		a.inven = {}
		a.x, a.y = nil, nil
		a:removeAllMOs()
		a:removeTimedEffectsOnClone()
		if a.can_multiply <= 0 then a:unlearnTalent(t.id) end

		print("[MULTIPLY]", x, y, "::", game.level.map(x,y,Map.ACTOR))
		print("[MULTIPLY]", a.can_multiply, "uids", self.uid,"=>",a.uid, "::", self.player, a.player)
		game.zone:addEntity(game.level, a, "actor", x, y)
		a:check("on_multiply", self)
		return true
	end,
	info = function(self, t)
		return ([[자기복제입니다!]])
	end,
}

newTalent{
	short_name = "CRAWL_POISON",
	name = "Poisonous Crawl",
	kr_name = "독성 발톱",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 독성 발톱으로 @Target3@ 할큅니다!",
	cooldown = 5,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	getMult = function(self, t) return self:combatTalentScale(t, 3, 7, "log") end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, t.getMult(self, t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self, t)
		return ([[독이 묻은 발톱으로 대상을 공격하여 %d%%의 피해를 줍니다.]]):
		format(100*t.getMult(self, t))
	end,
}

newTalent{
	short_name = "CRAWL_ACID",
	name = "Acidic Crawl",
	kr_name = "산성 발톱",
	points = 5,
	type = {"technique/other", 1},
	message = "@Source1@ 산성 발톱으로 @Target3@ 할큅니다!",
	cooldown = 2,
	range = 1,
	tactical = { ATTACK = { ACID = 2 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.ACID, self:combatTalentWeaponDamage(t, 1, 1.8), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self, t)
		return ([[산이 묻은 발톱으로 대상을 공격합니다.]])
	end,
}

newTalent{
	short_name = "SPORE_BLIND",
	name = "Blinding Spores",
	kr_name = "실명 포자",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 실명 포자를 @target@에게 뿌립니다!",
	cooldown = 2,
	range = 1,
	tactical = { DISABLE = { blind = 2 } },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, DamageType.LIGHT, self:combatTalentWeaponDamage(t, 1, 1.8), true)

		-- Try to blind !
		if hit then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 실명되지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상에게 실명 포자를 뿌려, %d 턴 동안 실명 상태로 만듭니다.]]):
		format(t.getDuration(self, t))
	end,
}

newTalent{
	short_name = "SPORE_POISON",
	name = "Poisonous Spores",
	kr_name = "독성 포자",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 독성 포자를 @target@에게 뿌립니다!",
	cooldown = 2,
	range = 1,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	requires_target = true,
	getMult = function(self, t) return self:combatTalentScale(t, 3, 7, "log") end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, t.getMult(self, t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self, t)
		return ([[대상에게 독성 포자를 뿌려, %d%%의 피해를 입히고 중독시킵니다.]]):
		format(100 * t.getMult(self, t))
	end,
}

newTalent{
	name = "Stun",
	kr_name = "기절",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { stun = 2 } },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상은 %d 턴 동안 기절합니다. 
		기절 확률은 물리력의 영향을 받아 증가합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 1), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Disarm",
	kr_name = "무장 해제",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { disarm = 2 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		if hit and target:canBe("disarm") then
			target:setEffect(target.EFF_DISARMED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			target:crossTierEffect(target.EFF_DISARMED, self:combatPhysicalpower())
		else
			game.logSeen(target, "%s 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상의 무장이 %d 턴 동안 해제됩니다. 무장 해제 확률은 물리력의 영향을 받아 증가합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 1), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Constrict",
	kr_name = "조르기",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { stun = 1 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 15, 52)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to constrict !
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_CONSTRICTED, t.getDuration(self, t), {src=self, power=1.5 * self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 질식 상태가 되지  않았습니다!", (target.kr_name or target.name):capitalize():addJosa("는"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상을 %d 턴 동안 질식시킵니다.
		질식 상태의 위력은 물리력의 영향을 받아 증가합니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 1), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Knockback",
	kr_name = "밀어내기",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	requires_target = true,
	tactical = { ATTACK = 1, DISABLE = { knockback = 2 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1.5, 2), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(self:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 4)
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatPhysicalpower())
			else
				game.logSeen(target, "%s 밀려나지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상이 밀려납니다. 밀려날 확률은 물리력의 영향을 받아 증가합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1.5, 2))
	end,
}

newTalent{
	short_name = "BITE_POISON",
	name = "Poisonous Bite",
	kr_name = "독성 깨물기",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ @Target3@ 깨물어 독을 흘려넣었습니다!",
	cooldown = 5,
	range = 1,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	requires_target = true,
	getMult = function(self, t) return self:combatTalentScale(t, 3, 7, "log") end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTarget(target, DamageType.POISON, t.getMult(self, t), true)
		return true
	end,
	info = function(self, t)
		return ([[대상을 깨물어, %d%%의 피해를 주면서 독을 주입합니다.]]):format(100 * t.getMult(self, t))
	end,
}

newTalent{
	name = "Summon",
	kr_name = "소환",
	type = {"wild-gift/other", 1},
	cooldown = 1,
	range = 10,
	equilibrium = 18,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = 2 },
	is_summon = true,
	action = function(self, t)
		if not self:canBe("summon") then game.logPlayer(self, "제압된 상태에서는 소환할 수 없습니다!") return end

		local filters = self.summon or {{type=self.type, subtype=self.subtype, number=1, hasxp=true, lastfor=20}}
		if #filters == 0 then return end
		local filter = rng.table(filters)

		-- Apply summon destabilization
		if self:getTalentLevel(t) < 5 then self:setEffect(self.EFF_SUMMON_DESTABILIZATION, 500, {power=5}) end

		for i = 1, filter.number do
			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 10, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "소환할 공간이 없습니다!")
				break
			end

			-- Find an actor with that filter
			filter = table.clone(filter)
			filter.max_ood = filter.max_ood or 2
			local m = game.zone:makeEntity(game.level, "actor", filter, nil, true)
			if m then
				if not filter.hasxp then m.exp_worth = 0 end
				m:resolve()

				if not filter.no_summoner_set then
					m.summoner = self
					m.summon_time = filter.lastfor
				end
				if not m.hard_faction then m.faction = self.faction end

				if not filter.hasloot then m:forgetInven(m.INVEN_INVEN) end

				game.zone:addEntity(game.level, m, "actor", x, y)

				self:logCombat(m, "#Source1# #Target3# 소환했습니다!")

				-- Apply summon destabilization
				if self:hasEffect(self.EFF_SUMMON_DESTABILIZATION) then
					m:setEffect(m.EFF_SUMMON_DESTABILIZATION, 500, {power=self:hasEffect(self.EFF_SUMMON_DESTABILIZATION).power})
				end

				-- Learn about summoners
				if game.level.map.seens(self.x, self.y) then
					game:setAllowedBuild("wilder_summoner", true)
				end
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[동료를 소환합니다.]])
	end,
}

newTalent{
	name = "Rotting Disease",
	kr_name = "부패성 질병",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source1@ @target@에게 질병을 옮깁니다.",
	requires_target = true,
	tactical = { ATTACK = { BLIGHT = 2 }, DISABLE = { disease = 1 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 13, 25)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:canBe("disease") then
				target:setEffect(target.EFF_ROTTING_DISEASE, t.getDuration(self, t), {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, con=math.floor(4 + target:getCon() * 0.1), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 병에 걸리지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 적중할 경우, 대상은 질병에 걸려 매 턴마다 %d 황폐 피해를 %d 턴 동안 받으며 체격 능력치가 감소됩니다.]]): 
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 1),damDesc(self, DamageType.BLIGHT,self:getStr() / 3 + self:getTalentLevel(t) * 2),t.getDuration(self, t))
	end,
}

newTalent{
	name = "Decrepitude Disease",
	kr_name = "노화성 질병",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source1@ @target@에게 질병을 옮깁니다.",
	tactical = { ATTACK = { BLIGHT = 2 }, DISABLE = { disease = 1 } },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 13, 25)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:canBe("disease") then
				target:setEffect(target.EFF_DECREPITUDE_DISEASE, t.getDuration(self, t), {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, dex=math.floor(4 + target:getDex() * 0.1), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 병에 걸리지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다.공격이 적중할 경우, 대상은 질병에 걸려 매 턴마다 %d 황폐 피해를 %d 턴 동안 받으며 민첩 능력치가 감소됩니다.]]): 
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 1),damDesc(self, DamageType.BLIGHT,self:getStr() / 3 + self:getTalentLevel(t) * 2),t.getDuration(self, t))
	end,
}

newTalent{
	name = "Weakness Disease",
	kr_name = "약화성 질병",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source1@ @target@에게 질병을 옮깁니다.",
	requires_target = true,
	tactical = { ATTACK = { BLIGHT = 2 }, DISABLE = { disease = 1 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 13, 25)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:canBe("disease") then
				target:setEffect(target.EFF_WEAKNESS_DISEASE, t.getDuration(self, t), {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, str=math.floor(4 + target:getStr() * 0.1), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 병에 걸리지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 적중할 경우, 대상은 질병에 걸려 매 턴마다 %d 황폐 피해를 %d 턴 동안 받으며 힘 능력치가 감소됩니다]]): 
		format(100 * self:combatTalentWeaponDamage(t, 0.5, 1),damDesc(self, DamageType.BLIGHT,self:getStr() / 3 + self:getTalentLevel(t) * 2),t.getDuration(self, t))
	end,
}

newTalent{
	name = "Mind Disruption",
	kr_name = "정신 방해",
	type = {"spell/other", 1},
	points = 5,
	cooldown = 10,
	mana = 16,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { DISABLE = { confusion = 3 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CONFUSION, {dur=t.getDuration(self, t), dam=50+self:getTalentLevelRaw(t)*10}, {type="manathrust"})
		return true
	end,
	info = function(self, t)
		return ([[대상을 %d 턴 동안 혼란 상태로 만듭니다.]]):format(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Water Bolt",
	kr_name = "물줄기 화살",
	type = {"spell/other", },
	points = 5,
	mana = 10,
	cooldown = 3,
	range = 10,
	reflectable = true,
	tactical = { ATTACK = { COLD = 1 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatScale(self:combatSpellpower() * self:getTalentLevel(t), 12, 0, 78.25, 265, 0.67) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.COLD, self:spellCrit(t.getDamage(self, t)), {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 물줄기를 발사하여, %0.1f 냉기 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD,t.getDamage(self, t)))
	end,
}

-- Crystal Flame replacement
newTalent{
	name = "Flame Bolt",
	kr_name = "불꽃 화살",
	type = {"spell/other",1},
	points = 1,
	random_ego = "attack",
	mana = 12,
	cooldown = 3,
	tactical = { ATTACK = { FIRE = 2 } },
	range = 10,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = nil

			self:projectile(tg, x, y, DamageType.FIREBURN, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
				game.level.map:particleEmitter(x, y, 1, "flame")
				if self:attr("burning_wake") then
					game.level.map:addEffect(self, x, y, 4, engine.DamageType.INFERNO, self:attr("burning_wake"), 0, 5, nil, {type="inferno"}, nil, self:spellFriendlyFire())
				end
			end)

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[불꽃 화살을 발사하여, 대상을 불태웁니다. 3 턴 동안 %0.2f 화염 피해를 나누어 입게 됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.FIRE, damage))
	end,
}

-- Crystal Ice Shards replacement
-- Very slow, moderate damage, freezes
newTalent{
	name = "Ice Bolt",
	kr_name = "얼음 화살",
	type = {"spell/other",1},
	points = 1,
	random_ego = "attack",
	mana = 12,
	cooldown = 3,
	tactical = { ATTACK = { FIRE = 2 } },
	range = 10,
	reflectable = true,
	proj_speed = 6,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 140) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local grids = self:project(tg, x, y, function(px, py)
			local actor = game.level.map(px, py, Map.ACTOR)
			if actor and actor ~= self then
				local tg2 = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="arrow", particle_args={tile="particles_images/ice_shards"}}}
				self:projectile(tg2, px, py, DamageType.ICE, self:spellCrit(t.getDamage(self, t)), {type="freeze"})
			end
		end)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[얼음 조각을 발사하여, %0.2f 냉기 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD, damage))
	end,
}

-- Crystal Soul Rot replacement
-- Slower projectile, higher damage, crit bonus
newTalent{
	name = "Blight Bolt",
	kr_name = "황폐 화살",
	type = {"spell/other",1},
	points = 1,
	random_ego = "attack",
	mana = 12,
	cooldown = 3,
	tactical = { ATTACK = { BLIGHT = 2 } },
	range = 10,
	reflectable = true,
	proj_speed = 10,
	requires_target = true,
	getCritChance = function(self, t) return self:combatTalentScale(t, 7, 25, 0.75) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 1, 140) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.BLIGHT, self:spellCrit(self:combatTalentSpellDamage(t, 1, 140), t.getCritChance(self, t)), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[순수한 황폐의 힘을 담은 화살을 발사해, %0.2f 황폐 피해를 줍니다.
		이 주문은 치명타가 발생할 확률이 +%0.2f%% 더 높습니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 1, 180)), t.getCritChance(self, t))
	end,
}

newTalent{
	name = "Water Jet",
	kr_name = "물대포",
	type = {"spell/other", },
	points = 5,
	mana = 10,
	cooldown = 8,
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	tactical = { DISABLE = { stun = 2 }, ATTACK = { COLD = 1 } },
	getDamage = function(self, t) return self:combatScale(self:combatSpellpower() * self:getTalentLevel(t), 12, 0, 65, 265, 0.67) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.COLDSTUN, self:spellCrit(t.getDamage(self, t)), {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 강력한 물줄기를 발사하여, %0.1f 냉기 피해를 주고 4 턴 동안 기절시킵니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD,t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Void Blast",
	kr_name = "공허의 돌풍",
	type = {"spell/other", },
	points = 5,
	mana = 3,
	cooldown = 2,
	tactical = { ATTACK = { ARCANE = 7 } },
	range = 10,
	reflectable = true,
	requires_target = true,
	proj_speed = 2,
	target = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_void", trail="voidtrail"}} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.VOID_BLAST, self:spellCrit(self:combatTalentSpellDamage(t, 15, 240)), {type="voidblast"})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[느리게 움직이는 공허의 돌풍을 발사하여, %0.2f 마법 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.ARCANE, self:combatTalentSpellDamage(t, 15, 240)))
	end,
}

newTalent{
	name = "Restoration",
	kr_name = "회복",
	type = {"spell/other", 1},
	points = 5,
	mana = 30,
	cooldown = 15,
	tactical = { CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.poison or e.subtype.disease then nb = nb + 1 end
		end
		return nb
	end },
	getCureCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	action = function(self, t)
		local target = self
		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.subtype.poison or e.subtype.disease then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getCureCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local curecount = t.getCureCount(self, t)
		return ([[자연의 힘을 빌어, 독과 질병을 %d 가지 회복합니다. (3 레벨 기준)]]):
		format(curecount)
	end,
}

newTalent{
	name = "Regeneration",
	kr_name = "재생",
	type = {"spell/other", 1},
	points = 5,
	mana = 30,
	cooldown = 10,
	tactical = { HEAL = 2 },
	getRegeneration = function(self, t) return 5 + self:combatTalentSpellDamage(t, 5, 25) end,
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=t.getRegeneration(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local regen = t.getRegeneration(self, t)
		return ([[자연의 힘을 빌어, 10 턴 동안 매 턴마다 %d 생명력을 회복합니다.
		회복량은 마법 능력치의 영향을 받아 증가합니다.]]):
		format(regen)
	end,
}

newTalent{
	name = "Grab",
	kr_name = "붙잡기",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	requires_target = true,
	tactical = { DISABLE = { pin = 2 }, ATTACK = { PHYSICAL = 1 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.4), true)

		-- Try to pin !
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 붙잡히지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상에게 %d%% 피해를 주고, 공격이 성공하면 대상을 %d 턴 동안 속박하여 움직이지 못하게 합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.4), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Blinding Ink",
	kr_name = "먹물 발사",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 12,
	cooldown = 12,
	message = "@Source1@ 먹물을 발사했습니다!",
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRadius(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	tactical = { DISABLE = { blind = 2 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLINDING_INK, t.getDuration(self, t))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[먹물을 발사하여, 대상을 %d 턴 동안 실명 상태로 만듭니다.]]):format(duration)
	end,
}

newTalent{
	name = "Spit Poison",
	kr_name = "독 뱉기",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	getDamage = function(self, t)
		return self:combatScale(math.max(self:getStr(), self:getDex())*self:getTalentLevel(t), 20, 0, 420, 500)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local s = math.max(self:getDex(), self:getStr())
		self:project(tg, x, y, DamageType.POISON, t.getDamage(self,t), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 독을 뱉어, 6 턴 동안 총 %0.2f 독 피해를 줍니다.
		피해량은 힘과 민첩 중 더 높은 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.POISON, t.getDamage(self,t)))
	end,
}

newTalent{
	name = "Spit Blight",
	kr_name = "병균 뱉기",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = { BLIGHT = 2 } },
	getDamage = function(self, t)
		return self:combatScale(self:getMag()*self:getTalentLevel(t), 20, 0, 420, 500)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLIGHT, t.getDamage(self,t), {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[병균 덩어리를 뱉어 대상에게 %0.2f 황폐화 피해를 줍니다.
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):format(t.getDamage(self,t))
	end,
}

newTalent{
	name = "Rushing Claws",
	kr_name = "갈고리 돌진",
	type = {"wild-gift/other", 1},
	message = "@Source1@ 돌진하여, 갈고리를 휘두릅니다!",
	points = 5,
	equilibrium = 10,
	cooldown = 15,
	tactical = { DISABLE = 2, CLOSEIN = 3 },
	requires_target = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "현재 그 행동을 할 수 없습니다.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

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

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 and target:canBe("pin") then
			target:setEffect(target.EFF_PINNED, 5, {})
		end

		return true
	end,
	info = function(self, t)
		return ([[엄청난 속도로 대상에게 달려듭니다. 접근이 성공하면, 갈고리로 대상을 5 턴 동안 땅에 고정시킵니다.
		돌진을 위해서는 적어도 2 칸 이상 떨어져 있어야 합니다.]])
	end,
}

newTalent{
	name = "Throw Bones",
	kr_name = "해골 던지기",
	type = {"undead/other", 1},
	points = 5,
	cooldown = 6,
	range = 10,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatScale(self:getStr()*self:getTalentLevel(t), 20, 0, 420, 500) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLEED, t.getDamage(self, t), {type="archery"})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 해골을 던져 출혈 상태로 만들고, %0.2f 물리 피해를 줍니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Lay Web",
	kr_name = "거미줄 치기",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	message = "@Source1@ 거미줄을 칠 적당한 공간을 찾습니다...",
	range = 10,
	requires_target = true,
	tactical = { DISABLE = { stun = 1, pin = 1 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local dur = t.getDuration(self,t)
		local trap = mod.class.Trap.new{
			type = "web", subtype="web", id_by_type=true, unided_name = "sticky web",
			display = '^', color=colors.YELLOW, image = "trap/trap_spiderweb_01_64.png",
			name = "sticky web", auto_id = true,
			kr_name = "끈적이는 거미줄", kr_unided_name = "끈적이는 거미줄",
			detect_power = 6 * self:getTalentLevel(t), disarm_power = 10 * self:getTalentLevel(t), --Trap Params
			level_range = {self.level, self.level},
			message = "@Target1@ 거미줄에 걸렸습니다!",
			pin_dur = dur,
			temporary = dur * 5,
			summoner = self,
			faction = false,
			canAct = false,
			energy = {value=0},
			x=self.x,
			y=self.y,
			canTrigger = function(self, x, y, who)
				if who.type == "spiderkin" then return false end
				return mod.class.Trap.canTrigger(self, x, y, who)
			end,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then
						game.level.map:remove(self.x, self.y, engine.Map.TRAP)
					end
					game.level:removeEntity(self)
				end
			end,
			triggered = function(self, x, y, who)
				if who:canBe("stun") and who:canBe("pin") then
					who:setEffect(who.EFF_PINNED, self.pin_dur, {apply_power=self.disarm_power + 5})
				else
					game.logSeen(who, "%s 저항했습니다!", (who.kr_name or who.name):capitalize():addJosa("가"))
				end
				return true, true
			end
		}
		game.level:addEntity(trap)
		game.zone:addEntity(game.level, trap, "trap", self.x, self.y)
		trap:setKnown(self, true)
		return true
	end,
	info = function(self, t)
		return ([[발 밑에 숨겨진 거미줄을 만들어, 거미류 이외의 종족을 %d 턴 동안 거미줄에 걸리게 합니다.]]):
		format(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Darkness",
	kr_name = "어둠",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.7, 5.3)) end,
	direct_hit = true,
	tactical = { DISABLE = 3 },
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	darkPower = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local g = engine.Entity.new{name="darkness", show_tooltip=true, block_sight=true, always_remember=false, unlit=t.darkPower(self, t)}
			game.level.map(px, py, Map.TERRAIN+1, g)
			game.level.map.remembers(px, py, false)
			game.level.map.lites(px, py, false)
		end, nil, {type="dark"})
		self:teleportRandom(self.x, self.y, 5)
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[반경 %d 칸 영역에 어둠을 만들어 (세기 %d) 거의 모든 빛을 차단하고, 단거리 순간이동을 합니다.]]):
		format(self:getTalentRadius(t), t.darkPower(self, t)) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Throw Boulder",
	kr_name = "바위 던지기",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 3,
	range = 10,
	radius = 1,
	direct_hit = true,
	tactical = { DISABLE = { knockback = 3 }, ATTACK = {PHYSICAL = 2 }, ESCAPE = { knockback = 2 } },
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	getDam = function(self, t) return self:combatScale(self:getStr() * self:getTalentLevel(t), 12, 0, 262, 500) end,
	getDist = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dist=t.getDist(self, t), dam=self:mindCrit(t.getDam(self, t))}, {type="archery"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 거대한 바위를 던져, %0.2f 피해를 주고 뒤로 %d 칸 밀어냅니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.PHYSICAL, t.getDam(self, t)), t.getDist(self, t))
	end,
}

newTalent{
	name = "Howl",
	kr_name = "울부짖음",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 10,
	message = "@Source1@ 울부짖습니다.",
	range = 10,
	tactical = { ATTACK = 3 },
	direct_hit = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		local rad = self:getTalentRadius(t)
		for i = self.x - rad, self.x + rad do for j = self.y - rad, self.y + rad do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and not actor.player then
				if self:reactionToward(actor) >= 0 then
					local tx, ty, a = self:getTarget()
					if a then
						actor:setTarget(a)
					end
				else
					actor:setTarget(self)
				end
			end
		end end end
		return true
	end,
	info = function(self, t)
		return ([[울부짖어 %d 칸 반경의 동료들을 부릅니다.]]):
		format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Shriek",
	kr_name = "비명",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 10,
	message = "@Source1@ 비명을 지릅니다.",
	range = 10,
	direct_hit = true,
	tactical = { ATTACK = 3 },
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	action = function(self, t)
		local rad = self:getTalentRadius(t)
		for i = self.x - rad, self.x + rad do for j = self.y - rad, self.y + rad do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and not actor.player then
				if self:reactionToward(actor) >= 0 then
					local tx, ty, a = self:getTarget()
					if a then
						actor:setTarget(a)
					end
				else
					actor:setTarget(self)
				end
			end
		end end end
		return true
	end,
	info = function(self, t)
		return ([[비명을 질러 %d 칸 반경의 동료들을 부릅니다.]]):
		format(self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Crush",
	kr_name = "분쇄",
	type = {"technique/other", 1},
	require = techs_req1,
	points = 5,
	cooldown = 6,
	stamina = 12,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { stun = 2 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local weapon = self:hasTwoHandedWeapon()
		if not weapon then
			game.logPlayer(self, "양손 무기 없이는 분쇄 기술을 사용할 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, self:combatTalentWeaponDamage(t, 1, 1.4))

		-- Try to pin !
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 분쇄를 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상의 다리를 공격하여 %d%% 무기 피해를 줍니다. 공격이 성공하면, 대상은 %d 턴 동안 움직일 수 없게 됩니다.]]):
		format(100 * self:combatTalentWeaponDamage(t, 1, 1.4), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Silence",
	kr_name = "침묵",
	type = {"psionic/other", 1},
	points = 5,
	cooldown = 10,
	psi = 5,
	range = 7,
	direct_hit = true,
	requires_target = true,
	tactical = { DISABLE = { silence = 3 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SILENCE, {dur=t.getDuration(self, t)}, {type="mind"})
		return true
	end,
	info = function(self, t)
		return ([[염력을 이용하여, 대상을 %d 턴 동안 침묵시킵니다.]]):
		format(t.getDuration(self, t))
	end,
}

newTalent{
	name = "Telekinetic Blast",
	kr_name = "염동 탄환",
	type = {"wild-gift/other", 1},
	points = 5,
	cooldown = 2,
	equilibrium = 5,
	range = 7,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	tactical = { ATTACK = { MIND = 2 }, ESCAPE = { knockback = 2 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(self:combatTalentMindDamage(t, 10, 170)), {type="mind"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[염동력으로 탄환을 만들어, %0.2f 물리 피해를 주고 대상을 밀어냅니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(self:combatTalentMindDamage(t, 10, 170))
	end,
}

newTalent{
	name = "Blightzone",
	kr_name = "황폐화 지역",
	type = {"corruption/other", 1},
	points = 5,
	cooldown = 13,
	vim = 27,
	range = 10,
	radius = 4,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACKAREA = { BLIGHT = 2 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local dam = self:combatTalentSpellDamage(t, 4, 65)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.BLIGHT, dam,
			self:getTalentRadius(t),
			5, nil,
			{type="blightzone"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 오염된 증기가 뿜어져나와 (반경 4), 주변에 %0.2f 황폐 속성 피해를 매 턴마다 줍니다. (지속시간 : %d 턴)
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, engine.DamageType.BLIGHT, self:combatTalentSpellDamage(t, 5, 65)), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Invoke Tentacle",
	kr_name = "촉수 소환",
	type = {"wild-gift/other", 1},
	cooldown = 1,
	range = 10,
	direct_hit = true,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t, nolock=true}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty then return nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 3, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		-- Find an actor with that filter
		local list = mod.class.NPC:loadList("/data/general/npcs/horror.lua")
		local m = list.GRGGLCK_TENTACLE:clone()
		if m then
			m.exp_worth = 0
			m:resolve()
			m:resolve(nil, true)

			m.summoner = self
			m.summon_time = 10
			if not self.is_grgglck then
				m.ai_real = m.ai
				m.ai = "summoned"
			end

			game.zone:addEntity(game.level, m, "actor", x, y)

			game.logSeen(self, "%s 촉수를 뻗습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		end

		return true
	end,
	info = function(self, t)
		return ([[희생자에게 자신의 촉수를 소환합니다.]])
	end,
}

newTalent{
	name = "Explode",
	kr_name = "폭발",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 폭발했습니다! @Target1@ 밝은 빛에 삼켜졌습니다!",
	cooldown = 1,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { LIGHT = 1 } },
	getDamage = function(self, t) return self:combatScale(self:combatSpellpower() * self:getTalentLevel(t), 0, 0, 66.25 , 265, 0.67) end,
	action = function(self, t)
		local tg = {type="bolt", range=1}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:project(tg, x, y, DamageType.LIGHT, t.getDamage(self, t), {type="light"})
		game.level.map:particleEmitter(self.x, self.y, 1, "ball_fire", {radius = 1, r = 1, g = 0, b = 0})
		self:die(self)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[시전자를 폭발시켜 (시전자는 사망합니다), 강렬한 빛을 뿜어내 %d 피해를 줍니다.]]): 
		format(damDesc(self, DamageType.LIGHT, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Will o' the Wisp Explode",
	kr_name = "윌 오 위습 폭발",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 폭발했습니다! @Target1@ 냉기에 휩싸입니다!",
	cooldown = 1,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { COLD = 1 } },
	action = function(self, t)
		local tg = {type="bolt", range=1}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:project(tg, x, y, DamageType.COLD, self.will_o_wisp_dam or 1)
		game.level.map:particleEmitter(self.x, self.y, 1, "ball_ice", {radius = 1, r = 1, g = 0, b = 0})
		self:die(self)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[폭발합니다.]])
	end,
}

newTalent{
	name = "Elemental bolt",
	kr_name = "원소의 탄환",
	type = {"spell/other", 1},
	points = 5,
	mana = 10,
	message = "@Source1@ 원소의 탄환을 사용합니다!",
	cooldown = 3,
	range = 10,
	proj_speed = 2,
	requires_target = true,
	tactical = { ATTACK = 2 },
	getDamage = function(self, t) return self:combatScale(self:getMag() * self:getTalentLevel(t), 0, 0, 450, 500) end,
	action = function(self, t)
		local tg = {type = "bolt", range = 20, talent = t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
			local elem = rng.table{
				{DamageType.ACID, "acid"},
				{DamageType.FIRE, "flame"},
				{DamageType.COLD, "freeze"},
				{DamageType.LIGHTNING, "lightning_explosion"},
				{DamageType.NATURE, "slime"},
				{DamageType.BLIGHT, "blood"},
				{DamageType.LIGHT, "light"},
				{DamageType.ARCANE, "manathrust"},
				{DamageType.DARKNESS, "dark"},
			}
		tg.display={particle="bolt_elemental", trail="generictrail"}
		self:projectile(tg, x, y, elem[1], t.getDamage(self, t), {type=elem[2]})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[무작위한 속성을 지녔으며, 느리게 날아가는 마법 탄환을 발사하여 %d 피해를 줍니다. 피해량은 마법 능력치의 영향을 받아 증가합니다.]]):
		format(t.getDamage(self, t))
	end,
}

newTalent{
	name = "Volcano",
	kr_name = "화산",
	type = {"spell/other", 1},
	points = 5,
	mana = 10,
	message = "화산이 폭발합니다!",
	cooldown = 20,
	range = 10,
	proj_speed = 2,
	requires_target = true,
	tactical = { ATTACK = { FIRE = 1, PHYSICAL = 1 } },
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	nbProj = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 80) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe:attr("temporary") then return end

		local e = Object.new{
			old_feat = oe,
			type = oe.type, subtype = oe.subtype,
			name = "raging volcano", image = oe.image, add_mos = {{image = "terrain/lava/volcano_01.png"}},
			kr_name = "격렬한 화산",
			display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
			always_remember = true,
			temporary = t.getDuration(self, t),
			x = x, y = y,
			canAct = false,
			nb_projs = t.nbProj(self, t),
			dam = t.getDamage(self, t),
			act = function(self)
				local tgts = {}
				local grids = core.fov.circle_grids(self.x, self.y, 5, true)
				for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
					local a = game.level.map(x, y, engine.Map.ACTOR)
					if a and self.summoner:reactionToward(a) < 0 then tgts[#tgts+1] = a end
				end end

				-- Randomly take targets
				local tg = {type="bolt", range=5, x=self.x, y=self.y, talent=self.summoner:getTalentFromId(self.summoner.T_VOLCANO), display={image="object/lava_boulder.png"}}
				for i = 1, self.nb_projs do
					if #tgts <= 0 then break end
					local a, id = rng.table(tgts)
					table.remove(tgts, id)

					self.summoner:projectile(tg, a.x, a.y, engine.DamageType.MOLTENROCK, self.dam, {type="flame"})
					game:playSoundNear(self, "talents/fire")
				end

				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self)
					game.level.map:updateMap(self.x, self.y)
					game.nicer_tiles:updateAround(game.level, self.x, self.y)
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[%d 턴 동안 작은 화산을 소환합니다. 매 턴마다 적에게 용암 덩어리를 %d 개 분출하여, %0.2f 화염 피해와 %0.2f 물리 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(t.getDuration(self, t), t.nbProj(self, t), damDesc(self, DamageType.FIRE, dam/2), damDesc(self, DamageType.PHYSICAL, dam/2))
	end,
}

newTalent{
	name = "Speed Sap",
	kr_name = "속도 훔치기",
	type = {"chronomancy/other", 1},
	points = 5,
	paradox = 10,
	cooldown = 8,
	tactical = {
		ATTACK = { TEMPORAL = 10 },
		DISABLE = 10,
	},
	range = 3,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.WASTING, self:spellCrit(t.getDamage(self, t)))
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SLOW, 3, {power=0.3})
			self:setEffect(self.EFF_SPEED, 3, {power=0.3})
		end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[대상의 속도를 3 턴 동안 30%% 훔쳐오며, %d 시간 피해를 줍니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

newTalent{
	name = "Dredge Frenzy",
	kr_name = "드렛지의 광란",
	type = {"chronomancy/other", 1},
	points = 5,
	cooldown = 12,
	tactical = {
		BUFF = 4,
	},
	direct_hit = true,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=true, talent=t}
	end,
	getPower = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 10, 50), 1, 0, 0, 0.329, 32.9) end, -- Limit < 100
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			local reapplied = false
			if target then
				local actor_frenzy = false
				if target.dredge then
					actor_frenzy = true
				end
				if actor_frenzy then
					-- silence the apply message if the target already has the effect
					for eff_id, p in pairs(target.tmp) do
						local e = target.tempeffect_def[eff_id]
						if e.name == "Frenzy" then
							reapplied = true
						end
					end
					target:setEffect(target.EFF_FRENZY, t.getDuration(self, t), {crit = t.getPower(self, t)*100, power=t.getPower(self, t), dieat=t.getPower(self, t)}, reapplied)
				end
			end
		end)

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_light", {radius=tg.radius})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		local range = t.radius(self,t)
		local power = t.getPower(self,t) * 100
		return ([[주변 %d 칸 범위 안에 있는 드렛지를 %d 턴 동안 광란 상태로 만듭니다.
		광란 상태에 빠지면 전체 속도가 %d%% / 물리 치명타율이 %d%% 상승하며, 생명력이 -%d%% 이하로 떨어지기 전까지는 죽지 않게 됩니다.]]): 
		format(range, t.getDuration(self, t), power, power, power)
	end,
}

newTalent{
	name = "Sever Lifeline",
	kr_name = "생명선 절단",
	type = {"chronomancy/other", 1},
	points = 5,
	paradox = 1,
	cooldown = 20,
	tactical = {
		ATTACK = 1000,
	},
	range = 10,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220) * 10000 *getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		target:setEffect(target.EFF_SEVER_LIFELINE, 4, {src=self, power=t.getDamage(self, t)})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[대상의 생명선을 자르기 시작합니다. 대상이 4 턴 동안 시야에서 벗어나지 못하면, 대상은 죽습니다.]])
	end,
}

newTalent{
	name = "Call of Amakthel",
	kr_name = "아마크텔의 부름",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 2,
	tactical = { DISABLE = 2 },
	range = 0,
	radius = function(self, t)
		return 10
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tgts = {}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			if self:reactionToward(target) < 0 and not tgts[target] then
				tgts[target] = true
				local ox, oy = target.x, target.y
				target:pull(self.x, self.y, 1)
				if target.x ~= ox or target.y ~= oy then game.logSeen(target, "%s 끌려옵니다!", (target.kr_name or target.name):capitalize():addJosa("가")) end
			end
		end)
		return true
	end,
	info = function(self, t)
		return ([[모든 적들을 끌어당깁니다.]])
	end,
}

newTalent{
	name = "Gift of Amakthel",
	kr_name = "아마크텔의 선물",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	tactical = { ATTACK = 2 },
	range = 10,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self.x, self.y
		if not tx or not ty then return nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 3, true, {[Map.ACTOR]=true})
		if not x then	
			game.logPlayer(self, "불러낼 공간이 없습니다!")
			return
		end

		-- Find an actor with that filter
		local m = game.zone:makeEntityByName(game.level, "actor", "SLIMY_CRAWLER")
		if m then
			m.exp_worth = 0
			m.summoner = self
			m.summon_time = 10
			game.zone:addEntity(game.level, m, "actor", x, y)
			local target = game.level.map(tx, ty, Map.ACTOR)
			m:setTarget(target)

			game.logSeen(self, "%s 끈적이며, 기어다니는 존재를 불러냅니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		end

		return true
	end,
	info = function(self, t)
		return ([[끈적이며, 기어다니는 존재를 불러냅니다.]])
	end,
}

newTalent{
	short_name = "STRIKE",
	name = "Strike",
	kr_name = "암석 타격",
	type = {"spell/other", 1},
	points = 5,
	random_ego = "attack",
	mana = 18,
	cooldown = 6,
	tactical = {
		ATTACK = { PHYSICAL = 1 },
		DISABLE = { knockback = 2 },
		ESCAPE = { knockback = 2 },
	},
	range = 10,
	reflectable = true,
	proj_speed = 6,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 8, 230) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_earth", trail="earthtrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.SPELLKNOCKBACK, self:spellCrit(t.getDamage(self, t)))
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[암석의 주먹을 발사하여, %0.2f 물리 피해를 주고 대상을 뒤로 밀어냅니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Corrosive Vapour",
	kr_name = "산성 증기",
	type = {"spell/other",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 20,
	cooldown = 8,
	tactical = { ATTACKAREA = { ACID = 2 } },
	range = 8,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 4, 50) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.ACID, t.getDamage(self, t),
			self:getTalentRadius(t),
			5, nil,
			{type="vapour"},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[땅에서 산성 증기가 뿜어져나와, 주변 3 칸 반경에 %d 턴 동안 %0.2f 산성 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(duration, damDesc(self, DamageType.ACID, damage)) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Manaflow",
	kr_name = "마나의 흐름",
	type = {"spell/other", 1},
	points = 5,
	mana = 0,
	cooldown = 25,
	tactical = { MANA = 3 },
	getManaRestoration = function(self, t) return 5 + self:combatTalentSpellDamage(t, 10, 20) end,
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_MANASURGE) end,
	action = function(self, t)
		self:setEffect(self.EFF_MANASURGE, 10, {power=t.getManaRestoration(self, t)})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local restoration = t.getManaRestoration(self, t)
		return ([[마나의 흐름에 몸을 맡겨, 10 턴 동안 매 턴마다 %d 마나를 회복합니다.
		마나 회복량은 주문력의 영향을 받아 증가합니다.]]):
		format(restoration)
	end,
}
newTalent{
	name = "Infernal Breath", image = "talents/flame_of_urh_rok.png",
	kr_name = "지옥의 호흡",
	type = {"spell/other",1},
	random_ego = "attack",
	cooldown = 20,
	tactical = { ATTACK = { FIRE = 1 }, HEAL = 1, },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DEMONFIRE, self:spellCrit(self:combatTalentStatDamage(t, "str", 30, 350)))

		game.level.map:addEffect(self,
				self.x, self.y, 4,
				DamageType.DEMONFIRE, self:spellCrit(self:combatTalentStatDamage(t, "str", 30, 70)),
				tg.radius,
				{delta_x=x-self.x, delta_y=y-self.y}, 55,
				{type="dark_inferno"},
				nil, true
		)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breathe")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[전방 %d 칸 반경에 암흑의 파동을 뿜어내, 악마가 아닌 적들에게 %0.2f 화염 피해를 주고 매 턴마다 %0.2f 화염 피해를 추가로 줍니다.
		악마에게 사용할 경우 피해량만큼 생명력을 회복하며, 피해량은 힘 능력치의 영향을 받아 증가합니다.]]):
		format(radius, damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 350)), damDesc(self, DamageType.FIRE, self:combatTalentStatDamage(t, "str", 30, 70)))
	end,
}

newTalent{
	name = "Frost Hands", image = "talents/shock_hands.png",
	kr_name = "얼어붙은 손",
	type = {"spell/other", 3},
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 40,
	tactical = { BUFF = 2 },
	getIceDamage = function(self, t) return self:combatTalentSpellDamage(t, 3, 20) end,
	getIceDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 5, 14) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")
		return {
			dam = self:addTemporaryValue("melee_project", {[DamageType.ICE] = t.getIceDamage(self, t)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.COLD] = t.getIceDamageIncrease(self, t)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		return true
	end,
	info = function(self, t)
		local icedamage = t.getIceDamage(self, t)
		local icedamageinc = t.getIceDamageIncrease(self, t)
		return ([[손과 무기를 냉기로 감싸 매 타격마다 %d 냉기 피해를 주고, 적에게 주는 냉기 피해량을 %d%% 증가시킵니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD, icedamage), icedamageinc, self:getTalentLevel(t) / 3)
	end,
}

newTalent{
	name = "Meteor Rain",
	kr_name = "유성우",
	type = {"spell/other", 3},
	points = 5,
	cooldown = 30,
	mana = 70,
	tactical = { ATTACKAREA = { FIRE=2, PHYSICAL=2 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 250) end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 3.3, 4.8, "log")) end,
	radius = 2,
	range = 5,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local terrains = t.terrains or mod.class.Grid:loadList("/data/general/grids/lava.lua")
		t.terrains = terrains -- cache

		local meteor = function(src, x, y, dam)
			game.level.map:particleEmitter(x, y, 10, "meteor", {x=x, y=y}).on_remove = function(self)
				local x, y = self.args.x, self.args.y
				game.level.map:particleEmitter(x, y, 10, "fireflash", {radius=2})
				game:playSoundNear(game.player, "talents/fireflash")

				local grids = {}
				for i = x-1, x+1 do for j = y-1, y+1 do
					local oe = game.level.map(i, j, Map.TERRAIN)
					if oe and not oe:attr("temporary") and
					(core.fov.distance(x, y, i, j) < 1 or rng.percent(40)) and (game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "dig") or game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "grow")) then
						local g = terrains.LAVA_FLOOR:clone()
						g:resolve() g:resolve(nil, true)
						game.zone:addEntity(game.level, g, "terrain", i, j)
						grids[#grids+1] = {x=i,y=j,oe=oe}
					end
				end end
				for i = x-1, x+1 do for j = y-1, y+1 do
					game.nicer_tiles:updateAround(game.level, i, j)
				end end
				for _, spot in ipairs(grids) do
					local i, j = spot.x, spot.y
					local g = game.level.map(i, j, Map.TERRAIN)
					g.temporary = 8
					g.x = i g.y = j
					g.canAct = false
					g.energy = { value = 0, mod = 1 }
					g.old_feat = spot.oe
					g.useEnergy = mod.class.Trap.useEnergy
					g.act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
							game.level:removeEntity(self)
							game.nicer_tiles:updateAround(game.level, self.x, self.y)
						end
					end
					game.level:addEntity(g)
				end

				src:project({type="ball", radius=2, selffire=false}, x, y, engine.DamageType.FIRE, dam/2)
				src:project({type="ball", radius=2, selffire=false}, x, y, engine.DamageType.PHYSICAL, dam/2)
				if core.shader.allow("distort") then game.level.map:particleEmitter(x, y, 2, "shockwave", {radius=2}) end
				game:getPlayer(true):attr("meteoric_crash", 1)
			end
		end

		local grids = {}
		self:project(tg, x, y, function(px, py) grids[#grids+1] = {x=px, y=py} end)

		for i = 1, t.getNb(self, t) do
			local g = rng.tableRemove(grids)
			if not g then break end
			meteor(self, g.x, g.y, t.getDamage(self, t))
		end

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[마법의 힘으로 운석을 %d 개 소환하여 지면과 충돌시킵니다. 주변 2 칸 반경에 %0.2f 화염 피해와 %0.2f 물리 피해를 줍니다.
		그리고, 운석이 떨어진 곳은 8 턴 동안 용암 지역이 됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(t.getNb(self, t), damDesc(self, DamageType.FIRE, dam), damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

newTalent{
	name = "Heal", short_name = "HEAL_NATURE", image = "talents/heal.png",
	kr_name = "치료",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 10,
	cooldown = 16,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentMindDamage(t, 10, 520) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:mindCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[자연의 힘을 이용하여, %d 생명력을 회복합니다.
		생명력 회복량은 정신력의 영향을 받아 증가합니다.]]):
		format(heal)
	end,
}

newTalent{
	name = "Call Lightning", image = "talents/lightning.png",
	kr_name = "번개 소환",
	type = {"wild-gift/other", 1},
	points = 5,
	equi = 4,
	cooldown = 3,
	tactical = { ATTACK = 2 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 350) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[적들을 관통하는 강력한 번개를 불러내, %0.2f - %0.2f 피해를 줍니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 3),
		damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

newTalent{
	short_name = "KEEPSAKE_FADE",
	name = "Fade",
	kr_name = "흐려짐",
	type = {"undead/keepsake",1},
	points = 5,
	cooldown = function(self, t)
		return math.max(3, 8 - self:getTalentLevelRaw(t))
	end,
	action = function(self, t)
		self:setEffect(self.EFF_FADED, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[자신의 존재를 지워, 자신의 다음 턴이 올 때까지 무적 상태가 됩니다.]])
	end,
}

newTalent{
	short_name = "KEEPSAKE_PHASE_DOOR",
	name = "Phase Door",
	kr_name = "근거리 순간이동",
	type = {"undead/keepsake",1},
	points = 5,
	range = 10,
	tactical = { ESCAPE = 2 },
	is_teleport = true,
	action = function(self, t)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
		self:teleportRandom(self.x, self.y, self:getTalentRange(t))
		game.level.map:particleEmitter(x, y, 1, "teleport_in")
		return true
	end,
	info = function(self, t)
		return ([[짧은 거리를 순간이동합니다.]])
	end,
}

newTalent{
	short_name = "KEEPSAKE_BLINDSIDE",
	name = "Blindside",
	kr_name = "맹점",
	type = {"undead/keepsake", 1},
	points = 5,
	random_ego = "attack",
	range = 10,
	requires_target = true,
	tactical = { CLOSEIN = 2 },
	action = function(self, t)
		local tg = {type="hit", pass_terrain = true, range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end

		local start = rng.range(0, 8)
		for i = start, start + 8 do
			local x = target.x + (i % 3) - 1
			local y = target.y + math.floor((i % 9) / 3) - 1
			if game.level.map:isBound(x, y)
					and self:canMove(x, y)
					and not game.level.map.attrs(x, y, "no_teleport") then
				game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
				self:move(x, y, true)
				game.level.map:particleEmitter(x, y, 1, "teleport_in")
				local multiplier = self:combatTalentWeaponDamage(t, 0.9, 1.9)
				self:attackTarget(target, nil, multiplier, true)
				return true
			end
		end

		return false
	end,
	info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 1.1, 1.9)
		return ([[대상에게 보이지 않을 정도의 속도로 최대 %d 칸 돌진하여, %d%% 피해를 줍니다.]]):format(self:getTalentRange(t), multiplier)
	end,
}

newTalent{
	name = "Suspended", image = "talents/arcane_feed.png",
	kr_name = "대기",
	type = {"other/other", 1},
	points = 1,
	mode = "sustained",
	cooldown = 10,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "invulnerable", 1)
		self:talentTemporaryValue(ret, "status_effect_immune", 1)
		self:talentTemporaryValue(ret, "dazed", 1)
		return ret
	end,
	deactivate = function(self, t, p)
		game.logSeen("#VIOLET#%s 대기 상태에서 벗어났습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		return true
	end,
	info = function(self, t)
		return ([[공격받기 전까지 어떤 반응도 할 수 없게 됩니다.]])
	end,
}

newTalent{ 
	name = "Frost Grab",
	kr_name = "얼어붙은 손",
	type = {"spell/other", 1},
	points = 5,
	mana = 19,
	cooldown = 8,
	range = 10,
	tactical = { DISABLE = 1, CLOSEIN = 3 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 5, 140))

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			target:pull(self.x, self.y, tg.range)

			DamageType:get(DamageType.COLD).projector(self, target.x, target.y, DamageType.COLD, dam)
			target:setEffect(target.EFF_SLOW_MOVE, t.getDuration(self, t), {apply_power=self:combatSpellpower(), power=0.5})
		end)
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		return ([[대상을 붙잡아 %0.2f 냉기 피해를 주고, 자신 쪽으로 이동시킵니다. 대상은 얼어붙어, 이동 속도가 %d 턴 동안 50%% 감소하게 됩니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.COLD, self:combatTalentSpellDamage(t, 5, 140)), t.getDuration(self, t)) --@ 변수 순서 조정
	end,
}



newTalent{
	name = "Body Shot",
	kr_name = "몸통 치기",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 10,
	stamina = 10,
	message = "@Source1@ 마무리로 몸통을 가격했습니다.",
	tactical = { ATTACK = { weapon = 2 }, DISABLE = { stun = 2 } },
	requires_target = true,
	--on_pre_use = function(self, t, silent) if not self:hasEffect(self.EFF_COMBO) then if not silent then game.logPlayer(self, "You must have a combo going to use this ability.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.8) + getStrikingStyle(self, dam) end,
	getDuration = function(self, t, comb) return math.ceil(self:combatTalentScale(t, 1, 5) * (0.25 + comb/5)) end,
	getDrain = function(self, t) return self:combatTalentScale(t, 2, 10, 0.75) * self:getCombo(combo) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- breaks active grapples if the target is not grappled
		if not target:isGrappled(self) then
			self:breakGrapples()
		end

		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hit then
			-- try to daze
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, t.getDuration(self, t, self:getCombo(combo)), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 혼절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end

			target:incStamina(- t.getDrain(self, t))

		end

		self:clearCombo()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local drain = self:getTalentLevel(t) * 2
		local daze = t.getDuration(self, t, 0)
		local dazemax = t.getDuration(self, t, 5)
		return ([[대상의 몸통을 가격하여 %d%% 의 피해를 주고, 연계 점수당 대상의 체력을 %d 씩 소진시키며, 연계 점수에 따라 대상을 %d 에서 %d 턴 동안 혼절시킵니다.
		혼절 확률은 물리력의 영향을 받아 증가합니다.
		이 기술은 마무리 기술이기 때문에, 사용하면 연계 점수가 초기화됩니다.]])
		:format(damage, drain, daze, dazemax)
	end,
}

newTalent{
	name = "Relentless Strikes",
	kr_name = "가차없는 공격",
	type = {"technique/other", 1},
	points = 5,
	mode = "passive",
	getStamina = function(self, t) return self:combatTalentScale(t, 1/4, 5/4, 0.75) end,
	getCooldownReduction = function(self, t) return self:combatTalentLimit(t, 0.67, 0.09, 1/3) end,  -- Limit < 67%
	info = function(self, t)
		local stamina = t.getStamina(self, t)
		local cooldown = t.getCooldownReduction(self, t)
		return ([[모든 타격계 기술의 지연 시간을 %d%% 줄입니다. 그리고, 연계 점수를 1 획득할 때마다 체력을 %0.2f 회복할 수 있게 됩니다.
		만약 현재 체력이 부족해 어떤 기술을 사용할 수 없더라도, 이 기술을 통해 어떤 기술을 사용할 수 있을만큼 체력을 확보할 수 있다면 그 기술을 사용할 수 있습니다.]])
		:format(cooldown * 100, stamina)
	end,
}

newTalent{
	name = "Combo String",
	kr_name = "연계 강화",
	type = {"technique/other", 1},
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 0.3, 2.3)) end,
	getChance = function(self, t) return self:combatLimit(self:getTalentLevel(t) * (5 + self:getCun(5, true)), 100, 0, 0, 50, 50) end, -- Limit < 100%
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[연계 점수를 획득할 때마다, %d%% 확률로 1 의 연계 점수를 추가로 획득합니다. 그리고, 연계 점수의 지속 시간이 %d 턴 늘어납니다.
		연계 점수를 추가로 획득할 확률은 교활함 능력치의 영향을 받아 증가합니다.]]):
		format(chance, duration)
	end,
}

newTalent{
	name = "Steady Mind",
	kr_name = "평정심",
	type = {"technique/other", 1},
	mode = "passive",
	points = 5,
	getDefense = function(self, t) return self:combatTalentStatDamage(t, "dex", 5, 35) end,
	getMental = function(self, t) return self:combatTalentStatDamage(t, "cun", 5, 35) end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local saves = t.getMental(self, t)
		return ([[정신적 수양을 통해 평정심을 갖게 되었습니다. 적들의 물리적, 정신적 공격에 차분하게 대응하여 회피도가 %d / 정신 내성이 %d 상승합니다.
		회피도는 민첩 능력치, 정신 내성은 교활함 능력치의 영향을 받아 상승합니다.]]):
		format(defense, saves)
	end,
}

newTalent{
	name = "Maim",
	kr_name = "관절기",
	type = {"technique/other", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 10,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = 2 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
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
		return ([[대상을 붙잡아 %0.2f 의 물리 피해를 줍니다. 
		대상이 이미 붙잡힌 상태라면 대상에게 관절기를 걸어서, 대상의 공격력을 %d 감소시키고 전체 속도를 30%% 감소시키는 효과를 %d 턴 동안 유지시킵니다.
		붙잡기 효과는 다른 붙잡기 기술들의 영향을 받으며, 물리 피해량은 물리력의 영향을 받아 증가합니다.]])
		:format(damDesc(self, DamageType.PHYSICAL, (damage)), maim, duration)
	end,
}

newTalent{
	name = "Bloodrage",
	kr_name = "피의 분노",
	type = {"technique/other", 1},
	points = 5,
	mode = "passive",
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	on_kill = function(self, t)
		self:setEffect(self.EFF_BLOODRAGE, t.getDuration(self, t), {max=math.floor(self:getTalentLevel(t) * 6), inc=2})
	end,
	info = function(self, t)
		return ([[적의 머리통을 박살낼 때마다 힘이 솟구칩니다! 적을 죽일 때마다 힘이 2 씩 증가하며, %d 턴 동안 유지됩니다. 최대로 올릴 수 있는 힘은 %d 입니다.]]):
		format(math.floor(self:getTalentLevel(t) * 6), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Martyrdom",
	kr_name = "고난",
	type = {"spell/other", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 22,
	positive = 25,
	tactical = { DISABLE = 2 },
	range = 6,
	reflectable = true,
	requires_target = true,
	getReturnDamage = function(self, t) return self:combatLimit(self:getTalentLevel(t)^.5, 100, 15, 1, 40, 2.24) end, -- Limit <100%
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_MARTYRDOM, 10, {src = self, power=t.getReturnDamage(self, t), apply_power=self:combatSpellpower()})
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local returndamage = t.getReturnDamage(self, t)
		return ([[대상을 10 턴 동안 고난을 받을 자로 지정합니다. 대상이 남에게 피해를 줄 때마다, %d%% 만큼의 피해를 자신도 받게 됩니다.]]):
		format(returndamage)
	end,
}

newTalent{
	name = "Overpower",
	kr_name = "압도",
	type = {"technique/other", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	stamina = 22,
	requires_target = true,
	tactical = { ATTACK = 2, ESCAPE = { knockback = 1 }, DISABLE = { knockback = 1 } },
	on_pre_use = function(self, t, silent) if not self:hasShield() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 무기와 방패가 필요합니다.") end return false end return true end,
	action = function(self, t)
		local shield = self:hasShield()
		if not shield then
			game.logPlayer(self, "방패가 없으면 압도 기술을 사용할 수 없습니다!")
			return nil
		end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		-- First attack with weapon
		self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3), true)
		-- Second attack with shield
		self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
		-- Third attack with shield
		local speed, hit = self:attackTargetWith(target, shield.special_combat, nil, self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))

		-- Try to stun !
		if hit then
			if target:checkHit(self:combatAttack(shield.special_combat), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 4)
			else
				game.logSeen(target, "%s 밀려나지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("이"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 무기로 공격하여 %d%% 의 무기 피해를 주고, 방패로 두 번 밀어쳐 %d%% 의 방패 피해를 줍니다.
		마지막 공격이 적중하면, 대상은 압도되어 밀려납니다. 밀어내기 확률은 정확도 능력치의 영향을 받아 증가합니다.]])
		:format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.3), 100 * self:combatTalentWeaponDamage(t, 0.8, 1.3, self:getTalentLevel(self.T_SHIELD_EXPERTISE)))
	end,
}

newTalent{
	name = "Perfect Control",
	kr_name = "완벽한 조작",
	type = {"psionic/other", 1},
	cooldown = 50,
	psi = 15,
	points = 5,
	tactical = { BUFF = 2 },
	getBoost = function(self, t)
		return self:combatScale(self:getTalentLevel(t)*self:combatStatTalentIntervalDamage(t, "combatMindpower", 1, 9), 15, 0, 49, 34)
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 50, 6, 10)) end, -- Limit < 50
	action = function(self, t)
		self:setEffect(self.EFF_CONTROL, t.getDuration(self, t), {power= t.getBoost(self, t)})
		return true
	end,
	info = function(self, t)
		local boost = t.getBoost(self, t)
		local dur = t.getDuration(self, t)
		return ([[육체를 정신력으로 감싸, 신경과 근육을 통한 비효율적인 운동 방식을 제거하고 몸의 움직임을 극도로 효율적이게 만듭니다. 
		%d 턴 동안 정확도가 %d / 치명타율이 %0.1f%% 증가합니다.]]):
		format(dur, boost, 0.5*boost)
	end,
}

newTalent{
	name = "Mindhook",
	kr_name = "염동 갈고리",
	type = {"psionic/other", 1},
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 18, 10)) end, -- Limit to >5
	psi = 20,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		local r = self:combatTalentLimit(t, 10, 3, 7) -- Limit base range to 10
		local gem_level = getGemLevel(self)
		local mult = 1 + 0.005*gem_level*self:callTalent(self.T_REACH, "rangebonus") -- reduced effect of reach
		return math.floor(r*mult)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "대상이 사거리 밖에 있습니다.")
			return
		end
		target:pull(self.x, self.y, tg.range)
		target:setEffect(target.EFF_DAZED, 1, {})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[염력으로 대상을 붙잡아, 시전자가 있는 곳으로 끌어옵니다.
		%d 칸 이내에 있는 대상까지 끌어올 수 있으며, 기술 레벨이 증가할수록 재사용 대기시간이 줄어들고 최대 사거리가 늘어납니다.
		이 기술은 도달 기술을 통해서 받는 효과가 감소됩니다.]]):
		format(range)
	end,
}

newTalent{
	name = "Reach",
	kr_name = "도달",
	type = {"psionic/other", 1},
	mode = "passive",
	points = 5,
	rangebonus = function(self,t) return math.max(0, self:combatTalentScale(t, 3, 10)) end,
	info = function(self, t)
		return ""
	end,
}
