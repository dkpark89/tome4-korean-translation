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

load("/data/general/npcs/ritch.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(0))
load("/data/general/npcs/ant.lua", rarity(2))
load("/data/general/npcs/jelly.lua", rarity(3))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_RITCH_REL",
	type = "insect", subtype = "ritch",
	display = "I", color=colors.RED,
	desc = [[릿치는 동대륙의 남부에 있는 불모지 태생인 거대 곤충입니다.
잔인한 포식자이고, 적들에게 타락성 질병을 주입하며, 날카로운 발톱은 대부분의 갑옷을 찢어버릴 수 있습니다.]],
	killer_message = "당신은 시체 속에 알을 산란당했습니다,",

	combat = { dam=resolvers.rngavg(10,32), atk=0, apr=4, damtype=DamageType.BLIGHT, dammod={dex=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 1,
	rank = 2,

	autolevel = "slinger",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=15, dex=15, mag=8, con=10 },

	poison_immune = 0.5,
	disease_immune = 0.5,
	ingredient_on_death = "RITCH_STINGER",
	resists = { [DamageType.BLIGHT] = 20, [DamageType.FIRE] = 40 },
}

newEntity{ base = "BASE_NPC_RITCH_REL",
	name = "ritch flamespitter", color=colors.DARK_RED,
	kr_name = "불꽃뿜는 릿치",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 5,
	life_rating = 3,
	lite = 1,

	rank = 2,

	ai_state = { ai_move="move_complex", talent_in=1, },
	resolvers.talents{
		[Talents.T_RITCH_FLAMESPITTER_BOLT]=1,
	},
}

newEntity{ base = "BASE_NPC_RITCH_REL",
	name = "ritch impaler", color=colors.UMBER,
	kr_name = "찌르는 릿치",
	level_range = {2, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 50,
	life_rating = 11,

	rank = 2,

	ai_state = { ai_move="move_complex", talent_in=1, },
	resolvers.talents{
		[Talents.T_RUSHING_CLAWS]=1,
	},
}

newEntity{ base = "BASE_NPC_RITCH_REL",
	name = "chitinous ritch", color=colors.YELLOW,
	kr_name = "키틴질 릿치",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 100,
	life_rating = 13,

	rank = 2,
	combat_armor = 6,

	ai_state = { ai_move="move_complex", talent_in=1, },
}

-- Screw it just die, die, die
newEntity{ base = "BASE_NPC_RITCH_REL", define_as = "HIVE_MOTHER",
	unique = true,
	name = "Ritch Great Hive Mother", image = "npc/insect_ritch_ritch_hive_mother.png",
	kr_name = "거대 군집의 어미 릿치",
	display = "I", color=colors.VIOLET,
	desc = [[이 커다란 릿치는 여기 있는 다른 모든 릿치들의 어미로 보입니다. 그녀의 날카롭고 이글거리는 발톱이 당신에게로 돌진합니다!]],
	level_range = {7, nil}, exp_worth = 2,
	max_life = 120, life_rating = 14, fixed_rating = true,
	equilibrium_regen = -50,
	infravision = 10,
	stats = { str=15, dex=10, cun=8, mag=16, wil=16, con=10 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	tier1 = true,
	rank = 4,
	size_category = 4,

	combat = { dam=30, atk=22, apr=7, dammod={str=1.1} },

	resists = { [DamageType.BLIGHT] = 40 },

	body = { INVEN = 10, BODY=1 },

	inc_damage = {all=-70},

	resolvers.drops{chance=100, nb=1, {defined="FLAMEWROUGHT", random_art_replace={chance=75}}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_SHRIEK]=2,
		[Talents.T_WEAKNESS_DISEASE]=1,
		[Talents.T_RITCH_FLAMESPITTER_BOLT]=2,
		[Talents.T_SPIT_BLIGHT]=2,
	},
	resolvers.sustains_at_birth(),

	summon = {
		{type="insect", subtype="ritch", number=1, hasxp=false},
	},

	autolevel = "dexmage",
	ai = "tactical", ai_state = { talent_in=2, },

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "ritch")
	end,
}
