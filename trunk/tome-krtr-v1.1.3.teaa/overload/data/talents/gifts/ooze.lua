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
	getMax = function(self, t) local _, _, max = checkMaxSummon(self, true) return math.min(max, math.max(1, math.floor(self:combatTalentScale(t, 0.5, 2.5)))) end,
	getChance = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "cun", 10, 400), 100, 20, 0, 61, 234) end, -- Limit < 100%
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
			stats = { wil=10, dex=10, mag=3, str=self:combatTalentScale(t, 0.8, 4, 0.75), con=self:combatStatScale("con", 10, 100, 0.75), cun=self:combatStatScale("cun", 10, 100, 0.75)},
			global_speed_base = 0.5,
			combat = {sound="creatures/jelly/jelly_hit"},
			combat_armor = self:combatTalentScale(t, 5, 25),
			combat_def = self:combatTalentScale(t, 5, 25, 0.75),
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
			summon_time = math.floor(self:combatTalentScale(t, 6, 10)),
			max_summon_time = math.floor(self:combatTalentScale(t, 6, 10)),
			resolvers.sustains_at_birth(),
		}
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
		당신은 (교활함 능력치와 기술 레벨에 따라) 최대 %d 마리 까지 진흙을 유지할 수 있습니다.
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
	equilibrium = 10,
	cooldown = 15,
	tactical = { PROTECT = 2, ATTACKAREA = { ARCANE = 1 } },
	getDam = function(self, t) return self:combatTalentMindDamage(t, 15, 200) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	on_pre_use = function(self, t)
		if not game.level or not self.x or not self.y then return false end
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

		self:setEffect(self.EFF_PAIN_SUPPRESSION, t.getDuration(self, t), {power=40})
		local tg = {type="ball", radius=3, range=0, talent=t, selffire=false, friendlyfire=false}
		self:project(tg, self.x, self.y, DamageType.MANABURN, self:mindCrit(t.getDam(self, t)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "acidflash", {radius=tg.radius})

		return true
	end,
	info = function(self, t)
		return ([[자신의 옆에 있는 진흙 덩어리와 합쳐져, %d 턴 동안 40%% 전체 피해 저항력을 부여받게 됩니다.
		그리고 진흙과 합쳐지는 순간 반마법적 폭발이 발생하여, %d 칸 반경에 있는 적들에게 %0.2f 마나 태우기 피해를 줍니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(t.getDuration(self, t),	3, damDesc(self, DamageType.ARCANE, t.getDam(self, t))) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Call of the Ooze",
	kr_name = "진흙 불러오기",
	type = {"wild-gift/ooze", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 5,
	cooldown = 20,
	getMax = function(self, t) local _, _, max = checkMaxSummon(self, true) return math.min(max, self:callTalent(self.T_MITOSIS, "getMax"), math.max(1, math.floor(self:combatTalentScale(t, 0.5, 2.5)))) end,
	getModHP = function(self, t) return self:combatTalentLimit(t, 1, 0.46, 0.7) end, --  Limit < 1
	action = function(self, t)
		local ot = self:getTalentFromId(self.T_MITOSIS)
		local _, cur_nb, max = checkMaxSummon(self, true, nil, "bloated_ooze")
		for i = cur_nb + 1, t.getMax(self, t) do
			ot.spawn(self, ot, ot.getMaxHP(self, ot) * t.getModHP(self, t))
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
		return ([[즉각적으로 이 지역에 있는 모든 진흙 덩어리를 불러옵니다. 만약 '유사 분열' 기술로 유지할 수 있는 최대 진흙 덩어리의 수를 채우지 못한 상태라면, 최대 %d 마리 까지의 진흙 덩어리가 '유사 분열'로 허용되는 최대 생명력의 %d%% 생명력을 가진 상태로 새로 생성됩니다.
		각각의 진흙 덩어리는 당신의 시야 내에 존재하는 임의의 적 근방으로 이동하며, 그 대상을 도발합니다.
		이 상황을 이용하여, 당신은 대상이 된 모든 적들에게 진흙 덩어리로 추가 근접 공격을 합니다. 이를 통해, 적에게 무기 피해량의 %d%% 만큼 산성 피해를 줄 수 있습니다.]]):
		format(t.getMax(self, t), t.getModHP(self, t)*100, self:combatTalentWeaponDamage(t, 0.6, 2.2) * 100)
	end,
}

newTalent{
	name = "Indiscernible Anatomy",
	kr_name = "알 수 없는 신체구조",
	type = {"wild-gift/ooze", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	critResist = function(self, t) return self:combatTalentScale(t, 20, 75) end,
	immunities = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.5) end, -- Limit < 100% immunities
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "blind_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "poison_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "disease_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "cut_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "confusion_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.critResist(self, t))
	end,
	info = function(self, t)
		return ([[몸 속의 장기들이 녹아내리고 마구 섞여, 신체의 약점을 숨깁니다.
		적에게 치명타를 받았을 경우, 치명타 배수가 %d%% 줄어듭니다 (보통 공격 이하로 떨어지지는 않습니다).
		추가적으로, 당신의 질병, 중독, 출혈, 혼란, 실명 면역력이 %d%% 증가하게 됩니다.]]):
		format(t.critResist(self, t), 100*t.immunities(self, t))
	end,
}
