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

local Talents = require("engine.interface.ActorTalents")

newEntity{ --rodent base
	define_as = "BASE_NPC_RODENT",
	type = "vermin", subtype = "rodent",
	display = "r", color=colors.WHITE,
	can_multiply = 2,
	body = { INVEN = 10 },
	infravision = 10,
	sound_moam = {"creatures/rats/rat_hurt_%d", 1, 2},
	sound_die = {"creatures/rats/rat_die_%d", 1, 2},
	sound_random = {"creatures/rats/rat_%d", 1, 3},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=8, dex=15, mag=3, con=5 },
	combat = {sound="creatures/rats/rat_attack"},
	combat_armor = 1, combat_def = 1,
	rank = 1,
	size_category = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant white mouse", color=colors.WHITE,
	kr_display_name = "흰 거대 생쥐",
	level_range = {1, 3}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant brown mouse", color=colors.UMBER,
	kr_display_name = "갈색 거대 생쥐",
	level_range = {1, 3}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant white rat", color=colors.WHITE,
	kr_display_name = "흰 거대 쥐",
	level_range = {1, 4}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=0, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant brown rat", color=colors.UMBER,
	kr_display_name = "갈색 거대 쥐",
	level_range = {1, 4}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=0, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant rabbit", color=colors.UMBER,
	kr_display_name = "거대 토끼",
	desc = [[토끼를 죽이자, 토끼를 죽여, 토끼를 주우우우욱이자.]], --@@ 이스터애그인 듯 - 만화의 그 토끼가 왜빗 -- 여우 팬그램도 그렇고, 정말 번역하기 난감한게 많네요 -_-;
	level_range = {1, 4}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(20,30),
	combat = { dam=8, atk=0, apr=10 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant crystal rat", color=colors.PINK,
	kr_display_name = "거대 수정 쥐",
	desc = [[털 대신 수정이 자라나는 쥐로, 그로 인해 더 높은 방어력을 가집니다.]],
	level_range = {1, 5}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(35,50),
	combat = { dam=7, atk=0, apr=10 },
	combat_armor = 4, combat_def = 2,
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant grey mouse", color=colors.SLATE,
	kr_display_name = "회색 거대 생쥐",
	level_range = {1, 3}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=5, atk=0, apr=10 },
	resolvers.talents{ [Talents.T_CRAWL_POISON]=1 },
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "giant grey rat", color=colors.SLATE,
	kr_display_name = "회색 거대 쥐",
	level_range = {1, 4}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=7, atk=0, apr=10 },
	resolvers.talents{ [Talents.T_CRAWL_POISON]=1 },
}
