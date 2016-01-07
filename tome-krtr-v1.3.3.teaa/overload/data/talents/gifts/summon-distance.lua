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

newTalent{ short_name = "RITCH_FLAMESPITTER_BOLT",
	name = "Flamespit",
	kr_name = "불꽃 뱉기",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 2,
	message = "@Source@ spits flames!",
	range = 10,
	reflectable = true,
	requires_target = true,
	tactical = { ATTACK = { FIRE = 2 } },
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, self:mindCrit(self:combatTalentMindDamage(t, 8, 120)), {type="flame"})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[불꽃 화살을 발사해, %0.2f 화염 피해를 줍니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.FIRE, self:combatTalentMindDamage(t, 8, 120)))
	end,
}

newTalent{
	name = "Flame Fury", image = "talents/blastwave.png",
	kr_name = "화염의 분노",
	type = {"wild-gift/other",1},
	points = 5,
	eqilibrium = 5,
	cooldown = 5,
	tactical = { ATTACKAREA = 2, DISABLE = 2, ESCAPE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 28, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.FIREKNOCKBACK_MIND, {dist=3, dam=self:mindCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_fire", {radius=tg.radius})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[주변 %d 칸 반경에 화염의 힘을 분출해, 적들을 밀어내고 불타게 만들어 %0.2f 화염 피해를 3 턴에 걸쳐 줍니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(radius, damDesc(self, DamageType.FIRE, damage))
	end,
}

newTalent{
	name = "Acid Breath",
	kr_name = "산성 브레스",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source1@ 산을 뿜어냅니다!",
	tactical = { ATTACKAREA = { ACID = 2 } },
	range = 0,
	radius = 5,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID, self:mindCrit(self:combatTalentStatDamage(t, "wil", 30, 430)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[적들에게 산을 뿜어내, %0.2f 피해를 줍니다.
		피해량은 의지 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.ACID, self:combatTalentStatDamage(t, "wil", 30, 430)))
	end,
}

newTalent{
	name = "Lightning Breath", short_name = "LIGHTNING_BREATH_HYDRA", image = "talents/lightning_breath.png",
	kr_name = "번개 브레스",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source@ breathes lightning!",
	tactical = { ATTACKAREA = { LIGHTNING = 2 } },
	range = 0,
	radius = 5,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:combatTalentStatDamage(t, "wil", 30, 500)
		self:project(tg, x, y, DamageType.LIGHTNING, self:mindCrit(rng.avg(dam / 3, dam, 3)))
		if core.shader.active() then game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y}, {type="lightning"})
		else game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_lightning", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		end
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		return ([[적들에게 번개를 뿜어내, %d - %d 피해를 줍니다.
		피해량은 의지 능력치의 영향을 받아 증가합니다.]]):
		format(
			damDesc(self, DamageType.LIGHTNING, (self:combatTalentStatDamage(t, "wil", 30, 500)) / 3),
			damDesc(self, DamageType.LIGHTNING, self:combatTalentStatDamage(t, "wil", 30, 500))
		)
	end,
}

newTalent{
	name = "Poison Breath",
	kr_name = "독성 브레스",
	type = {"wild-gift/other",1},
	require = gifts_req1,
	points = 5,
	equilibrium = 10,
	cooldown = 8,
	message = "@Source@ breathes poison!",
	tactical = { ATTACKAREA = { NATURE = 1, poison = 1 } },
	range = 0,
	radius = 5,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.POISON, {dam=self:mindCrit(self:combatTalentStatDamage(t, "wil", 30, 460)), apply_power=self:combatMindpower()})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_slime", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[적들에게 독을 뿜어내, %d 피해를 몇 턴에 걸쳐 줍니다.
		피해량은 의지 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.NATURE, self:combatTalentStatDamage(t, "wil", 30, 460)))
	end,
}

newTalent{
	name = "Winter's Fury",
	kr_name = "겨울의 분노",
	type = {"wild-gift/other",1},
	require = gifts_req4,
	points = 5,
	equilibrium = 10,
	cooldown = 4,
	tactical = { ATTACKAREA = { COLD = 2 }, DISABLE = { stun = 1 } },
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentStatDamage(t, "wil", 30, 120) end,
	getDuration = function(self, t) return 4 end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.ICE, t.getDamage(self, t),
			3,
			5, nil,
			{type="icestorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[냉기 폭풍을 발생시켜, 주변 3 칸 반경에 %d 턴 동안 %0.2f 냉기 피해를 줍니다.
		피해를 받은 적은 25%% 확률로 빙결 상태효과에 걸립니다.
		피해량과 지속시간은 의지 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.COLD, damage), duration)
	end,
}

