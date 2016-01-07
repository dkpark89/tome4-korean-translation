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
	name = "War Hound",
	kr_name = "전투견 소환",
	type = {"wild-gift/summon-melee", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 전투견을 소환했습니다!",
	equilibrium = 3,
	cooldown = 15,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { PHYSICAL = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.PHYSICAL, self:mindCrit(self:combatTalentMindDamage(t, 30, 250)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		local duration = self:callTalent(self.T_GRAND_ARRIVAL,"effectDuration")
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_PHYSICAL_RESIST, dur=duration, p={power=self:combatTalentMindDamage(t, 15, 70)}})
		game.level.map:particleEmitter(m.x, m.y, tg.radius, "shout", {size=4, distorion_factor=0.3, radius=tg.radius, life=30, nb_circles=8, rm=0.8, rM=1, gm=0.8, gM=1, bm=0.1, bM=0.2, am=0.6, aM=0.8})
	end,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 5, 0, 10, 5)) end,
	incStats = function(self, t,fake)
		local mp = self:combatMindpower()
		return{ 
			str=15 + (fake and mp or self:mindCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:combatTalentScale(t, 2, 10, 0.75),
			dex=15 + (fake and mp or self:mindCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:combatTalentScale(t, 2, 10, 0.75),
			con=15 + self:callTalent(self.T_RESILIENCE, "incCon")
		}
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "animal", subtype = "canine",
			display = "C", color=colors.LIGHT_DARK, image = "npc/summoner_wardog.png",
			name = "전투견", faction = self.faction,
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,
			global_speed_base = 1.2,

			max_life = resolvers.rngavg(25,50),
			life_rating = 6,
			infravision = 10,

			combat_armor = 2, combat_def = 4,
			combat = { dam=self:getTalentLevel(t) * 10 + rng.avg(12,25), atk=10, apr=10, dammod={str=0.8} },

			wild_gift_detonate = t.id,

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.kr_name = (m.kr_name or m.name).." (야생의 소환수)"
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_TOTAL_THUGGERY]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[%d 턴 동안 전투견을 소환하여 적과 싸우게 합니다. 전투견은 기초적이지만 강력한 근접 공격수입니다.
		소환수의 능력치는 다음과 같습니다 : %d 힘, %d 민첩, %d 체격
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 힘과 민첩 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self, t), incStats.str, incStats.dex, incStats.con)
	end,
}

newTalent{
	name = "Jelly",
	kr_name = "젤리 소환",
	type = {"wild-gift/summon-melee", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 젤리를 소환합니다!",
	equilibrium = 2,
	cooldown = 10,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { NATURE = 1 }, EQUILIBRIUM = 1, },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.SLIME, self:mindCrit(self:combatTalentMindDamage(t, 30, 200)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		local duration = self:callTalent(self.T_GRAND_ARRIVAL,"effectDuration")
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_NATURE_RESIST, dur=duration, p={power=self:combatTalentMindDamage(t, 15, 70)}}, {type="flame"})
	end,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 5, 0, 10, 5)) end,
	incStats = function(self, t, fake)
		local mp = self:combatMindpower()
		return{ 
			con=10 + (fake and mp or self:mindCrit(mp)) * 1.8 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:combatTalentScale(self:getTalentLevel(self.T_RESILIENCE), 3, 15, 0.75),
			str=10 + self:combatTalentScale(t, 2, 10, 0.75)
		}
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "immovable", subtype = "jelly", image = "npc/jelly-darkgrey.png",
			display = "j", color=colors.BLACK,
			desc = "던전 바닥에서 주로 볼 수 있는, 점액질 덩어리입니다.",
			name = "black jelly",
			kr_name = "검은 젤리",
			autolevel = "none", faction=self.faction,
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			resists = { [DamageType.LIGHT] = -50 },
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=5, },
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(25,50),
			life_rating = 15,
			infravision = 10,

			combat_armor = 1, combat_def = 1,
			never_move = 1,

			combat = { dam=8, atk=15, apr=5, damtype=DamageType.ACID, dammod={str=0.7} },

			wild_gift_detonate = t.id,

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target},

			on_takehit = function(self, value, src)
				local p = value * 0.10
				if self.summoner and not self.summoner.dead then
					self.summoner:incEquilibrium(-p)
					self:logCombat(self.summoner, "#GREEN##Source1# 충격의 일부를 흡수했습니다. #Target2# 자연과 조금 더 가까워 졌습니다.")
				end
				return value - p
			end,
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.kr_name = (m.kr_name or m.name).." (야생의 소환수)"
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_SWALLOW]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[%d 턴 동안 젤리를 소환하여 적과 싸우게 합니다. 젤리는 움직이지 않지만, 젤리가 받는 피해량의 10%% 만큼 평정을 찾을 수 있게 됩니다.
		소환수의 능력치는 다음과 같습니다 : %d 체격, %d 힘
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 건강 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self, t), incStats.con, incStats.str)
       end,
}

