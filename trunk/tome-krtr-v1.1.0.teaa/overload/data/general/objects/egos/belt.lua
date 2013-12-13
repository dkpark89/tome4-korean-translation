﻿-- ToME - Tales of Maj'Eyal
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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-defensive.lua")

newEntity{
	power_source = {arcane=true},
	name = " of carrying", suffix=true, instant_resolve=true,
	kr_name = "짐꾼의 ",
	keywords = {carrying=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		max_encumber = resolvers.mbonus_material(40, 20),
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
	},
}

newEntity{
	power_source = {antimagic=true},
	name = "cleansing ", prefix=true, instant_resolve=true,
	kr_name = "깨끗한 ",
	keywords = {cleansing=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 9,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "insulating ", prefix=true, instant_resolve=true,
	kr_name = "단열 처리된 ",
	keywords = {insulate=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "grounding ", prefix=true, instant_resolve=true,
	kr_name = "접지된 ",
	keywords = {grounding=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		resists={
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = "nightruned ", prefix=true, instant_resolve=true,
	kr_name = "밤의 룬을 새긴 ",
	keywords = {nightruned=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 6,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of dampening", suffix=true, instant_resolve=true,
	kr_name = "마력 약화의 ",
	keywords = {dampening=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(5, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(5, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(5, 5),
			[DamageType.COLD] = resolvers.mbonus_material(5, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "blurring ", prefix=true, instant_resolve=true,
	kr_name = "희미해지는 ",
	keywords = {blurring=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 10,
	wielder = {
		combat_def = resolvers.mbonus_material(15, 8),
		inc_stealth = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = "reinforced ", prefix=true, instant_resolve=true,
	kr_name = "보강된 ", --@@ 한글화 검수 필요
	keywords = {reinforced=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		combat_armor = resolvers.mbonus_material(10, 5),
		combat_def = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(15, 10),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of transcendance", suffix=true, instant_resolve=true,
	kr_name = "초월의 ", --@@ 한글화 검수 필요
	keywords = {transcend=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(10, 2),
		combat_physresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of the mystic", suffix=true, instant_resolve=true,
	kr_name = "신비의 ",
	keywords = {mystic=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(10, 2),
		combat_mentalresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of the giants", suffix=true, instant_resolve=true,
	kr_name = "거인의 ", --@@ 한글화 검수 필요 : of the titan(타이탄의)에서 바뀌었음
	keywords = {giant=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_dam = resolvers.mbonus_material(10, 2),
		combat_spellresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {nature=true},
	name = "monstrous ", prefix=true, instant_resolve=true,
	kr_name = "괴물같은 ",
	keywords = {monstrous=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(3, 3),
			[Stats.STAT_CON] = resolvers.mbonus_material(3, 3),
		},
		size_category = 1,
		combat_dam = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = "balancing ", prefix=true, instant_resolve=true,
	kr_name = "균형적인 ",
	keywords = {balancing=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 3),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 3),
		},
		combat_physcrit = resolvers.mbonus_material(10, 5),
		combat_mindcrit = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of recklessness", suffix=true, instant_resolve=true,
	kr_name = "무모함의 ",
	keywords = {reckless=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 40,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(3, 3),
		combat_critical_power = resolvers.mbonus_material(10, 5),
		combat_dam = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of burglary", suffix=true, instant_resolve=true,
	kr_name = "강도의 ",
	keywords = {burglary=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		disarm_bonus = resolvers.mbonus_material(25, 5),
		trap_detect_power = resolvers.mbonus_material(25, 5),
		infravision = resolvers.mbonus_material(3, 3),
		inc_stealth = resolvers.mbonus_material(10, 5),
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(3, 3),
			[Stats.STAT_CUN] = resolvers.mbonus_material(3, 3),
			[Stats.STAT_LCK] = resolvers.mbonus_material(5, 5),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "ravager's ", prefix=true, instant_resolve=true,
	kr_name = "파괴자 ",
	keywords = {ravager=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 100,
	wielder = {
		inc_damage = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(20, 5),
		},
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = "skylord's ", prefix=true, instant_resolve=true,
	kr_name = "천공 군주 ",
	keywords = {skylord=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 2),
			[Stats.STAT_DEX] = resolvers.mbonus_material(5, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 2),
		},
		combat_mentalresist = resolvers.mbonus_material(10, 10),
		combat_physresist = resolvers.mbonus_material(10, 10),
		combat_spellresist = resolvers.mbonus_material(10, 10),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "spiritwalker's ", prefix=true, instant_resolve=true,
	kr_name = "영혼 인도자 ",
	keywords = {spiritwalk=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		max_mana = resolvers.mbonus_material(40, 20),
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of magery", suffix=true, instant_resolve=true,
	kr_name = "마법 사용자의 ",
	keywords = {magery=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 50,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(3, 3),
			[Stats.STAT_WIL] = resolvers.mbonus_material(3, 3),
		},
		combat_spellcrit = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of unlife", suffix=true, instant_resolve=true,
	kr_name = "언데드의 ",
	keywords = {unlife=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 90,
	cost = 30,
	wielder = {
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
		},
		undead = 1,
		no_breath = 1,
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the vagrant", suffix=true, instant_resolve=true,
	kr_name = "부랑자의 ",
	keywords = {vagrant=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_mindpower = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of shielding", suffix=true, instant_resolve=true,
	kr_name = "방어의 ",
	keywords = {shielding=true},
	level_range = {20, 50},
	rarity = 10,
	cost = 40,
	wielder = {
		combat_armor = resolvers.mbonus_material(10, 5),
	},
	
	charm_power = resolvers.mbonus_material(80, 30),
	charm_power_def = {add=80, max=300, floor=true},
	resolvers.charm("피해를 %d 만큼 흡수하는 일시적인 보호막 생성", 30, function(self, who)
		local power = self:getCharmPower(who)
		who:setEffect(who.EFF_DAMAGE_SHIELD, 10, {power=power})
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	kr_name = "생명의 ",
	keywords = {life=true},
	level_range = {1, 50},
	rarity = 8,
	cost = 6,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		life_regen = resolvers.mbonus_material(30, 6, function(e, v) return 0, v/10 end),
	},
}

newEntity{
	power_source = {nature=true},
	name = " of resilience", suffix=true, instant_resolve=true,
	kr_name = "활력의 ",
	keywords = {resilience=true},
	level_range = {10, 50},
	rarity = 6,
	cost = 5,
	wielder = {
		max_life = resolvers.mbonus_material(40, 30),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of valiance", suffix=true, instant_resolve=true,
	kr_name = "용기의 ",
	keywords = {valiance=true},
	level_range = {25, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		max_life = resolvers.mbonus_material(70, 40),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of containment", suffix=true, instant_resolve=true,
	kr_name = "억제의 ",
	keywords = {containment=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 70,
	wielder = {
		max_life = resolvers.mbonus_material(80, 50),
		max_stamina = resolvers.mbonus_material(40, 25),
		max_mana = resolvers.mbonus_material(50, 30),
		max_vim = resolvers.mbonus_material(20, 20),
		max_positive = resolvers.mbonus_material(20, 20),
		max_negative = resolvers.mbonus_material(20, 20),
		max_hate = resolvers.mbonus_material(10, 10),
		paradox_reduce_fails = resolvers.mbonus_material(20, 20),
		max_psi = resolvers.mbonus_material(20, 20),
	},
}