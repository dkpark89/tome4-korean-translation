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

isOnMucus = function(map, x, y)
	for i, e in ipairs(map.effects) do
		if e.damtype == DamageType.MUCUS and e.grids[x] and e.grids[x][y] then return true end
	end
end

newTalent{
	name = "Mucus",
	kr_name = "점액",
	type = {"wild-gift/mucus", 1},
	require = gifts_req1,
	points = 5,
	equilibrium = 0,
	cooldown = 20,
	no_energy = true,
	tactical = { BUFF = 2, EQUILIBRIUM = 2,
		ATTACKAREA = function(self, t)
			if self:getTalentLevel(t)>=4 then return {NATURE = 1 } end
		end
	},
	getDur = function(self, t) return math.floor(self:combatTalentLimit(t, 20, 4, 6.5)) end, -- Limit < 20
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	-- note meditation recovery: local pt = 2 + self:combatTalentMindDamage(t, 20, 120) / 10 = O(<1)
	getEqui = function(self, t) return self:combatTalentMindDamage(t, 2, 8) end,
	-- Called by MUCUS effect in mod.data.timed_effects.physical.lua
	trigger = function(self, t, x, y, rad, eff) -- avoid stacking on map tile
		local oldmucus = eff and eff[x] and eff[x][y] -- get previous mucus at this spot
		if not oldmucus or oldmucus.duration <= 0 then -- make new mucus
			local mucus=game.level.map:addEffect(self,
				x, y, t.getDur(self, t),
				DamageType.MUCUS, {dam=t.getDamage(self, t), self_equi=t.getEqui(self, t), equi=1, bonus_level = 0},
				rad,
				5, nil,
				{zdepth=6, type="mucus"},
				nil, true
			)
			if eff then
				eff[x] = eff[x] or {}
				eff[x][y]=mucus
			end
		else
			if oldmucus.duration > 0 then -- Enhance existing mucus
				oldmucus.duration = t.getDur(self, t)
				oldmucus.dam.bonus_level = oldmucus.dam.bonus_level + 1
				oldmucus.dam.self_equi = oldmucus.dam.self_equi + 1
				oldmucus.dam.dam = t.getDamage(self, t) * (1+ self:combatTalentLimit(oldmucus.dam.bonus_level, 1, 0.25, 0.7)) -- Limit < 2x damage
			end
		end
	end,
	action = function(self, t)
		local dur = t.getDur(self, t)
		self:setEffect(self.EFF_MUCUS, dur, {})
		return true
	end,
	info = function(self, t)
		local dur = t.getDur(self, t)
		local dam = t.getDamage(self, t)
		local equi = t.getEqui(self, t)
		return ([[%d 턴 동안, 서 있는 장소와 지나간 자리에 점액을 만들어냅니다.
		The mucus is placed automatically every turn and lasts %d turns.
		At talent level 4 or greater, the mucus will expand to a radius 1 area from where it is placed.
		점액을 밟은 적은 독에 걸려, 5 턴 동안 매 턴마다 %0.1f 자연 피해를 입게 됩니다. (이 피해는 중첩됩니다)
		In addition, each turn, you will restore %0.1f Equilibrium while in your own mucus, and other friendly creatures in your mucus will restore 1 Equilibrium both for you and for themselves.
		The Poison damage and Equilibrium regeneration increase with your Mindpower, and laying down more mucus in the same spot will intensify its effects and refresh its duration.]]): --@@ 한글화 필요 #79~83
		format(dur, dur, damDesc(self, DamageType.NATURE, dam), equi)
	end,
}

