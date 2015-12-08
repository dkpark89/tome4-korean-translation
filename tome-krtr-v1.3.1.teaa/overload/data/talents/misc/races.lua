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

-- Generic requires for racial based on talent level
racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

------------------------------------------------------------------
-- Highers' powers
------------------------------------------------------------------
newTalentType{ type="race/higher", name = "higher", generic = true, description = "다양한 종족적 특성들입니다." }

newTalent{
	short_name = "HIGHER_HEAL",
	kr_name = "고귀한 피의 재능",
	name = "Gift of the Highborn",
	type = {"race/higher", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end, -- Limit >10
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self, t)
		return ([[고귀한 피의 재능을 사용하여, 10 턴 동안 매 턴마다 %d 생명력을 회복합니다.
		생명력 회복량은 의지 능력치의 영향을 받아 증가합니다.]]):format(5 + self:getWil() * 0.5)
	end,
}

newTalent{
	name = "Overseer of Nations",
	kr_name = "자연의 감시자",
	type = {"race/higher", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getSight = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getESight = function(self, t) return math.ceil(self:combatTalentScale(t, 0.3, 2.3, "log", 0, 2)) end,
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 0.4) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "blind_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "sight", t.getSight(self, t))
		self:talentTemporaryValue(p, "infravision", t.getESight(self, t))
		self:talentTemporaryValue(p, "heightened_senses", t.getESight(self, t))
	end,
	info = function(self, t)
		return ([[특별히 하고자 하는 사람이 없을 경우, 자연을 감시하는 하이어 종족의 의무는 주로 모험가 등 자신만의 길을 걷는 하이어들이 담당하게 됩니다.
		자연은 이 감시자들을 위해, 다른 사람들보다 더 멀리 볼 수 있는 힘을 줍니다.
		실명 면역력이 %d%% 증가하고, 최대 시야 거리가 %d 칸 늘어나며, 야간 시야 반경이나 감지력도 %d 만큼 증가합니다.]]):
		format(t.getImmune(self, t) * 100, t.getSight(self, t), t.getESight(self, t))
	end,
}

newTalent{
	name = "Born into Magic",
	kr_name = "마법과 함께 태어난 자",
	type = {"race/higher", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 19, 7)) end, -- Limit > 0
	getSave = function(self, t) return self:combatTalentScale(t, 5, 25, 0.75) end,
	power = function(self, t) return self:combatTalentScale(t, 7, 25) end,
	trigger = function(self, t, damtype)
		self:startTalentCooldown(t)
		self:setEffect(self.EFF_BORN_INTO_MAGIC, 5, {damtype=damtype})
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "resists",{[DamageType.ARCANE]=t.power(self, t)})
	end,
	info = function(self, t)
		local netpower = t.power(self, t)
		return ([[하이어 종족은 미혹의 시대 때 생겨난 인종이기 때문에, 그 근본부터 마력의 영향을 받은 종족입니다.
		그 영향으로 주문 내성이 %d / 마법 속성 저항력이 %d%% 상승합니다.
		또한 마법을 사용하여 피해를 줄 때마다, 해당 속성의 피해량이 5 턴 동안 15%% 증가하게 됩니다. (이 효과에는 재사용 대기시간이 있습니다)]]):
		format(t.getSave(self, t), netpower)
	end,
}

newTalent{
	name = "Highborn's Bloom",
	kr_name = "잠재된 마력 발현",
	type = {"race/higher", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 20, 47, 35)) end, -- Limit >20
	tactical = { MANA = 2, VIM = 2, EQUILIBRIUM = 2, STAMINA = 2, POSITIVE = 2, NEGATIVE = 2, PARADOX = 2, PSI = 2 },
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 2, 6.1)) end,  --  Limit to < 10
	action = function(self, t)
		self:setEffect(self.EFF_HIGHBORN_S_BLOOM, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[잠재된 마력을 활성화시켜, 기술의 원천력으로 사용합니다. %d 턴 동안, 모든 사용형 기술들을 원천력 소모 없이 사용할 수 있게 됩니다.
		기술을 사용할 수 있을 만큼의 원천력은 지니고 있어야 사용할 수 있으며, 실패율 등은 똑같이 적용됩니다.]]):format(duration)
	end,
}

