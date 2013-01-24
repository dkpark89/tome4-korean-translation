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
	kr_display_name = "고귀한 피의 재능",
	name = "Gift of the Highborn",
	type = {"race/higher", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		self:setEffect(self.EFF_REGENERATION, 10, {power=5 + self:getWil() * 0.5})
		return true
	end,
	info = function(self, t)
		return ([[고귀한 피의 재능을 사용하여,10 턴 동안  매 턴마다 %d 생명력을 회복합니다.
		생명력 회복량은 의지 능력치의 영향을 받아 증가합니다.]]):format(5 + self:getWil() * 0.5)
	end,
}

newTalent{
	name = "Overseer of Nations",
	kr_display_name = "자연의 감시자",
	type = {"race/higher", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.sight = self.sight + 1
		self.heightened_senses = (self.heightened_senses or 0) + 1
		self.infravision = (self.infravision or 0) + 1
	end,
	on_unlearn = function(self, t)
		self.sight = self.sight - 1
		self.heightened_senses = (self.heightened_senses or 0) - 1
		self.infravision = (self.infravision or 0) - 1
	end,
	info = function(self, t)
		return ([[특별히 하고자 하는 사람이 없을 경우, 자연을 감시하는 하이어 종족의 의무는 주로 모험가 등 자신만의 길을 걷는 하이어들이 담당하게 됩니다.
		자연은 이 감시자들을 위해, 다른 사람들보다 더 멀리 볼 수 있는 힘을 줍니다.
		최대 시야 거리가 %d 칸 늘어나며, 야간 시야 반경이나 감지력도 %d 만큼 증가합니다.]]):
		format(self:getTalentLevelRaw(t), math.ceil(self:getTalentLevelRaw(t)/2))
	end,
}

newTalent{
	name = "Born into Magic",
	kr_display_name = "마법과 함께 태어난 자",
	type = {"race/higher", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_spellresist = self.combat_spellresist + 5
		self.resists[DamageType.ARCANE] = (self.resists[DamageType.ARCANE] or 0) + 5
		self.inc_damage[DamageType.ARCANE] = (self.inc_damage[DamageType.ARCANE] or 0) + 5
	end,
	on_unlearn = function(self, t)
		self.combat_spellresist = self.combat_spellresist - 5
		self.resists[DamageType.ARCANE] = (self.resists[DamageType.ARCANE] or 0) - 5
		self.inc_damage[DamageType.ARCANE] = (self.inc_damage[DamageType.ARCANE] or 0) - 5
	end,
	info = function(self, t)
		return ([[하이어 종족은 미혹의 시대 때 생겨난 인종이기 때문에, 그 근본부터 마력의 영향을 받은 종족입니다.
		그 영향으로 주문 내성이 %d, 마법 속성 피해량이 %d%%, 마법 속성 저항력이 %d%% 상승합니다.]]):
		format(self:getTalentLevelRaw(t) * 5, self:getTalentLevelRaw(t) * 5, self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Highborn's Bloom",
	kr_display_name = "잠재된 마력 발현",
	type = {"race/higher", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	tactical = { MANA = 2, VIM = 2, EQUILIBRIUM = 2, STAMINA = 2, POSITIVE = 2, NEGATIVE = 2, PARADOX = 2, PSI = 2 },
	getDuration = function(self, t) return 1 + math.ceil(self:getTalentLevelRaw(t)/2) end,
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
	kr_display_name = "불멸의 은총",
	type = {"race/shalore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 4 end,
	tactical = { DEFEND = 1 },
	action = function(self, t)
		local power = 0.1 + self:getDex() / 210
		self:setEffect(self.EFF_SPEED, 8, {power=power})
		return true
	end,
	info = function(self, t)
		return ([[불멸의 은총을 받아, 8 턴 동안 전체 속도가 %d%% 증가합니다.
		속도 증가량은 민첩 능력치의 영향을 받아 증가합니다.]]):format((0.1 + self:getDex() / 210) * 100)
	end,
}

newTalent{
	name = "Magic of the Eternals",
	kr_display_name = "불멸의 마법",
	type = {"race/shalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_physcrit = self.combat_physcrit + 2
		self.combat_spellcrit = self.combat_spellcrit + 2
		self.combat_mindcrit = self.combat_mindcrit + 2
	end,
	on_unlearn = function(self, t)
		self.combat_physcrit = self.combat_physcrit - 2
		self.combat_spellcrit = self.combat_spellcrit - 2
		self.combat_mindcrit = self.combat_mindcrit - 2
	end,
	info = function(self, t)
		return ([[샬로레 종족의 마법적 본성으로 인해, 현실이 약간 왜곡되어 모든 치명타율이 %d%% 상승합니다.]]):format(self:getTalentLevelRaw(t) * 2)
	end,
}

newTalent{
	name = "Secrets of the Eternals",
	kr_display_name = "불멸의 비밀",
	type = {"race/shalore", 3},
	require = racial_req3,
	points = 5,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
	mode = "sustained",
	no_energy = true,
	activate = function(self, t)
		self.invis_on_hit_disable = self.invis_on_hit_disable or {}
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			invis = self:addTemporaryValue("invis_on_hit", self:getTalentLevelRaw(t) * 5),
			power = self:addTemporaryValue("invis_on_hit_power", 5 + self:getMag(20, true)),
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
		최대 생명력의 15%% 이상이 한번에 감소될 경우, %d%% 확률로 5 턴 동안 투명화 상태가 됩니다. (투명 수치 +%d)]]):
		format(self:getTalentLevelRaw(t) * 5, 5 + self:getMag(20, true))
	end,
}

newTalent{
	name = "Timeless",
	kr_display_name = "셀 수 없는 시간",
	type = {"race/shalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
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
					p.dur = p.dur + self:getTalentLevelRaw(t)
				elseif e.status == "detrimental" then
					p.dur = p.dur - self:getTalentLevelRaw(t) * 2
					if p.dur <= 0 then todel[#todel+1] = eff_id end
				end
			end
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[끝없는 세월을 이 세계와 함께한 자에게, '시간'의 개념은 필멸자들의 그것과는 다릅니다.
		나쁜 상태효과의 지속시간은 %d 턴 줄어들고, 좋은 상태효과의 지속시간은 %d 턴 늘어납니다.]]):
		format(self:getTalentLevelRaw(t) * 2, self:getTalentLevelRaw(t))
	end,
}

------------------------------------------------------------------
-- Thaloren's powers
------------------------------------------------------------------
newTalentType{ type="race/thalore", name = "thalore", generic = true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "THALOREN_WRATH",
	name = "Wrath of the Woods",
	kr_display_name = "나무의 분노",
	type = {"race/thalore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { ATTACK = 1, DEFEND = 1 },
	action = function(self, t)
		self:setEffect(self.EFF_ETERNAL_WRATH, 5, {power=10 + self:getWil(10, true)})
		return true
	end,
	info = function(self, t)
		return ([[자연의 분노를 불러내, 5 턴 동안 적에게 주는 피해량은 %d%% 증가하고 적에게 받는 피해량은 %d%% 감소합니다.
		증가량 및 감소량은 의지 능력치의 영향을 받아 증가합니다.]]):format(10 + self:getWil(10, true), 10 + self:getWil(10, true))
	end,
}

newTalent{
	name = "Unshackled",
	kr_display_name = "구속되지 않는 자",
	type = {"race/thalore", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 5
		self.combat_mentalresist = self.combat_mentalresist + 5
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist - 5
		self.combat_mentalresist = self.combat_mentalresist - 5
	end,
	info = function(self, t)
		return ([[탈로레 족은 그들이 사랑하는 숲 속에서, 바깥 세계에 대한 걱정 없이 자유롭게 살아왔습니다.
		물리 내성과 정신 내성이 %d 증가합니다.]]):format(self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Guardian of the Wood",
	kr_display_name = "나무의 수호자",
	type = {"race/thalore", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("disease_immune", 0.2)
		self.resists[DamageType.BLIGHT] = (self.resists[DamageType.BLIGHT] or 0) + 4
		self.resists.all = (self.resists.all or 0) + 2
	end,
	on_unlearn = function(self, t)
		self:attr("disease_immune", -0.2)
		self.resists[DamageType.BLIGHT] = (self.resists[DamageType.BLIGHT] or 0) - 4
		self.resists.all = (self.resists.all or 0) - 2
	end,
	info = function(self, t)
		return ([[이제는 나무의 일부나 마찬가지인 탈로레 족은, 각종 오염에 대한 저항력을 가지고 있습니다.
		질병 저항력이 %d%%, 황폐화 저항력이 %d%%, 모든 저항력이 %d%% 상승합니다.]]):format(self:getTalentLevelRaw(t) * 20, self:getTalentLevelRaw(t) * 4, self:getTalentLevelRaw(t) * 2)
	end,
}

newTalent{
	name = "Nature's Pride",
	kr_display_name = "자연의 긍지",
	type = {"race/thalore", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 4 end,
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
				return
			end

			local NPC = require "mod.class.NPC"
			local m = NPC.new{
				type = "immovable", subtype = "plants",
				display = "#",
				name = "treant", color=colors.GREEN,
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
				inc_stats = { str=25 + self:getWil() * self:getTalentLevel(t) / 5, dex=18, con=10 + self:getTalentLevel(t) * 2, },

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
			if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_CORROSIVE_WORM, true, 3) end
			setupSummon(self, m, x, y)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[언제나 자연과 함께 하여, 어느 곳에서라도 나무들을 불러낼 수 있게 됩니다.
		정예 등급의 아군 나무 정령 2 마리를 8 턴 동안 소환합니다.
		나무 정령의 모든 저항력은 시전자의 황폐화 저항력과 같으며, 적들을 기절시키고 뒤로 밀어내며 도발합니다.
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
	kr_display_name = "드워프의 체질",
	type = {"race/dwarf", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DWARVEN_RESILIENCE, 8, {
			armor=5 + self:getCon() / 5,
			physical=10 + self:getCon() / 5,
			spell=10 + self:getCon() / 5,
		})
		return true
	end,
	info = function(self, t)
		return ([[드워프 특유의 체질적 특성을 끌어올려, 8 턴 동안 방어도가 %d, 주문 내성이 %d, 정신 내성이 %d 증가합니다.
		증가량은 체격 능력치의 영향을 받아 증가합니다.]]):format(5 + self:getCon() / 5, 10 + self:getCon() / 5, 10 + self:getCon() / 5)
	end,
}

newTalent{
	name = "Stoneskin",
	kr_display_name = "단단한 피부",
	type = {"race/dwarf", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("auto_stoneskin", 6)
	end,
	on_unlearn = function(self, t)
		self:attr("auto_stoneskin", -6)
	end,
	info = function(self, t)
		return ([[드워프의 피부 구조는 매우 복잡하여, 공격을 받으면 자동적으로 단단해집니다.
		근접 공격을 받을 때마다, 15%% 확률로 5 턴 동안 방어도가 %d 상승합니다.]]):format(self:getTalentLevelRaw(t) * 6)
	end,
}

newTalent{
	name = "Power is Money",
	kr_display_name = "돈=힘",
	type = {"race/dwarf", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	info = function(self, t)
		return ([[드워프에게 있어 돈은 그 어떤 것보다도 강력한 동기 요인이며, 왕국을 유지시키는 심장과도 같은 존재입니다.
		가지고 있는 돈의 양에 따라, 모든 내성 수치가 증가합니다. 
		금화 %d 개 당 모든 내성이 1 증가합니다. (최대 내성 상승량 : +%d)]]):format(90 - self:getTalentLevelRaw(t) * 5, self:getTalentLevelRaw(t) * 7)
	end,
}

newTalent{
	name = "Stone Walking",
	kr_display_name = "드워프의 벽 통과법",
	type = {"race/dwarf", 4},
	require = racial_req4,
	points = 5,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	range = 1,
	no_npc_use = true,
	getRange = function(self, t) return math.floor(1 + self:getCon(4, true) + self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		self:probabilityTravel(x, y, t.getRange(self, t))
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
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
	kr_display_name = "작은 이의 행운",
	type = {"race/halfling", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_HALFLING_LUCK, 5, {
			physical=10 + self:getCun() / 2,
			spell=10 + self:getCun() / 2,
			mind=10 + self:getCun() / 2,
		})
		return true
	end,
	info = function(self, t)
		return ([[하플링의 행운을 빌어 5 턴 동안 모든 치명타율이 %d%% , 모든 내성이 %d 상승합니다.
		상승량은 교활함 수치의 영향을 받아 증가합니다.]]):format(10 + self:getCun() / 2, 10 + self:getCun() / 2)
	end,
}

newTalent{
	name = "Duck and Dodge",
	kr_display_name = "구사일생",
	type = {"race/halfling", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	getThreshold = function(self, t) return math.max(10, (15 - self:getTalentLevelRaw(t))) / 100 end,
	getEvasionChance = function(self, t) return self:getStat("lck") end,
	getDuration = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/2) end,
	info = function(self, t)
		local threshold = t.getThreshold(self, t)
		local evasion = t.getEvasionChance(self, t)
		local duration = t.getDuration(self, t)
		return ([[뛰어난 운 덕분에, 위험한 상황이 닥쳐오면 공격을 덜 맞게 됩니다.
		최대 생명력의 %d%% 이상이 한번에 감소될 경우, %d 턴 동안 행운 수치만큼 (현재 %d%%) 공격이 맞지 않게 됩니다.]]):
		format(duration, threshold * 100, evasion)
	end,
}

newTalent{
	name = "Militant Mind",
	kr_display_name = "투쟁 정신",
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
	kr_display_name = "불굴",
	type = {"race/halfling", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 5 end,
	tactical = { DEFEND = 1,  CURE = 1 },
	getRemoveCount = function(self, t) return 1 + self:getTalentLevel(t) end,
	getDuration = function(self, t) return 1 + self:getTalentLevel(t) end,
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
		return ([[하플링의 군대는 세계에서 가장 강력한 집단 중 하나입니다. 지난 수천 년 동안, 가장 많은 전쟁을 치뤄온 종족이기도 합니다.
		그 영향을 받아 자신에게 걸린 기절, 혼절, 속박 효과를 %d 개 없애고, 해당 효과에 %d 턴 동안 면역 상태가 됩니다.
		이 기술은 사용할 때 시간이 걸리지 않습니다.]]):format(duration, count)
	end,
}

------------------------------------------------------------------
-- Orcs' powers
------------------------------------------------------------------
newTalentType{ type="race/orc", name = "orc", generic = true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "ORC_FURY",
	name = "Orcish Fury",
	kr_display_name = "오크의 분노",
	type = {"race/orc", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 4 end,
	tactical = { ATTACK = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_ORC_FURY, 5, {power=10 + self:getWil(20, true)})
		return true
	end,
	info = function(self, t)
		return ([[피와 파괴에 대한 욕망을 끌어올려, 적에게 주는 모든 피해량이 5 턴 동안 %d%% 상승합니다.
		피해 상승량은 의지 능력치의 영향을 받아 증가합니다..]]):format(10 + self:getWil(20, true))
	end,
}

newTalent{
	name = "Hold the Ground",
	kr_display_name = "버티기",
	type = {"race/orc", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 5
		self.combat_mentalresist = self.combat_mentalresist + 5
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist - 5
		self.combat_mentalresist = self.combat_mentalresist - 5
	end,
	info = function(self, t)
		return ([[오크 종족에게는 지난 수천 년 동안 다른 종족들에게 이유없이 사냥당해온 과거가 있습니다. 이 과거를 통해, 오크들은 '약한 종족'의 생존법을 익혔습니다.
		물리 내성과 정신 내성이 %d 증가합니다.]]):format(self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Skirmisher",
	kr_display_name = "척후병",
	type = {"race/orc", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.resists_pen.all = (self.resists_pen.all or 0) + 5
	end,
	on_unlearn = function(self, t)
		self.resists_pen.all = (self.resists_pen.all or 0) - 5
	end,
	info = function(self, t)
		return ([[오크 종족은 셀 수 없이 많은 전투를 보았고, 대부분 승리하였습니다.
		모든 피해 관통력이 %d%% 증가합니다.]]):format(self:getTalentLevelRaw(t) * 5)
	end,
}

newTalent{
	name = "Pride of the Orcs",
	kr_display_name = "오크의 긍지",
	type = {"race/orc", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 4 end,
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

		for i = 1, math.ceil(self:getTalentLevel(t) * 3 / 5) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end
		self:attr("allow_on_heal", 1)
		self:heal(25 + self:getCon() * 2.3)
		self:attr("allow_on_heal", -1)
		return true
	end,
	info = function(self, t)
		return ([[오크의 자부심과 의지를 통해, 전장에서 살아남습니다.
		%d 생명력을 회복하고, 나쁜 상태효과를 %d 개 제거합니다.
		기술의 효과는 체격 능력치의 영향을 받아 증가합니다.]]):format(25 + self:getCon() * 2.3, math.ceil(self:getTalentLevel(t) * 3 / 5))
	end,
}

------------------------------------------------------------------
-- Yeeks' powers
------------------------------------------------------------------
newTalentType{ type="race/yeek", name = "yeek", generic = true, description = "다양한 종족적 특성들입니다." }
newTalent{
	short_name = "YEEK_WILL",
	name = "Dominant Will",
	kr_display_name = "지배의 의지",
	type = {"race/yeek", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
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
			if not target or target.dead then return end
			if not target:canBe("instakill") or target.rank > 2 or target:attr("undead") or not target:checkHit(self:getWil(20, true) + self.level * 1.5, target.level) then
				game.logSeen(target, "%s 정신 공격을 저항했습니다!", target.name:capitalize())
				return
			end
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:takeHit(1, self)
			target:setEffect(target.EFF_DOMINANT_WILL, 4 + self:getWil(10), {src=self})
		end)
		return true
	end,
	info = function(self, t)
		return ([[대상의 정신을 지배하여, %s 턴 동안 대상을 조종합니다.
		정신 지배 효과가 끝나면 대상은 사망하며, 정예 등급 이상의 적이나 언데드에게는 사용할 수 없습니다.
		지속시간은 의지 능력치의 영향을 받아 증가합니다.]]):format(4 + self:getWil(10))
	end,
}

newTalent{
	name = "Unity",
	kr_display_name = "통합",
	type = {"race/yeek", 2},
	require = racial_req2,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self:attr("confusion_immune", 0.12)
		self:attr("silence_immune", 0.12)
		self.combat_mentalresist = self.combat_mentalresist + 4
	end,
	on_unlearn = function(self, t)
		self:attr("confusion_immune", -0.12)
		self:attr("silence_immune", -0.12)
		self.combat_mentalresist = self.combat_mentalresist - 4
	end,
	info = function(self, t)
		return ([['길'과 동화되어, 외부의 효과로부터 정신을 보호합니다.
		혼란과 침묵 저항력이 %d%% 증가하고, 정신 내성이 %d 증가합니다.]]):format(self:getTalentLevelRaw(t) * 12, self:getTalentLevelRaw(t) * 4)
	end,
}

newTalent{
	name = "Quickened",
	kr_display_name = "빠름",
	type = {"race/yeek", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	on_learn = function(self, t)
		self.global_speed_base = self.global_speed_base + 0.03
		self:recomputeGlobalSpeed()
	end,
	on_unlearn = function(self, t)
		self.global_speed_base = self.global_speed_base - 0.03
		self:recomputeGlobalSpeed()
	end,
	info = function(self, t)
		return ([[이크 종족은 빠르게 행동하고, 빠르게 생각하고, '길'을 위한 제물을 빠르게 준비합니다.
		전체 속도가 %d%% 증가합니다.]]):format(self:getTalentLevelRaw(t) * 3)
	end,
}

newTalent{
	name = "Wayist",
	kr_display_name = "'길'의 일원",
	type = {"race/yeek", 4},
	require = racial_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 50 - self:getTalentLevel(t) * 3 end,
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
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_yeek_yeek_mindslayer.png", display_h=2, display_y=-1}}},
				desc = "A wayist that came to help.",

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				rank = 3,
				life_rating = 8,
				max_life = resolvers.rngavg(50,80),
				infravision = 10,

				autolevel = "none",
				ai = "summoned", ai_real = "tactical", ai_state = { talent_in=2, },
				stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
				inc_stats = { str=25 + self:getWil() * self:getTalentLevel(t) / 5, mag=10, cun=25 + self:getWil() * self:getTalentLevel(t) / 5, wil=25 + self:getWil() * self:getTalentLevel(t) / 5, dex=18, con=10 + self:getTalentLevel(t) * 2, },

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
				ai_target = {actor=target}
			}
			if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:learnTalent(m.T_DARK_PORTAL, true, 3) end
			setupSummon(self, m, x, y)
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[이크들의 정신 통합체 '길'에 도움을 요청합니다.
		이크 정신 파괴자 3 명이 아군으로 소환됩니다.]])
	end,
}

-- Yeek's power: ID
newTalent{
	short_name = "YEEK_ID",
	name = "Knowledge of the Way",
	kr_display_name = "'길'의 지식",
	type = {"base/race", 1},
	no_npc_use = true,
	no_unlearn_last = true,
	on_learn = function(self, t) self.auto_id = 2 end,
	action = function(self, t)
		local Chat = require("engine.Chat")
		local chat = Chat.new("elisa-orb-scrying", {name="The Way"}, self, {version="yeek"})
		chat:invoke()
		return true
	end,
	info = function(self, t)
		return ([['길'과 잠시 동화되어, 이크 종족이 가진 모든 지식에 접근합니다.
		이를 통해 알 수 없었던 도구나 장비를 감정해냅니다.]])
	end,
}
