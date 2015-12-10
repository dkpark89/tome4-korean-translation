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
	define_as = "BASE_NPC_SPIDER",
	type = "spiderkin", subtype = "spider",
	display = "S", color=colors.WHITE,
	desc = [[거미공포증...]],

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.NATURE, dammod={dex=1.2} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	size_category = 2,
	rank = 1,

	autolevel = "spider",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=4, },
	global_speed_base = 1.2,
	stats = { str=15, dex=15, mag=8, con=10 },

	resolvers.inscriptions(2, "infusion"),

	resolvers.sustains_at_birth(),

	poison_immune = 0.9,
	resists = { [DamageType.NATURE] = 20, [DamageType.LIGHT] = -20 },
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "giant spider", color=colors.LIGHT_DARK,
	kr_name = "거대 거미",
	desc = [[거대한 거미로, 거미줄도 그에 맞게 커다랗습니다.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 50,
	life_rating = 10,

	combat_armor = 5, combat_def = 5,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=1, every=10, max=5},
		[Talents.T_LAY_WEB]={base=1, every=10, max=5},
	},
	ingredient_on_death = "SPIDER_SPINNERET",
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "spitting spider", color=colors.DARK_UMBER,
	kr_name = "독뱉기 거미",
	desc = [[거대한 거미로, 사냥감을 향해 독을 내뿜습니다.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 60,
	life_rating = 10,

	combat_armor = 5, combat_def = 10,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=3, every=10, max=6},
		[Talents.T_SPIT_POISON]={base=3, every=10, max=6},
		[Talents.T_LAY_WEB]={base=3, every=10, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "chitinous spider", color=colors.LIGHT_GREEN,
	kr_name = "키틴질 거미",
	desc = [[억센 외골격을 가진, 거대한 거미입니다.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 1,
	max_life = 70,
	life_rating = 10,

	combat_armor = 10, combat_def = 14,

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=3, every=10, max=6},
		[Talents.T_LAY_WEB]={base=3, every=10, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "gaeramarth", color=colors.LIGHT_DARK,  -- dreadful fate
	kr_name = "개라마쓰",
	desc = [[이 교활한 거미는 자신의 영역을 계속 키우면서, 그 안으로 들어오는 모든 것을 위협합니다. 이 거미를 만나고 살아돌아온 존재는 거의 없다고 합니다.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 3,
	max_life = 120,
	life_rating = 13,

	combat_armor = 7, combat_def = 17,

	rank = 2,

	resolvers.tmasteries{ ["cunning/stealth"]=0.3},

	resolvers.talents{
		[Talents.T_RUSH]={base=4, every=6, max=7},
		[Talents.T_SPIDER_WEB]={base=4, every=6, max=7},
		[Talents.T_LAY_WEB]={base=4, every=6, max=7},
		[Talents.T_STEALTH]={base=4, every=6, max=7},
		[Talents.T_SHADOWSTRIKE]={base=4, every=6, max=7},
		[Talents.T_STUN]={base=2, every=6, max=5},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "ninurlhing", color=colors.DARK_GREEN,  -- water burn spider (acidic)
	kr_name = "니누르링",
	desc = [[대기에는 유독한 기운이 퍼지고, 주변의 땅은 썩어갑니다.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 3,
	max_life = 120,
	life_rating = 13,
	rank = 2,

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["wild-gift/slime"]=0.3, ["spell/water"]=0.3 },

	resolvers.talents{
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_ACIDIC_SKIN]={base=5, every=6, max=8},
		[Talents.T_CORROSIVE_VAPOUR]={base=5, every=6, max=8},
		[Talents.T_CRAWL_ACID]={base=3, every=6, max=6},
		[Talents.T_STUN]={base=2, every=6, max=7},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "faerlhing", color=colors.PURPLE,  -- spirit spider (arcane)
	kr_name = "패를링",
	desc = [[마나의 흐름을 조작할 수 있는 거미입니다. 마나가 그 몸속으로 자유롭게 들락거립니다.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	max_mana = 380,
	life_rating = 12,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["spell/phantasm"]=0.3, ["spell/water"]=0.3, ["spell/arcane"]=0.3 },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_PHANTASMAL_SHIELD]={base=5, every=6, max=8},
		[Talents.T_PHASE_DOOR]={base=5, every=6, max=8},
		[Talents.T_MANATHRUST]={base=5, every=6, max=8},
		[Talents.T_MANAFLOW]={base=5, every=6, max=8},
		[Talents.T_DISRUPTION_SHIELD]={base=3, every=6, max=6},
		[Talents.T_ARCANE_POWER]={base=3, every=6, max=6},
	},
	ingredient_on_death = "FAERLHING_FANG",
}

-- the brethren of Ungoliant :D  tough and deadly, probably too tough, but meh <evil laughter>
newEntity{ base = "BASE_NPC_SPIDER",
	name = "ungolmor", color={0,0,0},  -- spider night, don't change the color
	kr_name = "운골모르",
	desc = [[거미류 중 가장 큰 녀석입니다. 여러 겹으로 접혀진 피부는 뚫는 것이 거의 불가능해 보입니다.]],
	level_range = {38, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	life_rating = 16,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 75, combat_def = 12,  -- perhaps too impenetrable?  though at this level people should be doing over 100 damage each hit, so it could be more :D

	resolvers.tmasteries{ ["spell/aegis"]=0.9 },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_REGENERATION]={base=5, every=6, max=8},
		[Talents.T_BITE_POISON]={base=5, every=6, max=8},
		[Talents.T_DARKNESS]={base=5, every=6, max=8},
		[Talents.T_RUSH]=5,
		[Talents.T_STUN]={base=3, every=6, max=6},
	},

}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "losselhing", color=colors.LIGHT_BLUE,  -- snow star spider
	kr_name = "로셀링",
	desc = [[얼음장 같은 거미로, 주변의 공기가 딱딱하게 얼고 있습니다.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 4,
	max_life = 120,
	life_rating = 14,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	combat_armor = 7, combat_def = 17,

	resolvers.tmasteries{ ["spell/enhancement"]=0.7, ["wild-gift/cold-drake"]=0.7, ["spell/water"]=0.7 },

	resolvers.talents{
		[Talents.T_RUSH]={base=5, every=6, max=8},
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_FREEZE]={base=5, every=6, max=8},
		[Talents.T_ICY_SKIN]={base=5, every=6, max=8},
		[Talents.T_TIDAL_WAVE]={base=3, every=6, max=6},
		[Talents.T_ICE_STORM]={base=2, every=6, max=6},
		[Talents.T_FROST_HANDS]={base=5, every=6, max=8},
	},

}

-- Fate Weavers; temporal spiders
-- Weavers spend most of their adult life outside of normal space and time but lay their eggs and grow to maturity in the normal bounds of spacetime.
-- Male Weavers are extremely rare on Eyal with the young being the most common and the females occasionally will be encountered when they're caring for their young or laying eggs
-- Ninandra, The Great Weaver is said to be the mother of all Weavers and binds the threads of fate that let the Weavers travel back and forth through the timestream

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver young", color=colors.LIGHT_STEEL_BLUE,
	kr_name = "어린 무당거미",
	desc = [[현실과 비현실을 오가는, 작은 거미류입니다.]],
	level_range = {7, nil}, exp_worth = 1,
	rarity = 2, -- older weavers are much rarer, as they age they become less connected to the normal timeline
	max_life = 60,
	life_rating = 10,

	size_category = 1,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 5, combat_def = 10,
	resists = { [DamageType.PHYSICAL] = 20, [DamageType.TEMPORAL] = 20, },

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=1, every=10, max=5},
		[Talents.T_LAY_WEB]={base=1, every=10, max=5},
		[Talents.T_SPIN_FATE]={base=1, every=10, max=5},
		[Talents.T_SWAP]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver patriarch", color=colors.STEEL_BLUE,
	kr_name = "무당거미 가부장",
	desc = [[흉부에 흰 반점이 있는, 크고 푸른 거미류입니다. 시간의 흐름에 부분적으로 연결되어 있어, 그 형체가 변화하고 어른거립니다.]],
	level_range = {27, nil}, exp_worth = 1,
	rarity = 12, -- the rarest of the weavers; they spend most of their time courting females in their home realm
	max_life = 120,
	life_rating = 13,
	rank = 2,

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 7, combat_def = 17,
	resists = { [DamageType.PHYSICAL] = 20, [DamageType.TEMPORAL] = 20, },

	talent_cd_reduction = {[Talents.T_RETHREAD]=-4},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_SPIN_FATE]={base=5, every=6, max=8},
		[Talents.T_SWAP]={base=5, every=6, max=8},
		[Talents.T_RETHREAD]={base=5, every=6, max=8},
		[Talents.T_STATIC_HISTORY]={base=5, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver matriarch", female =1, color=colors.DARK_BLUE,
	kr_name = "무당거미 가모장",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_weaver_matriarch.png", display_h=2, display_y=-1}}},
	desc = [[흉부에 흰 반점이 있는, 크고 푸른 거미류입니다. 시간의 흐름에 부분적으로 연결되어 있어, 그 형체가 변화하고 어른거립니다.]],
	level_range = {38, nil}, exp_worth = 1,
	rarity = 6, -- rarer then most spiderkin; only encountered in Maj'Eyal while laying eggs or caring for her young
	size_category = 3,
	max_life = 120,
	life_rating = 16,
	rank = 3,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee", ai_state = { ai_move="move_complex", talent_in=2, },

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 70), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 7, combat_def = 17,
	resists = { [DamageType.PHYSICAL] = 20, [DamageType.TEMPORAL] = 20, },

	make_escort = {
		{type = "spiderkin", name="weaver young", number=2, no_subescort=true},
	},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=6, max=8},
		[Talents.T_LAY_WEB]={base=5, every=6, max=8},
		[Talents.T_SPIN_FATE]={base=5, every=6, max=8},
		[Talents.T_SWAP]={base=5, every=6, max=8},
		[Talents.T_RETHREAD]={base=5, every=6, max=8},
		[Talents.T_CHRONO_TIME_SHIELD]={base=5, every=6, max=8},
		[Talents.T_STATIC_HISTORY]={base=5, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "Ninandra, the Great Weaver", female=1, unique = true,
	kr_name = "위대한 무당거미, 니난드라",
	color = colors.VIOLET,
	rarity = 50,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_ninandra_the_great_weaver.png", display_h=2, display_y=-1}}},
	desc = [[현실을 넘나드는 존재이자, 변화하고 어른거리는 형상을 한 거대하고 푸른 흰 거미류입니다. 그녀는 숙명의 거미줄을 자아내어, 모든 이들의 운명을 그녀의 거미줄에 고정시킵니다.]],
	level_range = {45, nil}, exp_worth = 4,
	max_life = 400, life_rating = 25, fixed_rating = true,
	rank = 3.5,
	size_category = 4,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="THREADS_FATE", random_art_replace={chance=65}}},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee", ai_state = { ai_move="move_complex", talent_in=1, },

	combat = { dam=resolvers.levelup(resolvers.mbonus(100, 15), 1, 0.9), atk=16, apr=9, damtype=DamageType.WASTING, dammod={dex=1.2} },

	combat_armor = 7, combat_def = 17,
	resists = { [DamageType.PHYSICAL] = 20, [DamageType.TEMPORAL] = 20, },
	combat_physresist = 50,
	combat_spellresist = 50,
	combat_mentalresist = 50,
	combat_spellpower = 50,
	see_invisible = 18,

	make_escort = {
		{type = "spiderkin", name="weaver patriarch", number=2, no_subescort=true},
	},

	summon = {
		{type = "spiderkin", subtype = "spider", name="weaver young", number=4, hasxp=false},
	},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=7, every=6},
		[Talents.T_LAY_WEB]={base=7, every=6},

		-- She is the fateweaver, chronomancers learned these talents by emulating her
		[Talents.T_SPIN_FATE]={base=7, every=6},
		[Talents.T_WEBS_OF_FATE]={base=7, every=6},
		[Talents.T_FATEWEAVER]={base=7, every=6},
		[Talents.T_SEAL_FATE]={base=7, every=6},
		
		[Talents.T_STOP]={base=7, every=6},
		[Talents.T_STATIC_HISTORY]={base=7, every=6},
		[Talents.T_CHRONO_TIME_SHIELD]={base=7, every=6},
		[Talents.T_SPACETIME_STABILITY]={base=7, every=6},
		
		[Talents.T_DIMENSIONAL_STEP]=4,  -- At five this turns to swap, we want her to close with it
		[Talents.T_PHASE_PULSE]={base=7, every=6},
		[Talents.T_DIMENSIONAL_SHIFT]={base=7, every=6},
		
		[Talents.T_RETHREAD]={base=7, every=6},

		[Talents.T_SUMMON]=1,

		[Talents.T_LUCKY_DAY] = 1,
	},
}