------------------------------------------------------------------
-- Shaloren's powers
------------------------------------------------------------------
newTalentType{ type="race/shalore", name = "shalore", generic = true, is_spell=true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "SHALOREN_SPEED",
	name = "Grace of the Eternals",
	kr_name = "불멸의 은총",
	type = {"race/shalore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 46, 30)) end,  -- Limit to >10 turns
	getSpeed = function(self, t) return self:combatStatScale(math.max(self:getDex(), self:getMag()), 0.1, 0.476, 0.75) end,
	tactical = { DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_SPEED, 8, {power=t.getSpeed(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[불멸의 은총을 받아, 8 턴 동안 전체 속도가 %d%% 증가합니다.
		속도 증가량은 민첩 능력치와 마법 능력치 중 높은 쪽의 영향을 받아 증가합니다.]]):
		format(t.getSpeed(self, t) * 100)
	end,
}

newTalent{
	name = "Magic of the Eternals",
	kr_name = "불멸의 마법",
	type = {"race/shalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	critChance = function(self, t) return self:combatTalentScale(t, 3, 10, 0.75) end,
	critPower = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physcrit", t.critChance(self, t))
		self:talentTemporaryValue(p, "combat_spellcrit", t.critChance(self, t))
		self:talentTemporaryValue(p, "combat_mindcrit", t.critChance(self, t))
		self:talentTemporaryValue(p, "combat_critical_power", t.critPower(self, t))
	end,
	info = function(self, t)
		return ([[샬로레 종족의 마법적 특성으로 인해, 현실이 약간 왜곡되어 모든 치명타율이 %d%% / 치명타 배수가 %d%% 상승합니다.]]):
		format(t.critChance(self, t), t.critPower(self, t))
	end,
}

newTalent{
	name = "Secrets of the Eternals",
	kr_name = "불멸의 비밀",
	type = {"race/shalore", 3},
	require = racial_req3,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 47, 35)) end, -- Limit > 5
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 21, 45) end, -- Limit < 100%
	getInvis = function(self, t) return math.ceil(self:combatStatScale("mag" , 7, 25)) end,
	mode = "sustained",
	no_energy = true,
	activate = function(self, t)
		self.invis_on_hit_disable = self.invis_on_hit_disable or {}
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			invis = self:addTemporaryValue("invis_on_hit", t.getChance(self, t)),
			power = self:addTemporaryValue("invis_on_hit_power", t.getInvis(self, t)),
			talent = self:addTemporaryValue("invis_on_hit_disable", {[t.id]=1}),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("invis_on_hit", p.invis)
		self:removeTemporaryValue("invis_on_hit_power", p.power)
		self:removeTemporaryValue("invis_on_hit_disable", p.talent)
		return true
	end,
	info = function(self, t)
		return ([['에이알'의 세계에서 유일한 불멸의 종족인 샬로레는, 그들의 타고난 마법적 능력으로 자신들을 보호하는 법을 익혀왔습니다.
		최대 생명력의 10%% 이상이 한번에 감소될 경우, %d%% 확률로 5 턴 동안 투명화 상태가 됩니다. (투명 수치 +%d)]]):
		format(t.getChance(self, t), t.getInvis(self, t))
	end,
}

