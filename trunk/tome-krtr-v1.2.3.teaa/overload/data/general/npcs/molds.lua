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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_MOLD",
	type = "immovable", subtype = "molds",
	display = "m", color=colors.WHITE,
	blood_color = colors.PURPLE,
	desc = "던전의 바닥에서 자라난, 기묘한 존재입니다.",
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=3 },
	global_speed_base = 0.6,
	infravision = 10,
	combat_armor = 1, combat_def = 1,
	never_move = 1,
	blind_immune = 1,
	cut_immune = 1,
	poison_immune = 1,
	fear_immune = 1,
	no_breath = 1,
	rank = 1,
	size_category = 1,
	not_power_source = {technique_ranged=true},
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "grey mold", color=colors.SLATE,
	kr_name = "회색 곰팡이",
	desc = "던전의 바닥에서 자라난, 기묘한 회색의 존재입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_SLIME_ROOTS]={base=0, every=3, max=5},
		[Talents.T_NATURE_TOUCH]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "brown mold", color=colors.UMBER,
	kr_name = "갈색 곰팡이",
	desc = "던전의 바닥에서 자라난, 기묘한 갈색의 존재입니다.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(10,18),
	combat = { dam=5, atk=0, apr=10 },
	resolvers.talents{
		[Talents.T_SLIME_ROOTS]={base=0, every=3, max=5},
		[Talents.T_NATURE_TOUCH]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "shining mold", color=colors.YELLOW,
	kr_name = "빛나는 곰팡이",
	desc = "던전의 바닥에서 자라난, 기묘하게 빛나는 존재입니다",
	level_range = {3, 25}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=8, atk=5, apr=10 },

	resolvers.talents{
		[Talents.T_SLIME_ROOTS]={base=0, every=3, max=5},
		[Talents.T_NATURE_TOUCH]={base=0, every=5, max=5},
		[Talents.T_SPORE_BLIND]={base=1, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_MOLD",
	name = "green mold", color=colors.GREEN,
	kr_name = "녹색 곰팡이",
	desc = "던전의 바닥에서 자라난, 기묘한 녹색의 존재입니다.",
	level_range = {5, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(10,18),
	combat = { dam=5, atk=10, apr=10 },
	resolvers.talents{
		[Talents.T_SLIME_ROOTS]={base=1, every=3, max=5},
		[Talents.T_NATURE_TOUCH]={base=1, every=5, max=5},
		[Talents.T_SPORE_POISON]={base=1, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_MOLD",
	unique = true,
	type = "undead", subtype = "molds",
	name = "Z'quikzshl the skeletal mold", image = "npc/immovable_molds_skeletal_mold.png",
	kr_name = "해골 곰팡이, 즈'퀵즈쉴",
	display = 'm', color=colors.PURPLE,
	desc = [[악의에 물든 이 곰팡이는, 놀랍게도 죽음을 거부하였습니다. 곰팡이가 어떻게 해골이 될 수 있었는지는 알 수 없지만, 이 곰팡이는 자신만의 뼈대를 가지고 있습니다. 어떤 불행한 모험가의 뼈를 사용한 것일지도?]],

	level_range = {10, nil}, exp_worth = 5,
	rarity = 50,
	max_life = resolvers.rngavg(120,150),
	combat = { dam=resolvers.mbonus(30, 20), atk=25, apr=15 },

	rank = 3.5,
	size_category = 2,

	summon = {
		{type="immovable", subtype="molds", number=4, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_BONE_SPEAR]={base=4, every=10},
		[Talents.T_BONE_GRAB]={base=3, every=10},
		[Talents.T_SPORE_BLIND]={base=5, every=10},
		[Talents.T_SPORE_POISON]={base=5, every=10},
		[Talents.T_SLIME_ROOTS]={base=3, every=8, max=8},
		[Talents.T_NATURE_TOUCH]={base=3, every=10, max=8},
		[Talents.T_ROTTING_DISEASE]=5,
		[Talents.T_DECREPITUDE_DISEASE]=5,
		[Talents.T_WEAKNESS_DISEASE]=5,
		[Talents.T_GRAB]=5,
	},

	on_death_lore = "zquikzshl",
}
