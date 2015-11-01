-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
	desc = [[Arachnophobia...]],
	body = { INVEN = 10 },

	max_stamina = 150,
	rank = 1,
	size_category = 2,
	infravision = 10,

	autolevel = "spider",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=10, dex=17, mag=3, con=7 },
	combat = { dammod={dex=0.8} },
	combat_armor = 1, combat_def = 1,
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "weaver hatchling", color=colors.LIGHT_STEEL_BLUE, image="npc/spiderkin_spider_weaver_young.png",
	desc = [[A nearly translucent spider hatchling.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,	size_category = 1,
	max_life = resolvers.rngavg(10,20),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=5, apr=3, damtype=DamageType.WASTING, },
	make_escort = {
		{type = "spiderkin", subtype = "spider", name="weaver hatchling", number=2, no_subescort=true},
	},
	resolvers.talents{
		[Talents.T_DIMENSIONAL_STEP]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "orb spinner", color=colors.UMBER,
	desc = [[A large brownish arachnid, its fangs drip with a strange fluid.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(20,40),
	combat_armor = 1, combat_def = 3,
	combat = { dam=resolvers.levelup(5, 1, 0.7), atk=5, apr=3, damtype=DamageType.TEMPORAL, },
	resolvers.talents{
		[Talents.T_TEMPORAL_BOLT]=1,
	},
	make_escort = {
		{type = "spiderkin", subtype = "spider", name="orb weaver", number=1, no_subescort=true},
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "orb weaver", color=colors.DARK_UMBER,
	desc = [[A large brownish arachnid spinning its web.  It doesn't look pleased that you've disturbed its work.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 10, -- rarely appears alone
	max_life = resolvers.rngavg(40,60),
	combat_armor =2, combat_def = 4,
	combat = { dam=resolvers.levelup(6, 1, 0.8), atk=10, apr=3, damtype=DamageType.TEMPORAL, },
	resolvers.talents{
		[Talents.T_LAY_WEB]=1,
		[Talents.T_SPIDER_WEB]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "fate spinner", color=colors.SLATE,
	desc = [[Easily as big as a horse, this giant spider menaces at you with claws and fangs.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 2, rank = 2,
	size_category = 4,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 5,
	combat = { dam=resolvers.levelup(9, 1, 0.9), atk=15, apr=4, damtype=DamageType.WASTING, },
	resolvers.talents{
		[Talents.T_DIMENSIONAL_STEP]=1,
		[Talents.T_WARP_MINE_TOWARD]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER",
	name = "fate weaver", color=colors.WHITE,
	desc = [[A large white spider.]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 3, rank = 2,
	max_life = resolvers.rngavg(70,100),
	combat_armor = 3, combat_def = 4,
	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=15, apr=3, damtype=DamageType.TEMPORAL, },
	
	resolvers.talents{
		[Talents.T_SPIN_FATE]=1,
		[Talents.T_WEBS_OF_FATE]=1,
		[Talents.T_FATEWEAVER]=1,
		[Talents.T_RETHREAD]=1,
	},
}

newEntity{ base = "BASE_NPC_SPIDER", define_as = "WEAVER_QUEEN",
	name = "Weaver Queen", color=colors.WHITE, female=1,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_weaver_queen.png", display_h=2, display_y=-1}}},
	desc = [[A large white spider.]],
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
	
	summon = {{type = "spiderkin", subtype = "spider", name="weaver hatchling", number=1, hasxp=false}},
	
	resolvers.talents{
		[Talents.T_SPIN_FATE]=2,
		[Talents.T_WEBS_OF_FATE]=2,
		[Talents.T_FATEWEAVER]=2,
		[Talents.T_PHASE_PULSE]=2,
		[Talents.T_SUMMON]=1,
		[Talents.T_TEMPORAL_BOLT]=1,	
	},
	
	on_move = function(self)
		if rng.percent(50) then
			self:forceUseTalent(self.T_ANOMALY_WORMHOLE, {silent=true, ignore_energy=true})
		end
	end,

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-point-zero", engine.Quest.COMPLETED, "morass")
		require("engine.ui.Dialog"):simplePopup("Weaver Queen", "As you vanquish the queen you notice a temporal thread that seems to have been controlling her. It seems to go through a rift.")
		local rift = game.zone:makeEntityByName(game.level, "terrain", "RIFT_HOME")
		game.zone:addEntity(game.level, rift, "terrain", self.x, self.y)
	end,
}