newTalent{
	name = "Timeless",
	kr_name = "셀 수 없는 시간",
	type = {"race/shalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	fixed_cooldown = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 20, 47, 35)) end, -- Limit to >20
	getEffectGood = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getEffectBad = function(self, t) return math.floor(self:combatTalentScale(t, 2.9, 10.01, "log")) end,
	tactical = {
		BUFF = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.status == "beneficial" then nb = nb + 1 end
			end
			return nb
		end,
		CURE = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end,
	},
	action = function(self, t)
		local target = self
		local todel = {}
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type ~= "other" then
				if e.status == "beneficial" then
					p.dur = math.min(p.dur*2, p.dur + t.getEffectGood(self, t))
				elseif e.status == "detrimental" then
					p.dur = p.dur - t.getEffectBad(self, t)
					if p.dur <= 0 then todel[#todel+1] = eff_id end
				end
			end
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and self.talents_cd[tid] and not t.fixed_cooldown then tids[#tids+1] = t end
		end
		while #tids > 0 do
			local tt = rng.tableRemove(tids)
			if not tt then break end
			self.talents_cd[tt.id] = self.talents_cd[tt.id] - t.getEffectGood(self, t)
			if self.talents_cd[tt.id] <= 0 then self.talents_cd[tt.id] = nil end
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[끝없는 세월을 이 세계와 함께한 자에게, '시간'의 개념은 필멸자들의 그것과는 다릅니다.
		나쁜 상태효과의 지속시간은 %d 턴 줄어들고, 기술의 지연시간이 %d 턴 짧아지며, 좋은 상태효과의 지속시간은 %d 턴 늘어납니다 (최대치는 현재 남은 시간의 2배까지).]]):
		format(t.getEffectBad(self, t), t.getEffectGood(self, t), t.getEffectGood(self, t))
	end,
}

------------------------------------------------------------------
-- Thaloren's powers
------------------------------------------------------------------
newTalentType{ type="race/thalore", name = "thalore", generic = true, is_nature=true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "THALOREN_WRATH",
	name = "Wrath of the Woods",
	kr_name = "나무의 분노",
	type = {"race/thalore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end, -- Limit > 5
	getPower = function(self, t) return self:combatStatScale("wil", 11, 20) end,
	tactical = { ATTACK = 1, DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_ETERNAL_WRATH, 5, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[자연의 분노를 불러내, 5 턴 동안 적에게 주는 피해량은 %d%% 증가시키고 적에게 받는 피해량은 %d%% 감소시킵니다.
		증가량 및 감소량은 의지 능력치의 영향을 받아 증가합니다.]]):
		format(t.getPower(self, t), t.getPower(self, t))
	end,
}

newTalent{
	name = "Unshackled",
	kr_name = "구속되지 않는 자",
	type = {"race/thalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getSave = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSave(self, t))
	end,
	info = function(self, t)
	return ([[탈로레 족은 그들이 사랑하는 숲 속에서, 바깥 세계에 대한 걱정 없이 자유롭게 살아왔습니다.
		물리 내성과 정신 내성이 %d 증가합니다.]]):
		format(t.getSave(self, t))
	end,
}

newTalent{
	name = "Guardian of the Wood",
	kr_name = "나무의 수호자",
	type = {"race/thalore", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getDiseaseImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.75) end, -- Limit < 100%
	getBResist = function(self, t) return self:combatTalentScale(t, 3, 10) end,
	getAllResist = function(self, t) return self:combatTalentScale(t, 2, 6.5) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "disease_immune", t.getDiseaseImmune(self, t))
		self:talentTemporaryValue(p, "resists",{[DamageType.BLIGHT]=t.getBResist(self, t)})
		self:talentTemporaryValue(p, "resists",{all=t.getAllResist(self, t)})
	end,
	info = function(self, t)
		return ([[이제는 나무의 일부나 마찬가지인 탈로레 족은, 각종 오염에 대한 저항력을 가지고 있습니다.
		질병 면역력이 %d%% / 황폐화 저항력이 %0.1f%% / 전체 저항력이 %0.1f%% 상승합니다.]]):
		format(t.getDiseaseImmune(self, t)*100, t.getBResist(self, t), t.getAllResist(self, t))
	end,
}

newTalent{
	name = "Nature's Pride",
	kr_name = "자연의 긍지",
	type = {"race/thalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 46, 34)) end, -- limit >8
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = { stun = 1, knockback = 1 } },
	range = 4,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		for i = 1, 2 do
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "소환할 자리가 없습니다!")
				if i == 1 then return else break end
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "immovable", subtype = "plants",
				display = "#",
		 		name = "treant", color=colors.GREEN,
				kr_name = "나무 정령",
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/immovable_plants_treant.png", display_h=2, display_y=-1}}},
				desc = "지각력이 있는, 매우 강력한 나무입니다.",

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				rank = 3,
				life_rating = 13,
				max_life = resolvers.rngavg(50,80),
				infravision = 10,

				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, },
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				combat = { dam=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.3), atk=resolvers.levelup(resolvers.rngavg(15,25), 1, 1.6), dammod={str=1.1} },
				inc_stats = {
					str=25 + self:combatScale(self:getWil() * self:getTalentLevel(t), 0, 0, 100, 500, 0.75),
					dex=18,
					con=10 + self:combatTalentScale(t, 3, 10, 0.75),
				},
				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,

				resists = {all = self:combatGetResist(DamageType.BLIGHT)},

				combat_armor = 13, combat_def = 8,
				resolvers.talents{ [Talents.T_STUN]=self:getTalentLevelRaw(t), [Talents.T_KNOCKBACK]=self:getTalentLevelRaw(t), [Talents.T_TAUNT]=self:getTalentLevelRaw(t), },

				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = 8,
				ai_target = {actor=target}
			}
			setupSummon(self, m, x, y)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[언제나 자연과 함께 하여, 어느 곳에서라도 나무들을 불러낼 수 있게 됩니다.
		정예 등급의 아군 나무 정령 2 마리를 8 턴 동안 소환합니다.
		나무 정령의 전체 저항력은 시전자의 황폐화 저항력과 같으며, 적들을 기절시키고 뒤로 밀어내며 도발합니다.
		나무 정령의 위력은 의지 능력치의 영향을 받아 증가합니다.]]):format()
	end,
}

