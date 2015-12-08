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

-- last updated:  10:00 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_JELLY",
	type = "immovable", subtype = "jelly",
	display = "j", color=colors.WHITE,
	sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
	sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
	sound_random = {"creatures/jelly/jelly_%d", 1, 3},
	desc = "A strange blob on the dungeon floor.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=10 },
	combat = {sound="creatures/jelly/jelly_hit"},
	combat_armor = 1, combat_def = 1,
	never_move = 1,
	rank = 2,
	blind_immune = 1,
	poison_immune = 1,
	size_category = 3,
	infravision = 10,
	no_breath = 1,
	cut_immune = 1,
	no_breath = 1,

	drops = resolvers.drops{chance=60, nb=1, {type="money"} },

	resists = { [DamageType.LIGHT] = -50 },
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "green jelly", color=colors.GREEN, image="npc/jelly-green.png",
	blood_color = colors.GREEN,
	kr_name = "녹색 젤리",
	desc = "던전 바닥에 있는, 기묘한 녹색 젤리입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=0, apr=5, damtype=DamageType.POISON },
	all_damage_convert = DamageType.NATURE,
	all_damage_convert_percent = 50,
	talent_cd_reduction = {[Talents.T_SLIME_SPIT]=-10},
	inc_damage = {all=-30},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "red jelly", color=colors.RED, image="npc/jelly-red.png",
	blood_color = colors.RED,
	kr_name = "붉은 젤리",
	desc = "던전 바닥에 있는, 기묘한 붉은 젤리입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=0, apr=5, damtype=DamageType.FIRE },
	all_damage_convert = DamageType.FIRE,
	all_damage_convert_percent = 50,
	talent_cd_reduction = {[Talents.T_SLIME_SPIT]=-10},
	inc_damage = {all=-30},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "blue jelly", color=colors.BLUE, image="npc/jelly-blue.png",
	blood_color = colors.BLUE,
	kr_name = "푸른 젤리",
	desc = "던전 바닥에 있는, 기묘한 푸른 젤리입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=0, apr=5, damtype=DamageType.COLD },
	all_damage_convert = DamageType.COLD,
	all_damage_convert_percent = 50,
	talent_cd_reduction = {[Talents.T_SLIME_SPIT]=-10},
	inc_damage = {all=-30},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "white jelly", color=colors.WHITE, image="npc/jelly-white.png",
	blood_color = colors.WHITE,
	kr_name = "흰 젤리",
	desc = "던전 바닥에 있는, 기묘한 흰 젤리입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=0, apr=5 },
	talent_cd_reduction = {[Talents.T_SLIME_SPIT]=-10},
	inc_damage = {all=-30},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "yellow jelly", color=colors.YELLOW, image="npc/jelly-yellow.png",
	blood_color = colors.YELLOW,
	kr_name = "노란 젤리",
	desc = "던전 바닥에 있는, 기묘한 노란 젤리입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=0, apr=5, damtype=DamageType.LIGHTNING },
	all_damage_convert = DamageType.LIGHTNING,
	all_damage_convert_percent = 50,
	talent_cd_reduction = {[Talents.T_SLIME_SPIT]=-10},
	inc_damage = {all=-30},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_JELLY",
	name = "black jelly", color=colors.DARK_GREY, image="npc/jelly-darkgrey.png",
	blood_color = colors.DARK_GREY,
	kr_name = "검은 젤리",
	desc = "던전 바닥에 있는, 기묘한 검은 젤리입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=0, apr=5, damtype=DamageType.ACID },
	all_damage_convert = DamageType.ACID,
	all_damage_convert_percent = 50,
	talent_cd_reduction = {[Talents.T_SLIME_SPIT]=-10},
	inc_damage = {all=-30},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_JELLY",
	unique = true,
	name = "Malevolent Dimensional Jelly", color=colors.VIOLET, image="npc/jelly-darkgrey.png",
	kr_name = "사악한 차원의 젤리",
	blood_color = colors.VIOLET,
	desc = "던전 바닥에 있는, 기묘한 검은 젤리입니다. 그 속에서는 다른 시간과 공간의 모습이 보입니다. 그 속을 가만히 응시하자, 안쪽의 세상이 바깥으로 펼쳐집니다.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 50,
	max_life = resolvers.rngavg(50,90), life_rating = 5,
	combat = { dam=5, atk=15, apr=5, damtype=DamageType.DARKNESS },
	all_damage_convert = DamageType.DARKNESS,
	all_damage_convert_percent = 100,
	summon = {
		{number=1, hasexp=false},
	},
	-- Nullify their cooldowns
	talent_cd_reduction={[Talents.T_SUMMON]=4, [Talents.T_SLIME_SPIT]=4},
	resolvers.talents{
		[Talents.T_SLIME_SPIT]={base=5, every=5},
		[Talents.T_SUMMON]=1,
	},
}
