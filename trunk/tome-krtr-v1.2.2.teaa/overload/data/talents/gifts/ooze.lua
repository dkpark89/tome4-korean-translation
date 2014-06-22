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

newTalent{
	name = "Mitosis",
	kr_name = "유사 분열",
	type = {"wild-gift/ooze", 1},
	require = gifts_req1,
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_equilibrium = 10,
	tactical = { BUFF = 2,
		EQUILIBRIUM = function(self, t)
			if self:knowTalent(self.T_REABSORB) then return 1 end
		end
	},
	getMaxHP = function(self, t) return
		50 + self:combatTalentMindDamage(t, 30, 250) + self.max_life * self:combatTalentLimit(t, 0.25, .025, .1)
	end,
	getMax = function(self, t) local _, _, max = checkMaxSummon(self, true) return math.min(max, math.max(1, math.floor(self:combatTalentLimit(t, 6, 1, 3.1)))) end, --Limit < 6
	getChance = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "cun", 10, 400), 100, 20, 0, 61, 234) end, -- Limit < 100%
	getOozeResist = function(self, t) return self:combatTalentLimit(t, 70, 15, 30) end, --Limit < 70%
	getSummonTime = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	-- called in mod.class.Actor.onTakeHit
	spawn = function(self, t, life)
		-- check summoning limits
		if checkMaxSummon(self, true) or not self:canBe("summon") then return end
		local _, nb = checkMaxSummon(self, true, nil, "bloated_ooze")
		if nb >= t.getMax(self, t) then	return end

		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "몸을 분열시키려 했지만, 분열될 공간이 부족합니다!") 
			return
		end

		local m = mod.class.NPC.new{
			type = "vermin", subtype = "oozes",
			display = "j", color=colors.GREEN, image = "npc/vermin_oozes_bloated_ooze.png",
			name = "bloated ooze",
			kr_name = "진흙 덩어리",
			desc = "시전자의 살점으로 만들어진 진흙 덩어리입니다.",
			sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
			sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
			sound_random = {"creatures/jelly/jelly_%d", 1, 3},
			body = { INVEN = 10 },
			autolevel = "tank",
			ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=1, },
			stats = { wil=10, dex=10, mag=3, str=self:combatStatScale("wil", 10, 50, 0.75), con=self:combatStatScale("con", 10, 100, 0.75), cun=self:combatStatScale("cun", 10, 100, 0.75)},
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
			resists = { all = t.getOozeResist(self, t)},
			resists_cap = table.clone(self.resists_cap),
			fear_immune = 1,
			blood_color = colors.GREEN,
			level_range = {self.level, self.level}, exp_worth = 0,
			max_life = 30,
			life_regen = 0.1*life,
			faction = self.faction,
			combat = { dam=5, atk=self:combatStatScale("cun", 10, 100, 0.75), apr=5, damtype=DamageType.POISON },

			summoner = self, summoner_gain_exp=true, wild_gift_summon=true,
			summon_time = t.getSummonTime(self, t),
			max_summon_time = math.floor(self:combatTalentScale(t, 6, 10)),
			resolvers.sustains_at_birth(),
		}
		setupSummon(self, m, x, y)
		m.max_life = math.min(life, t.getMaxHP(self, t))
		m.life = m.max_life
		if self:isTalentActive(self.T_ACIDIC_SOIL) then
			m.life_regen = m.life_regen + self:callTalent(self.T_ACIDIC_SOIL, "getRegen")
		end

		game:playSoundNear(self, "talents/spell_generic2")

		return true
	end,
	activate = function(self, t)
		return {equil_regen = self:knowTalent(self.T_REABSORB) and self:addTemporaryValue("equilibrium_regen", -self:callTalent(self.T_REABSORB, "equiRegen"))}
	end,
	deactivate = function(self, t, p)
		if p.equil_regen then self:removeTemporaryValue("equilibrium_regen", p.equil_regen) end
		return true
	end,
	info = function(self, t)
		local xs = self:knowTalent(self.T_REABSORB) and ([[추가적으로, 이 기술이 유지되는 동안 매 턴마다 평정을 %0.1f 회복합니다.
		]]):format(self:callTalent(self.T_REABSORB, "equiRegen")) or ""
		return ([[시전자의 육체가 더욱 진흙과도 같은 상태로 변합니다.
		피해를 받을 때마다, 몸이 분열되어 시야 내의 근처에 '진흙 덩어리' 가 생성됩니다.
		진흙 덩어리의 생명력은 받은 피해량의 2 배입니다. (진흙 덩어리의 최대 생명력 : %d / 시전자의 정신력과 최대 생명력의 영향을 받아 증가)
		육체가 분열될 확률은 (%0.2f * 잃은 생명력)%% 입니다.
		한번에 최대 %d 개의 진흙 덩어리를 유지시킬 수 있으며 (기술 레벨과 소환 한계량의 영향을 받음), 시전자가 받는 모든 피해는 기술이 유지되는 한 시전자와 진흙 덩어리들이 공평하게 나눠받게 됩니다.
		진흙 덩어리들은 %d 턴 동안 유지되며, 저항력이 매우 높고 (진흙 덩어리가 직접 공격받을 경우 전체 저항력 %d%%) 생명력을 빠르게 재생합니다.
		%s육체가 분열될 확률은 교활함 능력치의 영향을 받아 증가합니다.]]):
		format(t.getMaxHP(self, t), t.getChance(self, t)*3/100, t.getMax(self, t), t.getSummonTime(self, t), t.getOozeResist(self, t), xs)
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
	equiRegen = function(self, t) return 0.2 + self:combatTalentMindDamage(t, 0, 1.4) end,
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
		이 과정에서 반마법적 폭발이 발생하여, %d 칸 반경으로 %0.1f 마나 태우기 피해를 줍니다.
		이 기술을 배우면, 유사 분열 기술이 유지되는 동안 매 턴마다 평정을 %0.1f 회복하게 됩니다.
		피해량, 지속 시간, 평정 회복량은 정신력의 영향을 받아 증가합니다.]]): 
		format(t.getDuration(self, t),	3, damDesc(self, DamageType.ARCANE, t.getDam(self, t)), t.equiRegen(self, t)) --@ 변수 순서 조정
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
	tactical = { ATTACK = { PHYSICAL = 1, ACID = 2 } },
	getMax = function(self, t) local _, _, max = checkMaxSummon(self, true) return math.min(max, self:callTalent(self.T_MITOSIS, "getMax"), math.max(1, math.floor(self:combatTalentScale(t, 0.5, 2.5)))) end,
	getModHP = function(self, t) return self:combatTalentLimit(t, 1, 0.46, 0.7) end, --  Limit < 1
	getLife = function(self, t) return self:callTalent(self.T_MITOSIS, "getMaxHP")*t.getModHP(self, t) end,
	getWepDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.7, 1.8) end,
	on_pre_use = function(self, t)
		local _, nb = checkMaxSummon(self, true, nil, "bloated_ooze")
		return nb < t.getMax(self, t)
	end,
	action = function(self, t)
		local ot = self:getTalentFromId(self.T_MITOSIS)
		local _, cur_nb, max = checkMaxSummon(self, true, nil, "bloated_ooze")
		local life = t.getLife(self, t)
		for i = cur_nb + 1, t.getMax(self, t) do
			ot.spawn(self, ot, life)
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
					self:attackTarget(target, DamageType.ACID, t.getWepDamage(self, t), true)
				end
			end
		end

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[즉각적으로 이 지역에 있는 모든 진흙 덩어리를 불러옵니다.
		만약 '유사 분열' 기술로 유지할 수 있는 최대 진흙 덩어리의 수를 채우지 못한 상태라면, 최대 %d 마리 까지의 진흙 덩어리가 생명력이 %d 인 상태로 새로 생성됩니다 ('유사 분열'로 허용되는 최대 생명력의 %d%%).
		새로이 생성된 진흙 덩어리는 당신의 시야 내에 존재하는 임의의 적 근방으로 이동하며, 그 대상을 도발합니다. (하나의 적에게 하나 이상의 진흙 덩어리가 배정되지 않습니다.)
		이 상황을 이용하여, 당신은 대상이 된 모든 적들에게 진흙 덩어리로 추가 근접 공격을 합니다. 이를 통해, 적에게 무기 피해량의 %d%% 만큼 산성 피해를 줄 수 있습니다.]]):
		format(t.getMax(self, t), t.getLife(self, t), t.getModHP(self, t)*100, t.getWepDamage(self, t) * 100)
	end,
}

newTalent{
	name = "Indiscernible Anatomy",
	kr_name = "알 수 없는 신체구조",
	type = {"wild-gift/ooze", 4},
	require = gifts_req4,
	points = 5,
	mode = "passive",
	--compare to lethality: self:combatTalentScale(t, 7.5, 25, 0.75)
	critResist = function(self, t) return self:combatTalentScale(t, 15, 50, 0.75) end,
	immunities = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.7) end, -- Limit < 100% immunities
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "blind_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "poison_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "disease_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "cut_immune", t.immunities(self, t))
		self:talentTemporaryValue(p, "ignore_direct_crits", t.critResist(self, t))
	end,
	info = function(self, t)
		return ([[몸 속의 장기들이 불명료하게 되어, 신체의 약점을 숨깁니다.
		적에게 치명타를 받았을 경우, 치명타 배수가 %d%% 줄어듭니다 (보통 공격 이하로 떨어지지는 않습니다).
		추가적으로, 당신의 질병, 중독, 출혈, 실명 면역력이 %d%% 증가하게 됩니다.]]):
		format(t.critResist(self, t), 100*t.immunities(self, t))
	end,
}