------------------------------------------------------------------
-- Dwarves' powers
------------------------------------------------------------------
newTalentType{ type="race/dwarf", name = "dwarf", generic = true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "DWARF_RESILIENCE",
	name = "Resilience of the Dwarves",
	kr_name = "드워프의 체질",
	type = {"race/dwarf", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 45, 25)) end, -- Limit >8
	getParams = function(self, t)
		return {
			armor = self:combatStatScale("con", 7, 25),
			physical = self:combatStatScale("con", 12, 30, 0.75),
			spell = self:combatStatScale("con", 12, 30, 0.75),
		}
	end,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DWARVEN_RESILIENCE, 8, t.getParams(self, t))
		return true
	end,
	info = function(self, t)
		local params = t.getParams(self, t)
		return ([[드워프 특유의 체질적 특성을 끌어올려, 8 턴 동안 방어도가 %d / 주문 내성이 %d / 정신 내성이 %d 증가합니다.
		증가량은 체격 능력치의 영향을 받아 증가합니다.]]):
		format(params.armor, params.physical, params.spell)
	end,
}

newTalent{
	name = "Stoneskin",
	kr_name = "단단한 피부",
	type = {"race/dwarf", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	armor = function(self, t) return self:combatTalentScale(t, 6, 30) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "auto_stoneskin", t.armor(self, t))
	end,
	info = function(self, t)
		return ([[드워프의 피부 구조는 매우 복잡하여, 공격을 받으면 자동적으로 단단해집니다.
		근접 공격을 받을 때마다, 15%% 확률로 5 턴 동안 방어도가 %d 상승합니다.]]):
		format(t.armor(self, t))
	end,
}

newTalent{
	name = "Power is Money",
	kr_name = "돈=힘",
	type = {"race/dwarf", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getMaxSaves = function(self, t) return self:combatTalentScale(t, 8, 35) end,
	getGold = function(self, t) return self:combatTalentLimit(t, 40, 85, 65) end, -- Limit > 40
	-- called by _M:combatPhysicalResist, _M:combatSpellResist, _M:combatMentalResist in mod.class.interface.Combat.lua
	getSaves = function(self, t)
		return util.bound(self.money / t.getGold(self, t), 0, t.getMaxSaves(self, t))
	end,
	info = function(self, t)
		return ([[드워프에게 있어 돈은 그 어떤 것보다도 강력한 동기 요인이며, 왕국을 유지시키는 심장과도 같은 존재입니다.
		가지고 있는 돈의 양에 따라, 모든 내성 수치가 증가합니다. 
		금화 %d 개 당 모든 내성이 1 증가합니다. (내성 상승량 최대 : +%d, 현재 : +%d)]]):
		format(t.getGold(self, t), t.getMaxSaves(self, t), t.getSaves(self, t))
	end,
}

newTalent{
	name = "Stone Walking",
	kr_name = "드워프의 벽 통과법",
	type = {"race/dwarf", 4},
	require = racial_req4,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end, -- Limit >5
	range = 1,
	no_npc_use = true,
	getRange = function(self, t)
		return math.max(1, math.floor(self:combatScale(0.04*self:getCon() + self:getTalentLevel(t), 2.4, 1.4, 10, 9)))
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		self:probabilityTravel(x, y, t.getRange(self, t))
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		local range = t.getRange(self, t)
		return ([[드워프의 기원이 무엇인지에 대해서는 다른 종족들 사이에서 그 의견이 분분하지만, 드워프들이 암석과 깊은 유대 관계를 형성하고 있다는 사실만은 분명합니다.
		최대 %d 칸의 벽을 통과할 수 있게 됩니다. 최대 이동량은 체격 능력치와 기술 레벨의 영향을 받아 증가합니다.]]):
		format(range)
	end,
}

------------------------------------------------------------------
-- Halflings' powers
------------------------------------------------------------------
newTalentType{ type="race/halfling", name = "halfling", generic = true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "HALFLING_LUCK",
	name = "Luck of the Little Folk",
	kr_name = "작은 이의 행운",
	type = {"race/halfling", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end, -- Limit >5
	getParams = function(self, t)
		return {
			physical = self:combatStatScale("cun", 15, 60, 0.75),
			spell = self:combatStatScale("cun", 15, 60, 0.75),
			mind = self:combatStatScale("cun", 15, 60, 0.75),
			}
	end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_HALFLING_LUCK, 5, t.getParams(self, t))
		return true
	end,
	info = function(self, t)
		local params = t.getParams(self, t)
		return ([[하플링의 행운을 빌어 5 턴 동안 모든 치명타율이 %d%% , 모든 내성이 %d 상승합니다.
		상승량은 교활함 수치의 영향을 받아 증가합니다.]]):
		format(params.mind, params.mind)
	end,
}

newTalent{
	name = "Duck and Dodge",
	kr_name = "구사일생",
	type = {"race/halfling", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getThreshold = function(self, t) return math.max(10, (15 - self:getTalentLevelRaw(t))) / 100 end,
	getEvasionChance = function(self, t) return 50 end,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 1.3, 3.3)) end,
	-- called by _M:onTakeHit function in mod.class.Actor.lua for trigger 
	getDefense = function(self) 
		local oldevasion = self:hasEffect(self.EFF_EVASION)
		return self:getStat("lck")/200*(self:combatDefenseBase() - (oldevasion and oldevasion.defense or 0)) -- Prevent stacking
	end,
	info = function(self, t)
		local threshold = t.getThreshold(self, t)
		local evasion = t.getEvasionChance(self, t)
		local duration = t.getDuration(self, t)
		return ([[뛰어난 운 덕분에, 위험한 상황이 닥쳐오면 공격을 덜 맞게 됩니다.
		최대 생명력의 %d%% 이상이 한번에 감소될 경우, %d 턴 동안 회피 상태(현재 %d%%)가 되고 회피도가 %d 만큼 증가합니다 (행운 능력치와 다른 방어 관련 능력치의 영향을 받습니다).]]):
		format(threshold * 100, evasion, t.getDefense(self), duration)
	end,
}

