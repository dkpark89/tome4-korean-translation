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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

newEntity{
	power_source = {technique=true},
	name = " of tirelessness", suffix=true, instant_resolve=true,
	kr_name = "끈기의 ",
	keywords = {tireless=true},
	level_range = {1, 50},
	rarity = 9,
	cost = 7,
	wielder = {
		max_stamina = resolvers.mbonus_material(30, 10),
		stamina_regen = resolvers.mbonus_material(10, 3, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "traveler's ", prefix=true, instant_resolve=true,
	kr_name = "여행자 ",
	keywords = {traveler=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_physresist = resolvers.mbonus_material(10, 5),
		max_encumber = resolvers.mbonus_material(30, 20),
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "scholar's ", prefix=true, instant_resolve=true,
	kr_name = "학자 ",
	keywords = {scholar=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_spellpower = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {technique=true},
	name = "miner's ", prefix=true, instant_resolve=true,
	kr_name = "광부 ",
	keywords = {miner=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_armor = resolvers.mbonus_material(6, 4),
		infravision = resolvers.mbonus_material(2, 1),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of phasing", suffix=true, instant_resolve=true,
	kr_name = "위상의 ",
	keywords = {phasing=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,
	use_no_energy = true,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(2, 2),
		},
	},
	charm_power = resolvers.mbonus_material(80, 20),
	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm("임의의 위치로 단거리 순간이동", 25, function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, self:getCharmPower(who))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s %s 사용했습니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	power_source = {technique=true},
	name = " of uncanny dodging", suffix=true, instant_resolve=true,
	kr_name = "뛰어난 회피의 ",
	keywords = {['u.dodge']=true},
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		combat_def = resolvers.mbonus_material(8, 2),
		combat_def_ranged = resolvers.mbonus_material(8, 2),
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of speed", suffix=true, instant_resolve=true,
	kr_name = "속도의 ",
	keywords = {speed=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		movement_speed = 0.2,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of rushing", suffix=true, instant_resolve=true,
	kr_name = "돌진의 ",
	keywords = {rushing=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,
	resolvers.charmt(Talents.T_RUSH, {1,2,3}, 25),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_CON] = resolvers.mbonus_material(2, 2),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of void walking", suffix=true, instant_resolve=true,
	kr_name = "공허를 걷는 자의 ",
	keywords = {void=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 60,
	wielder = {
		resists={
			[DamageType.DARKNESS] = resolvers.mbonus_material(20, 10),
			[DamageType.TEMPORAL] = resolvers.mbonus_material(20, 10),
	},
		resists_pen = {
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 10),
			[DamageType.TEMPORAL] = resolvers.mbonus_material(10, 10),
		},
		resist_all_on_teleport = resolvers.mbonus_material(10, 10),
		defense_on_teleport = resolvers.mbonus_material(20, 10),
		effect_reduction_on_teleport = resolvers.mbonus_material(20, 10),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of disengagement", suffix=true, instant_resolve=true,
	kr_name = "철수의 ",
	keywords = {disengage=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,
	use_no_energy = true,
	resolvers.charmt(Talents.T_DISENGAGE, {1,2,3}, 15),
	wielder = {
		inc_stats = {
			[Stats.STAT_DEX] = resolvers.mbonus_material(2, 2),
			[Stats.STAT_CUN] = resolvers.mbonus_material(2, 2),
		},
	},
}

newEntity{
	power_source = {technique=true},
	name = "blood-soaked ", prefix=true, instant_resolve=true,
	kr_name = "피에 절은 ",
	keywords = {blood=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 20,
	wielder = {
		combat_dam = resolvers.mbonus_material(3, 3),
		combat_apr = resolvers.mbonus_material(10, 3),
		combat_physcrit = resolvers.mbonus_material(3, 3),
	},
}

newEntity{
	power_source = {nature=true},
	name = "restorative ", prefix=true, instant_resolve=true,
	kr_name = "회복하는 ",
	keywords = {restorative=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 60,
	wielder = {
		healing_factor = resolvers.mbonus_material(20, 10, function(e, v) v=v/100 return 0, v end),
		life_regen = resolvers.mbonus_material(40, 15, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {nature=true},
	name = "invigorating ", prefix=true, instant_resolve=true,
	kr_name = "기운 나는 ",
	keywords = {['invigor.']=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 70,
	wielder = {
		fatigue = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end),
		max_life=resolvers.mbonus_material(30, 30),
		movement_speed = 0.1,
		stamina_regen = resolvers.mbonus_material(7, 2, function(e, v) v=v/10 return 0, v end),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "blightbringer's ", prefix=true, instant_resolve=true,
	kr_name = "황폐유발자 ",
	keywords = {blight=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 35,
	cost = 80,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(7, 3),
		},
		inc_damage = {
			[DamageType.ACID] = resolvers.mbonus_material(5, 5),
			[DamageType.BLIGHT] = resolvers.mbonus_material(5, 5),
		},
		combat_spellpower = resolvers.mbonus_material(7, 3),
		disease_immune = resolvers.mbonus_material(30, 20, function(e, v) return 0, v/100 end),
	},
}

newEntity{
	power_source = {technique=true},
	name = "wanderer's ", prefix=true, instant_resolve=true,
	kr_name = "방랑자 ",
	keywords = {wanderer=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_CUN] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1),
		},
		combat_mentalresist = resolvers.mbonus_material(15, 10),
		combat_physresist = resolvers.mbonus_material(15, 10),
	},
}


newEntity{
	power_source = {arcane=true},
	name = "undeterred ", prefix=true, instant_resolve=true,
	kr_name = "저해되지 않는 ",
	keywords = {undeterred=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 60,
	wielder = {
			stun_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
			silence_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
			confusion_immune = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end),
	},	
}

newEntity{
	power_source = {technique=true},
	name = "reinforced ", prefix=true, instant_resolve=true,
	kr_name = "보강된 ",
	keywords = {reinforced=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5),
		},
		combat_armor = resolvers.mbonus_material(7, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "eldritch ", prefix=true, instant_resolve=true,
	kr_name = "섬뜩한 ",
	keywords = {eldritch=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
			[Stats.STAT_WIL] = resolvers.mbonus_material(5, 1),
		},
		max_mana = resolvers.mbonus_material(40, 20),
		mana_regen = resolvers.mbonus_material(50, 10, function(e, v) v=v/100 return 0, v end),
		combat_spellcrit = resolvers.mbonus_material(4, 1),
	},
}

newEntity{
	power_source = {technique=true},
	name = " of massiveness", suffix=true, instant_resolve=true,
	kr_name = "커다람의 ",
	keywords = {massive=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 60,
	use_no_energy = true,
	resolvers.charmt(Talents.T_HEAVE, {2,3,4}, 10),
	wielder = {
		inc_stats = {
			[Stats.STAT_STR] = resolvers.mbonus_material(7, 3),
			[Stats.STAT_CON] = resolvers.mbonus_material(7, 3),
		},
		inc_damage = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(5, 5),
	},
		size_category = 1,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of invasion", suffix=true, instant_resolve=true,
	kr_name = "침략의 ",
	keywords = {invasion=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 40,
	wielder = {
		combat_physcrit = resolvers.mbonus_material(4, 1),
		combat_dam = resolvers.mbonus_material(3, 3),
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of spellbinding", suffix=true, instant_resolve=true,
	kr_name = "마법 집중의 ",
	keywords = {spellbinding=true},
	level_range = {30, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 30,
	wielder = {
		inc_stats = {
			[Stats.STAT_MAG] = resolvers.mbonus_material(5, 1),
		},
		combat_spellresist = resolvers.mbonus_material(7, 1),
		spell_cooldown_reduction = 0.1,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of evasion", suffix=true, instant_resolve=true,
	kr_name = "회피의 ",
	keywords = {evasion=true},
	level_range = {10, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	resolvers.charmt(Talents.T_EVASION, {2,3,4}, 30),
	wielder = {
		combat_def = resolvers.mbonus_material(15, 10),
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
	power_source = {psionic=true},
	name = "dreamer's ", prefix=true, instant_resolve=true,
	kr_name = "몽상가 ",
	keywords = {dreamer=true},
	level_range = {15, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	wielder = {
		combat_spellresist = resolvers.mbonus_material(10, 5),
		combat_mentalresist = resolvers.mbonus_material(10, 5),
		combat_physresist = resolvers.mbonus_material(10, 5),
	},
}

newEntity{
	power_source = {psionic=true},
	name = " of strife", suffix=true, instant_resolve=true,
	kr_name = "투쟁의 ",
	keywords = {rushing=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 18,
	cost = 40,
	resolvers.charmt(Talents.T_BLINDSIDE, {1,2,3}, 25),
	wielder = {
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(4, 2),
			[Stats.STAT_WIL] = resolvers.mbonus_material(4, 2),
		},
		resists_pen = {
			[DamageType.PHYSICAL] = resolvers.mbonus_material(5, 5),
	},
		combat_mindpower = resolvers.mbonus_material(6, 3),
	},
}