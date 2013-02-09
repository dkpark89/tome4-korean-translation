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
	kr_display_name = "자기복제",
	type = {"other/other", 1},
	cooldown = 3,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		if not self.can_multiply or self.can_multiply <= 0 then print("더 이상 복제 불가") return nil end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then print("공간 부족") return nil end

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
	kr_display_name = "독성 발톱",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 독성 발톱으로 @target2@ 할큅니다!",
	cooldown = 5,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self, t)
		return ([[독이 묻은 발톱으로 대상을 공격합니다.]])
	end,
}

newTalent{
	short_name = "CRAWL_ACID",
	name = "Acidic Crawl",
	kr_display_name = "산성 발톱",
	points = 5,
	type = {"technique/other", 1},
	message = "@Source1@ 산성 발톱으로 @target2@ 할큅니다!",
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
	kr_display_name = "실명 포자",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 실명 포자를 @target@에게 뿌립니다!",
	cooldown = 2,
	range = 1,
	tactical = { DISABLE = { blind = 2 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, DamageType.LIGHT, self:combatTalentWeaponDamage(t, 1, 1.8), true)

		-- Try to stun !
		if hit then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(5 + self:getTalentLevel(t)), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 실명되지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상에게 실명 포자를 뿌립니다.]])
	end,
}

newTalent{
	short_name = "SPORE_POISON",
	name = "Poisonous Spores",
	kr_display_name = "독성 포자",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 독성 포자를 @target@에게 뿌립니다!",
	cooldown = 2,
	range = 1,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self.combat_apr = self.combat_apr + 1000
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		self.combat_apr = self.combat_apr - 1000
		return true
	end,
	info = function(self, t)
		return ([[대상에게 독성 포자를 뿌립니다.]])
	end,
}