newTalent{
	name = "Militant Mind",
	kr_name = "투쟁 정신",
	type = {"race/halfling", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[하플링은 언제나 조직적이고 체계적으로 행동합니다. 더 많은 적을 조우할 때마다, 더 냉정하고 체계적으로 행동하게 됩니다.
		시야에 2 마리 이상의 적이 보일 경우, 적 1 마리 당 물리력, 물리 내성, 주문력, 주문 내성, 정신력, 정신 내성이 %0.1f 상승합니다. (최대 5 회 중첩 가능)]]):
		format(self:getTalentLevel(t) * 1.5)
	end,
}

newTalent{
	name = "Indomitable",
	kr_name = "불굴",
	type = {"race/halfling", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end, -- limit >10
	tactical = { DEFEND = 1,  CURE = 1 },
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6, "log")) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		local effs = {}

		-- Go through all effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.stun or e.subtype.pin then -- Daze is stun subtype
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			end
		end
	
		self:setEffect(self.EFF_FREE_ACTION, t.getDuration(self, t), {})
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[하플링의 군대는 세계에서 가장 강력한 힘을 가진 집단 중 하나입니다. 지난 수천 년 동안, 가장 많은 전쟁을 치뤄온 종족이기도 합니다.
		그 영향을 받아 자신에게 걸린 기절, 혼절, 속박 효과를 %d 개 없애고, 해당 효과에 %d 턴 동안 완전 면역 상태가 됩니다.
		이 기술은 사용할 때 시간이 걸리지 않습니다.]]):format(duration, count)
	end,
}

------------------------------------------------------------------
-- Orcs' powers
------------------------------------------------------------------
newTalentType{ type="race/orc", name = "orc", generic = true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "ORC_FURY",
	kr_name = "오크의 분노",
	name = "Orcish Fury",
	type = {"race/orc", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 46, 30)) end, -- Limit to >5 turns
	getPower = function(self, t) return self:combatStatScale("wil", 12, 30) end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_ORC_FURY, 5, {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[피와 파괴에 대한 욕망을 끌어올려, 적에게 주는 모든 피해량이 5 턴 동안 %d%% 상승합니다.
		피해 상승량은 의지 능력치의 영향을 받아 증가합니다..]]):
		format(t.getPower(self, t))
	end,
}

