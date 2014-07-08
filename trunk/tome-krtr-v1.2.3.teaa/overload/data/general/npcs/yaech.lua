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
	define_as = "BASE_NPC_YAECH",
	type = "humanoid", subtype = "yaech",
	blood_color = colors.BLUE,
	display = "y", color=colors.AQUAMARINE,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	can_breath={water=1},

	life_rating = 9,
	rank = 2,
	size_category = 2,

	open_door = true,

	autolevel = "wildcaster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=15, dex=15, mag=15, con=10 },
}

newEntity{ base = "BASE_NPC_YAECH",
	name = "yaech diver", color=colors.BLUE,
	kr_name = "야크 잠수부",
	desc = [[야크는 이크의 수생 아종입니다. 두 종족 간에는 같은 초능력을 공유하지만, 이들은 '한길' 에 소속되는 것을 거부했습니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(50,70),
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	resolvers.talents{
		[Talents.T_KINETIC_SHIELD]={base=1, every=15, max=3},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_YAECH",
	name = "yaech hunter", color=colors.UMBER,
	kr_name = "사냥꾼 야크",
	desc = [[야크는 이크의 수생 아종입니다. 두 종족 간에는 같은 초능력을 공유하지만, 이들은 '한길' 에 소속되는 것을 거부했습니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(90,110),
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	resolvers.talents{
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=10, max=5},
		[Talents.T_MINDHOOK]={base=1, every=7, max=5},
		[Talents.T_PERFECT_CONTROL]={base=2, every=7, max=5},
	},
}

newEntity{ base = "BASE_NPC_YAECH",
	name = "yaech mindslayer", color=colors.YELLOW,
	kr_name = "야크 정신 파괴자",
	desc = [[야크는 이크의 수생 아종입니다. 두 종족 간에는 같은 초능력을 공유하지만, 이들은 '한길' 에 소속되는 것을 거부했습니다.]],
	level_range = {2, nil}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(90,110),
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	resolvers.talents{
		[Talents.T_KINETIC_AURA]={base=1, every=7, max=5},
		[Talents.T_CHARGED_AURA]={base=1, every=7, max=5},
		[Talents.T_KINETIC_SHIELD]={base=2, every=7, max=5},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_YAECH",
	name = "yaech psion", color=colors.RED,
	kr_name = "야크 염동력자",
	desc = [[야크는 이크의 수생 아종입니다. 두 종족 간에는 같은 초능력을 공유하지만, 이들은 '한길' 에 소속되는 것을 거부했습니다.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(80,90),
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
	},
	resolvers.talents{
		[Talents.T_PYROKINESIS]={base=2, every=7, max=5},
		[Talents.T_MINDLASH]={base=1, every=7, max=5},
	},
}
