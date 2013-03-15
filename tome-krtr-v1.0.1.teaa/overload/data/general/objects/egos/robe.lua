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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

-- Resists and saves
newEntity{
	power_source = {nature=true},
	name = " of fire (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "화염(#RESIST#)의 ",
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.FIRE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.FIRE] = (e.wielder.resists[engine.DamageType.FIRE] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.FIRE]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of frost (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "냉기(#RESIST#)의 ",
	keywords = {frost=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.COLD] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.COLD] = (e.wielder.resists[engine.DamageType.COLD] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.COLD]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of nature (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "자연(#RESIST#)의 ",
	keywords = {nature=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.NATURE] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.NATURE] = (e.wielder.resists[engine.DamageType.NATURE] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.NATURE]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of lightning (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "전기(#RESIST#)의 ",
	keywords = {lightning=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHTNING] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.LIGHTNING] = (e.wielder.resists[engine.DamageType.LIGHTNING] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.LIGHTNING]*1.5) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of light (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "빛(#RESIST#)의 ",
	keywords = {light=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.LIGHT] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.LIGHT] = (e.wielder.resists[engine.DamageType.LIGHT] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.LIGHT]*1.5) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of darkness (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "어둠의 ",
	keywords = {darkness=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.DARKNESS] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.DARKNESS] = (e.wielder.resists[engine.DamageType.DARKNESS] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.DARKNESS]*1.5) end),
}

newEntity{
	power_source = {nature=true},
	name = " of corrosion (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "부식(#RESIST#)의 ",
	keywords = {corrosion=true},
	level_range = {1, 50},
	rarity = 6,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.ACID] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.ACID] = (e.wielder.resists[engine.DamageType.ACID] or 0) + math.floor(e.wielder.inc_damage[engine.DamageType.ACID]*1.5) end),
}

-- rare resists
newEntity{
	power_source = {arcane=true},
	name = " of blight (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "황폐(#RESIST#)의 ",
	keywords = {blight=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.BLIGHT] = (e.wielder.resists[engine.DamageType.BLIGHT] or 0) + (e.wielder.inc_damage[engine.DamageType.BLIGHT]) end),
}

newEntity{
	power_source = {nature=true},
	name = " of the mountain (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "산맥(#RESIST#)의 ",
	keywords = {mountain=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.PHYSICAL] = (e.wielder.resists[engine.DamageType.PHYSICAL] or 0) + (e.wielder.inc_damage[engine.DamageType.PHYSICAL]) end),
}

newEntity{
	power_source = {psionic=true},
	name = " of the mind (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "정신(#RESIST#)의 ",
	keywords = {mind=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.MIND] = (e.wielder.resists[engine.DamageType.MIND] or 0) + (e.wielder.inc_damage[engine.DamageType.MIND]) end),
}

newEntity{
	power_source = {arcane=true},
	name = " of time (#RESIST#)", suffix=true, instant_resolve=true,
	kr_name = "시간(#RESIST#)의 ",
	keywords = {time=true},
	level_range = {1, 50},
	rarity = 24,
	cost = 2,
	wielder = {
		inc_damage = { [DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10) },
		resists = {},
	},
	resolvers.genericlast(function(e) e.wielder.resists[engine.DamageType.TEMPORAL] = (e.wielder.resists[engine.DamageType.TEMPORAL] or 0) + (e.wielder.inc_damage[engine.DamageType.TEMPORAL]) end),
}
-- Arcane Damage doesn't get resist too so we give it +mana instead
newEntity{
	power_source = {arcane=true},
	name = "shimmering ", prefix=true, instant_resolve=true,
	kr_name = "희미하게 빛나는 ",
	keywords = {shimmering=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 6,
	wielder = {
		inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(10, 10) },
		max_mana = resolvers.mbonus_material(100, 10),
	},
}