newTalent{
	name = "Hold the Ground",
	kr_name = "버티기",
	type = {"race/orc", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getSaves = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physresist", t.getSaves(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSaves(self, t))
	end,
	info = function(self, t)
		return ([[오크 종족에게는 지난 수천 년 동안 다른 종족들에게 이유없이 사냥당해온 과거가 있습니다. 이 과거를 통해, 오크들은 '약한 종족'으로서의 생존법을 익혔습니다.
		물리 내성과 정신 내성이 %d 증가합니다.]]):
		format(t.getSaves(self, t))
	end,
}

newTalent{
	name = "Skirmisher",
	kr_name = "척후병",
	type = {"race/orc", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getPen = function(self, t) return self:combatTalentLimit(t, 20, 7, 15) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists_pen", {all = t.getPen(self, t)})
	end,
	info = function(self, t)
		return ([[오크 종족은 셀 수 없이 많은 전투를 보았고, 대부분 승리하였습니다.
		모든 피해 관통력이 %d%% 증가합니다.]]):
		format(t.getPen(self, t))
	end,
}

newTalent{
	name = "Pride of the Orcs",
	kr_name = "오크의 긍지",
	type = {"race/orc", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 46, 30)) end, -- Limit to >10
	remcount  = function(self,t) return math.ceil(self:combatTalentScale(t, 0.5, 3, "log", 0, 3)) end,
	heal = function(self, t) return 25 + 2.3* self:getCon() + self:combatTalentLimit(t, 0.1, 0.01, 0.05)*self.max_life end,
	is_heal = true,
	tactical = { DEFEND = 1, HEAL = 2, CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and (e.type == "physical" or e.type == "magical" or e.type == "mental") then
				nb = nb + 1
			end
		end
		return nb
	end },
	action = function(self, t)
		local target = self
		local effs = {}

		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.status == "detrimental" and (e.type == "physical" or e.type == "magical" or e.type == "mental") then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.remcount(self,t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end
		self:attr("allow_on_heal", 1)
		self:heal(t.heal(self, t), t)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
		self:attr("allow_on_heal", -1)
		return true
	end,
	info = function(self, t)
		return ([[오크의 자부심과 의지를 통해, 전장에서 살아남습니다.
		%d 생명력을 회복하고, 나쁜 상태효과를 %d 개 제거합니다.
		생명력 회복량은 체격 능력치의 영향을 받아 증가합니다.]]):
		format(t.heal(self, t), t.remcount(self,t))
	end,
}

------------------------------------------------------------------
-- Yeeks' powers
------------------------------------------------------------------
newTalentType{ type="race/yeek", name = "yeek", generic = true, is_mind=true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "YEEK_WILL",
	name = "Dominant Will",
	kr_name = "지배의 의지",
	type = {"race/yeek", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 47, 35)) end, -- Limit >10
	getduration = function(self) return math.floor(self:combatStatScale("wil", 5, 14)) end,
	range = 4,
	no_npc_use = true,
	requires_target = true,
	direct_hit = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target or target.dead or target == self then return end
			if not target:canBe("instakill") or target.rank > 3 or target:attr("undead") or game.party:hasMember(target) or not target:checkHit(self:getWil(20, true) + self.level * 1.5, target.level) then
				game.logSeen(target, "%s 정신 공격을 저항했습니다!", target.name:capitalize())
				return
			end
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:setEffect(target.EFF_DOMINANT_WILL, t.getduration(self), {src=self})
		end)
		return true
	end,
	info = function(self, t)
		return ([[대상의 정신을 지배하여, %s 턴 동안 대상을 조종합니다.
		정신 지배 효과가 끝나면 대상은 사망하며, 희귀함 등급 이상이거나 보스 등급의 적 그리고 언데드에게는 사용할 수 없습니다.
		지속시간은 의지 능력치의 영향을 받아 증가합니다.]]):format(t.getduration(self))
	end,
}

newTalent{
	name = "Unity",
	kr_name = "통합",
	type = {"race/yeek", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.17, 0.6) end, -- Limit < 100%
	getSave = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "confusion_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "silence_immune", t.getImmune(self, t))
		self:talentTemporaryValue(p, "combat_mentalresist", t.getSave(self, t))
	end,
	info = function(self, t)
		return ([['한길' 과 동화되어, 외부의 효과로부터 정신을 보호합니다.
		혼란과 침묵 면역력이 %d%% 증가하고, 정신 내성이 %d 증가합니다.]]):
		format(100*t.getImmune(self, t), t.getSave(self, t))
	end,
}