newTalent{
	name = "Ritch Flamespitter",
	kr_name = "불꽂뿜는 릿치 소환",
	type = {"wild-gift/summon-distance", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Ritch Flamespitter!",
	equilibrium = 2,
	cooldown = 10,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { FIRE = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.FIREBURN, self:mindCrit(self:combatTalentMindDamage(t, 30, 300)))
		game.level.map:particleEmitter(m.x, m.y, tg.radius, "ball_fire", {radius=tg.radius})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		local duration = self:callTalent(self.T_GRAND_ARRIVAL, "effectDuration")
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_FIRE_RESIST, dur=duration, p={power=self:combatTalentMindDamage(t, 15, 70)}})
		game.level.map:particleEmitter(m.x, m.y, tg.radius, "ball_fire", {radius=tg.radius})
	end,
	incStats = function(self, t, fake)
		local mp = self:combatMindpower()
		return{ 
			wil=15 + (fake and mp or self:mindCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
			cun=15 + (fake and mp or self:mindCrit(mp)) * 1.7 * self:combatTalentScale(t, 0.2, 1, 0.75),
			con=10 + self:callTalent(self.T_RESILIENCE, "incCon")
		}
	end,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 5, 0, 10, 5)) end,
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
			type = "insect", subtype = "ritch",
			display = "I", color=colors.LIGHT_RED, image = "npc/summoner_ritch.png",
			name = "ritch flamespitter", faction = self.faction,
			kr_name = "불꽃뿜는 릿치",
			desc = [[]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"ranged",
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 8,
			infravision = 10,

			combat_armor = 0, combat_def = 0,
			combat = { dam=1, atk=1, },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_RITCH_FLAMESPITTER_BOLT]=self:getTalentLevelRaw(t),
			},
			resists = { [DamageType.FIRE] = self:getTalentLevel(t)*10 },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (야생의 소환수)"
			m[#m+1] = resolvers.talents{ [self.T_FLAME_FURY]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[%d 턴 동안 불꽃뿜는 릿치를 소환하여 적과 싸우게 합니다. 릿치는 근접전에 매우 약하고 빨리 죽지만, 멀리서 적들을 불태울 수 있습니다.
		소환수의 능력치는 다음과 같습니다 : %d 의지, %d 교활함, %d 체격
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 의지와 교활함 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self, t), incStats.wil, incStats.cun, incStats.con)
	end,
}

newTalent{
	name = "Hydra",
	kr_name = "히드라 소환",
	type = {"wild-gift/summon-distance", 2},
	require = gifts_req2,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 머리 셋 달린 히드라를 소환합니다!",
	equilibrium = 5,
	cooldown = 18,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { ACID = 1, LIGHTING = 1, NATURE = 1 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, rng.table{DamageType.LIGHTNING,DamageType.ACID,DamageType.POISON}, self:mindCrit(self:combatTalentMindDamage(t, 30, 250)), {type="flame"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		game.level.map:addEffect(self,
			m.x, m.y, self:callTalent(self.T_GRAND_ARRIVAL,"effectDuration"),
			DamageType.POISON, {dam=self:combatTalentMindDamage(t, 10, 60), apply_power=self:combatMindpower()},
			self:getTalentRadius(t),
			5, nil,
			MapEffect.new{color_br=255, color_bg=255, color_bb=255, effect_shader="shader_images/poison_effect.png"},
			nil, false, false
		)
	end,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 5, 0, 10, 5)) end,
	incStats = function(self, t,fake)
		local mp = self:combatMindpower()
		return{ 
			wil=15 + (fake and mp or self:mindCrit(mp)) * 1.6 * self:combatTalentScale(t, 0.2, 1, 0.75),
			str = 18,
			con=10 + self:combatTalentScale(t, 2, 10, 0.75) + self:callTalent(self.T_RESILIENCE, "incCon")
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
			type = "hydra", subtype = "3head",
			display = "M", color=colors.GREEN, image = "npc/summoner_hydra.png",
			name = "3-headed hydra", faction = self.faction,
			kr_name = "머리3개 달린 히드라",
			desc = [[입에서 연기가 피어오르는, 기묘한 파충류 생명체입니다.]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},

			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(5,10),
			life_rating = 10,
			infravision = 10,

			combat_armor = 7, combat_def = 0,
			combat = { dam=12, atk=5, },

			resolvers.talents{
				[self.T_LIGHTNING_BREATH_HYDRA]=self:getTalentLevelRaw(t),
				[self.T_ACID_BREATH]=self:getTalentLevelRaw(t),
				[self.T_POISON_BREATH]=self:getTalentLevelRaw(t),
			},

			wild_gift_detonate = t.id,

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (야생의 소환수)"
			m[#m+1] = resolvers.talents{ [self.T_DISENGAGE]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[%d 턴 동안 머리 셋 달린 히드라를 소환하여 적과 싸우게 합니다. 히드라의 세 머리에서는 각각 독, 산성, 번개가 뿜어져 나옵니다.
		소환수의 능력치는 다음과 같습니다 : %d 의지, %d 체격, 18 힘
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 의지 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self, t), incStats.wil, incStats.con, incStats.str)
	end,
}

