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

require "engine.krtrUtils"

-- TODO:  More greater suffix psionic; more lesser suffix and prefix psionic

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

-------------------------------------------------------
--Nature and Antimagic---------------------------------
-------------------------------------------------------
newEntity{
	power_source = {nature=true},
	name = "blooming ", prefix=true, instant_resolve=true,
	kr_name = "꽃피우는 ",
	keywords = {blooming=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		heal_on_nature_summon = resolvers.mbonus_material(50, 10),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "gifted ", prefix=true, instant_resolve=true,
	kr_name = "천부적인 ",
	keywords = {gifted=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
	},
}

newEntity{
	power_source = {nature=true},
	name = "nature's ", prefix=true, instant_resolve=true,
	kr_name = "자연적인 ",
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		disease_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of balance", suffix=true, instant_resolve=true,
	kr_name = "균형의 ",
	keywords = {balance=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		combat_physresist = resolvers.mbonus_material(8, 2),
		combat_spellresist = resolvers.mbonus_material(8, 2),
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the jelly", suffix=true, instant_resolve=true,
	kr_name = "젤리의 ",
	keywords = {jelly=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		inc_damage={
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
		},
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	kr_name = "생명의 ",
	keywords = {life=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		max_life = resolvers.mbonus_material(40, 10),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {antimagic=true},
	name = " of slime", suffix=true, instant_resolve=true,
	kr_name = "끈적임의 ",
	keywords = {slime=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={
			[DamageType.ITEM_NATURE_SLOW] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		}
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "manaburning ", prefix=true, instant_resolve=true,
	kr_name = "마나를 태우는 ",
	keywords = {manaburning=true},
	level_range = {1, 50},
	rarity = 20,
	cost = 40,
	combat = {
		melee_project = {
			[DamageType.ITEM_ANTIMAGIC_MANABURN] = resolvers.mbonus_material(15, 10),
		},
	},
	wielder = {
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "inquisitor's ", prefix=true, instant_resolve=true,
	kr_name = "종교재판 ",
	keywords = {inquisitors=true},
	level_range = {30, 50},
	rarity = 45,
	greater_ego = 1,
	cost = 40,
	combat = {
		melee_project = {
			[DamageType.ITEM_ANTIMAGIC_MANABURN] = resolvers.mbonus_material(15, 10),
		},
		special_on_crit = {desc="주문 에너지를 태워, 재사용 대기시간을 발생시킴", fct=function(combat, who, target)
			local turns = 1 + math.ceil(who:combatMindpower() / 20)
			local check = math.max(who:combatSpellpower(), who:combatMindpower(), who:combatAttack())
			if not who:checkHit(check, target:combatMentalResist()) then game.logSeen(target, "%s 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가")) return nil end

			local tids = {}
			for tid, lev in pairs(target.talents) do
				local t = target:getTalentFromId(tid)
				if t and not target.talents_cd[tid] and t.mode == "activated" and t.is_spell and not t.innate then tids[#tids+1] = t end
			end

			local t = rng.tableRemove(tids)
			if not t then return nil end
			local damage = t.mana or t.vim or t.positive or t.negative or t.paradox or 0
			target.talents_cd[t.id] = turns

			local tg = {type="hit", range=1}
			damage = util.getval(damage, target, t)
			if type(damage) ~= "number" then damage = 0 end
			who:project(tg, target.x, target.y, engine.DamageType.ARCANE, damage)

			game.logSeen(target, "%s의 %s #ORCHID#불타#LAST#오릅니다!", (target.kr_name or target.name):capitalize(), (t.kr_name or t.name):addJosa("가"))
		end},
	},
	wielder = {
		inc_damage={
			[DamageType.ARCANE] = resolvers.mbonus_material(8, 2),
		},
		combat_spellresist = resolvers.mbonus_material(8, 2),
	},
}


newEntity{
	power_source = {antimagic=true},
	name = " of persecution", suffix=true, instant_resolve=true,
	kr_name = "박해의 ",
	keywords = {disruption=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 50,
	cost = 40,
	combat = {
		inc_damage_type = {
			unnatural=resolvers.mbonus_material(25, 5),
		},
		special_on_hit = {desc="주문 사용을 방해", fct=function(combat, who, target)
			local check = math.max(who:combatSpellpower(), who:combatMindpower(), who:combatAttack())
			target:setEffect(target.EFF_SPELL_DISRUPTION, 10, {src=who, power = 10, max = 50, apply_power=check})
		end},
	},
}

-------------------------------------------------------
--Psionic----------------------------------------------
-------------------------------------------------------
newEntity{
	power_source = {psionic=true},
	name = "horrifying ", prefix=true, instant_resolve=true,
	kr_name = "무시무시한 ",
	keywords = {horrifying=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		on_melee_hit={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
			[DamageType.DARKNESS] = resolvers.mbonus_material(8, 2),
		},
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	kr_name = "명석함의 ",
	keywords = {clarity=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		max_psi = resolvers.mbonus_material(40, 10),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "creative ", prefix=true, instant_resolve=true,
	kr_name = "창의적인 ",
	keywords = {creative=true},
	level_range = {1, 50},
	rarity = 4,
	cost = 8,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(6, 2),
		},
		combat_critical_power = resolvers.mbonus_material(20, 5),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of resolve", suffix=true, instant_resolve=true,
	kr_name = "결심의 ",
	keywords = {resolve=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(6, 2),
		},
		combat_physresist = resolvers.mbonus_material(8, 2),
	},
}

newEntity{
	power_source = {psionic=true},
	name = "hungering ", prefix=true, instant_resolve=true,
	kr_name = "갈망하는 ",
	keywords = {hungering=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		talents_types_mastery = {
			["psionic/voracity"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
			["cursed/dark-sustenance"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		hate_per_kill = resolvers.mbonus_material(4, 1),
		psi_per_kill = resolvers.mbonus_material(4, 1),
	},

	charm_power = resolvers.mbonus_material(80, 20),
	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm(function(self, who) 
		return ("%0.2f 의 정신 피해를 입히고(range 10), 염력과 증오를 피해량의 1/10 만큼 얻습니다"):format(who:damDesc(engine.DamageType.MIND, self.use_power.damage(self, who)))
		end,
		20,
		function(self, who)
			local tg = {type="hit", range=10,}
			local x, y, target = who:getTarget(tg)
			if not x or not y then return nil end
			if target then
				if target:checkHit(who:combatMindpower(), target:combatMentalResist(), 0, 95, 5) then
					local damage = self.use_power.damage(self, who)
					who:project(tg, x, y, engine.DamageType.MIND, {dam=damage, alwaysHit=true}, {type="mind"})
					who:incPsi(damage/10)
					who:incHate(damage/10)
				else
					game.logSeen(target, "%s 정신 공격을 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				end
			end
			game.logSeen(who, "%s 는 %s 를 이용해 정신적 습격을 가합니다!", who.name:capitalize(), self:getName({no_add_name = true}))
			return {id=true, used=true}
		end,
		"T_GLOBAL_CD",
		{damage = function(self, who) return self:getCharmPower(who) + (who:combatMindpower() * (1 + self.material_level/5)) end}
	),
}

newEntity{
	power_source = {psionic=true},
	name = " of nightfall", suffix=true, instant_resolve=true,
	kr_name = "황혼의 ",
	keywords = {nightfall=true},
	level_range = {30, 50},
	rarity = 30,
	cost = 40,
	wielder = {
		inc_damage={
			[DamageType.DARKNESS] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.DARKNESS] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(16, 4),
		},
		blind_immune = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end),
		talents_types_mastery = {
			["cursed/darkness"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
}

------------------------------------------------
-- Mindstar Sets -------------------------------
------------------------------------------------
local other_hand = function(object, who, inven_id)
	if inven_id == "MAINHAND" then return "OFFHAND" end
	if inven_id == "OFFHAND" then return "MAINHAND" end
end

local set_complete

local set_broken = function(self, who, inven_id, set_objects)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#SLATE#마석과의 연결이 끊어졌습니다.")
	end
end

-- Wild Cards: Capable of completing other sets
newEntity{
	power_source = {nature=true},
	name = "harmonious ", prefix=true, instant_resolve=true,
	kr_name = "조화로운 ",
	keywords = {harmonious=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		equilibrium_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		talents_types_mastery = {
			["wild-gift/harmony"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
		inc_damage={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.NATURE] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_harmonious = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_nature", true, inven_id = other_hand,},},},
	set_desc = {
		harmonious = "이 조화로운 마석은 다른 자연의 마석과 짝을 이룰겁니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.harmonious(self, who, inven_id, set_objects)
				end
			end
		end,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,},
}

newEntity{
	power_source = {antimagic=true},
	name = "purifying ", prefix=true, instant_resolve=true,
	kr_name = "정화의 ",
	keywords = {purifying=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.ITEM_ANTIMAGIC_MANABURN] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.ARCANE] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.ARCANE] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.ARCANE] = resolvers.mbonus_material(8, 2),
		},
	},
	resolvers.charmt(Talents.T_DESTROY_MAGIC, {3,4,5}, 30),
	ms_set_harmonious = true, ms_set_resonating = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_nature", true, inven_id = other_hand,},},
		resonating = {{"ms_set_psionic", true, inven_id = other_hand,},},
	},
	set_desc = {
		purifying = "이 정화하는 마석은 다른 마석을 정화 할 겁니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.harmonious(self, who, inven_id, set_objects)
				end
			end
		end,
		resonating = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.resonating(self, who, inven_id, set_objects)
				end
			end
		end,
	},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		resonating = set_broken,},
}

newEntity{
	power_source = {psionic=true},
	name = "resonating ", prefix=true, instant_resolve=true,
	kr_name = "공명하는 ",
	keywords = {resonating=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		damage_resonance = resolvers.mbonus_material(20, 5),
		psi_regen_when_hit = resolvers.mbonus_material(20, 5, function(e, v) v=v/10 return 0, v end),
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.MIND] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_resonating = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_psionic", true, inven_id = other_hand,},},},
	set_desc = {
		resonating = "이 마석은 다른 정신적인 마석과 공명 할 것 입니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.resonating(self, who, inven_id, set_objects)
				end
			end
		end,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,},
}

newEntity{
	power_source = {psionic=true},
	name = "honing ", prefix=true, instant_resolve=true,
	kr_name = "연마하는 ",
	keywords = {honing=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		inc_damage={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		resists_pen={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 1),
		},
	},
	ms_set_resonating = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_psionic", true, inven_id = other_hand,},},},
	set_desc = {
		honing = "이 연마하는 마석은 다른 정신적인 마석에 집중 할 것입니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.resonating(self, who, inven_id, set_objects)
				end
			end
		end,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,},
}

newEntity{
	power_source = {psionic=true},
	name = "parasitic ", prefix=true, instant_resolve=true,
	kr_nmae = "기생충의 ",
	keywords = {parasitic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		hate_on_crit = resolvers.mbonus_material(5, 1),
		max_hate = resolvers.mbonus_material(20, 5),
		life_leech_chance = resolvers.mbonus_material(20, 5),
		life_leech_value = resolvers.mbonus_material(20, 5),
	},
	ms_set_resonating = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_psionic", true, inven_id = other_hand,},},},
	set_desc = {
		parasitic = "이 기생하는 마석은 다른 정신적인 마석으로부터 힘을 뺏을 것입니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = function(self, who, inven_id, set_objects)
			for _, d in ipairs(set_objects) do
				if d.object ~= self then
					return d.object.on_set_complete.resonating(self, who, inven_id, set_objects)
				end
			end
		end,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,},
}

set_complete = function(self, who, inven_id, set_objects)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREEN#마석이 자연의 순수함과 공명하기 시작합니다.")
	end
	self:specialSetAdd({"wielder","nature_summon_regen"}, self.material_level)
end


-- Caller's Set: For summoners!
newEntity{
	power_source = {nature=true},
	name = "caller's ", prefix=true, instant_resolve=true,
	kr_name = "소환수 ",
	keywords = {callers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		inc_damage = {
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
		resists_pen = {
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_callers_callers = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		callers = {{"ms_set_callers_summoners", true, inven_id = other_hand,},},},
	set_desc = {
		callers = "이 자연적인 마석은 소환사를 필요로 하고 있습니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		callers = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		callers = set_broken,},
}

set_complete = function(self, who, inven_id, set_objects)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREEN#마석이 자연의 순수함과 공명하기 시작합니다.")
	end
	self:specialSetAdd({"wielder","nature_summon_max"}, 1)
end

newEntity{
	power_source = {nature=true},
	name = "summoner's ", prefix=true, instant_resolve=true,
	kr_name = "소환사 ",
	keywords = {summoners=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
	},
	ms_set_callers_summoners = true, ms_set_nature = true,
	set_list = {
			multiple = true,
			harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
			callers = {{"ms_set_callers_callers", true, inven_id = other_hand,},},},
	set_desc = {
		summoners = "이 자연적인 마석은 소환수를 소환하고 있습니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		callers = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		callers = set_broken,},
}

-- Drake sets; these may seem odd but they're designed to keep sets from over writing each other when resolved
-- Basically it allows a set on suffix without a set_list, keeps the drop tables balanced without being bloated, and allows one master item to complete multiple subsets
set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#몸 안에서 활발한 용의 영혼이 느껴집니다!")
	end
	self:specialSetAdd({"wielder","blind_immune"}, self.material_level / 10)
	self:specialSetAdd({"wielder","stun_immune"}, self.material_level / 10)
end

newEntity{
	power_source = {nature=true}, define_as = "MS_EGO_SET_WYRM",
	name = "wyrm's ", prefix=true, instant_resolve=true,
	kr_name = "용 ",
	keywords = {wyrms=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
		},
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(8, 2),
			[DamageType.COLD] = resolvers.mbonus_material(8, 2),
			[DamageType.FIRE] = resolvers.mbonus_material(8, 2),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(8, 2),
			[DamageType.ACID] = resolvers.mbonus_material(8, 2),
		},
	},
	ms_set_wyrm = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_drake", true, inven_id = other_hand,},},},
	set_desc = {
		wyrm = "이 자연적인 용은 원소를 찾고 있습니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#몸 안에서 활발한 용의 영혼이 느껴집니다!")
	end
	self:specialSetAdd({"wielder","global_speed_add"}, self.material_level / 100)
end


newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of flames", suffix=true, instant_resolve=true,
	kr_name = "불꽃의 ",
	keywords = {flames=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(16, 4),
		},
		global_speed_add = resolvers.mbonus_material(5, 1, function(e, v) v=v/100 return 0, v end),
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	set_desc = {
		flames = "이 자연적인 화염은 용에게 돌아가야만 합니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#몸 안에서 활발한 용의 영혼이 느껴집니다!")
	end
	self:specialSetAdd({"wielder","combat_armor"}, self.material_level * 3)
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of frost", suffix=true, instant_resolve=true,
	kr_name = "냉기의 ",
	keywords = {frost=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_armor = resolvers.mbonus_material(5, 5),
		on_melee_hit={
			[DamageType.ICE] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.COLD] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.COLD] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(16, 4),
		},
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	set_desc = {
		frost = "이 자연적인 냉기는 용에게 돌아가야만 합니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#몸 안에서 활발한 용의 영혼이 느껴집니다!")
	end
	self:specialSetAdd({"wielder","combat_physresist"}, self.material_level * 2)
	self:specialSetAdd({"wielder","combat_spellresist"}, self.material_level * 2)
	self:specialSetAdd({"wielder","combat_mentalresist"}, self.material_level * 2)
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of sand", suffix=true, instant_resolve=true,
	kr_name = "모래의 ",
	keywords = {sand=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.PHYSICAL] = resolvers.mbonus_material(16, 4),
		},
	},
	resolvers.charmt(Talents.T_BURROW, 1, 30),
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	set_desc = {
		sand = "이 자연적인 모래는 용에게 돌아가야만 합니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#몸 안에서 활발한 용의 영혼이 느껴집니다!")
	end
	local Stats = require "engine.interface.ActorStats"
	self:specialSetAdd({"wielder","inc_stats"}, {
											 [Stats.STAT_STR] = self.material_level,
											 [Stats.STAT_DEX] = self.material_level,
											 [Stats.STAT_CON] = self.material_level,
											 [Stats.STAT_MAG] = self.material_level,
											 [Stats.STAT_WIL] = self.material_level,
											 [Stats.STAT_CUN] = self.material_level,})
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of storms", suffix=true, instant_resolve=true,
	kr_name = "폭풍의 ",
	keywords = {storms=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(16, 4),
		},
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 1),
		},
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	set_desc = {
		storms = "이 자연적인 폭풍은 용에게 돌아가야만 합니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#PURPLE#You feel the spirit of the wyrm stirring inside you!")
	end
	local Stats = require "engine.interface.ActorStats"
	self:specialSetAdd({"wielder","life_regen"}, self.material_level/2)
end

newEntity{
	power_source = {nature=true}, is_drake_star = true,
	name = " of venom", suffix=true, instant_resolve=true,
	kr_name = "맹독의 ",
	keywords = {venom=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		on_melee_hit={
			[DamageType.ACID] = resolvers.mbonus_material(16, 4),
		},
		inc_damage={
			[DamageType.ACID] = resolvers.mbonus_material(16, 4),
		},
		resists_pen={
			[DamageType.ACID] = resolvers.mbonus_material(16, 4),
		},
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(16, 4),
		},
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
	},
	ms_set_drake = true, ms_set_nature = true,
	set_list = {
		multiple = true,
		harmonious = {{"ms_set_harmonious", true, inven_id = other_hand,},},
		wyrm = {{"ms_set_wyrm", true, inven_id = other_hand,},},},
	set_desc = {
		venom = "이 자연적인 맹독은 용에게 돌아가야만 합니다.",
	},
	on_set_complete = {
		multiple = true,
		harmonious = set_complete,
		wyrm = set_complete,},
	on_set_broken = {
		multiple = true,
		harmonious = set_broken,
		wyrm = set_broken,},
}

-- Dreamer Set: For Solipsists
set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#YELLOW#마석이 염력과 공명하기 시작합니다.")
	end
	self:specialSetAdd({"wielder","psi_regen"}, self.material_level / 10)
end

newEntity{
	power_source = {psionic=true},  define_as = "MS_EGO_SET_DREAMERS",
	name = "dreamer's ", prefix=true, instant_resolve=true,
	kr_name = "몽상가 ",
	keywords = {dreamers=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(8, 2),
		max_psi = resolvers.mbonus_material(40, 10),
		resists = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), }
	},
	ms_set_dreamers_dreamers = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		dreamers = {{"ms_set_dreamers_epiphanous", true, inven_id = other_hand,},},},
	set_desc = {
		dreamers = "이 정신적인 마석은 통찰의 꿈을 꾸고 있습니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		dreamers = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		dreamers = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#YELLOW#마석이 염력과 공명하기 시작합니다.")
	end
	self:specialSetAdd({"wielder","psi_on_crit"}, self.material_level)
end

newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_EPIPHANOUS",
	name = "epiphanous ", prefix=true, instant_resolve=true,
	kr_name = "통찰의 ",
	keywords = {epiphanous=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(5, 1),
		inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), },
	},
	ms_set_dreamers_epiphanous = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		dreamers = {{"ms_set_dreamers_dreamers", true, inven_id = other_hand,},},},
	set_desc = {
		epiphanous = "이 정신적인 마석은 꿈을 통찰하고 있습니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		dreamers = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		dreamers = set_broken,},
}