-- Saving Throws (robes give good saves)
newEntity{
	power_source = {technique=true},
	name = " of stability", suffix=true, instant_resolve=true,
	kr_name = "안정성의 ",
	keywords = {stable=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_physresist = resolvers.mbonus_material(15, 15),
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of spell shielding", suffix=true, instant_resolve=true,
	kr_name = "마법 저항의 ",
	keywords = {shielding=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_spellresist = resolvers.mbonus_material(15, 15),
	},
}
newEntity{
	power_source = {psionic=true},
	name = " of clarity", suffix=true, instant_resolve=true,
	kr_name = "명석함의 ",
	keywords = {clarity=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_mentalresist = resolvers.mbonus_material(15, 15),
	},
}
newEntity{
	power_source = {psionic=true},
	name = "dreamer's ", prefix=true, instant_resolve=true,
	kr_name = "몽상가 ",
	keywords = {dreamer=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		combat_physresist = resolvers.mbonus_material(10, 10),
		combat_spellresist = resolvers.mbonus_material(10, 10),
		combat_mentalresist = resolvers.mbonus_material(20, 20),
	},
}
newEntity{
	power_source = {arcane=true},
	name = "dispeller's ", prefix=true, instant_resolve=true,
	kr_name = "떨쳐내는 ",
	keywords = {dispeller=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		combat_physresist = resolvers.mbonus_material(10, 10),
		combat_mentalresist = resolvers.mbonus_material(10, 10),
		combat_spellresist = resolvers.mbonus_material(20, 20),
	},
}

-- The rest
newEntity{
	power_source = {arcane=true},
	name = " of retribution", suffix=true, instant_resolve=true,
	kr_name = "심판의 ",
	keywords = {retribution=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		on_melee_hit = {
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
	},	
}
newEntity{
	power_source = {arcane=true},
	name = "spellwoven ", prefix=true, instant_resolve=true,
	kr_name = "주문 엮인 ",
	keywords = {spellwoven=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(4, 2),
		combat_spellcrit = resolvers.mbonus_material(4, 2),
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of Linaniil", suffix=true, instant_resolve=true,
	kr_name = "리나니일의 ",
	keywords = {Linaniil=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
		combat_spellcrit = resolvers.mbonus_material(3, 3),
		max_mana = resolvers.mbonus_material(60, 40),
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),

	},
}
newEntity{
	power_source = {arcane=true},
	name = " of Angolwen", suffix=true, instant_resolve=true,
	kr_name = "앙골웬의 ",
	keywords = {Angolwen=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(4, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 2),
		},
		combat_spellpower = resolvers.mbonus_material(5, 5),
	},
}
newEntity{
	power_source = {arcane=true},
	name = "stargazer's ", prefix=true, instant_resolve=true,
	kr_name = "점성가 ",
	keywords = {stargazer=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
		},
		inc_damage = {
			[DamageType.LIGHT] = resolvers.mbonus_material(15, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5),
		},
		combat_spellpower = resolvers.mbonus_material(5, 5),
	},	
}
newEntity{
	power_source = {arcane=true},
	name = "ancient ", prefix=true, instant_resolve=true,
	kr_name = "고대 ",
	keywords = {ancient=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 40,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(9, 1),
		},
		inc_damage = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(15, 5),
		},
		resists = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 5),
		},
	},	
}
newEntity{
	power_source = {arcane=true},
	name = " of power", suffix=true, instant_resolve=true,
	kr_name = "강력함의 ",
	keywords = {power=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 15,
	wielder = {
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material(15, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5),
			[DamageType.COLD] = resolvers.mbonus_material(15, 5),
			[DamageType.ACID] = resolvers.mbonus_material(15, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
			[DamageType.NATURE] = resolvers.mbonus_material(15, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
		combat_spellpower = resolvers.mbonus_material(5, 5),
	},
}
newEntity{
	power_source = {arcane=true},
	name = " of chaos", suffix=true, instant_resolve=true,
	kr_name = "혼돈의 ",
	keywords = {chaos=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 40,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
			[DamageType.BLIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.NATURE] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
			[DamageType.ARCANE] = resolvers.mbonus_material(10, 5, function(e, v) return 0, -v end),
		},
		resists_pen = { 
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5),
		},
	},	
}
newEntity{
	power_source = {arcane=true},
	name = "sunsealed ", prefix=true, instant_resolve=true,
	kr_name = "태양력 ",
	keywords = {sunseal=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	wielder = {
		resists={
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 5),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		inc_damage = {
			[DamageType.LIGHT] = resolvers.mbonus_material(15, 5),
		},
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(7, 3),
		},
		lite = 1,
	},
}
newEntity{
	power_source = {nature=true},
	name = " of life", suffix=true, instant_resolve=true,
	kr_name = "생명의 ",
	keywords = {life=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		max_life=resolvers.mbonus_material(60, 40),
		life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end),
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		resists={
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5),
		},

	},
}
newEntity{
	power_source = {antimagic=true},
	name = "slimy ", prefix=true, instant_resolve=true,
	kr_name = "끈적이는 ",
	keywords = {slimy=true},
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		on_melee_hit={[DamageType.SLIME] = resolvers.mbonus_material(7, 3)},
	},
}
newEntity{
	power_source = {nature=true},
	name = "stormlord's ", prefix=true, instant_resolve=true,
	kr_name = "폭풍 군주 ",
	keywords = {stormlord=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 16,
	cost = 50,
	wielder = {
		resists={
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 4),
		},
		inc_damage = {
			[DamageType.COLD] = resolvers.mbonus_material(15, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5),
		},
	},
}
newEntity{
	power_source = {nature=true},
	name = "verdant ", prefix=true, instant_resolve=true,
	kr_name = "파릇파릇한 ",
	keywords = {verdant=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		life_regen = resolvers.mbonus_material(30, 5, function(e, v) v=v/10 return 0, v end),
		inc_damage = {
			[DamageType.NATURE] = resolvers.mbonus_material(15, 5),
		},
	},
}
newEntity{
	power_source = {psionic=true},
	name = "mindwoven ", prefix=true, instant_resolve=true,
	kr_name = "정신이 엮인 ",
	keywords = {mindwoven=true},
	level_range = {1, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		combat_mindpower = resolvers.mbonus_material(4, 2),
		combat_mindcrit = resolvers.mbonus_material(4, 2),
	},
}
newEntity{
	power_source = {psionic=true},
	name = "tormentor's ", prefix=true, instant_resolve=true,
	kr_name = "고문하는 ",
	keywords = {tormentor=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(9, 1),
		},
		combat_mindcrit = resolvers.mbonus_material(4, 1),
		combat_critical_power = resolvers.mbonus_material(30, 10),
	},	
}
newEntity{
	power_source = {psionic=true},
	name = "focusing ", prefix=true, instant_resolve=true,
	kr_name = "집중되는 ",
	keywords = {focus=true},
	level_range = {15, 50},
	rarity = 10,
	cost = 10,
	wielder = {
		mana_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
		psi_regen = resolvers.mbonus_material(30, 10, function(e, v) v=v/100 return 0, v end),
	},
}
newEntity{
	power_source = {psionic=true},
	name = "fearwoven ", prefix=true, instant_resolve=true,
	kr_name = "공포를 엮는 ",
	keywords = {fearwoven=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		inc_damage = {
			[DamageType.DARKNESS] = resolvers.mbonus_material(15, 5),
		},
		max_hate = resolvers.mbonus_material(10, 5),
		combat_mindpower = resolvers.mbonus_material(5, 5),
		combat_mindcrit = resolvers.mbonus_material(4, 1),
	},	
}
newEntity{
	power_source = {psionic=true},
	name = "psion's ", prefix=true, instant_resolve=true,
	kr_name = "염동력자 ",
	keywords = {psion=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 80,
	wielder = {
		inc_damage = {
			[DamageType.MIND] = resolvers.mbonus_material(15, 5),
		},
		max_psi = resolvers.mbonus_material(30, 10),
		combat_mindpower = resolvers.mbonus_material(5, 5),
		combat_mindcrit = resolvers.mbonus_material(4, 1),
	},	
}