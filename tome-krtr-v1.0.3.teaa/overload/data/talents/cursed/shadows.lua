-- ToME - Tales of Middle-Earth
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

newTalent{
	short_name = "SHADOW_FADE",
	name = "Fade",
	kr_name = "흐려짐",
	type = {"spell/other",1},
	points = 5,
	cooldown = function(self, t)
		return math.max(3, 8 - self:getTalentLevelRaw(t))
	end,
	action = function(self, t)
		self:setEffect(self.EFF_FADED, 1, {})
		return true
	end,
	info = function(self, t)
		return ([[시야에서 흐려져, 자신의 다음 턴이 올 때까지 무적이 됩니다.]])
	end,
}

newTalent{
	short_name = "SHADOW_PHASE_DOOR",
	name = "Phase Door",
	kr_name = "근거리 순간이동",
	type = {"spell/other",1},
	points = 5,
	range = 10,
	tactical = { ESCAPE = 2 },
	is_teleport = true,
	action = function(self, t)
		local x, y, range
		if self.ai_state.shadow_wall then
			x, y, range = self.ai_state.shadow_wall_target.x, self.ai_state.shadow_wall_target.y, 1
		elseif self.ai_target.x and self.ai_target.y then
			x, y, range = self.ai_target.x, self.ai_target.y, 1
		else
			x, y, range = self.summoner.x, self.summoner.y, self.ai_state.location_range
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
		self:teleportRandom(x, y, range)
		game.level.map:particleEmitter(x, y, 1, "teleport_in")
		return true
	end,
	info = function(self, t)
		return ([[짧은 거리를 순간이동합니다.]])
	end,
}

newTalent{
	short_name = "SHADOW_BLINDSIDE",
	name = "Blindside",
	kr_name = "습격",
	type = {"spell/other", 1},
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
	end,info = function(self, t)
		local multiplier = self:combatTalentWeaponDamage(t, 1.1, 1.9)
		return ([[눈 깜짝할 사이에 최대 %d 칸 떨어진 대상의 옆에 나타나, %d%% 피해를 줍니다.]]):format(self:getTalentRange(t), multiplier * 100)
	end,
}

newTalent{
	short_name = "SHADOW_LIGHTNING",
	name = "Shadow Lightning",
	kr_name = "그림자 번개",
	type = {"spell/other", 1},
	require = { },
	points = 5,
	random_ego = "attack",
	range = 1,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[대상을 그림자 번개로 공격하여, %0.2f - %0.2f 피해를 줍니다.
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 3),
		damDesc(self, DamageType.LIGHTNING, damage))
	end,
}

newTalent{
	short_name = "SHADOW_FLAMES",
	name = "Shadow Flames",
	kr_name = "그림자 불꽃",
	type = {"spell/other", 1},
	require = { },
	points = 5,
	random_ego = "attack",
	range = 6,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 140) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.FIRE, dam)
		game.level.map:particleEmitter(x, y, 1, "flame")
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[대상을 불태워, %0.2f 피해를 줍니다.
		피해량은 마법 능력치의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.FIREBURN, damage))
	end,
}

newTalent{
	short_name = "SHADOW_REFORM",
	name = "Reform",
	kr_name = "재구성",
	type = {"spell/other", 1},
	require = { },
	points = 5,
	getChance = function(self, t)
		return 50 --10 + self:getMag() * 0.25 + self:getTalentLevel(t) * 2
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[그림자가 파괴되기 직전에, %d%% 확률로 재구성되어 다시 나타날 수 있게 됩니다.]]):format(chance)
	end,
}