-- Channelers Set: For Mindslayers

set_complete = function(self, who, inven_id)
	local Talents = require "engine.interface.ActorTalents"
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#YELLOW#Psionic energy flows through your mindstars.")
	end
	self:specialSetAdd({"wielder","talent_cd_reduction"}, {
		[Talents.T_KINETIC_SHIELD]=1,
		[Talents.T_THERMAL_SHIELD]=1,
		[Talents.T_CHARGED_SHIELD]=1,
		[Talents.T_KINETIC_LEECH]=1,
		[Talents.T_THERMAL_LEECH]=1,
		[Talents.T_CHARGE_LEECH]=1,
	})
end

newEntity{
	power_source = {psionic=true},  define_as = "MS_EGO_SET_ABSORBING",
	name = "absorbing ", prefix=true, instant_resolve=true,
	kr_name = "흡수하는 ",
	keywords = {absorbing=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		resists = { 
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5), 
			[DamageType.COLD] = resolvers.mbonus_material(20, 5), 
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 5), 
		},
		talents_types_mastery = {
			["psionic/voracity"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
			["psionic/absorption"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
	ms_set_channeler_absorbing = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		channeler = {{"ms_set_channeler_projecting", true, inven_id = other_hand,},},},
	set_desc = {
		absorbing = "이 마석은 분출되어야 하는 정신적 에너지를 흡수하고 있습니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		channeler = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		channeler = set_broken,},
}

set_complete = function(self, who, inven_id)
	local Talents = require "engine.interface.ActorTalents"
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#YELLOW#Psionic energy flows through your mindstars.")
	end
	self:specialSetAdd({"wielder","talent_cd_reduction"}, {
		[Talents.T_KINETIC_AURA]=1,
		[Talents.T_THERMAL_AURA]=1,
		[Talents.T_CHARGED_AURA]=1,
		[Talents.T_FRENZIED_FOCUS]=1,
		[Talents.T_PYROKINESIS]=1,
		[Talents.T_BRAIN_STORM]=1,
	})
end

newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_PROJECTING",
	name = "projecting ", prefix=true, instant_resolve=true,
	kr_name = "분출하는 ",
	keywords = {projecting=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		inc_damage = { 
			[DamageType.FIRE] = resolvers.mbonus_material(20, 5), 
			[DamageType.COLD] = resolvers.mbonus_material(20, 5), 
			[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 5), 
		},
		talents_types_mastery = {
			["psionic/projection"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
			["psionic/focus"] = resolvers.mbonus_material(1, 1, function(e, v) v=v/10 return 0, v end),
		},
	},
	ms_set_channeler_projecting = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		channeler = {{"ms_set_channeler_absorbing", true, inven_id = other_hand,},},},
	set_desc = {
		projecting = "이 마석은 충분히 흡수 될 수 있다면 정신적 에너지를 분출할 것입니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		channeler = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		channeler = set_broken,},
}

-- Mitotic Set: Single Mindstar that splits in two
newEntity{
	power_source = {nature=true},
	name = "mitotic ", prefix=true, instant_resolve=true,
	kr_name = "분열하는 ",
	keywords = {mitotic=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 45, -- Rarity is high because melee based mindstar use is rare and you get two items out of one drop
	cost = 40,  -- cost is very low to discourage players from splitting them to make extra gold..  because that would be tedious and unfun
	combat = {
		physcrit = resolvers.mbonus_material(10, 2),
		melee_project = { [DamageType.ITEM_ACID_CORRODE]= resolvers.mbonus_material(15, 5), [DamageType.ITEM_NATURE_SLOW]= resolvers.mbonus_material(15, 5),},
	},
	no_auto_hotkey = true,
	resolvers.charm("마석을 둘로 나눔", 1,
		function(self, who)
			-- Check for free slot first
			if who:getFreeHands() == 0 then
				game.logPlayer(who, "%s 나누려면, 한 쪽 손은 아무 것도 들고 있으면 안됩니다.", (self.kr_name or self.name):addJosa("를"))
			return
			end

			if who:getInven("PSIONIC_FOCUS") and who:getInven("PSIONIC_FOCUS")[1] == self then
				game.logPlayer(who, "당신이 %s 염동력으로 잡고 있는 동안에는, 사용할 수 없는 기술입니다.", (self.kr_name or self.name):addJosa("를"))
				return
			end

			local o = self

			-- Remove some properties before cloning
			o.cost = self.cost / 2 -- more don't split for extra gold discouragement
			o.max_power = nil
			o.power_regen = nil
			o.use_power = nil
			local o2 = o:clone()

			-- Build the item set
			o.define_as = "MS_EGO_SET_MITOTIC_ACID"
			o2.define_as = "MS_EGO_SET_MITOTIC_SLIME"
			o.set_list = { {"define_as", "MS_EGO_SET_MITOTIC_SLIME"} }
			o2.set_list = { {"define_as", "MS_EGO_SET_MITOTIC_ACID"} }

			o.on_set_complete = function(self, who)
				self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.ACID_BLIND] = 10 * self.material_level } )
				game.logPlayer(who, "#GREEN#마석이 생명력으로 맥동하기 시작합니다.")
			end
			o.on_set_broken = function(self, who)
				game.logPlayer(who, "#SLATE#마석과의 연결이 끊어졌습니다.")
			end

			o2.on_set_complete = function(self, who)
				self:specialWearAdd({"combat","burst_on_crit"}, { [engine.DamageType.SLIME] = 10 * self.material_level } )
			end

			-- Wearing the second mindstar will complete the set and thus update the first mindstar
			who:wearObject(o2, true, true)

			-- Because we're removing the use_power we're not returning that it was used; instead we'll have the actor use energy manually
			who:useEnergy()
		end
	),
}

