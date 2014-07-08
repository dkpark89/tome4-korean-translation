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
	define_as = "BASE_NPC_GHOST",
	type = "undead", subtype = "ghost",
	blood_color = colors.GREY,
	display = "G", color=colors.WHITE,

	combat = { dam=1, atk=1, apr=1, sound={"creatures/ghost/attack%d", 1, 2} },

	sound_moam = {"creatures/ghost/on_hit%d", 1, 2},
	sound_die = {"creatures/ghost/death%d", 1, 1},
	sound_random = {"creatures/ghost/random%d", 1, 1},

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", ai_move="move_complex", sense_radius=40, talent_in=2, },
	dont_pass_target = true,
	stats = { str=14, dex=18, mag=20, con=12 },
	rank = 2,
	size_category = 3,
	infravision = 10,

	can_pass = {pass_wall=70},
	resists = {all = 35, [DamageType.LIGHT] = -70, [DamageType.DARKNESS] = 65},

	no_breath = 1,
	stone_immune = 1,
	confusion_immune = 1,
	fear_immune = 1,
	teleport_immune = 0.5,
	disease_immune = 1,
	poison_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	cut_immune = 1,
	see_invisible = 80,
	undead = 1,
	resolvers.sustains_at_birth(),
	not_power_source = {nature=true},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "dread", color=colors.ORANGE, image="npc/dread.png",
	kr_name = "드레드",
	desc = [[보는 것만으로도 비명이 나올 정도의 끔찍한 존재입니다. 죽음의 화신이자, 그 흉물스러운 검은색 육신은 마치 이 세계의 의지에 반하여 존재하는 것 같습니다.]],
	level_range = {25, nil}, exp_worth = 1,
	rarity = 10,
	max_life = resolvers.rngavg(90,100),
	combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
	stealth = resolvers.mbonus(40, 10),
	ai_state = { talent_in=4, },

	combat = { dam=resolvers.mbonus(45, 45), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5} },

	resolvers.talents{
		[Talents.T_BURNING_HEX]={base=3, every=5, max=7},
		[Talents.T_BLUR_SIGHT]={base=4, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "dreadmaster", color=colors.YELLOW, image="npc/dreadmaster.png",
	kr_name = "상급 드레드",
	desc = [[불공평할 정도로 강력한 역생의 힘을 보여주는 존재입니다. 실제로 존재하는 모든 것들을 모욕하고, 생명의 흐름을 두절시키며, 다른 세상에서 온 것 같이 순수한 검은색 사지는 쉽게 바위를 부수고 신체를 부패시킵니다.]],
	level_range = {32, nil}, exp_worth = 1,
	rarity = 15,
	rank = 3,
	max_life = resolvers.rngavg(140,170),

	ai = "tactical",

	combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
	stealth = resolvers.mbonus(30, 20),

	combat = { dam=resolvers.mbonus(65, 65), atk=resolvers.mbonus(25, 45), apr=100, dammod={str=0.5, mag=0.5} },

	summon = {{type="undead", subtype="ghost", name="dread", number=3, hasxp=false}, },
	resolvers.talents{
		[Talents.T_SUMMON]=1,
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_BLUR_SIGHT]={base=4, every=6, max=8},
		[Talents.T_DISPERSE_MAGIC]={base=3, every=7, max=6},
		[Talents.T_SILENCE]={base=2, every=10, max=6},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=8},
		[Talents.T_BURNING_HEX]={base=5, every=6, max=8},
	},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "banshee", color=colors.BLUE, image="npc/banshee.png", female=1,
	kr_name = "밴시",
	desc = [[슬픔에 잠겨 통곡하는 여성형 유령입니다.]],
	level_range = {20, nil}, exp_worth = 1,
	rarity = 8,
	max_life = resolvers.rngavg(40,50), life_rating = 6,

	combat_armor = 0, combat_def = resolvers.mbonus(10, 10),
	stealth = resolvers.mbonus(40, 10),

	combat = { dam=5, atk=5, apr=100, dammod={str=0.5, mag=0.5} },

	resolvers.talents{
		[Talents.T_SHRIEK]=4,
		[Talents.T_PHASE_DOOR]=2,
		[Talents.T_BLUR_SIGHT]={base=3, every=6, max=6},
		[Talents.T_SILENCE]={base=2, every=10, max=5},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=6},
	},
}

newEntity{ base = "BASE_NPC_GHOST",
	name = "ruin banshee", color=colors.GREY,
	kr_name = "파멸의 밴시",
	desc = [[울흐'록의 브레스에 의해 만들어져, 복수심에 불타는 비명을 지르는 영혼입니다. 공포의 영역에서 나오는 증기가 이 왜곡된 차원의 존재로부터 스며나와, 다른 것들을 시들고 부패하게 만듭니다.]],
	level_range = {42, nil}, exp_worth = 1,
	rarity = 15,
	rank = 3,
	max_life = resolvers.rngavg(240,270),

	ai = "tactical",

	combat_armor = 0, combat_def = resolvers.mbonus(10, 50),
	on_melee_hit = {[DamageType.BLIGHT]=resolvers.mbonus(25, 25)},
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(25, 25)},
	stealth = resolvers.mbonus(50, 20),

	combat = { dam=resolvers.mbonus(85, 85), atk=resolvers.mbonus(45, 45), apr=100, dammod={str=0.7, mag=0.7} },

	resolvers.talents{
		[Talents.T_PHASE_DOOR]=10,
		[Talents.T_SILENCE]={base=2, every=10, max=6},
		[Talents.T_MIND_DISRUPTION]={base=3, every=7, max=8},
		[Talents.T_CORRUPTED_NEGATION]={base=5, every=6, max=8},
		[Talents.T_CORROSIVE_WORM]={base=4, every=5, max=12},
		[Talents.T_POISON_STORM]={base=4, every=5, max=12},
		[Talents.T_CURSE_OF_DEATH]={base=5, every=6, max=8},
		[Talents.T_CURSE_OF_IMPOTENCE]={base=5, every=6, max=8},
	},
}