newTalent{
	name = "Acid Splash",
	kr_name = "산성 튀기기",
	type = {"wild-gift/mucus", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 10,
	cooldown = 10,
	range = 7,
	radius = function(self, t) return 2 + (self:getTalentLevel(t) >= 5 and 1 or 0) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false} end,
	tactical = { ATTACKAREA = { ACID = 2, NATURE = 1 } },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 220) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local grids, px, py = self:project(tg, x, y, DamageType.ACID, self:mindCrit(t.getDamage(self, t)))
		if self:knowTalent(self.T_MUCUS) then
			self:callTalent(self.T_MUCUS, nil, px, py, tg.radius, self:hasEffect(self.EFF_MUCUS))
		end
		game.level.map:particleEmitter(px, py, tg.radius, "acidflash", {radius=tg.radius, tx=px, ty=py})

		local tgts = {}
		for x, ys in pairs(grids) do for y, _ in pairs(ys) do
			local target = game.level.map(x, y, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then tgts[#tgts+1] = target end
		end end

		if #tgts > 0 then
			if game.party:hasMember(self) then
				for act, def in pairs(game.party.members) do
					local target = rng.table(tgts)
					if act.summoner and act.summoner == self and act.is_mucus_ooze then
						act.inc_damage.all = (act.inc_damage.all or 0) - 50
						act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
						act.inc_damage.all = (act.inc_damage.all or 0) + 50
					end
				end
			else
				for _, act in pairs(game.level.entities) do
					local target = rng.table(tgts)
					if act.summoner and act.summoner == self and act.is_mucus_ooze then
						act.inc_damage.all = (act.inc_damage.all or 0) - 50
						act:forceUseTalent(act.T_MUCUS_OOZE_SPIT, {force_target=target, ignore_energy=true})
						act.inc_damage.all = (act.inc_damage.all or 0) + 50
					end
				end
			end
		end


		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[자연의 힘을 빌어, 지면으로부터 주변 %d 칸 반경의 산성 폭발을 일으킵니다. 폭발에 휩쓸린 적은 %0.1f 산성 피해를 입으며, 폭발한 곳에는 점액이 남게 됩니다.
		또한 동료 점액 덩어리가 존재한다면, 점액 덩어리는 산성 폭발에 닿은 대상 중 하나에게 즉시 (감소된 위력의) 슬라임을 뱉습니다. (점액 덩어리가 적을 볼 수 있는 위치에 있어야 합니다)
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, dam))
	end,
}

newTalent{ short_name = "MUCUS_OOZE_SPIT", 
	name = "Slime Spit", image = "talents/slime_spit.png",
	kr_name = "슬라임 뱉기",
	type = {"wild-gift/other",1},
	points = 5,
	equilibrium = 2,
	mesage = "@Source1@ 슬라임을 뱉습니다!",
	range = 6,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { NATURE = 2 } },
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t, selffire=false, friendlyfire=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SLIME, self:mindCrit(self:combatTalentMindDamage(t, 8, 110)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "ooze_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[%0.2f 슬라임 피해를 주는, 관통하는 슬라임을 뱉습니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.SLIME, self:combatTalentMindDamage(t, 8, 80)))
	end,
}