-- Wrathful Set: Geared towards Afflicted

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREY#마석을 쥐자, 마음 속의 증오심이 불타오릅니다.")
	end
	self:specialSetAdd({"wielder","combat_mindpower"}, 2 * self.material_level)
end

newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_HATEFUL",
	name = "hateful ", prefix=true, instant_resolve=true,
	kr_name = "증오에 찬 ",
	keywords = {hateful=true},
	level_range = {30, 50},
	greater_ego =1,
	rarity = 35,
	cost = 35,
	wielder = {
		inc_damage={
			[DamageType.MIND] = resolvers.mbonus_material(20, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 5),
		},
		resists_pen={
			[DamageType.MIND] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		inc_damage_type = {humanoid=resolvers.mbonus_material(20, 5)},
	},
	ms_set_wrathful_hateful = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		wrathful = {{"ms_set_wrathful_wrathful", true, inven_id = other_hand,},},},
	set_desc = {
		hateful = "이 정신적인 마석은 격노하지 않는 것을 증오합니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		wrathful = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		wrathful = set_broken,},
}

set_complete = function(self, who, inven_id)
	if inven_id == "MAINHAND" then
		game.logPlayer(who, "#GREY#마석을 쥐자, 마음 속의 증오심이 불타오릅니다.")
	end
	self:specialSetAdd({"wielder","max_hate"}, 2 * self.material_level)
end

newEntity{
	power_source = {psionic=true}, define_as = "MS_EGO_SET_WRATHFUL",
	name = "wrathful ", prefix=true, instant_resolve=true,
	kr_name = "격노한 ",
	keywords = {wrath=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		psi_on_crit = resolvers.mbonus_material(5, 1),
		hate_on_crit = resolvers.mbonus_material(5, 1),
		combat_mindcrit = resolvers.mbonus_material(10, 2),
	},
	ms_set_wrathful_wrathful = true, ms_set_psionic = true,
	set_list = {
		multiple = true,
		resonating = {{"ms_set_resonating", true, inven_id = other_hand,},},
		wrathful = {{"ms_set_wrathful_hateful", true, inven_id = other_hand,},},},
	set_desc = {
		wrathful = "이 정신적인 마석은 증오된 자들에게 격노합니다.",
	},
	on_set_complete = {
		multiple = true,
		resonating = set_complete,
		wrathful = set_complete,},
	on_set_broken = {
		multiple = true,
		resonating = set_broken,
		wrathful = set_broken,},
}