newTalent{
	name = "Rimebark",
	kr_name = "서리나무 소환",
	type = {"wild-gift/summon-distance", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "attack",
	message = "@Source@ summons a Rimebark!",
	equilibrium = 8,
	cooldown = 10,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK =  { COLD = 1 }, DISABLE = { stun = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), friendlyfire=false, radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		self:project(tg, m.x, m.y, DamageType.ICE, self:mindCrit(self:combatTalentMindDamage(t, 30, 300)), {type="freeze"})
	end,
	on_arrival = function(self, t, m)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t, x=m.x, y=m.y}
		local duration = self:callTalent(self.T_GRAND_ARRIVAL,"effectDuration")
		self:project(tg, m.x, m.y, DamageType.TEMP_EFFECT, {foes=true, eff=self.EFF_LOWER_COLD_RESIST, dur=duration, p={power=self:combatTalentMindDamage(t, 15, 70)}}, {type="flame"})
	end,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 5, 0, 10, 5)) end,
	incStats = function(self, t,fake)
		local mp = self:combatMindpower()
		return{ 
			wil=15 + (fake and mp or self:mindCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
			cun=15 + (fake and mp or self:mindCrit(mp)) * 1.6 * self:combatTalentScale(t, 0.2, 1, 0.75),
			con=10 + self:callTalent(self.T_RESILIENCE, "incCon")
		}
	end,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		target = game.level.map(tx, ty, Map.ACTOR)
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)

		if target == self then target = nil end

		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "immovable", subtype = "plants",
			display = "#", color=colors.WHITE,
			name = "rimebark", faction = self.faction, image = "npc/immovable_plants_rimebark.png",
			kr_name = "서리나무",
			resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/immovable_plants_rimebark.png", display_h=2, display_y=-1}}},
			desc = [[거대한 나무로, 겨울의 분노를 품고 있습니다.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, ally_compassion=10},
			ai_tactic = resolvers.tactic"ranged",
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,
			never_move = 1,

			max_life = resolvers.rngavg(120,150),
			life_rating = 16,
			infravision = 10,

			combat_armor = 15, combat_def = 0,
			combat = { dam=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), atk=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), dammod={cun=1.1} },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_WINTER_S_FURY]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (야생의 소환수)"
			m[#m+1] = resolvers.talents{ [self.T_RESOLVE]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[%d 턴 동안 서리나무를 소환하여 적과 싸우게 합니다. 서리나무는 움직이지 못하지만, 주변에 영구적인 냉기 폭풍을 만들어 주변 3 칸 반경의 적들에게 피해를 주고 빙결 상태효과를 일으킵니다.
		소환수의 능력치는 다음과 같습니다 : %d 의지, %d 교활함, %d 체격
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 의지와 교활함 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self, t), incStats.wil, incStats.cun, incStats.con)
	end,
}