newTalent{
	name = "Quickened",
	kr_name = "빠름",
	type = {"race/yeek", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	speedup = function(self, t) return self:combatTalentScale(t, 0.04, 0.15, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "global_speed_base", t.speedup(self, t))
		self:recomputeGlobalSpeed()
	end,
	info = function(self, t)
		return ([[이크 종족은 빠르게 행동하고, 빠르게 생각하고, '한길' 을 위한 제물을 빠르게 준비합니다.
		전체 속도가 %0.1f%% 증가합니다.]]):format(100*t.speedup(self, t))
	end,
}

newTalent{
	name = "Wayist",
	kr_name = "'한길'의 일원",
	type = {"race/yeek", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 47, 35)) end, -- Limit >6
	range = 4,
	no_npc_use = true,
	action = function(self, t)
		local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end

		-- Find space
		for i = 1, 3 do
			local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "소환할 공간이 없습니다!")
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "humanoid", subtype = "yeek",
				display = "y",
				name = "yeek mindslayer", color=colors.YELLOW,
				kr_name = "이크 정신 파괴자",
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_yeek_yeek_mindslayer.png", display_h=2, display_y=-1}}},
				desc = "'한길'의 일원을 돕기 위해 도착한 정신 파괴자입니다.",

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				rank = 3,
				life_rating = 8,
				max_life = resolvers.rngavg(50,80),
				infravision = 10,

				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, },
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				inc_stats = {
					str=self:combatScale(self:getWil() * self:getTalentLevel(t), 25, 0, 125, 500, 0.75),
					mag=10,
					cun=self:combatScale(self:getWil() * self:getTalentLevel(t), 25, 0, 125, 500, 0.75),
					wil=self:combatScale(self:getWil() * self:getTalentLevel(t), 25, 0, 125, 500, 0.75),
					dex=18,
					con=10 + self:combatTalentScale(t, 2, 10, 0.75),
				},
				resolvers.equip{
					{type="weapon", subtype="longsword", autoreq=true},
					{type="weapon", subtype="dagger", autoreq=true},
				},

				level_range = {1, nil}, exp_worth = 0,
				silent_levelup = true,

				combat_armor = 13, combat_def = 8,
				resolvers.talents{
					[Talents.T_KINETIC_SHIELD]={base=1, every=5, max=5},
					[Talents.T_KINETIC_AURA]={base=1, every=5, max=5},
					[Talents.T_CHARGED_AURA]={base=1, every=5, max=5},
				},

				faction = self.faction,
				summoner = self, summoner_gain_exp=true,
				summon_time = 6,
				ai_target = {actor=target},
				no_drops = 1,
			}
			setupSummon(self, m, x, y)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
	return ([[이크들의 정신 통합체 '한길' 에 도움을 요청합니다.
		6 턴 동안 이크 정신 파괴자 3 명이 아군으로 소환됩니다.]])
	end,
}

-- Yeek's power: ID
newTalent{
	short_name = "YEEK_ID",
	name = "Knowledge of the Way",
	kr_name = "'한길'의 지식",
	type = {"base/race", 1},
	no_npc_use = true,
	no_unlearn_last = true,
	mode = "passive",
	on_learn = function(self, t) self.auto_id = 100 end,
	info = function(self, t)
		return ([['한길' 과 잠시 동화되어, 이크 종족이 가진 모든 지식에 접근합니다.
		이를 통해 알 수 없었던 도구나 장비를 감정해냅니다.]])
	end,
}

------------------------------------------------------------------
-- Ogre' powers
------------------------------------------------------------------
newTalentType{ type="race/ogre", name = "ogre", is_spell=true, generic = true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "OGRE_WRATH",
	name = "Ogric Wrath",
	kr_name = "오우거의 분노",
	type = {"race/ogre", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 47, 35)) end, -- Limit >10
	getduration = function(self) return math.floor(self:combatStatScale("str", 5, 12)) end,
	range = 4,
	no_npc_use = true,
	requires_target = true,
	direct_hit = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		self:setEffect(self.EFF_OGRIC_WRATH, t.getduration(self, t), {})
		return true
	end,
	info = function(self, t)
		
	--return ([[You enter an ogric wrath for %d turns, increasing your stun and pinning resistances by 20%% and all damage done by 10%%.
	--	In addition, whenever you miss a melee attack or any damage you deal is reduced by a damage shield or similar effect you gain a charge of Ogre Fury(up to 5 charges, each lasts 7 turns).
	--	Each charge grants 20%% critical damage power and 5%% critical strike chance.
	--	You lose a charge each time you deal a critical strike.
	--	The duration will increase with your Strength.]]):format(t.getduration(self))
	
	-- 없는것보다 낫다고 생각해서 부족한 실력이지만 바꿔둡니다. 추후 수정 요망.
	
	return ([[당신은 %d 턴동안 오우거의 분노에 들어가 기절과 혼란저항이 20%%만큼 상승하고 모든 피해량이 10%%만큼 증가합니다.
		또한 당신의 근접공격이 빗나가거나 모든 종류의 공격이 피해 보호막 또는 유사한효과로 감소했을경우 당신은 오우거의 광폭화를 얻게 됩니다.(이 효과는 5번까지 중첩되며 7턴동안 유지됩니다.)
		각각의 광폭화 중첩당 20%%의 치명타배율과 5%%의 치명타확률을 얻게되며, 당신이 치명타데미지를 입힐때마다 중첩이 사라집니다
		이 효과의 지속시간은 당신의 힘에의해 증가합니다.]]):format(t.getduration(self))
	
	end,
}

