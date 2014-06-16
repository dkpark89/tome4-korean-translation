﻿-- ToME - Tales of Maj'Eyal
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

-- last updated:  5:11 PM 1/29/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_CANINE",
	type = "animal", subtype = "canine",
	display = "C", color=colors.WHITE,
	body = { INVEN = 10 },
	sound_moam = {"creatures/wolves/wolf_hurt_%d", 1, 2},
	sound_die = {"creatures/wolves/wolf_hurt_%d", 1, 1},
	sound_random = {"creatures/wolves/wolf_howl_%d", 1, 3},

	max_stamina = 150,
	rank = 1,
	size_category = 2,
	infravision = 10,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	global_speed_base = 1.2,
	stats = { str=10, dex=17, mag=3, con=7 },
	combat = { dammod={str=0.6}, sound="creatures/wolves/wolf_attack_1" },
	combat_armor = 1, combat_def = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "wolf", color=colors.UMBER, image="npc/canine_w.png",
	kr_name = "늑대",
	desc = [[말랐고, 교활하며, 털이 수북한 늑대입니다. 배고픈 듯한 눈빛으로 당신을 쳐다봅니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(40,70),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=0, apr=3 },
	resolvers.talents{
		[Talents.T_RUSH]={base=0, every=10},
	},
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "great wolf", color=colors.UMBER, image="npc/canine_gw.png",
	kr_name = "대형 늑대",
	desc = [[보통의 늑대보다 더 커다랗습니다. 당신의 주변을 맴돌다가 달려듭니다.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(60,90),
	combat_armor =2, combat_def = 4,
	combat = { dam=resolvers.levelup(6, 1, 0.8), atk=0, apr=3 },
	resolvers.talents{
		[Talents.T_KNOCKBACK]={base=0, every=8},
		[Talents.T_HOWL]=1,
	},
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "dire wolf", color=colors.DARK_UMBER, image="npc/canine_dw.png",
	kr_name = "이리",
	desc = [[말 만큼이나 커다란 이 늑대는, 그 발톱과 이빨로 당신을 위협합니다.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(80,110),
	combat_armor = 3, combat_def = 5,
	combat = { dam=resolvers.levelup(9, 1, 0.9), atk=5, apr=4 },
	resolvers.talents{
		[Talents.T_RUSH]={base=0, every=10},
		[Talents.T_KNOCKBACK]={base=0, every=8},
		[Talents.T_HOWL]=1,
	},
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "white wolf", color=colors.WHITE, image="npc/canine_ww.png",
	kr_name = "흰 늑대",
	desc = [[북쪽 황무지에서 온, 근육질의 덩치 큰 늑대입니다. 냉기 섞인 차가운 숨을 쉬고 있으며, 털에는 서리가 맺혀 있습니다.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 4,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=5, apr=3 },
	resolvers.talents{
		[Talents.T_ICE_CLAW]={base=0, every=10},
		[Talents.T_ICY_SKIN]={base=1, every=10},
		[Talents.T_KNOCKBACK]={base=0, every=15},
		[Talents.T_HOWL]=2,
	},

	resists = { [DamageType.FIRE] = -50, [DamageType.COLD] = 100 },
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "warg", color=colors.BLACK, image="npc/canine_warg.png",
	kr_name = "와르그",
	desc = [[교활함으로 가득찬 눈을 가진, 대형 늑대입니다.]],
	level_range = {6, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 5, combat_def = 7,
	combat = { dam=resolvers.levelup(10, 1, 1), atk=10, apr=5 },
	resolvers.inscriptions(1, "infusion"),
	resolvers.talents{
		[Talents.T_RUSH]={base=0, every=10},
		[Talents.T_HACK_N_BACK]={base=1, every=10},
		[Talents.T_VITALITY]={base=3, every=8},
		[Talents.T_UNFLINCHING_RESOLVE]={base=1, every=8},
		[Talents.T_DAUNTING_PRESENCE]={base=0, every=8},
		[Talents.T_HOWL]=3,
	},
	ingredient_on_death = "WARG_CLAW",
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "fox", color=colors.RED, image="npc/canine_fox.png",
	kr_name = "여우",
	desc = [[여우와 다람쥐 헌 쳇바퀴에 타고파]],
	sound_moam = {"creatures/foxes/bark_hurt_%d", 1, 1},
	sound_die = {"creatures/wolves/death_%d", 1, 1},
	sound_random = {"creatures/wolves/bark_%d", 1, 2},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(40,50),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(4, 1, 0.7), atk=0, apr=3, sound="creatures/foxes/attack_1" },
	resolvers.talents{
		[Talents.T_RUSHING_CLAWS]={base=0, every=8},
		[Talents.T_NIMBLE_MOVEMENTS]={base=0, every=10},
	},
}

newEntity{ base = "BASE_NPC_CANINE",
	name = "Rungof the Warg Titan", color=colors.VIOLET, unique=true, image="npc/canine_rungof.png",
	kr_name = "타이탄 와르그, 룬고프",
	desc = [[보통의 와르그보다 세 배나 큰, 교활함으로 가득찬 눈을 가진 대형 늑대입니다.]],
	level_range = {20, nil}, exp_worth = 2,
	rank = 3.5,
	size_category = 4,
	rarity = 50,
	max_life = 220, life_rating = 18,
	combat_armor = 25, combat_def = 0,
	combat = { dam=resolvers.levelup(20, 1, 1.3), atk=20, apr=16 },

	ai = "tactical",

	resolvers.drops{chance=100, nb=1, {defined="RUNGOF_FANG"} },

	make_escort = {
		{type="animal", subtype="canine", name="warg", number=6},
	},
	resolvers.inscriptions(2, "infusion"),
	resolvers.talents{
		[Talents.T_RUSH]={base=3, every=10},
		[Talents.T_CRIPPLE]={base=3, every=10},
		[Talents.T_HACK_N_BACK]={base=3, every=10},
		[Talents.T_SET_UP]={base=3, every=10},
		[Talents.T_VITALITY]={base=3, every=8},
		[Talents.T_UNFLINCHING_RESOLVE]={base=3, every=8},
		[Talents.T_DAUNTING_PRESENCE]={base=3, every=8},
		[Talents.T_HOWL]=5,
	},
}