local function createShadow(self, level, tCallShadows, tShadowWarriors, tShadowMages, duration, target)
	local npc = require("mod.class.NPC").new{
		type = "undead", subtype = "shadow",
		name = "shadow",
		kr_name = "그림자",
		desc = [[]],
		display = 'b', color=colors.BLACK,

		never_anger = true,
		summoner = self,
		summoner_gain_exp=true,
		summon_time = duration,
		faction = self.faction,
		size_category = 2,
		rank = 2,
		autolevel = "none",
		level_range = {level, level},
		exp_worth=0,
		hate_regen = 1,
		avoid_traps = 1,

		max_life = resolvers.rngavg(3,12), life_rating = 5,
		stats = {
			str=5 + math.floor(level),
			dex=10 + math.floor(level * 1.5),
			mag=10 + math.floor(level * 1.5),
			wil=5 + math.floor(level),
			cun=5 + math.floor(level * 0.7),
			con=5 + math.floor(level * 0.7),
		},
		combat_armor = 0, combat_def = 3,
		combat = {
			dam=math.floor(level * 1.5),
			atk=10 + level,
			apr=8,
			dammod={str=0.5, dex=0.5}
		},
		mana = 100,
		spellpower = tShadowMages and tShadowMages.getSpellpowerChange(self, tShadowMages) or 0,
		summoner_hate_per_kill = self.hate_per_kill,
		resolvers.talents{
			[self.T_SHADOW_PHASE_DOOR]=tCallShadows.getPhaseDoorLevel(self, tCallShadows),
			[self.T_SHADOW_BLINDSIDE]=tCallShadows.getBlindsideLevel(self, tCallShadows),
			[self.T_HEAL]=tCallShadows.getHealLevel(self, tCallShadows),
			[self.T_DOMINATE]=tShadowWarriors and tShadowWarriors.getDominateLevel(self, tShadowWarriors) or 0,
			[self.T_SHADOW_FADE]=tShadowWarriors and tShadowWarriors.getFadeLevel(self, tShadowWarriors) or 0,
			[self.T_SHADOW_LIGHTNING]=tShadowMages and tShadowMages.getLightningLevel(self, tShadowMages) or 0,
			[self.T_SHADOW_FLAMES]=tShadowMages and tShadowMages.getFlamesLevel(self, tShadowMages) or 0,
			[self.T_SHADOW_REFORM]=tShadowMages and tShadowMages.getReformLevel(self, tShadowMages) or 0,
		},

		undead = 1,
		no_breath = 1,
		stone_immune = 1,
		confusion_immune = 1,
		fear_immune = 1,
		teleport_immune = 1,
		disease_immune = 1,
		poison_immune = 1,
		stun_immune = 1,
		blind_immune = 1,
		see_invisible = 80,
		resists = { [DamageType.LIGHT] = -100, [DamageType.DARKNESS] = 100 },
		resists_pen = { all=25 },

		ai = "shadow",
		ai_state = {
			summoner_range = 10,
			actor_range = 8,
			location_range = 4,
			target_time = 0,
			target_timeout = 10,
			focus_on_target = false,
			shadow_wall = false,
			shadow_wall_time = 0,

			blindside_chance = 15,
			phasedoor_chance = 5,
			close_attack_spell_chance = 0,
			far_attack_spell_chance = 0,
			can_reform = false,
			dominate_chance = 0,

			feed_level = 0
		},
		ai_target = {
			actor=target,
			x = nil,
			y = nil
		},

		healSelf = function(self)
			self:useTalent(self.T_HEAL)
		end,
		closeAttackSpell = function(self)
			return self:useTalent(self.T_SHADOW_LIGHTNING)
		end,
		farAttackSpell = function(self)
			if self:knowTalent(self.T_EMPATHIC_HEX) and not self:isTalentCoolingDown(self.T_EMPATHIC_HEX) and rng.percent(50) then
				return self:useTalent(self.T_EMPATHIC_HEX)
			else
				return self:useTalent(self.T_SHADOW_FLAMES)
			end
		end,
		dominate = function(self)
			return self:useTalent(self.T_DOMINATE)
		end,
		feed = function(self)
			if self.summoner:knowTalent(self.summoner.T_SHADOW_MAGES) then
				local tShadowMages = self.summoner:getTalentFromId(self.summoner.T_SHADOW_MAGES)
				self.ai_state.close_attack_spell_chance = tShadowMages.getCloseAttackSpellChance(self.summoner, tShadowMages)
				self.ai_state.far_attack_spell_chance = tShadowMages.getFarAttackSpellChance(self.summoner, tShadowMages)
				self.ai_state.can_reform = self.summoner:getTalentLevel(tShadowMages) >= 5
			else
				self.ai_state.close_attack_spell_chance = 0
				self.ai_state.far_attack_spell_chance = 0
				self.ai_state.can_reform = false
			end

			if self.ai_state.feed_temp1 then self:removeTemporaryValue("combat_atk", self.ai_state.feed_temp1) end
			self.ai_state.feed_temp1 = nil
			if self.ai_state.feed_temp2 then self:removeTemporaryValue("inc_damage", self.ai_state.feed_temp2) end
			self.ai_state.feed_temp2 = nil
			if self.summoner:knowTalent(self.summoner.T_SHADOW_WARRIORS) then
				local tShadowWarriors = self.summoner:getTalentFromId(self.summoner.T_SHADOW_WARRIORS)
				self.ai_state.feed_temp1 = self:addTemporaryValue("combat_atk", tShadowWarriors.getCombatAtk(self.summoner, tShadowWarriors))
				self.ai_state.feed_temp2 = self:addTemporaryValue("inc_damage", {all=tShadowWarriors.getIncDamage(self.summoner, tShadowWarriors)})
				self.ai_state.dominate_chance = tShadowWarriors.getDominateChance(self.summoner, tShadowWarriors)
			else
				self.ai_state.dominate_chance = 0
			end
		end,
		onTakeHit = function(self, value, src)
			if self:knowTalent(self.T_SHADOW_FADE) and not self:isTalentCoolingDown(self.T_SHADOW_FADE) then
				self:forceUseTalent(self.T_SHADOW_FADE, {ignore_energy=true})
			end

			return mod.class.Actor.onTakeHit(self, value, src)
		end,
	}

	if self:knowTalent(self.T_BLIGHTED_SUMMONING) then npc:learnTalent(npc.T_EMPATHIC_HEX, true, 3) end

	self:attr("summoned_times", 1)
	return npc
