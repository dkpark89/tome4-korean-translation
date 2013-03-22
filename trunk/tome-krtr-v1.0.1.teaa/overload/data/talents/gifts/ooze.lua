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

newTalent{
	name = "Mitosis",
	kr_name = "유사 분열",
	type = {"wild-gift/ooze", 1},
	require = gifts_req1,
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_equilibrium = 10,
	tactical = { BUFF = 2 },
	getMaxHP = function(self, t) return 50 + self:combatTalentMindDamage(t, 30, 250) end,
	getMax = function(self, t) return math.max(1, math.floor(self:getCun() / 10)) end,
	getChance = function(self, t) return 25 + math.floor(self:getCun() / 3) end,
	spawn = function(self, t, life)
		if checkMaxSummon(self, true) or not self:canBe("summon") then return end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "소환할 공간이 없습니다!")
			return
		end

		local m = mod.class.NPC.new{
			type = "vermin", subtype = "oozes",
			display = "j", color=colors.GREEN, image = "npc/vermin_oozes_bloated_ooze.png",
			name = "bloated ooze",
			kr_name = "진흙 덩어리",
			desc = "당신의 살점으로 만들어진 진흙 덩어리입니다.",
			sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
			sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
			sound_random = {"creatures/jelly/jelly_%d", 1, 3},
			body = { INVEN = 10 },
			autolevel = "tank",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { wil=10, dex=10, mag=3, str=self:getTalentLevel(t) / 5 * 4, con=self:getWil(), cun=self:getCun() },
			global_speed_base = 0.5,
			combat = {sound="creatures/jelly/jelly_hit"},
			combat_armor = self:getTalentLevel(t) * 5, combat_def = self:getTalentLevel(t) * 5,
			rank = 1,
			size_category = 3,
			infravision = 10,
			cut_immune = 1,
			blind_immune = 1,
			bloated_ooze = 1,

			resists = { all = 50 },
			fear_immune = 1,

			blood_color = colors.GREEN,
			level_range = {self.level, self.level}, exp_worth = 0,
			max_life = 30,
			life_regen = 0,

			combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			max_summon_time = math.ceil(self:getTalentLevel(t)) + 5,
			resolvers.sustains_at_birth(),
		}
		if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_BONE_SHIELD, true, 2) end
		setupSummon(self, m, x, y)
		m.max_life = life
		m.life = life
		if self:isTalentActive(self.T_ACIDIC_SOIL) then
			local st = self:getTalentFromId(self.T_ACIDIC_SOIL)
			m.life_regen = st.getRegen(self, st) * life / 100
		end

		game:playSoundNear(self, "talents/spell_generic2")

		return true
	end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[당신의 육체가 더욱 진흙과도 같은 상태로 변합니다.
		공격을 받으면 %d%% 확률로 몸이 분열되어, 당신이 받은 피해량만큼의 생명력을 가진 '진흙 덩어리' 가 생성됩니다, (진흙 덩어리의 최대 생명력 : %d)
		당신이 받는 모든 피해량은 당신과 진흙 덩어리가 나눠서 받게 됩니다.
		당신은 (교활함 능력치에 따라) 최대 %d 마리 까지 진흙 덩어리를 유지할 수 있습니다.
		진흙 덩어리는 피해에 대한 탄력이 매우 뛰어납니다. (50%% 전체 피해 저항력) 단, 당신을 통해서 전달되는 피해에는 이 효과가 적용되지 않습니다.
		진흙 덩어리의 최대 생명력은 정신력의 영향을 받아 증가하고, 발생 확률은 교활함의 영향을 받아 증가합니다.]]):
		format(t.getChance(self, t), t.getMaxHP(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Reabsorb",
	kr_name = "재흡수",
	type = {"wild-gift/ooze", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 1,
	cooldown = 12,
	tactical = { PROTECT = 2, ATTACKAREA = { ARCANE = 1 } },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 15, 200) end,
	on_pre_use = function(self, t)
		if not game.level then return false end
		for _, coor in pairs(util.adjacentCoords(self.x, self.y)) do
			local act = game.level.map(coor[1], coor[2], Map.ACTOR)
			if act and act.summoner == self and act.bloated_ooze then
				return true
			end
		end
		return false
	end,
	action = function(self, t)
		local possibles = {}
		for _, coor in pairs(util.adjacentCoords(self.x, self.y)) do
			local act = game.level.map(coor[1], coor[2], Map.ACTOR)
			if act and act.summoner == self and act.bloated_ooze then
				possibles[#possibles+1] = act
			end
		end
		if #possibles == 0 then return end

		local act = rng.table(possibles)
		act:die(self)

		self:setEffect(self.EFF_PAIN_SUPPRESSION, math.ceil(3 + self:getTalentLevel(t)), {power=50})

		local tg = {type="ball", radius=3, range=0, talent=t, selffire=false, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.MANABURN, self:mindCrit(t.getDam(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "acidflash", {radius=tg.radius})

		return true
	end,
	info = function(self, t)
		return ([[자신의 옆에 있는 진흙 덩어리와 합쳐져, %d 턴 동안 50%% 전체 피해 저항력을 부여받게 됩니다.
		그리고 진흙과 합쳐지는 순간 반마법적 폭발이 발생하여, %d 칸 반경에 있는 적들에게 %0.2f 마나 태우기 피해를 줍니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(
			math.ceil(3 + self:getTalentLevel(t)),
			3,
			damDesc(self, DamageType.ARCANE, t.getDam(self, t))
		) --@@ 변수 순서 조정
	end,
}

newTalent{
	name = "Call of the Ooze",
	kr_name = "진흙 불러오기",
	type = {"wild-gift/ooze", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 8,
	action = function(self, t)
		local ot = self:getTalentFromId(self.T_MITOSIS)
		for i = 1, math.floor(self:getTalentLevel(t)) do
			ot.spawn(self, ot, self:combatTalentMindDamage(t, 30, 300))
		end

		local list = {}
		if game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.bloated_ooze then list[#list+1] = act end
			end
		else
			for _, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.is_mucus_ooze then list[#list+1] = act	end
			end
		end

		local tg = {type="ball", radius=self.sight}
		local grids = self:project(tg, self.x, self.y, function() end)
		local tgts = {}
		for x, ys in pairs(grids) do for y, _ in pairs(ys) do
			local target = game.level.map(x, y, Map.ACTOR)
			if target and self:reactionToward(target) < 0 then tgts[#tgts+1] = target end
		end end

		while #tgts > 0 and #list > 0 do
			local ooze = rng.tableRemove(list)
			local target = rng.tableRemove(tgts)

			local tx, ty = util.findFreeGrid(target.x, target.y, 10, true, {[Map.ACTOR]=true})
			if tx then
				local ox, oy = ooze.x, ooze.y
				ooze:move(tx, ty, true)
				if config.settings.tome.smooth_move > 0 then
					ooze:resetMoveAnim()
					ooze:setMoveAnim(ox, oy, 8, 5)
				end
				if core.fov.distance(tx, ty, target.x, target.y) <= 1 then
					target:setTarget(ooze)
					self:attackTarget(target, DamageType.ACID, self:combatTalentWeaponDamage(t, 0.6, 2.2), true)
				end
			end
		end

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[즉각적으로 이 지역에 있는 모든 진흙 덩어리를 불러옵니다. 만약 '유사 분열' 기술로 유지할 수 있는 최대 진흙 덩어리의 수를 채우지 못한 상태라면, 최대 %d 마리 까지의 진흙 덩어리가 새로 생성됩니다. (진흙 덩어리의 생명력 : %d)
		각각의 진흙 덩어리는 당신의 시야 내에 존재하는 임의의 적 근방으로 이동하며, 그 대상을 도발합니다.
		이 상황을 이용하여, 당신은 대상이 된 모든 적들에게 진흙 덩어리로 추가 근접 공격을 합니다. 이를 통해, 적에게 무기 피해량의 %d%% 만큼 산성 피해를 줄 수 있습니다.]]):
		format(self:getTalentLevel(t), self:combatTalentMindDamage(t, 30, 300), self:combatTalentWeaponDamage(t, 0.6, 2.2) * 100)
	end,
}

newTalent{
	name = "Indiscernible Anatomy",
	kr_name = "알 수 없는 신체구조",
	type = {"wild-gift/ooze", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("blind_immune", 0.2)
		self:attr("poison_immune", 0.2)
		self:attr("disease_immune", 0.2)
		self:attr("cut_immune", 0.2)
		self:attr("confusion_immune", 0.2)
		self:attr("ignore_direct_crits", 15)
	end,
	on_unlearn = function(self, t)
		self:attr("blind_immune", -0.2)
		self:attr("poison_immune", -0.2)
		self:attr("disease_immune", -0.2)
		self:attr("cut_immune", -0.2)
		self:attr("confusion_immune", -0.2)
		self:attr("ignore_direct_crits", -15)
	end,
	info = function(self, t)
		return ([[몸 속의 장기들이 녹아내리고 마구 섞여, 치명타를 잘 받지 않게 됩니다.
		적에게 치명타를 받았을 경우, 이를 %d%% 확률로 보통 공격이 되게 만듭니다.
		추가적으로, 당신의 질병, 중독, 출혈, 혼란 면역력이 %d%% 증가하게 됩니다.]]):
		format(self:getTalentLevelRaw(t) * 15, self:getTalentLevelRaw(t) * 20)
	end,
}