newTalent{
	name = "Living Mucus",
	kr_name = "살아 있는 점액",
	type = {"wild-gift/mucus", 3},
	require = gifts_req3,
	points = 5,
	mode = "passive",
	getMax = function(self, t) return math.floor(math.max(1, self:combatStatScale("cun", 0.5, 5))) end,
	getChance = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 5, 300), 50, 12.6, 26, 32, 220) end, -- Limit < 50% --> 12.6 @ 36, 32 @ 220
	getSummonTime = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	-- by MUCUS damage type in mod.data.damage_types.lua
	spawn = function(self, t)
		local notok, nb, sumlim = checkMaxSummon(self, true, 1, "is_mucus_ooze")
		if notok or nb >= t.getMax(self, t) or not self:canBe("summon") then return end

		local ps = {}
		for i, e in ipairs(game.level.map.effects) do
			if e.damtype == DamageType.MUCUS then
				for x, ys in pairs(e.grids) do for y, _ in pairs(ys) do
					if self:canMove(x, y) then ps[#ps+1] = {x=x, y=y} end
				end end
			end
		end
		if #ps == 0 then return end
		local p = rng.table(ps)

		local m = mod.class.NPC.new{
			type = "vermin", subtype = "oozes",
			display = "j", color=colors.GREEN, image = "npc/vermin_oozes_green_ooze.png",
			name = "mucus ooze",
			kr_name = "점액 덩어리",
			faction = self.faction,
			desc = "점액이 뭉쳐져 만들어진 존재입니다. 물컹거립니다.",
			sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
			sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
			sound_random = {"creatures/jelly/jelly_%d", 1, 3},
			body = { INVEN = 10 },
			autolevel = "wildcaster",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { str=10, dex=10, mag=3, con=self:combatTalentScale(t, 0.8, 4, 0.75), wil=self:combatStatScale("wil", 10, 100, 0.75), cun=self:combatStatScale("cun", 10, 100, 0.75) },
			global_speed_base = 0.7,
			combat = {sound="creatures/jelly/jelly_hit"},
			combat_armor = 1, combat_def = 1,
			rank = 1,
			size_category = 3,
			infravision = 10,
			cut_immune = 1,
			blind_immune = 1,

			resists = { [DamageType.LIGHT] = -50, [DamageType.COLD] = -50 },
			fear_immune = 1,

			blood_color = colors.GREEN,
			level_range = {self.level, self.level}, exp_worth = 0,
			max_life = 30,

			combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true, is_mucus_ooze = true,
			summon_time = t.getSummonTime(self, t),
			max_summon_time = math.floor(self:combatTalentScale(t, 6, 10)),
		}
		m:learnTalent(m.T_MUCUS_OOZE_SPIT, true, self:getTalentLevelRaw(t))
		setupSummon(self, m, p.x, p.y)
		return true
	end,
	on_crit = function(self, t)
		if game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act.summon_time = util.bound(act.summon_time + 2, 1, act.max_summon_time)
				end
			end
		else
			for _, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then
					act.summon_time = util.bound(act.summon_time + 2, 1, act.max_summon_time)
				end
			end
		end

	end,
	info = function(self, t)
		return ([[동료 점액이 주변에 대한 지각력을 가집니다.
		매 턴마다 %d%% 확률로 점액이 있는 곳에 특수한 '점액 덩어리' 가 생겨납니다.
		점액 덩어리는 %d 턴 동안 유지되며, 적에게 슬라임을 뱉는 공격을 합니다.
		최대 %d 마리의 점액 덩어리를 동시에 유지할 수 있습니다. (교활함 능력치에 따라 최대 유지량이 증가합니다)
		정신적 공격으로 치명타가 발생할 때마다, 모든 점액 덩어리들의 유지 시간이 2 턴 증가하게 됩니다.
		점액 덩어리 발생 확률은 정신력의 영향을 받아 증가합니다.]]):
		format(t.getChance(self, t), t.getSummonTime(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Oozewalk",
	kr_name = "점액의 길",
	type = {"wild-gift/mucus", 4},
	require = gifts_req4,
	points = 5,
	cooldown = 7,
	equilibrium = 10,
	range = 10,
	tactical = { CLOSEIN = 2 },
	getNb = function(self, t) return math.ceil(self:combatTalentScale(t, 1.1, 2.9, "log")) end,
	getEnergy = function(self,t)
		local tl = math.max(0, self:getTalentLevel(t) - 1.8)
		return 1-tl/(tl + 2.13)
	end,
	on_pre_use = function(self, t)
		return game.level and game.level.map and isOnMucus(game.level.map, self.x, self.y)
	end,
	action = function(self, t)
		local tg = {type="hit", nolock=true, pass_terrain=true, nowarning=true, range=self:getTalentRange(t), requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)
		if not x then return nil end
		if not isOnMucus(game.level.map, x, y) then return nil end
		if not self:canMove(x, y) then return nil end

		local energy = 1 - t.getEnergy(self, t)
		self.energy.value = self.energy.value + game.energy_to_act * self.energy.mod * energy

		self:removeEffectsFilter(function(t) return t.type == "physical" or t.type == "magical" end, t.getNb(self, t))

		game.level.map:particleEmitter(self.x, self.y, 1, "slime")
		self:move(x, y, true)
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")

		return true
	end,
	info = function(self, t)
		local nb = t.getNb(self, t)
		local energy = t.getEnergy(self, t)
		return ([[일시적으로 자신이 만들어낸 점액과 결합하여, %d 가지의 물리적 상태효과와 마법적 상태효과를 제거합니다.
		또한, 10 칸 반경 이내에서 시야 내의 점액으로 뒤덮힌 장소 중 임의의 위치로 즉시 이동할 수 있습니다.
		이 과정은 굉장히 빠르게 진행되어, 1 턴의 %d%% 만큼 시간을 소모하는 것만으로도 사용할 수 있습니다.
		이 기술은 점액 위에 서 있을 때에만 사용할 수 있습니다.]]):
		format(nb, (energy) * 100)
	end,
}