end

newTalent{
	name = "Call Shadows",
	kr_name = "그림자 소환",
	type = {"cursed/shadows", 1},
	mode = "sustained",
	no_energy = true,
	require = cursed_cun_req1,
	points = 5,
	cooldown = 10,
	hate = 0,
	tactical = { BUFF = 5 },
	getLevel = function(self, t)
		return math.min(self.level, 50)
	end,
	getMaxShadows = function(self, t)
		return math.min(4, math.max(1, math.floor(self:getTalentLevel(t) * 0.55)))
	end,
	getPhaseDoorLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getBlindsideLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getHealLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		-- unsummon the shadows
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then
				e.summon_time = 0
			end
		end

		return true
	end,
	do_callShadows = function(self, t)
		if not self.shadows then
			self.shadows = {
				remainingCooldown = 0
			}
		end

		if game.zone.wilderness then return false end

		self.shadows.remainingCooldown = self.shadows.remainingCooldown - 1
		if self.shadows.remainingCooldown > 0 then return false end
		self.shadows.remainingCooldown = 10

		local shadowCount = 0
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "shadow" then shadowCount = shadowCount + 1 end
		end

		if shadowCount >= t.getMaxShadows(self, t) then
			return false
		end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 8, true, {[Map.ACTOR]=true})
		if not x then
			return false
		end

		-- use hate
		if self.hate < 6 then
			-- not enough hate..just wait for another try
			game.logPlayer(self, "그림자를 부를 증오가 부족합니다!", deflectDamage)
			return false
		end
		self:incHate(-6)

		level = t.getLevel(self, t)
		local tShadowWarriors = self:knowTalent(self.T_SHADOW_WARRIORS) and self:getTalentFromId(self.T_SHADOW_WARRIORS) or nil
		local tShadowMages = self:knowTalent(self.T_SHADOW_MAGES) and self:getTalentFromId(self.T_SHADOW_MAGES) or nil

		local shadow = createShadow(self, level, t, tShadowWarriors, tShadowMages, 1000, nil)

		shadow:resolve()
		shadow:resolve(nil, true)
		shadow:forceLevelup(level)
		game.zone:addEntity(game.level, shadow, "actor", x, y)
		shadow:feed()
		game.level.map:particleEmitter(x, y, 1, "teleport_in")

		shadow.no_party_ai = true
		shadow.unused_stats = 0
		shadow.unused_talents = 0
		shadow.unused_generics = 0
		shadow.unused_talents_types = 0
		shadow.no_points_on_levelup = true
		if game.party:hasMember(self) then
			shadow.remove_from_party_on_death = true
			game.party:addMember(shadow, { control="no", type="summon", title="Summon", kr_title="소환수"})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxShadows = t.getMaxShadows(self, t)
		local level = t.getLevel(self, t)
		local healLevel = t.getHealLevel(self, t)
		local blindsideLevel = t.getBlindsideLevel(self, t)
		return ([[이 기술을 활성화 시키면, %d 레벨인 그림자 %d 개가 지속적으로 생겨나 전투를 도와줍니다. 그림자는 소환할 때마다 증오가 6 씩 소모되며, 그림자는 약하지만 다양한 능력을 사용할 수 있습니다.
		- 기술 레벨 %d 인 '마법적 재구축' 을 통해 스스로 생명력을 회복합니다.
		- 기술 레벨 %d 인 '습격' 을 사용하여 적을 공격합니다.
		- '근거리 순간이동' 을 사용할 수 있습니다.]]):format(level, maxShadows, healLevel, blindsideLevel)
	end,
}