newTalent{
	name = "Grisly Constitution",
	kr_name = "끔찍한 육신",
	type = {"race/ogre", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	no_unlearn_last = true,
	getSave = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	getMult = function(self, t) return self:combatTalentScale(t, 15, 40) / 100 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellresist", t.getSave(self, t))
		self:talentTemporaryValue(p, "inscriptions_stat_multiplier", t.getMult(self, t))
	end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 5 then self:attr("allow_mainhand_2h_in_1h", 1) end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 4 then self:attr("allow_mainhand_2h_in_1h", -1) end
	end,
	info = function(self, t)
		--return ([[An ogre's body is acclimated to spells and inscriptions.
		--Increases spell save by %d and improves the contribution of primary stats on infusions and runes by %d%%.
		--At level 5 your body is so strong you can use a two handed weapon in your main hand while still using an offhand item.
		--When using a two handed weapon this way you suffer a 20%% physical power, spellpower and mindpower penalty, decreasing by 5%% per size category above #{italic}#big#{normal}#; also all damage procs from your offhand are reduced by 50%%.]]):
		
		-- 없는것보다 낫다고 생각해서 부족한 실력이지만 바꿔둡니다. 추후 수정 요망.
		
		return ([[오우거의 신체는 주문과 각인에 순응되어있습니다.
		주문내성이 %d 만큼 증가하고 주입물과 룬의 적용되는 능력치를 %d%% 만큼 향상시킵니다.
		기술 레벨이 5일때 당신의 신체는 강해져 양손무기를 주장비로 착용하는 도중에도 보조장비를 착용할 수 있게 됩니다.
		이런식으로 양손무기를 사용할때 물리력, 주문력 그리고 정신력에 20%% 의 불이익을 받게되며, 이 수치는 당신의 크기가 #{italic}#커질수록#{normal}#; 5%% 씩 감소합니다. 
		이 과정에서 당신의 무기를 통한 모든 추가 피해는 50%% 감소합니다.]]):
		
		format(t.getSave(self, t), t.getMult(self, t) * 100)
	end,
}

newTalent{
	name = "Scar-Scripted Flesh", short_name = "SCAR_SCRIPTED_FLESH",
	kr_name = "흉터박이",
	type = {"race/ogre", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 20, 45) end, -- Limit < 100%
	callbackOnCrit = function(self, t)
		if not rng.percent(t.getChance(self, t)) then return end
		self:alterEffectDuration(self.EFF_RUNE_COOLDOWN, -1)
		self:alterEffectDuration(self.EFF_INFUSION_COOLDOWN, -1)

		local list = {}
		for tid, c in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if t and t.is_inscription then
				list[#list+1] = tid
			end
		end
		if #list > 0 then
			local tid = rng.table(list)
			self:alterTalentCoolingdown(tid, -1)
		end
	end,
	info = function(self, t)
		--return ([[When you crit you have a %d%% chance to reduce by 1 the remaining cooldown of one of your inscriptions and of any saturations effects.
		--This effect can only happen once per turn.]]):
		
		-- 없는것보다 낫다고 생각해서 부족한 실력이지만 바꿔둡니다. 추후 수정 요망.
	
		return ([[당신이 치명타에 성공했을때 %d%% 의 확률로 하나의 각인의 대기시간과, 각인의 포화효과를 1 턴 줄입니다. 
		이 효과는 한 턴에 한 번만 발생합니다.  ]]):
		format(t.getChance(self, t))
	end,
}

newTalent{
	name = "Writ Large",
	kr_name = "뚜렷한 존재",
	type = {"race/ogre", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	no_unlearn_last = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 6, 47, 35)) end, -- Limit >6
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 5, 10)) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 5 then
			self.max_inscriptions = self.max_inscriptions + 1
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 4 then
			self.max_inscriptions = self.max_inscriptions - 1
		end
	end,
	action = function(self, t)
		self:removeEffect(self.EFF_RUNE_COOLDOWN)
		self:removeEffect(self.EFF_INFUSION_COOLDOWN)
		self:setEffect(self.EFF_WRIT_LARGE, t.getDuration(self, t), {power=1})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		--return ([[Instantly removes runic and infusion saturations.
		--For %d turns your inscriptions cooldown twice as fast.
		--At level 5 your command over inscriptions is so good that you can use one more.]]):
		
		-- 없는것보다 낫다고 생각해서 부족한 실력이지만 바꿔둡니다. 추후 수정 요망.
		
		return ([[즉시 룬과 주입물의 포화효과를 제거합니다.
		%d 턴동안 각인의 재사용 대기시간이 두 배 빨라집니다.
		5레벨이 되었을때 당신은 각인을 더욱 잘다루게 되어 한 번 더 사용할 수 있습니다.]]):
		format(t.getDuration(self, t))
	end,
}
