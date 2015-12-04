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

-- last updated:  9:54 AM 2/3/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_OOZE",
	type = "vermin", subtype = "oozes",
	display = "j", color=colors.WHITE,
	desc = "다양한 색깔을 가진 진흙 덩어리입니다.",
	sound_moam = {"creatures/jelly/jelly_%d", 1, 3},
	sound_die = {"creatures/jelly/jelly_die_%d", 1, 2},
	sound_random = {"creatures/jelly/jelly_%d", 1, 3},
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=10, dex=15, mag=3, con=10 },
	global_speed_base = 0.7,
	combat = {sound="creatures/jelly/jelly_hit"},
	combat_armor = 1, combat_def = 1,
	rank = 1,
	size_category = 3,
	infravision = 10,
	cut_immune = 1,
	blind_immune = 1,

	clone_on_hit = {min_dam_pct=15, chance=30},

	resolvers.drops{chance=90, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	resists = { [DamageType.LIGHT] = -50, [DamageType.COLD] = -50 },
	fear_immune = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "green ooze", color=colors.GREEN,
	blood_color = colors.GREEN,
	kr_name = "녹색 진흙 덩어리",
	desc = "녹색의 진흙 덩어리 입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.POISON },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "red ooze", color=colors.RED,
	blood_color = colors.RED,
	kr_name = "붉은 진흙 덩어리",
	desc = "붉은 진흙 덩어리 입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.FIRE },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "blue ooze", color=colors.BLUE,
	blood_color = colors.BLUE,
	kr_name = "푸른 진흙 덩어리",
	desc = "푸른 진흙 덩어리 입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.COLD },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "white ooze", color=colors.WHITE,
	blood_color = colors.WHITE,
	kr_name = "흰 진흙 덩어리",
	desc = "흰 진흙 덩어리 입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5 },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "yellow ooze", color=colors.YELLOW,
	blood_color = colors.YELLOW,
	kr_name = "노란 진흙 덩어리",
	desc = "노란 진흙 덩어리 입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.LIGHTNING },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "black ooze", color=colors.BLACK,
	blood_color = colors.BLACK,
	kr_name = "검은 진흙 덩어리",
	desc = "검은 진흙 덩어리 입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=5, damtype=DamageType.ACID },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "gelatinous cube", color=colors.BLACK,
	kr_name = "젤라틴 덩어리",
	desc = [[거대하고 기묘하게 생긴 젤라틴 덩어리입니다. 이것이 지나다니는 통로와 딱 들어맞는 사각형 모양을 하고 있습니다.
투명한 젤리 성분을 통해서, 이것이 집어삼킨 보물들과 시체들이 보입니다.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,100),
	combat = { dam=resolvers.mbonus(80, 15), atk=15, apr=6, damtype=DamageType.ACID },
	drops = resolvers.drops{chance=90, nb=3, {} },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "crimson ooze", color=colors.CRIMSON,
	kr_name = "핏빛의 진흙 덩어리",
	blood_color = colors.CRIMSON,
	desc = "핏빛 진흙 덩어리입니다.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.FIREBURN },
	clone_on_hit = {min_dam_pct=15, chance=50},
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "brittle clear ooze", color=colors.WHITE,
	kr_name = "아주 투명한 진흙 덩어리",
	blood_color = colors.WHITE,
	desc = "투명한 진흙 덩어리입니다.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 8,
	combat = { dam=resolvers.mbonus(40, 15), atk=15, apr=5, },
	clone_on_hit = {min_dam_pct=1, chance=50},
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "slimy ooze", color=colors.GREEN,
	kr_name = "끈적끈적한 진흙 덩어리",
	blood_color = colors.GREEN,
	desc = "아주 끈적끈적한 진흙 덩어리입니다.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.SLIME },
	clone_on_hit = {min_dam_pct=15, chance=50},

	resolvers.talents{ [Talents.T_SLIME_SPIT]=5 },
}

newEntity{ base = "BASE_NPC_OOZE",
	name = "poison ooze", color=colors.LIGHT_GREEN,
	kr_name = "산성 진흙 덩어리",
	blood_color = colors.LIGHT_GREEN,
	desc = "아주 끈적끈적한 진흙 덩어리입니다.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.POISON },
	clone_on_hit = {min_dam_pct=15, chance=50},

	resolvers.talents{ [Talents.T_POISONOUS_SPORES]=5 },
}

--[[
newEntity{ base = "BASE_NPC_OOZE",
	name = "morphic ooze", color=colors.GREY,
	desc = "Its shape changes every few seconds.",
	level_range = {25, nil}, exp_worth = 1,
	rarity = 1,
	rank = 3,
	max_life = resolvers.rngavg(140,170), life_rating = 11,
	combat = { dam=resolvers.mbonus(110, 15), atk=15, apr=5, damtype=DamageType.ACID },
	clone_on_hit = {min_dam_pct=40, chance=100},

	resolvers.talents{ [Talents.T_OOZE_MERGE]=5 },
}
]]