newTalent{
	name = "Stun",
	kr_display_name = "기절",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { stun = 2 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2 + self:getTalentLevel(t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상은 기절합니다. 기절 확률은 물리력의 영향을 받아 증가합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Disarm",
	kr_display_name = "무장 해제",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { disarm = 2 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		if hit and target:canBe("disarm") then
			target:setEffect(target.EFF_DISARMED, 2 + self:getTalentLevel(t), {apply_power=self:combatPhysicalpower()})
			target:crossTierEffect(target.EFF_DISARMED, self:combatPhysicalpower())
		else
			game.logSeen(target, "%s 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상의 무장이 해제됩니다. 무장 해제 확률은 물리력의 영향을 받아 증가합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Constrict",
	kr_display_name = "조르기",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { stun = 1 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to stun !
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_CONSTRICTED, (2 + self:getTalentLevel(t)) * 10, {src=self, power=1.5 * self:getTalentLevel(t), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 질식 상태가 되지  않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("는"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상을 질식시키기 시작합니다. 질식 상태의 위력은 물리력의 영향을 받아 증가합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Knockback",
	kr_display_name = "밀어내기",
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
				game.logSeen(target, "%s 밀려나지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
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
	kr_display_name = "독성 깨물기",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ @target2@ 깨물어 독을 흘려넣었습니다!",
	cooldown = 5,
	range = 1,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:attackTarget(target, DamageType.POISON, 2 + self:getTalentLevel(t), true)
		return true
	end,
	info = function(self, t)
		return ([[대상을 깨물어, 독을 주입합니다.]])
	end,
}

newTalent{
	name = "Summon",
	kr_display_name = "소환",
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

				m.summoner = self
				m.summon_time = filter.lastfor
				m.faction = self.faction

				game.zone:addEntity(game.level, m, "actor", x, y)

				game.logSeen(self, "%s %s 소환했습니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"), (m.kr_display_name or m.name):addJosa("를") )

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
	kr_display_name = "부패성 질병",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source1@ @target@에게 질병을 옮깁니다.",
	requires_target = true,
	tactical = { ATTACK = { BLIGHT = 2 }, DISABLE = { disease = 1 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:canBe("disease") then
				target:setEffect(target.EFF_ROTTING_DISEASE, 10 + self:getTalentLevel(t) * 3, {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, con=math.floor(4 + target:getCon() * 0.1), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 병에 걸리지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상은 질병에 걸립니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Decrepitude Disease",
	kr_display_name = "노화성 질병",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source1@ @target@에게 질병을 옮깁니다.",
	tactical = { ATTACK = { BLIGHT = 2 }, DISABLE = { disease = 1 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:canBe("disease") then
				target:setEffect(target.EFF_DECREPITUDE_DISEASE, 10 + self:getTalentLevel(t) * 3, {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, dex=math.floor(4 + target:getDex() * 0.1), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 병에 걸리지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상은 질병에 걸립니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Weakness Disease",
	kr_display_name = "약화성 질병",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 8,
	message = "@Source1@ @target@에게 질병을 옮깁니다.",
	requires_target = true,
	tactical = { ATTACK = { BLIGHT = 2 }, DISABLE = { disease = 1 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.5, 1), true)

		-- Try to rot !
		if hit then
			if target:canBe("disease") then
				target:setEffect(target.EFF_WEAKNESS_DISEASE, 10 + self:getTalentLevel(t) * 3, {src=self, dam=self:getStr() / 3 + self:getTalentLevel(t) * 2, str=math.floor(4 + target:getStr() * 0.1), apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 병에 걸리지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상을 공격하여 %d%% 피해를 줍니다. 공격이 명중하면, 대상은 질병에 걸립니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.5, 1))
	end,
}

newTalent{
	name = "Mind Disruption",
	kr_display_name = "정신 방해",
	type = {"spell/other", 1},
	points = 5,
	cooldown = 10,
	mana = 16,
	range = 10,
	direct_hit = true,
	requires_target = true,
	tactical = { DISABLE = { confusion = 3 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CONFUSION, {dur=2+self:getTalentLevel(t), dam=50+self:getTalentLevelRaw(t)*10}, {type="manathrust"})
		return true
	end,
	info = function(self, t)
		return ([[대상을 혼란 상태로 만듭니다.]])
	end,
}

newTalent{
	name = "Water Bolt",
	kr_display_name = "물줄기 화살",
	type = {"spell/other", },
	points = 5,
	mana = 10,
	cooldown = 3,
	range = 10,
	reflectable = true,
	tactical = { ATTACK = { COLD = 1 } },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.COLD, self:spellCrit(12 + self:combatSpellpower(0.25) * self:getTalentLevel(t)), {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 물줄기를 발사하여, %0.2f 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(12 + self:combatSpellpower(0.25) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Water Jet",
	kr_display_name = "물대포",
	type = {"spell/other", },
	points = 5,
	mana = 10,
	cooldown = 8,
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	tactical = { DISABLE = { stun = 2 }, ATTACK = { COLD = 1 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.COLDSTUN, self:spellCrit(12 + self:combatSpellpower(0.20) * self:getTalentLevel(t)), {type="freeze"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 강력한 물줄기를 발사하여, %0.2f 피해를 주고 4 턴 동안 기절시킵니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(12 + self:combatSpellpower(0.20) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Void Blast",
	kr_display_name = "공허의 돌풍",
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
	kr_display_name = "회복",
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
	getCureCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
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
		return ([[자연의 힘을 빌어, 독과 질병을 %d 만큼 회복합니다. (3 레벨 기준)]]):
		format(curecount)
	end,
}

newTalent{
	name = "Regeneration",
	kr_display_name = "재생",
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
	kr_display_name = "붙잡기",
	type = {"technique/other", 1},
	points = 5,
	cooldown = 6,
	stamina = 8,
	require = { stat = { str=12 }, },
	requires_target = true,
	tactical = { DISABLE = { pin = 2 }, ATTACK = { PHYSICAL = 1 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 0.8, 1.4), true)

		-- Try to stun !
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 1 + self:getTalentLevel(t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 붙잡히지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상에게 %d%% 피해를 주고, 공격이 성공하면 대상을 속박하여 움직이지 못하게 합니다.]]):format(100 * self:combatTalentWeaponDamage(t, 0.8, 1.4))
	end,
}

newTalent{
	name = "Blinding Ink",
	kr_display_name = "먹물 발사",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 12,
	cooldown = 12,
	message = "@Source1@ 먹물을 발사했습니다!",
	range = 0,
	radius = function(self, t)
		return 4 + self:getTalentLevelRaw(t)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRadius(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDuration = function(self, t)
		return 2 + self:getTalentLevelRaw(t)
	end,
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
	kr_display_name = "독 뱉기",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 1, poison = 1} },
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local s = math.max(self:getDex(), self:getStr())
		self:project(tg, x, y, DamageType.POISON, 20 + (s * self:getTalentLevel(t)) * 0.8, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local s = math.max(self:getDex(), self:getStr())
		return ([[대상에게 독을 뱉어, 6 턴 동안 총 %0.2f 독 피해를 줍니다.
		피해량은 힘과 민첩 중 더 높은 능력치의 영향을 받아 증가합니다.]]):format(20 + (s * self:getTalentLevel(t)) * 0.8)
	end,
}

newTalent{
	name = "Spit Blight",
	kr_display_name = "병균 뱉기",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	range = 10,
	requires_target = true,
	tactical = { ATTACK = { BLIGHT = 2 } },
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLIGHT, 20 + (self:getMag() * self:getTalentLevel(t)) * 0.8, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[병균 덩어리를 뱉어 대상에게 %0.2f 황폐화 피해를 줍니다.
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):format(20 + (self:getMag() * self:getTalentLevel(t)) * 0.8)
	end,
}

newTalent{
	name = "Rushing Claws",
	kr_display_name = "갈고리 돌진",
	type = {"wild-gift/other", 1},
	message = "@Source1@ 돌진하여, 갈고리를 휘두릅니다!",
	points = 5,
	equilibrium = 10,
	cooldown = 15,
	tactical = { DISABLE = 2, CLOSEIN = 3 },
	requires_target = true,
	range = function(self, t) return math.floor(5 + self:getTalentLevelRaw(t)) end,
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
	kr_display_name = "해골 던지기",
	type = {"undead/other", 1},
	points = 5,
	cooldown = 6,
	range = 10,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.BLEED, 20 + (self:getStr() * self:getTalentLevel(t)) * 0.8, {type="archery"})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 해골을 던져 출혈 상태로 만들고, %0.2f 물리 피해를 줍니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.]]):format(20 + (self:getStr() * self:getTalentLevel(t)) * 0.8)
	end,
}

newTalent{
	name = "Lay Web",
	kr_display_name = "거미줄 치기",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	message = "@Source1@ 거미줄을 칠 적당한 공간을 찾습니다...",
	range = 10,
	requires_target = true,
	tactical = { DISABLE = { stun = 1, pin = 1 } },
	action = function(self, t)
		local dur = 2 + self:getTalentLevel(t)
		local trap = mod.class.Trap.new{
			type = "web", subtype="web", id_by_type=true, unided_name = "sticky web",
			display = '^', color=colors.YELLOW, image = "trap/trap_spiderweb_01_64.png",
			name = "sticky web", auto_id = true,
			kr_display_name = "끈적이는 거미줄", kr_unided_name = "끈적이는 거미줄",
			detect_power = 6 * self:getTalentLevel(t), disarm_power = 10 * self:getTalentLevel(t),
			level_range = {self.level, self.level},
			message = "@Target1@ 거미줄에 걸렸습니다!",
			pin_dur = dur,
			faction = false,
			canTrigger = function(self, x, y, who)
				if who.type == "spiderkin" then return false end
				return mod.class.Trap.canTrigger(self, x, y, who)
			end,
			triggered = function(self, x, y, who)
				if who:canBe("stun") and who:canBe("pin") then
					who:setEffect(who.EFF_PINNED, self.pin_dur, {apply_power=self.disarm_power + 5})
				else
					game.logSeen(who, "%s 저항했습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"))
				end
				return true, true
			end
		}
		game.level.map(self.x, self.y, Map.TRAP, trap)
		return true
	end,
	info = function(self, t)
		return ([[투명한 거미줄을 만들어, 거미 이외의 종족을 거미줄에 걸리게 합니다.]]):format()
	end,
}

newTalent{
	name = "Darkness",
	kr_display_name = "어둠",
	type = {"wild-gift/other", 1},
	points = 5,
	equilibrium = 4,
	cooldown = 6,
	range = 0,
	radius = function(self, t)
		return 2 + self:getTalentLevelRaw(t) / 1.5
	end,
	direct_hit = true,
	tactical = { DISABLE = 3 },
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local g = engine.Entity.new{name="darkness", show_tooltip=true, block_sight=true, always_remember=false, unlit=self:getTalentLevel(t) * 10}
			game.level.map(px, py, Map.TERRAIN+1, g)
			game.level.map.remembers(px, py, false)
			game.level.map.lites(px, py, false)
		end, nil, {type="dark"})
		self:teleportRandom(self.x, self.y, 5)
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[어둠을 만들어 거의 모든 빛을 차단하고, 단거리 순간이동을 합니다.
		피해량은 민첩 능력치의 영향을 받아 증가합니다.]]):format(20 + (self:getDex() * self:getTalentLevel(t)) * 0.3)
	end,
}

newTalent{
	name = "Throw Boulder",
	kr_display_name = "바위 던지기",
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
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSKNOCKBACK, {dist=3+self:getTalentLevelRaw(t), dam=self:mindCrit(12 + self:getStr(50, true) * self:getTalentLevel(t))}, {type="archery"})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		return ([[대상에게 거대한 바위를 던져, %0.2f 피해를 주고 뒤로 밀어냅니다.
		피해량은 힘 능력치의 영향을 받아 증가합니다.]]):format(12 + self:getStr(50, true) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Howl",
	kr_display_name = "울부짖음",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 10,
	message = "@Source1@ 울부짖습니다.",
	range = 10,
	tactical = { ATTACK = 3 },
	direct_hit = true,
	action = function(self, t)
		local rad = self:getTalentLevel(t) + 5
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
		return ([[울부짖어 동료를 부릅니다.]])
	end,
}

newTalent{
	name = "Shriek",
	kr_display_name = "비명",
	type = {"wild-gift/other", },
	points = 5,
	equilibrium = 5,
	cooldown = 10,
	message = "@Source1@ 비명을 지릅니다.",
	range = 10,
	direct_hit = true,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		local rad = self:getTalentLevel(t) + 5
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
		return ([[비명을 질러 동료를 부릅니다.]])
	end,
}

newTalent{
	name = "Crush",
	kr_display_name = "분쇄",
	type = {"technique/other", 1},
	require = techs_req1,
	points = 5,
	cooldown = 6,
	stamina = 12,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 1 }, DISABLE = { stun = 2 } },
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

		-- Try to stun !
		if hit then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, 2 + self:getTalentLevel(t), {apply_power=self:combatPhysicalpower()})
			else
				game.logSeen(target, "%s 분쇄를 저항했습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[대상의 다리를 공격하여 %d%% 무기 피해를 줍니다. 공격이 성공하면, 대상은 %d 턴 동안 움직일 수 없게 됩니다.]]):format(100 * self:combatTalentWeaponDamage(t, 1, 1.4), 2+self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Silence",
	kr_display_name = "침묵",
	type = {"psionic/other", 1},
	points = 5,
	cooldown = 10,
	psi = 5,
	range = 7,
	direct_hit = true,
	requires_target = true,
	tactical = { DISABLE = { silence = 3 } },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SILENCE, {dur=math.floor(4 + self:getTalentLevel(t))}, {type="mind"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[염력을 이용하여, 대상을 %d 턴 동안 침묵시킵니다.]]):format(math.floor(4 + self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Telekinetic Blast",
	kr_display_name = "염동 탄환",
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
	kr_display_name = "황폐화 지역",
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
	action = function(self, t)
		local duration = self:getTalentLevel(t) + 2
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
		return ([[대상에게 오염된 증기가 뿜어져나와, 주변에 %0.2f 황폐 속성 피해를 매 턴마다 줍니다. (지속시간 : %d 턴)
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):format(self:combatTalentSpellDamage(t, 5, 65), self:getTalentLevel(t) + 2)
	end,
}

newTalent{
	name = "Invoke Tentacle",
	kr_display_name = "촉수 소환",
	type = {"wild-gift/other", 1},
	cooldown = 1,
	range = 10,
	direct_hit = true,
	tactical = { ATTACK = 3 },
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty = self:getTarget(tg)
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

			game.logSeen(self, "%s 촉수를 뻗습니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"))
		end

		return true
	end,
	info = function(self, t)
		return ([[희생자에게 자신의 촉수를 소환합니다.]])
	end,
}

newTalent{
	name = "Explode",
	kr_display_name = "폭발",
	type = {"technique/other", 1},
	points = 5,
	message = "@Source1@ 폭발했습니다! @Target1@ 밝은 빛에 삼켜졌습니다!",
	cooldown = 1,
	range = 1,
	requires_target = true,
	tactical = { ATTACK = { LIGHT = 1 } },
	action = function(self, t)
		local tg = {type="bolt", range=1}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		self:project(tg, x, y, DamageType.LIGHT, math.floor(self:combatSpellpower(0.25) * self:getTalentLevel(t)), {type="light"})
		game.level.map:particleEmitter(self.x, self.y, 1, "ball_fire", {radius = 1, r = 1, g = 0, b = 0})
		self:die(self)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[폭발하여, 눈이 멀 정도의 빛을 뿜어냅니다.]])
	end,
}

newTalent{
	name = "Will o' the Wisp Explode",
	kr_display_name = "윌 오 위습 폭발",
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
	kr_display_name = "원소의 탄환",
	type = {"spell/other", 1},
	points = 5,
	mana = 10,
	message = "@Source1@ 원소의 탄환을 사용합니다!",
	cooldown = 3,
	range = 10,
	proj_speed = 2,
	requires_target = true,
	tactical = { ATTACK = 2 },
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
		self:projectile(tg, x, y, elem[1], math.floor(self:getMag(90, true) * self:getTalentLevel(t)), {type=elem[2]})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[무작위한 속성을 지녔으며, 느리게 날아가는 마법 탄환을 발사합니다. 피해량은 마법 능력치의 영향을 받아 증가합니다.]])
	end,
}

newTalent{
	name = "Volcano",
	kr_display_name = "화산",
	type = {"spell/other", 1},
	points = 5,
	mana = 10,
	message = "화산이 폭발합니다!",
	cooldown = 20,
	range = 10,
	proj_speed = 2,
	requires_target = true,
	tactical = { ATTACK = { FIRE = 1, PHYSICAL = 1 } },
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
			kr_display_name = "격렬한 화산",
			display = '&', color=colors.LIGHT_RED, back_color=colors.RED,
			always_remember = true,
			temporary = 4 + self:getTalentLevel(t),
			x = x, y = y,
			canAct = false,
			nb_projs = math.floor(self:getTalentLevel(self.T_VOLCANO)),
			dam = self:combatTalentSpellDamage(self.T_VOLCANO, 15, 80),
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
		return ([[%d 턴 동안 작은 화산을 소환합니다. 매 턴마다 적에게 용암 덩어리를 %d 개 분출하여, %0.2f 화염 피해와 %0.2f 물리 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(4 + self:getTalentLevel(t), math.floor(self:getTalentLevel(self.T_VOLCANO)), damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(self.T_VOLCANO, 15, 80) / 2), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(self.T_VOLCANO, 15, 80) / 2))
	end,
}

newTalent{
	name = "Speed Sap",
	kr_display_name = "속도 훔치기",
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
	kr_display_name = "드렛지의 광란",
	type = {"chronomancy/other", 1},
	points = 5,
	cooldown = 12,
	tactical = {
		BUFF = 4,
	},
	direct_hit = true,
	range = 0,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=true, talent=t}
	end,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
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
					target:setEffect(target.EFF_FRENZY, self:getTalentLevel(t), {crit = t.getPower(self, t)/10, power=t.getPower(self, t)/100, dieat=t.getPower(self, t)/100}, reapplied)
				end
			end
		end)

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_light", {radius=tg.radius})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		return ([[근처에 있는 드렛지들의 속도가 빨라집니다.]]):format()
	end,
}

newTalent{
	name = "Sever Lifeline",
	kr_display_name = "생명선 절단",
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
	kr_display_name = "아마크텔의 부름",
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
				if target.x ~= ox or target.y ~= oy then game.logSeen(target, "%s 끌려옵니다!", (target.kr_display_name or target.name):capitalize():addJosa("가")) end
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
	kr_display_name = "아마크텔의 선물",
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

			game.logSeen(self, "%s 끈적이며, 기어다니는 존재를 불러냅니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"))
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
	kr_display_name = "암석 타격",
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
	kr_display_name = "산성 증기",
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
	getDuration = function(self, t) return self:getTalentLevel(t) + 2 end,
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
		format(duration, damDesc(self, DamageType.ACID, damage))
	end,
}

newTalent{
	name = "Manaflow",
	kr_display_name = "마나의 흐름",
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
	kr_display_name = "지옥의 호흡",
	type = {"spell/other",1},
	random_ego = "attack",
	cooldown = 20,
	tactical = { ATTACK = { FIRE = 1 }, HEAL = 1, },
	range = 0,
	radius = function(self, t)
		return 3 + self:getTalentLevelRaw(t)
	end,
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
	kr_display_name = "얼어붙은 손",
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
	kr_display_name = "유성우",
	type = {"spell/other", 3},
	points = 5,
	cooldown = 30,
	mana = 70,
	tactical = { ATTACKAREA = { FIRE=2, PHYSICAL=2 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 250) end,
	getNb = function(self, t) return 3 + math.floor(self:getTalentLevel(t) / 3) end,
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
				game.level.map:particleEmitter(x, y, 10, "ball_fire", {radius=2})
				game:playSoundNear(game.player, "talents/fireflash")

				for i = x-1, x+1 do for j = y-1, y+1 do
					local oe = game.level.map(i, j, Map.TERRAIN)
					if oe and not oe:attr("temporary") and
					(core.fov.distance(x, y, i, j) < 1 or rng.percent(40)) and (game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "dig") or game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "grow")) then
						local g = terrains.LAVA_FLOOR:clone()
						g:resolve() g:resolve(nil, true)
						g.temporary = 8
						g.x = i g.y = j
						g.canAct = false
						g.energy = { value = 0, mod = 1 }
						g.old_feat = game.level.map(i, j, engine.Map.TERRAIN)
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
						game.zone:addEntity(game.level, g, "terrain", i, j)
						game.level:addEntity(g)
					end
				end end
				for i = x-1, x+1 do for j = y-1, y+1 do
					game.nicer_tiles:updateAround(game.level, i, j)
				end end

				src:project({type="ball", radius=2, selffire=false}, x, y, engine.DamageType.FIRE, dam/2)
				src:project({type="ball", radius=2, selffire=false}, x, y, engine.DamageType.PHYSICAL, dam/2)
				game:getPlayer(true):attr("meteoric_crash", 1)
			end
		end

		local grids = {}
		self:project(tg, x, y, function(px, py) grids[#grids+1] = {x=px, y=py} end)

		for i = 1, t.getNb(self, t) do
			local g = rng.tableRemove(grids)
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
	kr_display_name = "치료",
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
	kr_display_name = "번개 소환",
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
	kr_display_name = "흐려짐",
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
	kr_display_name = "근거리 순간이동",
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
	kr_display_name = "맹점",
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
	kr_display_name = "대기",
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
		game.logSeen("#VIOLET#%s 대기 상태에서 벗어났습니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"))
		return true
	end,
	info = function(self, t)
		return ([[공격받기 전까지 어떤 반응도 할 수 없게 됩니다.]])
	end,
}
