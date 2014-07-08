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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_CAT",
	display = "c",
	stats = { str=10, dex=20, mag=3, cun=18, con=6 },
	autolevel = "rogue",
	size_category = 2,
	rank = 2,
	infravision = 10,
	global_speed_base = 1.25,
	type = "animal", subtype="feline",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },

	combat_physspeed = 2, -- Double attack per turn

	resolvers.sustains_at_birth(),
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "snow cat", color=colors.GRAY,
	kr_name = "설원 고양이",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_feline_snow_cat.png", display_h=2, display_y=-1}}},
	desc = [[검은 피부에 회색 털이 난 큰 고양이입니다.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(40,80),
	resists = { [DamageType.COLD] = 50 },
	combat_armor = 0, combat_def = 8,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=12, apr=15, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=1, every=6, max=5},
		[Talents.T_RUSH]={base=1, every=8, max=3},
		[Talents.T_LETHALITY]={base=1, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "panther", color=colors.BLACK,
	kr_name = "검은 표범",
	desc = [[검고 커다란 고양이과 짐승으로, 날씬한 근육질의 몸을 가지고 있습니다.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 4,
	size_category=3,
	max_life = resolvers.rngavg(60,100),
	combat_armor = 3, combat_def = 8,
	combat = { dam=resolvers.levelup(18, 1, 1), atk=12, apr=20, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=1, every=6, max=5},
		[Talents.T_RUSH]={base=1, every=8, max=3},
		[Talents.T_LETHALITY]={base=1, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "tiger", color=colors.YELLOW,
	kr_name = "호랑이",
	desc = [[노란 바탕에 검은 줄무늬를 가진, 정말 웅장한 짐승입니다.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 4,
	size_category=4,
	max_life = resolvers.rngavg(70,110),
	combat_armor = 3, combat_def = 8,
	combat = { dam=resolvers.levelup(25, 1, 1), atk=12, apr=25, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=2, every=6, max=5},
		[Talents.T_RUSH]={base=2, every=8, max=5},
		[Talents.T_LETHALITY]={base=2, every=8, max=5},
		[Talents.T_HIDE_IN_PLAIN_SIGHT]={base=10, every=8, max=5},
	},
}

newEntity{ base = "BASE_NPC_CAT",
	name = "sabertooth tiger", color=colors.YELLOW,
	kr_name = "검치호",
	desc = [[이 고양이과 짐승은 말 그대로 엄청난 존재입니다. 커다랗고 날카로운, 단검과도 같은 송곳니를 가지고 있습니다.]],
	level_range = {16, nil}, exp_worth = 1,
	rarity = 4,
	size_category=4,
	max_life = resolvers.rngavg(80,120),
	combat_armor = 3, combat_def = 8,
	combat = { dam=resolvers.levelup(28, 1, 1), atk=12, apr=35, dammod={str=0.5, dex=0.5}},
	resolvers.talents{
		[Talents.T_STEALTH]={base=3, every=6, max=5},
		[Talents.T_RUSH]={base=3, every=8, max=5},
		[Talents.T_LETHALITY]={base=3, every=8, max=5},
		[Talents.T_CRIPPLE]={base=3, every=8, max=5},
		[Talents.T_DEADLY_STRIKES]={base=3, every=8, max=5},
	},
}
