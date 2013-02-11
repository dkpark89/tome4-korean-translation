-- ToME - Tales of Maj'Eyal
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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_NAGA",
	type = "humanoid", subtype = "naga",
	display = "n", color=colors.AQUAMARINE,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	can_breath={water=1},

	life_rating = 11,
	rank = 2,
	size_category = 3,

	resolvers.racial(),

	open_door = true,
	resolvers.inscriptions(1, "infusion"),
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	global_speed_base = 1.2,
	stats = { str=15, dex=15, mag=15, con=10 },
	ingredient_on_death = "NAGA_TONGUE",
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga myrmidon", color=colors.DARK_UMBER, image="npc/naga_myrmidon.png",
	kr_display_name = "나가 신하",
	desc = [[당신이 아주 기다란 존재의 앞에 서자, 그의 다리가 있어야 할 자리에 뱀의 꼬리가 붙어 지탱하고 있음이 보입니다. 그의 상체는 사람같지만 딱맞는 갑옷 아래에는 근육이 불끈 튀어나와있고, 커다란 손은 사납도록 날카로운 삼지창을 쥐고 있습니다. 어둠 속에서도 그는 당신을 확실한 사냥감에게 달려드는 늑대처럼 노려보고 있습니다.]],
	level_range = {30, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(120,150), life_rating = 16,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, force_drop=true, special_rarity="trident_rarity"},
	},
	combat_armor = 20, combat_def = 10,
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=5, every=10, max=9},
		[Talents.T_SUNDER_ARMOUR]={base=4, every=10, max=8},
		[Talents.T_STUNNING_BLOW]={base=3, every=10, max=7},
		[Talents.T_RUSH]=8,
		[Talents.T_WEAPON_COMBAT]={base=3, every=10, max=6},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=3, every=10, max=6},
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga tide huntress", color=colors.RED, image="npc/naga_tide_huntress.png",
	kr_display_name = "나가 조류 사냥꾼",
	desc = [[계속 당신의 머리를 겨누고 있는 날카로운 화살이 걱정되지만, 더욱 무기력하게 만드는 것을 그걸 들고 있는 존재입니다. 허리위로는 날씬하고 유연한 여성이지만, 끔찍한 대형 뱀의 몸이 그 아래 달려있습니다. 그 꼬리는 뒤쪽으로 수미터나 뻗어있습니다. 냉정하고 차가워 보이는 눈을하고, 날카로운 화살촉에는 마법이 응집되어 있습니다. 갑자기 다시 걱정이 밀려옵니다.]],
	level_range = {34, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	female = true,
	max_life = resolvers.rngavg(110,130), life_rating = 14,
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
	},
	combat_armor = 10, combat_def = 10,
	autolevel = "warriormage",
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=5, every=10, max=10},
		[Talents.T_WATER_JET]={base=6, every=10, max=11},
		[Talents.T_WATER_BOLT]={base=7, every=10, max=12},
		[Talents.T_SHOOT]=1,
		[Talents.T_WEAPON_COMBAT]={base=3, every=10, max=6},
		[Talents.T_BOW_MASTERY]={base=3, every=10, max=6},
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga psyren", color=colors.YELLOW, image="npc/naga_psyren.png",
	kr_display_name = "나가 사이렌",
	desc = [[매혹적인 아름다움과 욕나오는 무서움이 섞여있는 한번도 보지못한 조합의 존재입니다. 위쪽은 아름다운 천상의 여인같이 호리호리하고 넋을 잃을 정도로 우아합니다. 아래쪽은 부드러운 뱀의 비늘이 달린 두껍고 죽 뻗은 뱀꼬리가 뒤쪽에서 앞뒤로 흔들거립니다. 꼬리의 움직임은 눈길을 끌고 최면을 겁니다. 그걸 쳐다보고 있으면 그녀의 유혹적인 입술에는 신비한 미소가 나타납니다.]],
	level_range = {36, nil}, exp_worth = 1,
	rarity = 4,
	rank = 3,
	female = true,
	max_life = resolvers.rngavg(100,110), life_rating = 11,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, force_drop=true, special_rarity="trident_rarity"},
	},
	combat_armor = 5, combat_def = 10,
	autolevel = "wildcaster",
	ai = "tactical",
	ai_tactic = resolvers.tactic"ranged",
	resolvers.talents{
		[Talents.T_MIND_DISRUPTION]={base=4, every=10, max=7},
		[Talents.T_MIND_SEAR]={base=5, every=10, max=8},
		[Talents.T_SILENCE]={base=4, every=10, max=7},
		[Talents.T_TELEKINETIC_BLAST]={base=4, every=10, max=7},
	},
}
