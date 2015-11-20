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

load("/data/general/npcs/gwelgoroth.lua", function(e) if e.rarity then e.derth_rarity, e.rarity = e.rarity, nil end end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ELVALA_TOWN",
	type = "humanoid", subtype = "shalore",
	display = "p", color=colors.WHITE,
	faction = "shalore",
	anger_emote = "@himher@ 잡아라!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_ELVALA_TOWN",
	name = "elvala guard", color=colors.LIGHT_UMBER,
	kr_name = "엘발라 경비",
	desc = [[엄격해 보이는 경비입니다. 이 경비는 당신이 마을을 어지럽히는 것을 용납하지 않을 것입니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
}

newEntity{ base = "BASE_NPC_ELVALA_TOWN",
	name = "shalore rune master", color=colors.RED,
	kr_name = "샬로레 룬의 명인",
	desc = [[온 몸이 룬으로 뒤덮힌, 키 큰 엘프입니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(50,60),
	ai_state = { talent_in=1, },
	autolevel = "caster",
	resolvers.inscriptions(3, {"heat beam rune", "frozen spear rune", "acid wave rune", "lightning rune"}),
}



newEntity{
	define_as = "BASE_NPC_ELVALA_OGRE_TOWN",
	type = "giant", subtype = "ogre",
	display = "O", color=colors.WHITE,
	faction = "shalore",
	anger_emote = "@himher@ 잡아라!",

	combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	lite = 3,

	life_rating = 10,
	rank = 2,
	size_category = 3,

	open_door = true,

	resolvers.racial(),
	resolvers.inscriptions(2, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=12, dex=8, mag=6, con=10 },

	emote_random = resolvers.emote_random{allow_backup_guardian=true},
}

newEntity{ base = "BASE_NPC_ELVALA_OGRE_TOWN",
	name = "ogre rune-spinner", color=colors.LIGHT_UMBER,
	kr_name = "오우거 룬-방직자",
	desc = [[거대한 오우거 경비입니다. 그녀의 피부는 룬으로 덮혀있습니다.]],
	female = 1,
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 1,
	rarity = 3,

	resolvers.inscriptions(3, {"shielding rune", "phase door rune", "heat beam rune", "acid wave rune", "lightning rune"}),
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_RUSH]=1, [Talents.T_PERFECT_STRIKE]=1, },
}