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
	define_as = "BASE_NPC_LOSGOROTH", -- lost goroth = void terror
	type = "elemental", subtype = "void",
	blood_color = colors.DARK_GREY,
	display = "E", color=colors.DARK_GREY,
	desc = [[로스고로스는 강력한 공허의 원소이며, 별들의 사이에 존재하는 공허에서 온 존재입니다. 이것들은 지표면에서는 거의 볼 수 없는 존재입니다.]],

	combat = { dam=resolvers.levelup(resolvers.mbonus(40, 15), 1, 1.2), atk=15, apr=15, dammod={mag=0.8}, damtype=DamageType.ARCANE },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	infravision = 10,
	life_rating = 8,
	life_regen = 0,
	rank = 2,
	size_category = 3,
	levitation = 1,
	can_pass = {pass_void=70},

	autolevel = "dexmage",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=10, dex=8, mag=6, con=16 },

	resists = { [DamageType.PHYSICAL] = -30, [DamageType.ARCANE] = 100 },

	no_breath = 1,
	poison_immune = 1,
	disease_immune = 1,
	cut_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	knockback_immune = 1,
	confusion_immune = 1,
	power_source = {arcane=true},
}

newEntity{ base = "BASE_NPC_LOSGOROTH",
	name = "losgoroth", color=colors.GREY,
	kr_name = "로스고로스",
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(40,60),
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.ARCANE] = resolvers.mbonus(20, 10), },

	resolvers.talents{
		[Talents.T_VOID_BLAST]={base=1, every=7, max=7},
	},
}

newEntity{ base = "BASE_NPC_LOSGOROTH",
	name = "manaworm", color=colors.BLUE,
	kr_name = "마나 벌레",
	level_range = {2, nil}, exp_worth = 1,
	desc = [[마나 벌레는 마법 사용자의 마나를 먹고 사는 로스고로스입니다. 항상 주문을 사용하는 이에게 접근하며, 그 또는 그녀에게 딱 달라붙어 마나를 빨아먹습니다.]],
	rarity = 3,
	max_life = resolvers.rngavg(40,60),
	movement_speed = 0.7,
	combat_armor = 0, combat_def = 20,
	on_melee_hit = { [DamageType.ARCANE] = resolvers.mbonus(20, 10), },
	combat = { atk=10000, apr=10000, damtype=DamageType.MANAWORM }, -- They can not miss
}
