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
	desc = [[거미 공포증...]],
	body = { INVEN = 10 },

	max_stamina = 150,
	rank = 1,
	size_category = 2,
	infravision = 10,

	autolevel = "spider",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	global_speed_base = 1.2,
	stats = { str=10, dex=17, mag=3, con=7 },
	combat = { dammod={dex=0.8} },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "orb spinner", color=colors.UMBER,
	kr_name = "오브 방적거미",
	desc = [[커다란 갈색 거미류입니다. 그 이빨에서는 이상한 액체가 흐르고 있습니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,40),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=15, apr=3, damtype=DamageType.CLOCK, },
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "orb weaver", color=colors.DARK_UMBER,
	kr_name = "오브 무당거미",
	desc = [[거미줄을 짜고 있는 커다란 갈색 거미류입니다. 당신이 그 일을 방해해서 기분이 나쁜 것 같습니다.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(40,60),
	combat_armor =2, combat_def = 4,
	combat = { dam=resolvers.levelup(6, 1, 0.8), atk=15, apr=3, damtype=DamageType.TEMPORAL, },
	resolvers.talents{
		[Talents.T_LAY_WEB]=1,
		[Talents.T_DIMENSIONAL_STEP]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "fate spinner", color=colors.SLATE,
	kr_name = "파멸의 방적거미",
	desc = [[한 마리 말 만큼이나 커다란 이 거대 거미는, 그 이빨과 발톱으로 당신을 위협하고 있습니다.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	size_category = 4,
	max_life = resolvers.rngavg(60,70),
	combat_armor = 3, combat_def = 5,
	combat = { dam=resolvers.levelup(9, 1, 0.9), atk=15, apr=4, damtype=DamageType.CLOCK, },
	resolvers.talents{
		[Talents.T_LAY_WEB]=1,
		[Talents.T_SPIDER_WEB]=1,
		[Talents.T_DIMENSIONAL_STEP]=1,
		[Talents.T_TURN_BACK_THE_CLOCK]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "fate weaver", color=colors.WHITE,
	kr_name = "파멸의 무당거미",
	desc = [[커다란 흰색 거미입니다.]],
	level_range = {4, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 4,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=15, apr=3, damtype=DamageType.WASTING, },

	talent_cd_reduction = {[Talents.T_RETHREAD]=-10},

	resolvers.talents{
		[Talents.T_SPIN_FATE]=2,
		[Talents.T_BANISH]=2,
		[Talents.T_RETHREAD]=2,
		[Talents.T_STATIC_HISTORY]=2,
	},
}

newEntity{ base = "BASE_NPC_SPIDER", define_as = "WEAVER_QUEEN",
	name = "Weaver Queen", color=colors.WHITE,
	kr_name = "무당거미 여왕",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_weaver_queen.png", display_h=2, display_y=-1}}},
	desc = [[커다란 흰색 거미입니다.]],
	level_range = {7, nil}, exp_worth = 1,
	unique = true,
	rarity = false,
	max_life = 150, life_rating = 10, fixed_rating = true,
	rank = 4,
	tier1 = true,
	size_category = 4,
	instakill_immune = 1,
	no_rod_recall = 1,

	combat_armor = 3, combat_def = 4,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=15, apr=3, damtype=DamageType.CLOCK, },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },


	inc_damage = {all=-20},
	healing_factor = 0.5,
	talent_cd_reduction = {[Talents.T_RETHREAD]=-10},

	resolvers.talents{
		[Talents.T_SPIN_FATE]=2,
		[Talents.T_BANISH]=2,
		[Talents.T_RETHREAD]=2,
		[Talents.T_STATIC_HISTORY]=2,
		[Talents.T_FADE_FROM_TIME]=3,
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-point-zero", engine.Quest.COMPLETED, "morass")
		require("engine.ui.Dialog"):simplePopup("무당거미 여왕", "여왕거미를 무찌르자, 그녀가 지배하던 것으로 보이는 시간의 흐름을 발견하였습니다. 이 흐름이 균열 사이로 지나가고 있습니다.")
		local rift = game.zone:makeEntityByName(game.level, "terrain", "RIFT_HOME")
		game.zone:addEntity(game.level, rift, "terrain", self.x, self.y)
	end,
}
