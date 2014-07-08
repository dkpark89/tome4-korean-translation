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
	define_as = "BASE_NPC_CORRUPTED_HORROR",
	type = "horror", subtype = "corrupted",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },

	combat_armor = 0, combat_def = 0,
	combat = { atk=2, dammod={str=0.6} },
--	max_life = resolvers.rngavg(30, 50),
	stats = { str=16, con=16 },
	infravision = 10,
	rank = 2,
	size_category = 3,

	blind_immune = 1,
	no_breath = 1,
}

newEntity{ base = "BASE_NPC_CORRUPTED_HORROR",
	dredge = 1,
	name = "dremling", color=colors.SLATE,
	kr_name = "어린 드렘",
	desc = "얼굴 없는 작은 존재로, 왠지 모르게 드워프를 닮은 것 같습니다. 낡고 녹슨 관리가 엉망인 전투도끼와 방패를 쥐고 있습니다.",
	level_range = {1, nil}, exp_worth = 1,

	combat = { atk=6, dammod={str=0.6} },
	max_life = resolvers.rngavg(30, 50),

	rarity = 1,
	rank = 2,
	size_category = 2,
	autolevel = "warrior",

	open_door = true,

	resists = { [DamageType.BLIGHT] = 20, [DamageType.DARKNESS] = 20,  [DamageType.LIGHT] = - 20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_DWARF_RESILIENCE]={base=1, every=5, max=5},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_CORRUPTED_HORROR",
	dredge = 1,
	name = "drem", color=colors.DARK_SLATE_GRAY,
	kr_name = "드렘",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_corrupted_drem.png", display_h=2, display_y=-1}}},
	desc = "가시돋고 거친 검은 피부를 가진, 거대한 존재입니다. 눈이 있을 자리가 텅 비어있는 것을 제외하면, 얼굴에는 아무런 특징이 없습니다.",
	level_range = {3, nil}, exp_worth = 1,

	combat_armor = 4, combat_def = 0,
	combat = { dam=resolvers.mbonus(45, 10), atk=2, apr=6, physspeed=2, dammod={str=0.8} },
	max_life = resolvers.rngavg(120,140),

	life_rating = 15,
	life_regen = 2,
	max_stamina = 90,

	open_door = true,

	rarity = 1,
	rank = 2,
	size_category = 4,
	autolevel = "warrior",

	resists = { [DamageType.FIRE] = -50 },
	fear_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	resolvers.talents{
		[Talents.T_CARBON_SPIKES]={base=1, every=7, max=6},
		[Talents.T_STUN]={base=1, every=10, max=5},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_CORRUPTED_HORROR",
	dredge = 1,
	name = "drem master", color=colors.LIGHT_GREY,
	kr_name = "상급 드렘",
	desc = "끼워맞춘 녹슨 중갑을 입고 있으며, 드워프를 닮은 것 같지만 상당히 훼손 상태가 심한 존재입니다. 그 입은 꿰매어져 서로 붙어있지만, 다른 드렘들을 지휘하고 있는 것으로 보입니다.",
	level_range = {3, nil}, exp_worth = 1,

	combat = { atk=10, dammod={str=0.6} },
	max_life = resolvers.rngavg(80, 120),

	rarity = 3,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	hate_regen = 2,

	open_door = true,

	resists = { [DamageType.BLIGHT] = 20, [DamageType.DARKNESS] = 20,  [DamageType.LIGHT] = - 20 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=60, nb=1, {type="money"} },

	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
		{type="armor", subtype="heavy", autoreq=true},
	},

	make_escort = {
		{type="horror", subtype="corrupted", name="drem", number=1, no_subescort=true},
		{type="horror", subtype="corrupted", name="dremling", number=2, no_subescort=true},
	},

	resolvers.talents{
		[Talents.T_DWARF_RESILIENCE]={base=1, every=5, max=5},
		[Talents.T_DREDGE_FRENZY]={base=1, every=10, max=5},
		[Talents.T_DOMINATE]={base=1, every=5, max=5},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_CORRUPTED_HORROR",
	name = "brecklorn", color=colors.PINK,  -- gloom bat
	kr_name = "브렉클론",
	desc = "비틀려진 드워프의 얼굴로 끊임없이 비명을 지르는, 털 없는 거대 박쥐입니다. 그 기형의 몸에는 질병의 흔적이 가득하며, 근처에 있는 것만으로도 공포심이 느껴집니다.",
	level_range = {1, nil}, exp_worth = 1,

	combat = { atk=10, dammod={dex=0.6} },
	combat_armor = 0, combat_def = 6,
	max_life = resolvers.rngavg(10, 20),

	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "rogue",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic "ranged",
	global_speed_base = 1.2,

	resists = { [DamageType.BLIGHT] = 50, [DamageType.DARKNESS] = 20,  [DamageType.LIGHT] = - 20 },

	resolvers.talents{
		[Talents.T_SPIT_BLIGHT]={base=1, every=5, max=5},
		[Talents.T_SHRIEK]={base=1, every=5, max=5},
		[Talents.T_GLOOM]={base=1, every=5, max=5},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_CORRUPTED_HORROR",
	name = "grannor'vor", color=colors.GREEN,  -- acid slug
	kr_name = "그란놀'보르",
	desc = "천천히 움직이는 커다란 달팽이과 생물입니다. 이 존재가 지나간 길에는 산성 액체가 남으며, 머리 부분은 이상하게 사람의 특징을 가지고 있습니다.",
	level_range = {2, nil}, exp_worth = 1,

	combat = { dam=resolvers.levelup(5, 1, 0.6), atk=15, apr=5, damtype=DamageType.ACID },
	combat_armor = 6, combat_def = 0,
	max_life = resolvers.rngavg(40, 60),

	rarity = 2,
	rank = 2,
	size_category = 3,
	autolevel = "warrior",

	global_speed_base = 0.8,

	resists = { [DamageType.ACID] = 50, [DamageType.DARKNESS] = 20,  [DamageType.LIGHT] = - 20 },

	clone_on_hit = {min_dam_pct=15, chance=30},

	resolvers.talents{
		[Talents.T_CRAWL_ACID]={base=2, every=5, max=5},
		[Talents.T_ACID_BLOOD]={base=1, every=5, max=5},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_CORRUPTED_HORROR",
	name = "grannor'vin", color=colors.BLACK,  -- shadow slug
	kr_name = "그란놀'빈",
	desc = "사람의 머리를 가진, 커다란 달팽이과 생물입니다. 그림자가 그 거대한 형상에 드리워져 있어, 근처의 모든 빛을 희미하게 만듭니다.",
	level_range = {2, nil}, exp_worth = 1,

	combat = { dam=5, atk=15, apr=5, damtype=DamageType.DARKNESS },
	combat_armor = 6, combat_def = 0,
	max_life = resolvers.rngavg(40, 60),
	hate_regen = 2,

	rarity = 4,
	rank = 2,
	size_category = 4,
	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },

	global_speed_base = 0.8,

	resists = { [DamageType.DARKNESS] = 50,  [DamageType.LIGHT] = - 20 },

	resolvers.talents{
		[Talents.T_CALL_SHADOWS]={base=3, every=6, max=7},
		[Talents.T_CREEPING_DARKNESS]={base=2, every=5, max=5},
		[Talents.T_DARK_TORRENT]={base=1, every=5, max=5},
	},

	resolvers.sustains_at_birth(),
}