newTalent{
	name = "Minotaur",
	kr_name = "미노타우르스 소환",
	type = {"wild-gift/summon-melee", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 미노타우르스를 소환합니다!",
	equilibrium = 10,
	cooldown = 15,
	range = 5,
	is_summon = true,
	requires_target = true,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { confusion = 1, stun = 1 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.BLEED, self:mindCrit(self:combatTalentMindDamage(t, 30, 350)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		local duration = self:callTalent(self.T_GRAND_ARRIVAL,"effectDuration")
		local slowdown = self:combatLimit(self:combatTalentMindDamage(t, 5, 500), 1, 0.1, 0, 0.47 , 369) -- Limit speed loss to <100%
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_SLOW_MOVE, dur=duration, p={power=slowdown}}, {type="flame"})
	end,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 2, 0, 7, 5)) end,
	incStats = function(self, t,fake)
		local mp = self:combatMindpower()
		return{ 
			str=25 + (fake and mp or self:mindCrit(mp)) * 2.1 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:combatTalentScale(t, 2, 10, 0.75),
			dex=10 + (fake and mp or self:mindCrit(mp)) * 1.8 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:combatTalentScale(t, 2, 10, 0.75),
			con=10 + self:combatTalentScale(t, 2, 10, 0.75) + self:callTalent(self.T_RESILIENCE, "incCon"),
		}
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "giant", subtype = "minotaur",
			display = "H",
			name = "minotaur", color=colors.UMBER, resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_minotaur_minotaur.png", display_h=2, display_y=-1}}},
				kr_name = "미노타우르스",

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			max_stamina = 100,
			life_rating = 13,
			max_life = resolvers.rngavg(50,80),
			infravision = 10,

			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
			global_speed_base=1.2,
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			desc = [[인간과 소의 혼혈입니다.]],
			resolvers.equip{ {type="weapon", subtype="battleaxe", auto_req=true}, },
			level_range = {self.level, self.level}, exp_worth = 0,

			combat_armor = 13, combat_def = 8,
			resolvers.talents{ [Talents.T_WARSHOUT]=3, [Talents.T_STUNNING_BLOW]=3, [Talents.T_SUNDER_ARMOUR]=2, [Talents.T_SUNDER_ARMS]=2, },

			wild_gift_detonate = t.id,

			faction = self.faction,
			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self,t),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.kr_name = (m.kr_name or m.name).." (야생의 소환수)"
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_RUSH]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[%d 턴 동안 미노타우르스를 소환하여 적과 싸우게 합니다. 미노타우르스는 소환 지속시간이 짧지만, 적에게 큰 피해를 줍니다.
		소환수의 능력치는 다음과 같습니다 : %d 힘, %d 체격, %d 민첩
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 힘과 민첩 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self,t), incStats.str, incStats.con, incStats.dex)
	end,
}

newTalent{
	name = "Stone Golem",
	kr_name = "암석 골렘 소환",
	type = {"wild-gift/summon-melee", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 암석 골렘을 소환합니다!",
	equilibrium = 15,
	cooldown = 20,
	range = 5,
	is_summon = true,
	tactical = { ATTACK = { PHYSICAL = 3 }, DISABLE = { knockback = 1 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.PHYSKNOCKBACK, {dam=self:mindCrit(self:combatTalentMindDamage(t, 30, 150)), dist=4}, {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		local duration = self:callTalent(self.T_GRAND_ARRIVAL,"effectDuration")
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_DAZED, check_immune="stun", dur=duration, p={}}, {type="flame"})
	end,
	requires_target = true,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 5, 0, 10, 5)) end,
	incStats = function(self, t,fake)
		local mp = self:combatMindpower()
		return{ 
			str=15 + (fake and mp or self:mindCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:combatTalentScale(t, 2, 10, 0.75),
			dex=15 + (fake and mp or self:mindCrit(mp)) * 1.9 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:combatTalentScale(t, 2, 10, 0.75),
			con=10 + self:combatTalentScale(t, 2, 10, 0.75) + self:callTalent(self.T_RESILIENCE, "incCon"),
		}
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "golem", subtype = "stone",
			display = "g",
			name = "stone golem", color=colors.WHITE, image = "npc/summoner_golem.png",
			kr_name = "암석 골렘",

			body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

			max_stamina = 800,
			life_rating = 13,
			max_life = resolvers.rngavg(50,80),
			infravision = 10,

			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			desc = [[살아 움직이는 거대한 석상입니다.]],
			level_range = {self.level, self.level}, exp_worth = 0,

			combat_armor = 25, combat_def = -20,
			combat = { dam=25 + self:getWil(), atk=20, apr=5, dammod={str=0.9} },
			resolvers.talents{ [Talents.T_UNSTOPPABLE]=3, [Talents.T_STUN]=3, },

			poison_immune=1, cut_immune=1, fear_immune=1, blind_immune=1,

			wild_gift_detonate = t.id,

			faction = self.faction,
			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target},
			resolvers.sustains_at_birth(),
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.kr_name = (m.kr_name or m.name).." (야생의 소환수)"
			m.name = m.name.." (wild summon)"
			m[#m+1] = resolvers.talents{ [self.T_SHATTERING_IMPACT]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t,true)
		return ([[%d 턴 동안 암석 골렘을 소환하여 적과 싸우게 합니다. 암석 골렘은 폭주 상태가 될 수 있는 강력한 소환수입니다.
		소환수의 능력치는 다음과 같습니다 : %d 힘, %d 체격, %d 민첩
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 힘과 민첩 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self, t), incStats.str, incStats.con, incStats.dex)
	end,
}