newTalent{
	name = "Shadow Warriors",
	kr_name = "그림자 전사",
	type = {"cursed/shadows", 2},
	mode = "passive",
	require = cursed_cun_req2,
	points = 5,
	getIncDamage = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 0.5) * 35)
	end,
	getCombatAtk = function(self, t)
		return math.floor((math.sqrt(self:getTalentLevel(t)) - 0.5) * 23)
	end,
	getDominateLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getFadeLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getDominateChance = function(self, t)
		if self:getTalentLevelRaw(t) > 0 then
			return math.min(100, math.sqrt(self:getTalentLevel(t)) * 7)
		else
			return 0
		end
	end,
	on_learn = function(self, t)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return { }
	end,
	on_unlearn = function(self, t, p)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local combatAtk = t.getCombatAtk(self, t)
		local incDamage = t.getIncDamage(self, t)
		local dominateChance = t.getDominateChance(self, t)
		local dominateLevel = t.getDominateLevel(self, t)
		local fadeCooldown = math.max(3, 8 - self:getTalentLevelRaw(t))
		return ([[그림자에 증오를 주입시켜, 공격력을 강화시킵니다. 그림자의 정확도가 %d%% 상승하며, %d%% 추가 피해를 줍니다. 그리고, 그림자의 능력이 추가됩니다.
		- 기술 레벨 %d 인 '지배' 기술을 사용하여, 근접한 적을 지배할 수 있게 됩니다. (지배 확률은 %d%% 입니다)
		- 1 턴 동안 어떤 공격도 받지 않게 되는 '흐려짐' 기술을 사용할 수 있게 됩니다. (기술의 재사용 대기시간은 %d 턴 입니다)]]):format(combatAtk, incDamage, dominateLevel, dominateChance, fadeCooldown)
	end,
}

