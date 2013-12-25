-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

newEntity{ define_as = "BEN_CRUTHDAR",
	allow_infinite_dungeon = true,
	type = "humanoid", subtype = "human", unique = true,
	name = "Ben Cruthdar, the Cursed",
	kr_name = "저주받은 자, 벤 크루스달",
	display = "p", color=colors.VIOLET,
	desc = [[매우 위험해 보이는 광인입니다. 그는 큰 도끼를 들고 있으며, 그것을 사용하려 합니다.
음울한 기운이 그에게서 뿜어져 나옵니다.]],
	level_range = {10, nil}, exp_worth = 2,
	max_life = 250, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=15, wil=18, con=20 },
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="battleaxe", tome_drops="boss", force_drop=true, autoreq=true}, },
	resolvers.drops{chance=100, nb=2, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_GLOOM]=3,
		[Talents.T_WEAKNESS]=3,
		[Talents.T_DISMAY]=3,
		[Talents.T_UNNATURAL_BODY]=4,
		[Talents.T_DOMINATE]=1,
		[Talents.T_BLINDSIDE]=3,
		[Talents.T_SLASH]=3,
		[Talents.T_RECKLESS_CHARGE]=1,
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriorwill",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "healing infusion"),

	on_die = function(self, who)
		local Chat = require "engine.Chat"
		Chat.new("lumberjack-quest-done", self, game.player:resolveSource()):invoke()
	end,
}

newEntity{ defined_as = "LUMBERJACK",
	type = "humanoid", subtype = "human",
	name = "lumberjack",
	kr_name = "나무꾼",
	display = "p", color=colors.UMBER, faction = "allied-kingdoms",
	desc = [[나무꾼입니다. 나무를 자르는 것이 그의 일이고, 꿈이며 열정입니다.]],
	level_range = {1, 1}, exp_worth = 1,
	rarity = 1,
	max_life = 100, life_rating = 10,
	stats = { str=20 },
	rank = 2,
	size_category = 2,
	infravision = 10,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="flee_dmap", },

	on_die = function(self, who)
		game.player:resolveSource():hasQuest("lumberjack-cursed"):lumberjack_dead()
	end,
}
