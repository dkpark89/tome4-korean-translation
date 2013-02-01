﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

-- last updated:  10:46 AM 2/3/2010

require "engine.krtrUtils"

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_HORROR_TEMPORAL",
	type = "horror", subtype = "temporal",
	display = "h", color=colors.WHITE,
	blood_color = colors.BLUE,
	body = { INVEN = 10 },
	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },

	stats = { str=20, dex=20, wil=20, mag=20, con=20, cun=20 },
	combat_armor = 5, combat_def = 10,
	combat = { dam=5, atk=10, apr=5, dammod={str=0.6} },
	infravision = 10,
	max_life = resolvers.rngavg(10,20),
	rank = 2,
	size_category = 3,

	no_breath = 1,
	cut_immune = 1,
	fear_immune = 1,
	not_power_source = {nature=true},
}

-- temporal horrors
newEntity{ base = "BASE_NPC_HORROR_TEMPORAL",
	dredge = 1,
	name = "dredgling", color=colors.TAN,
	kr_display_name = "어린 드렛지",
	desc = "커다란 툭 튀어나온 둥근 눈을 가진 분홍색 피부의 작은 영장류입니다.",
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	rank = 2,
	size_category = 2,
	autolevel = "warriormage",
	max_life = resolvers.rngavg(50, 80),
	combat_armor = 1, combat_def = 10,
	combat = { dam=resolvers.levelup(resolvers.rngavg(15,20), 1, 1.1), atk=resolvers.rngavg(5,15), apr=5, dammod={str=1} },

	resists = { [DamageType.TEMPORAL] = 25},

	resolvers.talents{
		[Talents.T_DUST_TO_DUST]={base=1, every=7, max=5},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_TEMPORAL",
	subtype = "temporal",
	dredge = 1,
	name = "dredge", color=colors.PINK,
	kr_display_name = "드렛지",
	desc = "나무줄기 만큼 두껍고 긴 팔을 가진 어슬렁 거리는 분홍색 피부의 존재입니다. 손가락을 땅에 질질 끌고 다니고 있습니다.",
	level_range = {15, nil}, exp_worth = 1,
	rarity = 2,
	rank = 2,
	size_category = 4,
	autolevel = "warrior",
	max_life = resolvers.rngavg(120, 150),
	life_rating = 16,
	global_speed_base = 0.7,
	combat_armor = 1, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,150), 1, 1.2), atk=resolvers.rngavg(25,130), apr=1, dammod={str=1.1} },

	resists = {all = 10, [DamageType.TEMPORAL] = 25, [DamageType.PHYSICAL] = 25},

	resolvers.talents{
		[Talents.T_STUN]={base=3, every=7, max=7},
		[Talents.T_SPEED_SAP]={base=2, every=7, max=6},
		[Talents.T_CLINCH]={base=2, every=6, max=8},
		[Talents.T_CRUSHING_HOLD]={base=2, every=6, max=8},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_TEMPORAL",
	subtype = "temporal",
	dredge = 1,
	name = "dredge captain", color=colors.SALMON,
	kr_display_name = "대장 드렛지",
	desc = "호리호리하고 긴 팔을 가진 마른 분홍색 피부의 존재입니다. 몸의 반은 늙고 주름졌으나, 나머지 반은 꽤 젋어 보입니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 5,
	rank = 3,
	size_category = 3,
	max_life = resolvers.rngavg(60,80),
	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	combat_armor = 1, combat_def = 0,

	resists = {all = 10, [DamageType.TEMPORAL] = 50},

	make_escort = {
		{type="horror", subtype="temporal", name="dredge", number=3, no_subescort=true},
	},

	resolvers.inscriptions(1, {"shielding rune"}),
	resolvers.inscriptions(1, "infusion"),

	resolvers.talents{
		[Talents.T_DREDGE_FRENZY]={base=5, every=7, max=9},
		[Talents.T_SPEED_SAP]={base=3, every=7, max=9},
	},

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_TEMPORAL",
	subtype = "temporal",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_temporal_temporal_stalker.png", display_h=2, display_y=-1}}},
	name = "temporal stalker", color=colors.STEEL_BLUE,
	kr_display_name = "시간의 추격자",
	desc = "긴 날카로운 손톱과 칼날같은 이빨을 가진 날씬한 금속질의 기괴한 존재입니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 3,
	size_category = 3,
	max_life = resolvers.rngavg(100,180),
	life_rating = 12,
	global_speed_base = 1.2,
	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	combat_armor = 10, combat_def = 10,
	combat = { dam=resolvers.levelup(resolvers.rngavg(25,100), 1, 1.2), atk=resolvers.rngavg(25,100), apr=25, dammod={dex=1.1} },

	resists = {all = 10, [DamageType.TEMPORAL] = 50},

	resolvers.talents{
		[Talents.T_PERFECT_AIM]={base=3, every=7, max=5},
		[Talents.T_SPIN_FATE]={base=5, every=7, max=8},
		[Talents.T_STEALTH]={base=3, every=7, max=5},
		[Talents.T_SHADOWSTRIKE]={base=3, every=7, max=5},
		[Talents.T_UNSEEN_ACTIONS]={base=3, every=7, max=5},
	},

	resolvers.inscriptions(1, "rune"),
	resolvers.inscriptions(1, "infusion"),

	resolvers.sustains_at_birth(),
}

newEntity{ base = "BASE_NPC_HORROR_TEMPORAL",
	subtype = "temporal",
	name = "void horror", color=colors.GREY,
	kr_display_name = "공허의 무서운자",
	desc = "시공간의 구명 같아 보이는 존재이지만, 그 이상으로 인상적입니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 4,
	rank = 2,
	size_category = 2,
	max_life = resolvers.rngavg(80, 120),
	life_rating = 10,
	autolevel = "summoner",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_snake" },
	combat_armor = 1, combat_def = 10,
	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={wil=0.8}, damtype=DamageType.TEMPORAL },
	on_melee_hit = { [DamageType.TEMPORAL] = resolvers.mbonus(20, 10), },

	stun_immune = 1,
	confusion_immune = 1,
	silence_immune = 1,

	resists = {[DamageType.TEMPORAL] = 50},

	resolvers.talents{
		[Talents.T_ENERGY_ABSORPTION]={base=3, every=7, max=5},
		[Talents.T_ENERGY_DECOMPOSITION]={base=3, every=7, max=5},
		[Talents.T_ENTROPIC_FIELD]={base=3, every=7, max=5},
		[Talents.T_ECHOES_FROM_THE_VOID]={base=3, every=7, max=5},
		[Talents.T_VOID_SHARDS]={base=2, every=7, max=5},
	},
	-- Random Anomaly on Death
	on_die = function(self, who)
		local ts = {}
		for id, t in pairs(self.talents_def) do
			if t.type[1] == "chronomancy/anomalies" then ts[#ts+1] = id end
		end
		self:forceUseTalent(rng.table(ts), {ignore_energy=true})
		game.logSeen(self, "%s 그 속으로 붕괴합니다.", (self.kr_display_name or self.name):capitalize():addJosa("가"))
	end,

	resolvers.sustains_at_birth(),
}