newTalent{
	name = "Shadow Mages",
	kr_name = "그림자 마법사",
	type = {"cursed/shadows", 3},
	mode = "passive",
	require = cursed_cun_req3,
	points = 5,
	getCloseAttackSpellChance = function(self, t)
		if math.floor(self:getTalentLevel(t)) > 0 then
			return math.min(100, math.sqrt(self:getTalentLevel(t)) * 7)
		else
			return 0
		end
	end,
	getFarAttackSpellChance = function(self, t)
		if math.floor(self:getTalentLevel(t)) >= 3 then
			return math.min(100, math.sqrt(self:getTalentLevel(t)) * 7)
		else
			return 0
		end
	end,
	getLightningLevel = function(self, t)
		return self:getTalentLevelRaw(t)
	end,
	getFlamesLevel = function(self, t)
		if self:getTalentLevel(t) >= 3 then
			return self:getTalentLevelRaw(t)
		else
			return 0
		end
	end,
	getReformLevel = function(self, t)
		if self:getTalentLevel(t) >= 5 then
			return self:getTalentLevelRaw(t)
		else
			return 0
		end
	end,
	canReform = function(self, t)
		return t.getReformLevel(self, t) > 0
	end,
	getSpellpowerChange = function(self, t)
		return math.floor(self:getTalentLevel(t) * 3)
	end,
	on_learn = function(self, t)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return { }
	end,
	on_unlearn = function(self, t, p)
		if game and game.level and game.level.entities then
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e:feed(t)
				end
			end
		end

		return true
	end,
	info = function(self, t)
		local closeAttackSpellChance = t.getCloseAttackSpellChance(self, t)
		local farAttackSpellChance = t.getFarAttackSpellChance(self, t)
		local spellpowerChange = t.getSpellpowerChange(self, t)
		local lightningLevel = t.getLightningLevel(self, t)
		local flamesLevel = t.getFlamesLevel(self, t)
		return ([[그림자에 마법의 힘을 주입시켜, 강력한 마법을 쓸 수 있게 합니다. 그림자의 주문력이 %d 상승하며, 그림자의 능력이 추가됩니다.
		-  %d%% 확률로 기술 레벨 %d 의 '전격' 마법을 사용하여 근접한 적을 공격합니다.
		- 그림자 마법사의 기술 레벨이 3 이상이면, %d%% 확률로 기술 레벨 %d 인 '불꽃' 마법을 사용하여 멀리 있는 적을 불태웁니다. (사거리 : 2 - 6 칸)
		- 그림자 마법사의 기술 레벨이 5 이상이면, 그림자가 파괴되었을 때 몸을 재구성하여 50%% 확률로 부활할 수 있게 됩니다.]]):format(spellpowerChange, closeAttackSpellChance, lightningLevel, farAttackSpellChance, flamesLevel)
	end,
}

newTalent{
	name = "Focus Shadows",
	kr_name = "그림자 집중",
	type = {"cursed/shadows", 4},
	require = cursed_cun_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	hate = 0,
	range = 6,
	requires_target = true,
	tactical = { ATTACK = 2 },
	getDefenseDuration = function(self, t)
		return 3 + math.floor(self:getTalentLevel(t) * 1.5)
	end,
	getBlindsideChance = function(self, t)
		return math.min(100, 30 + self:getTalentLevel(t) * 10)
	end,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local target = { type="hit", range=range, nowarning=true }
		local x, y, target = self:getTarget(target)
		if not x or not y or not target or core.fov.distance(self.x, self.y, x, y) > range then return nil end

		if self:reactionToward(target) < 0 then
			-- attack the target
			local blindsideChance = t.getBlindsideChance(self, t)
			local shadowCount = 0
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					-- reset target and set to focus
					e.ai_target.x = nil
					e.ai_target.y = nil
					e.ai_target.actor = target
					e.ai_target.focus_on_target = true
					e.ai_target.blindside_chance = blindsideChance

					shadowCount = shadowCount + 1
				end
			end

			if shadowCount > 0 then
				game.logPlayer(self, "#PINK#그림자들이 %s에게 모여듭니다!", (target.kr_name or target.name))
				return true
			else
				game.logPlayer(self, "집중시킬 그림자가 없습니다!")
				return false
			end
		else
			-- defend the target
			local defenseDuration = t.getDefenseDuration(self, t)
			local shadowCount = 0
			for _, e in pairs(game.level.entities) do
				if e.summoner and e.summoner == self and e.subtype == "shadow" then
					e.ai_state.shadow_wall = true
					e.ai_state.shadow_wall_target = target
					e.ai_state.shadow_wall_time = defenseDuration

					shadowCount = shadowCount + 1
				end
			end

			if shadowCount > 0 then
				game.logPlayer(self, "#PINK#그림자들이 %s에게 모여듭니다!", (target.kr_name or target.name))
				return true
			else
				game.logPlayer(self, "집중시킬 그림자가 없습니다!")
				return false
			end
		end
	end,
	info = function(self, t)
		local defenseDuration = t.getDefenseDuration(self, t)
		local blindsideChance = t.getBlindsideChance(self, t)
		return ([[그림자를 하나의 대상에 집중시킵니다. 대상이 아군일 경우 대상을 %d 턴 동안 보호하며, 대상이 적일 경우 그림자가 %d%% 확률로 대상을 습격합니다.
		이 기술은 원천력 소모 없이 사용할 수 있습니다.]]):format(defenseDuration, blindsideChance)
	end,
}