newTalent{
	name = "Fire Drake",
	kr_name = "화염 드레이크 소환",
	type = {"wild-gift/summon-distance", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	message = "@Source1@ 화염 드레이크를 소환합니다!",
	equilibrium = 15,
	cooldown = 10,
	range = 5,
	requires_target = true,
	is_summon = true,
	tactical = { ATTACK = { FIRE = 2 }, DISABLE = { knockback = 2 } },
	on_pre_use = function(self, t, silent)
		if not self:canBe("summon") and not silent then game.logPlayer(self, "제압된 상태이기 때문에, 소환을 사용할 수 없습니다!") return end
		return not checkMaxSummon(self, silent)
	end,
	on_detonate = function(self, t, m)
		game.level.map:addEffect(self,
			m.x, m.y, 6,
			DamageType.FIRE, self:mindCrit(self:combatTalentMindDamage(t, 10, 70)),
			self:getTalentRadius(t),
			5, nil,
			{type="inferno"},
			nil, false, false
		)
	end,
	on_arrival = function(self, t, m)
		for i = 1, self:callTalent(self.T_GRAND_ARRIVAL, "nbEscorts") do
			-- Find space
			local x, y = util.findFreeGrid(m.x, m.y, 5, true, {[Map.ACTOR]=true})
			if not x then return end

			local NPC = require "mod.class.NPC"
			local mh = NPC.new{
				type = "dragon", subtype = "fire",
				display = "d", color=colors.RED, image = "npc/dragon_fire_fire_drake_hatchling.png",
				name = "fire drake hatchling", faction = self.faction,
				kr_name = "화염 드레이크 해츨링",
				desc = [[강력한 화염 드레이크입니다.]],
				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				inc_stats = { -- No crit chance for escorts
					str=15 + self:combatMindpower(2) * self:combatTalentScale(t, 1/6, 5/6, 0.75),
					wil=38,
					con=20 + self:combatMindpower(1.5) * self:combatTalentScale(t, 1/6, 5/6, 0.75) + self:callTalent(self.T_RESILIENCE, "incCon"), 
				},
				level_range = {self.level, self.level}, exp_worth = 0,

				max_life = resolvers.rngavg(40, 60),
				life_rating = 10,
				infravision = 10,

				combat_armor = 0, combat_def = 0,
				combat = { dam=resolvers.levelup(resolvers.rngavg(25,40), 1, 0.6), atk=resolvers.rngavg(25,60), apr=25, dammod={str=1.1} },
				on_melee_hit = {[DamageType.FIRE]=resolvers.mbonus(7, 2)},

				resists = { [DamageType.FIRE] = 100, },

				summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
				summon_time = m.summon_time,
				ai_target = {actor=m.ai_target.actor}
			}
			setupSummon(self, mh, x, y)
		end
	end,
	summonTime = function(self, t) return math.floor(self:combatScale(self:getTalentLevel(t) + self:getTalentLevel(self.T_RESILIENCE), 2, 0, 7, 5)) end,
	incStats = function(self, t,fake)
		local mp = self:combatMindpower()
		return{ 
			str=15 + (fake and mp or self:mindCrit(mp)) * 2 * self:combatTalentScale(t, 0.2, 1, 0.75),
			wil = 38,
			con=20 + (fake and mp or self:mindCrit(mp)) * 1.5 * self:combatTalentScale(t, 0.2, 1, 0.75) + self:callTalent(self.T_RESILIENCE, "incCon"),
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
			type = "dragon", subtype = "fire",
			display = "D", color=colors.RED, image = "npc/dragon_fire_fire_drake.png",
			name = "fire drake", faction = self.faction,
			kr_name = "화염 드레이크",
			desc = [[강력한 화염 드레이크입니다.]],
			autolevel = "none",
			ai = "summoned", ai_real = "tactical", ai_state = { talent_in=1, ally_compassion=10},
			stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
			inc_stats = t.incStats(self, t),
			level_range = {self.level, self.level}, exp_worth = 0,

			max_life = resolvers.rngavg(100, 150),
			life_rating = 12,
			infravision = 10,

			combat_armor = 0, combat_def = 0,
			combat = { dam=15, atk=10, apr=15 },

			resists = { [DamageType.FIRE] = 100, },

			wild_gift_detonate = t.id,

			resolvers.talents{
				[self.T_FIRE_BREATH]=self:getTalentLevelRaw(t),
				[self.T_BELLOWING_ROAR]=self:getTalentLevelRaw(t),
				[self.T_WING_BUFFET]=self:getTalentLevelRaw(t),
				[self.T_DEVOURING_FLAME]=self:getTalentLevelRaw(t),
			},

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.summonTime(self, t),
			ai_target = {actor=target}
		}
		if self:attr("wild_summon") and rng.percent(self:attr("wild_summon")) then
			m.name = m.name.." (야생의 소환수)"
			m[#m+1] = resolvers.talents{ [self.T_AURA_OF_SILENCE]=self:getTalentLevelRaw(t) }
		end
		setupSummon(self, m, x, y)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		return ([[%d 턴 동안 화염 드레이크를 소환하여 적과 싸우게 합니다. 화염 드레이크는 자신의 브레스로 적들을 태워버립니다.
		소환수의 능력치는 다음과 같습니다 : %d 힘, %d 체격, 38 의지
		소환수의 피해 증가량, 기절/속박/혼란/실명 면역력, 방어도 관통력은 시전자와 동일합니다.
		소환수의 힘과 체격 능력치는 정신력의 영향을 받아 증가합니다.]])
		:format(t.summonTime(self, t), incStats.str, incStats.con)
	end,
}
