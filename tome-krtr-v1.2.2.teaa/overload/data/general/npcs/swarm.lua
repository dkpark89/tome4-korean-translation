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

--updated 7:33 PM 1/28/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_INSECT",
	type = "insect", subtype = "swarms",
	display = "I", color=colors.WHITE,
	can_multiply = 2,
	desc = "부우우우우우우우우우우우우우웅.",
	body = { INVEN = 1 },
	autolevel = "warrior",
	sound_moam = {"creatures/swarm/mswarm_%d", 1, 4},
	sound_die = "creatures/swarm/mswarm_die",
	sound_random = {"creatures/swarm/mswarm_%d", 1, 4},
	combat = {sound={"creatures/swarm/mswarm_%d", 1, 4}, sound_miss={"creatures/swarm/mswarm_%d", 1, 4}},
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=1, dex=20, mag=3, con=1 },
	global_speed_base = 2,
	infravision = 10,
	combat_armor = 1, combat_def = 10,
	rank = 1,
	size_category = 1,
	cut_immune = 1,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "midge swarm", color=colors.UMBER, image="npc/midge_swarm.png",
	kr_name = "작은 곤충 무리",
	desc = "피를 원하는 작은 곤충들의 무리입니다.",
	level_range = {1, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(1,2),
	combat = { dam=1, atk=0, apr=20 },
	resolvers.talents{
		[Talents.T_HEIGHTENED_REFLEXES]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "bee swarm", color=colors.GOLD, image="npc/bee_swarm.png",
	kr_name = "벌떼",
	desc = "당신이 벌집으로 가까이 다가가자, 위협적으로 윙윙거리기 시작합니다.",
	level_range = {2, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(1,3),
	combat = { dam=2, atk=0, apr=20 },

	resolvers.talents{
		[Talents.T_BITE_POISON]={base=1, every=5, max=8},
		[Talents.T_HEIGHTENED_REFLEXES]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "hornet swarm", color=colors.YELLOW, image="npc/hornet_swarm.png",
	kr_name = "말벌떼",
	desc = "그들의 영역을 침범하면, 그들은 어떤 대가를 치르더라도 그 앞을 막아섭니다.",
	sound_moam = {"creatures/bee/bee_%d", 1, 4},
	sound_die = "creatures/bee/bee_die",
	sound_random = {"creatures/bee/bee_%d", 1, 4},
	level_range = {3, 25}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(3,5),
	combat = { dam=5, atk=5, apr=20 },

	resolvers.talents{
		[Talents.T_BITE_POISON]={base=2, every=5, max=8},
		[Talents.T_HEIGHTENED_REFLEXES]={base=0, every=5, max=5},
	},
}

newEntity{ base = "BASE_NPC_INSECT",
	name = "hummerhorn", color=colors.YELLOW, image="npc/hummerhorn.png",
	kr_name = "허밍뿔",
	desc = "윙윙거리며 날아다니는 뿔이라는 의미의 이름을 한 거대 말벌로, 침에서는 독액이 흐릅니다. ",
	sound_moam = {"creatures/bee/bee_%d", 1, 4},
	sound_die = "creatures/bee/bee_die",
	sound_random = {"creatures/bee/bee_%d", 1, 4},
	level_range = {16, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,7),
	combat = { dam=10, atk=15, apr=20 },
	can_multiply = 4,

	resolvers.talents{
		[Talents.T_BITE_POISON]={base=3, every=10, max=8},
		[Talents.T_HEIGHTENED_REFLEXES]={base=0, every=5, max=5},
		[Talents.T_POISONOUS_SPORES]={base=0, every=15, max=2},
	},
	ingredient_on_death = "HUMMERHORN_WING",
}
